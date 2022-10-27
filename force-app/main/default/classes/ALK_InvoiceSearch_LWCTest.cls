@isTest public class ALK_InvoiceSearch_LWCTest {
    
    @testSetup
    public static void setUp() {        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;        
        
        Schema.Location testLocation = new Schema.Location(Name='Test Location',
                                                           ALK_Unidad_de_Venta__c = 'Test');
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
        
        Schema.Location lcT = new Schema.Location(ALK_Unidad_de_Venta__c='AKB68',Name='AKB68',LocationType='Bogota');
        insert lcT;
        
        Case cas = new Case (AccountId = a.Id, STATUS = 'New', Origin = 'Homepage',ALK_INVOICE_TYPE__c='RMA');
        insert cas;
    }
    
    @isTest public static void searchInvoiceTestSuccess() {
        
        List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> invoices = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceCalloutMockSuccess());
        
        Test.startTest();
        Date startDate = Date.today();
        Date endDate = startDate.addDays(10);
        invoices = ALK_InvoiceSearch_LWC.searchInvoice('t',startDate,endDate);
        Test.stopTest();
        
        System.assertEquals(1, invoices.size());
        
        
    }
    
    @isTest public static void searchInvoiceDetailTestSuccess() {
        
        List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> invoices = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceDetailCalloutMockSuccess());
        
        Test.startTest();
        List<Schema.Location> locationList = [SELECT ID, ALK_Unidad_de_Venta__c FROM Location LIMIT 1];
        invoices = ALK_InvoiceSearch_LWC.searchInvoiceDetail('Test',locationList[0].ID);
        Test.stopTest();
        
        System.assertEquals(1, invoices.size());
        
    }
    
    //Edit by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com
    //Now the ALK_InvoiceSearch_LWC.searchInvoiceDetail supports the location field in null
    @isTest public static void searchInvoiceDetailTestFail() {
        
        List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> invoices = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceDetailCalloutMockSuccess());
        
        Test.startTest();
        invoices = ALK_InvoiceSearch_LWC.searchInvoiceDetail('Test',null);
        Test.stopTest();
        
        System.assertEquals(1, invoices.size());
        
    }
    //Created by Daniel Guillermo Murcia Suarez -DGMS- daniel.murcia@globant.com
    //Method to add coverage to the class ALK_InvoiceSearch_LWC - assignInvoice
    @isTest public static void assignInvoiceTest() {
        // Set string JsonData
        String jsonData='[{	"brandCode": "TEST BRAND",	"brandDescription": " TEST BRAND DCR",	"categoryCode": "0000",	"categoryDescription": "TEST","description": "TEST ALK","divisionCode": "TEST",	"divisionDescription": "Servicios",	"familyCode": "789","familyDescription": "TEST","groupCode": "TEST","groupDescription": "TEST GR DESC",	"lineCode": "00","lineDescription": "LN DESC TEST","productId": "00112233",	"SETID": "TESTID",	"subCategoryCode": "62B00",	"subCategoryDescription": "TESTSUBC","subLineCode": "00A","subLineDescription": "Bonos","eanCode": "001122","address": "TEST",	"businessUnit": "AKB68","category": "TESTCAT",	"devolutionNumber": "0020001",	"ean": "001122",	"invoiceNumber": "123456789","key": "00221133665544778899","provider": "102547896","salesType": "return-void","user": " A001202","invoice": "123456789",	"descr": "BONOS ALKOSTO","location": "AKB68","business_unit": "AKB68","opendate": "2022-01-01","devolutionDate":"01/06/2022 20:08:28",	"qty": 1,"total": 25000,"nit_comprador": "123456","nombre_comprador": "TEST NAME COMP","phone_comprador": "3000000000","cliente_envio": "TESCLENV","pedido": "TESTPED"}]';
        Test.startTest();
        List<Case> lstCase = [SELECT Id FROM Case LIMIT 1];
        ALK_InvoiceSearch_LWC.assignInvoice(jsonData,lstCase[0].Id);
        Test.stopTest();
        List<ALK_Invoice__c> lstInvResp= new List<ALK_Invoice__c>([SELECT Id,Name FROM ALK_Invoice__c LIMIT 1]);
        System.assertEquals(1, lstInvResp.size());
        
    } 
    
    @isTest public static void assignInvoiceRMATst() {
        // Set string JsonData
        String jsonData='[{"invoice":"W1290001008679","qty":1,"unidadVenta":"AKB68","unidadRecoge":"AKB68","noGuia":"","noRMA":"RMA9167520","motivoRma":"RecogidaporFallaTécnica","estado":"Solicitado","ultimaObservacion":"last obs","direccion":"DG62ASUR#19B-80CS","ciudad":"BOGOTÁD.C.","telefono":"","transportador":"VendedorRecoge","fechaCreacionRma":"01/03/2022","fechaProgramadaRecogida":"2022-03-03","observacionesPS":"other ob","grupo":"Pendiente por validar","provedor":"Pendiente por validar","marca":"test ALK"}]';
        Test.startTest();        
        List<Case> lstCase = [SELECT Id FROM Case LIMIT 1];
        ALK_InvoiceSearch_LWC.assignInvoiceRMA(jsonData,lstCase[0].Id);
        Test.stopTest();
        List<ALK_Invoice__c> lstInvResp= new List<ALK_Invoice__c>([SELECT Id,Name FROM ALK_Invoice__c LIMIT 1]);
        System.assertEquals(1, lstInvResp.size());
        
    }
    @isTest public static void assignInvoiceDesTst() {
        // Set string JsonData
        String jsonData='[{"address":"ELECT.","businessUnit":"AKB68","category":"ELECT.ELE04.29.292.2923.29230.2923000000.","description":"EstPNYÑ","devolutionDate":"03/03/2022 12:24:02","devolutionNumber":"0040051300413049","ean":"7706060012511","invoiceNumber":"W1290001008679","key":"0303202212240200040051000000012565","provider":"8002418105","reason":"113-Falla Producto","salesType":"return","user":"300413049","brandCode":"ABBA","brandDescription":"Industria De Electrodomesticos S.A.S","categoryCode":"2923","categoryDescription":"Mixtas","divisionCode":"ELE04","divisionDescription":"Grandes Electrodomesticos","familyCode":"2923000000","familyDescription":"Mixtas","groupCode":"ELECT","groupDescription":"Electronica","lineCode":"29","lineDescription":"Coccion","productId":"7706060012511","SETID":"COLCO","subCategoryCode":"29230","subCategoryDescription":"Mixtas","subLineCode":"292","subLineDescription":"Estufas De Piso","invoice":"W1290001008679","descripcion":"EstPisoABB?","unidadVenta":"AKB68","fechaFactura":"26/01/2022","qty":1,"noDespacho":"END0322844","unidadDespacho":"AKCED","tipoDespacho":"Despachos a la dirección","documentoFactura":"11406002","clienteFactura":"Rojas Gutierrez Jose Reinaldo","noLinea":1,"transportador":"ABBA","observacionesPS":"J0-3105727256 ACACIAS SUR","noPedido":null,"noConsigment":null,"canal":"","documentoEnvio":"11406002","clienteEnvio":"Rojas Gutierrez Jose Reinaldo","valor":1165900,"gestionDespacho":0,"reexpedicion":"NO","direccion":"DG 62 A SUR # 19 B - 80 CS","fechaReprogramada":null,"fechaDespacho":"27/01/2022","fechaPactada":"2022-01-01","fechaReal":null,"fechaUltimoEstado":null,"estado":"","noGuia":" ","link":"https://www.google.com/","telefono":"3105727256","ciudad":"BOGOTÁ D.C.","unidadRecoge":"AKCED","fechaProgramadaRecogida":"","ultimaObservacion":"null"}]';
        Test.startTest();        
        List<Case> lstCase = [SELECT Id FROM Case LIMIT 1];
        ALK_InvoiceSearch_LWC.assignInvoiceDes(jsonData,lstCase[0].Id);
        Test.stopTest();
        List<ALK_Invoice__c> lstInvResp= new List<ALK_Invoice__c>([SELECT Id,Name FROM ALK_Invoice__c LIMIT 1]);
        System.assertEquals(1, lstInvResp.size());
        
    }
    
    @isTest public static void searchInvoiceDetailRMATst() {
        List<ALK_InvoiceCalloutResponseWrapper.ALK_InvoiceWrapper> invoices = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpInvoiceDetailCalloutMockSuccess());        
        Test.startTest();
        List<Schema.Location> locationList = [SELECT ID, ALK_Unidad_de_Venta__c FROM Location LIMIT 1];
        invoices = ALK_InvoiceSearch_LWC.searchInvoiceDetailRMA('Test');
        Test.stopTest();        
        System.assertEquals(1, invoices.size());
        
    }
    
    @isTest public static void searchRMATst() {        
        string responseFnl= null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpDispatchCalloutMockSuccess());        
        Test.startTest();
        List<Schema.Location> locationList = [SELECT ID, ALK_Unidad_de_Venta__c FROM Location LIMIT 1];
        responseFnl = ALK_InvoiceSearch_LWC.searchRMA('Test');
        Test.stopTest();        
        System.assertEquals(true, string.isNotEmpty(responseFnl));
        
    }
    
    @isTest public static void getIdentificationTst() {        
        String docNum;
        Test.startTest();
        List<Case> lstCase = [SELECT Id FROM Case LIMIT 1];
        List<Account> lstAcnt = [SELECT Id FROM Account LIMIT 1];
        docNum = ALK_InvoiceSearch_LWC.getIdentification(lstCase[0].Id);
        docNum = ALK_InvoiceSearch_LWC.getIdentification(lstAcnt[0].Id);
        Test.stopTest();        
        System.assertEquals(true,String.isNotEmpty(docNum));        
    }    
}