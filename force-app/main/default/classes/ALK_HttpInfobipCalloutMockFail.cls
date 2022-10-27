@isTest
global class ALK_HttpInfobipCalloutMockFail implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "Fail","statusCode": 404}');
		response.setStatusCode(404);            
		return response;
	}
}