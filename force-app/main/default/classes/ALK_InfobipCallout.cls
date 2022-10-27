public with sharing class ALK_InfobipCallout extends ALK_StandardCallout { 
   public ALK_InfobipCalloutResponseWrapper sendMessage(ALK_InfobipCalloutRequestWrapper fieldsParam) {
    	ALK_InfobipCalloutResponseWrapper result = new ALK_InfobipCalloutResponseWrapper();{}
        try{
            result = (ALK_InfobipCalloutResponseWrapper)super.execute(fieldsParam);
        }
        catch(Exception ex) {
           // This part need to be reviewed when the error messagem. 
            result.isSucceeded = false;
            result.statusCode = 0;
            result.status = ex.getMessage();
        }
        
        return result; 
    }
    
    protected override ALK_API_Callouts__mdt getCalloutConfig() {
        return ALK_API_Callouts__mdt.getInstance('ALK_Infobip_Callout'); 
    }

    protected override String getPathParams(object requestWrapper) {
        return '';
    }
    
    protected override Map<String, Object> getPayLoad(object requestWrapper) {
	    ALK_InfobipCalloutRequestWrapper request = (ALK_InfobipCalloutRequestWrapper)requestWrapper;
        Map<String, Object> bodyPayload = new map<String, Object>();            
        bodyPayload.put('type',request.type);
        bodyPayload.put('destinationTo',request.destinationTo);
        bodyPayload.put('message',request.message);
        bodyPayload.put('templateName',request.templateName);
        bodyPayload.put('templateData',request.templateData);
        return bodyPayload;        
    }
    
    protected override Object getResponse(HttpResponse response) {
		ALK_InfobipCalloutResponseWrapper result = new ALK_InfobipCalloutResponseWrapper();       
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 201) {
            result.isSucceeded = true;
	        Map<String, Object> resultPayload = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        	result.status = (String)resultPayload.get('status');                
        } else {
            // This part need to be reviewed when the error messagem be available from SIAF. 
            result.isSucceeded = false;
            result.status = response.getStatus();
        } 
                
        result.statusCode = response.getStatusCode();   
        
        
        
        return result;        
    }
}