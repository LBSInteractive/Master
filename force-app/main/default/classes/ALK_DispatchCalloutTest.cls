@isTest
public class ALK_DispatchCalloutTest {
	static String jsonTestSearch = 'W1290001008679'; 
    
    @isTest static void testSearchSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpDispatchCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_DispatchCallout callout = new ALK_DispatchCallout();
        ALK_DispatchCalloutResponseWrapper result = callout.searchDispatch(jsonTestSearch);
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    }
        
    @isTest static void testDetailFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpDispatchCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_DispatchCallout callout = new ALK_DispatchCallout();
        ALK_DispatchCalloutResponseWrapper result = callout.searchDispatch(jsonTestSearch);
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    }       
}