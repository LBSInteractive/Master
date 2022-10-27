public abstract class ALK_StandardCallout {
    protected virtual object execute(object requestWrapper) {  
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        
        ALK_API_Callouts__mdt config = this.getCalloutConfig();
        
        String pathParams = this.getPathParams(requestWrapper);
        
        String endPoint = this.getEndpoint(config,requestWrapper);
        
        request.setEndpoint(endPoint+pathParams);
        
        request.setMethod(config.ALK_Method__c);
        
        this.setHeader(request,config);
        
        this.setCredentials(request,config);
                  
        this.setBody(request, this.getPayLoad(requestWrapper));
        
        ALK_Callout_Configs__c calloutConfigsParams = ALK_Callout_Configs__c.getInstance();
        request.setTimeout(Integer.valueOf(calloutConfigsParams.ALK_timeout__c));        
                
        HttpResponse response = http.send(request);
			System.debug('response -> ' + response);            
        
        return getResponse(response);        
    }
        
    protected abstract ALK_API_Callouts__mdt getCalloutConfig();

    protected abstract String getPathParams(object requestWrapper);
    
    protected abstract Map<String, Object> getPayLoad(object requestWrapper);
    
    protected abstract Object getResponse(HttpResponse response);
    
    protected virtual String getEndpoint(ALK_API_Callouts__mdt config, object requestWrapper) {
       return 'callout:'+config.ALK_Path__c;
    }
    
    protected virtual void setCredentials(HttpRequest request, ALK_API_Callouts__mdt config) {
        request.setHeader('client_id', config.ALK_Client_ID__c);
        request.setHeader('client_secret', config.ALK_Client_Secret__c);        
    }    

    protected virtual void setHeader(HttpRequest request, ALK_API_Callouts__mdt config) {
        request.setHeader('Content-Type', 'application/json');        
    }    

    protected virtual void setBody(HttpRequest request, Map<String, Object> bodyPayload) {
        if (bodyPayload.size() > 0) {
        	request.setBody(JSON.serialize(bodyPayload));
        }
    }    
}