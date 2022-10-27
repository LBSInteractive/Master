@isTest
public class ALK_NotificationServiceTest {
    
    @isTest static void testSendSMSSuccess() {
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;        
		Test.setMock(HttpCalloutMock.class, new ALK_HttpInfobipCalloutMockSuccess());
        
        Test.startTest();
        String result = ALK_NotificationService.sendSMS(System.Label.ALK_Infobip_SMS_Cita_Agendado,new string[]{'12-03-2022'}, '+5581999919603');
        Test.stopTest();
        
        System.assertEquals(ALK_NotificationService.SUCCESS, result);        
    }

    @isTest static void testSendSMSFailed() {
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;        
		Test.setMock(HttpCalloutMock.class, new ALK_HttpInfobipCalloutMockFail());
        
        Test.startTest();
        String result = ALK_NotificationService.sendSMS(System.Label.ALK_Infobip_SMS_Cita_Agendado,new string[]{'12-03-2022'}, '+5581999919603');
        Test.stopTest();
        
        System.assertEquals(ALK_NotificationService.FAILED, result);           
    }
    
    @isTest static void testSendWhatsAppSuccess() {
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;        
		Test.setMock(HttpCalloutMock.class, new ALK_HttpInfobipCalloutMockSuccess());
        
        Test.startTest();
        String result = ALK_NotificationService.sendWhatsapp(
            System.Label.ALK_Infobip_WhatsApp_Cita_Agendado,
            new string[]{'Nombre','Servicio','12-03-2022','10:00','Ordem','Orientaciones'}, 
            '+5581999919603');
        Test.stopTest();
        
        System.assertEquals(ALK_NotificationService.SUCCESS, result);        
    }

    @isTest static void testSendWhatsAppFailed() {
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;        
		Test.setMock(HttpCalloutMock.class, new ALK_HttpInfobipCalloutMockFail());
        
        Test.startTest();
        String result = ALK_NotificationService.sendWhatsapp(
            System.Label.ALK_Infobip_WhatsApp_Cita_Agendado,
            new string[]{'Nombre','Servicio','12-03-2022','10:00','Ordem','Orientaciones'}, 
            '+5581999919603');
        Test.stopTest();
        
        System.assertEquals(ALK_NotificationService.FAILED, result);           
    }  
    
    @isTest static void testSendEmail() {
        Test.startTest();
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');           
        String result = ALK_NotificationService.sendEmail(
            'ALK_WorkOrder_Notification',
            new Map<String,String>(), 
            'test@test.com');
        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');             
        Test.stopTest();
        
        System.assertEquals(ALK_NotificationService.SUCCESS, result);             
    }

    @isTest static void testSendEmailWithParams() {
        Test.startTest();
        System.assertEquals(0, Limits.getEmailInvocations(), 'No emails should be sent');           
        String result = ALK_NotificationService.sendEmail(
            'ALK_WorkOrder_Notification',
            new Map<String,String>{'{!WorkOrder.WorkOrderNumber}'=>'123456789'}, 
            'test@test.com');
        System.assertEquals(1, Limits.getEmailInvocations(), 'Emails should be sent');             
        Test.stopTest();
        
        System.assertEquals(ALK_NotificationService.SUCCESS, result);             
    }
    
    @isTest static void testFormatMessage() {
        String  message = 'Hey {0}, are you ok?';
        
        System.assertEquals('Hey John, are you ok?',  ALK_NotificationService.getFormattedMessage(message, new string[]{'John'}));        
    }    
}