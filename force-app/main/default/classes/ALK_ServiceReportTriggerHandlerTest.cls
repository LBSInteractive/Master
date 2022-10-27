@isTest
public class ALK_ServiceReportTriggerHandlerTest {
    
    @isTest
    public static void test() {        
        Account a = new Account(FirstName = 'testAccountSA', 
                                LastName = 'Last', 
                                PersonEmail='test@test.com',
                                RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        insert a; 
        
        Case cas = new Case (AccountId = a.Id, STATUS = 'New', Origin = 'Homepage');
        insert cas;
        
        WorkType wt = new WorkType(Name='Test', DurationType = 'Hours', EstimatedDuration=1);
        insert wt;
        
        WorkOrder WO = new WorkOrder (AccountId = a.Id, CaseId = cas.Id, WorkTypeId = wt.Id, ALK_Email_Address__c='test@test.com');
        insert WO;
        
        ServiceAppointment SA = new ServiceAppointment (ParentRecordId = WO.Id,
                                                        DueDate = System.today(),
                                                        DurationType='Minutes',
                                                        Duration=75);
        insert SA;
        
        ServiceReport sr = new ServiceReport();
        sr.DocumentBody = Blob.valueOf('Test Content') ; 
        sr.DocumentContentType ='application/pdf';
        sr.DocumentName='Test';
        sr.ParentId = SA.Id; 

        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');
 
        Test.startTest();
               
        insert sr ;
        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');         
        Test.stopTest();         
        
    }
}