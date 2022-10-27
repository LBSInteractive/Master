public with sharing class ALK_AddressCreateCallout extends ALK_StandardCallout {
   public ALK_AddressCreateCalloutResponseWrapper addAddress(ALK_AddressCreateCalloutRequestWrapper request) {  
    	ALK_AddressCreateCalloutResponseWrapper result = new ALK_AddressCreateCalloutResponseWrapper();{}
        try{
            result = (ALK_AddressCreateCalloutResponseWrapper)super.execute(request);
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
        return ALK_API_Callouts__mdt.getInstance('ALK_Account_Create_Address_Callout'); 
    }
    
    protected override String getEndpoint(ALK_API_Callouts__mdt config, object requestWrapper) {      
        return 'callout:'+String.format (config.ALK_Path__c, new String[]{((ALK_AddressCreateCalloutRequestWrapper)requestWrapper).customerId});
    }    

    protected override String getPathParams(object requestWrapper) {
        return '';
    }
    
    protected override Map<String, Object> getPayLoad(object requestWrapper) {
        Map<String, Object> bodyPayload = new map<String, Object>();  
        bodyPayload.put('address',((ALK_AddressCreateCalloutRequestWrapper)requestWrapper).address);
        bodyPayload.put('city',((ALK_AddressCreateCalloutRequestWrapper)requestWrapper).city);
        bodyPayload.put('department',((ALK_AddressCreateCalloutRequestWrapper)requestWrapper).department);
        return bodyPayload;        
    }
    
    protected override Object getResponse(HttpResponse response) {
		ALK_AddressCreateCalloutResponseWrapper result = new ALK_AddressCreateCalloutResponseWrapper(); 
        result.addressCreationStatus = new ALK_AddressCreateCalloutResponseWrapper.AddressCreationStatusWrapper();
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
			Map<String,object> resultPayload = (Map<String,object>)JSON.deserializeUntyped(response.getBody());            
            
            result.isSucceeded = true;
            result.addressCreationStatus.isError = (String)resultPayload.get('ERROR_FLAG') == 'N'? false : true;
            result.addressCreationStatus.errorCode = (String)resultPayload.get('ERRNUM');
            result.addressCreationStatus.errorMessage = (String)resultPayload.get('ERROR_MESSAGE_TXT');                         
        } else {
            // This part need to be reviewed when the error messagem be available from SIAF. 
            result.isSucceeded = false;
        }
        
        result.statusCode = response.getStatusCode();
        result.status = response.getStatus();        
        
        return result;        
    }
}