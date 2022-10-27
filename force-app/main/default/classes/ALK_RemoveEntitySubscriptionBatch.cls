public with sharing class ALK_RemoveEntitySubscriptionBatch extends ALK_StandardBatch {
    
    private static final Integer MINUTES_AGO = -10;
    
    public List<ServiceAppointment> start(Database.BatchableContext BC){
        return [SELECT Id, 
                ParentRecordId,
                ALK_Previous_Service_Resource_UserId__c               
                From ServiceAppointment 
                Where ALK_Delete_Entity_Subscription__c = true AND
                ALK_Entity_Subscription_Reference_Date__c <= :DateTime.now().addMinutes(MINUTES_AGO) WITH SECURITY_ENFORCED];
    }
    
    public void execute(Database.BatchableContext BC, List<ServiceAppointment> scope){
        List<String> parentRecordIds = new List<String>();
        List<String> userIds = new List<String>();
        
        for(ServiceAppointment a : scope) {
            parentRecordIds.add(a.ParentRecordId);
            userIds.add(a.ALK_Previous_Service_Resource_UserId__c);
            a.ALK_Delete_Entity_Subscription__c = false;
        }
        
        if (scope.size() > 0) {
            List<EntitySubscription> subscriptionsToRemove = [SELECT Id 
                                                              FROM EntitySubscription 
                                                              Where ParentId = :parentRecordIds AND
                                                              SubscriberId = :userIds WITH SECURITY_ENFORCED];
            
            if (subscriptionsToRemove.size() > 0) {
                delete subscriptionsToRemove;
            }
            
            update scope;
        }
    }
    
    protected override String getBatchName() {
        return 'Remove entity subscription Job';
    } 
}