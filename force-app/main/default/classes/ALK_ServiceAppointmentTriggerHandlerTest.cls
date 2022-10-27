@isTest(SeeAllData=true)
public class ALK_ServiceAppointmentTriggerHandlerTest {
    
    @isTest static void triggerWhatsAppNotification() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInfobipCalloutMockSuccess());
        
        Account a = new Account(FirstName = 'testAccountSA', 
                                LastName = 'Last', 
                                PersonEmail='test@test.com',
                                Phone='573005716885',
                                ALK_WHATSAPP__c = true,
                                ALK_SMS__c = false,
                                ALK_EMAIL__c = false,
                                RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        insert a; 
        
        Case cas = new Case (AccountId = a.Id, STATUS = 'New', Origin = 'Homepage');
        insert cas;
        
        WorkType wt = new WorkType(Name='Test', DurationType = 'Hours', EstimatedDuration=1);
        insert wt;
        
        WorkOrder WO = new WorkOrder (AccountId = a.Id, CaseId = cas.Id, WorkTypeId = wt.Id);
        insert WO;
        
        ServiceAppointment SA = new ServiceAppointment (ParentRecordId = WO.Id,
                                                        DueDate = System.today().AddDays(5),
                                                        EarliestStartTime = System.today().AddDays(-10),
                                                        DurationType='Minutes',
                                                        Duration=75,
                                                        ALK_Update_Status_Mobile__c=false);
        insert SA;    
        
        Test.startTest();
        sa.Status = 'Agendada';
        update SA;     
        ALK_ServiceAppointmentNotificationBatch B = new ALK_ServiceAppointmentNotificationBatch();
        b.isTestRunning = true;
        b.scopeTestRunning = new List<ServiceAppointment>{getSAById(sa.Id)};
        Database.executeBatch(b);
        Test.stopTest();
        
        System.assertEquals('Notificación Enviada', 
                            [SELECT ALK_Notificaction_Status__c FROM ServiceAppointment Where Id = :sa.Id].ALK_Notificaction_Status__c, 
                            'Notification sent successfully');

		delete sa;
		delete wo;
		delete wt;
		delete cas;        
        delete a;
    }
    
    @isTest static void triggerSMSNotification() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInfobipCalloutMockSuccess());
        Test.startTest();        
        Account a = new Account(FirstName = 'testAccountSA', 
                                LastName = 'Last', 
                                PersonEmail='test@test.com',
                                Phone='573005716885',
                                ALK_WHATSAPP__c = false,
                                ALK_SMS__c = true,
                                ALK_EMAIL__c = false,
                                RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        insert a; 
        
        Case cas = new Case (AccountId = a.Id, STATUS = 'New', Origin = 'Homepage');
        insert cas;
        
        WorkType wt = new WorkType(Name='Test', DurationType = 'Hours', EstimatedDuration=1);
        insert wt;
        
        WorkOrder WO = new WorkOrder (AccountId = a.Id, CaseId = cas.Id, WorkTypeId = wt.Id);
        insert WO;
        
        ServiceAppointment SA = new ServiceAppointment (ParentRecordId = WO.Id,
                                                        DueDate = System.today().AddDays(5),
                                                        EarliestStartTime = System.today().AddDays(-10),
                                                        DurationType='Minutes',
                                                        Duration=75);
        insert SA;

        sa.Status = 'Agendada';
        update SA; 
        ALK_ServiceAppointmentNotificationBatch B = new ALK_ServiceAppointmentNotificationBatch();
        b.isTestRunning = true;  
        b.scopeTestRunning = new List<ServiceAppointment>{getSAById(sa.Id)};        
        Database.executeBatch(b);
        Test.stopTest();  

        System.assertEquals('Notificación Enviada', 
                            [SELECT ALK_Notificaction_Status__c FROM ServiceAppointment Where Id = :sa.Id].ALK_Notificaction_Status__c, 
                            'Notification sent successfully');   
        
		delete sa;
		delete wo;
		delete wt;
		delete cas;        
        delete a;        
    } 
    
    @isTest static void triggerEmailNotification() {       
        Account a = new Account(FirstName = 'testAccountSA', 
                                LastName = 'Last', 
                                PersonEmail='aurinosf@gmail.com',
                                Phone='573005716885',
                                ALK_WHATSAPP__c = false,
                                ALK_SMS__c = false,
                                ALK_EMAIL__c = true,                                
                                RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        insert a; 
        
        Case cas = new Case (AccountId = a.Id, STATUS = 'New', Origin = 'Homepage');
        insert cas;
        
        WorkType wt = new WorkType(Name='Test', DurationType = 'Hours', EstimatedDuration=1);
        insert wt;
        
        WorkOrder WO = new WorkOrder (AccountId = a.Id, CaseId = cas.Id, WorkTypeId = wt.Id);
        insert WO;
        
        ServiceAppointment SA = new ServiceAppointment (ParentRecordId = WO.Id,
                                                        DueDate = System.today().AddDays(5),
                                                        EarliestStartTime = System.today().AddDays(-10),
                                                        DurationType='Minutes',
                                                        Duration=75,
                                                        ContactId=[SELECT Id From Contact Where AccountId = :a.Id].Id);
        insert SA;

        sa.Status = 'Agendada';
        Test.startTest();
        update SA;
        ALK_ServiceAppointmentNotificationBatch B = new ALK_ServiceAppointmentNotificationBatch();
        b.isTestRunning = true;  
        b.scopeTestRunning = new List<ServiceAppointment>{getSAById(sa.Id)};        
        Database.executeBatch(b);        
        Test.stopTest();          

        System.assertEquals('Notificación Enviada', 
                            [SELECT ALK_Notificaction_Status__c FROM ServiceAppointment Where Id = :sa.Id].ALK_Notificaction_Status__c, 
                            'Notification sent successfully');        
        
		delete sa;
		delete wo;
		delete wt;
		delete cas;        
        delete a;        
    }  
    
    @isTest static void sendSupportEmailOnError() {
        Test.startTest();
        ALK_ServiceAppointmentNotificationBatch b = new ALK_ServiceAppointmentNotificationBatch();
        b.isTestRunning = true;
        b.scopeTestRunning = new List<ServiceAppointment>();        
        Database.executeBatch(b); 
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus FROM AsyncApexJob Limit 1]; 
        b.sendSupportEmail(a);
        Test.stopTest();        
    }

    private static ServiceAppointment getSAById(String id) {
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
              Id = :id];
    }    
}