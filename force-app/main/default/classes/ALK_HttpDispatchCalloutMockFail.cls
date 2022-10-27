@isTest
global class ALK_HttpDispatchCalloutMockFail  implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{}');
		response.setStatusCode(500);            
		return response;
	}
}