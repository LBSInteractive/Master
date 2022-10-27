public with sharing class ALK_VicidialService {

    @InvocableMethod
    public static List<String> doExternalCall(List<ALK_ExternalCallParams> params) {
        if(params == null || params.size() == 0) {
            throw new ALK_VicidialServiceException('Agent, phone and case numbers need to be provided.');
        }

        if(String.isEmpty(params[0].agentUserNo)) {
            throw new ALK_VicidialServiceException('A valid agent identification needs to be provided. agentUserNo param cannot be empty!');
        }

        if(String.isEmpty(params[0].phoneNumber)) {
            throw new ALK_VicidialServiceException('A valid phone number needs to be provided. phoneNumber param cannot be empty!');
        }

        if(String.isEmpty(params[0].caseNumber)) {
            throw new ALK_VicidialServiceException('A valid case number needs to be provided. caseNumber param cannot be empty!');
        }  
        
        ALK_VicidialCalloutRequestWrapper request = new ALK_VicidialCalloutRequestWrapper();
        request.agentUserNo = params[0].agentUserNo;
        request.phoneNumber = params[0].phoneNumber;
        request.caseNumber = params[0].caseNumber;
            
        ALK_VicidialCalloutResponseWrapper response = new ALK_VicidialCallout().doACall(request);
        
        ALK_VicidialService.checkIntegrationRequestResult(response.statusCode, response.status);
                        
        return new String[]{response.leadId};        
    }
    
    private static void checkIntegrationRequestResult(Integer statusCode, String status) {
        if (statusCode != 201 && statusCode != 200) {
            throw new ALK_VicidialServiceException(String.format('The Vicidial integration didn\'t work properly and result status code {0} and status {1}.',
                                                            new String[]{String.valueOf(statusCode), status}));
        }        
    }    
    
    public class ALK_VicidialServiceException Extends Exception {}
    
    public class ALK_ExternalCallParams {
        @InvocableVariable
        public String agentUserNo;
        @InvocableVariable
        public String phoneNumber;
        @InvocableVariable
        public String caseNumber;
    }
}