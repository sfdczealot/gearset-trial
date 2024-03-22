@isTest
public with sharing class UpdateOnClosedWonTriggerHandler_Test {
    @isTest
    static void Method1(){
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'PGAccountTrigger';
        TE1.Enable_del__c = true;
        insert TE1;

        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'UpdateOnClosedWonTrigger';
        TE2.Enable_del__c = true;
        insert TE2;

        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();

        Set<Id> accset = New Set<Id>();
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
        a.Current_Subscription_Code__c = 'abc';
        a.Current_Subscription_Spending_Amount__c = 50;
        a.Pro_Rate_Amount__c =10;
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.AgentKey__c = 'UT91919';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.PersonBirthdate = date.newInstance(1970, 1, 1);
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'I1234567J';
        a.PersonBirthdate=system.today();
        insert a;
        accset.add(a.id);

        Map<Id, Opportunity> mapUpdateOppTest = New Map<Id, Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Summary_Of_Subscription_Item_new__c = 10.00;
        opp.OMC_Submitted_Time__c = system.today();
        opp.Approval_Status__c = 'OMC Approval Approved';
        opp.Opportunity_Type__c='B2C - Upgrade';
        opp.Pro_Rate__c=7;
        opp.OMC_Approved_Date__c= system.today();
        opp.Is_Current_Subscription__c = true;
        opp.Include_Subscription_Ext__c= true;
        insert opp;
        opp.OMC_Approved_Date__c= system.today().adddays(10);
        update opp;
        mapUpdateOppTest.put(opp.id,opp);
        system.debug('check'+ [Select id,name ,(select id,name from opportunities) from Account]);


        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;

        Product_Class__c prodClass = New Product_Class__c(Name='Subscription',	CurrencyIsoCode='SGD');
        insert prodClass;

        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                     ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
        insert prod;
        prod.Product_Category__c = 'Subscription';
        update prod;


        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id ,unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;

        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Quantity = 500;
        oli.Start_Date__c= system.today();
        oli.End_Date__c =system.today().adddays(1);
        oli.UnitPrice = 10000;
        oli.Product_Category__c = 'Subscription';
        oli.Complimentary__c = false;
        oli.Discount_Reason__c ='First-Timer Discount';
        oli.Amount_Despite_VIP__c = 10;
        insert oli;
        listOppLine.add(oli);
        system.debug('checkoli'+ [Select id,name ,AccountId,(select id from  opportunityLineItems) from opportunity]);

        List<Error_Log__c> listOfErr = new List<Error_Log__c>();
        Error_Log__c ErrLog =  new Error_Log__c();
        ErrLog.Related_Record_Id__c='TestRecordId';
        ErrLog.Data_To_Update__c = 'abcdefg';
        ErrLog.Error_Message__c='vvvvqqqq';
        ErrLog.CurrencyIsoCode='SGD';
        insert ErrLog;
        listOfErr.add(ErrLog);

        EventBus.publish(new Updates_On_Closed_Won__e(
            Account_Id__c = a.id,
            Opportunity_Id__c = opp.Id
        ));
    }
    @isTest
    static void Method2(){
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'PGAccountTrigger';
        TE1.Enable_del__c = true;
        insert TE1;

        Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'UpdateOnClosedWonTrigger';
        TE2.Enable_del__c = true;
        insert TE2;

        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Account ag = new Account();
        ag.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        ag.Name = 'AgencyName';
        ag.Customer_Type__c = 'Agency';
        ag.CEA_License__c = 'CEALC';
        ag.Agency_Id__c = 'Test Agency Id';

        insert ag;



        Set<Id> accset = New Set<Id>();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.Agency__c = ag.Id;
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        a.Current_Subscription_Code__c = 'abc';
        a.Current_Subscription_Spending_Amount__c = 50;
        a.Pro_Rate_Amount__c = 10;
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.AgentKey__c = 'UT91919';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.PersonBirthdate = date.newInstance(1970, 1, 1);
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'I1234567J';
        a.PersonBirthdate=system.today();
        insert a;
        a.Pro_Rate_Amount__c = null;
        update a;
        accset.add(a.id);

        Account a1 = new Account();
        a1.RecordTypeId = accRectype;
        a1.Agency_Name__c =	'PropNex Realty';
        a1.PersonMobilePhone = '7777755555';
        a1.Account_Rule_Code__c='TRIAL';
        a1.FirstName = 'IsYuni';
        a1.LastName = 'TestYuni';
        a1.AgentNet_ID__c = '666513';
        a1.Salutation = 'Mrs.';
        a1.CurrencyIsoCode = 'SGD';
        a1.Subscription_Start_Date__c = system.today().addMonths(-10);
        a1.BillingStreet = 'test';
        a1.BillingCity = 'test';
        a1.BillingCountry = 'Singapore';
        a1.BillingPostalCode = '8373';
        a1.Current_Subscription_Code__c = 'abc';
        a1.Current_Subscription_Spending_Amount__c = 50;
        a1.Pro_Rate_Amount__c = 10;
        a1.PersonEmail = 'test@yuni123.com';
        a1.Account_Rule_Code__c = 'test';
        a1.Previous_Account_Rule__c = 'test';
        a1.AgentKey__c = 'UT91919';
        a1.Status__c = 'Active';
        a1.Country__c = 'Singapore';
        a1.PersonBirthdate = date.newInstance(1970, 1, 1);
        a1.Subscription_End_Date__c = system.today().addMonths(-9);
        a1.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a1.Is_Qualify_Agent_Referral_Program__c = true;
        a1.CEA_Salesperson_Number__c = 'I1234567J';
        a1.PersonBirthdate=system.today();
        insert a1;
        a1.Account_Rule_Code__c='TRIAL';
        update a1;

        Map<Id, Opportunity> mapUpdateOppTest = New Map<Id, Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().Addmonths(-12);
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Summary_Of_Subscription_Item_new__c = 10.00;
        opp.OMC_Submitted_Time__c = system.today();
        opp.Approval_Status__c = 'OMC Approval Approved';
        opp.Opportunity_Type__c='B2C - Upgrade';
        opp.Pro_Rate__c=7;
        opp.OMC_Approved_Date__c= system.today();
        opp.Is_Current_Subscription__c = true;
        opp.Include_Subscription_Ext__c= true;
        insert opp;
        opp.Is_Current_Subscription__c = true;
        opp.ByAuto__c = true;
        opp.Months_Included__c=true;
        update opp;

        mapUpdateOppTest.put(opp.id,opp);

        Test.startTest();

        Opportunity opp1 = new opportunity();
        opp1.Name = 'Test Opp1';
        opp1.StageName = 'Proposal';
        opp1.AccountId = a.id;
        opp1.CloseDate = system.today().Addmonths(12);
        opp1.Total_Spending__c = 100;
        opp1.RecordTypeId = oppRectype;
        opp1.PG_Tenure__c = 1;
        opp1.Summary_Of_Subscription_Item_new__c = 10.00;
        opp1.OMC_Submitted_Time__c = system.today();
        opp1.Approval_Status__c = 'OMC Approval Approved';
        opp1.Opportunity_Type__c='B2C - Standard';
        opp1.Pro_Rate__c=7;
        opp1.OMC_Approved_Date__c= system.today();
        opp1.Is_Current_Subscription__c = true;
        opp1.Include_Subscription_Ext__c= true;
        insert opp1;

        opp1.StageName = 'Closed Won';
        update opp1;

        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book',  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;

        Product_Class__c prodClass = New Product_Class__c(Name='Subscription',	CurrencyIsoCode='SGD');
        insert prodClass;

        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test',  Product_Type__c='PG',Description='DummyText'
                                     ,Is_Bundle__c=true,Product_Class__c = prodClass.id);
        insert prod;
        prod.Product_Category__c = 'Subscription';
        update prod;


        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id ,unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;

        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Quantity = 500;
        oli.Start_Date__c= system.today().adddays(10);
        oli.UnitPrice = 10000;
        oli.Product_Category__c = 'Subscription';
        oli.Complimentary__c = true;
        oli.Discount_Reason__c ='VIP (Relationship)';
        oli.Amount_Despite_VIP__c = 10;
        oli.End_Date__c =system.today().adddays(210);
        insert oli;
        oli.Complimentary__c = false;
        update oli;
        listOppLine.add(oli);


        opportunityLineItem oli1 = new opportunityLineItem();
        oli1.Product2Id = prod.Id;
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbe2.Id;
        oli1.Quantity = 500;
        oli1.Start_Date__c= system.today().adddays(10);
        oli1.UnitPrice = 10000;
        oli1.Product_Category__c = 'Subscription';
        oli1.Complimentary__c = true;
        oli1.Discount_Reason__c ='VIP (Relationship)';
        oli1.Amount_Despite_VIP__c = 10;
        oli1.End_Date__c =system.today().adddays(210);
        insert oli1;

        EventBus.publish(new Updates_On_Closed_Won__e(
            Account_Id__c = a.id,
            Opportunity_Id__c = opp.Id
        ));
        Test.stopTest();
    }
}