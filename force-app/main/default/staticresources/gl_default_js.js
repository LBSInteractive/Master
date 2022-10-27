/*
(default customization: out of the box functionality)
Implement out of the box logic. Includes IWS events handling, event routing, search calls, screen pop calls.

Listens to events:
"workspace/message"

*/

(function(window, jQuery, undefined) {

var _log = Log ? Log.log : console.log;

jQuery.subscribe("workspace/message", processMessage);
jQuery.subscribe("connector/message", processNavigation);


function createAttDataArray(userData) {
	var businessAttributes = Workspace.getBusinessAttributes();
	var attData = new Array();
	$.each(userData, function(key, value) {
		if (! (key in businessAttributes)) {
			return;
		}
		var attr = $.extend(true, {}, businessAttributes[key]);
		attr.value = value;
		attData.push(attr);
	});
	return attData;
}

function showAttachedData(userData) {
    if (!userData) {
    	return;
    }

    Connector.showAttachedData(createAttDataArray(userData));
    if(Workspace.getAutoOpenDataDisplay == 'true')
    	//sforce.interaction.setVisible(true);
    	sforce.opencti.setSoftphonePanelVisibility({visible:true,});
}

////////////////////////////////////////////////////////////////////////////////////////
// event processing
//
// processMessage is called for all received communications from Interaction Workspace
// that contains valid work to be performed.
////////////////////////////////////////////////////////////////////////////////////////

function processMessage(obj) {
    if (obj.action == "OpenObject") {
        _log("in OpenObject");
        
    	if(typeof(Storage) !== "undefined" && window!=null && window.sessionStorage!=null)
    	{
    		var Genesys_activeInteraction = (obj.id === undefined) ? "" : obj.id;
    		window.sessionStorage.setItem("Genesys_activeInteraction", Genesys_activeInteraction);
    		_log("setting Genesys_activeInteraction = " + Genesys_activeInteraction);
    		
    		var Genesys_useFocusedRecord = (obj.useFocusedRecord === undefined) ? "" : obj.useFocusedRecord;
    		window.sessionStorage.setItem("Genesys_useFocusedRecord", Genesys_useFocusedRecord);
    		_log("setting Genesys_useFocusedRecord = " + Genesys_useFocusedRecord);
    	}

    	showAttachedData(obj.userData);
        
        if(obj.caseScreenpop.toLowerCase() == "true"){
        	performCaseAction(obj);
        	return;
        }

        // open based on type attribute
        if (obj.type == "Voice") {
                // Inbound, internal or consult voice
                if (obj.calltype == "Inbound" || obj.calltype == "Internal" || obj.calltype == "Consult") {
                    _log("processMessage: Inbound Voice handling for caller ID = " + obj.source);
                    performInboundVoiceAction(obj);
                }

                // Outbound voice
                if (obj.calltype == "Outbound") {
                    _log("processMessage: Outbound Voice handling for party = " + obj.destination);
                    performOutboundVoiceAction(obj);
                }
                if (obj.calltype == "Unknown") {
                    _log("processMessage: Unknown, clickToDialNum = " + clickToDialNum + ", destination = " + obj.destination);
                    clickToDialNum = "";
                    //performOutboundVoiceAction(obj);
                }
        }
        else if (obj.type == "Email") {
            _log("processMessage: Email pop action");
            performEmailAction(obj);
        }
        else if (obj.type == "Chat") {
            _log("processMessage: Chat pop action");
            performChatAction(obj);
        }
        else if (obj.type == "InteractionWorkItem") {
            _log("processMessage: Workitem pop action for mediaType: " + obj.mediaType);
            if (obj.mediaType == "chat_crm") {
				performChatCRMAction(obj);
			}
			else if (obj.mediaType == "case_crm") {
				performCaseCRMAction(obj);
			}
			else {
				performWorkItemAction(obj);
			}           
        }
        else if (obj.type == "Sms") {
            _log("processMessage: Sms pop action");
            performSmsAction(obj);
        }
        else if (obj.type == "WebCallback") {
            _log("processMessage: WebCallback pop action");
            performWebCallbackAction(obj);
        }
        else if (obj.type == "OpenMedia") {
            _log("processMessage: OpenMedia pop action");
            performOpenMediaAction(obj);
        }

	}
	//Show new case creation page : EASFP-48
	else if(obj.action == "ShowNewCasePage"){
		if(obj.type == "Voice"){
			if (obj.userData != undefined && obj.userData.sfdcObjectId != undefined && obj.userData.sfdcObjectId != null) 
			{
				objectIdForActivity = obj.userData.sfdcObjectId;
				_log("CreateCase using object " + objectIdForActivity);
				// create case
				Salesforce.screenPopNewCase(obj,objectIdForActivity);		        	    
			}else{
				_log("No sfdc object is identified");
				//EASFP-37
				prepareCreateObject(obj, "","showNewCase");
			}
		}
	}
	//Case creation features (EASFP-21)
	else if(obj.action == "CreateCase"){
		if(obj.type == "Chat" || obj.type == "Voice"){
			if (obj.userData != undefined && obj.userData.sfdcObjectId != undefined && obj.userData.sfdcObjectId != null) 
			{
				objectIdForActivity = obj.userData.sfdcObjectId;
				_log("CreateCase using object " + objectIdForActivity);
				// create case
				createCase(obj, objectIdForActivity);		        	    
			}else{
				_log("No sfdc object is identified");
				//EASFP-37
				prepareCreateObject(obj, "","case");
			}
		}
	}
    else if (obj.action == "CreateActivity") {
    	var objectIdForActivity = "";  
    	//check for attached data sfdcObjectId - if it is there, then use that
    	//*********************************
    	///TODO - Check for create activity on Case screen pop when initially multiple found and one is selected
    	/*
    	if(useFocusedRecord!=null && useFocusedRecord.toLowerCase() == "true")
    	{
    	    sforce.interaction.getPageInfo(function(o) {
	    	if(o!=null && o.result!=null){	    		
	    	    var jsonResult = jQuery.parseJSON(o.result);
	    	    if(jsonResult!=null && jsonResult.objectId!=null){
	    		objectIdForActivity = jsonResult.objectId;
	    		_log("CreateActivity for connID " + obj.id + " using object " + objectIdForActivity);
	    		// create the task
	    		createTask(obj, objectIdForActivity);	    			
	    		return;
	    	    }
	    	}
    		prepareCreateTask(obj, objectIdForActivity);
	    });	    
	    clickToDialNum = "";
	    return;
    	}*/
    	//*****************
    	if (obj.userData.sfdcObjectId != null) 
    	{
    	    objectIdForActivity = obj.userData.sfdcObjectId;
    	    _log("CreateActivity for voice using object " + objectIdForActivity);
		
    	    // create the task
    	    createTask(obj, objectIdForActivity);
		        
    	    clickToDialNum = "";
    	    return;		        	    
    	}
		//EASFP-37
		prepareCreateObject(obj, objectIdForActivity);
    }
    else if (obj.action == "MarkedDone") {
    	//TODO
    	//var ixnId = Salesforce.getIxnId(obj.id);
        //_log("MarkedDone for connID " + obj.id + " delete Windows - " + ixnId);
        //Salesforce.removeIxnWindow(ixnId);
    }
    else if (obj.action == "FocusTab") {
        _log("FocusTab for " + obj.id);
        //TODO
        //Salesforce.focusIxnTab(obj.id);
    }
    else if (obj.action == 'ConnectionDenied') {
    	//Don't reconnect if denied
    	_log("Connection denied, do not retry");
    	if(typeof(Storage) !== "undefined" && window!=null && window.sessionStorage!=null)
    	{
    		window.sessionStorage.setItem("Genesys_sfdc_Banned", "true");
    	}
    }
    else if (obj.action == 'PerformSFDCRequest') {
    	_log("PerformSFDCRequest");
    } 
    else if (obj.action == 'SetSFDCAvailability') {
    	_log("SetSFDCAvailability apiName = " + obj.apiName);
    	//SFP-5: sets wde status in salesforce omnichannel utility
		setAgentPresenceStatus(obj.apiName);
    }
    else if (obj.action == 'AgentStatusNotification')
    {
    	_log("AgentStatusNotification available_media = " + obj.available_media);
    	var available_media = obj.available_media;
    	if (available_media != null && available_media.length > 0)
    	{
    		for (i=0; i<available_media.length; i++)
    		{
    			var channelStatus = available_media[i] + "_status";
    			_log("AgentStatusNotification media=" + available_media[i] + "   status= " + obj[channelStatus].status + "  reasoncode=" +  obj[channelStatus].reasoncode);  		
    		}
    	}
    }
    else if (obj.action == 'IxnStatusNotification')
    {
    	_log("IxnStatusNotification");
    	if (obj.type == "Voice") {
	    	
	    	//Pop the application panel
	    	if (obj.reason.toLowerCase() == 'answer')
	    	{
	    		showAttachedData(obj.userData);
	    		if (obj.popPanelOnVoiceAnswered.toLowerCase() == "true" )
	    		{
	    			sforce.opencti.setSoftphonePanelVisibility({visible:true,});  
	    		}
	    	}
	    	_log("IxnStatusNotification InteractionId = " + obj.id);
	    	
	    	//If the current agent is on a call and the other end performs a single step transfer,
	    	//the obj.reason will be PartyChanged for the current agent
	    	_log("IxnStatusNotification reason = " + obj.reason);    	
	    	//calltype provides information on Inbound, Outbound, Consult and  Outbound Campaign
	    	var partiesCount =  (obj.partiesCount === undefined) ? 0 : parseInt(obj.partiesCount);
	    	_log("IxnStatusNotification partiesCount=" + obj.partiesCount);
	    	//Can access parties information via obj.partiesInfo
	    	
	    	//Profile provides information on Primary, Consult, Transfer and Conference info.  It is raw data from Genesys Interaction
	    	_log("IxnStatusNotification interactionProfile=" + obj.interactionProfile);
	    	//verify for single step transfer
	    	var cause =  (obj.cause === undefined) ? '' : obj.cause;
	    	//If the current agent does SingleStepTransfer, cause will show SingleStepTransfer
	    	//and targetName will show the number that the interaction is transferred to
	    	//cause and targetName are raw Genesys information
	    	if (cause != '')
	    	{
	    		_log("IxnStatusNotification cause = " + obj.cause);
	    	}    	
	    	var targetName =  (obj.targetName === undefined) ? '' : obj.targetName;
	    	if (targetName != '')
	    	{
	    		_log("IxnStatusNotification targetName=" + targetName);        	
	    	}  
    	}
    	
    	
    	
    }
    
    
    clickToDialNum = "";
}

//SFP-5: Gets the status id using api name
function setAgentPresenceStatus(apiName){
    _log("setAgentPresenceStatus apiName = " + apiName);
    Workspace.setWDEPresenceStatus(apiName);
    gl_WorkspaceConnectorController.getPresenceStatusId(apiName, function(statusId){
	if(statusId && statusId != ''){			
	    //The statusId is stored as an 18-characters string in database. 
	    //The last 3 characters are specific to apps that are case-insensitive and can be truncated
	    statusId = statusId.substring(0,15);
	    _log('setAgentPresenceStatus apiName = ' + apiName +  '   statusId = '+ statusId);
	    setAgentStatus(statusId);
	}
    });
}

//SFP-5: Sets the WDE status to Salesforce OMNI channel utility
function setAgentStatus(statusId){
    _log("setAgentStatus statusId = " + statusId);
    sforce.console.presence.setServicePresenceStatus(statusId, function(result) {
	if (result.success) {
	    _log('setAgentStatus Updated to statusId = ' + statusId);
	} else {
	    _log('setAgentStatus - setServicePresenceStatus failed for statusId=' + result.statusId);
	}
    });	
}


//To prevent timing issue resulting with duplicate activities, create the task at the end when objectIdForActivity is identified
//Converted prepareCreateTask method to generalized for supporting both case and task when objectIdForActivity is not available in creation request - EASFP-37
function prepareCreateObject(obj, objectIdForActivity, from = "task")
{      
    var searchObjectType = (obj.searchObjectType === undefined) ? "default" : obj.searchObjectType;     
    var start
    _log("prepareCreateObject  searchObjectType= " + searchObjectType);
        
    if (obj.type == "Voice")
    { 
	clickToDialNum = "";
    	var lookupNumber='';
    	if (obj.calltype == "Inbound" || obj.calltype == "Internal"  || obj.calltype=="Consult" || obj.calltype=="Conference") {
	    lookupNumber = obj.source;
	    if (obj.role == 'RoleOrigination') {
	        lookupNumber = obj.destination;
	    }
	}
	else if(obj.calltype == "Outbound") {
	    lookupNumber = obj.destination;
	}		
    	//When no match is found for Case and no manual search is done, Activity should be an orphan Activity under the User.
    	var caseScreenpop = (obj.caseScreenpop === undefined) ? "" : obj.caseScreenpop;
    	if(caseScreenpop.toLowerCase() == "true"){
    	    _log("prepareCreateObject for voice under User since CaseNumber processing did not yield a match");
			
			//EASFP-37
			//createTask(obj, objectIdForActivity);
			if(from == "case")
				createCase(obj, objectIdForActivity);
			//EASFP-48
			else if(from == "showNewCase")
				Salesforce.screenPopNewCase(obj,objectIdForActivity);
			else
    	    	createTask(obj, objectIdForActivity);

    	    return;
    	}
    }
    	
    var searchFieldsCount =  (obj.searchFieldsCount === undefined) ? 0 : parseInt(obj.searchFieldsCount);  
    _log("prepareCreateObject for " + obj.type + "  searchFieldsCount= " + searchFieldsCount);
    var searchAllFields = (obj.searchAllFields === undefined) ? true : (obj.searchAllFields.toLowerCase() == "true");    
    _log("prepareCreateObject for " + obj.type + "   searchAllFields= " + searchAllFields);
           
    if(searchFieldsCount > 0 || (obj.fieldName != undefined && obj.fieldValue != undefined)){    	    
		var searchFieldName = obj.fieldName;
		var searchFieldValue = obj.fieldValue;
		_log("prepareCreateObject for " + obj.type + " using search field " + searchFieldName + " for a value of " + searchFieldValue);
		if (searchObjectType == 'contact' || searchObjectType == 'account' || searchObjectType == 'personaccount'){
	 	   if (searchFieldsCount > 0){    	
	 		  var searchList_ =  getSearchList(obj, false)
	 	      gl_WorkspaceConnectorController.findObjectByTypeMapSearch(searchList_.fields, searchList_.values, searchAllFields, searchObjectType, function(o) {
						//multimatch check for not showing case creation page when multiple matches found : EASFP-48
						var multimatch = false;
						if (o != null && o.length == 1) {
		    		       objectIdForActivity = o[0].Id;
		    		       _log("prepareCreateObject Id found " + objectIdForActivity);
		    		   }else if(o != null && o.length > 1){
							multimatch = true;
					   }else {
						   _log("prepareCreateObject Id not found ");
						   //Finding the contact for dummy mail configured and mapping to the auto case incase of no match found in chat: EASFP-55
						   if(from == "case" && obj.type == "Chat" && searchObjectType == 'contact' && 'dummyContactMailForAutoCaseOnNoMatch' in obj){
							obj.search_SFDC1_value=obj.dummyContactMailForAutoCaseOnNoMatch;
							var searchList_ =  getSearchList(obj, false);
							gl_WorkspaceConnectorController.findObjectByTypeMapSearch(searchList_.fields, searchList_.values, searchAllFields, searchObjectType, function(ob) { 
								if (ob.length >= 1){
									objectIdForActivity =ob[0].Id;
									_log("prepareCreateObject Id found for the dummy contact mail Id configured : " + objectIdForActivity);
								}else
									_log("No Contact Found for the Dummy mail configured : "+obj.dummyContactMailForAutoCaseOnNoMatch);
								createCase(obj, objectIdForActivity);
							});
							return;
						}
		           	   }
		    		   _log("---prepareCreateObject for interaction Id " + obj.id + " using object " + objectIdForActivity);
					   //EASFP-37
					   if(from == "case")
							createCase(obj, objectIdForActivity);
					   //EASFP-48
					   else if(from == "showNewCase"){
						  if(!multimatch)
							Salesforce.screenPopNewCase(obj,objectIdForActivity);
					   }else
					   		createTask(obj, objectIdForActivity);
		    		   return;
	 	       }); 
	 	   }
	 	   else{
	 	       gl_WorkspaceConnectorController.findObjectByType(searchFieldName,searchFieldValue, searchObjectType, function(o) {
					   //multimatch check for not showing case creation page when multiple matches found : EASFP-48
					   var multimatch = false;
		    		   if (o != null && o.length == 1) {
		    		       objectIdForActivity = o[0].Id;
		    		       _log("prepareCreateObject Id found " + objectIdForActivity);
		    		   }else if(o != null && o.length > 1){
							multimatch = true;
					   }else {
		    		       _log("prepareCreateObject Id not found ");
		    		   }
		    		   _log("+++prepareCreateObject for interaction Id " + obj.id + " using object " + objectIdForActivity);
					   //EASFP-37
					   if(from == "case")
							createCase(obj, objectIdForActivity);
					   //EASFP-48
					   else if(from == "showNewCase"){
						if(!multimatch)
					  		Salesforce.screenPopNewCase(obj,objectIdForActivity);
					   }else
					   		createTask(obj, objectIdForActivity);
		               return;
		    	    });  
	 	   }
	 	}
		else if(searchObjectType == 'all')
    	{
    		gl_WorkspaceConnectorController.IsPersonAccountEnabled(function(result){
	    		if (result == null || result == 'false'){
	    		    if (searchFieldsCount > 0){	    		
	    		    	var searchList_ =  getSearchList(obj, false)
	        			gl_WorkspaceConnectorController.findGenericObjectMapSearch(searchList_.fields, searchList_.values, searchAllFields, function(o) {
							_log("prepareCreateObject all " + o);
							//multimatch check for not showing case creation page when multiple matches found : EASFP-48
							var multimatch = false;
		    			    if (o != null &&  o != 'not found' &&  o !=  'multiple found' ){
		    		    	    	objectIdForActivity = o.Id;
		    		    	    	_log("prepareCreateObject Id found " + objectIdForActivity);
							}else if(o != null && o == 'multiple found'){
								multimatch = true;
							}else {
		    					_log("prepareCreateObject Id not found ");
		    			    }
		    			    _log("****prepareCreateObject for interaction Id " + obj.id + " using object " + objectIdForActivity);
							//EASFP-37
							if(from == "case")
								createCase(obj, objectIdForActivity);
							 //EASFP-48
							else if(from == "showNewCase"){
								if(!multimatch)
							 		Salesforce.screenPopNewCase(obj,objectIdForActivity);
							}else 
								createTask(obj, objectIdForActivity);
		        		     return;
		    			}); 
	    		    }
	    		    else{
		    			_log("prepareCreateObject all for " + obj.type + " using search field for default setting");
		    			gl_WorkspaceConnectorController.findGenericObject(searchFieldName,searchFieldValue, function(o) {
							_log("prepareCreateObject " + o);
							//multimatch check for not showing case creation page when multiple matches found : EASFP-48
							var multimatch = false;
		    			    if (o != null &&  o != 'not found' &&  o !=  'multiple found' ) {
		    			    	objectIdForActivity = o.Id;
		    		    	    _log("prepareCreateObject Id found " + objectIdForActivity);
		    			    }else if(o != null && o == 'multiple found'){
								multimatch = true;
							}else {
		    			    	_log("prepareCreateObject Id not found ");
		    			    }
		    			    _log("xxxxprepareCreateObject for interaction Id " + obj.id + " using object " + objectIdForActivity);
							//EASFP-37
							if(from == "case")
								createCase(obj, objectIdForActivity);
							//EASFP-48
							else if(from == "showNewCase"){
								if(!multimatch)
							 		Salesforce.screenPopNewCase(obj,objectIdForActivity);
							}else
								createTask(obj, objectIdForActivity);
		        		    return;
		    			});
	    		    }
	    		}
    	    });
    	}
    	else //searchObjectType is 'default'
    	{
    		gl_WorkspaceConnectorController.IsPersonAccountEnabled(function(result){
	    		if (result == null || result == 'false'){
	    		    if (searchFieldsCount > 0){	    		
	    		    	var searchList_ =  getSearchList(obj, false)
	        			gl_WorkspaceConnectorController.findObjectMapSearch(searchList_.fields, searchList_.values, searchAllFields, function(o) {
							_log("prepareCreateObject " + o);
							//multimatch check for not showing case creation page when multiple matches found : EASFP-48
							var multimatch = false;
		    			    if (o != null &&  o != 'not found' &&  o !=  'multiple found' ){
		    		    	    	objectIdForActivity = o.Id;
		    		    	    	_log("prepareCreateObject Id found " + objectIdForActivity);
		    			    }else if(o != null && o == 'multiple found'){
								multimatch = true;
							}else {
		    					_log("prepareCreateObject Id not found ");
		    			    }
		    			    _log("****prepareCreateObject for interaction Id " + obj.id + " using object " + objectIdForActivity);
							//EASFP-37 
							if(from == "case")
								createCase(obj, objectIdForActivity);
							//EASFP-48
							else if(from == "showNewCase"){
								if(!multimatch)
							 		Salesforce.screenPopNewCase(obj,objectIdForActivity);
							}else
								createTask(obj, objectIdForActivity);
		        		     return;
		    			}); 
	    		    }
	    		    else{
		    			_log("prepareCreateObject for " + obj.type + " using search field for default setting");
		    			gl_WorkspaceConnectorController.findObject(searchFieldName,searchFieldValue, function(o) {
							_log("prepareCreateObject " + o);
							//multimatch check for not showing case creation page when multiple matches found : EASFP-48
							var multimatch = false;
		    			    if (o != null &&  o != 'not found' &&  o !=  'multiple found' ) {
		    			    	objectIdForActivity = o.Id;
		    		    	    _log("prepareCreateObject Id found " + objectIdForActivity);
		    			    }else if(o != null && o == 'multiple found'){
								multimatch = true;
							}else {
		    			    	_log("prepareCreateObject Id not found ");
		    			    }
		    			    _log("xxxxprepareCreateObject for interaction Id " + obj.id + " using object " + objectIdForActivity);
							//EASFP-37
							if(from == "case")
								createCase(obj, objectIdForActivity);
							//EASFP-48
							else if(from == "showNewCase"){
								if(!multimatch)
							 		Salesforce.screenPopNewCase(obj,objectIdForActivity);
							}else
								createTask(obj, objectIdForActivity);
		        		    return;
		    			});
	    		    }
	    		}
    	    });
    	}
    }
    if (obj.type == "Voice" && searchFieldsCount == 0 && (obj.fieldName == undefined || obj.fieldValue == undefined)){
        _log("prepareCreateObject for voice with lookup " + lookupNumber);
        if (searchObjectType == 'contact' || searchObjectType == 'account' || searchObjectType == 'personaccount')
        {
        	gl_WorkspaceConnectorController.findObjectFromANIByType(lookupNumber, searchObjectType, function(o) {
				//multimatch check for not showing case creation page when multiple matches found : EASFP-48
				var multimatch = false;
				if (o != null) {
	        	    if (o == 'not found') {
	        		_log("No results");
	        	    }
	        	    else{           		    
	        		if (o.length == 1){
	        		    objectIdForActivity = o[0].Id;
	        		    _log("Id found " + objectIdForActivity);
	        		}
	        		else if(o.length > 1){           			
						_log("Multiple results");
						multimatch = true;
	        		}
	        		else //0 match
	        		    _log("No results");
	        	    }
	        	} 
	        	else {
	        	    _log("No results");
	        	}
	        	_log("CreateActivity for connID " + obj.id + " using object " + objectIdForActivity);
				//EASFP-37
				if(from == "case")
					createCase(obj, objectIdForActivity);
				//EASFP-48
				else if(from == "showNewCase"){
					if(!multimatch)
						Salesforce.screenPopNewCase(obj,objectIdForActivity);
				}else
					createTask(obj, objectIdForActivity);
	        	return;
            });   
        }
        else //searchObjectType is 'default'
        { 
            gl_WorkspaceConnectorController.IsPersonAccountEnabled(function(result){
	        	if (result == null || result == 'false'){	 
	        	    gl_WorkspaceConnectorController.findObjectFromANI(lookupNumber, function(o) {
						//multimatch check for not showing case creation page when multiple matches found : EASFP-48
						var multimatch = false;
		        		if (o != null) {
		        		    if(o != 'not found' && o != 'multiple found'){
			        			objectIdForActivity = o.Id;
			        			_log("prepareCreateObject Id found " + objectIdForActivity);
		        		    }
		        		    else if(o == 'multiple found'){
								_log("prepareCreateObject Multiple results");
								multimatch = true;
		            		    //find the one with the most recent completed activity and create the task there
		            		    //findMostRecentlyCompletedActivity(lookupNumber, false, obj.id, obj);
		            		    //return;
		        		    }
		        		}
		        		else{ //o is null
		        		    _log("prepareCreateObject No results");
		        		}		
		        		_log("prepareCreateObject for connID " + obj.id + " using object " + objectIdForActivity);
						//EASFP-37
						if(from == "case")
							createCase(obj, objectIdForActivity);
					    //EASFP-48
						else if(from == "showNewCase"){
							if(!multimatch)
								Salesforce.screenPopNewCase(obj,objectIdForActivity);
						}
					    else
							createTask(obj, objectIdForActivity);
	            		return;
	        	    });
	        	}
            });    	
        }	  
    }

    //_log("prepareCreateTask for interaction Id " + obj.id + " using object " + objectIdForActivity);

    // create the task
    //createTask(obj, objectIdForActivity);
}

////////////////////////////////////////////////////////////////////////////////////////
// Inbound and Outbound Voice handling
////////////////////////////////////////////////////////////////////////////////////////

/*Check the object type to search in
1 - default: Account, Contact, Lead
2 - account
3 - personaccount
4 - contact
*/ 
//Added 2 parameters sortby and limit to pass to contact lookup page : EASFP-51, EASFP-54
function searchByFieldAndType(searchFieldName,searchFieldValue, ixnId, searchObjectType, contactSortBy, contactResultsLimit)
{
    _log("searchByFieldAndType:  searchObjectType - " + searchObjectType + ", searchFieldName - " + searchFieldName + ", searchFieldValue - " + searchFieldValue);       
    if (searchObjectType == 'account' || searchObjectType == 'personaccount' || searchObjectType == 'contact')
    {
    	gl_WorkspaceConnectorController.findObjectByType(searchFieldName,searchFieldValue, searchObjectType, function(o) {  
		    if (o != null) {
			if (o.length == 1){
	           	    Salesforce.screenPop(o[0].Id); 
			    var newData = '{"sfdcObjectId":"' + o[0].Id + '","id":"' + ixnId + '"}';
			    Workspace.sendAttachData(newData);
	   		}
	   		else if(o.length > 1){
				_log("searchByFieldAndType Multiple entry, open the new search page");
	   		    Salesforce.openSearchByType(o,ixnId, searchObjectType, '', contactSortBy, contactResultsLimit);
	   		}
	   		else //0 match
	   			Salesforce.openSearchByType("",ixnId, searchObjectType, '', contactSortBy, contactResultsLimit);
		    }
		    else { //o is null
				_log("searchByFieldAndType: No entry, open the new search page");          	    
	   	        Salesforce.openSearchByType("",ixnId , searchObjectType, '', contactSortBy, contactResultsLimit);
	   	     }
		});	    
    }
    else if (searchObjectType == 'all') // Generic search
    {	 
    	gl_WorkspaceConnectorController.findGenericObject(searchFieldName, searchFieldValue, function(o) {
    		if (o == null || o == 'not found'){
    			_log("searchByFieldsListAndType: result = " + o);
           	         	//open search
           	         	Salesforce.openSearch("", ixnId); 
    		    }
    		    else if (o ==  'multiple found'){
    			_log("searchByFieldsListAndType: result = " + o);
           	         	//open search
           	         	Salesforce.openGenericSearchByFields(searchFieldName, searchFieldValue, ixnId);
    		    }
    		    else{
    		    	_log("searchByFieldsListAndType one result found, screen pop the result result = " + o.Id);	   	
    		    	Salesforce.screenPop(o.Id); 
        	        	//inform workspace of SFobject id for subsequent use in activity creation and transfer
        	        	var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + ixnId + '"}';
        	        	Workspace.sendAttachData(newData);
    		    }     	    
    	 });
    }
    else // searchObjectType is 'default'
    {	 
    	gl_WorkspaceConnectorController.findObject(searchFieldName,searchFieldValue, function(o) {
    	    if (o == null || o == 'not found'){
    	    	_log("searchByFieldAndType: result = " + o);
   	         	//open search
   	         	Salesforce.openSearch("", ixnId); 
		    }
		    else if (o ==  'multiple found'){
		    	_log("searchByFieldAndType: result = " + o);
	   	         	//open search
	   	         	Salesforce.openSearchByFields(searchFieldName, searchFieldValue, ixnId);
		    }
		    else{
		    	Salesforce.screenPop(o.Id); 
		        	//inform workspace of SFobject id for subsequent use in activity creation and transfer
		        	var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + ixnId + '"}';
		        	Workspace.sendAttachData(newData);
		    }
    	    
    	 });
    }
}

//Added 2 parameters sortby and limit to pass to contact lookup page : EASFP-51, EASFP-54
function searchByFieldsListAndType(searchList, searchAllFields, ixnId, searchObjectType, contactSortBy, contactResultsLimit)
{
    _log("searchByFieldsListAndType");       
	if (searchObjectType == 'account' || searchObjectType == 'personaccount' || searchObjectType == 'contact')
   {
	gl_WorkspaceConnectorController.findObjectByTypeMapSearch(searchList.fields, searchList.values, searchAllFields, searchObjectType, function(o) {  
	    if (o != null) {
		if (o.length == 1){
		    Salesforce.screenPop(o[0].Id); 
		    //inform workspace of SFobject id for subsequent use in activity creation and transfer
		    var newData = '{"sfdcObjectId":"' + o[0].Id + '","id":"' + ixnId + '"}';
		    Workspace.sendAttachData(newData);
   		}
   		else if(o.length > 1){
   		    _log("searchByFieldsListAndType Multiple entry, open the new search page");   
			Salesforce.openSearchByType(o,ixnId, searchObjectType, '', contactSortBy, contactResultsLimit);
   		}
   		else //0 match
			Salesforce.openSearchByType("",ixnId, searchObjectType, '', contactSortBy, contactResultsLimit);    
	    }
	    else { //o is null
   	         _log("searchByFieldsListAndType: No entry, open the new search page");	
			Salesforce.openSearchByType("",ixnId , searchObjectType, '', contactSortBy, contactResultsLimit);
   	     }
	});	    
    }
    else if (searchObjectType == 'default')// searchObjectType is 'default'
    {
	 
		gl_WorkspaceConnectorController.findObjectMapSearch(searchList.fields, searchList.values, searchAllFields, function(o) {  
		    if (o == null || o == 'not found'){
			_log("searchByFieldsListAndType: result = " + o);
       	         	//open search
       	         	Salesforce.openSearch("", ixnId); 
		    }
		    else if (o ==  'multiple found'){
			_log("searchByFieldsListAndType: result = " + o);
       	         	//open search
       	         	Salesforce.openSearchByFieldsMap(searchList.fields, searchList.values, ixnId, searchAllFields);
		    }
		    else{
		    	_log("searchByFieldsListAndType one result found, screen pop the result result = " + o.Id);	   	
		    	Salesforce.screenPop(o.Id); 
    	        	//inform workspace of SFobject id for subsequent use in activity creation and transfer
    	        	var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + ixnId + '"}';
    	        	Workspace.sendAttachData(newData);
		    } 
        	    
		});
    }
    else // Generic search
    {	 
    	gl_WorkspaceConnectorController.findGenericObjectMapSearch(searchList.fields, searchList.values, searchAllFields, function(o) {
    		if (o == null || o == 'not found'){
    			_log("searchByFieldsListAndType: result = " + o);
           	         	//open search
           	         	Salesforce.openSearch("", ixnId); 
    		    }
    		    else if (o ==  'multiple found'){
    			_log("searchByFieldsListAndType: result = " + o);
           	         	//open search
           	         	Salesforce.openGenericSearchByFieldsMap(searchList.fields, searchList.values, ixnId, searchAllFields);
    		    }
    		    else{
    		    	_log("searchByFieldsListAndType one result found, screen pop the result result = " + o.Id);	   	
    		    	Salesforce.screenPop(o.Id); 
        	        	//inform workspace of SFobject id for subsequent use in activity creation and transfer
        	        	var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + ixnId + '"}';
        	        	Workspace.sendAttachData(newData);
    		    }     	    
    	 });
    }
}

//Added 2 parameters sortby and limit to pass to contact lookup page : EASFP-51, EASFP-54
function searchByLookupPhoneNumberAndType(lookupNumber, ixnId, searchObjectType, contactSortBy, contactResultsLimit)
{
    _log("Using lookupNumber = " + lookupNumber);
    if (searchObjectType == 'account' || searchObjectType == 'personaccount' || searchObjectType == 'contact')
    {	    
		gl_WorkspaceConnectorController.findObjectFromANIByType(lookupNumber, searchObjectType, function(o) {
		    if (o != null) {
				if (o == 'not found') {
				    Salesforce.openSearchByType('', ixnId, searchObjectType, lookupNumber, contactSortBy, contactResultsLimit);
				    return;
				}
				else{
				    if (o.length == 1){
		               	    	Salesforce.screenPop(o[0].Id); 
		               	    	var newData = '{"sfdcObjectId":"' + o[0].Id + '","id":"' + ixnId + '"}';
		               	    	Workspace.sendAttachData(newData);
		       		}
				    else if(o.length > 1){
							_log("searchByLookupPhoneNumberAndType Multiple entry, open the new search page");
		       		    	Salesforce.openSearchByType(o,ixnId, searchObjectType, lookupNumber, contactSortBy, contactResultsLimit);
				    }
				    else //0 match
		       		    	Salesforce.openSearchByType('',ixnId, searchObjectType, lookupNumber, contactSortBy, contactResultsLimit);
				}
		    }
		    else { // o is null
				_log("No records found with phone field containing: " + lookupNumber);
				Salesforce.openSearchByType('', ixnId, searchObjectType, lookupNumber, contactSortBy, contactResultsLimit);
		    }
		});   
	}
    else //searchObjectType is 'default'
    {	 
    	gl_WorkspaceConnectorController.findObjectFromANI(lookupNumber, function(o) {
    	    if (o != null) {
                if (o == 'multiple found' || o == 'not found') {
                    Salesforce.openSearch(lookupNumber, ixnId);
                    return;
                }
                //Salesforce.addIxnWindow(obj.id, o.Id);
                Salesforce.screenPop(o.Id); 
                //else Workspace.sendFocusChange(o.Id, true); //move screenpop so that it wasn't called while we were still sending events
                //inform workspace of SFobject id for subsequent use in activity creation and transfer
                var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + ixnId + '"}';
                Workspace.sendAttachData(newData);
            } 
    	    else {
                _log("No records found with phone field containing: " + lookupNumber);
            }
    	});
    }    
}


//Allows duplicate keys:   Example - Multiple key names of Phone with different values
function getSearchList(obj, isCase) {
	let fieldsAndValues = {
		'fields' : [],
		'values' : []
	};
	_log("in getSearchList isCase=" + isCase);
	if (!isCase) {
		var searchFieldsCount = (obj.searchFieldsCount === undefined) ? 0
				: parseInt(obj.searchFieldsCount);
		_log("getSearchList  searchFieldsCount= " + searchFieldsCount);

		if (searchFieldsCount > 0) {
			// var searchMap = new Object();
			for (var index = 1; index <= searchFieldsCount; index++) {
				var fieldKeyName = "search_SFDC" + index + "_field";
				var valueKeyName = "search_SFDC" + index + "_value";
				var _SFDCfield = (obj[fieldKeyName] === undefined) ? ""
						: obj[fieldKeyName];
				var _SFDCvalue = (obj[valueKeyName] === undefined) ? ""
						: obj[valueKeyName];
				_log("getSearchList  _SFDCfield: " + _SFDCfield
						+ " _SFDCvalue: " + _SFDCvalue);
				
				fieldsAndValues.fields.push(_SFDCfield.toLowerCase());
				//SFP-7 - Handling salesforce field with case sensitive enabled - Search the exact value instead of convering it to lowercase and searching
				if(!_SFDCfield.toLowerCase().includes(".id") && !(obj.isCaseSensitiveSearch && obj.isCaseSensitiveSearch.toLowerCase() == "true")){					
					fieldsAndValues.values.push(_SFDCvalue.toLowerCase());
				}
				else{					
					fieldsAndValues.values.push(_SFDCvalue);
				}
			}
		}
	} else {
		var caseSearchFieldsCount = (obj.caseSearchFieldsCount === undefined) ? 0
				: parseInt(obj.caseSearchFieldsCount);
		_log("getSearchList  caseSearchFieldsCount= "
				+ caseSearchFieldsCount);

		if (caseSearchFieldsCount > 0) {
			// var searchMap = new Object();

			for (var index = 1; index <= caseSearchFieldsCount; index++) {
				var fieldKeyName = "case_SFDC" + index + "_field";
				var valueKeyName = "case_SFDC" + index + "_value";
				var _SFDCfield = (obj[fieldKeyName] === undefined) ? ""
						: obj[fieldKeyName];
				var _SFDCvalue = (obj[valueKeyName] === undefined) ? ""
						: obj[valueKeyName];
				_log("getSearchList  _SFDCfield: " + _SFDCfield
						+ " _SFDCvalue: " + _SFDCvalue);
				fieldsAndValues.fields.push(_SFDCfield.toLowerCase());
				//SFP-7 - Handling salesforce field with case sensitive enabled - Search the exact value instead of convering it to lowercase and searching
				if(!_SFDCfield.toLowerCase().includes(".id") && !(obj.isCaseSensitiveSearch && obj.isCaseSensitiveSearch.toLowerCase() == "true")){				
					fieldsAndValues.values.push(_SFDCvalue.toLowerCase());
				}
				else{					
					fieldsAndValues.values.push(_SFDCvalue);
				}
				// searchMap[_SFDCfield] = _SFDCvalue;
			}
		}
	}
	_log("getSearchList: " + JSON.stringify(fieldsAndValues));
	return fieldsAndValues;

}


// screen pop for inbound voice. If role is RoleDestination, then this is inbound, if
// RoleOrigination, then it is an manual outbound dial
function performInboundVoiceAction(obj) {
    _log("in performInboundVoiceAction()");
    

    // determine number to use based on role
    _log("performInboundVoiceAction Role is " + obj.role);
    var lookupNumber = obj.source;
    if (obj.role == 'RoleOrigination') {
        lookupNumber = obj.destination;
    }
    
    if(obj.calltype == "Consult" && obj.userData.primaryANI != undefined && obj.userData.primaryANI != ""){
	_log("Using primaryANI from Consult");
	lookupNumber = obj.userData.primaryANI;
    }

    
    if (Salesforce.screenPopUser(obj)) {
        return;
    }
    
    var searchObjectType = (obj.searchObjectType === undefined) ? "default" : obj.searchObjectType;        
    _log("performInboundVoiceAction  searchObjectType= " + searchObjectType);
    
    var searchAllFields = (obj.searchAllFields === undefined) ? true : (obj.searchAllFields.toLowerCase() == "true");        
    var searchFieldsCount =  (obj.searchFieldsCount === undefined) ? 0 : parseInt(obj.searchFieldsCount);  
    _log("performInboundVoiceAction  searchFieldsCount= " + searchFieldsCount);
	
	//Passing sortby and limit to contact lookup page : EASFP-51, EASFP-54
	var contactSortBy = (obj.contactSortBy === undefined) ? "defaultSorting" : obj.contactSortBy;        
    var contactResultsLimit =  (obj.contactResultsLimit === undefined || isNaN(parseInt(obj.contactResultsLimit))) ? 1000 : parseInt(obj.contactResultsLimit);
	
    if (searchFieldsCount > 0){
		var searchList_ =  getSearchList(obj, false);
    	searchByFieldsListAndType(searchList_, searchAllFields, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
    }       
    else if(obj.fieldName != undefined && obj.fieldValue != undefined){
		var searchFieldName = obj.fieldName;
		var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
		_log("performInboundVoiceAction search field " + searchFieldName + " for a value of " + searchFieldValue);        	
		searchByFieldAndType(searchFieldName,searchFieldValue, obj.id, searchObjectType, contactSortBy, contactResultsLimit)
    }
    else{
		_log("performInboundVoiceAction search by ANI");     
		searchByLookupPhoneNumberAndType(lookupNumber, obj.id, searchObjectType, contactSortBy, contactResultsLimit); 	
    }
}

// screen pop for outbound voice
function performOutboundVoiceAction(obj) {
    _log("in performOutboundVoiceAction()");
    if (Salesforce.screenPopUser(obj)) {
        return;
    }

    var lookupNumber = obj.destination;
    _log("performOutboundVoiceAction using lookupNumber = " + lookupNumber);
    
    var searchObjectType = (obj.searchObjectType === undefined) ? "default" : obj.searchObjectType;        
    _log("performOutboundVoiceAction  searchObjectType= " + searchObjectType); 
    
    var searchAllFields = (obj.searchAllFields === undefined) ? true : (obj.searchAllFields.toLowerCase() == "true");        
    var searchFieldsCount =  (obj.searchFieldsCount === undefined) ? 0 : parseInt(obj.searchFieldsCount);  
    _log("performOutboundVoiceAction  searchFieldsCount= " + searchFieldsCount);
	
	//Passing sortby and limit to contact lookup page : EASFP-51, EASFP-54
	var contactSortBy = (obj.contactSortBy === undefined) ? "defaultSorting" : obj.contactSortBy;        
    var contactResultsLimit =  (obj.contactResultsLimit === undefined || isNaN(parseInt(obj.contactResultsLimit))) ? 1000 : parseInt(obj.contactResultsLimit);
	
    //Handle outbound campaign calls which do have attached data as well as outgoing calls which do not have valuable attached data
    if (searchFieldsCount > 0){
		var searchList_ =  getSearchList(obj, false);
    	searchByFieldsListAndType(searchList_, searchAllFields, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
    }       
    else if(obj.fieldName != undefined && obj.fieldValue != undefined){
		var searchFieldName = obj.fieldName;
		var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
		_log("performOutboundVoiceAction search field " + searchFieldName + " for a value of " + searchFieldValue);        	
		searchByFieldAndType(searchFieldName,searchFieldValue, obj.id, searchObjectType, contactSortBy, contactResultsLimit)
    }
    else{
		_log("performOutboundVoiceAction search by DNIS");     
		searchByLookupPhoneNumberAndType(lookupNumber, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
    }
	
}

////////////////////////////////////////////////////////////////////////////////////////
// Email handling
////////////////////////////////////////////////////////////////////////////////////////

// screen pop for email

function performEmailAction(obj) {
    _log("in performEmailAction()");
    if (Salesforce.screenPopUser(obj)) {
        return;
    }
    var searchFieldName = "";
    var searchFieldValue = "";
    var lookupContact;
    
    /*Check the object type to search in
	1 - default: Account, Contact, Lead
	2 - account
	3 - personaccount
	4 - contact
     */        
    var searchObjectType = (obj.searchObjectType === undefined) ? "default" : obj.searchObjectType;        
    _log("performEmailAction  searchObjectType= " + searchObjectType);
    
    var searchAllFields = (obj.searchAllFields === undefined) ? true : (obj.searchAllFields.toLowerCase() == "true");        
    var searchFieldsCount =  (obj.searchFieldsCount === undefined) ? 0 : parseInt(obj.searchFieldsCount);  
    _log("performEmailAction  searchFieldsCount= " + searchFieldsCount);
	
	//Passing sortby and limit to contact lookup page : EASFP-51, EASFP-54
	var contactSortBy = (obj.contactSortBy === undefined) ? "defaultSorting" : obj.contactSortBy;        
	var contactResultsLimit =  (obj.contactResultsLimit === undefined || isNaN(parseInt(obj.contactResultsLimit))) ? 1000 : parseInt(obj.contactResultsLimit);
	
    if (searchFieldsCount > 0){
		var searchList_ =  getSearchList(obj, false);
    	searchByFieldsListAndType(searchList_, searchAllFields, obj.id, searchObjectType, contactSortBy, contactResultsLimit); 
    }    
    else{
	if(obj.source != undefined && obj.source != '') {
	    lookupContact = obj.source;
	    searchFieldName = (obj.fieldName === undefined) ? "" : obj.fieldName;
	    searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
	}
	else{
	    if(obj.destination != undefined){
		var emailAddr = obj.destination;
    		//remove trailing ; or ,
    		var lastChar1 = emailAddr.lastIndexOf(";");
    		var lastChar2 = emailAddr.lastIndexOf(",");
    		if(lastChar1 == (emailAddr.length-1) || lastChar2 == (emailAddr.length-1)){
    			//remove last character
    			emailAddr = emailAddr.slice(0,-1);			
    		}			
    		_log("emailAddr " + emailAddr);
    		lookupContact = emailAddr;
    		searchFieldName = "email";
    		searchFieldValue = emailAddr;
	    }
	}
    
	_log("performEmailAction search field " + searchFieldName + " for a value of " + searchFieldValue);
	searchByFieldAndType(searchFieldName,searchFieldValue, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
    }

}

////////////////////////////////////////////////////////////////////////////////////////
// Chat handling
////////////////////////////////////////////////////////////////////////////////////////

// screen pop for chat
function performChatAction(obj) {
    _log("in performChatAction()");
    // check for attached data sfdcObjectId - if it is already there, then pop that
    if (Salesforce.screenPopUser(obj)) {
        return;
    }

    var name = obj.source;
    var searchFieldName = (obj.fieldName === undefined) ? "" : obj.fieldName;
    var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
    _log("performChatAction search field " + searchFieldName + " for a value of " + searchFieldValue);
     
    var searchObjectType = (obj.searchObjectType === undefined) ? "default" : obj.searchObjectType;        
    _log("performChatAction  searchObjectType= " + searchObjectType);	
    
    var searchAllFields = (obj.searchAllFields === undefined) ? true : (obj.searchAllFields.toLowerCase() == "true");        
    var searchFieldsCount =  (obj.searchFieldsCount === undefined) ? 0 : parseInt(obj.searchFieldsCount);  
    _log("performChatAction  searchFieldsCount= " + searchFieldsCount);
	
	//Passing sortby and limit to contact lookup page : EASFP-51, EASFP-54
	var contactSortBy = (obj.contactSortBy === undefined) ? "defaultSorting" : obj.contactSortBy;        
    var contactResultsLimit =  (obj.contactResultsLimit === undefined || isNaN(parseInt(obj.contactResultsLimit))) ? 1000 : parseInt(obj.contactResultsLimit);
	
    if (searchFieldsCount > 0){
		var searchList_ =  getSearchList(obj, false);
    	searchByFieldsListAndType(searchList_, searchAllFields, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
 
    }
    else{
		// using the source attribute locate the contact
        searchByFieldAndType(searchFieldName,searchFieldValue,obj.id, searchObjectType, contactSortBy, contactResultsLimit);
    }
}


////////////////////////////////////////////////////////////////////////////////////////
// WorkItem handling
////////////////////////////////////////////////////////////////////////////////////////

// screen pop for WorkItem
function performWorkItemAction(obj) {
    _log("in performWorkItemAction()");
    // check for attached data sfdcObjectId - if it is already there, then pop that
    if (Salesforce.screenPopUser(obj)) {
        return;
    }

    var name = obj.source;
    var searchFieldName = (obj.fieldName === undefined) ? "" : obj.fieldName;
    var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
    _log("performWorkItemAction search field " + searchFieldName + " for a value of " + searchFieldValue);   
    
    var searchObjectType = (obj.searchObjectType === undefined) ? "default" : obj.searchObjectType;        
    _log("performWorkItemAction  searchObjectType= " + searchObjectType);
    
    var searchAllFields = (obj.mediaTypeSearchAllFields === undefined) ? true : (obj.mediaTypeSearchAllFields.toLowerCase() == "true");    
    _log("performWorkItemAction for work item screen pop searchAllFields= " + searchAllFields);
	
	//Passing sortby and limit to contact lookup page : EASFP-51, EASFP-54
	var contactSortBy = (obj.contactSortBy === undefined) ? "defaultSorting" : obj.contactSortBy;        
	var contactResultsLimit =  (obj.contactResultsLimit === undefined || isNaN(parseInt(obj.contactResultsLimit))) ? 1000 : parseInt(obj.contactResultsLimit);
	
    if(searchObjectType == "all"){
    	if(searchFieldName.includes(',') && searchFieldValue.includes(',')){
    		var fields = searchFieldName.split(',');
    		var values = searchFieldValue.split(',');
    		var searchList = {};
    		searchList.fields = fields;
			searchList.values = values;
    		searchByFieldsListAndType(searchList, searchAllFields, obj.id, searchObjectType, contactSortBy, contactResultsLimit)
    	}
    	else
    		searchByFieldAndType(searchFieldName,searchFieldValue, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
    }
    else{    	
		// using the source attribute locate the contact
    	searchByFieldAndType(searchFieldName,searchFieldValue, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
    }
}

//AgentWork screen pop for "Chat CRM" WorkItem
function performChatCRMAction(obj) {
    _log("in performChatCRMAction()");

	// Live Agent
    _log("liveChatDistribution call start");
    Salesforce.liveChatDistribution(obj);
    _log("liveChatDistribution call end");
}

// AgentWork screen pop for "Case CRM" WorkItem
function performCaseCRMAction(obj) {
    _log("in performCaseCRMAction()");
    
	// Live Agent
    _log("liveChatDistribution call start");
    Salesforce.liveChatDistribution(obj);
    _log("liveChatDistribution call end");
}

////////////////////////////////////////////////////////////////////////////////////////
//SMS handling
////////////////////////////////////////////////////////////////////////////////////////

//screen pop for SMS
function performSmsAction(obj) {
    _log("in performSmsAction()");
    // check for attached data sfdcObjectId - if it is already there, then pop that
    if (Salesforce.screenPopUser(obj)) {
        return;
    }
   
    var name = obj.source;
    var searchFieldName = (obj.fieldName === undefined) ? "" : obj.fieldName;
    var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
    _log(" performSmsAction search field " + searchFieldName + " for a value of " + searchFieldValue);
   
  
   var searchObjectType = (obj.searchObjectType === undefined) ? "default" : obj.searchObjectType;        
   _log("performSmsAction  searchObjectType= " + searchObjectType);
   
   var searchAllFields = (obj.searchAllFields === undefined) ? true : (obj.searchAllFields.toLowerCase() == "true");        
   var searchFieldsCount =  (obj.searchFieldsCount === undefined) ? 0 : parseInt(obj.searchFieldsCount);  
   _log("performSmsAction  searchFieldsCount= " + searchFieldsCount);

   //Passing sortby and limit to contact lookup page : EASFP-51, EASFP-54
	var contactSortBy = (obj.contactSortBy === undefined) ? "defaultSorting" : obj.contactSortBy;        
    var contactResultsLimit =  (obj.contactResultsLimit === undefined || isNaN(parseInt(obj.contactResultsLimit))) ? 1000 : parseInt(obj.contactResultsLimit);
   
   if (searchFieldsCount > 0){
		var searchList_ =  getSearchList(obj, false);
   		searchByFieldsListAndType(searchList_, searchAllFields, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
   }  
   else{     
	   searchByFieldAndType(searchFieldName,searchFieldValue, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
   }
}

////////////////////////////////////////////////////////////////////////////////////////
//WebCallback handling
////////////////////////////////////////////////////////////////////////////////////////

//screen pop for WebCallback
function performWebCallbackAction(obj) {
    _log("in performWebCallbackAction()");
	
    //add startDate to interaction for Subject on Activity
    var startDate = getDateB();
    var newData = '{"startDate":"' + startDate + '","id":"' + obj.id + '"}';
    Workspace.sendAttachData(newData);
	
    // check for attached data sfdcObjectId - if it is already there, then pop that
    if (Salesforce.screenPopUser(obj)) {
	return;
    }

    var name = obj.source;
    var searchFieldName = (obj.fieldName === undefined) ? "" : obj.fieldName;
    var searchFieldValue = (obj.fieldValue === undefined) ? "" : obj.fieldValue;
    _log("performWebCallbackAction search field " + searchFieldName + " for a value of " + searchFieldValue);
	 
      
    var searchObjectType = (obj.searchObjectType === undefined) ? "default" : obj.searchObjectType;        
    _log("performWebCallbackAction  searchObjectType= " + searchObjectType);
    
    var searchAllFields = (obj.searchAllFields === undefined) ? true : (obj.searchAllFields.toLowerCase() == "true");        
    var searchFieldsCount =  (obj.searchFieldsCount === undefined) ? 0 : parseInt(obj.searchFieldsCount);  
    _log("performEmailAction  searchFieldsCount= " + searchFieldsCount);
	
	//Passing sortby and limit to contact lookup page : EASFP-51, EASFP-54
	var contactSortBy = (obj.contactSortBy === undefined) ? "defaultSorting" : obj.contactSortBy;        
	var contactResultsLimit =  (obj.contactResultsLimit === undefined || isNaN(parseInt(obj.contactResultsLimit))) ? 1000 : parseInt(obj.contactResultsLimit);
	
    if (searchFieldsCount > 0){
		var searchList_ =  getSearchList(obj, false);
    	searchByFieldsListAndType(searchList_, searchAllFields, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
    }    
    else{
    	searchByFieldAndType(searchFieldName,searchFieldValue, obj.id, searchObjectType, contactSortBy, contactResultsLimit);
    }
}

////////////////////////////////////////////////////////////////////////////////////////
// Open Media handling
////////////////////////////////////////////////////////////////////////////////////////

// screen pop for OpenMedia
function performOpenMediaAction(obj) {
    _log("in performOpenMediaAction()");
    // check for attached data sfdcObjectId - if it is already there, then pop that
    if (Salesforce.screenPopUser(obj)) {
        return;
    }

    var name = obj.source;
    
    var searchObjectType = (obj.searchObjectType === undefined) ? "default" : obj.searchObjectType;        
	_log("performOpenMediaAction  searchObjectType= " + searchObjectType);
	
	//Passing sortby and limit to contact lookup page : EASFP-51, EASFP-54
	var contactSortBy = (obj.contactSortBy === undefined) ? "defaultSorting" : obj.contactSortBy;        
    var contactResultsLimit =  (obj.contactResultsLimit === undefined || isNaN(parseInt(obj.contactResultsLimit))) ? 1000 : parseInt(obj.contactResultsLimit);
    
    if (searchObjectType == 'account' || searchObjectType == 'personaccount'){
		searchByFieldAndType('Name', name, searchObjectType, contactSortBy, contactResultsLimit);
    }
    else{
		gl_WorkspaceConnectorController.IsPersonAccountEnabled(function(result){
		    if (result == null || result == 'false'){	 
		    	// using the source attribute locate the contact
				gl_WorkspaceConnectorController.findContactFromOpenMediaAddress(name, function(o) {
                    if (o != null) {
                    	Salesforce.screenPop(o.Id); 
                    	//else Workspace.sendFocusChange(o.Id, true); //move screenpop so that it wasn't called while we were still sending events
                        //inform workspace of SFobject id for subsequent use in activity creation and transfer
                        var newData = '{"sfdcObjectId":"' + o.Id + '","id":"' + obj.id + '"}';
                        Workspace.sendAttachData(newData);
                    } else {
                        _log("performOpenMediaAction: No records found with Name containing: " + name);
                        //open search
                        Salesforce.openSearch("", obj.id); 
                    }
				});
		    }
		});
    }
}


////////////////////////////////////////////////////////////////////////////////////////
// Case handling
////////////////////////////////////////////////////////////////////////////////////////

function searchCaseByField(searchFieldName,searchFieldValue, ixnId)
{
    _log("in searchCaseByField");
    if(searchFieldName!= undefined && searchFieldValue != undefined){
    	 gl_WorkspaceConnectorController.findCaseObject(searchFieldName,searchFieldValue, function(o) {
    	     if (o != null) {
    		 if (o.length == 1){    		 
    		     if(o.ContactId != undefined){
    			 Salesforce.screenPop(o.ContactId);
    			 var newData = '{"sfdcObjectId":"' + o.ContactId + '","id":"' + ixnId + '"}';
    			 Workspace.sendAttachData(newData); 
    		     }
    		     if(o.Id != undefined){
    			 Salesforce.screenPop(o.Id);
    			 var newData = '{"sfdcCaseId":"' + o.Id + '","id":"' + ixnId + '"}';
    			 Workspace.sendAttachData(newData);
    		     }   
    		 }
    		 else if(o.length > 1){
    		     _log("searchByFieldsListAndType Multiple entry, open the new search page");
    		     Salesforce.openSearchCase(o,ixnId);
    		 }
    		 else{
    		     //open search
    		     Salesforce.openSearchCase("", ixnId);     
    		 }
    	     }
    	     else {
    		 _log("searchCaseByField: result = " + o);
    		 //open search
    		 Salesforce.openSearchCase("", ixnId); 
    	     }
    	 });
    }
    else
	Salesforce.openSearchCase("", ixnId); 
}

function searchCaseByFieldsList(searchList, searchAllFields, ixnId)
{
    _log("in searchCaseByFieldsList" );
    gl_WorkspaceConnectorController.findCaseObjectMapSearch(searchList.fields, searchList.values, searchAllFields, function(o) {
	if (o != null) {
	    if (o.length == 1){ 
		_log("searchCaseByFieldsList:  One entry, open the case");
		if(o[0].ContactId != undefined){		    
		    Salesforce.screenPop(o[0].ContactId);
		    var newData = '{"sfdcObjectId":"' + o[0].ContactId + '","id":"' + ixnId + '"}';
		    Workspace.sendAttachData(newData); 
		}
		if(o[0].Id != undefined){
		    Salesforce.screenPop(o[0].Id);
		    var newData = '{"sfdcCaseId":"' + o[0].Id + '","id":"' + ixnId + '"}';
		    Workspace.sendAttachData(newData);
		}   
	    }
	    else if(o.length > 1){
		_log("searchByFieldsListAndType Multiple entry, open the new search page");
		Salesforce.openSearchCase(o,ixnId);
	    }
	    else{
		//open search
		_log("searchCaseByFieldsList:  No entry, open the new search page");
		Salesforce.openSearchCase("", ixnId);     
	    }
	}
	else {
	    _log("searchCaseByFieldsList: result = " + o);
	    //open search
	    Salesforce.openSearchCase("", ixnId); 
	}
    });
}


function performCaseAction(obj){
	_log("in performCaseAction");
    // check for attached data sfdcCaseId and sfdcObjectId - if it is already there, then pop that
	var sfdcCase = (obj.userData.sfdcCaseId === undefined) ? "" : obj.userData.sfdcCaseId;
	if (sfdcCase != "") {
		Salesforce.screenPop(sfdcCase);
		Salesforce.screenPopUser(obj);
		return;
	}
	
    if (Salesforce.screenPopUser(obj)) {
        return;
    }
    
    var caseSearchFieldsCount =  (obj.caseSearchFieldsCount === undefined) ? 0 : parseInt(obj.caseSearchFieldsCount);  
    _log("searchCaseByFieldsList for case screen pop caseSearchFieldsCount= " + caseSearchFieldsCount);
    var caseSearchAllFields = (obj.caseSearchAllFields === undefined) ? true : (obj.caseSearchAllFields.toLowerCase() == "true");    
    _log("searchCaseByFieldsList for case screen pop caseSearchAllFields= " + caseSearchAllFields);
    if (caseSearchFieldsCount > 0){    	
    	var searchList_ =  getSearchList(obj, true);
    	searchCaseByFieldsList(searchList_, caseSearchAllFields, obj.id);
    }
    else if(obj.caseSfdcField != undefined && obj.caseSfdcField != undefined){
    	var searchFieldName = obj.caseSfdcField;
    	var searchFieldValue = (obj.caseSfdcFieldValue === undefined) ? "" : obj.caseSfdcFieldValue;
    	searchCaseByField(searchFieldName, searchFieldValue, obj.id);    	 
    }
    else
	Salesforce.openSearchCase("", obj.id);   	
}

////////////////////////////////////////////////////////////////////////////////////////
// Task handling
//
// Writes a simple task from provided disposition information
////////////////////////////////////////////////////////////////////////////////////////

function getDateB() {
    var date = new Date();
    var hrs = date.getHours();
    if(hrs < 10)
    	hrs = "0" + hrs;
    var min = date.getMinutes();
    if(min < 10)
    	min = "0" + min;
    var sec = date.getSeconds();
    if(sec < 10)
    	sec = "0" + sec;
    var day = date.getDate();
    if(day < 10)
    	day = "0" + day;
    var month = date.getMonth() + 1;
    if(month < 10)
    	month = "0" + month;
    return (date.getFullYear()) + '-' + month + '-' + day
        + " " + hrs + ':' + min + ':' + sec;
}

function getDisplayDate() {
    var date = new Date();
    var hrs = date.getHours();
    if(hrs < 10)
    	hrs = "0" + hrs;
    var min = date.getMinutes();
    if(min < 10)
    	min = "0" + min;
    var sec = date.getSeconds();
    if(sec < 10)
    	sec = "0" + sec;
    return (date.getMonth() + 1) + '/' + (date.getDate()) + '/' + date.getFullYear()
        //+ " " + date.getHours() + ':' + date.getMinutes() + ':' + date.getSeconds();
        + " " + hrs + ':' + min + ':' + sec;
}

//Case creation features (EASFP-21)
function createCase(obj, objIdForCase, isItFromPrepare){
	_log("Create case");
	var mapCase = {
		"Subject":(obj.type === undefined) ? "Case "+getDateB() : obj.type+ ' ' + getDateB(),
		"Description": (obj.notes === undefined) ? "" : obj.notes
	};
	var defaultValues=null;
	
	if('caseDefaultValues' in obj){
		defaultValues=obj.caseDefaultValues;
		_log("Default values configured for case creation: " + defaultValues);
		jQuery.extend(mapCase, defaultValues);
	}else{
		_log("Default values are not configured for case creation");
	}
	
	_log("Case attributes :" + JSON.stringify(mapCase));

	var caseId = "";
	if(obj.userData != undefined && obj.userData.sfdcCaseId != undefined)
		caseId=obj.userData.sfdcCaseId;

	if(caseId != ""){
		_log("Going to update case " + caseId);
		gl_WorkspaceConnectorController.updateCase(caseId, mapCase, objIdForCase,function(result) {
			//Update to avoid caseId is being overridden in SFDCObjectId
			if(objIdForCase != undefined && objIdForCase != ""){
				_log("Update Case: Setting Genesys_AutoCreatedCase : "+ caseId);
				window.sessionStorage.setItem("Genesys_AutoCreatedCase", caseId);
			}
			Salesforce.screenPopRefresh(caseId);
			_log(result);
		});
	}else{
		_log("Going to create a case");
		gl_WorkspaceConnectorController.createCase(mapCase, objIdForCase,function(result) {
		if(result!=null && result!="case not created"){
			_log("Created Case: " + result);
			var newData = '{"sfdcCaseId":"' + result + '","id":"' + obj.id + '"}';
			Workspace.sendAttachData(newData);
			//Update to avoid caseId is being overridden in SFDCObjectId
			_log("Create Case: Setting Genesys_AutoCreatedCase : " + result);
			window.sessionStorage.setItem("Genesys_AutoCreatedCase", result);

			var displayCase = (obj.displayCase === undefined) ? "false" : obj.displayCase;
    		_log("in createCase: displayCase = " + displayCase);
			if (displayCase.toLowerCase() == 'true'){
	        	_log("createCase: Pop the newly created case");
				Salesforce.screenPopRefresh(result);				
	        }
	        else{
	        	//Had to create a small delay since salesforce was not quick with the case
	        	//list update in the Lightning mode
	        	if(objIdForCase != undefined && objIdForCase != ""){  
	        	    //Refresh another screen and get back to the sfdcObjectId screen
	        	    //This enforces the update of the case list
	        	    Salesforce.screenPopRefresh(result);
	        	    Salesforce.screenPopRefresh(objIdForCase);
				}
			}
		}else{
			_log(result);
		}

	});
	}

	
}

function createTask(createObj, objIdForActivity, isItFromPrepare) {
    _log("in createTask");
    var createObjType = (createObj.type === undefined) ? getDisplayDate() : createObj.type;
    _log("createTask for " + createObjType);
    var displayDate = (createObj.startDate === undefined) ? getDisplayDate() : createObj.startDate;
    var lookupSource = "";
    var ixnType = "";
    var mediaType = "";
    var startDate = createObj.startDate;
    var endDate = createObj.endDate;    
    var transferredFrom = (createObj.transferredFrom===undefined) ? "" : createObj.transferredFrom;
    var _FIELDNAME = (createObj.fieldName === undefined) ? "" : createObj.fieldName;
    var _FIELDVALUE = (createObj.fieldValue === undefined) ? "" : createObj.fieldValue;
    var _SFDCCASEID = (createObj.userData.sfdcCaseId === undefined) ? "" : createObj.userData.sfdcCaseId;
    _log("in createTask: createObj.displayActivity = " + createObj.displayActivity);
    var displayActivity = (createObj.displayActivity === undefined) ? "false" : createObj.displayActivity;
	_log("in createTask: displayActivity = " + displayActivity);
	//To identify whether case creation is initiated - Case creation features (EASFP-21)
	var isCaseCreationInitiated = (createObj.isCaseCreationEnabled === undefined) ? "false" : createObj.isCaseCreationEnabled;
	_log("in createTask: isCaseCreationInitiated = " + isCaseCreationInitiated);

	//Handling task default values - EASFP-21
	var defaultTaskValues=null;
	if('taskDefaultValues' in createObj){
		defaultTaskValues=createObj.taskDefaultValues;
		_log("Setting Default values to task map "+JSON.stringify(defaultTaskValues));
	}


    switch (createObjType) {
        case "Voice":
            // if outbound then use destination as source
            if (createObj.calltype == "Outbound") {
                lookupSource = createObj.destination;
                //ixnType = "Outbound";
                mediaType = (createObj.outboundtype === undefined) ? "" : createObj.outboundtype;
                if(createObj.outboundtype === undefined || createObj.outboundtype === ""){
                	ixnType = "Voice-Outbound Dial"; 
                }
                else ixnType = "Voice-Outbound";
            }
            else {
                if (createObj.role == 'RoleOrigination') {
                    lookupSource = createObj.destination;
                    ixnType = "Voice-Outbound Dial";
                }
                else {
                    lookupSource = createObj.source;
                    ixnType = "Voice-Inbound";
                }
            }
            break;
        case "Email":        	
        	if(createObj.calltype == "Inbound" && createObj.source != undefined && createObj.source != ''){
        		lookupSource = createObj.source;
        		ixnType = "Email-Inbound";
        	}
        	else if(createObj.calltype == "Outbound" && createObj.destination != undefined && createObj.destination != ''){
        			lookupSource = createObj.destination;
        			ixnType = "Email-Outbound";
				 }
            break;
        case "Chat":
            lookupSource = createObj.source;
            ixnType = createObj.type;
            break;
        case "InteractionWorkItem":
            lookupSource = createObj.source;
            ixnType = createObj.type;
            mediaType = createObj.mediaType;
            break;
        case "Sms":
            lookupSource = createObj.source;
            ixnType = createObj.type;
            break;
        case "WebCallback":
            lookupSource = createObj.source;
            ixnType = createObj.type;
            displayDate = (createObj.userData.startDate === undefined) ? getDisplayDate() : createObj.userData.startDate;
            break;            
        case "OpenMedia":
            lookupSource = createObj.source;
            ixnType = createObj.mediaType;
            break;
        case "Social":
            lookupSource = createObj.source;
            ixnType = createObj.type;
            break;
        default:
            _log("activity not created for " + createObj.type);
            return;
    }

    if (objIdForActivity != "") {
        _log("createTask: " + ixnType + " using objIdForActivity " + objIdForActivity);
    }
    else {
        _log("createTask: " + ixnType + " using field " + _FIELDNAME + " to search for a value of " + _FIELDVALUE);
    }

    var _CALL_DURATION = (createObj.duration === undefined) ? "" : createObj.duration;
    var _IXNTYPE = ixnType;
    var _COMMENTS = (createObj.notes === undefined) ? "" : createObj.notes;
    //var _DISP = (createObj.userData.DispositionCode === undefined) ? "" :
    //    createObj.userData.DispositionCode;
    var _DISP = (createObj.dispositionCode === undefined) ? "": createObj.dispositionCode;
	//Fix for the disposition code is updated as empty issue - EASFP-35
	if(_DISP == "")
		_DISP = (createObj.userData.DispositionCode === undefined) ? "" : createObj.userData.DispositionCode;
	_log("createTask: _DISP = " + _DISP);

	var _DNIS = (createObj.destination === undefined) ? "" : createObj.destination;
    var _GENESYSID = (createObj.id === undefined) ? "" : createObj.id;
	var _ANI = (createObj.source === undefined) ? "" : createObj.source;
    var _SFDC_OBJECT_ID = objIdForActivity;
    
    //email specific
    var _Attachment_Flag = (createObj.Attachment_Flag === undefined) ? "" : createObj.Attachment_Flag;
    var _EMAIL_DESC = (createObj.emailDescription === undefined) ? "" : createObj.emailDescription;
    if(_EMAIL_DESC != ""){
    	_EMAIL_DESC = "\n" + "***EMAIL***" + _EMAIL_DESC;
    }
    
    var _CHAT_TRANSCRIPT = (createObj.transcript === undefined) ? "" : createObj.transcript;
    if(_CHAT_TRANSCRIPT != ""){
    	_CHAT_TRANSCRIPT = "\n" + "***CHAT***" + "\n" + _CHAT_TRANSCRIPT;
    }
    
    var _SMS_TRANSCRIPT = (createObj.smstranscript === undefined) ? "" : createObj.smstranscript;
    if(_SMS_TRANSCRIPT != ""){
    	_SMS_TRANSCRIPT = "\n" + "***SMS***" + "\n" + _SMS_TRANSCRIPT;
    }    
    
    var _REASON = ((createObj.reason === undefined) ? "MarkedDone" : createObj.reason).toLowerCase();
    _log("createTask: _REASON = " + _REASON);
    
    var _USE_WDE_NOTES = ((createObj.useWDEnotes === undefined) ? "true" : createObj.useWDEnotes).toLowerCase();
    _log("createTask: _USE_WDE_NOTES = " + _USE_WDE_NOTES);
    
    //There may be some WDE comments at the start of the call for transfers.  
    //If WDE notes are in use, they can be reflected in the activity from the start
    if (_USE_WDE_NOTES == "true")
    {
	if(_COMMENTS != ""){ 
	    	_COMMENTS = "*** NOTES ***" + "\n" + _COMMENTS;
	}   
	    
    }

    //Transcripts and email descriptions are added at the end of the call
    if (_REASON == "markeddone")
    {    
        if(_EMAIL_DESC != ""){
        		_COMMENTS = "\n" +_COMMENTS + _EMAIL_DESC;
        }
        if(_CHAT_TRANSCRIPT != ""){
        		_COMMENTS = "\n" +_COMMENTS + _CHAT_TRANSCRIPT;
        }
        if(_SMS_TRANSCRIPT != ""){
    		_COMMENTS = "\n" +_COMMENTS + _SMS_TRANSCRIPT;
        }
    }
    
    var _SFDC1value = (createObj.SFDC1value === undefined) ? "" : createObj.SFDC1value;
    var _SFDC2value = (createObj.SFDC2value === undefined) ? "" : createObj.SFDC2value;
    var _SFDC3value = (createObj.SFDC3value === undefined) ? "" : createObj.SFDC3value;
    var _SFDC4value = (createObj.SFDC4value === undefined) ? "" : createObj.SFDC4value;
    var _SFDC5value = (createObj.SFDC5value === undefined) ? "" : createObj.SFDC5value;
    var _SFDC1field = (createObj.SFDC1field === undefined) ? "" : createObj.SFDC1field;
    var _SFDC2field = (createObj.SFDC2field === undefined) ? "" : createObj.SFDC2field;
    var _SFDC3field = (createObj.SFDC3field === undefined) ? "" : createObj.SFDC3field;
    var _SFDC4field = (createObj.SFDC4field === undefined) ? "" : createObj.SFDC4field;
    var _SFDC5field = (createObj.SFDC5field === undefined) ? "" : createObj.SFDC5field;

	//SFP-1: Map callType value Activity standard field CallType
    var CALL_TYPE = (createObj.calltype === undefined) ? "" : createObj.calltype;

    _log("creating task map");
    var mapActivity = {
    	"Call Duration": _CALL_DURATION,
        "IXN Type": _IXNTYPE,
        "Comments": _COMMENTS,
        "Disposition": _DISP, "DNIS": _DNIS,
        "GenesysId": _GENESYSID, "ANI": _ANI,
        "sfdc Object Id": _SFDC_OBJECT_ID,
        "SFDC1value": _SFDC1value, "SFDC2value": _SFDC2value, "SFDC3value": _SFDC3value,
        "SFDC4value": _SFDC4value, "SFDC5value": _SFDC5value,
        "SFDC1field": _SFDC1field, "SFDC2field": _SFDC2field, "SFDC3field": _SFDC3field,
        "SFDC4field": _SFDC4field, "SFDC5field": _SFDC5field,
        "Media Type": mediaType,
        "DATE": displayDate, 
        "fieldName" : _FIELDNAME, "fieldValue" : _FIELDVALUE,
        "StartDate": startDate, "EndDate": endDate,
        "TransferredFrom": transferredFrom,
        "sfdcCaseId" : _SFDCCASEID,
        "Use WDE Notes" : _USE_WDE_NOTES,
		"CallType" : CALL_TYPE
    };
    
    var searchObjectType = (createObj.searchObjectType === undefined) ? "default" : createObj.searchObjectType;        
    _log("createTask  searchObjectType= " + searchObjectType);
	
    //MS:04202017 - Provide the option of create vs update of activity to allow creation of activity at the start of interaction
    gl_WorkspaceConnectorController.findActivity(createObj.id, function(taskID) {
	if(taskID != null){
		_log("createTask Activity Found - updateActivity " + taskID);

	    /*  =====================   Send activity Description to WDE for storage in UCS 
		if (_USE_WDE_NOTES == "false")
		{
		    //If comments are inserted from SF, get the comments before it gets updated by chat/sms transcript or email description
		    gl_WorkspaceConnectorController.getActivityComments(taskID, function (sfComment, event){
			_log("createTask Activity Found with description of: " + sfComment);
			Workspace.sendActivityDescription(_GENESYSID, sfComment);
		    });
		}
	    */
	    gl_WorkspaceConnectorController.updateActivity(taskID,mapActivity, defaultTaskValues, function(result, event) {
		_log("createTask   updateActivity RESULT = " + result);		
		if (result == "success"){
		    Salesforce.screenPopRefresh(taskID);
		    if(_Attachment_Flag == 'True'){
			_log("createTask Get attachment info on update activity");
			//Attachment info is in the form of :
			//	"attachments": [
			//		{"id":"1", "name":"a.zip", "desc":"file a", "mimeType":"gzip"},
			//		{"id":"2", "name":"b.zip", "desc":"file b", "mimeType":"gzip"}
			//	]
			var attachmentInfo = createObj.attachments;
			_log("createTask Get attachment info on update activity displayActivity=" + displayActivity);
			getAttachment(attachmentInfo,createObj.id,0,taskID, displayActivity);
		    }
		}    		
	    });
	    return;
	}
	else{
	    _log("createTask Activity Not Found - create Activity");
		
		gl_WorkspaceConnectorController.createActivity(mapActivity, searchObjectType, defaultTaskValues, function(result, event) {
	        _log("createTask RESULT = " + result);
	        if (result != null && result != "not found") {
	            _log("createTask new activity is created - " + result + " displayActivity = " + displayActivity);	            
	            //The option is added to manage the display/hide of activity when an interaction is accepted/answered
	            if (displayActivity.toLowerCase() == 'true'){
	        	_log("createTask Pop the new activity");
	        	Salesforce.screenPopRefresh(result);
	            }
				
				
				else{     
	        	//Refresh the search screen pop result that this activity is associated with 
	        	//Had to create a small delay since salesforce was not quick with the activity
				//list update in the Lightning mode
				//added isCaseCreationInitiated as it overrides the case display page with the sfdcObject page
	        	if(_SFDC_OBJECT_ID != undefined && _SFDC_OBJECT_ID != ""){  
	        	    //Option 1:
	        	    //There seems there is an issue with Lightning, tried a time delay on the Salesforce end
	        	    //but the result was inconsistent
	        	    /*
	        	    var myInterval = setInterval(function(){
	        		_log("Refresh the screen with the existing sfdcObjectId= " + _SFDC_OBJECT_ID);
	        		 Salesforce.screenPopRefresh(_SFDC_OBJECT_ID);	        		
	        		clearInterval(myInterval);	        		
	        	    },200);
	        	    */  
	        	    //Option 2:
	        	    //Refresh another screen and get back to the sfdcObjectId screen
	        	    //This enforces the update of the activity list
	        	    Salesforce.screenPopRefresh(result);
	        	    Salesforce.screenPopRefresh(_SFDC_OBJECT_ID);	
	        	}
	            }

	            if(_Attachment_Flag == 'True'){
	        	_log("createTask Get attachment info on create activity");
		        //Attachment info is in the form of :
		        //	"attachments": [
		        //		{"id":"1", "name":"a.zip", "desc":"file a", "mimeType":"gzip"},
		        //		{"id":"2", "name":"b.zip", "desc":"file b", "mimeType":"gzip"}
		        //	]
		
	            	var attachmentInfo = createObj.attachments;
	            	_log("createTask Get attachment info on create activity displayActivity=" + displayActivity);
		        getAttachment(attachmentInfo,createObj.id,0,result, displayActivity);	            }
	        }
	        else {
	            _log("createTask Could not create task for");
	        }
	    	if(typeof(Storage) !== "undefined" && window!=null && window.sessionStorage!=null)
	    	{
	    		window.sessionStorage.setItem("createTask Genesys_activeInteraction", "");
	    		_log("createTask resetting Genesys_activeInteraction ");
	    	}
	    });
	}
    });
    
}


function getAttachment(arrAttachId,interactionId,idx,myTaskID, redirectToTaskID){
	_log("in getAttachment");    
	//Passing message to WDE through websocket if UseWebsockets option is enabled - EASFP-9
	var wsParams = Workspace.getParameters();
	if(wsParams.useWebSockets){
		var msgJ = "";
		if(arrAttachId.length > idx ){
			for(var i = idx; i < arrAttachId.length; i++){
				if(arrAttachId.length == (i+1)){
					msgJ = '{"action":"RequestAttachment",' + wsParams.CI_connectionData + ',"actionData":{"id":"' + interactionId + '","attachmentID":"' + arrAttachId[i].id + '","attachmentName":"' + arrAttachId[i].name + '","attachmentMimeType":"' + arrAttachId[i].mimeType + '","myTaskID":"' + myTaskID + '","redirectToTaskID":"' + redirectToTaskID + '" ,"finalRequest":"true"}}';
				}else{
					msgJ = '{"action":"RequestAttachment",' + wsParams.CI_connectionData + ',"actionData":{"id":"' + interactionId + '","attachmentID":"' + arrAttachId[i].id + '","attachmentName":"' + arrAttachId[i].name + '","attachmentMimeType":"' + arrAttachId[i].mimeType + '","myTaskID":"' + myTaskID + '","redirectToTaskID":"' + redirectToTaskID + '"}}';
				}
				Workspace.sendToWSClient(msgJ);
			}
		}
	}else{
		if(arrAttachId.length > idx ){	
			var msgJ;
			if(arrAttachId.length == (idx+1))
				//final request
				msgJ = '{"action":"RequestAttachment",' + wsParams.CI_connectionData + ',"actionData":{"id":"' + interactionId + '","attachmentID":"' + arrAttachId[idx].id + '","attachmentName":"' + arrAttachId[idx].name + '","finalRequest":"true"}}';
			else
				msgJ = '{"action":"RequestAttachment",' + wsParams.CI_connectionData + ',"actionData":{"id":"' + interactionId + '","attachmentID":"' + arrAttachId[idx].id + '","attachmentName":"' + arrAttachId[idx].name + '"}}';
			
			//this.requestUrl = wsParams.pollUrl + ":" + wsParams.pollPort + "/request=" + msgJ;
			//_log("getAttachment url = " + this.requestUrl);
				this.requestUrl = wsParams.pollUrl + ":" + wsParams.pollPort;
				_log("getAttachment data = " + msgJ);
				$.ajax({
					url: requestUrl,
					data: "/request=" + msgJ,
					timeout: 20000,
					async: true,
					crossDomain: true,
					cache: false,
					//dataType: 'text',
					dataType: 'jsonp',
					success: function (data) {
						// call the callback on retrieval

						//setup first time call info
						var attachmentInfo = arrAttachId[idx];
						attachmentInfo.positionIndex = 0;
						var attachmentId = null;
						uploadAttachment(attachmentId,data,attachmentInfo,myTaskID, redirectToTaskID);
						getAttachment(arrAttachId,interactionId,idx+1,myTaskID, redirectToTaskID);
					},
					error: function (xhr, ajaxOptions, thrownError) {
						if (thrownError == 'timeout')
							_log("Failed to connect for attachment request");
						else
							_log('Request error ' + xhr.status + ' ' + thrownError);
					}
				});
			}
		}
}

/*
* Process the attachment data response
*/


var maxStringSize = 6000000;    //Maximum String size is 6,000,000 characters
var maxFileSize =   4350000;    
var chunkSize =      950000;    //Maximum Javascript Remoting message size is 1,000,000 characters


function uploadAttachment(attachmentId,attachmentData,attachmentInfo,myTaskID, redirectToTaskID) {
    var attachmentBody = "";
    //var descriptionText = "";
    //var nameText = "";
    //var mimeType = "";
    var doneUploading = false;
    var positionIndex = attachmentInfo.positionIndex;
    var attachment = (attachmentData.attachment === undefined) ? "" : attachmentData.attachment;
    var descriptionText = (attachmentInfo.desc === undefined) ? "" : attachmentInfo.desc;
    var nameText = (attachmentInfo.name === undefined) ? "" : attachmentInfo.name;
    var mimeType = (attachmentInfo.mimeType === undefined) ? "" : attachmentInfo.mimeType;
    var fileSize = attachment.length;
    _log("uploadAttachment " + nameText + ", fileSize = " + fileSize);
    //temporary check to prevent this APEX error
    // String length exceeds maximum: 6000000
    if(fileSize > maxStringSize){
    	_log("error adding attachment - String length exceeds maximum: 6000000");
    	return;
    }
    
    _log("mimeType = " + mimeType);
    if(fileSize <= positionIndex + chunkSize) {
      attachmentBody = attachment.substring(positionIndex);
      doneUploading = true;
    } else {
      attachmentBody = attachment.substring(positionIndex, positionIndex + chunkSize);
    }
    

    _log("Uploading " + attachmentBody.length + " chars of " + fileSize);
    _log("myTaskID: " + myTaskID + " descriptionText: " + descriptionText + " nameText: " + nameText + " mimeType: " + mimeType + "attachmentId: "  + attachmentId);
    gl_WorkspaceConnectorController.addAttachment(myTaskID,descriptionText,nameText,mimeType,attachmentBody,attachmentId, function(result){
    	_log("addAttachment result = " + result);
    	if(result != null && result != "error") {
        	//OOP = Attachment
          if(result.substring(0,3) == '00P') { 
            if(doneUploading == true) {
              _log("doneUploading");
              if (redirectToTaskID === undefined || redirectToTaskID.toLowerCase() == 'true'){
        	  _log("screenpop the task = " + myTaskID);
        	  Salesforce.screenPopRefresh(myTaskID);
              }
            } else {
              _log("continueUploading");             
              attachmentInfo.positionIndex += chunkSize; 
              _log("total uploaded so far = " + attachmentInfo.positionIndex);
              uploadAttachment(result,attachmentData,attachmentInfo,myTaskID, redirectToTaskID);
            }
          }
        } else {
          _log("error adding attachment");
        }
      }
    );
  }



////////////////////////////////////////////////////////////////////////////////////////
//Miscellaneous functions
//
//
////////////////////////////////////////////////////////////////////////////////////////

function processNavigation(payload){
	_log("processNavigation for " + payload);
	var myObjResult = JSON.parse(payload);
	var objectId = (myObjResult.recordId === undefined) ? "" : myObjResult.recordId;
	var genesysId = window.sessionStorage.getItem("Genesys_activeInteraction");
	var search_completed = window.sessionStorage.getItem("Genesys_search_completed");
	var useFocusedRecord = window.sessionStorage.getItem("Genesys_useFocusedRecord");
	var autoCreatedCase = window.sessionStorage.getItem("Genesys_AutoCreatedCase");

	_log("   genesysId = " + genesysId + ", search_completed = " + search_completed + ", useFocusedRecord = " + useFocusedRecord +", autoCreatedCase=" + autoCreatedCase);
	
	var sendAttachedData = false;
	if(objectId != "" && genesysId != "" && search_completed == "true")
		sendAttachedData = true;

	if(genesysId != "" && useFocusedRecord != null && useFocusedRecord.toLowerCase() == "true")
		sendAttachedData = true;
	
	if(myObjResult.objectType == "Contact" && sendAttachedData){
	        var newData = '{"sfdcObjectId":"' + objectId + '","id":"' + genesysId + '"}';
	        Workspace.sendAttachData(newData);
	    	window.sessionStorage.setItem("Genesys_search_completed", "");
	}
	else if(myObjResult.objectType == "Account" && sendAttachedData){
	        var newData = '{"sfdcObjectId":"' + objectId + '","id":"' + genesysId + '"}';
	        Workspace.sendAttachData(newData);
	    	window.sessionStorage.setItem("Genesys_search_completed", "");
	}
	else if(myObjResult.objectType == "Lead" && sendAttachedData){
	        var newData = '{"sfdcObjectId":"' + objectId + '","id":"' + genesysId + '"}';
	        Workspace.sendAttachData(newData);
	    	window.sessionStorage.setItem("Genesys_search_completed", "");
	}
	else if(myObjResult.objectType == "Case" && sendAttachedData){
			var newData = '{"sfdcObjectId":"' + objectId + '","id":"' + genesysId + '"}';
			//For not updating sfdcObjectId for autocreated cases - it is overriding actual screenpop objects - EASFP-21
			if(autoCreatedCase!=objectId){
				Workspace.sendAttachData(newData);
			}
			
	    	window.sessionStorage.setItem("Genesys_search_completed", "");
	}
	//Added task check - For not updating sfdcObjectId for autocreated cases - it is overriding actual screenpop objects - EASFP-21
	else if(myObjResult.objectType && sendAttachedData && myObjResult.objectType!="Task"){
		var newData = '{"sfdcObjectId":"' + objectId + '","id":"' + genesysId + '"}';
        Workspace.sendAttachData(newData);
    	window.sessionStorage.setItem("Genesys_search_completed", "");
	}
}
var defaultMethods = {
	"uploadAttachment" : uploadAttachment
}
window["DefaultsFunc"] = defaultMethods;
})(window, jQuery, undefined);
