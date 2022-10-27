public with sharing class ALK_InvoiceLwc {
    @AuraEnabled
    public static List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> searchInvoice(String id, Date startDate, Date endDate) {
        return ALK_InvoiceService.searchInvoice(id, startDate, endDate);
    }
}