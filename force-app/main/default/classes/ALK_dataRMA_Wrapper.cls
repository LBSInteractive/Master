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
public with sharing class ALK_dataRMA_Wrapper {
   
    public class wrpDataResponse {
        @AuraEnabled
        public String caseId = '';
        @AuraEnabled        
        public String invoiceId = ''; 
        @AuraEnabled        
        public String email = ''; 
        @AuraEnabled
        public String invoiceNumber = '';    
        @AuraEnabled
        public String EAN = '';  
        @AuraEnabled
        public String saleStore = '';  
        @AuraEnabled
        public String name = ''; 
        @AuraEnabled
        public String idNumber = '';   
        @AuraEnabled
        public String noPedido = ''; 
        @AuraEnabled
        public Decimal quantity = 0; 
        @AuraEnabled
        public String uCollect = '';    
        @AuraEnabled
        public String typeMngmt = '';               
    }
}