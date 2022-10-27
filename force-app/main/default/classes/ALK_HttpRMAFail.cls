@isTest
global class ALK_HttpRMAFail implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');        
        response.setBody('{"RMA_ID":null,"ERROR_CODE": "300","DESCRLONG":"Error"}');
        response.setStatusCode(201);            
        return response;
    }
}