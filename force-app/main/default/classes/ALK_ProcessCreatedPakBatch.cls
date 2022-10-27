public without sharing class ALK_ProcessCreatedPakBatch extends ALK_StandardBatch {    
    public List<ALK_Invoice__c> start(Database.BatchableContext BC){
        List<ALK_Invoice__c> scope = [SELECT Id,
                NAME,
                ALK_EAN__c,
                ALK_Case__c
                From ALK_Invoice__c 
                Where ALK_Case__r.ALK_Pak_Batch_Status__c = 'No procesado' AND
                ALK_Case__r.RecordTypeId = :Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_PAK').getRecordTypeId()];
        
        return scope;
    }
    
    public void execute(Database.BatchableContext BC, List<ALK_Invoice__c> scope){
        List<String> invoiceNuList = new List<String>();
        List<String> eanNuList = new List<String>();
        Map<String,Case> pakCaseMap = new Map<String,Case>();
                
        if (scope.size() > 0) {
            
            for(ALK_Invoice__c i : scope) {
                invoiceNuList.add(i.Name);
                eanNuList.add(i.ALK_EAN__c);
                pakCaseMap.put(i.ALK_Case__c,null);
            }            
            this.updatePakCaseMap(pakCaseMap);

            Map<String,String> odsByPakCaseIdList = 
                this.getRelatedInvoiceByInvoiceAndProductNum(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_ODS').getRecordTypeId(), 
                                                new Map<String,String>(), 
                                                invoiceNuList, 
                                                eanNuList);
            
            Map<String,String> pqrQuejaByPakCaseIdList = 
                this.getRelatedInvoiceByInvoiceAndProductNum(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_QUEJA').getRecordTypeId(), 
                                                new Map<String,String>(), 
                                                invoiceNuList, 
                                                eanNuList);

            Map<String,String> pqrSolicitudByPakCaseIdList = 
                this.getRelatedInvoiceByInvoiceAndProductNum(Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_SOLICITUD').getRecordTypeId(), 
                                                pqrQuejaByPakCaseIdList, 
                                                invoiceNuList, 
                                                eanNuList); 
            
            for(ALK_Invoice__c i : Scope) {
                String key = i.Name+i.ALK_EAN__c;
                
                if (odsByPakCaseIdList.containsKey(key)) {
                    pakCaseMap.get(i.ALK_Case__c).ALK_Related_ODS__c = odsByPakCaseIdList.get(key);
                }
                
                if (pqrQuejaByPakCaseIdList.containsKey(key)) {
                    pakCaseMap.get(i.ALK_Case__c).ALK_Related_PQR__c = pqrQuejaByPakCaseIdList.get(key);
                }

                if (pqrSolicitudByPakCaseIdList.containsKey(key)) {
                    pakCaseMap.get(i.ALK_Case__c).ALK_Related_PQR__c = pqrSolicitudByPakCaseIdList.get(key);
                }

				pakCaseMap.get(i.ALK_Case__c).ALK_Pak_Batch_Status__c = 'ODS/PQR relacionados';               
            }
            
            update pakCaseMap.values();
        }
    }
     
    private void updatePakCaseMap(Map<String,Case> packCaseMap) {
         for(Case c : [SELECT Id, ParentId, ALK_Related_ODS__c, ALK_Pak_Batch_Status__c From Case Where Id = :packCaseMap.keyset()]) {
             packCaseMap.put(c.Id, c);
         }        
    }
    
    private Map<String,String> getRelatedInvoiceByInvoiceAndProductNum(String caseRTId, Map<String, String> ignoredMap, List<String> invoiceNuList, List<String> eanNuList) {
        Map<String,String> result = new Map<String,String>();
        
        for(ALK_Invoice__c i : [SELECT ALK_Case__c,
                                Name, 
                                ALK_EAN__c 
                                From ALK_Invoice__c 
                                Where ALK_Case__r.Status <> 'Closed' AND 
                                ALK_Case__r.RecordTypeId = :caseRTId AND
                                Name = :invoiceNuList AND
                                ALK_EAN__c = :eanNuList
                                ORDER BY ALK_Case__r.CreatedDate desc]) {
                                    String key = i.Name + i.ALK_EAN__c;
                                    
                                    if(!ignoredMap.containsKey(key) && !result.containsKey(key)) {
                                        result.put(key,i.ALK_Case__c);
                                    }
        }

        return result;
    }
    
    protected override String getBatchName() {
        return 'Update ODS and PQR on Pak Creation';
    }     
}