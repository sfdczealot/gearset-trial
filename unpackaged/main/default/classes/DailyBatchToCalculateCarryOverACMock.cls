@isTest
public class DailyBatchToCalculateCarryOverACMock implements HttpCalloutMock{
 
    public HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('{ "total": 1, "records": [ { "id": 1155150, "webuserId": 89953, "invoiceId": "0062r0000056DA2AAM", "externalId": "21267507-PGQ-21094052", "billingSourceId": 3, "purchasedDate": { "date": "2021-07-29 18:00:44.000000", "timezone_type": 3, "timezone": "Asia/Singapore" }, "internalId": "21267507-PGQ-21094052_1_2", "startDate": { "date": "2021-08-03 00:00:00.000000", "timezone_type": 3, "timezone": "Asia/Singapore" }, "expiryDate": { "date": "2022-08-02 00:00:00.000000", "timezone_type": 3, "timezone": "Asia/Singapore" }, "name": "PG02B3249 Bundle Ad Credit (1 Credit)", "productCode": "PG_1237", "purchasedQuantity": 500, "statusCode": "ACTIVE", "utilizedQuantity": 182, "balanceQuantity": 318 } ] }');
        res.setStatusCode(200);
        return res;
    }

}