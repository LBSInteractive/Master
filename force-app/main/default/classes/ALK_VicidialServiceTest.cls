@isTest public class ALK_VicidialServiceTest {
	@testSetup
    public static void setUp() {        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        calloutConfigsParams.ALK_timeout__c = 120000;
        calloutConfigsParams.Name = 'Teste 120000';
        
        insert calloutConfigsParams;        
    }
    
    @isTest public static void doACallSuccess() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpVicidialCalloutMockSuccess());        
        
        List<String> leadId = new List<String>();
        
        Test.startTest();    
        ALK_VicidialService.ALK_ExternalCallParams params = new ALK_VicidialService.ALK_ExternalCallParams();
        params.agentUserNo = '48600';
        params.phoneNumber = '3106883866';
        params.caseNumber = '123456789';
        
        leadId = ALK_VicidialService.doExternalCall(new List<ALK_VicidialService.ALK_ExternalCallParams>{params});        
        Test.stopTest();
        
        System.assertEquals('1234567890', leadId[0]);
    } 

    @isTest public static void doACallFail() {
        // Set mock callout class success result. 
        Test.setMock(HttpCalloutMock.class, new ALK_HttpVicidialCalloutMockFail());
        
        try {
            Test.startTest();
            ALK_VicidialService.ALK_ExternalCallParams params = new ALK_VicidialService.ALK_ExternalCallParams();
            params.agentUserNo = '48600';
            params.phoneNumber = '3106883866';
            params.caseNumber = '123456789';            
            ALK_VicidialService.doExternalCall(new List<ALK_VicidialService.ALK_ExternalCallParams>{params});
            Test.stopTest();            
        } catch(Exception ex) {
            System.assertEquals('ALK_VicidialService.ALK_VicidialServiceException', EX.getTypeName());
        }
        
        try {      
            ALK_VicidialService.ALK_ExternalCallParams params = new ALK_VicidialService.ALK_ExternalCallParams();
            params.agentUserNo = '';
            params.phoneNumber = '3106883866';
            params.caseNumber = '123456789';            
            ALK_VicidialService.doExternalCall(new List<ALK_VicidialService.ALK_ExternalCallParams>{params});          
        } catch(Exception ex) {
            System.assertEquals('ALK_VicidialService.ALK_VicidialServiceException', EX.getTypeName());
        }           

        try {      
            ALK_VicidialService.ALK_ExternalCallParams params = new ALK_VicidialService.ALK_ExternalCallParams();
            params.agentUserNo = '48600';
            params.phoneNumber = '';
            params.caseNumber = '123456789';            
            ALK_VicidialService.doExternalCall(new List<ALK_VicidialService.ALK_ExternalCallParams>{params});          
        } catch(Exception ex) {
            System.assertEquals('ALK_VicidialService.ALK_VicidialServiceException', EX.getTypeName());
        }  
        
        try {      
            ALK_VicidialService.ALK_ExternalCallParams params = new ALK_VicidialService.ALK_ExternalCallParams();
            params.agentUserNo = '123456';
            params.phoneNumber = '3106883866';
            params.caseNumber = '';            
            ALK_VicidialService.doExternalCall(new List<ALK_VicidialService.ALK_ExternalCallParams>{params});          
        } catch(Exception ex) {
            System.assertEquals('ALK_VicidialService.ALK_VicidialServiceException', EX.getTypeName());
        }            
    }      
}