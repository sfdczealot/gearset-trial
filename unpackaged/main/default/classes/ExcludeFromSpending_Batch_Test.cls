/**
* Created by gianr on 9/21/2018.
*/
@IsTest
public class ExcludeFromSpending_Batch_Test {
    static testMethod void runTest() {
        Test.startTest();
        
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        PGTestDataFactory_v2.initSetupData();
        Subsidiary__c sb1 = PGTestDataFactory.createSubsidiary();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Status__c = 'Active';
        a.Account_Rule_Code__c = 'test';
        a.Subsidiary__pc = sb1.Id;
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = '51231231';
        a.Current_Subscription_Spending_Amount__c = 200;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb1.id;
        opp.PG_Tenure__c = 4;
        opp.Order_Type_Clone__c = 'Contract - Upgrade';
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = false;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = false;
        
        insert opp;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb1.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        insert oli;
        
        opp.OMC_Approved_Date__c = date.today();
        opp.Approval_Status__c = 'OMC Approval Approved';
        opp.StageName = 'Closed Won';
        opp.Months_Included__c = false;
        update opp;
        
        system.debug('iki:' + [select id,total_spending_on_Discretionary_Product__c,Exclude_from_Spending_at__c from opportunity where id = :opp.id]);
        
        ExcludeFromSpending_BatchSchedulable schedulable = new ExcludeFromSpending_BatchSchedulable(a.id, true);
        String sch = '0 0 0 * * ? *';
        system.schedule('Test Schedule', sch, schedulable);
        ExcludeFromSpending_BatchSchedulable schedulable2 = new ExcludeFromSpending_BatchSchedulable('', false);
        String sch2 = '0 0 0 * * ? *';
        system.schedule('Test Schedule2', sch2, schedulable2);
        /*
        String CRON_EXP = '0 0 0 15 3 ? 2022';
              
              // Schedule the test job
              String jobId = System.schedule('Test my class',
                                CRON_EXP, 
                                new ExcludeFromSpending_BatchSchedulable(a.id));
        
              // Get the information from the CronTrigger API object
              CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                 NextFireTime
                 FROM CronTrigger WHERE id = :jobId];
        
              // Verify the expressions are the same
              System.assertEquals(CRON_EXP, 
                 ct.CronExpression);
        
              // Verify the job has not run
              System.assertEquals(0, ct.TimesTriggered);
        
              // Verify the next time the job will run
              System.assertEquals('2022-03-15 00:00:00', 
                 String.valueOf(ct.NextFireTime));*/
        
        //ExcludeFromSpending_Batch exclude_subs = new ExcludeFromSpending_Batch(a.id); 
        //Database.executeBatch(exclude_subs);
        Test.stopTest();
    }
    static testMethod void runTest2() {
        Test.startTest();
        
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
         PGTestDataFactory_v2.initSetupData();
        Subsidiary__c sb1 = PGTestDataFactory.createSubsidiary();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Status__c = 'Active';
        a.Account_Rule_Code__c = 'test';
        a.Subsidiary__pc = sb1.Id;
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = '51231231';
        a.Current_Subscription_Spending_Amount__c = 200;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb1.id;
        opp.PG_Tenure__c = 4;
        opp.Order_Type_Clone__c = 'Contract - Upgrade';
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = false;
        
        insert opp;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb1.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        insert oli;
        
        opp.OMC_Approved_Date__c = date.today().addMonths(-13);
        opp.Approval_Status__c = 'OMC Approval Approved';
        opp.StageName = 'Closed Won';
        update opp;
        
        system.debug('iki:' + [select id,total_spending_on_Discretionary_Product__c,Exclude_from_Spending_at__c from opportunity where id = :opp.id]);
        
        ExcludeFromSpending_BatchSchedulable schedulable = new ExcludeFromSpending_BatchSchedulable(a.id, true);
        String sch = '0 0 0 * * ? *';
        system.schedule('Test Schedule', sch, schedulable);
        ExcludeFromSpending_BatchSchedulable schedulable2 = new ExcludeFromSpending_BatchSchedulable('', false);
        String sch2 = '0 0 0 * * ? *';
        system.schedule('Test Schedule2', sch2, schedulable2);
        /*
        String CRON_EXP = '0 0 0 15 3 ? 2022';
              
              // Schedule the test job
              String jobId = System.schedule('Test my class',
                                CRON_EXP, 
                                new ExcludeFromSpending_BatchSchedulable(a.id));
        
              // Get the information from the CronTrigger API object
              CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                 NextFireTime
                 FROM CronTrigger WHERE id = :jobId];
        
              // Verify the expressions are the same
              System.assertEquals(CRON_EXP, 
                 ct.CronExpression);
        
              // Verify the job has not run
              System.assertEquals(0, ct.TimesTriggered);
        
              // Verify the next time the job will run
              System.assertEquals('2022-03-15 00:00:00', 
                 String.valueOf(ct.NextFireTime));*/
        
        //ExcludeFromSpending_Batch exclude_subs = new ExcludeFromSpending_Batch(a.id); 
        //Database.executeBatch(exclude_subs);
        Test.stopTest();
    }
}