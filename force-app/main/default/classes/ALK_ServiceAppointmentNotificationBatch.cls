public with sharing class ALK_ServiceAppointmentNotificationBatch extends ALK_StandardBatch implements Database.AllowsCallouts{	
	@testVisible
    private Boolean isTestRunning = false;
    @testVisible
    List<ServiceAppointment> scopeTestRunning = null;
    
   public List<ServiceAppointment> start(Database.BatchableContext BC){
      List<String> validStatus = new List<String>{'Agendada','Cancelada','Ejecutada','En Viaje','Incompleta','No Contactada','Retrasada'};
      return [SELECT Id, 
              ALK_Customer_Name__c, 
              ALK_Work_Type_Name__c, 
              ALK_Service_Date__c, 
              ALK_Time_Window__c, 
              ALK_Work_Order_Number__c, 
              ALK_General_Recommendations__c,
              ALK_Email_Incomplete_Reason__c,
              ALK_Notificaction_Status__c,
              ALK_Update_Status_Mobile__c,
              ALK_Process_Notification__c,
              Status,
              AccountId,
              ContactId,
              Account.Phone,
              Contact.Email,
              Account.ALK_SMS__c,
              Account.ALK_WhatsApp__c,
              Account.ALK_Email__c                
              From ServiceAppointment 
              Where ALK_Process_Notification__c = true AND
              Status = :validStatus];
   }

   public void execute(Database.BatchableContext BC, List<ServiceAppointment> scope){
       if (!this.isTestRunning) {
       		ALK_ServiceAppointmentNotifyHandler.sendNotification(scope);
       } else {
           ALK_ServiceAppointmentNotifyHandler.sendNotification(this.scopeTestRunning);           
       }
   }

   public override void finish(Database.BatchableContext BC){
		super.finish(BC);
       
       if(!this.isTestRunning) {
           // Schedule the batch to process future record 
           System.scheduleBatch(new ALK_ServiceAppointmentNotificationBatch(), 
                                'Service Appointment Send Notification Job('+System.currentTimeMillis()+')', 
                                Integer.valueOf(this.getConfig().ALK_Notification_Interval__c), 
                                100);
       }
   }
    
    protected override String getBatchName() {
        return 'Service Appointment Send Notification Job';
    }
}