public with sharing class ALK_RMAService {
    public static ALK_RMACalloutResponseWrapper.ALK_RMAResponseWrapper createRMA(ALK_RMACalloutRequestWrapper request) {
        ALK_RMACallout callout = new ALK_RMACallout();
        ALK_RMACalloutResponseWrapper response = callout.createRMA(request);
        
        ALK_RMAService.checkIntegrationRequestResult(response.statusCode, response.status, 'RMA Creation');
        
        return response.response;
    }
    
    public static ALK_DispatchCalloutResponseWrapper.ALK_DispatchWrapper searchDispatch(String invoiceNumber) {
        ALK_DispatchCallout callout = new ALK_DispatchCallout();
        ALK_DispatchCalloutResponseWrapper response = callout.searchDispatch(invoiceNumber);
        
        ALK_RMAService.checkIntegrationRequestResult(response.statusCode, response.status, 'Dispatch Search');
        
        return response.dispatch;
    }  
    
    private static void checkIntegrationRequestResult(Integer statusCode, String status, String integration) {
        if (statusCode != 200 && statusCode != 201) {
            throw new ALK_RMAServiceException(String.format('The {0} integration didn\'t work properly and result status code {1} and status {2}.',
                                                            new String[]{integration, String.valueOf(statusCode), status}));
        }        
    }    
    
    public class ALK_RMAServiceException extends Exception {}
}