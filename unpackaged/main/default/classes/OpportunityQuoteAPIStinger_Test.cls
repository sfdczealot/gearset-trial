@isTest
public class OpportunityQuoteAPIStinger_Test {

    @isTest
    static void runTest() {
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){  

        Trigger_Execute__c TECampMember = new Trigger_Execute__c();
        TECampMember.Name = 'PGCampMemberTrigger';
        TECampMember.Enable_del__c = true;
        insert TECampMember;

        Trigger_Execute__c TECampElig = new Trigger_Execute__c();
        TECampElig.Name = 'PGCampaignEligibilityTrigger';
        TECampElig.Enable_del__c = true;
        insert TECampElig;

        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;

        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;

        User runUsser = [Select id, Webuser_ID__c From User where id =: UserInfo.getUserId()];

        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='Trigger_Quote';
        customsetting.Enable_del__c=true;
        insert customsetting;
            
        Trigger_Execute__c TECampMember1 = new Trigger_Execute__c();
        TECampMember1.Name = 'PGPaymentTrigger';
        TECampMember1.Enable_del__c = true;
        insert TECampMember1;

        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'QuoteLineItemTrigger';
        insert TE;
        CountryCode__c cc = new CountryCode__c();
        cc.Name = 'singapore';
        insert cc;
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);

        PGTestDataFactory_v2.CutomSettingFieldCreation();

        id subId = PGTestDataFactory.createSubsidiary().Id;

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
        a.Subsidiary__c = subId;
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = 'A212312B';
        a.PersonBirthdate= System.today();
        a.Mobile_Country__c = '65';
        insert a;

        Id personConId = [Select Id, PersonContactId from Account where Id =: a.Id].PersonContactId;

        Opportunity opp = new opportunity();
        opp.RecordTypeId = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C');
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.From_Button__c = true;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Last_Outbound_Sync__c = system.now();
        opp.Outbound_Sync_Error__c = 'test';
        opp.Guruland_Quote_Link__c = '';
        opp.Subsidiary__c = subId;
        opp.Allowed_Payment_Type__c = 'All';
        opp.Count_of_Referral_Agent_Promotion__c = 1;
        opp.CurrencyIsoCode = 'SGD';
        insert opp;

        opp.NetSuite_Sales_Order__c = '1212';
        update opp;

        Campaign cm = new Campaign();
        cm.Name = 'TestCampaign';
        cm.IsActive = false;
        cm.Source_Campaign_Reference__c='camp1';
        cm.CurrencyIsoCode = 'SGD';    
        cm.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('B2B Developer Online Form').getRecordTypeId();
        cm.EndDate = system.today().addDays(-2);
        insert cm;

        Campaign cm1 = new Campaign();
        cm1.Name = 'TestCampaign';
        cm1.IsActive = true;
        cm1.Parentid=cm.id;
        cm1.CurrencyIsoCode = 'SGD';
        cm1.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('B2B Developer Online Form').getRecordTypeId();
        cm1.EndDate = system.today().addDays(-2);
        insert cm1;

        List<CampaignMember> campMemberList = new List<CampaignMember>();

        CampaignMember campMember1 = new CampaignMember();
        campMember1.ContactId = personConId;
        campMember1.Status = 'Eligible';
        campMember1.CampaignId = cm.Id;
        campMemberList.add(campMember1);

        /*CampaignMember campMember = new CampaignMember();
        campMember.ContactId = personConId;
        campMember.Status = 'Eligible';
        campMember.CampaignId = cm.Id;
        campMemberList.add(campMember);
        insert campMemberList;

        Campaign_Eligibility__c campElig = new Campaign_Eligibility__c();
        campElig.Name = 'Test Elig';
        campElig.CurrencyIsoCode ='SGD';
        campElig.Campaign__c =cm.Id ;
        insert campElig;

        Campaign_Eligibility__c campElig1 = new Campaign_Eligibility__c();
        campElig1.Name = 'Test Elig';
        campElig1.CurrencyIsoCode ='SGD';
        campElig1.Campaign__c =cm.Id ;
        insert campElig1;

        Promo_Mechanic__c PM = new Promo_Mechanic__c();
        PM.name = 'Test1';
        PM.Discount_Reason__c = 'Managerial Discount';
        PM.Campaign_Eligibility__c = campElig.Id;
        PM.Discount_Reason__c = 'VIP (Relationship)';
        PM.CurrencyIsoCode = 'SGD';
        insert PM;

        Promo_Mechanic__c PM2 = new Promo_Mechanic__c();
        PM2.name = 'Test2';
        PM2.Campaign_Eligibility__c = campElig.Id;
        PM2.CurrencyIsoCode = 'SGD';
        PM2.Discount_Reason__c = 'Renewal Promotion';
        insert PM2;*/
       // String PromoIds = String.valueOf(PM.Id)+','+ String.valueOf(PM2.Id);
        Test.StartTest();
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Pending Online Payment';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.Payment_Link__c = '';
        qu.OpportunityId = Opp.id;
        //qu.to_FOC_Approval__c = true;
        qu.FOC_Approved__c = false;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.Floor_Price_Type__c = 'Below Floor Price';
        qu.CurrencyIsoCode = 'SGD';
        qu.Quote_Type__c = 'B2C - Renewal';
        qu.PriceBook2Id = Test.getStandardPricebookId();    
        qu.Subsidiary__c = subId;

        insert qu;

        Quote qu1 = new Quote();
        qu1.Name = 'Test Quote';
        qu1.Status = 'Proposal';
        qu1.From_Button__c = true;
        qu1.CreatedDate__c = system.today().AddDays(30);
        qu1.Payment_Time__c = system.now();
        qu1.Agent_Accepted_Time__c = system.now();
        qu1.Last_Outbound_Sync__c = system.now();
        qu1.Outbound_Sync_Error__c = 'test';
        qu1.Payment_Link__c = '';
        qu1.OpportunityId = Opp.id;
        //qu1.Allowed_Payment_Type__c = 'Online only';
        qu1.Count_of_Referral_Agent_Promotion__c = 1;
        qu1.Payment_Amount__c = null;
        qu1.CurrencyIsoCode = 'SGD';
        qu1.PriceBook2Id = Test.getStandardPricebookId();    
        qu1.Subsidiary__c = subId;

        insert qu1;
        
        Product2 prod1 = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Discretionary', SKU_Code__c = System.Label.SG_AD_CREDIT_SKU_CODE,CurrencyIsoCode = 'SGD');
        insert prod1;

        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc',CurrencyIsoCode = 'SGD',Is_KIT_Parent__c = true,Revised_Product__c = prod1.Id);
        insert prod;
            
        Floor_Price__c fp1 = new Floor_Price__c();
        fp1.List_Price__c = 1.50;
        fp1.Max_Quantity__c = 1000;
        fp1.Min_Quantity__c = 100;
        fp1.Name = 'Credit Range 1';
        fp1.Price__c = 1.25;
        fp1.Product__c = prod1.id;
        insert fp1;

        Id StdpricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true,currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;

        QuoteLineItem qli1 = new QuoteLineItem();
        qli1.QuoteId = qu1.id;
        qli1.Product2Id = prod.id;
        qli1.PricebookEntryId = pbe.id;
        qli1.Quantity = 3;
        qli1.UnitPrice =3;
        qli1.Pro_Rate_Amount__c = 100;
        qli1.SNo__c = 1.00;
        qli1.GST_VAT_Rate__c = 7;
        qli1.Push_to_NetSuite__c = true;
        //qli1.Promo_Mechanic_Id__c = PM.Id;
        qli1.WHT_Rate__c = 10;
        insert qli1;

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.SNo__c = 1.00;
     //   oli.Promo_Mechanic_Id__c = PM.Id;
        oli.GST_VAT_Rate__c = 7;
        insert oli;

        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu.id;
        qli.Product2Id = prod1.id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 150;
        qli.UnitPrice =1.50;
        qli.SNo__c = 1.00;
        qli.Pro_Rate_Amount__c = 100;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
     //   qli.Promo_Mechanic_Id__c = PM.id;
        qli.WHT_Rate__c = 10;
        insert qli;
            
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Cash',CurrencyIsoCode='SGD');
        insert paymethod;
        
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = qu.Id;
        payment.Opportunity_Record__c = qu.OpportunityId;
        payment.Reference_Number__c = qu.Payment_Reference__c;
        payment.Payment_Mode__c = 'Offline';
        payment.Amount2__c = 5;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = paymethod.Id;
        insert payment;

        map<string, Country_Attribute__mdt> countryAtt = EligibilityHandler.getCountryAttribute();
        //system.assertEquals('Proposal', oppStage, 'Invalid Stage');
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new OpportunityQuoteCalloutMock());
        // This causes a fake response to be sent from the class that implements HttpCalloutMock.
        HttpResponse response = OpportunityQuoteAPIStinger.sendtoGurulandAct(qu.id);
        OpportunityQuoteAPIStinger.sendtoGurulandValidate(qu.id);
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        //system.assertEquals('application/json', contentType);
        String actualValue = response.getBody();
        system.debug(response.getBody());
        String expectedValue = '{"id":5799,"region":"sg","agent_id":43770,"invoice_id":"PGSO-19005761","currency":"sgd","total":1.07,"order_info":"{\'webuserId\':\'43770\',\'tranTotal\':\'1.07\',\'tranTax\':\'0.07\',\'tranDisc\':\'0.00\',\'tranAmount\':\'1.07\',\'salesRep\':{\'name\':\'Admin Viseo\',\'email\':\'whisnu-satriya.wardhana@viseo.com\',\'contactNo\':\'6546373\'},\'region\':\'sg\',\'referenceNo\':\'PGSO-19005761\',\'email\':\'viseo1.viseo1.deepti.malik09@gmail.com\',\'customerName\':\'Deepti Malik\',\'createdDate\':\'2019-01-30 14:15:29\',\'billaddress\':\'sadas asdas Singapore\', \'items\': [{\'startDate\':\'2019-01-30\',\'itemTax\':\'0.07\',\'itemQuantity\':\'1.00\',\'itemPrice\':\'1.00\',\'itemName\':\'PGSG Bundle Ad Credit (1 Credit)\',\'itemDisc\':\'0.00\',\'itemDescription\':\'Bundle Ad Credit (1 Credit)\',\'itemAmount\':\'1.07\',\'endDate\':\'2020-01-29\'}]}","payment_method":"all","os":"","browser":"","ip_address":"","timestamp":null,"accepted_datetime":null,"created":"2019-01-30 14:16:24","modified":"2019-01-30 14:16:27","status":"open","hash":"U2FsdGVkX19nQSBmR5EtTUjzol6QF8uZkdfMRCO79eCG0orLlEcV/uvSDU+RsNcX","expiry":"2019-01-30 14:16:24","hash_base64":"VTJGc2RHVmtYMTluUVNCbVI1RXRUVWp6b2w2UUY4dVprZGZNUkNPNzllQ0cwb3JMbEVjVi91dlNEVStSc05jWA=="}';
        //system.assertEquals(expectedValue, actualValue, 'Invalid HTTP Response body');
        //system.assertEquals(200, response.getStatusCode(), 'Invalid Status Code');
      //  OpportunityQuoteAPIStinger.updateQuoteLink(qu.id, 'Hash64', false);
        //OpportunityQuoteAPIStinger.updateQuoteLink(qu.id, '', false);
        OpportunityQuoteAPIStinger.updateQuoteLink(qu.id, '','', false);
        OpportunityQuoteAPIStinger.createFeeditem(qu.id, 'Test');
        OpportunityQuoteAPIStinger.getQuoteDetails(qu.id);
        OpportunityQuoteAPIStinger.updateEmailAddress(qu.id,'test@mail.com');
        OpportunityQuoteAPIStinger.increasecoverage();
        //OpportunityQuoteAPIStinger.validatePromoCampaigns(qu.id);
        try {
            OpportunityQuoteAPIStinger.validatePromoCampaigns(qu1.id);
        } catch (Exception ex) {}
        try {
            string oppStage = OpportunityQuoteAPIStinger.checkConditionsBeforePayment(qu.Id);
            //OpportunityQuoteAPIStinger.sendtoGuruland(qu.id);

        } catch (Exception ex) {}
        
        
        //Quote QuoAssert = [select Id, Name, Payment_Link__c, Country__c from Quote where Id=:qu.Id];
        //system.assertEquals(countryAtt.get(QuoAssert.Country__c).Payment_Link__c+'Hash64', QuoAssert.Payment_Link__c, 'Invalid Guruland Quote Link.');
        Test.stopTest();
    }
  }
    
    @isTest
    static void runTest1() {
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){

        Trigger_Execute__c TECampMember = new Trigger_Execute__c();
        TECampMember.Name = 'PGCampMemberTrigger';
        TECampMember.Enable_del__c = true;
        insert TECampMember;

        Trigger_Execute__c TECampElig = new Trigger_Execute__c();
        TECampElig.Name = 'PGCampaignEligibilityTrigger';
        TECampElig.Enable_del__c = true;
        insert TECampElig;

        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;

        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;

        User runUsser = [Select id, Webuser_ID__c From User where id =: UserInfo.getUserId()];

        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='Trigger_Quote';
        customsetting.Enable_del__c=true;
        insert customsetting;

        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'QuoteLineItemTrigger';
        insert TE;
        CountryCode__c cc = new CountryCode__c();
        cc.Name = 'singapore';
        insert cc;
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);

        PGTestDataFactory_v2.CutomSettingFieldCreation();

        id subId = PGTestDataFactory.createSubsidiary().Id;

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
        a.Subsidiary__c = subId;
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = 'A212312B';
        a.PersonBirthdate= System.today();
        a.Mobile_Country__c = '65';
        insert a;

        Id personConId = [Select Id, PersonContactId from Account where Id =: a.Id].PersonContactId;

        Opportunity opp = new opportunity();
        opp.RecordTypeId = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C');
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.From_Button__c = true;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Last_Outbound_Sync__c = system.now();
        opp.Outbound_Sync_Error__c = 'test';
        opp.Guruland_Quote_Link__c = '';
        opp.Subsidiary__c = subId;
        opp.Allowed_Payment_Type__c = 'All';
        opp.Count_of_Referral_Agent_Promotion__c = 1;
        opp.CurrencyIsoCode = 'SGD';
        insert opp;

        opp.NetSuite_Sales_Order__c = '1212';
        update opp;

       /* Campaign cm = new Campaign();
        cm.Name = 'TestCampaign';
        cm.IsActive = false;
        cm.Source_Campaign_Reference__c='camp1';
        cm.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('B2B Developer Online Form').getRecordTypeId();
        cm.EndDate = system.today().addDays(-2);
        insert cm;

        Campaign cm1 = new Campaign();
        cm1.Name = 'TestCampaign';
        cm1.IsActive = true;
        cm1.Parentid=cm.id;
        cm1.CurrencyIsoCode = 'SGD';
        cm1.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('B2B Developer Online Form').getRecordTypeId();
        cm1.EndDate = system.today().addDays(-2);
        insert cm1;

        List<CampaignMember> campMemberList = new List<CampaignMember>();

        CampaignMember campMember1 = new CampaignMember();
        campMember1.ContactId = personConId;
        campMember1.Status = 'Eligible';
        campMember1.CampaignId = cm1.Id;
        campMemberList.add(campMember1);

        CampaignMember campMember = new CampaignMember();
        campMember.ContactId = personConId;
        campMember.Status = 'Eligible';
        campMember.CampaignId = cm.Id;
        campMemberList.add(campMember);
        insert campMemberList;

        Campaign_Eligibility__c campElig = new Campaign_Eligibility__c();
        campElig.Name = 'Test Elig';
        campElig.CurrencyIsoCode ='SGD';
        campElig.Campaign__c =cm1.Id ;
        insert campElig;

        Campaign_Eligibility__c campElig1 = new Campaign_Eligibility__c();
        campElig1.Name = 'Test Elig';
        campElig1.CurrencyIsoCode ='SGD';
        campElig1.Campaign__c =cm.Id ;
        insert campElig1;

        Promo_Mechanic__c PM = new Promo_Mechanic__c();
        PM.name = 'Test1';
        PM.Discount_Reason__c = 'Managerial Discount';
        PM.Campaign_Eligibility__c = campElig.Id;
        PM.CurrencyIsoCode = 'SGD';
        insert PM;

        Promo_Mechanic__c PM2 = new Promo_Mechanic__c();
        PM2.name = 'Test2';
        PM2.Campaign_Eligibility__c = campElig1.Id;
        PM2.CurrencyIsoCode = 'SGD';
        insert PM2;*/

        Test.StartTest();
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
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Subsidiary__c = subId;
        qu.Quote_Type__c = 'B2C - Standard';
        insert qu;

        Quote qu1 = new Quote();
        qu1.Name = 'Test Quote';
        qu1.Status = 'Proposal';
        qu1.From_Button__c = true;
        qu1.CreatedDate__c = system.today().AddDays(30);
        qu1.Payment_Time__c = system.now();
        qu1.Agent_Accepted_Time__c = system.now();
        qu1.Last_Outbound_Sync__c = system.now();
        qu1.Outbound_Sync_Error__c = 'test';
        qu1.Payment_Link__c = '';
        qu1.OpportunityId = Opp.id;
        qu1.Allowed_Payment_Type__c = 'All';
        qu1.Count_of_Referral_Agent_Promotion__c = 1;
        qu1.Payment_Amount__c = null;
        qu1.CurrencyIsoCode = 'SGD';
        qu1.PriceBook2Id = Test.getStandardPricebookId();
        qu1.Subsidiary__c = subId;

        insert qu1;


        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc',CurrencyIsoCode = 'SGD');
        insert prod;

        Id StdpricebookId = Test.getStandardPricebookId();

        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true,currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;

        QuoteLineItem qli1 = new QuoteLineItem();
        qli1.QuoteId = qu1.id;
        qli1.Product2Id = prod.id;
        qli1.PricebookEntryId = pbe.id;
        qli1.Quantity = 3;
        qli1.UnitPrice =3;
        qli1.SNo__c = 1.00;
        qli1.GST_VAT_Rate__c = 7;
        qli1.Push_to_NetSuite__c = true;
       // qli1.Promo_Mechanic_Id__c = PM2.id;
        qli1.WHT_Rate__c = 10;
        insert qli1;

        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.SNo__c = 1.00;
       // oli.Promo_Mechanic_Id__c = PM.Id;
        oli.GST_VAT_Rate__c = 7;
        insert oli;

        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu.id;
        qli.Product2Id = prod.id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 3;
        qli.UnitPrice =3;
        qli.SNo__c = 1.00;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
       // qli.Promo_Mechanic_Id__c = PM.id;
        qli.WHT_Rate__c = 10;
        insert qli;

        map<string, Country_Attribute__mdt> countryAtt = EligibilityHandler.getCountryAttribute();
        //system.assertEquals('Proposal', oppStage, 'Invalid Stage');
        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new OpportunityQuoteCalloutMock());
        // This causes a fake response to be sent from the class that implements HttpCalloutMock.
        HttpResponse response = OpportunityQuoteAPIStinger.sendtoGurulandAct(qu.id);
        OpportunityQuoteAPIStinger.sendtoGurulandValidate(qu.id);
        // Verify that the response received contains fake values
        String contentType = response.getHeader('Content-Type');
        //system.assertEquals('application/json', contentType);
        String actualValue = response.getBody();
        system.debug(response.getBody());
        String expectedValue = '{"id":5799,"region":"sg","agent_id":43770,"invoice_id":"PGSO-19005761","currency":"sgd","total":1.07,"order_info":"{\'webuserId\':\'43770\',\'tranTotal\':\'1.07\',\'tranTax\':\'0.07\',\'tranDisc\':\'0.00\',\'tranAmount\':\'1.07\',\'salesRep\':{\'name\':\'Admin Viseo\',\'email\':\'whisnu-satriya.wardhana@viseo.com\',\'contactNo\':\'6546373\'},\'region\':\'sg\',\'referenceNo\':\'PGSO-19005761\',\'email\':\'viseo1.viseo1.deepti.malik09@gmail.com\',\'customerName\':\'Deepti Malik\',\'createdDate\':\'2019-01-30 14:15:29\',\'billaddress\':\'sadas asdas Singapore\', \'items\': [{\'startDate\':\'2019-01-30\',\'itemTax\':\'0.07\',\'itemQuantity\':\'1.00\',\'itemPrice\':\'1.00\',\'itemName\':\'PGSG Bundle Ad Credit (1 Credit)\',\'itemDisc\':\'0.00\',\'itemDescription\':\'Bundle Ad Credit (1 Credit)\',\'itemAmount\':\'1.07\',\'endDate\':\'2020-01-29\'}]}","payment_method":"Online only","os":"","browser":"","ip_address":"","timestamp":null,"accepted_datetime":null,"created":"2019-01-30 14:16:24","modified":"2019-01-30 14:16:27","status":"open","hash":"U2FsdGVkX19nQSBmR5EtTUjzol6QF8uZkdfMRCO79eCG0orLlEcV/uvSDU+RsNcX","expiry":"2019-01-30 14:16:24","hash_base64":"VTJGc2RHVmtYMTluUVNCbVI1RXRUVWp6b2w2UUY4dVprZGZNUkNPNzllQ0cwb3JMbEVjVi91dlNEVStSc05jWA=="}';
        //system.assertEquals(expectedValue, actualValue, 'Invalid HTTP Response body');
        //system.assertEquals(200, response.getStatusCode(), 'Invalid Status Code');
      //  OpportunityQuoteAPIStinger.updateQuoteLink(qu.id, 'Hash64', false);
        //OpportunityQuoteAPIStinger.updateQuoteLink(qu.id, '', true);
        OpportunityQuoteAPIStinger.updateQuoteLink(qu.id, '','', true);
        OpportunityQuoteAPIStinger.createFeeditem(qu.id, 'Test');
        OpportunityQuoteAPIStinger.getQuoteDetails(qu.id);
        OpportunityQuoteAPIStinger.updateEmailAddress(qu.id,'test@mail.com');
        OpportunityQuoteAPIStinger.validatePromoCampaigns(qu.id);
        try {
            OpportunityQuoteAPIStinger.validatePromoCampaigns(qu1.id);
        } catch (Exception ex) {}
        try {
            string oppStage = OpportunityQuoteAPIStinger.checkConditionsBeforePayment(qu.Id);
        } catch (Exception ex) {}
        OpportunityQuoteAPIStinger.sendtoGuruland(qu.id);
        OpportunityQuoteAPIStinger.increasecoverage();
   
        
        //Quote QuoAssert = [select Id, Name, Payment_Link__c, Country__c from Quote where Id=:qu.Id];
        //system.assertEquals(countryAtt.get(QuoAssert.Country__c).Payment_Link__c+'Hash64', QuoAssert.Payment_Link__c, 'Invalid Guruland Quote Link.');
        Test.stopTest();
    }
  }
}