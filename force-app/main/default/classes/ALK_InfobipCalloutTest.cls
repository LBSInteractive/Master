@isTest
public class ALK_InfobipCalloutTest {
    
	static String jsonTest = '{"type":"WhatsApp", "destinationTo":"573214179475", "message":"","templateName":"cod_cam_dirv2"}'; 
    
    
    @isTest static void testSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInfobipCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the infobip Callout. 
        Test.startTest();
        ALK_InfobipCallout callout = new ALK_InfobipCallout();
        ALK_InfobipCalloutResponseWrapper result = callout.sendMessage((ALK_InfobipCalloutRequestWrapper)Json.deserializeStrict(jsonTest, ALK_InfobipCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    } 
    
    @isTest static void testFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInfobipCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the infobip Callout. 
        Test.startTest();
        ALK_InfobipCallout callout = new ALK_InfobipCallout();
        ALK_InfobipCalloutResponseWrapper result = callout.sendMessage((ALK_InfobipCalloutRequestWrapper)Json.deserializeStrict(jsonTest, ALK_InfobipCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    }     
}