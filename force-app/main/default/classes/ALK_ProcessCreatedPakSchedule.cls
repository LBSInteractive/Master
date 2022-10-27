public without sharing class ALK_ProcessCreatedPakSchedule implements System.Schedulable {
    
    public void execute(System.SchedulableContext sc) {
		Database.executeBatch(new ALK_ProcessCreatedPakBatch());
    }
}