public with sharing class ALK_RMACalloutResponseWrapper {
    public String status = '';
    public Integer statusCode = 0;
    public Boolean isSucceeded = false;
    public ALK_RMAResponseWrapper response;
    
    public class ALK_RMAResponseWrapper {
        @AuraEnabled
        public String rmaNumber='';
        @AuraEnabled
        public String ErrorCode = '';
        @AuraEnabled
        public String ErrorDescription = '';        
    }
}