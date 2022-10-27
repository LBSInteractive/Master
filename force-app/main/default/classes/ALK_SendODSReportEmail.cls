public without sharing class ALK_SendODSReportEmail {

    @InvocableMethod
    public static List<String> sendODSReport(List<String> caseId) {
        String result = '';
        List<Messaging.Emailfileattachment> files = ALK_SendODSReportEmail.getEmailfileattachments(caseId[0]);
        
        for(ALK_Invoice__c invoice : ALK_SendODSReportEmail.getInvoiceIdsByCaseId(caseId[0])) {
            result = ALK_NotificationService.sendEmail('ALK_Template_Print_ODS', 
                                              invoice.ALK_Case__r.ContactId,
                                              invoice.Id,
                                              new String[] {UserInfo.getUserEmail(), invoice.ALK_Case__r.ALK_Delivery_Email__c}, 
                                              files);            
        } 
        
        return new String[]{result};
    }
    
    private static List<Messaging.Emailfileattachment> getEmailfileattachments(String caseId) {
        List<Messaging.Emailfileattachment> result = new List<Messaging.Emailfileattachment>();
        
        Map<String,Blob> bodies = ALK_SendODSReportEmail.getDocumentBodies(caseId);
        
        for(String key : bodies.keyset()) {
            Messaging.Emailfileattachment fa = new Messaging.Emailfileattachment();
            fa.setContentType('application/image');
            fa.setInline(false);
            fa.setFileName(key);            
            fa.setBody(bodies.get(key));
            
            result.add(fa);                
        }

		return result;        
    } 
    
    private static Map<String,Blob> getDocumentBodies(String caseId) {
        Map<String,Blob> result = new Map<String, Blob>();
        List<String> documentIds = new List<String>();
        
        for(ContentDocumentLink cdl : [SELECT ContentDocumentId FROM ContentDocumentLink Where LinkedEntityId = :caseId]) {
            documentIds.add(cdl.ContentDocumentId);
        }
        
        for(ContentVersion cv : [SELECT ContentDocumentId, ContentDocument.Title, ContentDocument.FileType, VersionData 
                                 From ContentVersion 
                                 Where ContentDocumentId = :documentIds AND 
                                 (FileType = 'PNG' OR FileType = 'JPG')]) {
            result.put(cv.ContentDocument.Title+'_'+cv.ContentDocumentId+'.'+cv.ContentDocument.FileType,cv.VersionData);
        }

        return result;
    }  
    
    private static List<ALK_Invoice__c> getInvoiceIdsByCaseId(String caseId) {
        List<ALK_Invoice__c> result = new List<ALK_Invoice__c>();
        
        for (ALK_Invoice__c i : [SELECT Id, ALK_Case__r.ALK_Delivery_Email__c, ALK_Case__r.ContactId from ALK_Invoice__c Where ALK_Case__c = :caseId]) {
            result.add(i);
        }
        
        return result;
    }
}