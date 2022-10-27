({
    markDone: function(component, event, helper) {
      		
        	var Id=component.get("v.CallObject");
        	var Disposition=component.get("v.Disposition");
        	var Description=component.get("v.Description");
        	var message = {"action": "MarkDone", "actionData": {"sfdcObjectType":"Task","id":""+Id+"","reason":""+Disposition+"","description":""+Description+""}}
            var resultsToast = $A.get("e.force:showToast");
          	try 
          	{
				//sendToWDE(message, 5050);
				helper.publishMCS(component,message); 
    		 } 
    		catch (e) 
    		 {
    			alert("Error: "+e);
    		}
    	        resultsToast.fire();
    	        var dismissActionPanel = $A.get("e.force:closeQuickAction");
    	        dismissActionPanel.fire();
    }
    ,
     
    doInit : function(component, event, helper) {
	helper.getRecord(component); 
    }

})