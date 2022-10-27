@isTest public class ALK_AccountCalloutTest {  
    @isTest static void testSearchAccountSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAccountCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_AccountCallout callout = new ALK_AccountCallout();
        ALK_AccountCalloutResponseWrapper result = callout.importAccount('8909009431');
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    } 
        
    @isTest static void testSearchAccountFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAccountCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_AccountCallout callout = new ALK_AccountCallout();
        ALK_AccountCalloutResponseWrapper result = callout.importAccount('8909009431');
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    }     
}