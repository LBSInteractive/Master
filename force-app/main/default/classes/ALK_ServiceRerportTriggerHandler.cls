public with sharing class ALK_ServiceRerportTriggerHandler extends TriggerHandler {
    
    @TestVisible
    protected override void afterInsert(){        
        List<ServiceAppointment> sas = this.getServiceAppointments();
        
        Map<Id, Messaging.Emailfileattachment> fas = this.getEmailfileattachments();
               
        for(ServiceAppointment sa : sas) {
            ALK_NotificationService.sendEmail('ALK_WorkOrder_Notification', 
                                              new Map<String, string> {'{!WorkOrder.WorkOrderNumber}'=> sa.ALK_Work_Order__r.WorkOrderNumber},
                                              sa.ALK_Work_Order__r.ALK_Email_Address__c, 
                                              new Messaging.Emailfileattachment[] {fas.get(sa.Id)});
        }
    }
    
    private List<ServiceAppointment> getServiceAppointments() { 
        List<ServiceAppointment> result = new List<ServiceAppointment>();
        
        for(ServiceAppointment sa : [SELECT Id,AccountId, Account.ALK_Email__c,ALK_Work_Order__r.ALK_Email_Address__c,ALK_Work_Order__r.WorkOrderNumber,ParentRecordId
                                     FROM ServiceAppointment 
                                     WHERE Id = :this.getServiceAppoitmentIds() AND 
                                     AccountId!= null AND 
                                     ParentRecordId != null
                                     WITH SECURITY_ENFORCED]) {
                                         if (!String.isEmpty(sa.ALK_Work_Order__r.ALK_Email_Address__c)) {
                                             System.debug('result.add(sa) -> ' + sa.id);
                                             result.add(sa);
                                         }
                                     }  
        
        return result;
    }
    
    private Map<Id, Messaging.Emailfileattachment> getEmailfileattachments() {
        Map<Id, Messaging.Emailfileattachment> result = new Map<Id, Messaging.Emailfileattachment>();
        Map<Id, Blob> bodies = this.getDocumentBodies();
        
        for(Object sr : Trigger.new) {
            Messaging.Emailfileattachment fa = new Messaging.Emailfileattachment();
            fa.setContentType('application/pdf');
            fa.setInline(false);
            fa.setFileName(((ServiceReport)sr).ServiceReportNumber);            
            fa.setBody(bodies.get(((ServiceReport)sr).Id));
             
            result.put(((ServiceReport)sr).ParentId, fa );            
        }

		return result;        
    } 
    
    private Map<Id, Blob> getDocumentBodies() {
        Map<Id, Blob> result = new Map<Id, Blob>();
        
        for(ServiceReport sr : [SELECT Id, DocumentBody FROM ServiceReport WHERE Id = :this.getServiceReportIds() WITH SECURITY_ENFORCED]) {
            result.put(sr.Id,sr.DocumentBody);
        }

        return result;
    }
    
    private List<Id> getServiceReportIds() {
        List<Id> result = new List<Id>();
        
        for(Object sr : Trigger.new) {
            result.add(((ServiceReport)sr).Id);
        }
        
        return result;
    }    
    
    private List<Id> getServiceAppoitmentIds() {
        List<Id> result = new List<Id>();
        
        for(Object sr : Trigger.new) {
            result.add(((ServiceReport)sr).ParentId);
        }
        
        return result;
    }
}