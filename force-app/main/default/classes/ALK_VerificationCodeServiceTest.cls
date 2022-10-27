@isTest
public class ALK_VerificationCodeServiceTest {

    @isTest public static void sendVerificationCodeSuccess() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInfobipCalloutMockSuccess());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        Account acc = new Account(FirstName = 'Test', 
                                  LastName='Verification Code', 
                                  RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        
        insert acc;
        
        ALK_VerificationCodeService.ALK_MessageSettings setting = new ALK_VerificationCodeService.ALK_MessageSettings();
        
        setting.sendBySMS = true;
        setting.sendByWhatsApp = true;
        setting.sendByEmail = true;        
        setting.mobilePhone = '+5581999999999';  
        setting.accountId = acc.Id;  
        setting.email = 'test@colcomercio.co';
        
        Test.startTest();
        List<ALK_VerificationCodeService.ALK_VerificationCodeStatus> result = ALK_VerificationCodeService.sendVerificationCode(
            new List<ALK_VerificationCodeService.ALK_MessageSettings>{setting});
        Test.stopTest();
        
        System.assert(!String.isEmpty(result[0].verificationCode));
        System.assertEquals(String.format(System.label.ALK_Code_Sent,new String[]{'SMS'}), result[0].statusSMSMessage);
        System.assertEquals(String.format(System.label.ALK_Code_Sent,new String[]{'Email'}), result[0].statusEmailMessage);            
        System.assertEquals(String.format(System.label.ALK_Code_Sent,new String[]{'Whatsapp'}), result[0].statusWhatsAppMessage);
        System.assertEquals(true,result[0].smsMessageSent);
        System.assertEquals(true,result[0].emailMessageSent);            
        System.assertEquals(true,result[0].whatsAppMessageSent);    
        
    }
    
    @isTest public static void sendVerificationCodeFail() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInfobipCalloutMockFail());
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;
        
        Account acc = new Account(FirstName = 'Test', 
                                  LastName='Verification Code', 
                                  RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        
        insert acc;
        
        ALK_VerificationCodeService.ALK_MessageSettings setting = new ALK_VerificationCodeService.ALK_MessageSettings();
        
        setting.sendBySMS = true;
        setting.sendByWhatsApp = true;
        setting.sendByEmail = true;        
        setting.mobilePhone = '+5581999999999';  
        setting.accountId = acc.Id;  
        setting.email = 'test@colcomercio.co';
        
        Test.startTest();
        List<ALK_VerificationCodeService.ALK_VerificationCodeStatus> result = ALK_VerificationCodeService.sendVerificationCode(
            new List<ALK_VerificationCodeService.ALK_MessageSettings>{setting});
        Test.stopTest();
        
        System.assert(!String.isEmpty(result[0].verificationCode));
        System.assertEquals(System.Label.ALK_Infobip_Code_Sent_Fail, result[0].statusSMSMessage);
    }

    @isTest public static void checkMessageSettingsFail() {
        ALK_VerificationCodeService.ALK_MessageSettings setting = new ALK_VerificationCodeService.ALK_MessageSettings();
        
        setting.sendBySMS = false;
        setting.sendByWhatsApp = false;
        setting.sendByEmail = false;        
        setting.mobilePhone = '';  
        setting.accountId = '';  
        setting.email = '';
        
        try {
            List<ALK_VerificationCodeService.ALK_VerificationCodeStatus> result = ALK_VerificationCodeService.sendVerificationCode(
                new List<ALK_VerificationCodeService.ALK_MessageSettings>{setting});            
        } catch(ALK_VerificationCodeService.ALK_VefificationCodeServiceException ex) {
			System.assertEquals(ALK_VerificationCodeService.UNDEFINEDCHANNEL,ex.getMessage());   
        }   
        setting.sendBySMS = true;
        try {
            List<ALK_VerificationCodeService.ALK_VerificationCodeStatus> result = ALK_VerificationCodeService.sendVerificationCode(
                new List<ALK_VerificationCodeService.ALK_MessageSettings>{setting});            
        } catch(ALK_VerificationCodeService.ALK_VefificationCodeServiceException ex) {
			System.assertEquals(ALK_VerificationCodeService.UNDEFINEDACCOUNT,ex.getMessage());   
        }  
        setting.accountId = '1';
        try {
            List<ALK_VerificationCodeService.ALK_VerificationCodeStatus> result = ALK_VerificationCodeService.sendVerificationCode(
                new List<ALK_VerificationCodeService.ALK_MessageSettings>{setting});            
        } catch(ALK_VerificationCodeService.ALK_VefificationCodeServiceException ex) {
			System.assertEquals(ALK_VerificationCodeService.UNDEFINEDPHONE,ex.getMessage());   
        } 
 
        setting.mobilePhone = '+5581999999999';
        setting.sendByEmail = true;
        try {
            List<ALK_VerificationCodeService.ALK_VerificationCodeStatus> result = ALK_VerificationCodeService.sendVerificationCode(
                new List<ALK_VerificationCodeService.ALK_MessageSettings>{setting});            
        } catch(ALK_VerificationCodeService.ALK_VefificationCodeServiceException ex) {
			System.assertEquals(ALK_VerificationCodeService.UNDEFINEDEMAIL,ex.getMessage());   
        }         
    }    
}