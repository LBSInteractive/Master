@isTest public class ALK_AccountServiceTest {
    @testSetup public static void setUp() {        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;        
    }
    
    @isTest public static void searchAccountIntegrationSuccess() {
		Account a = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAccountCalloutMockSuccess());
        
        Test.startTest();
   		a = ALK_AccountService.searchAccount('8909009431');
        Test.stopTest();
        
        System.assert(a==null);
    } 
    
    @isTest public static void searchAccountIntegrationSuccess2() {
		List<String> result = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAccountCalloutMockSuccess());
        
        Test.startTest();
        result = ALK_AccountService.searchAccount(new List<String>{'8909009431'});
        Test.stopTest();
        
        System.assert(result.size() == 0);
    }     
    
    @isTest public static void searchAccountFail() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAccountCalloutMockFail());
        
               
        try {
            Test.startTest(); 
            ALK_AccountService.searchAccount('8909009431'); 
                    Test.stopTest();
        } catch(Exception ex) {
            System.assertEquals('ALK_AccountService.ALK_AccountServiceException', EX.getTypeName());
        }     
    }  
    
    @isTest public static void searchAccountException() {        
        try {
            ALK_AccountService.searchAccount('');          
        } catch(Exception ex) {
            System.assertEquals('ALK_AccountService.ALK_AccountServiceException', EX.getTypeName());
        }     
    }

    @isTest public static void searchAccountException2() {        
        try {
            ALK_AccountService.searchAccount(new List<String>());          
        } catch(Exception ex) {
            System.assertEquals('ALK_AccountService.ALK_AccountServiceException', EX.getTypeName());
        }     
    }     
    
    @isTest public static void searchAccountSFSuccess() {
        Account a = new Account(FirstName = 'Test', 
                                LastName='Test',
                                ALK_Identification_Number__c = '8909009431',
                                RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        
        insert a;
        
        Account b = null;
        
        Test.startTest();
        b = ALK_AccountService.searchAccount('8909009431');
        Test.stopTest();
        
        System.assertEquals(a.Id,b.Id);
    }
    
    @isTest public static void searchAddressIntegrationSuccess() {
		List<ALK_AddressSearchCalloutResponseWrapper.ALK_AddressWrapper> addresses = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAddressSearchCalloutMockSuccess());
        
        Test.startTest();
   		addresses = ALK_AccountService.searchAddress('8909009431');
        Test.stopTest();
        
        System.assert(addresses.size() > 0);
    }   
    
    @isTest public static void searchAddressFail() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAddressSearchCalloutMockFail());
        
               
        try {
            Test.startTest(); 
            ALK_AccountService.searchAddress('8909009431');
                    Test.stopTest();
        } catch(Exception ex) {
            System.assertEquals('ALK_AccountService.ALK_AccountServiceException', EX.getTypeName());
        } 
        
        try {
            ALK_AccountService.searchAddress('');
        } catch(Exception ex) {
            System.assertEquals('ALK_AccountService.ALK_AccountServiceException', EX.getTypeName());
        }        
    }  

    @isTest public static void createAddressIntegrationSuccess() {
		ALK_AddressCreateCalloutResponseWrapper.AddressCreationStatusWrapper addressCreationStatus = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAddressCreateCalloutMockSuccess());
        
        Test.startTest();
   		addressCreationStatus = ALK_AccountService.createAddress('8909009431','BLBA BLA','BOGOTA','ANTIOQUIA');
        Test.stopTest();
        
        System.assert(addressCreationStatus != null);
    }   
    
    @isTest public static void createAddressFail() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAddressCreateCalloutMockFail());
        
               
        try {
            Test.startTest(); 
            ALK_AccountService.createAddress('8909009431','BLBA BLA','BOGOTA','ANTIOQUIA');
            Test.stopTest();
        } catch(Exception ex) {
            System.assertEquals('ALK_AccountService.ALK_AccountServiceException', EX.getTypeName());
        }  
        
        try {
            ALK_AccountService.createAddress('','BLBA BLA','BOGOTA','ANTIOQUIA');
        } catch(Exception ex) {
            System.assertEquals('ALK_AccountService.ALK_AccountServiceException', EX.getTypeName());
        }
        
        try {
            ALK_AccountService.createAddress('8909009431','','BOGOTA','ANTIOQUIA');
        } catch(Exception ex) {
            System.assertEquals('ALK_AccountService.ALK_AccountServiceException', EX.getTypeName());
        }        
        
        try {
            ALK_AccountService.createAddress('8909009431','BLBA BLA','','ANTIOQUIA');
        } catch(Exception ex) {
            System.assertEquals('ALK_AccountService.ALK_AccountServiceException', EX.getTypeName());
        }         
        
        try {
            ALK_AccountService.createAddress('8909009431','BLBA BLA','BOGOTA','');
        } catch(Exception ex) {
            System.assertEquals('ALK_AccountService.ALK_AccountServiceException', EX.getTypeName());
        }         
        
    }     
}