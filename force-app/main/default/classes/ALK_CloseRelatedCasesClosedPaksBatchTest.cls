@isTest public class ALK_CloseRelatedCasesClosedPaksBatchTest {
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
                              Status = 'New',
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
                              Status = 'New',
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
                              Status = 'New',
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
                              Status = 'New',
                              ALK_Approval_Number__c = 'AP_91953',
                              ALK_Pak_Batch_Status__c = 'ODS/PQR relacionados',
                              RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_PAK').getRecordTypeId());        

        insert pak;
        
        ALK_Invoice__c ipak = new alk_Invoice__c();
        ipak.ALK_Case__c = pak.Id;
        ipak.ALK_EAN__c = '12345';
        ipak.Name = '12345';        
        
        insert ipak; 
        
        pak.Status = 'Solicitud Finalizada con devolución';
        update pak;
        
        Test.startTest();
        ALK_CloseRelatedCasesClosedPaksBatch b = new ALK_CloseRelatedCasesClosedPaksBatch();     
        Database.executeBatch(b);
        Test.stopTest();
        
        pak = [SELECT Id, ALK_Pak_Batch_Status__c FROM Case Where Id = :pak.Id];
        ods = [SELECT Id, Status, Sub_Estado__c, ALK_Motivo_de_Cierre__c FROM Case Where Id = :ods.Id];
        queja = [SELECT Id, Status, ALK_Motivo_de_Cierre__c FROM Case Where Id = :queja.Id];
        solicitud = [SELECT Id, Status, ALK_Motivo_de_Cierre__c FROM Case Where Id = :solicitud.Id];
        
        System.assertEquals(queja.status, 'Cerrado');
        System.assertEquals(solicitud.status, 'Cerrado');        
        System.assertEquals(ods.status, 'Solución al Cliente');
        System.assertEquals(ods.Sub_Estado__c, 'Entregado Bono Cambio');        
        
        
        System.assertEquals(queja.ALK_Motivo_de_Cierre__c, 'A FAVOR DE CLIENTE ASUME ALKOSTO');
        System.assertEquals(solicitud.ALK_Motivo_de_Cierre__c, 'A FAVOR DE CLIENTE ASUME ALKOSTO');        
        System.assertEquals(ods.ALK_Motivo_de_Cierre__c, 'A FAVOR DE CLIENTE ASUME ALKOSTO');        
        
        System.assertEquals(pak.ALK_Pak_Batch_Status__c, 'ODS/PQR Cerrados');        
        
    }
    
    @isTest static void testSchedule() {             
        Test.startTest();
        ALK_CloseRelatedCasesClosedPaksScheduler s = new ALK_CloseRelatedCasesClosedPaksScheduler();
		System.schedule('One shot', '0 0 8 13 2 ?', s);
        Test.stopTest();
    }    
    
    @isTest static void sendSupportEmailOnError() {
        Test.startTest();
        ALK_CloseRelatedCasesClosedPaksBatch b = new ALK_CloseRelatedCasesClosedPaksBatch();     
        Database.executeBatch(b); 
		AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.Email, ExtendedStatus FROM AsyncApexJob Limit 1]; 
        b.sendSupportEmail(a);
        Test.stopTest();        
    }  
}