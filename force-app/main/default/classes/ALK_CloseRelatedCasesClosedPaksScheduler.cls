public without sharing class ALK_CloseRelatedCasesClosedPaksScheduler implements System.Schedulable {
    public void execute(System.SchedulableContext sc) {
		Database.executeBatch(new ALK_CloseRelatedCasesClosedPaksBatch());
    }
}