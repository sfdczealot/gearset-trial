@isTest
public class BatchTOUpdateAgencyLOGO_Mockclass implements HttpCalloutMock {
 public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        String image = EncodingUtil.base64Encode(Blob.valueOf('emp'));
        res.setBody(image);
        res.setStatusCode(200);
        return res;
    }
}