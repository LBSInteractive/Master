/***********************************************************************************************************************
*   Author: Daniel Murcia Suarez daniel.murcia@abbott.com
*   Description: created this class as controller of the LWC create RMA
*   Date : 30-07-2022
*   Test Class: ALK_createRMA_LWCTest [Code Coverage: 90%]
**
* -------------------------------------
*            No.    Date           Author                           Description      
*            ----   ----------     ---------------------------     -------------    
* @version   1.1    30-07-2022   Daniel Murcia Suarez DGMS        Creation on the class         
**************************************************************************************************************************/
public without sharing class ALK_createRMA_LWC {
    
    @AuraEnabled
    public static ALK_dataRMA_Wrapper.wrpDataResponse searchInvoice(String caseId) {
        ALK_dataRMA_Wrapper.wrpDataResponse rmaWrp= new ALK_dataRMA_Wrapper.wrpDataResponse ();
        List<ALK_Invoice__c> listInv= new List<ALK_Invoice__c>();
        listInv=[SELECT Id, ALK_Case__r.Account.Name,ALK_EAN__c, ALK_Case__r.ALK_Person_Account_Email__c, Name,
                 ALK_Warehouse__r.ALK_Unidad_de_Venta__c, ALK_Quantity__c, ALK_Unit_Collects__c, ALK_Conveyor__c,ALK_Order_Number__c,
                 ALK_Dispatch_Number__c,ALK_RMA_Number__c, ALK_NIT_Send__c,ALK_Warehouse__r.Name,ALK_Purchaser_Name__c,
                 ALK_Case__c,ALK_NIT_Purchaser__c,recordType.DeveloperName
                 FROM ALK_Invoice__c 
                 WHERE ALK_Case__c=:caseId order by createdDate desc LIMIT 1 ];
        if (listInv!= null ) {
            String desVal=Label.ALK_desVal;
            String endVal=Label.ALK_endVal;
            String venVal=Label.ALK_venVal;
            String typeMngmt =label.ALK_typeMngmt;
            String frstValues='';
            for (ALK_Invoice__c invObj : listInv) {
                rmaWrp.invoiceId=invObj.Id;
                rmaWrp.caseId =invObj.ALK_Case__c;
                rmaWrp.EAN= invObj.ALK_EAN__c;
                rmaWrp.name=invObj.ALK_Purchaser_Name__c;
                rmaWrp.email=invObj.ALK_Case__r.ALK_Person_Account_Email__c;
                rmaWrp.invoiceNumber=invObj.Name;
                rmaWrp.saleStore=invObj.ALK_Warehouse__r.ALK_Unidad_de_Venta__c;
                rmaWrp.quantity=invObj.ALK_Quantity__c;
                rmaWrp.uCollect=invObj.ALK_Unit_Collects__c;
                rmaWrp.typeMngmt=typeMngmt;
                if (invObj.recordType.DeveloperName!= null){
                    if (invObj.recordType.DeveloperName ==Label.ALK_Invoice_RMA_Type) {
                        rmaWrp.noPedido=invObj.ALK_RMA_Number__c;
                        frstValues=getFristValues(invObj.ALK_RMA_Number__c);
                    }
                    else if (invObj.recordType.DeveloperName== Label.ALK_Invoice_PosVent_Type) {		
                        rmaWrp.noPedido=invObj.ALK_Order_Number__c;
                        frstValues=getFristValues(invObj.ALK_Order_Number__c);
                    }
                    else if (invObj.recordType.DeveloperName== Label.ALK_Invoice_Despacho_Type) {
                        rmaWrp.noPedido=invObj.ALK_Dispatch_Number__c;
                        frstValues=getFristValues(invObj.ALK_Dispatch_Number__c);                        
                    }
                    else {		 
                        rmaWrp.noPedido=invObj.ALK_Order_Number__c;
                        frstValues=getFristValues(invObj.ALK_Order_Number__c);
                    }
                }                
                if (frstValues.contains(desVal) || frstValues.contains(endVal)) {
                    rmaWrp.idNumber=invObj.ALK_NIT_Send__c;
                } else if(frstValues.contains(venVal)){
                    rmaWrp.idNumber=invObj.ALK_NIT_Purchaser__c;
                } else {
                    rmaWrp.idNumber=invObj.ALK_NIT_Purchaser__c;                    
                }
            }
        }
        System.debug('RMAwrp--> '+RMAwrp);
        return RMAwrp;
    }
    
    public static string getFristValues(String orderNum){
       return !String.isEmpty(orderNum) && orderNum.length() >= 3 ? orderNum.substring(0, 3) : '';
    }
    
    @AuraEnabled
    public static List<ALK_AddressSearchCalloutResponseWrapper.ALK_AddressWrapper> getAddress (String docNumber){
        return ALK_AccountService.searchAddress(docNumber);
    }
    
    @AuraEnabled
    public static ALK_AddressCreateCalloutResponseWrapper.AddressCreationStatusWrapper crtAddress (string customerId, string address, string city, string stateName){
        return ALK_AccountService.CreateAddress(customerId,address,city,stateName);
    }
    
    @AuraEnabled
    public static List<Schema.Location> searchLocation() {
        return [SELECT Id, Name,ALK_Unidad_de_Venta__c,ALK_pickup__c FROM Location WHERE ALK_pickup__c= true];
    }
    
    @AuraEnabled
    public static List<ALK_State__c> searchState() {
        return [Select Id, Name from ALK_State__c];
    }
    
    @AuraEnabled
    public static List<ALK_City__c> searchCity(String StateId) {
        return [Select ALK_State_Code__c, Name from ALK_City__c WHERE ALK_State__c=:stateId];
    }
    
    @AuraEnabled
    public static List<ALK_RMA_Parameters__mdt> searchRMAParameters (String filterStr) {
        return [Select MasterLabel , RMA_Label__c, Value__c from ALK_RMA_Parameters__mdt where MasterLabel=:filterStr];
    }
    
    @AuraEnabled
    public static ALK_RMACalloutResponseWrapper.ALK_RMAResponseWrapper createRMA (String jsonInput, String caseId) {
        List<ALK_RMACalloutRequestWrapper> lstRMACll= (List<ALK_RMACalloutRequestWrapper>) System.JSON.deserialize(jsonInput, List<ALK_RMACalloutRequestWrapper>.class);
        ALK_RMACalloutResponseWrapper.ALK_RMAResponseWrapper responseRMA=ALK_RMAService.createRMA(lstRMACll[0]);
        try{
            if (responseRMA.rmaNumber== null) {                
                string errorMsg='Error,' + responseRMA.ErrorCode + ' '+responseRMA.ErrorDescription;
                createPostChat(caseId , errorMsg);           
            }else {
                case relatedCase = [SELECT Id,ALK_RMA_Automatic__c,Status,Sub_Estado__c FROM Case WHERE Id=:caseId LIMIT 1];
                relatedCase.ALK_RMA_Automatic__c=responseRMA.rmaNumber;
                relatedCase.Status=Label.ALK_RMA_final_case_status;
                relatedCase.Sub_Estado__c=Label.ALK_RMA_final_case_sStatus;
                update relatedCase;
            }
        }catch(Exception e){
            throw new ALK_RMACreationException(e.getMessage());
        }
        return responseRMA;
    }
    
    public static void createPostChat(String recordId, string strMsg){
        FeedItem post = new FeedItem();
        post.ParentId = recordId;
        post.Body = strMsg;
        insert post;
    }
    
    public class ALK_RMACreationException extends Exception {}
}