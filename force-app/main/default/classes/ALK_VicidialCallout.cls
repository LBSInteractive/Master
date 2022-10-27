public with sharing class ALK_VicidialCallout extends ALK_StandardCallout {
   public ALK_VicidialCalloutResponseWrapper doACall(ALK_VicidialCalloutRequestWrapper fieldsParam) {
    	ALK_VicidialCalloutResponseWrapper result = new ALK_VicidialCalloutResponseWrapper();{}
        try{
            result = (ALK_VicidialCalloutResponseWrapper)super.execute(fieldsParam);
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
        return ALK_API_Callouts__mdt.getInstance('ALK_Vicidial_Callout'); 
    }

    protected override String getPathParams(object requestWrapper) {
        return '';
    }
    
    protected override Map<String, Object> getPayLoad(object requestWrapper) {
	    ALK_VicidialCalloutRequestWrapper request = (ALK_VicidialCalloutRequestWrapper)requestWrapper;
        Map<String, Object> bodyPayload = new map<String, Object>();            
        bodyPayload.put('agentUser',request.agentUserNo);
        bodyPayload.put('phoneNumber',request.phoneNumber);
        bodyPayload.put('caseNumber',request.caseNumber);

        bodyPayload.put('vendorId','');
        bodyPayload.put('firstName','');
        bodyPayload.put('sourceId','');
        bodyPayload.put('lastName','');
        
        return bodyPayload;        
    }
    
    protected override Object getResponse(HttpResponse response) {
		ALK_VicidialCalloutResponseWrapper result = new ALK_VicidialCalloutResponseWrapper();       
        Map<String, Object> resultPayload = (Map<String, Object>) JSON.deserializeUntyped(response.getBody()); 
        System.debug('resultPayload ->'+ resultPayload);
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 201 || response.getStatusCode() == 200) {
            result.isSucceeded = true;
            result.leadId = (String)resultPayload.get('leadId');             
        } else {
            // This part need to be reviewed when the error messagem be available from SIAF. 
            result.isSucceeded = false;
            try {
                result.status = (string)((Map<String, Object>)resultPayload.get('error')).get('description');                                                
            } catch(Exception ex) {
                result.status = (string)resultPayload.get('error');                                                                
            }
        } 
               
        result.statusCode = response.getStatusCode(); 
           
        return result;        
    }
}