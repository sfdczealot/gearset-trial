@isTest
public class callCEAEndpointClass_Test {
    private static Account a  = null;
    @testSetup
    public static void testData(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            //data setup
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            a = PGTestDataFactory_v2.createB2CAccount('test@test.com','12321', thisUser, sb);
            //standard PB
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            opportunity opp =PGTestDataFactory_v2.createB2CSubscriptionOpty(a, thisUser, sb, standardPB, 'B2C - Renewal');
            quote q= PGTestDataFactory_v2.createQuote(opp, sb, a, StandardPB, 'B2C - Renewal', 'proposal');       
        }
        
    }
    @isTest
    public static void testCEACheck(){
        Account a=[select id from account limit 1];
        Opportunity opp=[select id from opportunity limit 1];
        callCEAEndpointClass.runningInASandbox();
        
        Test.startTest();
        Quote q=[select id,quote_number__c from quote limit 1];
        Test.setMock(HttpCalloutMock.class, new MockClass1());
        try{
            callCEAEndpointClass.verifyCEADetails('CEACHECK1',opp.id,q.quote_number__c );
        } catch(AuraHandledException e) {}
        Test.setMock(HttpCalloutMock.class, new MockClass2());
        try{
            callCEAEndpointClass.verifyCEADetails('CEACHECK1',opp.id,q.quote_number__c );
        } catch(AuraHandledException e) {}
        try{
            callCEAEndpointClass.verifyCEADetails('CEACHECK1',opp.id,'null' );
        } catch(AuraHandledException e){}
        
        Test.stopTest();
    }
    
    //Mock Response
    public class MockClass2 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', ' text/html');
            res.setBody('{"valid":true,"message":"test"}');
            res.setStatusCode(200);
            return res;
            
        }
        
    }
    public class MockClass1 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', ' text/html');
            res.setBody('{"name":"true","message":"test"}');
            res.setStatusCode(401);
            return res;
            
        }
    }
    
    @isTest
    public static void testCEACheck1(){
        Test.startTest();
        account a=[select id from account limit 1];
        opportunity opp=[select id from opportunity limit 1];
        callCEAEndpointClass.runningInASandbox();
        
        Quote q=[select id,quote_number__c from quote limit 1];
        Test.setMock(HttpCalloutMock.class, new MockClass3());
        try {
            callCEAEndpointClass.verifyCEADetails('CEACHECK1',opp.id,q.quote_number__c );
        } catch(AuraHandledException e) {}
        
        Test.setMock(HttpCalloutMock.class, new MockClass4());
        try {
            callCEAEndpointClass.verifyCEADetails('CEACHECK1',opp.id,q.quote_number__c );
        } catch(AuraHandledException e) {}
        
        Test.stopTest();
    }
    
    public class MockClass4 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', ' text/html');
            res.setBody('{"valid":false,"message":"test"}');
            res.setStatusCode(200);
            return res;
        }
    }
    
    public class MockClass3 implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', ' text/html');
            res.setBody('{"name":"expired_jwt_token","message":"test"}');
            res.setStatusCode(404);
            return res;
        }
    }
}