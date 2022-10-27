public without sharing class ALK_CloseRelatedCasesClosedPaksBatch Extends ALK_StandardBatch {
    public List<ALK_Invoice__c> start(Database.BatchableContext BC){
        List<ALK_Invoice__c> scope = [SELECT Id,
                NAME,
                ALK_EAN__c,
                ALK_Case__c,
                ALK_Case__r.CaseNumber,
                ALK_Case__r.ALK_Approval_Number__c
                From ALK_Invoice__c 
                Where ALK_Case__r.ALK_Pak_Batch_Status__c = 'ODS/PQR relacionados' AND
                ALK_Case__r.RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_PAK').getRecordTypeId() AND
                (ALK_Case__r.Status = 'Solicitud Finalizada con devolución' OR ALK_Case__r.Status = 'No hay solicitudes pendientes')];
        
        System.debug('scope -> ' + scope);
        
        return scope;
    }

    public void execute(Database.BatchableContext BC, List<ALK_Invoice__c> scope){
        List<String> invoiceNuList = new List<String>();
        List<String> eanNuList = new List<String>();
        List<String> caseRTIdList = new List<String>{
            Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_ODS').getRecordTypeId(),
            Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_QUEJA').getRecordTypeId(),
            Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_SOLICITUD').getRecordTypeId()};
        List<String> statusListQueja = new List<String>{'New', 'En Progreso', 'En espera del cliente', 'En espera del Proveedor'};
        List<String> statusListODS = new List<String>{'Cambio Evitado Gestión Técnico','Anulación de ODS','Abandono Cliente;','Solución al cliente'};            
        List<Case> casesToBeUpdated = new List<Case>();
        Map<String,String> caseNumberMap = new Map<String,String>();
        Map<String,String> caseApprovalNumberMap = new Map<String,String>(); 
        List<String> pakCaseIdList = new List<String>();         
        List<FeedItem> posts = new List<FeedItem>();
        Map<String,String> relatedCaseIdClosedReasonMap = new Map<String,String>();                      
        Map<String,String> relatedCaseIdClosedStateMap = new Map<String,String>();                      
        
        if (scope.size() > 0) {
            
            for(ALK_Invoice__c i : scope) {
                invoiceNuList.add(i.Name);
                eanNuList.add(i.ALK_EAN__c);
                caseNumberMap.put(i.Name+i.ALK_EAN__c,i.ALK_Case__r.CaseNumber);
                caseApprovalNumberMap.put(i.Name+i.ALK_EAN__c,i.ALK_Case__r.ALK_Approval_Number__c);
                pakCaseIdList.add(i.ALK_Case__c);
            }

            List<ALK_Invoice__c> relatedInvoiceList = this.getRelatedInvoices(caseRTIdList, invoiceNuList, eanNuList, statusListQueja, statusListODS);
            
            for(ALK_Invoice__c i : relatedInvoiceList) {
                posts.add(new FeedItem(ParentId = i.ALK_Case__c, Body=String.format(System.Label.ALK_Related_Pak_Closed_Reason, new string[]{caseNumberMap.get(i.Name+i.ALK_EAN__c)})));
                relatedCaseIdClosedReasonMap.put(i.ALK_Case__c,
                                                caseApprovalNumberMap.get(i.Name+i.ALK_EAN__c).startsWithIgnoreCase('AP') 
                                                ? 'A FAVOR DE CLIENTE ASUME ALKOSTO'
                                                : 'A FAVOR DE CLIENTE ASUME MARCA');
                relatedCaseIdClosedStateMap.put(i.ALK_Case__c,
                                                i.ALK_Case__r.RecordType.DeveloperName == 'ALK_ODS' 
                                                ? 'Solución al Cliente;Entregado Bono Cambio'
                                                : 'Cerrado');
            }
            
            for(Case c : [Select Id, Status, Sub_Estado__c , RecordType.DeveloperName, ALK_Motivo_de_Cierre__c From Case Where Id = :relatedCaseIdClosedReasonMap.keySet()]) {
            	String[] status = relatedCaseIdClosedStateMap.get(c.Id).split(';');
                System.debug('status=>'+status);
                System.debug('RecordType.DeveloperName=>'+c.RecordType.DeveloperName);
                
                c.Status = status[0];
                if(c.RecordType.DeveloperName == 'ALK_ODS') {
                    c.Sub_Estado__c = status[1];	                    
                }
                c.ALK_Motivo_de_Cierre__c = relatedCaseIdClosedReasonMap.get(c.Id);
                
                casesToBeUpdated.add(c);
            } 
            
            for(Case c : [Select Id, ALK_Pak_Batch_Status__c From Case Where Id = :pakCaseIdList]) {
                c.ALK_Pak_Batch_Status__c = 'ODS/PQR Cerrados';
                
                casesToBeUpdated.add(c);                
            }
            
            if (casesToBeUpdated.size() > 0) {
	            update casesToBeUpdated;              
            } 

            if (posts.size() > 0) {
                insert posts;             
            }                         
        }
    }
   
    private List<ALK_Invoice__c> getRelatedInvoices(List<String> caseRTIdList, List<String> invoiceNuList, List<String> eanNuList, List<String> statusListQueja, List<String> statusListODS) {
        List<ALK_Invoice__c> result = new List<ALK_Invoice__c>();
        
        for(ALK_Invoice__c i : [SELECT Name, ALK_Case__c, ALK_EAN__c, ALK_Case__r.ALK_Approval_Number__c,ALK_Case__r.Status, ALK_Case__r.RecordType.DeveloperName
                From ALK_Invoice__c                                 
                Where ALK_Case__r.RecordTypeId = :caseRTIdList AND                                
                Name = :invoiceNuList AND                                
                                ALK_EAN__c = :eanNuList]) {
                                    if ((i.ALK_Case__r.RecordType.DeveloperName == 'ALK_ODS') && (!statusListODS.contains(i.ALK_Case__r.Status))) {
                                    	result.add(i);    
                                    } else if((i.ALK_Case__r.RecordType.DeveloperName != 'ALK_ODS') && (statusListQueja.contains(i.ALK_Case__r.Status))) {
                                    	result.add(i);                                            
                                    }
                                }
        return result;
    }
    
    protected override String getBatchName() {
        return 'Close related Pak\'s ODS and PQR';
    }         
}