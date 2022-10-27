public with sharing class ALK_ProductDetailCalloutResponseWrapper {
    public String status = '';
    public Integer statusCode = 0;
    public Boolean isSucceeded = false; 
    public ALK_ProductDetailWrapper detail = new ALK_ProductDetailWrapper();
    
    public class ALK_ProductDetailWrapper {
        @AuraEnabled
        public String SETID = '';
        @AuraEnabled
        public String productId = '';
        @AuraEnabled
        public String description = '';
        @AuraEnabled
        public String groupCode = '';
        @AuraEnabled
        public String groupDescription = '';
        @AuraEnabled
        public String divisionCode = '';
        @AuraEnabled
        public String divisionDescription = '';
        @AuraEnabled
        public String lineCode = '';
        @AuraEnabled
        public String lineDescription = '';
        @AuraEnabled
        public String subLineCode = '';
        @AuraEnabled
        public String subLineDescription = '';
        @AuraEnabled
        public String categoryCode = '';
        @AuraEnabled
        public String categoryDescription = '';
        @AuraEnabled
        public String subCategoryCode = '';
        @AuraEnabled
        public String subCategoryDescription = '';
        @AuraEnabled
        public String familyCode = '';
        @AuraEnabled
        public String familyDescription = '';
        @AuraEnabled
        public String brandCode = '';
        @AuraEnabled
        public String brandDescription = '';
	}    
}