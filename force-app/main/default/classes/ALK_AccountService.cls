public with sharing class ALK_AccountService {
    @AuraEnabled
    public static Account searchAccount(String customerId) {
        if(String.isEmpty(customerId)) {
            throw new ALK_AccountServiceException('A valid customer identification needs to be provided. customerId param cannot be empty!');
        }        
        
        List<Account> result = [SELECT Id, Name From Account Where ALK_Identification_Number__c = :customerId WITH SECURITY_ENFORCED LIMIT 1];
        
        if (result.size() == 0) {
            result = [SELECT Id, Name From Account Where Id = :ALK_AccountService.importAccount(customerId) WITH SECURITY_ENFORCED];
        }
        
        return result.size() > 0 ? result[0] : null;
    }
    @invocableMethod
    public static List<String> searchAccount(List<String> customerId) {
        if(customerId == null || customerId.size() == 0) {
            throw new ALK_AccountServiceException('A valid customer identification needs to be provided. customerId param cannot be empty!');
        }        
        
        List<Account> result = [SELECT Id, Name From Account Where ALK_Identification_Number__c = :customerId[0] WITH SECURITY_ENFORCED LIMIT 1];
        
        if (result.size() == 0) {
            result = [SELECT Id, Name From Account Where Id = :ALK_AccountService.importAccount(customerId[0]) WITH SECURITY_ENFORCED];
        }
        
        return result.size() > 0 ? new List<string>{result[0].Id} : new List<String>();
    }

    public static List<ALK_AddressSearchCalloutResponseWrapper.ALK_AddressWrapper> searchAddress(string customerId) {
        if(String.isEmpty(customerId)) {
            throw new ALK_AccountServiceException('A valid customer identification needs to be provided. customerId param cannot be empty!');
        } 
        
        ALK_AddressSearchCallout callout = new ALK_AddressSearchCallout();
        
        ALK_AddressSearchCalloutResponseWrapper response = callout.getAddress(customerId);
        
        ALK_AccountService.checkIntegrationRequestResult(response.statusCode, response.status, 'Search account address');
        
        return response.address;
    }
    
    public static ALK_AddressCreateCalloutResponseWrapper.AddressCreationStatusWrapper CreateAddress(string customerId, string address, string city, string department) {
        if(String.isEmpty(customerId)) {
            throw new ALK_AccountServiceException('A valid customer identification needs to be provided. customerId param cannot be empty!');
        }

        if(String.isEmpty(address)) {
            throw new ALK_AccountServiceException('A valid customer address needs to be provided. address param cannot be empty!');
        }

        if(String.isEmpty(city)) {
            throw new ALK_AccountServiceException('A valid customer address city needs to be provided. city param cannot be empty!');
        }

        if(String.isEmpty(department)) {
            throw new ALK_AccountServiceException('A valid customer address department needs to be provided. department param cannot be empty!');
        }
        
        ALK_AddressCreateCallout callout = new ALK_AddressCreateCallout();
	
        ALK_AddressCreateCalloutRequestWrapper request = new ALK_AddressCreateCalloutRequestWrapper();
        request.customerId = customerId;
        request.address = address;
        request.city = city;
        request.department = department;
                
        ALK_AddressCreateCalloutResponseWrapper response = callout.addAddress(request);
        
        ALK_AccountService.checkIntegrationRequestResult(response.statusCode, response.status, 'Create account address');
        
        return response.addressCreationStatus;
    }     
    
    private static String importAccount(String customerId) {
        ALK_AccountCallout callout = new ALK_AccountCallout();
        
        ALK_AccountCalloutResponseWrapper response = callout.importAccount(customerId);
        
        ALK_AccountService.checkIntegrationRequestResult(response.statusCode, response.status, 'Search Account');

        return response.id;
    }
    
    private static void checkIntegrationRequestResult(Integer statusCode, String status, String integration) {
        if (statusCode != 200 && statusCode != 201 && statusCode != 404) {
            throw new ALK_AccountServiceException(String.format('The {0} integration didn\'t work properly and result status code {1} and status {2}.',
                                                            new String[]{integration, String.valueOf(statusCode), status}));
        }        
    }
    
    public class ALK_AccountServiceException extends Exception {}
}