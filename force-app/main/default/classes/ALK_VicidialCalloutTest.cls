@isTest public class ALK_VicidialCalloutTest {
	static String jsonTest = '{"agentUserNo":48600, "phoneNumber":"3106883866", "caseNumber":"123456789"}'; 
    
    
    @isTest static void testSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpVicidialCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the infobip Callout. 
        Test.startTest();
        ALK_VicidialCallout callout = new ALK_VicidialCallout();
        ALK_VicidialCalloutResponseWrapper result = callout.doACall((ALK_VicidialCalloutRequestWrapper)Json.deserializeStrict(jsonTest, ALK_VicidialCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    } 
    
    @isTest static void testFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpVicidialCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the infobip Callout. 
        Test.startTest();
        ALK_VicidialCallout callout = new ALK_VicidialCallout();
        ALK_VicidialCalloutResponseWrapper result = callout.doACall((ALK_VicidialCalloutRequestWrapper)Json.deserializeStrict(jsonTest, ALK_VicidialCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    }    
}