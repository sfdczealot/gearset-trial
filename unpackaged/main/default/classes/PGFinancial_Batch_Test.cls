@isTest
public class PGFinancial_Batch_Test {

    private static final String FAKE_RESPONSE_JSON = 'VGhpcyBpcyBhIFRlc3Q=';
    static testMethod void testDocumentSync() {
        Financial__c FinRec = new Financial__c();
        FinRec.NetSuite_Id__c = '3763639';
        FinRec.Type__c = 'Invoice';
        FinRec.Document_Id__c = '';
        FinRec.Name = 'TestTransaction';
       
        
        insert FinRec;
        Integer ctr = integer.valueof(label.PG_LABEL_BatchJob_TestCtr);
        DateTime dt = DateTime.now().addDays(ctr);
        system.debug(dt);
        test.setCreatedDate(FinRec.Id, dt);
        Test.setMock(HttpCalloutMock.class, new Mock());
        Test.StartTest();
        
		PGFinancial_BatchSchedulable schedulable = new PGFinancial_BatchSchedulable();
		String sch = '0 0 0 * * ? *';
		system.schedule('Test Schedule', sch, schedulable);
        Test.stopTest();
    }

    private class Mock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {

            // You could assert the request content here

            HTTPResponse res = new HTTPResponse();
            res.setBody(FAKE_RESPONSE_JSON);
            res.setStatusCode(200);
            return res;
        }
    }

}