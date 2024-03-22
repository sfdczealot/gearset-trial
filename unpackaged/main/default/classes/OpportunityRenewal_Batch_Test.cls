@isTest
public class OpportunityRenewal_Batch_Test {
    /*
* Created by : Yuni
* Company    : Viseo Asia PTE LTD
* created Date : 27/07/2018
*/
    
    static testMethod void runTest() {
        Test.StartTest();
        id subId = PGTestDataFactory.createSubsidiary().Id;
        PGTestDataFactory_v2.initSetupData();
        
        string accRectypeB2B = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        Account aB2B = new Account();
        aB2B.RecordTypeId = accRectypeB2B;
        aB2B.Name = 'Unit Test Agency';
        aB2B.Customer_Type__c = 'Developer';
        aB2B.BillingStreet = 'test street';
        aB2B.BillingCity = 'city';
        aB2B.BillingCountry = 'Singapore';
        aB2B.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        aB2B.Country__c = 'Singapore';
        insert aB2B;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        a.CEA_Salesperson_Number__c='12345';
       // a.BillingState = 'Singapore';
        a.Current_Subscription__c = 'Advance';
        a.Current_Subscription_Code__c = 'abc';
        a.Subscription_End_Date__c = system.today();
        a.account_rule_code__c = 'Standard';
        a.personemail = 'alkjha@yaho.com';
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.PersonBirthdate= Date.newInstance(2016, 12, 9);
        a.Country__c = 'Singapore';
        a.Subsidiary__c = subId;
        a.Status__c = 'Active';
        a.Commando_Sales_Rep__c = UserInfo.getUserId();
        insert a;

        Account ac = new Account();
        ac.RecordTypeId = accRectype;
        ac.LastName = 'TestYuni';
        ac.AgentNet_ID__c = 'TestPurposeId';
        ac.CurrencyIsoCode = 'SGD';
        ac.Subscription_Start_Date__c = system.today().addMonths(-10);
        ac.Subscription_End_Date__c = system.today().addMonths(1);
        ac.BillingStreet = 'test';
        ac.BillingCity = 'test';
        ac.BillingCountry = 'Singapore';
        ac.BillingPostalCode = '83713';
      //  ac.BillingState = 'test';
        ac.Current_Subscription__c = 'Premier';
        ac.Current_Subscription_Code__c = 'abc';
        ac.account_rule_code__c = 'Standard';
        ac.personemail = 'a1213axy@yaho.com';
        ac.salutation = 'Mr.';
        ac.firstname = 'aaaa';
        ac.Country__c = 'Malaysia';
        ac.Subsidiary__c = subId;
        ac.Status__c = 'Active';
        ac.Commando_Sales_Rep__c = UserInfo.getUserId();
        ac.VIP__c = true;
        ac.CEA_Salesperson_Number__c = '123456';
        ac.PersonBirthdate= Date.newInstance(2016, 12, 9);
        insert ac;
         
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = aB2B.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.Subsidiary__c = subId;
        insert opp;
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc');
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true);
        insert pbe; 
        
        OpportunityLineItem oplineItem = new OpportunityLineItem();
        oplineItem.OpportunityId = opp.id;
        oplineItem.Product2Id = prod.id;
        oplineItem.PricebookEntryId = pbe.id;
        oplineItem.Quantity = 2;
        oplineItem.UnitPrice = 1200;
        insert oplineItem;
        
        OpportunityRenewal_Batch obj = new OpportunityRenewal_Batch();
        Database.executeBatch(obj);
        Test.stopTest();

       /* //AccountAssignment_BatchSchedulable sh1 = new AccountAssignment_BatchSchedulable();      
        String sch = '0 0 0 * * ? *';
        // system.schedule('Test Schedule', sch, sh1);
        
        
        OpportunityRenewal_BatchSchedulable orbs = new OpportunityRenewal_BatchSchedulable();      
        sch = '0 0 0 * * ? *';
        system.schedule('Test Schedule Renewal', sch, orbs);
        */
    }
    
}