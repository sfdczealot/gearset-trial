@isTest
global class GurulandApiMock implements HttpCalloutMock {
    global HttpResponse respond(HttpRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setBody('{"agentId":"10244901","code":"AG2000","message":"Resend verification email is successful."}');
        response.setStatusCode(200);
        return response;
    }
}