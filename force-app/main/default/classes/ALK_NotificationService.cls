public with sharing class ALK_NotificationService {    
	public static final String SUCCESS = 'SUCCESS';
	public static final String FAILED = 'FAILED';    
    
    public static string sendSMS(String message, List<String> messageParamValues, String phoneNumber) {
        ALK_InfobipCalloutRequestWrapper request = new ALK_InfobipCalloutRequestWrapper();
                
        request.type = ALK_InfobipCalloutRequestWrapper.SMS;
        request.destinationTo= phoneNumber;
        request.message = getFormattedMessage(message, messageParamValues);        
        ALk_InfobipCallout callout = new ALk_InfobipCallout();
        
        ALK_InfobipCalloutResponseWrapper response = callout.sendMessage(request);
        
        return response.isSucceeded ? SUCCESS : FAILED;
    }
    
    public static string sendWhatsApp(String templateName, List<String> templateData, String phoneNumber) {
        ALK_InfobipCalloutRequestWrapper request = new ALK_InfobipCalloutRequestWrapper();
                
        request.type = ALK_InfobipCalloutRequestWrapper.WHATSAPP;
        request.destinationTo= phoneNumber;
        request.templateName = templateName;        
        request.templateData = templateData;        
        
        ALk_InfobipCallout callout = new ALk_InfobipCallout();
        
        ALK_InfobipCalloutResponseWrapper response = callout.sendMessage(request);
        
        return response.isSucceeded ? SUCCESS : FAILED;
    }

    public static string sendEmail(String templateName, Map<String, string> templateParams, String emailAddress) {
        return sendEmail(templateName, templateParams, emailAddress, new list<Messaging.Emailfileattachment>());
    }
    
    public static string sendEmail(String templateName, Map<String, string> templateParams, String emailAddress, 
                                   list<Messaging.Emailfileattachment> attachedFiles) {
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSenderDisplayName('Alkosto Support'); // definir custom label para isso
        message.setReplyTo('no-reply@company.com');
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        EmailTemplate emailTemplate = ALK_NotificationService.getEmailTemplate(templateName);
        
        String subject = emailTemplate.Subject;
        String htmlBody = emailTemplate.HtmlValue;
        String textBody = emailTemplate.Body;
        
        for(String key : templateParams.keySet() ) {
            if (!String.isEmpty(subject)) {
                subject  = subject.replace(key, (templateParams.get(key) == null) ? '' : templateParams.get(key));
            }
            if (!String.isEmpty(htmlBody)) {
            	htmlBody = htmlBody.replace(key, (templateParams.get(key) == null) ? '' : templateParams.get(key));
            }
            if (!String.isEmpty(textBody)) {
            	textBody = textBody.replace(key, (templateParams.get(key) == null) ? '' : templateParams.get(key));  
            }
        }
                
		message.setSubject(subject);                                       
        message.setPlainTextBody(textBody);
        message.setHtmlBody(htmlBody);       
                                       
        message.toAddresses = new String[] { emailAddress};
        if (attachedFiles.size() > 0) {
                message.setFileAttachments(attachedFiles);                
       	}
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
        
        System.debug('Email sent with success ' + results[0].success);                               
        if (results[0].success)
        {
            return SUCCESS;
        }
        else
        {
            return FAILED;
        }
    }    
    public static string sendEmail(String templateName, String targetObjectId, String whatId, string emailAddress) {
    	return ALK_NotificationService.sendEmail(templateName, targetObjectId, whatId, new String[] { emailAddress}, new list<Messaging.Emailfileattachment>());
    }
    
    public static string sendEmail(String templateName, String targetObjectId, String whatId, string[] emailAddress, list<Messaging.Emailfileattachment> attachedFiles) {
        
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setSenderDisplayName('Alkosto Support'); // definir custom label para isso
        message.setReplyTo('no-reply@company.com');
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        message.setTreatTargetObjectAsRecipient(false);
        message.setTargetObjectId(targetObjectId);
        message.setWhatId(whatId);
        EmailTemplate emailTemplate =ALK_NotificationService.getEmailTemplate(templateName);
              
        message.setTemplateId(emailTemplate.Id);                               
        message.toAddresses = emailAddress;
        
        if (attachedFiles.size() > 0) {
                message.setFileAttachments(attachedFiles);                
       	}
        
        Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage> {message};
        Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
                                     
        if (results[0].success)
        {
            return SUCCESS;
        }
        else
        {
            return FAILED;
        }
    } 
    
    @TestVisible
    private static String getFormattedMessage(String message, List<String> paramValues) {
        String result = message;
        
        if (paramValues.size() > 0) {
            result = String.format(message, paramValues);
        }
        
        return result;
    }
    
    private static EmailTemplate getEmailTemplate(String templateName) {
        System.debug('email templateName -> ' + templateName);
        return [Select Id,Subject,Description, HtmlValue,DeveloperName,Body from EmailTemplate where DeveloperName = :templateName];
    }
}