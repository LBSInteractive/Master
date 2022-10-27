public with sharing class ALK_AddressSearchCallout extends ALK_StandardCallout {
   public ALK_AddressSearchCalloutResponseWrapper getAddress(String identificationNumber) {  
    	ALK_AddressSearchCalloutResponseWrapper result = new ALK_AddressSearchCalloutResponseWrapper();{}
        try{
            result = (ALK_AddressSearchCalloutResponseWrapper)super.execute(identificationNumber);
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
        return ALK_API_Callouts__mdt.getInstance('ALK_Account_Search_Address_Callout'); 
    }
    
    protected override String getEndpoint(ALK_API_Callouts__mdt config, object requestWrapper) {      
        return 'callout:'+String.format (config.ALK_Path__c, new String[]{(String)requestWrapper});
    }    

    protected override String getPathParams(object requestWrapper) {
        return '';
    }
    
    protected override Map<String, Object> getPayLoad(object requestWrapper) {
        Map<String, Object> bodyPayload = new map<String, Object>();            
        return bodyPayload;        
    }
    
    protected override Object getResponse(HttpResponse response) {
		ALK_AddressSearchCalloutResponseWrapper result = new ALK_AddressSearchCalloutResponseWrapper(); 
        
        // If the request is successful, parse the JSON response.
        if(response.getStatusCode() == 200) {
            result.isSucceeded = true;
            result.address = new List<ALK_AddressSearchCalloutResponseWrapper.ALK_AddressWrapper>();
            
            List<Object> resultPayload = (List<Object>)JSON.deserializeUntyped(response.getBody());
            
            for(Object addressPayLoad : resultPayload) {
                Map<String,object> addressPayLoadItem = (Map<String,object>)addressPayLoad;
                
                ALK_AddressSearchCalloutResponseWrapper.ALK_AddressWrapper address = new ALK_AddressSearchCalloutResponseWrapper.ALK_AddressWrapper();

                address.SETID = (String)addressPayLoadItem.get('SETID');
                address.custId = (String)addressPayLoadItem.get('CUST_ID');
                address.country = (String)addressPayLoadItem.get('COUNTRY');
                address.state = (String)addressPayLoadItem.get('STATE');
                address.descr = (String)addressPayLoadItem.get('DESCR');
                address.city = (String)addressPayLoadItem.get('CITY');
                address.county = (String)addressPayLoadItem.get('COUNTY');
                address.address1 = (String)addressPayLoadItem.get('ADDRESS1');
                address.address2 = (String)addressPayLoadItem.get('ADDRESS2');
                address.countryCode = (String)addressPayLoadItem.get('COUNTRY_CODE');
                address.phone = (String)addressPayLoadItem.get('PHONE');
                address.fax = (String)addressPayLoadItem.get('FAX');
                address.addressSeqNum = (Integer)addressPayLoadItem.get('ADDRESS_SEQ_NUM');
                address.billToAddr = (String)addressPayLoadItem.get('BILL_TO_ADDR') == 'Y'? true : false;
                address.shipToAddr = (String)addressPayLoadItem.get('SHIP_TO_ADDR') == 'Y'? true : false;
                address.soldToAddr = (String)addressPayLoadItem.get('SOLD_TO_ADDR') == 'Y'? true : false;  
                
                result.address.add(address);
            }
                         
        } else {
            // This part need to be reviewed when the error messagem be available from SIAF. 
            result.isSucceeded = false;
        }
        
        result.statusCode = response.getStatusCode();
        result.status = response.getStatus();        
        
        return result;        
    }
}