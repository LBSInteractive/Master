@isTest public class ALK_RemoveEntitySubscriptionBatchTest {
    @isTest static void test1() {
        Account a = new Account(FirstName = 'testAccountSA', 
                                LastName = 'Last', 
                                PersonEmail='test@test.com',
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
        
        ServiceAppointment sa = new ServiceAppointment (ParentRecordId = WO.Id,
                                                        DueDate = System.today().AddDays(5),
                                                        EarliestStartTime = System.today().AddDays(-10),
                                                        DurationType='Minutes',
                                                        Duration=75,
                                                        ALK_Update_Status_Mobile__c=false,
                                                        ALK_Delete_Entity_Subscription__c = true,
                                                        ALK_Entity_Subscription_Reference_Date__c = System.now().addMinutes(-30),
                                                        ALK_Previous_Service_Resource_UserId__c = UserInfo.getUserId());
        insert sa;    
             
        EntitySubscription es = new EntitySubscription(ParentId = WO.Id, SubscriberId = UserInfo.getUserId());
		insert es;       
                
        Test.startTest();
        ALK_RemoveEntitySubscriptionBatch b = new ALK_RemoveEntitySubscriptionBatch();
		Database.executeBatch(b);
        Test.stopTest();
        
        System.assertEquals(false, [SELECT ALK_Delete_Entity_Subscription__c FROM ServiceAppointment Where Id = :sa.Id].ALK_Delete_Entity_Subscription__c);
        System.assertEquals(0, [SELECT Id, ParentId, SubscriberId FROM EntitySubscription].size());
    }
    
    @isTest static void testSchedule() {             
        Test.startTest();
        ALK_RemoveEntitySubscriptionSchedule s = new ALK_RemoveEntitySubscriptionSchedule();
		System.schedule('One shot', '0 0 8 13 2 ?', s);
        Test.stopTest();
    }    
    
    @isTest static void sendSupportEmailOnError() {
        Test.startTest();
        ALK_RemoveEntitySubscriptionBatch b = new ALK_RemoveEntitySubscriptionBatch();     
        Database.executeBatch(b); 
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus FROM AsyncApexJob Limit 1]; 
        b.sendSupportEmail(a);
        Test.stopTest();        
    }    
}