global class ALK_HttpAddressCreateCalloutMockSuccess implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"ERROR_FLAG": "N","ERRNUM": "0","ERROR_MESSAGE_TXT": null}');
		response.setStatusCode(200);            
		return response;
	}
}