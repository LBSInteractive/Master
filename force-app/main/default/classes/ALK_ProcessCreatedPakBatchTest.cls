@isTest public class ALK_ProcessCreatedPakBatchTest {
    
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
        
        Case solicitud = new Case(AccountId = a.Id, 
                              Origin = 'Solicitud Demanda', 
                              Priority = 'Media', 
                              Subject = 'SOLICITUD', 
                              Status = 'Nuevo',
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_SOLICITUD').getRecordTypeId());
        insert solicitud;
        
        ALK_Invoice__c isolicitud = new alk_Invoice__c();
        isolicitud.ALK_Case__c = solicitud.Id;
        isolicitud.ALK_EAN__c = '12345';
        isolicitud.Name = '12345';        
        
        insert isolicitud;        
        
        Case queja = new Case(AccountId = a.Id, 
                              Origin = 'SIC Demanda', 
                              Priority = 'Media', 
                              Subject = 'Queja', 
                              Status = 'Nuevo',
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_QUEJA').getRecordTypeId());
        insert queja;
        
        ALK_Invoice__c iQueja = new alk_Invoice__c();
        iQueja.ALK_Case__c = queja.Id;
        iQueja.ALK_EAN__c = '12345';
        iQueja.Name = '12345';        
        
        insert iQueja;
        
        Case ods = new Case(AccountId = a.Id, 
                              Origin = 'ODS Demanda', 
                              Priority = 'Media', 
                              Subject = 'ODS', 
                              Status = 'Nuevo',
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_ODS').getRecordTypeId());        

        insert ods;
        
        ALK_Invoice__c iods = new alk_Invoice__c();
        iods.ALK_Case__c = ods.Id;
        iods.ALK_EAN__c = '12345';
        iods.Name = '12345';        
        
        insert iods; 
        
        Case pak = new Case(AccountId = a.Id,
                              Origin = 'PAk', 
                              Priority = 'Media', 
                              Subject = 'Autorización de Cambio PAK', 
                              Status = 'Baja',
                              ALK_Pak_Batch_Status__c = 'No procesado',
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_PAK').getRecordTypeId());        

        insert pak;
        
        ALK_Invoice__c ipak = new alk_Invoice__c();
        ipak.ALK_Case__c = pak.Id;
        ipak.ALK_EAN__c = '12345';
        ipak.Name = '12345';        
        
        insert ipak; 
        
        Test.startTest();
        ALK_ProcessCreatedPakBatch b = new ALK_ProcessCreatedPakBatch();     
        Database.executeBatch(b);
        Test.stopTest();
        
        pak = [SELECT Id, ALK_Related_PQR__c, ALK_Related_ODS__c, ALK_Pak_Batch_Status__c FROM Case Where Id = :pak.Id];
        
        System.assertEquals(queja.Id, pak.ALK_Related_PQR__c);
        System.assertEquals(ods.Id, pak.ALK_Related_ODS__c);        
        System.assertEquals(pak.ALK_Pak_Batch_Status__c, 'ODS/PQR relacionados');        
    }

    @isTest static void testSchedule() {             
        Test.startTest();
        ALK_ProcessCreatedPakSchedule s = new ALK_ProcessCreatedPakSchedule();
		System.schedule('One shot', '0 0 8 13 2 ?', s);
        Test.stopTest();
    }    
    
    @isTest static void sendSupportEmailOnError() {
        Test.startTest();
        ALK_ProcessCreatedPakBatch b = new ALK_ProcessCreatedPakBatch();     
        Database.executeBatch(b); 
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus FROM AsyncApexJob Limit 1]; 
        b.sendSupportEmail(a);
        Test.stopTest();        
    }    
}