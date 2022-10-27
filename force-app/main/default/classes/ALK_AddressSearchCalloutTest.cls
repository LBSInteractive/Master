@isTest public class ALK_AddressSearchCalloutTest {
    static String id = '8909009431'; 
    
    @isTest static void testSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAddressSearchCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        Test.startTest();
        ALK_AddressSearchCallout callout = new ALK_AddressSearchCallout();
        ALK_AddressSearchCalloutResponseWrapper result = callout.getAddress(id);
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    } 

    @isTest static void testFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAddressSearchCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        Test.startTest();
        ALK_AddressSearchCallout callout = new ALK_AddressSearchCallout();
        ALK_AddressSearchCalloutResponseWrapper result = callout.getAddress(id);
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    } 
}