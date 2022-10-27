@isTest 
public class ALK_SendODSReportEmailTest {

    @isTest public static void test() {
        Account a = new Account(FirstName = 'testAccountSA', 
                                LastName = 'Last', 
                                PersonEmail='test@test.com',
                                Phone='573005716885',
                                ALK_WHATSAPP__c = false,
                                ALK_SMS__c = false,
                                ALK_EMAIL__c = true,
                                RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        insert a;        
        
        Case ods = new Case(AccountId = a.Id, 
                              Origin = 'ODS Demanda', 
                              Priority = 'Media', 
                              Subject = 'ODS', 
                              Status = 'Nuevo',
                              ALK_Delivery_Email__c = 'test@test.com',
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_ODS').getRecordTypeId());        

        insert ods;
        
        ALK_Invoice__c iods = new alk_Invoice__c();
        iods.ALK_Case__c = ods.Id;
        iods.ALK_EAN__c = '12345';
        iods.Name = '12345';        
        
        insert iods;
        
        ContentVersion contentVersion = new ContentVersion(
            Title          = 'a picture',
            PathOnClient   = 'Pic.jpg',
            VersionData    = Blob.valueOf('Test Content'),
            IsMajorVersion = true);
        insert contentVersion;
        
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record
        ContentDocumentLink cdl = new ContentDocumentLink();
        cdl.LinkedEntityId = ods.Id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.ShareType = 'V';
        cdl.Visibility = 'AllUsers';
        insert cdl;  
        
        Test.startTest();
        List<String> result = ALK_SendODSReportEmail.sendODSReport(new List<String>{ods.Id});
        
        System.assertEquals('SUCCESS', result.get(0));
        Test.stopTest();
    }
}