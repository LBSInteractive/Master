@isTest
public class ALK_InvoiceCalloutTest {
	static String jsonTestInvoice = '{"invoice":"", "bu":"", "id":"8909009431 ", "documentType":"sale","startDate":"2022-01-01","endDate":"2022-04-18","ean":""}'; 
	static String jsonTestDetail = '{"invoice":"SETT0003121479", "bu":"KTINT", "id":"", "documentType":"","startDate":"","endDate":"","ean":""}'; 
    
    
    @isTest static void testInvoiceSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_InvoiceCallout callout = new ALK_InvoiceCallout();
        ALK_InvoiceCalloutResponseWrapper result = callout.getInvoices((ALK_InvoiceCalloutRequestWrapper)Json.deserializeStrict(jsonTestInvoice, ALK_InvoiceCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    } 

    @isTest static void testDetailSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceDetailCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_InvoiceCallout callout = new ALK_InvoiceCallout();
        ALK_InvoiceCalloutResponseWrapper result = callout.getInvoices((ALK_InvoiceCalloutRequestWrapper)Json.deserializeStrict(jsonTestDetail, ALK_InvoiceCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    } 
        
    @isTest static void testInvoiceFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_InvoiceCallout callout = new ALK_InvoiceCallout();
        ALK_InvoiceCalloutResponseWrapper result = callout.getInvoices((ALK_InvoiceCalloutRequestWrapper)Json.deserializeStrict(jsonTestInvoice, ALK_InvoiceCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    }     
    
    @isTest static void testDetailFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_InvoiceCallout callout = new ALK_InvoiceCallout();
        ALK_InvoiceCalloutResponseWrapper result = callout.getInvoices((ALK_InvoiceCalloutRequestWrapper)Json.deserializeStrict(jsonTestDetail, ALK_InvoiceCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    }         
}