@isTest
global class ALK_HttpVicidialCalloutMockFail implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"code": "500","description": "HTTP:INTERNAL_SERVER_ERROR","resource": "Calls-exp-021-Management-dev-API","correlationId": "6553fa40-17e7-11ed-9ea2-0abcb3dcdf13","error": {"code": "ERROR_500","description": "ERROR :agent_user is not paused - 48600"}}');
		response.setStatusCode(500);            
		return response;
	}
}