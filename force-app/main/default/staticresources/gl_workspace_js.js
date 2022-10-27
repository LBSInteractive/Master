/*
Maintain connection to IWS.
Receive and dispatch event from IWS (depends on Events).
Send requests to IWS.
Fire events on connection established/lost.

Events will be delivered via pub/sub model.
Events:
workspace/connected
	Indicates that connection to IWS is established. Fired on each poll of IWS.
workspace/disconnected
	Indicates that connection to IWS is not established. Fired on each poll of IWS.
workspace/message
	Notifies of message received from IWS.
*/

(function(window, jQuery, undefined) {

var _log = Log ? Log.log : console.log;

var pollUrl;
var pollPort;
var requestTimeout;
var pollQueueTimeout;
var pollQueueTimeoutError;
var connectionTimeout = '';
var CI_connectionData;
var businessAttributes = {};
var autoOpenDataDisplay = "true";
var monitorSFDCSession = false;
var wdePresenceStatus = "";

var useWebSockets = undefined;
var webSocket = null;

////////////////////////////////////////////////////////////////////////////////////////
// *** AJAX Functions **** //
////////////////////////////////////////////////////////////////////////////////////////

function setParameters(params) {
	pollUrl = params.pollUrl;
	pollPort = params.pollPort;
	requestTimeout = params.requestTimeout;
	pollQueueTimeout = params.pollQueueTimeout;
	pollQueueTimeoutError = params.pollQueueTimeoutError;
    CI_connectionData = params.CI_connectionData;
    useWebSockets = params.useWebSockets;
}

function getParameters() {
	return {
		"pollUrl": pollUrl,
		"pollPort": pollPort,
		"requestTimeout": requestTimeout,
		"pollQueueTimeout": pollQueueTimeout,
		"pollQueueTimeoutError": pollQueueTimeoutError,
        "CI_connectionData": CI_connectionData,
        "useWebSockets": useWebSockets
	};
}

function poll(timeout) {
    setTimeout(function () {
    	//If we are monitoring the Salesforce session
	if(monitorSFDCSession)
	{
	    gl_WorkspaceConnectorController.testConnection(function(o) {
	        if (o == null) {
		    _log('Session expired, attempting to refresh connector');
		    document.location.reload();
		}
	    });
	}
        jQuery.ajax({
            url: pollUrl + ":" + pollPort + "/poll=" + "{" + CI_connectionData + "}" ,
            //url: pollUrl + ":" + pollPort + "/poll",
            timeout: requestTimeout,
            async: true,
            crossDomain: true,
            cache: false,
            dataType: 'jsonp',
            success: function(data) {
                if (data.action != 'NoWork') {
                    _log('JSON Received- ' + jQuery.param(data));
                    jQuery.publish("workspace/message", [data]);
                }

		//Track if the connection was denied so we don't keep retrying
		if (data.action != 'ConnectionDenied')
		{
                    poll(pollQueueTimeout);
                    jQuery.publish("workspace/connected", []);
		}
		else
		{
                    if(typeof(Storage) !== "undefined" && window!=null && window.sessionStorage!=null)
                    {
                    	window.sessionStorage.setItem("Genesys_sfdc_Banned", "true");
                    }
                    jQuery.publish("workspace/disconnected", []);	            	
		}	   
            },
            error: function(xhr, ajaxOptions, thrownError) {
                _log('work request error (' + pollPort + ') ' + xhr.status + ' ' + thrownError);

                jQuery.publish("workspace/disconnected", []);

                if (thrownError == 'timeout') {
                    requestConnection();	//If we timeout, we should request a new connection in case Workspace has been restarted, not continue polling
                }
                else {
                    poll(pollQueueTimeout);
                }
            }
        });

    }, timeout);
}

function send(message) {  
    //Passing message to WDE through websocket if UseWebsockets option is enabled - EASFP-9
    if(useWebSockets){
        sendToWSClient(message);
    }else{
        _log("send Sending:" + message);
        jQuery.ajax({
            url: pollUrl + ":" + pollPort,
            data:"/request=" + message,
            type: 'GET',
            processData: false,
            timeout: requestTimeout,
            async: false,
            crossDomain: true,
            cache: false,
            dataType: 'jsonp',
            success: function(data) {
                _log('Request sent - response = ' + data.action);
            },
            error: function(xhr, ajaxOptions, thrownError) {
                _log('Request sent error (' + pollPort + ') ' + ajaxOptions + ' - ' + xhr.status + ' ' + thrownError);
            }
        });
    }
}

//request connection from workspace
function requestConnection() {
    var connectMsg = '{"action":"ConnectionRequest","actionData":{},"pollInterval":"' + pollQueueTimeout + '",' + CI_connectionData + '}';
    _log("Sending ConnectionRequest");
    jQuery.ajax({
    	url: pollUrl + ":" + pollPort,
    	data: "/request=" + connectMsg,
    	type: 'GET',
        timeout: requestTimeout,     
        async: true,
        crossDomain: true,
        cache: false,
        dataType: 'jsonp',
        success: function(data) {
    		_log('JSON Received requestConnection- ' + jQuery.param(data));
	    	if (data.action == 'ConnectionAccepted') {
	    		//Will we try to track the SalesForce session?
	    		if(data.monitorSFDCSession!=null && data.monitorSFDCSession=='true')
	    			monitorSFDCSession = true;
	    		else
	    			monitorSFDCSession = false;
	    		_log('Monitor Salesforce session: ' + monitorSFDCSession);
	    		
	    		stopTimer();
	            requestBusinessAttributes();
	        }
	        else if (data.action == 'ConnectionDenied'){ //Don't retry again if the session was denied
	            stopTimer();
	            _log('Connection denied, do not retry');
	            if(typeof(Storage) !== "undefined" && window!=null && window.sessionStorage!=null)
	            {
	            	window.sessionStorage.setItem("Genesys_sfdc_Banned", "true");
	            }
	        }
	        else{ //ConnectionDenied
	            //start a timeout and try again
	            connectionTimeout = setTimeout('Workspace.requestConnection()', requestTimeout);
	        }
    	},
        error: function(xhr, ajaxOptions, thrownError) {
            _log('requestConnection error (' + pollPort + ') ' + xhr.status + ' ' + thrownError);
            connectionTimeout = setTimeout('Workspace.requestConnection()', requestTimeout);
        }
    });
} 

function stopTimer() {
	if (connectionTimeout != '') {
		clearTimeout(connectionTimeout);
	}
	connectionTimeout = '';
}

function notifyConnectionAccepted() {
	jQuery.publish("workspace/connectionAccepted", []);
}


//inform workspace so it can attach data
//input must be in JSON format
function processAttachData(objToProcess) {
    _log("processAttachData");
    //This request comes from Salesforce fireEvent or window listener
    send(objToProcess);
}

//inform workspace so it can attach data
//input must be in JSON format
function processMarkDone(objToProcess) {
	_log("processMarkDone");
	//This request comes from window listener
	send(objToProcess);
}

function sendAttachData(newData) {
    _log("sendAttachData - " + newData);
    send('{"action":"AttachData",' + CI_connectionData + ',"actionData":' + newData + '}');
    var myObj = jQuery.parseJSON(newData);
    _log("   myObj.sfdcObjectId = " + myObj.sfdcObjectId);
    if(myObj.sfdcObjectId != undefined){
        if(typeof(Storage) !== "undefined" && window!=null && window.sessionStorage!=null){
        	window.sessionStorage.setItem("Genesys_sfdc_objectId",myObj.sfdcObjectId);
        }
    }    	
}

function requestBusinessAttributes() {
    _log("Requesting Business Attributes");
    var message = '{"action":"GetData",' + CI_connectionData + ',"actionData":{"data":"data-display-attribute"}}';
    //Passing message to WDE through websocket if UseWebsockets option is enabled - EASFP-9
    if(useWebSockets){
        sendToWSClient(message);
        notifyConnectionAccepted();
    }else{
        _log("Sending:" + message);
        jQuery.ajax({
            //url: pollUrl + ":" + pollPort + "/request=" + message,
            url: pollUrl + ":" + pollPort,
            data: "/request=" + message,
            type: 'GET',
            timeout: requestTimeout,
            async: false,
            crossDomain: true,
            cache: false,
            dataType: 'jsonp',
            success: function(data) {
                _log('Request sent - response = ' + data.action);
                stopTimer();
                if (data.action == "DataRetrieved") {
                    setBusinessAttributes(data.actionData["data-display-attribute"]);
                    if(data.actionData.autoOpen != undefined && data.actionData.autoOpen != ""){
                        autoOpenDataDisplay = data.actionData.autoOpen;	 
                    }
                    if(data.actionData.autoLoggingEnabled == "True"){
                        Connector.activateLogging();
                    }
                }
                notifyConnectionAccepted();
            },
            error: function(xhr, ajaxOptions, thrownError) {
                _log('requestBusinessAttributes error (' + pollPort + ') ' + ajaxOptions + ' - ' + xhr.status + ' ' + thrownError);
                //connectionTimeout = setTimeout('Workspace.requestBusinessAttributes()', requestTimeout);
                _log("continue with processing"); 
                notifyConnectionAccepted();
            }
        });
    }
}

function setBusinessAttributes(actionData) {
	businessAttributes = {};
	if (!actionData || actionData.length == 0) {
		_log("Received empty Business Attributes array");
		return;
	}

    for (var i = 0; i < actionData.length; i++) {
    	var attr = actionData[i];
    	businessAttributes[attr.Name] = extendAttribute(attr);
    }
}

function extendAttribute(attr) {
	var template = {
		"order": 0,
		"label": attr.DisplayName,
		"type": "string",
		"key": "",
		"value": "",
		"style": "",
		"readonly": true
	};

	return jQuery.extend(template, attr);
}

function getBusinessAttributes() {
	return businessAttributes;
}

function getAutoOpenDataDisplay(){
	return autoOpenDataDisplay;
}

function sendActivityDescription(interactionId, description) {
    _log("sendActivityDescription - InteractionId: "+interactionId + "  description: " + description);   
    var newData = '{"interactionId":"' + interactionId + '","description":"' + description + '"}';
    message = '{"action":"ActivityDescription",' + CI_connectionData + ',"actionData":' + newData + '}';
    
    //Passing message to WDE through websocket if UseWebsockets option is enabled - EASFP-9
    if(useWebSockets){
        sendToWSClient(message);
    }else{
        _log("Sending:" + message);
        jQuery.ajax({
            //url: pollUrl + ":" + requestPort + "/request=" + message,
            //url: pollUrl + ":" + pollPort + "/request=" + message,
            url: pollUrl + ":" + pollPort,
            data: "/request=" + message,
            type: 'GET',
            timeout: requestTimeout,
            async: true,
            crossDomain: true,
            cache: false,
            dataType: 'jsonp',
            success: function(data) {
                _log('sendActivityDescription sent - response = ' + data.action);

            },
            error: function(xhr, ajaxOptions, thrownError) {
                _log('sendActivityDescription sent error (' + pollPort + ') ' + ajaxOptions + ' - ' + xhr.status + ' ' + thrownError);
            }
        });
    }
}

function sendFocusChange(objId, isScreenPop) {
    //_log("sendFocusChange - " + newData);
	_log("sendFocusChange - " + objId);
    var screenPop = '';
    if(isScreenPop==true)
    	screenPop = ',"screenPop":"true"'
    var newData = '{"sfdcObjectId":"' + objId + '"' + screenPop + '}';    
    message = '{"action":"FocusChanged",' + CI_connectionData + ',"actionData":' + newData + '}';
    
    //Passing message to WDE through websocket if UseWebsockets option is enabled - EASFP-9
    if(useWebSockets){
        sendToWSClient(message);
        //check
        if(isScreenPop==true)
            Salesforce.screenPop(objId);
    }else{
        _log("Sending:" + message);
        jQuery.ajax({
            url: pollUrl + ":" + pollPort,
            data: "/request=" + message,
            type: 'GET',
            timeout: requestTimeout,
            async: true,
            crossDomain: true,
            cache: false,
            dataType: 'jsonp',
            success: function(data) {
                _log('Request sent - response = ' + data.action);
                if(isScreenPop==true)
                    Salesforce.screenPop(objId);
            },
            error: function(xhr, ajaxOptions, thrownError) {
                _log('Request sent error (' + pollPort + ') ' + ajaxOptions + ' - ' + xhr.status + ' ' + thrownError);
            }
        });
    }
}

function setWDEPresenceStatus(apiName){
	wdePresenceStatus = apiName;
}

function getWDEPresenceStatus(){
	return wdePresenceStatus;
}
// Send the request for status change from SF to WDE
function sendAgentPresenceStatus(channel, apiName) {
	if(getWDEPresenceStatus() === apiName){
		_log("WDE presence status is already in " + apiName);
	}
	else{
	    _log("sendAgentPresenceStatus - channel: "+ channel + "  apiName: " + apiName);   
	    var newData = '{"channel":"' + channel + '","apiName":"' + apiName + '"}';
	    message = '{"action":"SendAgentPresenceStatus",' + CI_connectionData + ',"actionData":' + newData + '}';
		
		//Passing message to WDE through websocket if UseWebsockets option is enabled - EASFP-9
		if(useWebSockets){
			sendToWSClient(message);
		}else{
			_log("Sending:" + message);
			jQuery.ajax({
				url: pollUrl + ":" + pollPort,
				data: "/request=" + message,
				type: 'GET',
				timeout: requestTimeout,
				async: true,
				crossDomain: true,
				cache: false,
				dataType: 'jsonp',
				success: function(data) {
					_log('sendAgentPresenceStatus sent - response = ' + data.action);
					setWDEPresenceStatus(apiName);
				},
				error: function(xhr, ajaxOptions, thrownError) {
					_log('sendAgentPresenceStatus sent error (' + pollPort + ') ' + ajaxOptions + ' - ' + xhr.status + ' ' + thrownError);
				}
			});
		}
	}
}

  
//Create Websocket client to communicate with WDE through websocket - EASFP-9
function createWSClient() {
    var webSocketURL = null;
    var isDuplicate = false;
    pollUrl = pollUrl.replace("http","ws");
    webSocketURL = pollUrl + ":" + pollPort;
    _log("openWSConnection - Connecting to: " + webSocketURL);

    try {
        //Create websocket client
        webSocket = new WebSocket(webSocketURL);
        webSocket.onopen = function(openEvent) {
            _log("WebSocket Opened: " + JSON.stringify(webSocket));
            var connectMsg = '{"action":"ConnectionRequest"}';
            webSocket.send(connectMsg);
        };
        //CloseEvent handler - This is called when websocket is closed
        webSocket.onclose = function (closeEvent) {
            _log("WebSocket Closed");
            handleDisconnection();
            if(!isDuplicate) {
                _log("Retrying to connect...");
                createWSClient();
            }
        };
        //ErrorEvent handler - This is called when there is an error in websocket connection
        webSocket.onerror = function (errorEvent) {
            _log("Error in websocket communication");
            handleDisconnection();
        };
        //MessageEvent handler - This is called when a message is sent from server
        webSocket.onmessage = function (messageEvent) {
            var data = messageEvent.data;
            console.log("MESSAGE from WDE: " + data);
            if (data.indexOf("error") > 0) {
                _log("Error in Websocket message: " + wsMsg.error);
            } else {
                var wsMsg = JSON.parse(messageEvent.data);
                //Sending acknowledgement to WDE for notifying that message is received successfully in salesforce
                var ackMsg = '{reason:"OK",code:0}';
                webSocket.send(ackMsg);
                
                //Response from WDE for the ConnectionRequest message
                if(wsMsg.action == 'ConnectionAccepted'){
                    if(data.monitorSFDCSession!=null && data.monitorSFDCSession=='true')
                        monitorSFDCSession = true;
                    else
                        monitorSFDCSession = false;
                    _log('Monitor Salesforce session: ' + monitorSFDCSession);    
                    requestBusinessAttributes();
                    jQuery.publish("workspace/connected", []);
                
                //Response from WDE for the ConnectionRequest message - Stats that connection is not accepted by WDE
                }else if(wsMsg.action == 'ConnectionDenied'){
                    _log(wsMsg.actionData.reason);
                    isDuplicate = true;
                    handleDisconnection();

                //Response from WDE for the GetData message
                }else if (wsMsg.action == "DataRetrieved") {
                    setBusinessAttributes(wsMsg.actionData["data-display-attribute"]);
                    if(wsMsg.actionData.autoOpen != undefined && wsMsg.actionData.autoOpen != ""){
                        autoOpenDataDisplay = wsMsg.actionData.autoOpen;	 
                    }
                    if(wsMsg.actionData.autoLoggingEnabled == "True"){
                        Connector.activateLogging();
                    }
                
                //Response from WDE for salesforce requests [i.e MarkDone, AttachData etc] - Stats that requested operation is completed
                }else if (wsMsg.action == "Complete") {
                    _log("Request completed for " + wsMsg.for);
                    //SFP-5: sync status between salesforce and wde on global ready and notready 
					if(wsMsg.for == "SendAgentPresenceStatus" && wsMsg.requestDetails.apiName)
                    setWDEPresenceStatus(wsMsg.requestDetails.apiName);

                //Response from WDE for the RequestAttachment message - stats that the attachmentdata is ready to upload into salesforce
                }else if(wsMsg.action == "UploadAttachment"){
                    _log("GetAttachment completed");
                    var attachmentInfo = {};
                    attachmentInfo.id = wsMsg.requestDetails.attachmentID;
                    attachmentInfo.name = wsMsg.requestDetails.attachmentName;
                    attachmentInfo.mimeType = wsMsg.requestDetails.attachmentMimeType;
                    attachmentInfo.positionIndex = 0;
                    var myTaskID = wsMsg.requestDetails.myTaskID;
                    var redirectToTaskID = wsMsg.requestDetails.redirectToTaskID;
					var attachmentId = null;
                    DefaultsFunc.uploadAttachment(attachmentId,wsMsg,attachmentInfo,myTaskID,redirectToTaskID);
                }else{
                    //monitoring sf session
                    if(monitorSFDCSession){
                        gl_WorkspaceConnectorController.testConnection(function(o) {
                            if (o == null) {
                            _log('Session expired, attempting to refresh connector');
                            document.location.reload();
                        }
                        });
                    }
                    //Requests from WDE to salesforce comes here and it is published for processing
                    jQuery.publish("workspace/message", [wsMsg]);
                }
            }
        };
    } catch (exception) {
        _log(exception);
    }
}

//Sending message to WDE through websocket
function sendToWSClient(message) {
    try{
        _log("Sending via websocket:" + message);
        if(webSocket != null)
            webSocket.send(message);
        else
            _log("Websocket instance is not available");
    } catch (exception) {
        _log(exception);
    }    
}

function handleDisconnection(){
    jQuery.publish("workspace/disconnected", []);
}

var Workspace = {
	"setParameters": setParameters,
	"getParameters": getParameters,
	"poll": poll,
	"send": send,
	"processAttachData": processAttachData,
	"processMarkDone": processMarkDone,	
	"sendAttachData": sendAttachData,
	"requestConnection": requestConnection,
	"requestBusinessAttributes": requestBusinessAttributes,
	"getBusinessAttributes": getBusinessAttributes,
	"getAutoOpenDataDisplay": getAutoOpenDataDisplay,
	"sendActivityDescription": sendActivityDescription,
    "sendFocusChange": sendFocusChange,
    "createWSClient" : createWSClient,
    "sendToWSClient" : sendToWSClient,
    "sendAgentPresenceStatus" : sendAgentPresenceStatus,
    "setWDEPresenceStatus" : setWDEPresenceStatus	
}

window["Workspace"] = Workspace;

})(window, jQuery, undefined);
