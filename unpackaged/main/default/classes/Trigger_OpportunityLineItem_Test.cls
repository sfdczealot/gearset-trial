/*
* Created by : Yuni
* Company    : Viseo Asia PTE LTD
* created Date : 21/09/2018
*/
@isTest
public class Trigger_OpportunityLineItem_Test {
    static testMethod void runTest() {
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();   
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        list<Account> listAcc = new list<Account>();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.AgentNet_ID__c = 'TestPurposeIdXX';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
         a.billingcountryCode = 'SG';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'asd131sfaa@yaho.com';
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        //a.Total_Spending_12_Months__c = 1200;
        listAcc.add(a);
        
        Account ac = new Account();
        ac.RecordTypeId = accRectype;
        ac.LastName = 'TestYuni';
        //a.Customer_Type__c = 'Agency';
        ac.AgentNet_ID__c = 'TestPurposeId';
        ac.CurrencyIsoCode = 'SGD';
        ac.Subscription_Start_Date__c = system.today().addMonths(-10);
        ac.Subscription_End_Date__c = system.today().addMonths(1);
        ac.BillingStreet = 'test';
        ac.BillingCity = 'test';
        ac.billingcountryCode = 'SG';
        ac.BillingPostalCode = '8373';
      //  ac.BillingState = 'Singapore';
        ac.Current_Subscription_Code__c = 'abc';
        //a.Total_Spending_12_Months__c = 1200;
        ac.account_rule_code__c = 'Standard';
        ac.personemail = 'a789axz@yaho.com';
        ac.salutation = 'Mr.';
        ac.firstname = 'aaaa';
        ac.Country__c = 'Singapore';
        ac.Status__c = 'Active';
        ac.CEA_Salesperson_Number__c = 'CEACHECK';
        ac.PersonBirthdate = Date.newInstance(1996, 12, 21);
        listAcc.add(ac);
        insert listAcc;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.CurrencyIsoCode = 'SGD';
        //opp.Total_Spending_on_Discretionary_Product__c = 1200;
        insert opp;
        
        
        list<Product2> listProd = new list<Product2>();
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Is_Bundle__c= true, CurrencyIsoCode = 'SGD');
        listProd.add(prod);
        
        Product2 prod2 = new Product2(Name = 'Test Prod2', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Is_Bundle__c= false, CurrencyIsoCode = 'SGD');
        listProd.add(prod2);
        insert listProd;
        //STANDARD PRICEBOOK
        Id StdpricebookId = Test.getStandardPricebookId();
        
        list <PriceBookEntry> listPbe = new list<PricebookEntry>();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true);
        listPbe.add(pbe); 
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod2.id,unitprice=100.0, isActive=true);
        listPbe.add(pbe2);
        
        //NEW PRICEBOOK
        Pricebook2 pb = new Pricebook2(Name = 'Standard Price Book 2009', Description = 'Price Book 2009 Products', IsActive = true);
        insert pb;
        PricebookEntry pbe11 = new PricebookEntry(pricebook2id=pb.id, product2id=prod.id,unitprice=100.0, isActive=true);
        listPbe.add(pbe11);
        
        PricebookEntry pbe21 = new PricebookEntry(pricebook2id=pb.id, product2id=prod2.id,unitprice=100.0, isActive=true);
        listPbe.add(pbe21);
        insert listPbe;
        
        item_bundle__c bund = new item_bundle__c();
        bund.Parent_Product__c = prod.id;
        bund.Child_Product__c = prod2.id;
        bund.Qty__c = 1;
        insert bund;
        
        Test.StartTest();
        list<OpportunityLineItem> listOppLine = new list<OpportunityLineItem>();
        //BUNDLE PRODUCT
        OpportunityLineItem oplineItem = new OpportunityLineItem();
        oplineItem.OpportunityId = opp.id;
        oplineItem.Product2Id = prod.id;
        oplineItem.PricebookEntryId = pbe11.id;
        oplineItem.Quantity = 2;
        oplineItem.UnitPrice = 1200;
        oplineItem.Discount_Reason__c = 'Agent Referral: Referee';
        //oplineItem.Is_Bundle__c = true;
        listOppLine.add(oplineItem);
        
        //NONBUNDLEPRODUCT
        OpportunityLineItem oplineItem2 = new OpportunityLineItem();
        oplineItem2.OpportunityId = opp.id;
        oplineItem2.Product2Id = prod2.id;
        oplineItem2.PricebookEntryId = pbe21.id;
        oplineItem2.Quantity = 2;
        oplineItem2.UnitPrice = 1200;
        //oplineItem.Is_Bundle__c = true;
        listOppLine.add(oplineItem2);
        insert listOppLine;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.stageName = 'Closed Won';
        opp.Approval_Status__c = 'OMC Approval Approved';
        opp.OMC_Approved_Date__c = system.today();
        if(listOppLine != null && !listOppLine.isEmpty())
            QuoteSyncHandler.sync(new set<id> {listOppLine[0].id});
        update opp;
        update listOppLine;
        Test.stopTest();
        
    }
    static testMethod void coverB2BApproval() {
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.AgentNet_ID__c = 'TestPurposeIdXX';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.billingcountryCode = 'SG';
        a.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'asd131sfaa@yaho.com';
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.CurrencyIsoCode = 'SGD';
        insert opp;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2B Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Is_Bundle__c= true, CurrencyIsoCode = 'SGD');
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true);
        insert pbe;
        
        OpportunityLineItem oplineItem = new OpportunityLineItem();
        oplineItem.OpportunityId = opp.id;
        oplineItem.Product2Id = prod.id;
        oplineItem.PricebookEntryId = pbe.id;
        oplineItem.Quantity = 2;
        oplineItem.UnitPrice = 1200;
        oplineItem.Discount_Reason__c = 'Agent Referral: Referee';
        insert oplineItem;
        
        opp.Approval_Status__c='Discount Approval Submitted';
        update opp;
        try{
        delete oplineItem;
        }catch(Exception exp){
             
        }
        opp.Approval_Status__c='Director Approved';
        update opp;
        //delete oplineItem;
      }
 }