@istest public class ALK_AddressCreateCalloutTest {

    static String requestJson = '{"customerId":"8909009431","address":"CL 7 SUR, Los Balsos No. 2","city":"BOGOTA", "department":"ANTIOQUIA"}'; 
    
    @isTest static void testSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAddressCreateCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        Test.startTest();
        ALK_AddressCreateCallout callout = new ALK_AddressCreateCallout();
        ALK_AddressCreateCalloutResponseWrapper result = callout.addAddress((ALK_AddressCreateCalloutRequestWrapper)Json.deserialize(requestJson, ALK_AddressCreateCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    } 

    @isTest static void testFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAddressCreateCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
       
        insert calloutConfigsParams;
        
        Test.startTest();
        ALK_AddressCreateCallout callout = new ALK_AddressCreateCallout();
        ALK_AddressCreateCalloutResponseWrapper result = callout.addAddress((ALK_AddressCreateCalloutRequestWrapper)Json.deserialize(requestJson, ALK_AddressCreateCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    }     
}