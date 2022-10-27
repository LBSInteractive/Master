public with sharing class ALK_VerificationCodeService { 
    @testVisible private static final String UNDEFINEDCHANNEL = 'At least one channel needs to be defined to send the verification code!';
    @testVisible private static final String UNDEFINEDACCOUNT = 'At least one account needs to be defined. The property \'accountId\' cannot be empty!';
    @testVisible private static final String UNDEFINEDPHONE = 'At least one phone number needs to be defined. The property \'mobilePhone\' cannot be empty!';
    @testVisible private static final String UNDEFINEDEMAIL = 'At least one email address needs to be defined. The property \'email\' cannot be empty!';
    
    @InvocableMethod
    public static List<ALK_VerificationCodeStatus> sendVerificationCode(List<ALK_MessageSettings> settings) {
    	ALK_VerificationCodeStatus result = new ALK_VerificationCodeStatus();
        
        // get the first value of the list because just one setting is needed to perform the process. The method must receive a list settings to be called 
        // by flow.
        ALK_MessageSettings setting = settings.get(0);
        
        ALK_VerificationCodeService.checkMessageSettings(setting);
        
        result.verificationCode = ALK_VerificationCodeService.getVerificationCode();
        
        Account acc = ALK_VerificationCodeService.getAccountById(setting.accountId);
        
        ALK_VerificationCodeService.sendWhatsApp(setting,acc,result.verificationCode,result);

        ALK_VerificationCodeService.sendSMS(setting,acc,result.verificationCode,result);

        ALK_VerificationCodeService.sendEmail(setting,acc,result.verificationCode,result);
        
        return new List<ALK_VerificationCodeStatus>{result};
    }
        
    private static String getVerificationCode() {
        String code = String.valueOf(Math.random());
        
        return code.right(5);
    }

    private static void checkMessageSettings(ALK_MessageSettings setting) {
        if (!setting.sendBySMS && !setting.sendByWhatsApp && !setting.sendByEmail) {
			throw new ALK_VefificationCodeServiceException(ALK_VerificationCodeService.UNDEFINEDCHANNEL);
        }
        
        if (String.isEmpty(setting.accountId)) {
			throw new ALK_VefificationCodeServiceException(ALK_VerificationCodeService.UNDEFINEDACCOUNT);
        }

        if ((setting.sendBySMS || setting.sendByWhatsApp) && String.isEmpty(setting.mobilePhone)) {
			throw new ALK_VefificationCodeServiceException(ALK_VerificationCodeService.UNDEFINEDPHONE);
        }  
        
        if (setting.sendByEmail && String.isEmpty(setting.email)) {
			throw new ALK_VefificationCodeServiceException(ALK_VerificationCodeService.UNDEFINEDEMAIL);
        }         
    }
    
    private static Account getAccountById(String id) {
        return [SELECT Id, Name From Account Where Id = :id];
    }
    
    private static void sendWhatsApp(ALK_MessageSettings setting, Account acc, String code, ALK_VerificationCodeStatus status) {
        if(setting.sendByWhatsApp) {
        	String[] data = new String[]{acc.Name,code,DateTime.now().format('dd/MM/yyyy')};
            String sendMessageResult = ALK_NotificationService.sendWhatsApp(System.Label.ALK_Infobip_WhatsApp_Verification_Code, data, setting.mobilePhone);
            
            if(sendMessageResult == ALK_NotificationService.SUCCESS) {
                status.statusWhatsAppMessage = String.format(System.label.ALK_Code_Sent,new String[]{'Whatsapp'});
                status.whatsAppMessageSent = true;
            } else {
                status.statusWhatsAppMessage = System.Label.ALK_Infobip_Code_Sent_Fail;
                status.whatsAppMessageSent = false;
            }              
        }
    }
    
    private static void sendSMS(ALK_MessageSettings setting, Account acc, String code, ALK_VerificationCodeStatus status) {
        if(setting.sendBySMS) {
        	String[] data = new String[]{code,DateTime.now().format('dd/MM/yyyy')};
            String sendMessageResult = ALK_NotificationService.sendSMS(System.Label.ALK_Infobip_SMS_Verification_Code, data, setting.mobilePhone);
            
            if(sendMessageResult == ALK_NotificationService.SUCCESS) {
                status.statusSMSMessage = String.format(System.label.ALK_Code_Sent,new String[]{'SMS'});
                status.smsMessageSent = true;
            } else {
                status.statusSMSMessage = System.Label.ALK_Infobip_Code_Sent_Fail;
                status.smsMessageSent = false;
            }               
        }        
    }

    private static void sendEmail(ALK_MessageSettings setting, Account acc, String code, ALK_VerificationCodeStatus status) {
        if(setting.sendByEmail) {
            Map<String,String> data = new Map<String,String>{'{!Nombre}' => acc.Name,'{!Codigo}'=> code,'{!Data}'=> DateTime.now().format('dd/MM/yyyy')};
            String sendMessageResult = ALK_NotificationService.sendEmail('ALK_Email_Verification_Code', data, setting.email);
            
            if(sendMessageResult == ALK_NotificationService.SUCCESS) {
                status.statusEmailMessage = String.format(System.label.ALK_Code_Sent,new String[]{'Email'});
                status.emailMessageSent = true;
            } else {
                status.statusEmailMessage = System.Label.ALK_Infobip_Code_Sent_Fail;
                status.emailMessageSent = false;
            }
        }          
    }  
    
    public class ALK_MessageSettings {
        @InvocableVariable
		public Boolean sendBySMS;
        @InvocableVariable
        public Boolean sendByWhatsApp;
        @InvocableVariable
        public Boolean sendByEmail;
        @InvocableVariable
        public String accountId = '';
        @InvocableVariable
        public String mobilePhone = '';
        @InvocableVariable
        public String email ='';      
    }
    
    public class ALK_VerificationCodeStatus {
        @InvocableVariable
		public String statusSMSMessage = '';
        @InvocableVariable        
        public Boolean smsMessageSent = false;
        @InvocableVariable
		public String statusWhatsAppMessage = '';
        @InvocableVariable        
        public Boolean WhatsAppMessageSent = false;        
        @InvocableVariable
		public String statusEmailMessage = '';
        @InvocableVariable        
        public Boolean emailMessageSent = false;          
        @InvocableVariable
		public String verificationCode = '';   
        @InvocableVariable
		public DateTime dateTimeCondeSent = System.now();           
    }
    
    // exception class
    public class ALK_VefificationCodeServiceException extends Exception {}          
}