@isTest
public class PGQuoteTriggerHandler_Test {
    public static testMethod void unitTest(){
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        Trigger_Execute__c tE = new Trigger_Execute__c();
        tE.Name = 'QuoteLineItemTriggerPG';     
        insert tE;

        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;

        update runningUser;
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        objcustom.IsTrackingEnable__c = true;
        insert objcustom;
        
        QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Stinger__c = true;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        system.assertEquals(opp.Id,opp.Id,'1');
        
        Quote objquote=new Quote();
        objquote.name='Test';
        objquote.CreatedDate__c=system.today();
        objquote.OpportunityId=opp.Id;
        insert objquote;
        
      
        objquote.Status='Expired';
        update objquote;
        
        Set<Id> setoppId=new Set<Id>{opp.ID};
        PGQuoteOpportunityHelper.expireActiveRenUpgQuote(setoppId);
    }
    @isTest
    public static void changeCampaignMemberStatus(){
        
        Trigger_Execute__c TECM = new Trigger_Execute__c();
        TECM.Name = 'PGCampMemberTrigger';
        TECM.Enable_del__c = true;
        insert TECM;
        
        Trigger_Execute__c TECE = new Trigger_Execute__c();
        TECE.Name = 'PGCampaignEligibilityTrigger';
        TECE.Enable_del__c = true;
        insert TECE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;

        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
        Trigger_Execute__c tE = new Trigger_Execute__c();
        tE.Name = 'QuoteLineItemTrigger';
        insert tE;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        objcustom.IsTrackingEnable__c = true;
        insert objcustom;
        
        Trigger_Execute__c teOLI = new Trigger_Execute__c();
        teOLI.Name = 'Trigger_OpportunityLineItem';
        teOLI.IsTrackingEnable__c = true;
        insert teOLI;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
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
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
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
        opp.StageName = 'Pending Online Payment';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.CurrencyIsoCode = 'SGD';
        insert opp;
        
        opportunityList.add(opp);
        
        List<Quote> quoteList = new List<Quote>();
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.Quote_Type__c = 'B2C - Standard';
        qu.PriceBook2Id = standardPB.Id;
        qu.ContactId = [select Id,PersonContactId from Account where Id =: a.Id].PersonContactId;
        insert qu;
        quoteList.add(qu);
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
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
            
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        insert oli2;
        
        List<quoteLineItem> listQuoLine = new List<quoteLineItem>();
        quoteLineItem qli = new quoteLineItem();
        qli.Product2Id = prod.Id;
        qli.OpportunityLineItemId = oli.Id;
        qli.PricebookEntryId = pbe2.Id;
        qli.Amount_Despite_VIP__c = 1.3;
        qli.Pro_Rate_Amount__c = 2;
        qli.Promo_Mechanic_Id__c = prm.Id;
        qli.UnitPrice = 2;
        qli.QuoteId = qu.Id;
        qli.Quantity = 2;
        insert qli;
        listQuoLine.add(qli);
        
        quoteLineItem qli2 = new quoteLineItem();
        qli2.Product2Id = prod2.Id;
        qli2.OpportunityLineItemId = oli2.Id;
        qli2.PricebookEntryId = pbe2.Id;
        qli2.Amount_Despite_VIP__c = 2.3;
        qli2.Pro_Rate_Amount__c = 2;
        qli2.QuoteId = qu.Id;
        qli2.UnitPrice = 2;
        qli2.Quantity = 2;
        qli2.Promo_Mechanic_Id__c = prm1.Id;
        insert qli2;
        
        Map<Id,Quote> newMap = new Map<Id,Quote>();
        newMap.put(qu.Id,qu);
        Map<Id,Quote> oldMap = new Map<Id,Quote>();
        oldMap.put(qu.Id,qu);
        
        Map<Id,Opportunity> oppOldMap = new Map<Id,Opportunity>();
        oppOldMap.put(opp.Id,opp);
        Trigger_Execute__c tE2 = new Trigger_Execute__c();
        tE2.Name = 'QuoteLineItemTrigger';

        insert tE2;
        oppOldMap.get(opp.Id).StageName = 'Proposal';
        opportunityList[0].Approval_Status__c = 'OMC Approval Approved';
        update opportunityList[0];
        
        Test.startTest();
        PGQuoteTriggerHandler.changeCampaignMemberStatus(quoteList, oldMap);
        oldMap.get(qu.Id).Status = 'Proposal';
        PGQuoteTriggerHandler.changeCampaignMemberStatus(quoteList, oldMap);
        quoteList[0].Approval_Status__c = 'OMC Approval Approved';
        quoteList[0].Status = 'OMC Approval Submitted';
        Test.stopTest();
    }
    @isTest
    public static void changeCampaignMemberStatus1(){

        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        Trigger_Execute__c TECM = new Trigger_Execute__c();
        TECM.Name = 'PGCampMemberTrigger';
        TECM.Enable_del__c = true;
        insert TECM;
        
        Trigger_Execute__c TECE = new Trigger_Execute__c();
        TECE.Name = 'PGCampaignEligibilityTrigger';
        TECE.Enable_del__c = true;
        insert TECE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
        Trigger_Execute__c tE = new Trigger_Execute__c();
        tE.Name = 'QuoteLineItemTrigger';
        insert tE;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        objcustom.IsTrackingEnable__c = true;
        insert objcustom;
        
        Trigger_Execute__c teOLI = new Trigger_Execute__c();
        teOLI.Name = 'Trigger_OpportunityLineItem';
        teOLI.IsTrackingEnable__c = true;
        insert teOLI;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
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
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
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
        opp.StageName = 'Pending Online Payment';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.CurrencyIsoCode = 'SGD';
        insert opp;
        
        opportunityList.add(opp);
        
        List<Quote> quoteList = new List<Quote>();
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.Quote_Type__c = 'B2C - Standard';
        qu.PriceBook2Id = standardPB.Id;
        qu.ContactId = [select Id,PersonContactId from Account where Id =: a.Id].PersonContactId;
        insert qu;
        quoteList.add(qu);
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
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
        prm.Discount_Reason__c = 'VIP (Spending)';
        insert prm;
		
		Promo_Mechanic__c prm1 = new Promo_Mechanic__c();
        prm1.Name = 'TestName1';
        prm1.Eligible_Product__c = prod.Id;
        prm1.Campaign_Eligibility__c = ce1.Id;
        prm1.Usage__c = 1;
        prm1.Discount_Reason__c = 'VIP (Spending)';
        insert prm1;
            
        List<opportunityLineItem> listOppLine = new List<opportunityLineItem>();
        opportunityLineItem oli = new opportunityLineItem();
        oli.Product2Id = prod.Id;
        oli.OpportunityId = opp.Id;
        oli.PricebookEntryId = pbe2.Id;
        oli.Promo_Mechanic_Id__c = prm.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.UnitPrice = 2;
        insert oli;
        listOppLine.add(oli);
        
        opportunityLineItem oli2 = new opportunityLineItem();
        oli2.Product2Id = prod2.Id;
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbe2.Id;
        oli2.Promo_Mechanic_Id__c = prm1.Id;
        oli2.Amount_Despite_VIP__c = 2.3;
        oli2.Pro_Rate_Amount__c = 2;
        oli2.UnitPrice = 2;
        insert oli2;
        
        List<quoteLineItem> listQuoLine = new List<quoteLineItem>();
        quoteLineItem qli = new quoteLineItem();
        qli.Product2Id = prod.Id;
        qli.OpportunityLineItemId = oli.Id;
        qli.PricebookEntryId = pbe2.Id;
        qli.Amount_Despite_VIP__c = 1.3;
        qli.Pro_Rate_Amount__c = 2;
        qli.Promo_Mechanic_Id__c = prm.Id;
        qli.UnitPrice = 2;
        qli.QuoteId = qu.Id;
        qli.Quantity = 2;
        insert qli;
        listQuoLine.add(qli);
        
        quoteLineItem qli2 = new quoteLineItem();
        qli2.Product2Id = prod2.Id;
        qli2.OpportunityLineItemId = oli2.Id;
        qli2.PricebookEntryId = pbe2.Id;
        qli2.Amount_Despite_VIP__c = 2.3;
        qli2.Pro_Rate_Amount__c = 2;
        qli2.QuoteId = qu.Id;
        qli2.UnitPrice = 2;
        qli2.Quantity = 2;
        qli2.Promo_Mechanic_Id__c = prm1.Id;
        insert qli2;
        
        Map<Id,Quote> newMap = new Map<Id,Quote>();
        newMap.put(qu.Id,qu);
        Map<Id,Quote> oldMap = new Map<Id,Quote>();
        oldMap.put(qu.Id,qu);
        
        Map<Id,Opportunity> oppOldMap = new Map<Id,Opportunity>();
        oppOldMap.put(opp.Id,opp);
        Trigger_Execute__c tE2 = new Trigger_Execute__c();
        tE2.Name = 'QuoteLineItemTrigger';
        insert tE2;
        oppOldMap.get(opp.Id).StageName = 'Proposal';
        opportunityList[0].Approval_Status__c = 'OMC Approval Approved';
        update opportunityList[0];
        Test.startTest();
        PGQuoteTriggerHandler.changeCampaignMemberStatus(quoteList, oldMap);
        oldMap.get(qu.Id).Status = 'Proposal';
        
        PGQuoteTriggerHandler.changeCampaignMemberStatus(quoteList, oldMap);
        quoteList[0].Approval_Status__c = 'OMC Approval Approved';
        quoteList[0].Status = 'OMC Approval Submitted';
        Test.stopTest();
    }
      @isTest
   public static void coverOLiQLiSync(){

       Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
       
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Trigger_Execute__c tE = new Trigger_Execute__c();
        tE.Name = 'QuoteLineItemTrigger';
        insert tE;
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        objcustom.IsTrackingEnable__c = true;
        insert objcustom;
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
       a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.Billing_Street_new__c='TEst';
        opp.Billing_City_new__c='city';
        opp.Billing_Country_new__c='Singapore';
        opp.PG_Tenure__c = 1;
        opp.Stinger__c = true;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
       Test.startTest();
        system.assertEquals(opp.Id,opp.Id,'1');
        
        Quote objquote=new Quote();
        objquote.name='Test';
        objquote.CreatedDate__c=system.today();
        objquote.OpportunityId=opp.Id;
        insert objquote;
        
        opp.SyncedQuoteId=objquote.Id;
        opp.OMC_Approved_Date__c=system.today();
        opp.stageName='Pending OMC Approval';
        opp.Submit_to_OMC_Manually__c =false;
        opp.Approval_Status__c='OMC Approval Approved';
        update opp;
        
        objquote.Status='Accepted';
        objquote.Approval_Status__c='OMC Approval Approved';
        update objquote;
        
        Set<Id> setoppId=new Set<Id>{opp.ID};
        PGQuoteOpportunityHelper.expireActiveRenUpgQuote(setoppId);
       Test.stopTest();
    }
    public static testMethod void coverLoyaltyDis(){
        Test.startTest();
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        
        Trigger_Execute__c tE = new Trigger_Execute__c();
        tE.Name = 'QuoteLineItemTrigger';
        insert tE;

        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        Trigger_Execute__c objcustom=new Trigger_Execute__c();
        objcustom.Name='Trigger_Quote';
        objcustom.Enable_del__c=true;
        objcustom.IsTrackingEnable__c = true;
        insert objcustom;
        
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
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
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.id,  IsActive = true, CurrencyIsoCode = 'SGD');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Discretionary', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe1 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe1;
        
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        

        List<Opportunity> opportunityList = new List<Opportunity>();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Pending Online Payment';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.CurrencyIsoCode = 'SGD';
        insert opp;
        
        opportunityList.add(opp);
        
        List<Quote> quoteList = new List<Quote>();
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.Quote_Type__c = 'B2C - Standard';
        qu.PriceBook2Id = standardPB.Id;
        qu.ContactId = [select Id,PersonContactId from Account where Id =: a.Id].PersonContactId;
        insert qu;
       
        quoteList.add(qu);
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        Loyalty__c objLoyal=new Loyalty__c();
        objLoyal.Name='Test Loyal';
        objLoyal.PG_Tenure__c = 10;
        objLoyal.Campaign__c = cma.Id;
        objLoyal.Discount_Percentage__c = 0.5;
        insert objLoyal;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        QuoteLineItem oli = new QuoteLineItem();
        oli.Product2Id = prod.Id;
        oli.QuoteId = qu.Id;
        oli.Quantity =1;
        oli.PricebookEntryId = pbe2.Id;
        oli.Amount_Despite_VIP__c = 1.3;
        oli.Pro_Rate_Amount__c = 2;
        oli.Discount_Reason__c = 'Loyalty Discount';
        oli.UnitPrice = 2;
        oli.Discount__c = 0.5;
        insert oli; 
        
       
        qu.PG_Tenure__c=10;
        update qu;
        
        Quote quoteobj=new Quote();
        quoteobj.Name = 'Test Quote';
        quoteobj.Status = 'Proposal';
        quoteobj.OpportunityId = Opp.id;
        quoteobj.CreatedDate__c = system.today().AddDays(30);
        insert quoteobj;
        Delete quoteobj;
          Test.stopTest();
    }
}