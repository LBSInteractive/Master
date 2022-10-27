@isTest
global class ALK_HttpRMACalloutMockFail  implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"status": "Fail","statusCode": 500}');
		response.setStatusCode(500);            
		return response;
	}
}