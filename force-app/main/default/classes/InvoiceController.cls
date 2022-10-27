public with sharing class InvoiceController {
    @AuraEnabled(cacheable=true)
    public static List<ALK_Invoice__c> getInvoice() {
        return [
            SELECT
                Id,
                ALK_Case__c,
                ALK_Description__c
            FROM ALK_Invoice__c
            LIMIT 10
        ];
    }
}