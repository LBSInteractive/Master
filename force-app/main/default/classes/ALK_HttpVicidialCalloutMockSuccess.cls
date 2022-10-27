@isTest
global class ALK_HttpVicidialCalloutMockSuccess  implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"leadId": "1234567890"}');
		response.setStatusCode(201);            
		return response;
	}
}