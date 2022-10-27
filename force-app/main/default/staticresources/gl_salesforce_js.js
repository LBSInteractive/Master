/*
Screen pop functions that open SF tabs, subtabs or browser tabs for certain types of SF objects.
Search functions that search for specified object types by specified criteria. 
	Search functions will return results to a callback function that decides how to act 
	(screen pop, display list, other action).
Receive click-to-dial, click-to-email events and route them via Events object.
Functions to enable/disable SF features (e.g. stop routing click-to events).
Functions to create new SF objects (allow hooks on before/after creation).

*/

(function(window, undefined) {

var _log = Log ? Log.log : console.log;

var _inServiceCloudConsole;
var ixnWindows = []; // interaction ID -> SF Tab object ID

////////////////////////////////////////////////////////////////////////////////////////
// *** Search Handling **** //
////////////////////////////////////////////////////////////////////////////////////////


function openSearch(searchField, ixnId) {
    _log("openSearch for " + searchField);
    var Jsearch = "";
    if(searchField != null && searchField != ""){	
	Jsearch = JSON.stringify(searchField);
	Jsearch = Jsearch.replace(/&amp;/g, 'MyAmpersand');
	Jsearch = Jsearch.replace(/&#39;/g, 'SingleQuote');
	Jsearch = Jsearch.replace(/&plus;/g, 'MyPlus');
	Jsearch = Jsearch.replace(/'/g, 'SingleQuote');
	Jsearch = Jsearch.replace(/\+/g, "MyPlus");
    }  
    
    var url = "/apex/gl_CustomLookup?lksrch=" + Jsearch + "&ixnId=" + ixnId;
    _log("openSearch url = " + url);
    if(navigator.userAgent.indexOf('Edge')>0)
	{
    	url = encodeURI(url);// To handle special character issue with Edge Browser
	}
    screenPopUrl(url, "Search");
}

function openSearchByFields(searchFieldName, searchFieldValue, ixnId){
    var JsearchFieldName = "";
    _log("openSearchByFields for " + searchFieldName + " and " + searchFieldValue);
    var JsearchFieldName = "";
    if(searchFieldName != null && searchFieldName != ""){	
	JsearchFieldName = JSON.stringify(searchFieldName);
	JsearchFieldName = JsearchFieldName.replace(/&amp;/g, 'MyAmpersand');
	JsearchFieldName = JsearchFieldName.replace(/&#39;/g, 'SingleQuote');
	JsearchFieldName = JsearchFieldName.replace(/&plus;/g, 'MyPlus');
	JsearchFieldName = JsearchFieldName.replace(/'/g, 'SingleQuote');
	JsearchFieldName = JsearchFieldName.replace(/\+/g, "MyPlus");
    }
    
    var JsearchFieldValue = "";
    if(searchFieldValue != null && searchFieldValue != ""){	
	JsearchFieldValue = JSON.stringify(searchFieldValue);
	JsearchFieldValue = JsearchFieldValue.replace(/&amp;/g, 'MyAmpersand');
	JsearchFieldValue = JsearchFieldValue.replace(/&#39;/g, 'SingleQuote');
	JsearchFieldValue = JsearchFieldValue.replace(/&plus;/g, 'MyPlus');
	JsearchFieldValue = JsearchFieldValue.replace(/'/g, 'SingleQuote');
	JsearchFieldValue = JsearchFieldValue.replace(/\+/g, "MyPlus");
    } 
    
    var Jsearch = "";
    _log("openSearch for searchFieldName: " + JsearchFieldName + "  and searchFieldValue:" + JsearchFieldValue);
    var url = "/apex/gl_CustomLookup?lksrch=&searchFieldName=" + JsearchFieldName + "&searchFieldValue=" + JsearchFieldValue + "&ixnId=" + ixnId; 	
    if(navigator.userAgent.indexOf('Edge')>0)
	{
	url = encodeURI(url);// To handle special character issue with Edge Browser
	}
    _log("openSearchByFields url = " + url);

    screenPopUrl(url, "Search");

}

function openGenericSearchByFields(searchFieldName, searchFieldValue, ixnId){
    var JsearchFieldName = "";
    _log("openGenericSearchByFields for " + searchFieldName + " and " + searchFieldValue);
    var JsearchFieldName = "";
    if(searchFieldName != null && searchFieldName != ""){	
	JsearchFieldName = searchFieldName;
	JsearchFieldName = JsearchFieldName.replace(/&amp;/g, 'MyAmpersand');
	JsearchFieldName = JsearchFieldName.replace(/&#39;/g, 'SingleQuote');
	JsearchFieldName = JsearchFieldName.replace(/&plus;/g, 'MyPlus');
	JsearchFieldName = JsearchFieldName.replace(/'/g, 'SingleQuote');
	JsearchFieldName = JsearchFieldName.replace(/\+/g, "MyPlus");
    }
    
    var JsearchFieldValue = "";
    if(searchFieldValue != null && searchFieldValue != ""){	
	JsearchFieldValue = searchFieldValue;
	JsearchFieldValue = JsearchFieldValue.replace(/&amp;/g, 'MyAmpersand');
	JsearchFieldValue = JsearchFieldValue.replace(/&#39;/g, 'SingleQuote');
	JsearchFieldValue = JsearchFieldValue.replace(/&plus;/g, 'MyPlus');
	JsearchFieldValue = JsearchFieldValue.replace(/'/g, 'SingleQuote');
	JsearchFieldValue = JsearchFieldValue.replace(/\+/g, "MyPlus");
    } 
    
    var Jsearch = "";
    _log("openGenericSearchByFields for searchFieldName: " + JsearchFieldName + "  and searchFieldValue:" + JsearchFieldValue);
    var url = "/apex/gl_CustomGenericLookup?lksrch=&searchFieldName=" + JsearchFieldName + "&searchFieldValue=" + JsearchFieldValue + "&ixnId=" + ixnId; 	
    if(navigator.userAgent.indexOf('Edge')>0)
	{
	url = encodeURI(url);// To handle special character issue with Edge Browser
	}
    _log("openGenericSearchByFields url = " + url);

    screenPopUrl(url, "Search");

}

function openGenericSearchByFieldsMap(searchFields, searchValues, ixnId, searchAllFields){
	_log("openGenericSearchByFieldsMap");
	var JsearchFields = "";
	var JsearchValues = "";
	if(searchFields != null ){	
		JsearchFields = JSON.stringify(searchFields);
		JsearchFields = JsearchFields.replace(/&amp;/g, 'MyAmpersand');
		JsearchFields = JsearchFields.replace(/&#39;/g, 'SingleQuote');
		JsearchFields = JsearchFields.replace(/&plus;/g, 'MyPlus');
		JsearchFields = JsearchFields.replace(/'/g, 'SingleQuote');
		JsearchFields = JsearchFields.replace(/\+/g, "MyPlus");
    }
    
    if(searchValues != null ){	
    	JsearchValues = JSON.stringify(searchValues);
    	JsearchValues = JsearchValues.replace(/&amp;/g, 'MyAmpersand');
    	JsearchValues = JsearchValues.replace(/&#39;/g, 'SingleQuote');
    	JsearchValues = JsearchValues.replace(/&plus;/g, 'MyPlus');
    	JsearchValues = JsearchValues.replace(/'/g, 'SingleQuote');
    	JsearchValues = JsearchValues.replace(/\+/g, "MyPlus");
    }

    _log("openSearch for openGenericSearchByFieldsMap JsearchFields: " + JsearchFields);
    _log("openSearch for openGenericSearchByFieldsMap JsearchValues: " + JsearchValues);
    var url = "/apex/gl_CustomGenericLookup?lksrch=&searchFields=" + JsearchFields + "&searchValues=" + JsearchValues + "&ixnId=" + ixnId
    			+ "&searchAllFields=" + searchAllFields;
    if(navigator.userAgent.indexOf('Edge')>0)
	{
	url = encodeURI(url);// To handle special character issue with Edge Browser
	}
    _log("openGenericSearchByFieldsMap url = " + url);

    screenPopUrl(url, "Search");
    
}

function openSearchByFieldsMap(searchFields, searchValues, ixnId, searchAllFields){
	_log("openSearchByFieldsMap");
	var JsearchFields = "";
	var JsearchValues = "";
	if(searchFields != null ){	
		JsearchFields = JSON.stringify(searchFields);
		JsearchFields = JsearchFields.replace(/&amp;/g, 'MyAmpersand');
		JsearchFields = JsearchFields.replace(/&#39;/g, 'SingleQuote');
		JsearchFields = JsearchFields.replace(/&plus;/g, 'MyPlus');
		JsearchFields = JsearchFields.replace(/'/g, 'SingleQuote');
		JsearchFields = JsearchFields.replace(/\+/g, "MyPlus");
    }
    
    if(searchValues != null ){	
    	JsearchValues = JSON.stringify(searchValues);
    	JsearchValues = JsearchValues.replace(/&amp;/g, 'MyAmpersand');
    	JsearchValues = JsearchValues.replace(/&#39;/g, 'SingleQuote');
    	JsearchValues = JsearchValues.replace(/&plus;/g, 'MyPlus');
    	JsearchValues = JsearchValues.replace(/'/g, 'SingleQuote');
    	JsearchValues = JsearchValues.replace(/\+/g, "MyPlus");
    }

    _log("openSearch for openSearchByFieldsMap JsearchFields: " + JsearchFields);
    _log("openSearch for openSearchByFieldsMap JsearchValues: " + JsearchValues);
    var url = "/apex/gl_CustomLookup?lksrch=&searchFields=" + JsearchFields + "&searchValues=" + JsearchValues + "&ixnId=" + ixnId
    			+ "&searchAllFields=" + searchAllFields;
    if(navigator.userAgent.indexOf('Edge')>0)
	{
	url = encodeURI(url);// To handle special character issue with Edge Browser
	}
    _log("openSearchByFieldsMap url = " + url);

    screenPopUrl(url, "Search");
    
}

//Added for 414 Uri too long issue - EASFP-59
function cutDownLksearch(Jsearch){
	var JsearchObj = JSON.parse(Jsearch);
		var charLimit = 13000;
		var encodedJsearch = encodeURIComponent(Jsearch);
		_log("Actual lksearch: " + Jsearch);
		if(JsearchObj.length != 0 && encodedJsearch.length > charLimit){
			_log("Encoded lksearch count " + encodedJsearch.length + " exceeds url limit " + charLimit);
			_log(encodedJsearch);
			var finalJsearch = [];
			var count = 0;
			var encodedFinalSearch = encodeURIComponent(JSON.stringify(finalJsearch));
			while(encodedFinalSearch.length < charLimit && count < JsearchObj.length){
				var expLength = encodedFinalSearch.length + encodeURIComponent(JSON.stringify(JsearchObj[count])).length
				if(expLength >= charLimit)
					break;
				finalJsearch[count] = JsearchObj[count];
				encodedFinalSearch = encodeURIComponent(JSON.stringify(finalJsearch));
				//_log("Encoded string of " + (count+1) + " objects : " + encodedFinalSearch);
				count++;
			}
			if(finalJsearch.length > 0){
				_log("Encoded lksearch count " + encodedFinalSearch.length + " after cut down: " + encodedFinalSearch);
				_log("Setting the cut down lksearch with the url");
				Jsearch = JSON.stringify(finalJsearch);
			}
		}
		return Jsearch;
}

function openSearchByType(searchField, ixnId, searchObjectType,lookupNumber, sortBy, limit) {
    _log("openSearchByType");
    var Jsearch = "";
    if(searchField != null && searchField != ""){	
    //var objMap = { searchField}; 
    //var json = JSON.stringify(objMap);
    
	Jsearch = JSON.stringify(searchField);//.replace("\","");
	Jsearch = Jsearch.replace(/&amp;/g, 'MyAmpersand');
	Jsearch = Jsearch.replace(/&#39;/g, 'SingleQuote');
	Jsearch = Jsearch.replace(/&plus;/g, 'MyPlus');
	Jsearch = Jsearch.replace(/'/g, 'SingleQuote');
	Jsearch = Jsearch.replace(/\+/g, "MyPlus");
		
	//Added for 414 Uri too long issue - EASFP-59
	Jsearch = cutDownLksearch(Jsearch);

    }
    
    if (searchObjectType == 'contact')
    {
		//Passing sortby and limit to lookup page : EASFP-51, EASFP-54
		var url = "/apex/gl_CustomContactLookup?lksrch=" + Jsearch + "&ixnId=" + ixnId	
    	  	+ "&searchObjectType=" + searchObjectType+ "&lookupNumber=" + lookupNumber+ "&sortBy=" + sortBy+ "&limit=" + limit;
    	if(navigator.userAgent.indexOf('Edge')>0)
    	{
    	url = encodeURI(url);// To handle special character issue with Edge Browser
    	}
	    _log("openSearchByType Contact url = " + url); 
	    
	    screenPopUrl(url, "Contact Search"); 
    }
    else if (searchObjectType == 'account' || searchObjectType == 'personaccount')
    {
		var url = "/apex/gl_CustomAccountLookup?lksrch=" + Jsearch + "&ixnId=" + ixnId    	
	    	+ "&searchObjectType=" + searchObjectType+ "&lookupNumber=" + lookupNumber;
	
	    if(navigator.userAgent.indexOf('Edge')>0)
		{
		url = encodeURI(url);// To handle special character issue with Edge Browser
		}
	    _log("openSearchByType Account url = " + url); 
	    screenPopUrl(url, "Account Search");
    }
}

function openSearchCase(searchField, ixnId) {
    _log("openSearchCase for " + searchField);
    var Jsearch = "";
    if(searchField != null && searchField != ""){	
	Jsearch = JSON.stringify(searchField);
	Jsearch = Jsearch.replace(/&amp;/g, 'MyAmpersand');
	Jsearch = Jsearch.replace(/&#39;/g, 'SingleQuote');
	Jsearch = Jsearch.replace(/&plus;/g, 'MyPlus');
	Jsearch = Jsearch.replace(/'/g, 'SingleQuote');
	Jsearch = Jsearch.replace(/\+/g, "MyPlus");
	Jsearch = Jsearch.replace(/\+/g, "MyPlus");
	//Jsearch = Jsearch.replace(/ /g,"%20");

	//Added for 414 Uri too long issue - EASFP-59
	Jsearch = cutDownLksearch(Jsearch);

    } 
    
    var url = "/apex/gl_CustomCaseLookup?lksrch=" + Jsearch + "&ixnId=" + ixnId; 
    if(navigator.userAgent.indexOf('Edge')>0)
	{
	url = encodeURI(url);// To handle special character issue with Edge Browser
	}
    _log("openSearchCase url = " + url);

    screenPopUrl(url, "Search");
}

var param = {};

function screenPopUrl(url, caseNumber) {
	
	//url may consist of URL only.
	
	 _log("url in screenpop  = " + url);
	
	
	try {
 	sforce.opencti.screenPop({
 		type: sforce.opencti.SCREENPOP_TYPE.URL,
 		params: { url:url }
 	});  
	} catch(err) {
		  document.getElementById("demo").innerHTML = err.message;
		}
}


function screenPop(url, caseNumber) {
	// url should not include leading slash "/".
	// url may consist of SF Object ID only.
    	sforce.opencti.screenPop({
    		type: sforce.opencti.SCREENPOP_TYPE.SOBJECT,
    		params: { recordId: url } 
    	});  
}



function refreshPrimaryTab(result) {
    if (result.id != null) {
        _log("refreshPrimaryTab result.id = " + result.id);
        sforce.console.refreshPrimaryTabById(result.id, false);
    }
}

function screenPopRefresh(url, caseNumber) {
	//url = "/" + url;
    	sforce.opencti.screenPop({
    		type: sforce.opencti.SCREENPOP_TYPE.SOBJECT,
    		params: { recordId: url } 
    	});
}


// returns true if screen pop performed
function screenPopUser(obj) {
    // check for attached data sfdcObjectId - if it is already there, then pop that
    var id = obj.userData.sfdcObjectId;
    if (id !== undefined) {
        _log("sfdcObjectId = " + id);
        screenPop(id);
        return true;
    }
    return false;
}



function SF_default_search(searchField){
	_log("SF_default_search");
	var url = '/_ui/search/ui/UnifiedSearchResults?isdtp=nv&searchType=2&sen=003&sen=00Q&searchType=2&str=' + searchField;
	if(navigator.userAgent.indexOf('Edge')>0)
		{
		url = encodeURI(url);// To handle special character issue with Edge Browser
		}
	//sforce.interaction.screenPop(url, function(response) {});
 	sforce.opencti.screenPop({
 		type: sforce.opencti.SCREENPOP_TYPE.URL,
 		params: { url: url } 
 	});
}

function inServiceCloudConsole() {
	return _inServiceCloudConsole;
}

function setInServiceCloudConsole(inConsole) {
	_inServiceCloudConsole = inConsole;
}

////////////////////////////////////////////////////////////////////////////////////////
// Interaction Windows (tabs) tracking
////////////////////////////////////////////////////////////////////////////////////////

function addIxnWindow(ixnId, tabId) {
	/* TODO
	_log("addIxnWindow - " + ixnId + ", " + tabId);
	ixnWindows[ixnId] = tabId;
	*/
}

function removeIxnWindow(ixnId) {
	/* TODO
	_log("removeIxnWindow - " + ixnId);
	delete ixnWindows[ixnId];
	*/
}

function getIxnTabId(ixnId) {
	_log("getIxnTabId from ixnWindow - " + ixnId);
	return ixnWindows[ixnId];
}

function getIxnId(tabId) {
	_log("getIxnId from ixnWindow - " + tabId);
	var index = jQuery.inArray(tabId, ixnWindows);
	for (var id in ixnWindows) {
		  if (ixnWindows.hasOwnProperty(id)) { 
		    _log("id: " + id + " value: " + ixnWindows[id])
		    if(ixnWindows[id].indexOf(tabId) > -1){
		    	return id;
		    }
		  }
	}

	$.each(ixnWindows, function( k, v ) {
		_log( "Key: " + k + ", Value: " + v );
		});
	return null;
	//return (index < 0) ? null : ixnWindows[index];
}

// bring a primary tab to front
function focusIxnTab(ixnId) {
    _log("focusIxnTab for " + ixnId);
    var tabId = Salesforce.getIxnTabId(ixnId);
    if (tabId) {
    	//Salesforce.consolePop(tabId);
    }
}

//Distribute live agent chat to current user
function liveChatDistribution(obj) {
	 // check for attached data if it is live chat
	
	_log("obj.userData");
	_log("obj.userData = " + obj.userData["Subject"]);
	
	var subject = obj.userData["Subject"];
	if (subject !== undefined) {
		 _log("WorkItem subject = " + subject);
		 
		 // current session ID
		 sforce.connection.sessionId = __sfdcSessionId;
		 _log("sforce.connection.sessionId = " + sforce.connection.sessionId);
		 
		 // create AgentWork by using Apex Class call in a webservice
		 sforce.apex.execute("gl_AgentWorkUtils", "createAgentWork", {serviceChannelID:obj.userData["sfdc_ServiceChannelId"], workItemId:obj.userData["sfdc_WorkItemId"]});
		
		 return true;
	 }
	 
	return false;
}

//Functionality to show a new case creation page with the default values populated: EASFP-48
function screenPopNewCase(obj,objectToUse) {
	var defaultFieldValues={};
	var recordTypeName="";
	if('caseDefaultValues' in obj){
		defaultFieldValues = obj.caseDefaultValues;
		_log("Default values configured: " + JSON.stringify(defaultFieldValues));
		recordTypeName = (defaultFieldValues.RecordTypeId === undefined) ? "" : defaultFieldValues.RecordTypeId;
	}
	
	if(recordTypeName != "" || objectToUse != ""){
		_log("Object to use:" + objectToUse + " RecordType:" + recordTypeName);
		gl_WorkspaceConnectorController.buildCasePopulationMap(objectToUse, defaultFieldValues, function(defaultValuesMap) {
			showNewCase(defaultValuesMap);
		});
	}else{
		showNewCase(defaultFieldValues);
	}
}

function showNewCase(defaultFieldValues){
	_log("Setting Default values to New Case Screen: "+JSON.stringify(defaultFieldValues));
	sforce.opencti.screenPop({
		type: sforce.opencti.SCREENPOP_TYPE.NEW_RECORD_MODAL,
		params: {
			entityName: 'Case',
			defaultFieldValues:	defaultFieldValues
		 } 
	});
}

var Salesforce = {
	"openSearch": openSearch,
	"openSearchByFields": openSearchByFields,
	"openGenericSearchByFields":openGenericSearchByFields,
	"openSearchByFieldsMap": openSearchByFieldsMap,
	"openGenericSearchByFieldsMap": openGenericSearchByFieldsMap,
	"openSearchByType": openSearchByType,
	"openSearchCase": openSearchCase,
	"screenPop": screenPop,
	"screenPopRefresh": screenPopRefresh,
	"screenPopUser": screenPopUser,
	"inServiceCloudConsole": inServiceCloudConsole,
	"setInServiceCloudConsole": setInServiceCloudConsole,
	"addIxnWindow": addIxnWindow,
	"removeIxnWindow": removeIxnWindow,
	"getIxnTabId": getIxnTabId,
	"getIxnId": getIxnId,
	"focusIxnTab": focusIxnTab,
	"liveChatDistribution": liveChatDistribution,
	"screenPopNewCase":screenPopNewCase
};

window["Salesforce"] = Salesforce;

})(window, undefined);
