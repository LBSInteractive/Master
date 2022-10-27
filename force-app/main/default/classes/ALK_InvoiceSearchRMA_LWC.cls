public with sharing class ALK_InvoiceSearchRMA_LWC {
    @AuraEnabled
    public static List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> searchInvoice(String customerId, Date startDate, Date endDate) {
        return ALK_InvoiceService.searchInvoice(customerId, startDate, endDate);
    }
    
    @AuraEnabled
    public static List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> searchInvoiceDetail(String invoiceNumber, String location) {
        List<Schema.Location> locationList = [SELECT ID, ALK_Unidad_de_Venta__c FROM Location WHERE ID = :location];
        if(!locationList.isEmpty()){
            return ALK_InvoiceService.searchInvoiceDetail(invoiceNumber, locationList[0].ALK_Unidad_de_Venta__c);
        }
        else{
            return null;
        }
    }    
     @AuraEnabled
    public static ALK_DispatchCalloutResponseWrapper.ALK_DispatchWrapper searchInvoiceRMA(String invoiceNumber) {
            return ALK_RMAService.searchDispatch(invoiceNumber);
            
      
    }    
     @AuraEnabled
    public static ALK_ProductDetailCalloutResponseWrapper.ALK_ProductDetailWrapper searchProductDetailBU(String invoiceNumber, String location, String ean) {
		system.debug('** ean'+ean+'** invoiceNumber '+invoiceNumber+'** location '+location);
            return ALK_InvoiceService.searchProductDetail(invoiceNumber, location, ean);
        
    }    
}