@isTest
public class ALK_ProductDetailCalloutTest {

    static String jsonTestProduct = '{"invoice":"SETT0003169799", "bu":"KTINT", "ean":12345}'; 
    
    @isTest static void testSuccess() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpProductDetailCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        // Call the invoice Callout. 
        Test.startTest();
        ALK_ProductDetailCallout callout = new ALK_ProductDetailCallout();
        ALK_ProductDetailCalloutResponseWrapper result = callout.getProductDetail((ALK_InvoiceCalloutRequestWrapper)Json.deserializeStrict(jsonTestProduct,ALK_InvoiceCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(true, result.isSucceeded);
    } 

    @isTest static void testInvoiceFail() {
        
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpProductDetailCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        Test.startTest();
        ALK_ProductDetailCallout callout = new ALK_ProductDetailCallout();
        ALK_ProductDetailCalloutResponseWrapper result = callout.getProductDetail((ALK_InvoiceCalloutRequestWrapper)Json.deserializeStrict(jsonTestProduct,ALK_InvoiceCalloutRequestWrapper.class));
        Test.stopTest();
        
        // Check the results. 
        System.assertEquals(false, result.isSucceeded);
    }  
}