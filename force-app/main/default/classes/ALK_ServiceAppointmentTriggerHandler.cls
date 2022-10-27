public without sharing class ALK_ServiceAppointmentTriggerHandler extends TriggerHandler {
    protected override void beforeUpdate(){
        ALK_ServiceAppointmentNotifyHandler.updateToNotify((List<ServiceAppointment>)Trigger.new, (Map<Id,ServiceAppointment>)Trigger.oldMap);
    }
}