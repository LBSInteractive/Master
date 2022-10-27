/*
Initialization sequence
Every other object will register its initialization function on load to be called later from Connector object (late binding).
Caveat: we may face circular dependencies here.

jquery.subscribe plug-in will be used for subscriber/publisher model.

Listens to events:
"workpace/connectionAccepted"
"workspace/connected"
"workspace/disconnected"

*/

(function(window, jQuery, undefined) {

var _log = Log ? Log.log : console.log;

var initFunctions = []; // [function, ...]

var version = getVersion();

var debugInfoVisible = true;
var logVisible = true;
var attachedDataVisible = false;
var statusConnected = false;
var initCompleted = false;
var useWebSockets = false;

//CI Connection Information
var connectionDate = new Date().getTime();
connectionDate = connectionDate + "a";
var CI_connectionData = '"CI":"' + connectionDate + '"';
var connectionTimeout;

var clickToDialNum = "";

var CTI_MC = "ctiAuraMessageChannel__c";
var CTI_MC_SUBSCRIPTION = null;


function registerInitFn(initFn) {
	// todo
}

function init() {
    _log("Version = " + version);
    var serviceCloudConsoleOnly = "false";
    
    var autoLoggingEnabled = getURLParam("autologgingenabled", "true");       
    if(autoLoggingEnabled.toLowerCase() == "true"){
    	Log.setStoreLog(true);
    	jQuery('#saveLog').attr('checked', true);
    	_log("Version = " + version);        	
    }    
    _log("autoLoggingEnabled from url = " + autoLoggingEnabled);
    
    jQuery('#logoTd').html('<img src="' + gl_resources["logo"] + '">');
    jQuery('#title').hide(); 

    try {
            jQuery.subscribe("workspace/connectionAccepted", connectionInitialized, []); 
			jQuery.subscribe("workspace/connected", showConnectedStatus, [true]);
		    jQuery.subscribe("workspace/disconnected", showConnectedStatus, [false]);

            sforce.opencti.getCallCenterSettings({callback : initCallCenter});
            
            //Initiating ctiAuraMessageChannel for enabling communication between cti and aura
            initLightningChannel();
    }
    catch (e) {
    	_log("Could not initialize Connector: " + e);
    }
}



function getOption(callCenterDefinition, optionName, defValue) {
	var value = callCenterDefinition['/WorkspaceOptions/' + optionName];
    if (value) {
        _log("getOption: " + optionName + ": " + value);
        return value;
    } else {
    	_log("getOption: " + optionName + " (default): " + defValue);
    	return defValue;
    }
}

function initCallCenter(response) {
	// set up display
	jQuery('#title').show(); 
    sforce.opencti.setSoftphonePanelIcon({key:"info_alt"});
    sforce.opencti.setSoftphoneItemLabel({label: nickName});
    sforce.opencti.setSoftphonePanelLabel({label: version});
	
    // set defaults
    var useLocalHost = true;
    var pollURL = "http://localhost";
    var url127 = "http://127.0.0.1";
    var pollURLHTTPS = "https://localhost";
    var url127HTTPS = "https://127.0.0.1";
    var useHTTPS = 'false';
    var pollPort = "0";
    var pollQueueTimeout = 100;
    var pollQueueTimeoutError = 500;
    var requestTimeout = 5000;

    _log('getCallCenterSettings success = ' + response.success);
    if(response.success){  
    	var callCenterDefinition = response.returnValue;
		useLocalHost = getOption(callCenterDefinition, "UseLocalHost", useLocalHost);
		pollPort = getURLParam("port", pollPort);
	    _log('pollPort from URL - ' + pollPort);
		if (pollPort == "0") {
			pollPort = getOption(callCenterDefinition, "PollPort", "5050");
		}
		pollQueueTimeout = getOption(callCenterDefinition, "PollQueueTimeout", pollQueueTimeout);
		pollQueueTimeoutError = getOption(callCenterDefinition, "PollQueueTimeoutError", pollQueueTimeoutError);
		requestTimeout = getOption(callCenterDefinition, "RequestTimeout", requestTimeout);
        useHTTPS = getOption(callCenterDefinition, "SecureConnection", useHTTPS);
        useWebSockets = getOption(callCenterDefinition, "UseWebSockets", 'false').toLowerCase() == 'true';

		if (useLocalHost === 'false') {
			if(useHTTPS === 'false')
				pollURL = url127;
			else
				pollURL = url127HTTPS;
        }
		else {
			if(useHTTPS === 'false')
				pollURL = pollURL;
			else
				pollURL = pollURLHTTPS;
		}
        _log('getCallCenterSettings: pollURL - ' + pollURL);
    }

	if(typeof(Storage) !== "undefined" && window!=null && window.sessionStorage!=null)
	{
		var sessionInfo = window.sessionStorage.getItem("Genesys_sfdc_CI");
		if(sessionInfo!=null)
		{
			CI_connectionData = sessionInfo;				
			connectionDate = CI_connectionData.substring(CI_connectionData.lastIndexOf(':"')+2, CI_connectionData.lastIndexOf('"'));
		}
		else
			window.sessionStorage.setItem("Genesys_sfdc_CI", CI_connectionData);
	}

        Workspace.setParameters({
			"pollUrl": pollURL,
			"pollPort": pollPort,
			"requestTimeout": requestTimeout,
			"pollQueueTimeout": pollQueueTimeout,
			"pollQueueTimeoutError": pollQueueTimeoutError,
            "CI_connectionData": CI_connectionData,
            "useWebSockets": useWebSockets
		});
        // start out in disconnect state 
        showConnectedStatus(false);

        // Initialize logging UI
        showLog(false);
        
        //Do not retry a connection with this window if we've been rejected already
        var canConnect = true;
        if(typeof(Storage) !== "undefined" && window!=null && window.sessionStorage!=null)
        {
        	canConnect = window.sessionStorage.getItem("Genesys_sfdc_Banned");
        }
        if(canConnect==null || canConnect==true || canConnect=="True")
        {
            //don't continue until a Connection Accepted message is received
            //Create Websocket client and handle WS connection if UseWebSocket call center option is enabled - EASFP-9
            if(useWebSockets)
                Workspace.createWSClient();
            else
                Workspace.requestConnection(); 
        }
        else
        {
        	_log('This browser session was already denied.');
        }        
}

//handle response from workspace
function connectionInitialized(){
    _log("connectionInitialized");
    //Continue with polling if websocket connection mode is not enabled  - EASFP-9
    if(!useWebSockets){
        _log('Start polling');
        Workspace.poll(100); 
        _log('Polling started');
    }
    if (!initCompleted) {
    	canCommunicate();
    	initCompleted = true;
    } 
}

//if we are tracking the selected object
function trackFocusedObject()
{
    //@MSavoj 04-19-2017 Added track focus content
    _log('trackFocusedObject started');
    sforce.interaction.getPageInfo(function(o) {
	if(o!=null && o.result!=null)
	{ 
	    _log('trackFocusedObject o.result=' + o.result);
	    var jsonResult = jQuery.parseJSON(o.result);
	    if(jsonResult!=null && jsonResult.objectId!=null)
	    {
		_log('trackFocusedObject jsonResult=' + jsonResult);
		var objectId = jsonResult.objectId;
		_log("trackFocusedObject Object selected= " + objectId);
		if (objectId != '') {
		    Workspace.sendFocusChange(objectId,false);
		}
	    }
	}
    });	

}

// connection is made, enable features
function canCommunicate() {
	
    var dialListener = function (payload) {
        if (payload == null) {
            return;
        }

        /*var result = JSON.parse(response.result);
        var numberToCall = result.number;
        var objectId = result.objectId;*/
        var numberToCall = payload.number;
        var objectId = payload.recordId;

        // Keep formatting - workspace will take care of removing chars based on
        // expression.phone-number.supported-characters 
        //numberToCall = numberToCall.replace(/\D/g, '');

        var msg = {
            action: 'Dial',
            CI : connectionDate,
            actionData: { number: numberToCall, sfdcObjectId: objectId  }
        };
        clickToDialNum = numberToCall;
        _log("clickToDialNum = " + clickToDialNum);
        Workspace.send(JSON.stringify(msg));
    };
    sforce.opencti.onClickToDial({listener:dialListener});


    var enableClickToDialResponse = function (response){
    	 _log("ClickToDial = " + response.success);
    }
    sforce.opencti.enableClickToDial({callback:enableClickToDialResponse});

   
    _log("Lightning - add window event listener");
    window.addEventListener('message', receiveWindowMessage, false);
    
    
    var navigation = function(payload){
    	_log("navigation occurred");
    	_log("   payload.url = " + payload.url);
    	_log("   payload.recordId = " + payload.recordId);
    	_log("   payload.recordName = " + payload.recordName);
    	_log("   payload.objectType = " + payload.objectType);

    	payload = JSON.stringify(payload);
    	jQuery.publish("connector/message",[payload]);

    }
    sforce.opencti.onNavigationChange({listener: navigation});
    jQuery('#debug').show();
    var wsParams = Workspace.getParameters();
    jQuery('#port').append(wsParams.pollPort);

    //SFP-5: Receive presence change notifications
    sforce.console.addEventListener(sforce.console.ConsoleEvent.PRESENCE.STATUS_CHANGED, onAgentStatusChanged);

}

//SFP-5: on status change, sends the current status to WDE
var onAgentStatusChanged = function (result){
	_log('Omni Channel Status Changed - Result: ' + JSON.stringify(result));
	Workspace.sendAgentPresenceStatus('', result.statusApiName);	    	
};


////////////////////////////////////////////////////////////////////////////////////////
// *** Request received from other VF pages **** //
////////////////////////////////////////////////////////////////////////////////////////

// todo change to event subscription
function receiveSFMessage(result) {
    //receive message from Salesforce fireEvent - THIS DOES NOT APPLY TO LIGHTNING
    //var myObj = eval('(' + result.message + ')');
    var myObj = JSON.parse(result.message);
    _log("receiveSFMessage CTIEvent = " + myObj.action);
    if (myObj.action == "ObjectSelected") {
        processObjectSelected(result.message);
    }
    if (myObj.action == "AttachData") {
    	myObj.CI = connectionDate;
        _log("Calling processAttachData with " + JSON.stringify(myObj));
        //Workspace.processAttachData(result.message);
        Workspace.processAttachData(JSON.stringify(myObj));
    }
    if (myObj.action == "MarkDone") {
    	myObj.CI = connectionDate;
        _log("Calling processMarkDone with " + JSON.stringify(myObj));
        //Workspace.processAttachData(result.message);
        Workspace.processMarkDone(JSON.stringify(myObj));
    }
}

function receivedClientReqMessage(result){
	_log("in receivedClientReqMessage");
	jQuery.publish("client/req_message", [result]);
}
/*
// todo change to event subscription
function receiveWindowMessage(event) {
    //receive message from window listener
    //_log("receiveWindowMessage = " + event.data);
    var messageData = event.data;
    if(messageData != null){
    	_log("receiveWindowMessage = " + messageData.methodName);
    	return;
    }
    var n = s.indexOf("AttachData");
    if (n > -1) {
    	_log("receiveWindowMessage = " + s);
    	var msg = jQuery.parseJSON(s);
        msg.CI = connectionDate;
        _log("Calling processAttachData with " + JSON.stringify(msg));
        Workspace.processAttachData(JSON.stringify(msg));
        return;
    }
    n = s.indexOf("MarkDone");
    if (n > -1) {
    	_log("receiveWindowMessage = " + s);
    	var msg = jQuery.parseJSON(s);
        msg.CI = connectionDate;
        _log("Calling processMarkDone with " + JSON.stringify(msg));
        Workspace.processMarkDone(JSON.stringify(msg));
        return;
    } 
    n = s.indexOf("GetInteractions");
    if(n> -1){
    	_log("GOT MESSAGE");
    }
    //_log("receiveWindowMessage no processing");
}
*/

function receiveWindowMessage(event) {
    //receive message from window listener
    if (event != null && event.data != null){
        _log("receiveWindowMessage = " + event.data);
        if (event.data.action != null){
            if (event.data.action === "AttachData")
        	{
            	event.data.CI=connectionDate;
                Workspace.processAttachData(JSON.stringify(event.data));
        	    return;
            }
            if (event.data.action === "MarkDone")
        	{
            	event.data.CI=connectionDate;
        		Workspace.processMarkDone(JSON.stringify(event.data));
        		return;
            } 
            if (event.data.action === "GetInteractions")
        	{
            	_log("GOT MESSAGE");
            }
        }
    }
    else
	 _log("receiveWindowMessage : event or event.data is null." );
}

function showInteractionByTabId(tabId) {
    if (tabId == null) {
        _log('showInteractionByTabId: tabId is null');
        return;
    }
    _log("showInteractionByTabId: tabId is not null");
    var ixnId = Salesforce.getIxnId(tabId);
    if (!ixnId) {
        _log('showInteractionByTabId: could not find match');
        return;
    }
    _log('showInteractionByTabId: found match, sending to IWS');
    //Workspace.send('{"action":"ShowInteraction","actionData":{"interactionId":"' + ixnId + '"}}');
    var msg = {
         	action : 'ShowInteraction',
         	CI : connectionDate,
         	actionData : { "interactionId":ixnId }
    };
    Workspace.send(JSON.stringify(msg));
}


// todo change to event subscription
function processObjectSelected(result) {
    // Search page returns the following:
    var objSelected = JSON.parse(result);
    _log("processObjectSelected for " + objSelected.id);
    if (objSelected.id != '') {
        //inform workspace of SFobject id for subsequent use in activity creation and transfer
        //check for Case
    	if(objSelected.id.substring(0, 3) == '500'){
    		gl_WorkspaceConnectorController.findContactFromcase(objSelected.id, function(o) {
    			if (o != null) {
    				//screen pop the contact
    				Salesforce.screenPop(o);
    				var newData = '{"sfdcObjectId":"' + o + '","id":"' + objSelected.interactionId + '"}';
    				Workspace.sendAttachData(newData);
    		        var newData = '{"sfdcCaseId":"' + objSelected.id + '","id":"' + objSelected.interactionId + '"}';
    		        Workspace.sendAttachData(newData);
    			}
    			else {
    		        var newData = '{"sfdcObjectId":"' + objSelected.id + '","id":"' + objSelected.interactionId + '"}';
    		        Workspace.sendAttachData(newData);
    			}
    		});
    	}
    	else{
	        var newData = '{"sfdcObjectId":"' + objSelected.id + '","id":"' + objSelected.interactionId + '"}';
	        Workspace.sendAttachData(newData);
    	}
        //Salesforce.addIxnWindow(objSelected.interactionId, objSelected.id);
    }
}


////////////////////////////////////////////////////////////////////////////////////////
// *** MISC Functions **** //
////////////////////////////////////////////////////////////////////////////////////////

function getIconName(connected, debugInfoVisible) {
	return (debugInfoVisible ? "minus" : "plus") + "_" + (connected ? "green" : "red");
}

function updateLogElement() {
    Log.setLogElementId((debugInfoVisible && logVisible) ? "log" : null); // Stop Log writing to page element
}

function updateSize() {
	var w = debugInfoVisible ? 300 : 200;
	var h = jQuery("#title").outerHeight();

	if (attachedDataVisible) {
		var adh = jQuery("#attDataHeader").outerHeight() * 3;
		h += Math.min(adh, jQuery("#attDataContent").outerHeight());
		w = 300;
	}
	
	if (debugInfoVisible) {
		h += jQuery("#portStatus").outerHeight();
		h += jQuery("#logHeader").outerHeight();
		if (logVisible) {
			h += 235; // Log text div
		}
	}
	
	if(h >= 240 && h <= 700)
		sforce.opencti.setSoftphonePanelHeight({heightPX:h});

	
	if(w >= 200 && w <= 1240)
		sforce.opencti.setSoftphonePanelWidth({widthPX:w});  
}

function showConnectedStatus(connected) {
    //_log("showConnectedStatus statusConnected = " + statusConnected);
    //_log("showConnectedStatus debugInfoVisible = " + debugInfoVisible);
    //_log("showConnectedStatus connected = " + connected);

    statusConnected = connected;
    
    //Lightning - for icons see https://www.lightningdesignsystem.com/icons/
    var icon_connected = "success";
    var icon_disconnected = "warning";
    var icon_display = statusConnected ? icon_connected : icon_disconnected;
    sforce.opencti.setSoftphoneItemIcon({key:icon_display});
}

function switchDebugInfo() {
	showDebugInfo(!debugInfoVisible);
}

function showDebugInfo(newDebugInfoVisible) {
    //_log("showDebugInfo statusConnected = " + statusConnected);
    //_log("showDebugInfo debugInfoVisible = " + debugInfoVisible);
    //_log("showDebugInfo newDebugInfoVisible = " + newDebugInfoVisible);

    jQuery('#debug').show();
    debugInfoVisible = newDebugInfoVisible;

    updateLogElement();
    updateSize();
}

function switchLog() {
	showLog(!logVisible);
}

function showLog(newLogVisible) {
	var iconName;
	if (newLogVisible) {
		iconName = "minus_blue";
		jQuery("#logContainer").show();
	}
	else {
		iconName = "plus_blue";
		jQuery("#logContainer").hide();
	}

	jQuery("#logSwitchIcon").html('<img src="' + gl_resources[iconName] + '">');

	logVisible = newLogVisible;

    updateLogElement();
    updateSize();
}

function showAttachedData(data) {
	var el = jQuery("#attDataContent");
	el.empty();

	if(data.length == 0){
		hideAttachedData();
		return;
	}
	var ud = new DataPanel(el, "en", true);
	ud.setData(data);

	jQuery("#attDataPanel").show();
	attachedDataVisible = true;
    updateSize();
}

function hideAttachedData() {
	jQuery("#attDataPanel").hide();
	jQuery("#attDataContent").empty();
	attachedDataVisible = false;
    updateSize();
}

function activateLogging(){
	Log.setStoreLog(true);
	jQuery('#saveLog').attr('checked', true);
	_log("autoLoggingEnabled ");
}

////////////////////////////////////////////////////////////////////////////////////////
// *** Lightning Message Service **** //
////////////////////////////////////////////////////////////////////////////////////////

//Mark done component to communicate with cti
function initLightningChannel(){
    subscribeToCTI_MC();
}
function subscribeToCTI_MC() {
    if (!CTI_MC_SUBSCRIPTION) {
        console.log("subscribing......");
        sforce.opencti.subscribe({channelName: CTI_MC, listener: onPublishMessage, callback: subscribeCTI_MCCallback});
    }
}

function unsubscribeToCTI_MC() {
    if (CTI_MC_SUBSCRIPTION) {
        sforce.opencti.unsubscribe({subscription: CTI_MC_SUBSCRIPTION, callback: lightningMessageServiceCallback});
        CTI_MC_SUBSCRIPTION = null;
    }
}

function publishCTI_MC() {
    /* const message = {
        from: "LightningMessageService_OpenCTI_TestPage",
        type: "CTI_MC",
        time: new Date().toLocaleTimeString()
    };

    sforce.opencti.publish({channelName: CTI_MC, message: message, callback: lightningMessageServiceCallback});*/
}

function lightningMessageServiceCallback(result) {
    if (result.success) {
        console.log(result.returnValue);
    } else {
        console.log(result.errors);
    }
}

function subscribeCTI_MCCallback(result) {
    if (result.success) {
        console.log("subscribed! "+result.subscription);
        CTI_MC_SUBSCRIPTION = result.subscription;
    } else {
        console.log(result.errors);
    }
}

function onPublishMessage(message) {
    console.log("Incoming message from aura:"+JSON.stringify(message.message1, null, '\t'));
    message.message1.CI=connectionDate;
    Workspace.send(JSON.stringify(message.message1));
}

// Publish API
var Connector = {
	"init": init,
	"registerInitFn": registerInitFn,
	"switchLog": switchLog,
	"showAttachedData": showAttachedData,
	"hideAttachedData": hideAttachedData,
	"activateLogging" : activateLogging
};

window["Connector"] = Connector;

jQuery(document).ready(function() { Connector.init(); });

})(window, jQuery, undefined);
