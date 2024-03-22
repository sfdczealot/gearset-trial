@isTest
public class developerAPI_Test {
     
        @isTest
        public static void test(){
  opportunityTriggerHandler.TriggerDisabled=true;
        Account acc = TestDataSetupBasic.createAccount();
        acc.Developer_ID__c = 'tyh';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
   
        acc.Phone = '2345';
        acc.Developer_ID__c = null;
        insert acc;
        
        Contact testContact = TestDataSetupSO.createContact(acc);
        insert testContact;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = false;
        insert TEOppSplit;
              Trigger_Execute__c TEOpp = new Trigger_Execute__c();
        TEOpp.Name = 'PGOpportunityTrigger';
        TEOpp.Enable_del__c = false;
        insert TEOpp;
        
        Opportunity testOpportunity = TestDataSetupSO.createOpportunity(acc, testContact);
        testOpportunity.Subsidiary_Type__c = 'iPP';
        insert testOpportunity;
        
        testOpportunity.Approval_Status__c = 'OMC Approval Approved';
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId=testOpportunity.Id,ContactId=testContact.Id,Role='Campaign Contact' );
        insert ocr;
        
        test.startTest();
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = '/services/apexrest/developer';  //Request URL
        req2.httpMethod = 'GET';//HTTP Request Type
        req2.addParameter('id', acc.id);
        RestContext.request = req2;
        RestContext.response= res2;
        
            DeveloperAPI.getDeveloperAccount();
            test.stopTest();
        
    }
  
     @isTest
    public static void test2(){
        opportunityTriggerHandler.TriggerDisabled=true;
        Account acc = TestDataSetupBasic.createAccount();
        acc.Developer_ID__c = 'tyh';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
   
        acc.Phone = '2345';
        insert acc;
        
        Contact testContact = TestDataSetupSO.createContact(acc);
        insert testContact;
           Trigger_Execute__c TEOpp = new Trigger_Execute__c();
        TEOpp.Name = 'PGOpportunityTrigger';
        TEOpp.Enable_del__c = false;
        insert TEOpp;
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = false;
        insert TEOppSplit;
        
        Opportunity testOpportunity = TestDataSetupSO.createOpportunity(acc, testContact);
        testOpportunity.Subsidiary_Type__c = 'iPP';
        insert testOpportunity;
        
        test.startTest();
        String JSON ='{"firstName":"Test","lastName":"Developer","countryCode":"60","mobile":"91378378","phone":"463633","website":"www.dev.com","email":"test@dev.com","accID":"'+acc.ID+'","developerKey":"MY1234","country":"Malaysia"}';
        RestRequest req = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req.requestURI = '/services/apexrest/developer';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
           req.requestBody = Blob.valueof(JSON);
       // req2.addParameter('id', acc.id);
        RestContext.request = req;
        RestContext.response= res2;
        
        DeveloperAPI.upsertDeveloperAccount();
        test.stopTest();
    }
    
     @isTest
        public static void test3(){
             opportunityTriggerHandler.TriggerDisabled=true;
    Trigger_Execute__c TEOpp = new Trigger_Execute__c();
        TEOpp.Name = 'PGOpportunityTrigger';
        TEOpp.Enable_del__c = false;
        insert TEOpp;
        Account acc = TestDataSetupBasic.createAccount();
        acc.Developer_ID__c = 'tyh';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
   
        acc.Phone = '2345';
        acc.Developer_ID__c = 'developer';
        insert acc;
        
        Contact testContact = TestDataSetupSO.createContact(acc);
        insert testContact;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = false;
        insert TEOppSplit;
        
        Opportunity testOpportunity = TestDataSetupSO.createOpportunity(acc, testContact);
        testOpportunity.Subsidiary_Type__c = 'iPP';
        insert testOpportunity;
        
        testOpportunity.Approval_Status__c = 'OMC Approval Approved';
        testOpportunity.StageName = 'Closed Won';
        update testOpportunity;
        
        OpportunityContactRole ocr = new OpportunityContactRole(OpportunityId=testOpportunity.Id,ContactId=testContact.Id,Role='Campaign Contact' );
        insert ocr;
        
        test.startTest();
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        req2.requestURI = '/services/apexrest/developer';  //Request URL
        req2.httpMethod = 'GET';//HTTP Request Type
        req2.addParameter('id', acc.id);
        RestContext.request = req2;
        RestContext.response= res2;
        
            DeveloperAPI.getDeveloperAccount();
            test.stopTest();
        
    }
}