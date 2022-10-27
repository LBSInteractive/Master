trigger ALK_ServiceReportTrigger on ServiceReport (after insert) {
    new ALK_ServiceRerportTriggerHandler().run();
}