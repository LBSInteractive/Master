public with sharing class ALK_RMACallout extends ALK_StandardCallout {
   public ALK_RMACalloutResponseWrapper createRMA(ALK_RMACalloutRequestWrapper fieldsParam) {
    	ALK_RMACalloutResponseWrapper result = new ALK_RMACalloutResponseWrapper();{}
        try{
            result = (ALK_RMACalloutResponseWrapper)super.execute(fieldsParam);
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
        return ALK_API_Callouts__mdt.getInstance('ALK_RMA_Create_Callout'); 
    }

    protected override String getPathParams(object requestWrapper) {
        return '';
    }
    
    protected override Map<String, Object> getPayLoad(object requestWrapper) {
	    ALK_RMACalloutRequestWrapper request = (ALK_RMACalloutRequestWrapper)requestWrapper;
        Map<String, Object> bodyPayload = new map<String, Object>();  
        bodyPayload.put('businessUnit',request.businessUnit);
        bodyPayload.put('invoice',request.invoice);
        bodyPayload.put('orderNo',request.orderNo);
        bodyPayload.put('custId',request.custId);
        bodyPayload.put('estReturnDt',request.estReturnDt);
        bodyPayload.put('reasonCd',request.reasonCd);
        bodyPayload.put('returnToIbu',request.returnToIbu);
        bodyPayload.put('oprid',request.oprid);
        bodyPayload.put('oprid2',request.oprid2);
        bodyPayload.put('carrierId',request.carrierId);
        bodyPayload.put('addressSeqNum',request.addressSeqNum);
        bodyPayload.put('invItemId',request.invItemId);
        bodyPayload.put('qty',request.qty);
        bodyPayload.put('ckComments',request.ckComments);
        bodyPayload.put('rmaStatus',request.rmaStatus);
        bodyPayload.put('emailTo',request.emailTo);

        return bodyPayload;        
    }
    
    protected override Object getResponse(HttpResponse response) {
		ALK_RMACalloutResponseWrapper result = new ALK_RMACalloutResponseWrapper();   
        
       // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 201) {
            result.isSucceeded = true;
        } else {
            // This part need to be reviewed when the error messagem be available from SIAF. 
            result.isSucceeded = false;
        }
        
        Map<String, Object> resultPayload = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());                   
        result.statusCode = response.getStatusCode();   
        result.status = response.getStatus();
        
        result.response = new ALK_RMACalloutResponseWrapper.ALK_RMAResponseWrapper();
        
        result.response.rmaNumber = (String)resultPayload.get('RMA_ID'); 
        result.response.errorCode = (String)resultPayload.get('ERROR_CODE'); 
        result.response.errorDescription = (String)resultPayload.get('DESCRLONG'); 
                        
        return result;        
    }
}