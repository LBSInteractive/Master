public with sharing class ALK_ServiceAppointmentNotifyHandler {
    private static final string AGENDADA = 'Agendada';
    private static final string CANCELADA = 'Cancelada';
    private static final string EJECUTADA = 'Ejecutada';
    private static final string ENVIAJE = 'En Viaje';
    private static final string INCOMPLETA = 'Incompleta';
    private static final string NOCONTACTADA = 'No Contactada';
    private static final string RETRASADA = 'Retrasada';
    private static final string WHATSAPP = 'WHATSAPP';
    private static final string SMS = 'SMS';
    private static final string EMAIL = 'EMAIL';
    private static final LIST<String> STATUS = new LIST<String>{AGENDADA,CANCELADA,EJECUTADA,ENVIAJE,INCOMPLETA,NOCONTACTADA,RETRASADA};
           
    public static void updateToNotify(List<ServiceAppointment> newList, Map<Id,ServiceAppointment> oldMap) {
        List<ServiceAppointment> updateList = ALK_ServiceAppointmentNotifyHandler.getServiceAppointmentStatusChanged(newList, oldMap);
        
        for(ServiceAppointment sa : updateList) {
            sa.ALK_Process_Notification__c = true;
        }        
    }   
    
    public static void sendNotification(List<ServiceAppointment> sas) {
        String template = '';
        String notificationResult = '';
        
        for(ServiceAppointment sa : sas) {
            if (ALK_ServiceAppointmentNotifyHandler.isOkToSendNotification(sa)) {
                if(sa.Account.ALK_WhatsApp__c) {
                    template = ALK_ServiceAppointmentNotifyHandler.getMessageTemplate(WHATSAPP, sa.Status);
                    
                    List<String> templateParamValues = ALK_ServiceAppointmentNotifyHandler.getMessageParamValues(sa, WHATSAPP, sa.Status);
                    
                    ALK_ServiceAppointmentNotifyHandler.sendMessage(sa, template, templateParamValues, sa.Account.Phone, true);
                    
                } else if(sa.Account.ALK_SMS__c || !sa.Account.ALK_EMAIl__c) {
                    template = ALK_ServiceAppointmentNotifyHandler.getMessageTemplate(SMS, sa.Status);
                    
                    List<String> templateParamValues = ALK_ServiceAppointmentNotifyHandler.getMessageParamValues(sa, SMS, sa.Status);
                                    
                    ALK_ServiceAppointmentNotifyHandler.sendMessage(sa, template, templateParamValues, sa.Account.Phone, false);
                } else if(sa.Account.ALK_EMAIl__c) {
                    template = ALK_ServiceAppointmentNotifyHandler.getMessageTemplate(EMAIL, sa.Status);
                    notificationResult = ALK_NotificationService.sendEmail(template, sa.ContactId, sa.Id, sa.Contact.Email); 
                    ALK_ServiceAppointmentNotifyHandler.updateNotificationStatus(sa, notificationResult);
                }                                        
            } else {
                ALK_ServiceAppointmentNotifyHandler.updateNotificationStatus(sa, ALK_NotificationService.FAILED);
            }
        }
        
        if (sas.size() > 0) {
            update sas;            
        }
    }
    
    private static Boolean isOkToSendNotification(ServiceAppointment sa) {
        if((!sa.Account.ALK_Email__c && String.isEmpty(sa.Account.Phone)) || 
           (!sa.Account.ALK_WhatsApp__c && !sa.Account.ALK_SMS__c && sa.Account.ALK_Email__c && String.isEmpty(sa.Contact.Email))) {
               return false;
           }
        return true;
    }

    private static List<ServiceAppointment> getServiceAppointmentStatusChanged(List<ServiceAppointment> newList, Map<Id,ServiceAppointment> oldMap) {
        List<ServiceAppointment> result = new List<ServiceAppointment>();
 
        for(ServiceAppointment sa : newList) {
            if (ALK_ServiceAppointmentNotifyHandler.STATUS.contains(sa.Status) &&
                (((sa.Status != oldMap.get(sa.Id).Status) || sa.ALK_Update_Status_Mobile__c) &&
                (!sa.ALK_Trabajo_Complejo__c || (sa.ALK_Related_Service_Appointment__c != null)))) {
                    result.add(sa);
                }
        }
               
        return result;
    }  
        
    private static List<ServiceAppointment> getServiceAppointments(Set<Id> saIds) {
        List<ServiceAppointment> result = [SELECT Id, 
                                           ALK_Customer_Name__c, 
                                           ALK_Work_Type_Name__c, 
                                           ALK_Service_Date__c, 
                                           ALK_Time_Window__c, 
                                           ALK_Work_Order_Number__c, 
                                           ALK_General_Recommendations__c,
                                           ALK_Email_Incomplete_Reason__c,
                                           ALK_Notificaction_Status__c,
                                           ALK_Update_Status_Mobile__c,
                                           Status,
                                           AccountId,
                                           ContactId,
                                           Account.Phone,
                                           Contact.Email,
                                           Account.ALK_SMS__c,
                                           Account.ALK_WhatsApp__c,
                                           Account.ALK_Email__c                
                                           From ServiceAppointment 
                                           Where Id = :saIds];
        
        return result;
    }    
    
    private static String getMessageTemplate(String c, String s){
        Map<String,Map<String,String>> templates = new Map<String,Map<String,String>> {
            ALK_ServiceAppointmentNotifyHandler.WHATSAPP => new Map<String,String> {
                ALK_ServiceAppointmentNotifyHandler.AGENDADA => System.Label.ALK_Infobip_WhatsApp_Cita_Agendado,
                ALK_ServiceAppointmentNotifyHandler.CANCELADA=>System.Label.ALK_Infobip_WhatsApp_Cita_Cancelada,
                ALK_ServiceAppointmentNotifyHandler.EJECUTADA=>System.Label.ALK_Infobip_WhatsApp_Cita_Ejecutado,
                ALK_ServiceAppointmentNotifyHandler.ENVIAJE=>System.Label.ALK_Infobip_WhatsApp_Cita_En_Viaje,
                ALK_ServiceAppointmentNotifyHandler.INCOMPLETA=>System.Label.ALK_Infobip_WhatsApp_Cita_Incompleto,
                ALK_ServiceAppointmentNotifyHandler.NOCONTACTADA=>System.Label.ALK_Infobip_WhatsApp_Cita_No_Contactado,
                ALK_ServiceAppointmentNotifyHandler.RETRASADA=>System.Label.ALK_Infobip_WhatsApp_Cita_Retrasado_Novedad},
            ALK_ServiceAppointmentNotifyHandler.SMS => new Map<String,String> {	
                ALK_ServiceAppointmentNotifyHandler.AGENDADA => System.Label.ALK_Infobip_SMS_Cita_Agendado,
                ALK_ServiceAppointmentNotifyHandler.CANCELADA=>System.Label.ALK_Infobip_SMS_Cita_Cancelada,
                ALK_ServiceAppointmentNotifyHandler.EJECUTADA=>System.Label.ALK_Infobip_SMS_Cita_Ejecutado,
                ALK_ServiceAppointmentNotifyHandler.ENVIAJE=>System.Label.ALK_Infobip_SMS_Cita_En_Viaje,
                ALK_ServiceAppointmentNotifyHandler.INCOMPLETA=>System.Label.ALK_Infobip_SMS_Cita_Incompleto,
                ALK_ServiceAppointmentNotifyHandler.NOCONTACTADA=>System.Label.ALK_Infobip_SMS_Cita_No_Contactado,
                ALK_ServiceAppointmentNotifyHandler.RETRASADA=>System.Label.ALK_Infobip_SMS_Cita_Retrasado_Novedad},
            ALK_ServiceAppointmentNotifyHandler.EMAIL => new Map<String,String> {	
                ALK_ServiceAppointmentNotifyHandler.AGENDADA => 'ALK_Email_Cita_Agendado',
                ALK_ServiceAppointmentNotifyHandler.CANCELADA=>'ALK_Email_Cita_Cancelada',
                ALK_ServiceAppointmentNotifyHandler.EJECUTADA=>'ALK_Email_Cita_Ejecutado',
                ALK_ServiceAppointmentNotifyHandler.ENVIAJE=>'ALK_Email_Cita_En_Viaje',
                ALK_ServiceAppointmentNotifyHandler.INCOMPLETA=>'ALK_Email_Cita_Incompleto',
                ALK_ServiceAppointmentNotifyHandler.NOCONTACTADA=>'ALK_Email_Cita_No_Contactado',
                ALK_ServiceAppointmentNotifyHandler.RETRASADA=>'ALK_Email_Cita_Retrasado_Novedad'}
        };
            
            return templates.get(c).get(s);
    }
    
    private static List<String> getMessageParamValues(ServiceAppointment sa, String c, String s){
        Map<String,Map<String,List<String>>> templates = new Map<String,Map<String,List<String>>> {
            ALK_ServiceAppointmentNotifyHandler.WHATSAPP => new Map<String,List<String>> {
                ALK_ServiceAppointmentNotifyHandler.AGENDADA => new List<String>{sa.ALK_Customer_Name__c,sa.ALK_Work_Type_Name__c,String.valueOf(sa.ALK_Service_Date__c),sa.ALK_Time_Window__c,sa.ALK_Work_Order_Number__c,String.isEmpty(sa.ALK_General_Recommendations__c) ? '': sa.ALK_General_Recommendations__c.replace('\n', '  ')},
                ALK_ServiceAppointmentNotifyHandler.CANCELADA=>new List<String>{sa.ALK_Customer_Name__c,sa.ALK_Work_Type_Name__c,sa.ALK_Work_Order_Number__c},
                ALK_ServiceAppointmentNotifyHandler.EJECUTADA=>new List<String>{sa.ALK_Customer_Name__c},
                ALK_ServiceAppointmentNotifyHandler.ENVIAJE=>new List<String>{sa.ALK_Customer_Name__c,sa.ALK_Work_Order_Number__c, sa.ALK_Work_Type_Name__c},
                ALK_ServiceAppointmentNotifyHandler.INCOMPLETA=>new List<String>{sa.ALK_Customer_Name__c,sa.ALK_Work_Type_Name__c,sa.ALK_Work_Order_Number__c,sa.ALK_Email_Incomplete_Reason__c},
                ALK_ServiceAppointmentNotifyHandler.NOCONTACTADA=>new List<String>{sa.ALK_Customer_Name__c,sa.ALK_Work_Type_Name__c,sa.ALK_Work_Order_Number__c},
                ALK_ServiceAppointmentNotifyHandler.RETRASADA=>new List<String>{sa.ALK_Customer_Name__c, sa.ALK_Work_Type_Name__c}},
            ALK_ServiceAppointmentNotifyHandler.SMS => new Map<String,List<String>> {	
                ALK_ServiceAppointmentNotifyHandler.AGENDADA => new List<String>{String.valueOf(sa.ALK_Service_Date__c),sa.ALK_Time_Window__c},
                ALK_ServiceAppointmentNotifyHandler.CANCELADA=>new List<String>{sa.ALK_Work_Order_Number__c},
                ALK_ServiceAppointmentNotifyHandler.EJECUTADA=>new List<String>{},
                ALK_ServiceAppointmentNotifyHandler.ENVIAJE=>new List<String>{sa.ALK_Time_Window__c},
                ALK_ServiceAppointmentNotifyHandler.INCOMPLETA=>new List<String>{sa.ALK_Work_Order_Number__c, sa.ALK_Email_Incomplete_Reason__c},
                ALK_ServiceAppointmentNotifyHandler.NOCONTACTADA=>new List<String>{},
                ALK_ServiceAppointmentNotifyHandler.RETRASADA=>new List<String>{}}
        };           
    
		return templates.get(c).get(s);
    }
    
    private static void sendMessage(ServiceAppointment sa, String template, List<String> templateParamValues, string phone, Boolean sendToWhatsApp) {
        String notificationResult = '';
        
        if (sendToWhatsApp) {
            notificationResult = ALK_NotificationService.sendWhatsApp(template, templateParamValues, phone);
        } else {
            notificationResult = ALK_NotificationService.sendSMS(template, templateParamValues, phone);  
        }
        ALK_ServiceAppointmentNotifyHandler.updateNotificationStatus(sa, notificationResult);
    }
    
    private static void updateNotificationStatus(ServiceAppointment sa, String notificationResult) {        
        if (notificationResult == ALK_NotificationService.SUCCESS) {
            sa.ALK_Notificaction_Status__c = 'Notificación Enviada';
        } else {
            sa.ALK_Notificaction_Status__c = 'Envío de notificación fallido';            
        }
        
        sa.ALK_Update_Status_Mobile__c = false;
        sa.ALK_Process_Notification__c = false;               
    }      
}