@isTest
global class ALK_HttpAccountCalloutMockSuccess implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"Id":"0010100000ScTV1AAN","ALK_Autorization_habeas_data__c":"false"}');
		response.setStatusCode(200);            
		return response;
	}
}