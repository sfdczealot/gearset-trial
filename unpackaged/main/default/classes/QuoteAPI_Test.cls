/*
* Created by : Yuni
* Company    : Viseo Asia PTE LTD
* created Date : 30/07/2018
*/
@isTest
public class QuoteAPI_Test {
    static testMethod void runTest() {
        String resp = '';
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                         );
        
        insert u;
        PGTestDataFactory_v2.initSetupData();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
          a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c='qwerty';
        a.PersonBirthdate=system.today();
        
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Agent_Accepted_Time__c = system.now();
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        insert opp;
        opp.Payment_Time__c = system.now();
        update opp;
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc');
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true);
        insert pbe;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        insert oli;
        string testMonth = '';
        testMonth = (system.today().month()<10?'0'+system.today().month():string.valueof(system.today().month()));
        string testDate = system.today().year() +'-'+ testMonth +'-'+ (system.today().day()>9?string.valueOf(system.today().day()):'0'+system.today().day());
        Opportunity opp2 = new opportunity();
        opp2 = [select id,createddate from opportunity where id =: opp.id];
        Test.StartTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/quote';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.addParameter('id', opp.id);
        RestContext.request = req;
        RestContext.response= res;
        QuotesAPI.readQuote();
        resp = res.responseBody.toString();
        map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(resp);
        String created ='';
        String refno = '';
        String expiry = '';
        if(responseJson != null){
            created = (string) responseJson.get('created');  
            refno = (string) responseJson.get('invoice_id'); 
            expiry = (string)responseJson.get('expiry');
        }
        system.debug('First Actual Response : ' + resp);
        //system.assertEquals('{"total":"9.00","status":"close","region":null,"order_info":{"webuserId":"123","tranTotal":"9.00","tranTax":"0.00","tranDisc":"0.00","tranAmount":"9.00","salesRep":{"name":"GianTest","email":"giantest@testorg.com","contactNo":null},"region":null,"referenceNo":"'+refno+'","items":[{"startDate":"'+testDate+'","itemTax":"0.00","itemQuantity":"3.00","itemPrice":"3.00","itemName":"Test Prod","itemDisc":"0.00","itemDescription":null,"itemAmount":"9.00","endDate":"' + testDate + '"}],"email":"12121assas@yahoo.com","customerName":"abc TestYuni","createdDate":"'+created+'","billaddress":"test test Singapore"},"invoice_id":"'+refno+'","expiry":"'+expiry+'","created":"'+created+'","agent_id":"123"}', resp, 'Expected and Actual response from GET method did not match');
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        string requestQuote = '{"Id":" '+ opp.Opportunity_Number__c + '","Agent_Accepted_Time__c": "2018-09-24T14:23:47+00:00"}';
        req2.requestURI = '/services/apexrest/quote';  //Request URL
        req2.httpMethod = 'post';//HTTP Request Type
        req2.requestBody = blob.valueOf(requestQuote);
        RestContext.request = req2;
        RestContext.response= res2;
        QuotesAPI.updateQuote();
        resp = res2.responseBody.toString();
        system.debug('Second Actual Response : ' + resp);
        System.assertEquals('List has no rows for assignment to SObject 64', resp, 'Expected and Actual response did not match !');
        
        Test.stopTest();
    }
}