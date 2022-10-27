public class ALK_AddressSearchCalloutResponseWrapper {
	public String status='';
	public Integer statusCode;
    public Boolean isSucceeded;
    @AuraEnabled    
    public List<ALK_AddressWrapper> address;
    
    public class ALK_AddressWrapper {
        @AuraEnabled        
        public String setId;
        @AuraEnabled        
        public String custId;
        @AuraEnabled        
        public String country;
        @AuraEnabled        
        public String state;
        @AuraEnabled        
        public String descr;
        @AuraEnabled        
        public String city;
        @AuraEnabled        
        public String county;
        @AuraEnabled        
        public String address1;
        @AuraEnabled        
        public String address2;
        @AuraEnabled        
        public String countryCode;
        @AuraEnabled        
        public String phone;
        @AuraEnabled        
        public String fax;
        @AuraEnabled        
        public Integer addressSeqNum;
        @AuraEnabled        
        public Boolean billToAddr;
        @AuraEnabled        
        public Boolean shipToAddr;
        @AuraEnabled        
        public Boolean soldToAddr;
    }
}