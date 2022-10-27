public with sharing class ALK_RemoveEntitySubscriptionSchedule implements System.Schedulable {
    
    public void execute(System.SchedulableContext sc) {
		Database.executeBatch(new ALK_RemoveEntitySubscriptionBatch());
    }
}