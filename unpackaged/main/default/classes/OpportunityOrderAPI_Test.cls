/*
* Created by : Yuni
* Company    : Viseo Asia PTE LTD
* created Date : 10/07/2018
*/
@isTest
public class OpportunityOrderAPI_Test {
    static testMethod void runTest() {
        Date startDate = system.today(); 
        Date endDate = system.today().AddDays(30);
        User runUsser = [Select id, Webuser_ID__c From User where id =: UserInfo.getUserId()];
        runUsser.Webuser_ID__c= 1;
        update runUsser;
        string resp = '';
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        PGTestDataFactory_v2.initSetupData();

        a.LastName = 'TestYuni';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
      // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = '5775';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.PersonBirthdate = System.today();
        a.CEA_Salesperson_Number__c='test1021';
        a.Status__c = 'Active';
        a.AgentNet_ID__c = '6776';
        insert a;
        
        Id recTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2C').getRecordTypeId();
    
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.RecordTypeId = recTypeid;
        opp.Start_Date__c = Date.today();
        opp.End_Date__c = Date.today().adddays(1);
        opp.Order_Type_Clone__c = 'Contract - Upgrade';
        opp.OMC_Approved_Date__c = Date.today().adddays(1);
        insert opp;
        
        list<Product2> prod = new list <Product2>();
        prod.add(new product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only',Product_Category__c = 'Subscription',SKU_Code__c = '1.00', Product_Function__c = 'post'));
        prod.add(new product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only',Product_Category__c = 'Subscription',SKU_Code__c = '1.12', Product_Function__c = 'aa'));
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod[0].id,unitprice=100.0, isActive=true);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod[1].id,unitprice=100.0, isActive=true);
        insert pbe2;
        
        list<OpportunityLineItem> oli = new list<OpportunityLineItem>();
        oli.add(new opportunityLineItem(OpportunityId = opp.id, Product2Id = prod[0].id,PricebookEntryId = pbe.id,Quantity = 3,UnitPrice =3,SNo__c = 1.00,GST_VAT_Rate__c = 7,Start_Date__c = startDate, End_Date__c = endDate));
        oli.add(new opportunityLineItem(OpportunityId = opp.id, Product2Id = prod[1].id,PricebookEntryId = pbe.id,Quantity = 3,UnitPrice =3,SNo__c = 1.11,GST_VAT_Rate__c = 7,Start_Date__c = startDate, End_Date__c = endDate ));
        
        insert oli;
        
        Test.StartTest();
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/order';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.addParameter('id', opp.id);
        RestContext.request = req;
        RestContext.response= res;
        OpportunityOrderAPI.getOpportunity();
        resp = res.responseBody.toString();
        map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(resp);
    
        String internalId = '';         String created ='';     String externalId = '';        String parentInternalId = '';
        if(responseJson != null){
            created = (string) responseJson.get('purchasedDate');  
            externalId = (string) responseJson.get('externalId');       
            internalID = externalId + '_1';
            parentInternalId = externalId + '_1_11';
        }
        //system.assertEquals('{"webuserId":123,"totalAmount":"19.26","source":"offline","purchasedProducts":[{"validityPeriod":"null null","statusCode":"ACTIVE","startDate":"' + startDate + '","standardProduct":"1","salesPersonId":1,"quantity":"3.00","purchasedProductFunctions":[{"value":"0","code":"post"}],"parentInternalId":"'+ internalId+'","parent":null,"netAmount":"9.63","internalId":"'+ internalId +'","externalProductId":null,"expiryDate":"'+ endDate + '","durationPeriod":"null null","createdBy":1,"chargeValue":"3.00","chargeCurrency":"SGD","autoActivate":"T"},{"validityPeriod":"null null","statusCode":"ACTIVE","startDate":"'+ startDate +'","standardProduct":"0","salesPersonId":1,"quantity":"3.00","purchasedProductFunctions":[{"value":"0","code":"post"}],"parentInternalId":"'+ internalId +'","parent":null,"netAmount":"9.63","internalId":"'+parentinternalId+'","externalProductId":null,"expiryDate":"'+ endDate + '","durationPeriod":"null null","createdBy":1,"chargeValue":"3.00","chargeCurrency":"SGD","autoActivate":"T"}],"purchasedDate":"'+  created +'","invoiceId":"'+opp.id+'","externalId":"'+ externalId + '","createdBy":1,"billingSourceId":3}', resp, 'Expected and Actual response from GET method did not match');
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        
        req2.requestURI = '/services/apexrest/order';  //Request URL
        req2.httpMethod = 'GET';//HTTP Request Type
        req2.addParameter('id', 'aaa');
        RestContext.request = req2;
        RestContext.response= res2;
        OpportunityOrderAPI.getOpportunity();
        resp = res.responseBody.toString();
        //system.assertEquals('{"webuserId":123,"totalAmount":"19.26","source":"offline","purchasedProducts":[{"validityPeriod":"null null","statusCode":"ACTIVE","startDate":"'+ startDate +'","standardProduct":"1","salesPersonId":1,"quantity":"3.00","purchasedProductFunctions":[{"value":"0","code":"post"}],"parentInternalId":"'+ internalId+'","parent":null,"netAmount":"9.63","internalId":"'+ internalId +'","externalProductId":null,"expiryDate":"'+ endDate + '","durationPeriod":"null null","createdBy":1,"chargeValue":"3.00","chargeCurrency":"SGD","autoActivate":"T"},{"validityPeriod":"null null","statusCode":"ACTIVE","startDate":"'+ startDate + '","standardProduct":"0","salesPersonId":1,"quantity":"3.00","purchasedProductFunctions":[{"value":"0","code":"post"}],"parentInternalId":"'+ internalId +'","parent":null,"netAmount":"9.63","internalId":"'+parentinternalId+'","externalProductId":null,"expiryDate":"'+ endDate +'","durationPeriod":"null null","createdBy":1,"chargeValue":"3.00","chargeCurrency":"SGD","autoActivate":"T"}],"purchasedDate":"'+  created +'","invoiceId":"'+opp.id+'","externalId":"'+ externalId + '","createdBy":1,"billingSourceId":3}', resp, 'Expected and Actual response from GET method did not match');
        Test.stopTest();
    }
}