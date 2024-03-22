@isTest
public class CreateOrderApi_Test {

    @isTest
    public static void unitTest(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=true;
        insert oppTrigger;
        
        Trigger_Execute__c oppTrigger1 = new Trigger_Execute__c();
        oppTrigger1.Name='Trigger_OpportunitySplit';
        oppTrigger1.Enable_del__c=true;
        insert oppTrigger1;
        
        string resp = '';
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.Name = 'test Acc';
        a.Customer_Type__c = 'Developer';
        insert a;
        
        Contact con = new Contact();
        con.LastName = 'test Contact';
        con.AccountId = a.Id;
        con.Email = 'con@gmail.com';
        insert con;
        
        Test.StartTest();
        
        Id recTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId();
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
        Opp.CurrencyIsoCode = 'IDR';
        insert opp;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
		so.csmso__Advertiser__c = a.Id;
		so.csmso__Status__c = 'Delivered';
		so.csmso__Opportunity__c = opp.Id;
		so.Primary_Sales_Order__c = true;
		so.Advertiser_Final__c = a.Id;
        so.Billing_schedule__c = 'Bill by item';
        insert so;
        
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = a.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        /*    // Call REST endpoint
        csdf__Fulfilment__c result = FulfilmentRestResource.doGet();
        
        // Verify result
        System.assertEquals(fulfilment.Id, result.Id);
        System.assertEquals(fulfilment.Name, result.Name);*/
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/CreateOrder';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
        req.addParameter('id', testFulfilment.id);
        RestContext.request = req;
        RestContext.response= res;
    //    CreateOrderApi.doGet();
    //    resp = res.responseBody.toString();
        csdf__Fulfilment__c result = CreateOrderApi.doGet();
   
        Test.stopTest();
    //    map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(resp);
    }
}