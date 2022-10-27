trigger ALK_ServiceAppointmentTrigger on ServiceAppointment (before update) {
    new ALK_ServiceAppointmentTriggerHandler().run();
}