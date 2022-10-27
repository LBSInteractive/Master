@isTest public class ALK_InvoiceServiceTest {
	@testSetup
    public static void setUp() {        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;        
    }
        
    @isTest public static void searchInvoiceSuccess() {
        List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> invoices = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceCalloutMockSuccess());
        
        Test.startTest();
   		invoices = ALK_InvoiceService.searchInvoice('8909009431', Date.valueOf('2022-01-01'), Date.valueOf('2022-04-18'));
        Test.stopTest();
        
        System.assertEquals(1, invoices.size());
    } 
    
    @isTest public static void searchInvoiceDetailSuccess() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceDetailCalloutMockSuccess());
        
        Test.startTest();        
   		ALK_InvoiceService.searchInvoiceDetail('SETT0003169815', 'KTINT');
        Test.stopTest();        

        ALK_InvoiceService.searchInvoiceDetail('SETT0003169815', '');        
        ALK_InvoiceService.searchInvoiceDetail('SETT0003169815', 'KTINT');
        
		System.assertEquals(true, ALK_InvoiceService.removeFromCache(ALK_InvoiceService.INVOICE_DETAIL_GROUP+'SETT0003169815'));        
    } 
    
    @isTest public static void searchDevolutionsSuccess() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_DevolutionCalloutMockSuccess());        
        
        Test.startTest();        
   		ALK_InvoiceService.searchDevolutions('15430000004827');        
        Test.stopTest();
        
        List<ALK_DevolutionCalloutResponseWrapper.ALK_DevolutionWrapper> devos = ALK_InvoiceService.searchDevolutions('15430000004827');
        
        System.assertEquals(true, ALK_InvoiceService.removeFromCache(ALK_InvoiceService.INVOICE_DEVOLUTION_GROUP+'15430000004827'));
    }        

    @isTest public static void searchProductDetailSuccess() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpProductDetailCalloutMockSuccess());        
        
        Test.startTest();        
   		ALK_InvoiceService.searchProductDetail('SETT0003121479', 'AKIPI', '7701023462488');        
        Test.stopTest();
        
        ALK_ProductDetailCalloutResponseWrapper.ALK_ProductDetailWrapper p = ALK_InvoiceService.searchProductDetail('SETT0003121479', 'AKIPI', '7701023462488');
		
        System.assertEquals('7701023462488', p.productId);
        
        System.assertEquals(true, ALK_InvoiceService.removeFromCache('SETT0003121479AKIPI7701023462488'));
    }          
    
    @isTest public static void searchInvoiceFail() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceCalloutMockFail());
        
        try {
            Test.startTest();
            ALK_InvoiceService.searchInvoice('8909009431', Date.valueOf('2022-01-01'), Date.valueOf('2022-04-18'));
            Test.stopTest();            
        } catch(Exception ex) {
            System.assertEquals('ALK_InvoiceService.ALK_InvoiceServiceException', EX.getTypeName());
        }
        
        try {      
            ALK_InvoiceService.searchInvoice('', Date.valueOf('2022-01-01'), Date.valueOf('2022-04-18'));           
        } catch(Exception ex) {
            System.assertEquals('ALK_InvoiceService.ALK_InvoiceServiceException', EX.getTypeName());
        }           

        try {      
            ALK_InvoiceService.searchInvoice('8909009431', null, Date.valueOf('2022-04-18'));           
        } catch(Exception ex) {
            System.assertEquals('ALK_InvoiceService.ALK_InvoiceServiceException', EX.getTypeName());
        }        
    }     
    
    @isTest public static void searchInvoiceDetailFail() {
        try {      
            ALK_InvoiceService.searchInvoiceDetail('', 'KTINT');            
        } catch(Exception ex) {
            System.assertEquals('ALK_InvoiceService.ALK_InvoiceServiceException', EX.getTypeName());
        }            
    }
    
    @isTest public static void searchDevolutions() {
        try {      
            ALK_InvoiceService.searchDevolutions('');            
        } catch(Exception ex) {
            System.assertEquals('ALK_InvoiceService.ALK_InvoiceServiceException', EX.getTypeName());
        }            
    } 
    @isTest public static void searchProductDetailFail() {
        try {        
            ALK_InvoiceService.searchProductDetail('', 'AKIPI', '7701023462488');            
        } catch(Exception ex) {
            System.assertEquals('ALK_InvoiceService.ALK_InvoiceServiceException', EX.getTypeName());
        }     

        try {      
            ALK_InvoiceService.searchProductDetail('SETT0003121479', '', '7701023462488');           
        } catch(Exception ex) {
            System.assertEquals('ALK_InvoiceService.ALK_InvoiceServiceException', EX.getTypeName());
        }       

        try {       
            ALK_InvoiceService.searchProductDetail('SETT0003121479', 'AKIPI', '');            
        } catch(Exception ex) {
            System.assertEquals('ALK_InvoiceService.ALK_InvoiceServiceException', EX.getTypeName());
        }         
    }       
}