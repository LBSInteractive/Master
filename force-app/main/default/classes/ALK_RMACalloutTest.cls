@isTest
public class ALK_RMACalloutTest {

	static String jsonTestCreate = '{"BUSINESSUNIT":"AKCA2","INVOICE":"20630010065629","ORDERNO":"END0091033","CUSTID":"67041284","ESTRETURNDT":"2021/04/08","REASONCD":"REC_AR_CA","RETURNTOIBU":"AKCAL","OPRID":"80082422","OPRID2":"80082422","CARRIERID":"COOR-00","ADDRESSSEQNUM":"KR 26 P3 # 96 - 81 PI 2","INVITEMID":"7704353422887","QTY":"1","CKCOMMENTS":"test lady","RMASTATUS":"O","EMAILTO":"faley0207@hotmail.com"}';
	static String jsonTestSearch = 'SETT0003121479'; 
    
    
    @isTest static void testCreateSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpRMACalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_RMACallout callout = new ALK_RMACallout();
        ALK_RMACalloutResponseWrapper result = callout.createRMA((ALK_RMACalloutRequestWrapper)Json.deserializeStrict(jsonTestCreate, ALK_RMACalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    } 
        
    @isTest static void testInvoiceFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpRMACalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_RMACallout callout = new ALK_RMACallout();
        ALK_RMACalloutResponseWrapper result = callout.createRMA((ALK_RMACalloutRequestWrapper)Json.deserializeStrict(jsonTestCreate, ALK_RMACalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    }         
}