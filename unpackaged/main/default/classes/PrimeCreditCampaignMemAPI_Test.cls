@isTest
public class PrimeCreditCampaignMemAPI_Test {
 
    @testSetup
    static void datasetup(){
         Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
    }
 @isTest
    static void runTest1(){
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        Contact con = PGTestDataFactory_v2.createContact('FirstName','LastName','test@mail.com');
        CampaignMember cmp = PGTestDataFactory_v2.CreateCampaignMember(con.Id, cma.Id);
        
   
        String jsonData = '{ "campaignId": "'+cma.id+'", "campaignMember": [{ "contactId": "0037F000012hFZ4", "status": "Eligible" , "syncNeeded":true }, { "contactId": "0037F00001m8vC1", "status": "Eligible" , "syncNeeded":true },{ "contactId": "0037F000012hAWI", "status": "Eligible" , "syncNeeded":true }] }';
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/pccampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        Test.startTest();
        PrimeCreditCampaignMemAPI.upsertCampaignMember();
        Test.stopTest();
        
        JSONGenerator gen1 = JSON.createGenerator(true);
       
        String jsonData1 = gen1.getAsString();
        
        RestRequest req1 = new RestRequest();
        RestResponse res1 = new RestResponse();
        req1.requestURI = '/services/apexrest/api/pgcampaign/pccampaignmember/';
        req1.httpMethod = 'POST';
        
        req1.requestBody = blob.valueOf(jsonData1);
        
        RestContext.request = req1;
        RestContext.response= res1;
        PrimeCreditCampaignMemAPI.upsertCampaignMember();
    }
    @isTest
    static void runTest2(){
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        cma.IsActive = false;
        update cma;
                
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', cma.Id);
        
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/pccampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PrimeCreditCampaignMemAPI.upsertCampaignMember();
        Test.stopTest();
        
        
       
       
    }
  @isTest
    static void runTest3(){
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', '7019D0000002zR2');
        
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/pccampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PrimeCreditCampaignMemAPI.upsertCampaignMember();
        Test.stopTest();
    }
    @isTest
      static void runTest(){
        
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', '');
        
        gen.writeEndObject();
        String jsonData = gen.getAsString();
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/pccampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PrimeCreditCampaignMemAPI.upsertCampaignMember();
        Test.stopTest();
    }
    @isTest
    static void runTest4(){
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        
     
  String jsonData = '{ "campaignId": "'+cma.id+'", "campaignMember": [{ "contactId": "", "status": "Eligible" , "syncNeeded":true }, { "contactId": "0037F00001m8vC1", "status": "Eligible" , "syncNeeded":true },{ "contactId": "0037F000012hAWI", "status": "Eligible" , "syncNeeded":true }] }';
      
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/pccampaignmember/';
        req.httpMethod = 'POST';
        
        req.requestBody = blob.valueOf(jsonData);
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        PrimeCreditCampaignMemAPI.upsertCampaignMember();
        Test.stopTest();
    }
   
 
}