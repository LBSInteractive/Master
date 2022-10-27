public with sharing class ALK_AddressCreateCalloutResponseWrapper {
	public String status='';
	public Integer statusCode;
    public Boolean isSucceeded;
    public AddressCreationStatusWrapper addressCreationStatus;
    
    public class AddressCreationStatusWrapper {
        @AuraEnabled
        public Boolean isError;
        @AuraEnabled
        public String errorCode;
        @AuraEnabled
        public String errorMessage;           
    }
}