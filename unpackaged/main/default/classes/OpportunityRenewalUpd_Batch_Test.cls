@isTest
public class OpportunityRenewalUpd_Batch_Test {
    
    static testMethod void runTest() {
        Test.StartTest();
        id subId = PGTestDataFactory.createSubsidiary().Id;
        PGTestDataFactory_v2.initSetupData();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        
        
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
        ac.BillingPostalCode = '8373';
       // ac.BillingState = 'test';
        ac.Current_Subscription_Code__c = 'abc';
        ac.account_rule_code__c = 'Standard';
        ac.personemail = 'a1213axy@yaho.com';
        ac.salutation = 'Mr.';
        ac.firstname = 'aaaa';
        ac.Country__c = 'Singapore';
        ac.Subsidiary__c = subId;
        ac.Status__c = 'Active';
        ac.PersonBirthdate = Date.newInstance(1996, 12, 21);
        ac.CEA_Salesperson_Number__c = '123123123';
        insert ac;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = ac.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.Subsidiary__c = subId;
        opp.NetSuite_Sales_Order__c = 'Contract - Renewal';
        opp.RecordTypeId = oppRectype;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        insert opp;
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only',
                                     Product_Category__c = 'Subscription', SKU_Code__c = 'abc');
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, 
                                                product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe; 
        
        OpportunityLineItem oplineItem = new OpportunityLineItem();
        oplineItem.OpportunityId = opp.id;
        oplineItem.Product2Id = prod.id;
        oplineItem.PricebookEntryId = pbe.id;
        oplineItem.Quantity = 2;
        oplineItem.UnitPrice = 1200;
        insert oplineItem;
        
        //AccountAssignment_BatchSchedulable sh1 = new AccountAssignment_BatchSchedulable();  
        String sch2 = '0 0 0 * * ? *';
        // system.schedule('Test Schedule', sch, sh1);
        
        OpportunityRenewalUpd_BatchSchedulable orbs2 = new OpportunityRenewalUpd_BatchSchedulable();      
        sch2 = '0 0 0 * * ? *';
        system.schedule('Test Schedule Renewal 2', sch2, orbs2);
        
        OpportunityRenewalUpd_BatchSchedulable orbs3 = new OpportunityRenewalUpd_BatchSchedulable();      
        system.schedule('Test Schedule Renewal 3', sch2, orbs3);
        Test.stopTest();
    }
    
    static testMethod void runTest1() {
        Test.StartTest();
        id subId = PGTestDataFactory.createSubsidiary().Id;
        PGTestDataFactory_v2.initSetupData();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        
        
        Account ac = new Account();
        ac.RecordTypeId = accRectype;
        ac.LastName = 'TestYuni';
        ac.AgentNet_ID__c = 'TestPurposeId';
        ac.CurrencyIsoCode = 'SGD';
        ac.Subscription_Start_Date__c = system.today().addMonths(-10);
        ac.Subscription_End_Date__c = system.today();
        ac.BillingStreet = 'test';
        ac.BillingCity = 'test';
        ac.BillingCountry = 'Singapore';
        ac.BillingPostalCode = '8373';
       // ac.BillingState = 'test';
        ac.Current_Subscription_Code__c = 'abc';
        ac.account_rule_code__c = 'Standard';
        ac.personemail = 'a1213axy@yaho.com';
        ac.salutation = 'Mr.';
        ac.firstname = 'aaaa';
        ac.Country__c = 'Singapore';
        ac.Subsidiary__c = subId;
        ac.Status__c = 'Active';
        ac.PersonBirthdate = Date.newInstance(1996, 12, 21);
        ac.CEA_Salesperson_Number__c = '123123123';
        insert ac;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = ac.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.Subsidiary__c = subId;
        opp.NetSuite_Sales_Order__c = 'Contract - Renewal';
        opp.RecordTypeId = oppRectype;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        insert opp;
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only',
                                     Product_Category__c = 'Subscription', SKU_Code__c = 'abc');
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, 
                                                product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe; 
        
        OpportunityLineItem oplineItem = new OpportunityLineItem();
        oplineItem.OpportunityId = opp.id;
        oplineItem.Product2Id = prod.id;
        oplineItem.PricebookEntryId = pbe.id;
        oplineItem.Quantity = 2;
        oplineItem.UnitPrice = 1200;
        insert oplineItem;
        
        //AccountAssignment_BatchSchedulable sh1 = new AccountAssignment_BatchSchedulable();  
        String sch2 = '0 0 0 * * ? *';
        // system.schedule('Test Schedule', sch, sh1);
        
        OpportunityRenewalUpd_BatchSchedulable orbs2 = new OpportunityRenewalUpd_BatchSchedulable();      
        sch2 = '0 0 0 * * ? *';
        system.schedule('Test Schedule Renewal 2', sch2, orbs2);
        
        OpportunityRenewalUpd_BatchSchedulable orbs3 = new OpportunityRenewalUpd_BatchSchedulable();      
        system.schedule('Test Schedule Renewal 3', sch2, orbs3);
        Test.stopTest();
    }
    
    static testMethod void runTest2() {
        Test.StartTest();
        id subId = PGTestDataFactory.createSubsidiary().Id;
        PGTestDataFactory_v2.initSetupData();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        
        
        Account ac = new Account();
        ac.RecordTypeId = accRectype;
        ac.LastName = 'TestYuni';
        ac.AgentNet_ID__c = 'TestPurposeId';
        ac.CurrencyIsoCode = 'SGD';
        ac.Subscription_Start_Date__c = system.today().addMonths(-10);
        ac.Subscription_End_Date__c = system.today().addMonths(-1);
        ac.BillingStreet = 'test';
        ac.BillingCity = 'test';
        ac.BillingCountry = 'Singapore';
        ac.BillingPostalCode = '8373';
       // ac.BillingState = 'test';
        ac.Current_Subscription_Code__c = 'abc';
        ac.account_rule_code__c = 'Standard';
        ac.personemail = 'a1213axy@yaho.com';
        ac.salutation = 'Mr.';
        ac.firstname = 'aaaa';
        ac.Country__c = 'Singapore';
        ac.Subsidiary__c = subId;
        ac.Status__c = 'Active';
        ac.PersonBirthdate = Date.newInstance(1996, 12, 21);
        ac.CEA_Salesperson_Number__c = '123123123';
        insert ac;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = ac.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.Subsidiary__c = subId;
        opp.NetSuite_Sales_Order__c = 'Contract - Renewal';
        opp.RecordTypeId = oppRectype;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        opp.Renewal_State__c = 'Actual Month';
        insert opp;
        
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.Payment_Link__c = '';
        qu.OpportunityId = opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Subsidiary__c = subId; 
        
        insert qu;
        
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only',
                                     Product_Category__c = 'Subscription', SKU_Code__c = 'abc');
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, 
                                                product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe; 
        
        OpportunityLineItem oplineItem = new OpportunityLineItem();
        oplineItem.OpportunityId = opp.id;
        oplineItem.Product2Id = prod.id;
        oplineItem.PricebookEntryId = pbe.id;
        oplineItem.Quantity = 2;
        oplineItem.UnitPrice = 1200;
        insert oplineItem;
        
        //AccountAssignment_BatchSchedulable sh1 = new AccountAssignment_BatchSchedulable();  
        String sch2 = '0 0 0 * * ? *';
        // system.schedule('Test Schedule', sch, sh1);
        
        OpportunityRenewalUpd_BatchSchedulable orbs2 = new OpportunityRenewalUpd_BatchSchedulable();      
        sch2 = '0 0 0 * * ? *';
        system.schedule('Test Schedule Renewal 2', sch2, orbs2);
        
        OpportunityRenewalUpd_BatchSchedulable orbs3 = new OpportunityRenewalUpd_BatchSchedulable();      
        system.schedule('Test Schedule Renewal 3', sch2, orbs3);
        Test.stopTest();
    }
    
    
    
    
}