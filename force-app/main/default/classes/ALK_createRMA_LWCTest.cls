/***********************************************************************************************************************
*   Author: Daniel Murcia Suarez daniel.murcia@abbott.com
*   Description: test class by ALK_createRMA_LWC class
*   Date : 05-08-2022
**
* -------------------------------------
*            No.    Date           Author                           Description      
*            ----   ----------     ---------------------------     -------------    
* @version   1.1     05-08-2022   Daniel Murcia Suarez DGMS        Creation on the class         
**************************************************************************************************************************/
@isTest public class ALK_createRMA_LWCTest {
    
    @testSetup
    public static void setUp() {     
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';        
        insert calloutConfigsParams;        
        
        Schema.Location testLocation = new Schema.Location(Name='Test Location',ALK_Unidad_de_Venta__c = 'Test');
        insert testLocation;
        
        Account a = new Account(FirstName = 'testAccountSA', 
                                LastName = 'Last', 
                                PersonEmail='test@test.com',
                                Phone='573005716885',
                                ALK_WHATSAPP__c = true,
                                ALK_SMS__c = false,
                                ALK_EMAIL__c = false,
                                ALK_Identification_Number__c='SFDCDOC1234',
                                RecordTypeId= Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId());
        insert a; 
        
        Schema.Location lcT = new Schema.Location(ALK_Unidad_de_Venta__c='AKB68',Name='AKB68',LocationType='Bogota',ALK_pickup__c=true);
        insert lcT;
        
        Case cas = new Case (AccountId = a.Id, 
                             STATUS = 'New',
                             Origin = 'Homepage',
                             ALK_INVOICE_TYPE__c='Producto',
                             RecordTypeId= Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ALK_QUEJA').getRecordTypeId());
        insert cas; 
        
        String jsonData='[{	"brandCode": "TEST BRAND",	"brandDescription": " TEST BRAND DCR",	"categoryCode": "0000",	"categoryDescription": "TEST","description": "TEST ALK","divisionCode": "TEST",	"divisionDescription": "Servicios",	"familyCode": "789","familyDescription": "TEST","groupCode": "TEST","groupDescription": "TEST GR DESC",	"lineCode": "00","lineDescription": "LN DESC TEST","productId": "00112233",	"SETID": "TESTID",	"subCategoryCode": "62B00",	"subCategoryDescription": "TESTSUBC","subLineCode": "00A","subLineDescription": "Bonos","eanCode": "001122","address": "TEST",	"businessUnit": "AKB68","category": "TESTCAT",	"devolutionNumber": "0020001",	"ean": "001122",	"invoiceNumber": "VEN23456789","key": "00221133665544778899","provider": "102547896","salesType": "return-void","user": " A001202","invoice": "123456789",	"descr": "BONOS ALKOSTO","location": "AKB68","business_unit": "AKB68","opendate": "2022-01-04","devolutionDate":"01/06/2022 20:08:28",	"qty": 1,"total": 25000,"nit_comprador": "123456","nombre_comprador": "TEST NAME COMP","phone_comprador": "573005716885","cliente_envio": "TESCLENV","pedido": "VEN23456789"}]';
        ALK_InvoiceSearch_LWC.assignInvoice(jsonData,cas.Id); 
        List<ALK_Invoice__c> lstInvResp= new List<ALK_Invoice__c>([SELECT Id,Name FROM ALK_Invoice__c LIMIT 1]);
        
        ALK_State__c state = new ALK_State__c (Name='Bogotá',ALK_State_Code__c='11');
        insert state;
        
        ALK_City__c city = new ALK_City__c (Name='Bogotá',ALK_State_Code__c='11001', ALK_State__c=state.Id);
        insert city;
    }
    
    //Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com
    //Method to add coverage to the class ALK_createRMA_LWC - searchInvoice
    @isTest public static void searchInvoiceTst() {
        Test.startTest();
        List<Case> lstCase = [SELECT Id FROM Case LIMIT 1];
         List<ALK_Invoice__c> listInv= new List<ALK_Invoice__c>();
        ALK_dataRMA_Wrapper.wrpDataResponse rspWrp= ALK_createRMA_LWC.searchInvoice(lstCase[0].Id);
        Test.stopTest();
        System.assertEquals(rspWrp.caseId, lstCase[0].Id);        
    }
    
    //Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com
    //Method to add coverage to the class ALK_createRMA_LWC - getAddressTst
    @isTest public static void getAddressTst() {
        List<ALK_AddressSearchCalloutResponseWrapper.ALK_AddressWrapper> addresses = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAddressSearchCalloutMockSuccess());        
        Test.startTest();
        addresses = ALK_createRMA_LWC.getAddress('8909009431');
        Test.stopTest();        
        System.assert(addresses.size() > 0);       
    }
    
    //Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com
    //Method to add coverage to the class ALK_createRMA_LWC - crtAddress
    @isTest public static void crtAddressTst() {
        ALK_AddressCreateCalloutResponseWrapper.AddressCreationStatusWrapper addressCreationStatus = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpAddressCreateCalloutMockSuccess());        
        Test.startTest();
        addressCreationStatus = ALK_createRMA_LWC.crtAddress('8909009431', 'CL 1 2 3', 'Bogotá', 'Bogotá');
        Test.stopTest();
        
        System.assert(addressCreationStatus != null);    
    }
    
    //Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com
    //Method to add coverage to the class ALK_createRMA_LWC - searchLocation, searchState, searchCity,searchRMAParameters
    @isTest public static void searchInfoTst() {     
        Test.startTest();
        List<Schema.Location> searchLocation= ALK_createRMA_LWC.searchLocation();
        List<ALK_State__c> searchState=ALK_createRMA_LWC.searchState();
        List<ALK_City__c> searchCity=ALK_createRMA_LWC.searchCity(searchState[0].Id);        
        List<ALK_RMA_Parameters__mdt> searchRMAParameters =ALK_createRMA_LWC.searchRMAParameters('Reason Pickup');
        Test.stopTest();
        System.assert(searchLocation.size()>0);  
        System.assert(searchState.size()>0);  
        System.assert(searchCity.size()>0);   
        System.assert(searchRMAParameters.size()>0);   
    }
    
    //Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com
    //Method to add coverage to the class ALK_createRMA_LWC - createRMA
    @isTest public static void createRMATst() {         
        ALK_RMACalloutResponseWrapper.ALK_RMAResponseWrapper response = null;
        string jsonInput='[{"businessUnit":"KTINT","invoice":"20630010065629","orderNo":"END0091033","custId":"80082422","estReturnDt":"2022-08-26","reasonCd":"REC_DÑ_IN","returnToIbu":"AKB68","oprid":"80082422","oprid2":"80082422","carrierId":"AAA-002","addressSeqNum":"5","invItemId":"7704353422887","qty":1,"ckComments":"TEST","rmaStatus":"P","emailTo":"test@alkosto.com"}]';
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpRMACalloutMockSuccess()); 
        List<Case> lstCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        response=ALK_createRMA_LWC.createRMA(jsonInput,lstCase[0].Id);
        Test.stopTest();
        System.assertEquals('1234567', response.rmaNumber);   
    }
    
    @isTest public static void createRMATstFail() {         
        ALK_RMACalloutResponseWrapper.ALK_RMAResponseWrapper response = null;
        string jsonInput='[{"businessUnit":"KTINT","invoice":"20630010065629","orderNo":"END0091033","custId":"80082422","estReturnDt":"2022-08-26","reasonCd":"REC_DÑ_IN","returnToIbu":"AKB68","oprid":"80082422","oprid2":"80082422","carrierId":"AAA-002","addressSeqNum":"5","invItemId":"7704353422887","qty":1,"ckComments":"TEST","rmaStatus":"P","emailTo":"test@alkosto.com"}]';
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpRMAFail()); 
        List<Case> lstCase = [SELECT Id FROM Case LIMIT 1];
        Test.startTest();
        response=ALK_createRMA_LWC.createRMA(jsonInput,lstCase[0].Id);
        Test.stopTest();
        List<FeedItem> lstFeedItem = [SELECT Id FROM FeedItem LIMIT 1];
        System.assert(lstFeedItem.size()>0);   
    }
    
    
}