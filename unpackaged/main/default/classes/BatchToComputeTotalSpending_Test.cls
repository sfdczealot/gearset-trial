@istest
public class BatchToComputeTotalSpending_Test {
    public testMethod static void runTest() {    
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'PGCampaignEligibilityTrigger';
        TE2.Enable_del__c = true;
        insert TE2;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Trigger_Execute__c customsetting2=new Trigger_Execute__c();
        customsetting2.Name='Trigger_OpportunitySplit';
        customsetting2.Enable_del__c=true;
        insert customsetting2;
        
        Rewards_Calculator__c customsetting1  = new Rewards_Calculator__c();
        customsetting1.Name='Singapore';
        customsetting1.X_factor__c=8;
        customsetting1.Y_factor__c=5;
        customsetting1.country__c='Singapore';
        insert customsetting1;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        id subId =  PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount1 = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        listAccount1.add(agency);
        
        insert listAccount1;
        
        list<Account> listAccount = new list<Account>();
        Account acc = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc.FirstName = 'TestMe';
        acc.LastName = 'Lasting';
        acc.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc.Salutation = 'Mrs.';
        acc.CurrencyIsoCode = 'SGD';
        acc.Agency__c = agency.Id;
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Singapore';
        acc.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        //acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='A738392A';
        acc.PGF_Reward_Points__c = 650;
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        //acc.OwnerId = us.id;
        listAccount.add(acc); 
        
        
        
        Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.PGF_Reward_Points__c = 350;
        acc1.CEA_Salesperson_Number__c='A838292A';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2020, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        //acc1.OwnerId = us.id;
        listAccount.add(acc1); 
        
        insert listAccount;
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = subId,  IsActive = true, CurrencyIsoCode = 'SGD');
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
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = subId;
        opp.Total_Spending__c = 100;
        opp.CurrencyIsoCode = 'SGD';
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp';
        opp1.StageName = 'Proposal';
        opp1.AccountId = acc1.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.Subsidiary__c = subId;
        opp1.Total_Spending__c = 100;
        opp1.RecordTypeId = oppRectype;
        opp1.PG_Tenure__c = 1;
        opp1.CurrencyIsoCode = 'SGD';
        opp1.count_of_subscription_item_new__c = 100.0;
        opp1.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp1.Order_Type_Clone__c = 'Contract - Renewal';
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.CurrencyIsoCode = 'SGD';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        insert prm1;
        
        insert opp1;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp1.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        oli.Quantity = 20;
        oli.SNo__c = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp1.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        oli2.GST_VAT_Rate__c  = 2;
        oli2.Quantity = 20;
        oli2.SNo__c = 2;
        insert oli2;
        
        opp1.Approval_Status__c = 'OMC Approval Approved';
        opp1.StageName = 'Closed Won';
        update opp1;
        
        
        Financial__c FinRec = new Financial__c();
        FinRec.NetSuite_Id__c = '3763639';
        FinRec.Type__c = 'Invoice';
        FinRec.Name = 'PG/Test';
        FinRec.Opportunity__c = opp.Id;
        FinRec.Discretionary_Total__c = 565;
        FinRec.Subscription_Total__c = 6576;
        insert FinRec;
        
        Financial__c FinRec1 = new Financial__c();
        FinRec1.NetSuite_Id__c = '3703639';
        FinRec1.Type__c = 'Credit Memo';
        FinRec1.Name = 'PG/Test';
        FinRec1.Opportunity__c = opp.Id;
        FinRec1.Discretionary_Total__c = 65;
        FinRec1.Subscription_Total__c = 576;
        insert FinRec1;
        }
        Test.startTest();
        Date d = date.newInstance(2021, 10, 10);
        BatchToComputeTotalSpending_Scheduler obj = new BatchToComputeTotalSpending_Scheduler();
        BatchToComputeTotalSpending obj1=new BatchToComputeTotalSpending('Singapore',True);
        obj1.calculateCED(True,'Singapore');
        database.executebatch(obj1);
        BatchToComputeTotalSpending_Scheduler.scdeuleJob(d);
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 9, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 11, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 2, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 4, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 6, 1));
        Test.stopTest();
        
    }
    
    public testMethod static void runTest2() {
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'PGCampaignEligibilityTrigger';
        TE2.Enable_del__c = true;
        insert TE2;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Trigger_Execute__c customsetting2=new Trigger_Execute__c();
        customsetting2.Name='Trigger_OpportunitySplit';
        customsetting2.Enable_del__c=true;
        insert customsetting2;
        
        Rewards_Calculator__c customsetting1  = new Rewards_Calculator__c();
        customsetting1.Name='Singapore';
        customsetting1.X_factor__c=8;
        customsetting1.Y_factor__c=5;
        customsetting1.country__c='Singapore';
        insert customsetting1;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        id subId =  PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount1 = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        listAccount1.add(agency);
        insert listAccount1;
        
        list<Account> listAccount = new list<Account>();
        Account acc = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc.FirstName = 'TestMe';
        acc.LastName = 'Lasting';
        acc.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc.Salutation = 'Mrs.';
        acc.CurrencyIsoCode = 'SGD';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Singapore';
        acc.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='A524596A';
        acc.PGF_Reward_Points__c = 1250;
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 10);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        //  acc.calledFromBatch = false;
        //  acc.Calculation_end_date = Date.newInstance(2018, 11, 10) ;
        listAccount.add(acc); 
        
        
        
        Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.PGF_Reward_Points__c = 2550;
        acc1.CEA_Salesperson_Number__c='A783929A';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2020, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        //  acc1.calledFromBatch = false;
        //  acc1.Calculation_end_date = Date.newInstance(2018, 11, 10) ;
        listAccount.add(acc1); 
        
        insert listAccount;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = subId,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = subId;
        opp.Total_Spending__c = 100;
        opp.CurrencyIsoCode = 'SGD';
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp';
        opp1.StageName = 'Proposal';
        opp1.AccountId = acc1.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.Subsidiary__c = subId;
        opp1.Total_Spending__c = 100;
        opp1.RecordTypeId = oppRectype;
        opp1.CurrencyIsoCode = 'SGD';
        opp1.PG_Tenure__c = 1;
        opp1.count_of_subscription_item_new__c = 100.0;
        opp1.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp1.Order_Type_Clone__c = 'Contract - Renewal';
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.CurrencyIsoCode = 'SGD';
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        insert prm1;
        
        insert opp1;
        
        opp1.Approval_Status__c = 'OMC Approval Approved';
        opp1.StageName = 'Closed Won';
        update opp1;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp1.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        oli.Quantity = 20;
        oli.SNo__c = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp1.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        oli2.GST_VAT_Rate__c  = 2;
        oli2.Quantity = 20;
        oli2.SNo__c = 2;
        insert oli2;
        
        
        
        
        Financial__c FinRec = new Financial__c();
        FinRec.NetSuite_Id__c = '3763639';
        FinRec.Type__c = 'Invoice';
        FinRec.Name = 'PG/Test';
        FinRec.Opportunity__c = opp.Id;
        FinRec.Discretionary_Total__c = 565;
        FinRec.Subscription_Total__c = 6576;
        insert FinRec;
        
        Financial__c FinRec1 = new Financial__c();
        FinRec1.NetSuite_Id__c = '3703639';
        FinRec1.Type__c = 'Credit Memo';
        FinRec1.Name = 'PG/Test';
        FinRec1.Opportunity__c = opp.Id;
        FinRec1.Discretionary_Total__c = 65;
        FinRec1.Subscription_Total__c = 576;
        insert FinRec1;
        }
        Test.startTest();
        Date d = date.newInstance(2021, 10, 10);
        BatchToComputeTotalSpending_Scheduler obj = new BatchToComputeTotalSpending_Scheduler();
        BatchToComputeTotalSpending obj1=new BatchToComputeTotalSpending('Singapore',false);
        obj1.calculateCED(True,'Singapore');
        database.executeBatch(obj1);
        BatchToComputeTotalSpending_Scheduler.scdeuleJob(d);
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 9, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 11, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 2, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 4, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 6, 1));
        //  BatchToComputeTotalSpending.computeTotalSpending(scope,Calculation_end_date,xFactor,yFactor,calledFromBatch);
        //   BatchToComputeTotalSpending.returnRewardFactors();
        // BatchToComputeTotalSpending.calculateCED(date.newInstance(2021, 4, 1));
        // BatchToComputeTotalSpending.calculateCED(date.newInstance(2021, 6, 1));
        Test.stopTest();
        
    }
    
    
    public testMethod static void runTest1() {
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'PGCampaignEligibilityTrigger';
        TE2.Enable_del__c = true;
        insert TE2;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Rewards_Calculator__c customsetting1  = new Rewards_Calculator__c();
        customsetting1.Name='Singapore';
        customsetting1.X_factor__c=8;
        customsetting1.Y_factor__c=5;
        customsetting1.country__c='Singapore';
        insert customsetting1;
        
        Trigger_Execute__c customsetting2=new Trigger_Execute__c();
        customsetting2.Name='Trigger_OpportunitySplit';
        customsetting2.Enable_del__c=true;
        insert customsetting2;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();
        
        id subId =  PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount1 = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        listAccount1.add(agency);
        insert listAccount1;
        
        list<Account> listAccount = new list<Account>();
        Account acc = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc.FirstName = 'TestMe';
        acc.LastName = 'Lasting';
        acc.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc.Salutation = 'Mrs.';
        acc.CurrencyIsoCode = 'SGD';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Singapore';
        acc.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='A876567A';
        acc.PGF_Reward_Points__c = 20;
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 10);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        //  acc.calledFromBatch = false;
        //  acc.Calculation_end_date = Date.newInstance(2018, 11, 10) ;
        listAccount.add(acc); 
        
        
        
        Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc.PGF_Reward_Points__c = 20;
        acc1.CEA_Salesperson_Number__c='A987654A';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2020, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        //  acc1.calledFromBatch = false;
        //  acc1.Calculation_end_date = Date.newInstance(2018, 11, 10) ;
        listAccount.add(acc1); 
        
        insert listAccount;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = subId,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = subId;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.CurrencyIsoCode = 'SGD';
        opp.count_of_subscription_item_new__c = 100.0;
        opp.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp';
        opp1.StageName = 'Converted';
        opp1.AccountId = acc1.id;
        opp1.CloseDate = system.today().AddDays(-90);
        opp1.Subsidiary__c = subId;
        opp1.Total_Spending__c = 100;
        opp1.RecordTypeId = oppRectype;
        opp1.PG_Tenure__c = 1;
        opp1.CurrencyIsoCode = 'SGD';
        opp1.count_of_subscription_item_new__c = 100.0;
        opp1.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp1.Order_Type_Clone__c = 'Contract - Renewal';
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.CurrencyIsoCode = 'SGD';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        insert prm1;
        
        insert opp1;
        
        opp1.Approval_Status__c = 'OMC Approval Approved';
        //opp1.StageName = 'Closed Won';
        update opp1;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp1.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        oli.Quantity = 20;
        oli.SNo__c = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp1.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        oli2.GST_VAT_Rate__c  = 2;
        oli2.Quantity = 20;
        oli2.SNo__c = 2;
        insert oli2;
        
        
        
        
        Financial__c FinRec = new Financial__c();
        FinRec.NetSuite_Id__c = '3763639';
        FinRec.Type__c = 'Invoice';
        FinRec.Name = 'PG/Test';
        FinRec.Opportunity__c = opp.Id;
        FinRec.Discretionary_Total__c = 565;
        FinRec.Subscription_Total__c = 6576;
        insert FinRec;
        
        Financial__c FinRec1 = new Financial__c();
        FinRec1.NetSuite_Id__c = '3703639';
        FinRec1.Type__c = 'Credit Memo';
        FinRec1.Name = 'PG/Test';
        FinRec1.Opportunity__c = opp.Id;
        FinRec1.Discretionary_Total__c = 65;
        FinRec1.Subscription_Total__c = 576;
        insert FinRec1;
        }
        Test.startTest();
        Date d = date.newInstance(2021, 10, 10);
        BatchToComputeTotalSpending_Scheduler obj = new BatchToComputeTotalSpending_Scheduler();
        BatchToComputeTotalSpending obj1=new BatchToComputeTotalSpending('Singapore',false);
        obj1.calculateCED(True,'Singapore');
        database.executeBatch(obj1);
        BatchToComputeTotalSpending_Scheduler.scdeuleJob(d);
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 9, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 11, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 2, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 4, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 6, 1));
        //  BatchToComputeTotalSpending.computeTotalSpending(scope,Calculation_end_date,xFactor,yFactor,calledFromBatch);
        //   BatchToComputeTotalSpending.returnRewardFactors();
        // BatchToComputeTotalSpending.calculateCED(date.newInstance(2021, 4, 1));
        // BatchToComputeTotalSpending.calculateCED(date.newInstance(2021, 6, 1));
        Test.stopTest();  
    }
    public testMethod static void runTest4() {
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c customsetting2=new Trigger_Execute__c();
        customsetting2.Name='Trigger_OpportunitySplit';
        customsetting2.Enable_del__c=true;
        insert customsetting2;
        
        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'PGCampaignEligibilityTrigger';
        TE2.Enable_del__c = true;
        insert TE2;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Rewards_Calculator__c customsetting1  = new Rewards_Calculator__c();
        customsetting1.Name='Singapore';
        customsetting1.X_factor__c=8;
        customsetting1.Y_factor__c=5;
        customsetting1.country__c='Singapore';
        insert customsetting1;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();
        
        id subId =  PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount1 = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        listAccount1.add(agency);
        insert listAccount1;
        
        list<Account> listAccount = new list<Account>();
        Account acc = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc.FirstName = 'TestMe';
        acc.LastName = 'Lasting';
        acc.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc.Salutation = 'Mrs.';
        acc.CurrencyIsoCode = 'SGD';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Singapore';
        acc.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='A765432A';
        acc.PGF_Reward_Points__c = 20;
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2023, 01, 31);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        //  acc.calledFromBatch = false;
        //  acc.Calculation_end_date = Date.newInstance(2018, 11, 10) ;
        listAccount.add(acc); 
        
        
        
        Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc.PGF_Reward_Points__c = 20;
        acc1.CEA_Salesperson_Number__c='A987654A';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 01, 31);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        //  acc1.calledFromBatch = false;
        //  acc1.Calculation_end_date = Date.newInstance(2018, 11, 10) ;
        listAccount.add(acc1); 
        
        insert listAccount;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = subId,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = subId;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.CurrencyIsoCode = 'SGD';
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp';
        opp1.StageName = 'Converted';
        opp1.AccountId = acc1.id;
        opp1.CurrencyIsoCode = 'SGD';
        opp1.CloseDate = system.today().AddDays(-90);
        opp1.Subsidiary__c = subId;
        opp1.Total_Spending__c = 100;
        opp1.RecordTypeId = oppRectype;
        opp1.PG_Tenure__c = 1;
        opp1.count_of_subscription_item_new__c = 100.0;
        opp1.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp1.Order_Type_Clone__c = 'Contract - Renewal';
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.CurrencyIsoCode = 'SGD';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        insert prm1;
        
        insert opp1;
        
        opp1.Approval_Status__c = 'OMC Approval Approved';
        //opp1.StageName = 'Closed Won';
        update opp1;
        
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp1.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        oli.Quantity = 20;
        oli.SNo__c = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp1.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        oli2.GST_VAT_Rate__c  = 2;
        oli2.Quantity = 20;
        oli2.SNo__c = 2;
        insert oli2;
        
        
        
        
        Financial__c FinRec = new Financial__c();
        FinRec.NetSuite_Id__c = '3763639';
        FinRec.Type__c = 'Invoice';
        FinRec.Name = 'PG/Test';
        FinRec.Opportunity__c = opp.Id;
        FinRec.Discretionary_Total__c = 565;
        FinRec.Subscription_Total__c = 6576;
        insert FinRec;
        
        Financial__c FinRec1 = new Financial__c();
        FinRec1.NetSuite_Id__c = '3703639';
        FinRec1.Type__c = 'Credit Memo';
        FinRec1.Name = 'PG/Test';
        FinRec1.Opportunity__c = opp.Id;
        FinRec1.Discretionary_Total__c = 65;
        FinRec1.Subscription_Total__c = 576;
        insert FinRec1;
        
        Test.startTest();
        Date d = date.newInstance(2021, 10, 10);
        BatchToComputeTotalSpending_Scheduler obj = new BatchToComputeTotalSpending_Scheduler();
        BatchToComputeTotalSpending obj1=new BatchToComputeTotalSpending('Singapore',false);
        database.executeBatch(obj1);
        obj1.calculateCED(True,'Singapore');
        BatchToComputeTotalSpending_Scheduler.scdeuleJob(d);
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 9, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 11, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 2, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 4, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 6, 1));
        }
        Test.stopTest();  
    }
    public testMethod static void runTest3() {
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Thailand' and isActive = true and profile.name = 'TH B2C Sales User' Limit 1];
        System.runAs (thisUser) {
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c customsetting2=new Trigger_Execute__c();
            customsetting2.Name='PGOpportunityTrigger';
            customsetting2.Enable_del__c=true;
            insert customsetting2;
            
            Trigger_Execute__c customsetting3=new Trigger_Execute__c();
            customsetting3.Name='Trigger_OpportunitySplit';
            customsetting3.Enable_del__c=true;
            insert customsetting3;
            
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGCampMemberTrigger';
            TE.Enable_del__c = true;
            insert TE;
            
            Trigger_Execute__c TE2 = new Trigger_Execute__c();
            TE2.Name = 'PGCampaignEligibilityTrigger';
            TE2.Enable_del__c = true;
            insert TE2;
            
            Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
            TEPromoMech.Name = 'PGPromoMechanicTrigger';
            TEPromoMech.Enable_del__c = true;
            insert TEPromoMech;
            
            Rewards_Calculator__c customsetting1  = new Rewards_Calculator__c();
            customsetting1.Name='Thailand';
            customsetting1.X_factor__c=8;
            customsetting1.Y_factor__c=5;
            customsetting1.country__c='Thailand';
            insert customsetting1;
            
            string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();
            
            id subId =  PGTestDataFactory.createSubsidiary().Id;
            list<Account> listAccount1 = new list<Account>();
            
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Thailand';
            //agency.OwnerId = u.Id;
            agency.Subsidiary__c = subId;
            listAccount1.add(agency);
            insert listAccount1;
            system.debug('owner of agency'+listAccount1[0].OwnerId);
            list<Account> listAccount = new list<Account>();
            Account acc = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc.FirstName = 'TestMe';
            acc.LastName = 'Lasting';
            acc.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc.Salutation = 'Mrs.';
            acc.CurrencyIsoCode = 'THB';
            acc.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc.BillingStreet = 'test';
            acc.BillingCity = 'test';
            acc.PersonMobilePhone = '4686868';
            acc.Mobile_Country__c = '66';
            acc.BillingCountry = 'Thailand';
            acc.BillingPostalCode = '83773';
            //  acc.BillingState = 'test';
            acc.Current_Subscription_Code__c = 'abc';
            acc.PersonEmail = 'test@yuni.com';
            acc.Account_Rule_Code__c = 'PRO';
            acc.Status__c = 'ACTIVE';
            acc.Country__c = 'Thailand';
            acc.Agency__c = agency.id;
            acc.Subsidiary__c = subId;
            acc.CEA_Salesperson_Number__c='A876567A';
            acc.PGF_Reward_Points__c = 20;
            acc.PersonBirthdate=system.today();
            acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 10);
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc.VIP_Campaign__c = 'VIP Advance SC';
            acc.Approval_Status__c = 'Test';
            //  acc.calledFromBatch = false;
            //  acc.Calculation_end_date = Date.newInstance(2018, 11, 10) ;
            listAccount.add(acc); 
            
            
            
            Account acc1 = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc1.FirstName = 'TestMe';
            acc1.LastName = 'Lasting';
            acc1.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc1.Salutation = 'Mrs.';
            acc1.CurrencyIsoCode = 'THB';
            acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc1.BillingStreet = 'test';
            acc1.BillingCity = 'test';
            acc1.PersonMobilePhone = '546587979';
            acc1.Mobile_Country__c = '66';
            acc1.BillingCountry = 'Thailand';
            acc1.BillingPostalCode = '83763';
            //  acc.BillingState = 'test';
            acc1.Current_Subscription_Code__c = 'abc';
            acc1.PersonEmail = 'test@yuni.com';
            acc1.Account_Rule_Code__c = 'PRO';
            acc1.Status__c = 'Active';
            acc1.Country__c = 'Thailand';
            acc1.Agency__c = agency.id;
            acc1.Subsidiary__c = subId;
            acc.PGF_Reward_Points__c = 20;
            acc1.CEA_Salesperson_Number__c='A987654A';
            acc1.PersonBirthdate=system.today();
            acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc1.Loyalty_Start_Date__c = Date.newInstance(2020, 12, 9);
            acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc1.VIP_Campaign__c = 'VIP Advance SC';
            acc1.Approval_Status__c = 'Test';
            //  acc1.calledFromBatch = false;
            //  acc1.Calculation_end_date = Date.newInstance(2018, 11, 10) ;
            listAccount.add(acc1); 
            
            insert listAccount;
            
            Tax_Code__c taxcode = new Tax_Code__c();
            taxcode.Name = 'SG - 7% GST';
            taxcode.Tax_Rate__c =  7;
            taxcode.Country__c = 'Thailand';
            insert taxcode;
            
            Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = subId,  IsActive = true, CurrencyIsoCode = 'THB');
            insert standardPB;
            
            Product_Class__c productClass = new Product_Class__c(Name = 'Subscription', CurrencyIsoCode = 'THB');
            insert productClass;
            
            
            Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'THB',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
            insert prod;
            Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'THB',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
            insert prod2;
            Id StdpricebookId = Test.getStandardPricebookId();
            
            PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'THB', useStandardPrice = false);
            insert pbe1;
            
            PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'THB', useStandardPrice = false);
            insert pbe2;
            
            List<Opportunity> opportunityList = new List<Opportunity>();
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'New';
            opp.AccountId = acc.id;
            opp.CloseDate = system.today().AddDays(30);
            //opp.Subsidiary__c = subId;
            opp.Total_Spending__c = 100;
            opp.CurrencyIsoCode = 'THB';
            opp.RecordTypeId = oppRectype;
            opp.PG_Tenure__c = 1;
            opp.count_of_subscription_item_new__c = 100.0;
            opp.OMC_Approved_Date__c = System.today().addmonths(-6);
            opp.Order_Type_Clone__c = 'Contract - Renewal';
            insert opp;
            
            Opportunity opp1 = new opportunity();
            opp1.Name = 'Test Opp';
            opp1.StageName = 'Converted';
            opp1.AccountId = acc1.id;
            opp1.CurrencyIsoCode = 'THB';
            opp1.CloseDate = system.today().AddDays(-90);
            //opp1.Subsidiary__c = subId;
            opp1.Total_Spending__c = 100;
            opp1.RecordTypeId = oppRectype;
            opp1.PG_Tenure__c = 1;
            opp1.count_of_subscription_item_new__c = 100.0;
            opp1.OMC_Approved_Date__c = System.today().addmonths(-6);
            opp1.Order_Type_Clone__c = 'Contract - Renewal';
            
            Campaign cma = new Campaign();
            cma.Name = 'TestNameCampaign';
            cma.Country__c = 'Thailand';
            cma.CurrencyIsoCode = 'THB';
            cma.IsActive = true;
            cma.EndDate = system.today().addDays(-2);
            insert cma;
            
            Contact con = new Contact();
            con.FirstName = 'TestFName';
            con.LastName = 'testLname';
            con.Email = 'test@nmail.com';
            insert con;
            
            CampaignMember cmp = new CampaignMember();
            cmp.ContactId = con.Id;
            cmp.Status = 'Responded';
            cmp.CampaignId = cma.Id;
            insert cmp;
            
            String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
            CampaignInfluence cmi = new CampaignInfluence();
            cmi.CampaignId = cma.Id;
            cmi.OpportunityId = opp.Id;
            cmi.ModelId = modeId;
            insert cmi;
            
            Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
            insert ce1;
            
            Promo_Mechanic__c prm = new Promo_Mechanic__c();
            prm.Name = 'TestName';
            prm.Eligible_Product__c = prod.Id;
            prm.Campaign_Eligibility__c = ce1.Id;
            prm.Usage__c = 1;
            insert prm;
            
            Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
            prm1.Name = 'TestName1';
            prm1.Eligible_Product__c = prod.Id;
            prm1.Campaign_Eligibility__c = ce1.Id;
            prm1.Usage__c = 1;
            insert prm1;
            
            insert opp1;
            
            opp1.Approval_Status__c = 'OMC Approval Approved';
            //opp1.StageName = 'Closed Won';
            update opp1;
            
            List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
            opportunityLineItem oli = new opportunityLineItem();
            oli.Product2Id = prod.Id;
            oli.OpportunityId = opp1.Id;
            oli.PricebookEntryId = pbe2.Id;
            oli.Promo_Mechanic_Id__c = prm.Id;
            oli.Amount_Despite_VIP__c = 1.3;
            oli.Pro_Rate_Amount__c = 2;
            oli.UnitPrice = 2;
            oli.Quantity = 20;
            oli.SNo__c = 2;
            insert oli;
            listOppLine.add(oli);
            
            opportunityLineItem oli2 = new opportunityLineItem();
            oli2.Product2Id = prod2.Id;
            oli2.OpportunityId = opp1.Id;
            oli2.PricebookEntryId = pbe2.Id;
            oli2.Promo_Mechanic_Id__c = prm1.Id;
            oli2.Amount_Despite_VIP__c = 2.3;
            oli2.Pro_Rate_Amount__c = 2;
            oli2.UnitPrice = 2;
            oli2.GST_VAT_Rate__c  = 2;
            oli2.Quantity = 20;
            oli2.SNo__c = 2;
            insert oli2;
            
            
            
            
            Financial__c FinRec = new Financial__c();
            FinRec.NetSuite_Id__c = '3763639';
            FinRec.Type__c = 'Invoice';
            FinRec.Name = 'PG/Test';
            FinRec.Opportunity__c = opp.Id;
            FinRec.Discretionary_Total__c = 565;
            FinRec.Subscription_Total__c = 6576;
            insert FinRec;
            
            Financial__c FinRec1 = new Financial__c();
            FinRec1.NetSuite_Id__c = '3703639';
            FinRec1.Type__c = 'Credit Memo';
            FinRec1.Name = 'PG/Test';
            FinRec1.Opportunity__c = opp.Id;
            FinRec1.Discretionary_Total__c = 65;
            FinRec1.Subscription_Total__c = 576;
            insert FinRec1;
        }  
        Test.startTest();
        Date d = date.newInstance(2021, 10, 10);
        BatchToComputeTotalSpending obj1=new BatchToComputeTotalSpending('Thailand',false);
        obj1.calculateCED(True,'Thailand');
        database.executeBatch(obj1);
        BatchToComputeTotalSpending_Scheduler.scdeuleJob(d);
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 9, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 11, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 2, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 4, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 6, 1));
        //  BatchToComputeTotalSpending.computeTotalSpending(scope,Calculation_end_date,xFactor,yFactor,calledFromBatch);
        //   BatchToComputeTotalSpending.returnRewardFactors();
        // BatchToComputeTotalSpending.calculateCED(date.newInstance(2021, 4, 1));
        // BatchToComputeTotalSpending.calculateCED(date.newInstance(2021, 6, 1));
        Test.stopTest();  
    }
    
    public testMethod static void runTest5() {
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Thailand' and isActive = true and profile.name = 'TH B2C Sales User' Limit 1];
        System.runAs (thisUser) {
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c customsetting2=new Trigger_Execute__c();
        customsetting2.Name='Trigger_OpportunitySplit';
        customsetting2.Enable_del__c=true;
        insert customsetting2;
        
        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'PGCampaignEligibilityTrigger';
        TE2.Enable_del__c = true;
        insert TE2;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Rewards_Calculator__c customsetting1  = new Rewards_Calculator__c();
        customsetting1.Name='Thailand';
        customsetting1.X_factor__c=8;
        customsetting1.Y_factor__c=5;
        customsetting1.country__c='Thailand';
        insert customsetting1;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        id subId =  PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount1 = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Thailand';
        agency.Subsidiary__c = subId;
        listAccount1.add(agency);
        insert listAccount1;
        list<Account> listAccount = new list<Account>();
        Account acc = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc.FirstName = 'TestMe';
        acc.LastName = 'Lasting';
        acc.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc.Salutation = 'Mrs.';
        acc.CurrencyIsoCode = 'THB';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Singapore';
        acc.BillingPostalCode = '83473';
        //  acc.BillingState = 'test';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'PRO';
        acc.PersonMobilePhone = '46586879';
        acc.Mobile_Country__c = '66';
        acc.Status__c = 'Active';
        acc.Country__c = 'Thailand';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='A738392A';
        acc.PGF_Reward_Points__c = 650;
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        listAccount.add(acc); 
        
        
        
        Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'THB';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Thailand';
        acc1.BillingPostalCode = '83743';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test@yuni.com';
        acc1.Account_Rule_Code__c = 'PRO';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Thailand';
        acc1.Agency__c = agency.id;
        acc1.Mobile_Country__c = '66';
        acc1.PersonMobilePhone = '575768689';
        acc1.Subsidiary__c = subId;
        acc1.PGF_Reward_Points__c = 350;
        acc1.CEA_Salesperson_Number__c='A838292A';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2020, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        listAccount.add(acc1); 
        
        insert listAccount;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Thailand';
        insert taxcode;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = subId,  IsActive = true, CurrencyIsoCode = 'THB');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'THB');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'THB',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'THB',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'THB', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'THB', useStandardPrice = false);
        insert pbe2;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = subId;
        opp.Total_Spending__c = 100;
        opp.CurrencyIsoCode = 'THB';
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp';
        opp1.StageName = 'Proposal';
        opp1.AccountId = acc1.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.Subsidiary__c = subId;
        opp1.CurrencyIsoCode = 'THB';
        opp1.Total_Spending__c = 100;
        opp1.RecordTypeId = oppRectype;
        opp1.PG_Tenure__c = 1;
        opp1.count_of_subscription_item_new__c = 100.0;
        opp1.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp1.Order_Type_Clone__c = 'Contract - Renewal';
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Thailand';
        cma.CurrencyIsoCode = 'THB';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        insert prm1;
        
        insert opp1;
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp1.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        oli.Quantity = 20;
        oli.SNo__c = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp1.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        oli2.GST_VAT_Rate__c  = 2;
        oli2.Quantity = 20;
        oli2.SNo__c = 2;
        insert oli2;
        
        opp1.Approval_Status__c = 'OMC Approval Approved';
        opp1.StageName = 'Closed Won';
        update opp1;
        
        
        Financial__c FinRec = new Financial__c();
        FinRec.NetSuite_Id__c = '3763639';
        FinRec.Type__c = 'Invoice';
        FinRec.Name = 'PG/Test';
        FinRec.Opportunity__c = opp.Id;
        FinRec.Discretionary_Total__c = 565;
        FinRec.Subscription_Total__c = 6576;
        insert FinRec;
        
        Financial__c FinRec1 = new Financial__c();
        FinRec1.NetSuite_Id__c = '3703639';
        FinRec1.Type__c = 'Credit Memo';
        FinRec1.Name = 'PG/Test';
        FinRec1.Opportunity__c = opp.Id;
        FinRec1.Discretionary_Total__c = 65;
        FinRec1.Subscription_Total__c = 576;
        insert FinRec1;
        }
        Test.startTest();
        Date d = date.newInstance(2021, 10, 10);
        BatchToComputeTotalSpending_Scheduler obj = new BatchToComputeTotalSpending_Scheduler();
        BatchToComputeTotalSpending obj1=new BatchToComputeTotalSpending('Thailand',True);
        obj1.calculateCED(True,'Thailand');
        database.executeBatch(obj1);
        BatchToComputeTotalSpending_Scheduler.scdeuleJob(d);
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 9, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 11, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 2, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 4, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 6, 1));
        Test.stopTest();
        
    }
    
    public testMethod static void runTest6(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Thailand' and isActive = true and profile.name = 'TH B2C Sales User' Limit 1];
        System.runAs (thisUser) {
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'PGCampaignEligibilityTrigger';
        TE2.Enable_del__c = true;
        insert TE2;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Trigger_Execute__c customsetting2=new Trigger_Execute__c();
        customsetting2.Name='Trigger_OpportunitySplit';
        customsetting2.Enable_del__c=true;
        insert customsetting2;
        
        Rewards_Calculator__c customsetting1  = new Rewards_Calculator__c();
        customsetting1.Name='Thailand';
        customsetting1.X_factor__c=8;
        customsetting1.Y_factor__c=5;
        customsetting1.country__c='Thailand';
        insert customsetting1;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C Self-Serve').getRecordTypeId();
        
        id subId =  PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount1 = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Thailand';
        agency.Subsidiary__c = subId;
        listAccount1.add(agency);
        insert listAccount1;
        list<Account> listAccount = new list<Account>();
        Account acc = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc.FirstName = 'TestMe';
        acc.LastName = 'Lasting';
        acc.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc.Salutation = 'Mrs.';
        acc.CurrencyIsoCode = 'THB';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Singapore';
        acc.BillingPostalCode = '83473';
        //  acc.BillingState = 'test';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'PRO';
        acc.PersonMobilePhone = '46586879';
        acc.Mobile_Country__c = '66';
        acc.Status__c = 'Active';
        acc.Country__c = 'Thailand';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='A738392A';
        acc.PGF_Reward_Points__c = 650;
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        listAccount.add(acc); 
        
        
        
        Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'THB';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Thailand';
        acc1.BillingPostalCode = '83743';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test@yuni.com';
        acc1.Account_Rule_Code__c = 'PRO';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Thailand';
        acc1.Agency__c = agency.id;
        acc1.Mobile_Country__c = '66';
        acc1.PersonMobilePhone = '575768689';
        acc1.Subsidiary__c = subId;
        acc1.PGF_Reward_Points__c = 350;
        acc1.CEA_Salesperson_Number__c='A838292A';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2020, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        listAccount.add(acc1); 
        
        insert listAccount;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Thailand';
        insert taxcode;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = subId,  IsActive = true, CurrencyIsoCode = 'THB');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'THB');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'THB',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'THB',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'THB', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'THB', useStandardPrice = false);
        insert pbe2;
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.AccountId = acc.id;
        opp.CloseDate = Date.newInstance(2021, 03, 04);
        opp.Subsidiary__c = subId;
        opp.Total_Spending__c = 100;
        opp.CurrencyIsoCode = 'THB';
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp';
        opp1.StageName = 'Converted';
        opp1.AccountId = acc1.id;
        opp1.CloseDate = Date.newInstance(2021, 03, 04);
        opp1.Subsidiary__c = subId;
        opp1.CurrencyIsoCode = 'THB';
        opp1.Total_Spending__c = 100;
        opp1.RecordTypeId = oppRectype;
        opp1.PG_Tenure__c = 1;
        opp1.count_of_subscription_item_new__c = 100.0;
        opp1.OMC_Approved_Date__c = System.today().addmonths(-6);
        opp1.Order_Type_Clone__c = 'Contract - Renewal';
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Thailand';
        cma.CurrencyIsoCode = 'THB';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Responded';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        String modeId = [SELECT Id, DeveloperName FROM CampaignInfluenceModel where DeveloperName = 'primaryModel'].Id;
        CampaignInfluence cmi = new CampaignInfluence();
        cmi.CampaignId = cma.Id;
        cmi.OpportunityId = opp.Id;
        cmi.ModelId = modeId;
        insert cmi;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id);     
        insert ce1;
        
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = 'TestName';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce1.Id;
        prm.Usage__c = 1;
        insert prm;
        
        Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        insert prm1;
        
        insert opp1;
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp1.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        oli.Quantity = 20;
        oli.SNo__c = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp1.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        oli2.GST_VAT_Rate__c  = 2;
        oli2.Quantity = 20;
        oli2.SNo__c = 2;
        insert oli2;
        
        opp1.Approval_Status__c = 'OMC Approval Approved';
        opp1.StageName = 'Closed Won';
        update opp1;
        
        
        Financial__c FinRec = new Financial__c();
        FinRec.NetSuite_Id__c = '3763639';
        FinRec.Type__c = 'Invoice';
        FinRec.Name = 'PG/Test';
        FinRec.Opportunity__c = opp.Id;
        FinRec.Discretionary_Total__c = 565;
        FinRec.Subscription_Total__c = 6576;
        insert FinRec;
        
        Financial__c FinRec1 = new Financial__c();
        FinRec1.NetSuite_Id__c = '3703639';
        FinRec1.Type__c = 'Credit Memo';
        FinRec1.Name = 'PG/Test';
        FinRec1.Opportunity__c = opp.Id;
        FinRec1.Discretionary_Total__c = 65;
        FinRec1.Subscription_Total__c = 576;
        insert FinRec1;
        }
        
        Test.startTest();
        Date d = date.newInstance(2021, 10, 10);
        BatchToComputeTotalSpending_Scheduler obj = new BatchToComputeTotalSpending_Scheduler();
        BatchToComputeTotalSpending obj1=new BatchToComputeTotalSpending('Thailand',True);
        obj1.calculateCED(True,'Thailand');
        database.executeBatch(obj1);
        BatchToComputeTotalSpending_Scheduler.scdeuleJob(d);
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 9, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 11, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 2, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 4, 1));
        BatchToComputeTotalSpending_Scheduler.calculateCED(date.newInstance(2021, 6, 1));
        Test.stopTest();
    }
}