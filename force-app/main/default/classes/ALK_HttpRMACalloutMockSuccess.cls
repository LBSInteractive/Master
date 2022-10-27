@isTest
global class ALK_HttpRMACalloutMockSuccess  implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');        
        response.setBody('{"RMA_ID":"1234567","ERROR_CODE": "","DESCRLONG":""}');
        response.setStatusCode(201);            
		return response;
	}
}