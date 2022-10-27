@isTest public class ALK_RMAServiceTest {
	@testSetup
    public static void setUp() {        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;        
    }
    
    @isTest public static void createRMASuccess() {
        ALK_RMACalloutResponseWrapper.ALK_RMAResponseWrapper response;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpRMACalloutMockSuccess());
        
        Test.startTest();
        ALK_RMACalloutRequestWrapper request = new ALK_RMACalloutRequestWrapper();
        request.businessUnit = 'AKCA2';
        request.invoice = '20630010065629';
        request.orderNo = 'END0091033';
        request.custId = '67041284';
        request.estReturnDt = '2021/04/08';
        request.reasonCd = 'REC_AR_CA';    
        request.returnToIbu = 'AKCAL';
        request.oprid = '80082422';
        request.oprid2 = '80082422';
        request.carrierId = 'COOR-00';
        request.addressSeqNum = 'KR 26 P3 # 96 - 81 PI 2';
        request.invItemId = '7704353422887';
        request.qty = 1;
        request.ckComments = 'test lady';
        request.rmaStatus = 'O';
        request.emailTo = 'faley0207@hotmail.com';        
   		response = ALK_RMAService.createRMA(request);
        Test.stopTest();
        
        System.assertEquals('1234567', response.rmaNumber);
    }     
    
    
    @isTest public static void searchDispatchSuccess() {
        ALK_DispatchCalloutResponseWrapper.ALK_DispatchWrapper dispatch = null;
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpDispatchCalloutMockSuccess());
        
        Test.startTest();
   		dispatch = ALK_RMAService.searchDispatch('W1290001008679');
        Test.stopTest();
        
        System.assertEquals('W1290001008679', dispatch.noFactura);
    } 

    @isTest public static void createRMAFail() {
        try {      
            ALK_RMACalloutResponseWrapper.ALK_RMAResponseWrapper response;
            // Set mock callout class success result. 
            Test.setMock(HttpCalloutMock.class, new ALK_HttpRMACalloutMockFail());
            
            ALK_RMACalloutRequestWrapper request = new ALK_RMACalloutRequestWrapper();
            request.businessUnit = 'AKCA2';
            request.invoice = '20630010065629';
            request.orderNo = 'END0091033';
            request.custId = '67041284';
            request.estReturnDt = '2021/04/08';
            request.reasonCd = 'REC_AR_CA';    
            request.returnToIbu = 'AKCAL';
            request.oprid = '80082422';
            request.oprid2 = '80082422';
            request.carrierId = 'COOR-00';
            request.addressSeqNum = 'KR 26 P3 # 96 - 81 PI 2';
            request.invItemId = '7704353422887';
            request.qty = 1;
            request.ckComments = 'test lady';
            request.rmaStatus = 'O';
            request.emailTo = 'faley0207@hotmail.com';   
            
            response = ALK_RMAService.createRMA(request);       
        } catch(Exception ex) {
            System.assertEquals('ALK_RMAService.ALK_RMAServiceException', EX.getTypeName());
        }            
    }     
}