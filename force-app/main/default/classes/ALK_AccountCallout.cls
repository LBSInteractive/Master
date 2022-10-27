public with sharing class ALK_AccountCallout extends ALK_StandardCallout {
   public ALK_AccountCalloutResponseWrapper importAccount(String id) {
    	ALK_AccountCalloutResponseWrapper result = new ALK_AccountCalloutResponseWrapper();{}
        try{
            result = (ALK_AccountCalloutResponseWrapper)super.execute(id);
       }catch(Exception ex) {
           // This part need to be reviewed when the error messagem. 
            result.isSucceeded = false;
            result.statusCode = 0;
            result.status = ex.getMessage();
        }
        
        return result; 
    }
    
    protected override ALK_API_Callouts__mdt getCalloutConfig() {
        return ALK_API_Callouts__mdt.getInstance('ALK_Account_Import_Callout'); 
    }

    protected override String getPathParams(object requestWrapper) {
        return '/'+requestWrapper+'?searchInSalesforce=false';
    }
    
    protected override Map<String, Object> getPayLoad(object requestWrapper) {
        Map<String, Object> bodyPayload = new map<String, Object>();  
        return bodyPayload;        
    }
    
    protected override Object getResponse(HttpResponse response) {
		ALK_AccountCalloutResponseWrapper result = new ALK_AccountCalloutResponseWrapper();   
        
       // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            result.isSucceeded = true;

            Map<String, Object> payLoad = (Map<String, Object>)JSON.deserializeUntyped(response.getBody()); 
            System.debug('payLoad->'+payLoad);
            result.id= (String)payLoad.get('Id');             
            result.autorizationHabeasData = String.valueOf(payLoad.get('ALK_Autorization_habeas_data__c')); 
        } else {
            result.isSucceeded = false;            
        }           

        result.statusCode = response.getStatusCode();   
        result.status = response.getStatus(); 

        
        return result;        
    }
}