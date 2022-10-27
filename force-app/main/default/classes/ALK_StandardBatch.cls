public without sharing abstract class ALK_StandardBatch implements Database.Batchable<sObject> {

    public virtual void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus
                          FROM AsyncApexJob WHERE Id = :BC.getJobId()];
                
        if (a.NumberOfErrors > 0) {
            this.sendSupportEmail(a);
        }
    }
    
    protected abstract String getBatchName();
    
    protected virtual ALK_Notification_Settings__mdt getConfig() {
        return ALK_Notification_Settings__mdt.getInstance('Default');
    }
    
    @TestVisible
    protected virtual void sendSupportEmail(AsyncApexJob a) {
        
        Organization org = [select InstanceName from Organization where Id =:UserInfo.getOrganizationId()];
        
        ALK_Notification_Settings__mdt config = this.getConfig();

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
        String[] toAddresses = new String[] {config.ALK_Email_Support__c};
        
        mail.setToAddresses(toAddresses);
        mail.setSubject(this.getBatchName() + ' (' + a.Status+')');
        mail.setPlainTextBody(String.format('The batch Apex job \"{0} ({1})\" processed {2} batches with {3} failures runnig on Instance {4}. \rFirst error short description:\r {5}', 
                                            new String[]{this.getBatchName(),
                                                a.Status, 
                                                String.valueOf(a.TotalJobItems), 
                                                String.valueOf(a.NumberOfErrors), 
                                                org.InstanceName,
                                                a.ExtendedStatus}));
        
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });         
    }    
}