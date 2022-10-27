@isTest
global class ALK_HttpInfobipCalloutMockSuccess  implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "Ok","statusCode": 201}');
		response.setStatusCode(201);            
		return response;
	}
}