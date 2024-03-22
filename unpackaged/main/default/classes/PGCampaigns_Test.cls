@isTest
public class PGCampaigns_Test {
    
    @isTest
    static void runTest1(){
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        Contact con = PGTestDataFactory_v2.createContact('FirstName','LastName','test@mail.com');
        CampaignMember cmp = PGTestDataFactory_v2.CreateCampaignMember(con.Id, cma.Id);
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', cma.Id);
        gen.writeFieldName('campaignMember');
        gen.writeStartObject();
        gen.writeStringField('id', cmp.Id);
        gen.writeStringField('contactId', con.Id);
        gen.writeStringField('status', cmp.Status);
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/upsertcampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        PGCampaigns.upsertCampaignMember();
        Test.stopTest();
        
        JSONGenerator gen1 = JSON.createGenerator(true);
       
        String jsonData1 = gen1.getAsString();
        
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        req1.requestURI = '/services/apexrest/api/pgcampaign/upsertcampaignmember/';
        req1.httpMethod = 'POST';
        
        req1.requestBody = blob.valueOf(jsonData1);
        
        RestContext.request = req1;
        RestContext.response= res1;
        PGCampaigns.upsertCampaignMember();
    }
    @isTest
    static void runTest2(){
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        cma.IsActive = false;
        update cma;
                
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', cma.Id);
        gen.writeFieldName('campaignMember');
        gen.writeStartObject();
        gen.writeStringField('id', '');
        gen.writeStringField('contactId', '');
        gen.writeStringField('status', 'Sent');
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/upsertcampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PGCampaigns.upsertCampaignMember();
        Test.stopTest();
        
        
       
       
    }
    @isTest
    static void runTest3(){
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', '');
        gen.writeFieldName('campaignMember');
        gen.writeStartObject();
        gen.writeStringField('id', '');
        gen.writeStringField('contactId', '');
        gen.writeStringField('status', 'Sent');
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/upsertcampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PGCampaigns.upsertCampaignMember();
        Test.stopTest();
    }
    @isTest
    static void runTest4(){
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', cma.Id);
        gen.writeFieldName('campaignMember');
        gen.writeStartObject();
        gen.writeStringField('id', '');
        gen.writeStringField('contactId', '');
        gen.writeStringField('status', 'Sent');
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/upsertcampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PGCampaigns.upsertCampaignMember();
        Test.stopTest();
    }
      @isTest
    static void runTest5(){
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        cma.IsActive = false;
        update cma;
                
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', '1234');
        gen.writeFieldName('campaignMember');
        gen.writeStartObject();
        gen.writeStringField('id', '');
        gen.writeStringField('contactId', '');
        gen.writeStringField('status', 'Sent');
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/upsertcampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PGCampaigns.upsertCampaignMember();
        Test.stopTest();
        
        
       
       
    }
      @isTest
    static void runTest6(){
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        cma.IsActive = true;
        update cma;
                contact con = PGTestDataFactory_v2.createContact('FirstName', 'LastName', 'Email@test.com');
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', cma.id);
        gen.writeFieldName('campaignMember');
        gen.writeStartObject();
        gen.writeStringField('id', '');
        gen.writeStringField('contactId', con.id);
        gen.writeStringField('status', 'Sent');
        gen.writeEndObject();
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/upsertcampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PGCampaigns.upsertCampaignMember();
        Test.stopTest();
        
        
       
       
    }
   /* @istest
     static void runTest7(){
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        cma.IsActive = true;
        update cma;
                contact con = PGTestDataFactory_v2.createContact('FirstName', 'LastName', 'Email@test.com');
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', cma.id);
        
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/upsertcampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PGCampaigns.upsertCampaignMember();
        Test.stopTest();
        
        
       
       
    }*/
}