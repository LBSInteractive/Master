@isTest public class ALK_DevolutionCalloutTest {
    static String id = '15430000004827'; 
    
    @isTest static void testSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_DevolutionCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        Test.startTest();
        ALK_DevolutionCallout callout = new ALK_DevolutionCallout();
        ALK_DevolutionCalloutResponseWrapper result = callout.getDevolutions(id);
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    } 

    @isTest static void testDevolutionFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_DevolutionCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        Test.startTest();
        ALK_DevolutionCallout callout = new ALK_DevolutionCallout();
        ALK_DevolutionCalloutResponseWrapper result = callout.getDevolutions(id);
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    }
}