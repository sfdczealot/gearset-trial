@isTest
public class PaymentsAPI_Test {
    
    @TestSetup
    static void testData(){
        Test.StartTest();
       	Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'QuoteLineItemTrigger';
        insert TE;
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='Trigger_Quote';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsettingPG = new Trigger_Execute__c();
        customsettingPG.Name='OppTrigger';
        customsettingPG.Enable_del__c=true;
        insert customsettingPG;
        
        Trigger_Execute__c paymentTrigger = new Trigger_Execute__c();
        paymentTrigger.Name='PGPaymentTrigger';
        paymentTrigger.Enable_del__c=true;
        insert paymentTrigger;
        
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        
        PGTestDataFactory_v2.initSetupData();
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                         );
        
        insert u;
        
        subsidiary__c sb = new Subsidiary__c();
        sb.Name = u.Subsidiary__c;
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
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'India';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'A212312B';
        a.PersonBirthdate = system.today();
        a.Mobile_Country__c = '60';
        insert a;
        Test.StopTest();
    }
    
    @isTest
    static void runTestMethod(){
        String resp = '';
        
        Account a = [Select Id,FirstName FROM Account Where FirstName = 'abc' LIMIT 1];
        User u = [Select Id, Email From User Where Email = 'giantest@testorg.com' LIMIT 1];
        subsidiary__c sb = [Select Id , Tax_Label__c FRom subsidiary__c Where Tax_Label__c = 'taxLabel' LIMIT 1];
		Tax_Code__c taxcode = [Select Id, Name From Tax_Code__c Where Name = 'SG - 7% GST' LIMIT 1];    
        PGOpportunityTriggerHandler.isFirstTimeSub = false;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        insert opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        //qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Agent_Accepted_Time__c = system.now();
        insert qu;
        
        Quote qu1 = [Select Id, Opp_Quote_Ref_num__c, Country__c,Account.Name, Owner.Name, Owner.Phone, Owner.Email, Account.personEmail, 
                     Agent_Accepted_Time__c From Quote Where Id =: qu.Id];
        
        Test.StartTest();

        qu.Approval_Status__c = 'OMC Approval Submitted';
        qu.Status = 'Pending OMC Approval';
        update qu;
        
       
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.Id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
       
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        //Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        //insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.GST_VAT_Rate__c = 3;
        oli.Discount__c = 1;
        oli.Pro_Rate_Amount__c = 3;
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
        insert qli;
        
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Adyen (SG)',CurrencyIsoCode='SGD');
        insert paymethod;
        
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = qu.Id;
        payment.Opportunity_Record__c = qu.OpportunityId;
        payment.Reference_Number__c = qu.Payment_Reference__c;
        payment.Payment_Gateway__c = 'Adyen';
        payment.Payment_Mode__c = 'Paypal';
        payment.Amount2__c = 4;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = paymethod.Id;
        insert payment;
        //PaymentsAPI.readQuote();
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        string requestQuote = '{"Id":"'+ qu1.Opp_Quote_Ref_num__c + '","Agent_Accepted_Time__c": "2018-09-24T14:23:47+00:00","Payment_Amount" : 1190,"Payment_Type":"offline","Payment_Gateway": "Adyen","Quote_Ref":"'+ qu1.Opp_Quote_Ref_num__c + '"}';
        req2.requestURI = '/services/apexrest/Payment/';  //Request URL
        req2.httpMethod = 'post';//HTTP Request Type
        req2.requestBody = blob.valueOf(requestQuote);
        RestContext.request = req2;
        
        RestContext.response= res2;
        PaymentsAPI.upsertPayment();
        resp = res2.responseBody.toString();
        system.debug('resp$$$>>> '+resp);
        PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
        PaymentsAPI.callOMCApproval(qu1.ID,Opp.id);
        PaymentsAPI.isEligibleForAutoApproved(qu,null);
        Test.stopTest();
    }
    
    @isTest
    static void runTestMethod2(){
        
        String resp = '';
        
        Account a = [Select Id,FirstName FROM Account Where FirstName = 'abc' LIMIT 1];
        User u = [Select Id, Email From User Where Email = 'giantest@testorg.com' LIMIT 1];
        subsidiary__c sb = [Select Id , Tax_Label__c FRom subsidiary__c Where Tax_Label__c = 'taxLabel' LIMIT 1];
		Tax_Code__c taxcode = [Select Id, Name From Tax_Code__c Where Name = 'SG - 7% GST' LIMIT 1];    
        PGOpportunityTriggerHandler.isFirstTimeSub = false;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        insert opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        //qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Agent_Accepted_Time__c = system.now();
        insert qu;
        
        Quote qu1 = [Select Id, Opp_Quote_Ref_num__c, Country__c,Account.Name, Owner.Name, Owner.Phone, Owner.Email, Account.personEmail, 
                     Agent_Accepted_Time__c From Quote Where Id =: qu.Id];
        
        Test.StartTest();

        qu.Approval_Status__c = 'OMC Approval Submitted';
        qu.Status = 'Pending OMC Approval';
        update qu;
        
       
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.Id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
       
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        //Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        //insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.GST_VAT_Rate__c = 3;
        oli.Discount__c = 1;
        oli.Pro_Rate_Amount__c = 3;
        insert oli;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu1.id;
        qli.Product2Id = prod.id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 3;
        qli.UnitPrice =3;
        qli.SNo__c = 1.00;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
        qli.Product_Category__c = 'Subscription';
        insert qli;
        
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Adyen (SG)',CurrencyIsoCode='SGD');
        insert paymethod;
        
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = qu.Id;
        payment.Opportunity_Record__c = qu.OpportunityId;
        payment.Reference_Number__c = qu.Payment_Reference__c;
        payment.Payment_Gateway__c = '2c2p';
        payment.Payment_Mode__c = 'offline';
        payment.Amount2__c = 4;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = paymethod.Id;
        insert payment;
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        string requestQuote = '{"Id":"'+qu1.Opp_Quote_Ref_num__c+'","Agent_Accepted_Time__c": "2018-09-24T14:23:47+00:00","Payment_Amount" : null,"Bank_Name":"UOB","Installment_Period":"6","Payment_Gateway": "2c2p","Quote_Ref":"'+ qu1.Opp_Quote_Ref_num__c + '"}';
        req2.requestURI = '/services/apexrest/Payment/';  //Request URL
        req2.httpMethod = 'post';//HTTP Request Type
        req2.requestBody = blob.valueOf(requestQuote);
        RestContext.request = req2;
        RestContext.response= res2;
        PaymentsAPI.upsertPayment();
        resp = res2.responseBody.toString();
        system.debug('resp$$$>>> '+resp);
    	RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
       	PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
		PaymentsAPI.isEligibleForAutoApproved(qu,null);
        Test.stopTest();
    }
    
    @isTest
    static void runTestMethod3(){
        
        String resp = '';
        
        Account a = [Select Id,FirstName FROM Account Where FirstName = 'abc' LIMIT 1];
        User u = [Select Id, Email From User Where Email = 'giantest@testorg.com' LIMIT 1];
        subsidiary__c sb = [Select Id , Tax_Label__c FRom subsidiary__c Where Tax_Label__c = 'taxLabel' LIMIT 1];
		Tax_Code__c taxcode = [Select Id, Name From Tax_Code__c Where Name = 'SG - 7% GST' LIMIT 1];    
        PGOpportunityTriggerHandler.isFirstTimeSub = false;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        insert opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        //qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Agent_Accepted_Time__c = system.now();
        insert qu;
        
        Quote qu1 = [Select Id, Opp_Quote_Ref_num__c, Country__c,Account.Name, Owner.Name, Owner.Phone, Owner.Email, Account.personEmail, 
                     Agent_Accepted_Time__c From Quote Where Id =: qu.Id];
        
        Test.StartTest();

        qu.Approval_Status__c = 'OMC Approval Submitted';
        qu.Status = 'Pending OMC Approval';
        update qu;
        
       
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.Id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
       
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        //Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        //insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.GST_VAT_Rate__c = 3;
        oli.Discount__c = 1;
        oli.Pro_Rate_Amount__c = 3;
        insert oli;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu1.id;
        qli.Product2Id = prod.id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 3;
        qli.UnitPrice =3;
        qli.SNo__c = 1.00;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
        qli.Product_Category__c = 'Subscription';
        insert qli;
        
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Adyen (SG)',CurrencyIsoCode='SGD');
        insert paymethod;
        
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = qu.Id;
        payment.Opportunity_Record__c = qu.OpportunityId;
        payment.Reference_Number__c = qu.Payment_Reference__c;
        payment.Payment_Gateway__c = '2c2p';
        payment.Payment_Mode__c = 'offline';
        payment.Amount2__c = 4;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = paymethod.Id;
        insert payment;
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        string requestQuote = '{"Id":"'+qu1.Opp_Quote_Ref_num__c+'","Agent_Accepted_Time__c": "2018-09-24T14:23:47+00:00","Payment_Amount" : null,"Bank_Name":"KBANK","Installment_Period":"3","Payment_Gateway": "kbank","Quote_Ref":"'+ qu1.Opp_Quote_Ref_num__c + '"}';
        req2.requestURI = '/services/apexrest/Payment/';  //Request URL
        req2.httpMethod = 'post';//HTTP Request Type
        req2.requestBody = blob.valueOf(requestQuote);
        RestContext.request = req2;
        RestContext.response= res2;
        PaymentsAPI.upsertPayment();
        resp = res2.responseBody.toString();
        system.debug('resp$$$>>> '+resp);
    	RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
       	PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
		PaymentsAPI.isEligibleForAutoApproved(qu,null);
        Test.stopTest();
    }
      @isTest
    static void runTestMethod4(){
        
        String resp = '';
        
        Account a = [Select Id,FirstName FROM Account Where FirstName = 'abc' LIMIT 1];
        User u = [Select Id, Email From User Where Email = 'giantest@testorg.com' LIMIT 1];
        subsidiary__c sb = [Select Id , Tax_Label__c FRom subsidiary__c Where Tax_Label__c = 'taxLabel' LIMIT 1];
		Tax_Code__c taxcode = [Select Id, Name From Tax_Code__c Where Name = 'SG - 7% GST' LIMIT 1];    
        PGOpportunityTriggerHandler.isFirstTimeSub = false;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        insert opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        //qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Agent_Accepted_Time__c = system.now();
        insert qu;
        
        Quote qu1 = [Select Id, Opp_Quote_Ref_num__c, Country__c,Account.Name, Owner.Name, Owner.Phone, Owner.Email, Account.personEmail, 
                     Agent_Accepted_Time__c From Quote Where Id =: qu.Id];
        
        Test.StartTest();

        qu.Approval_Status__c = 'OMC Approval Submitted';
        qu.Status = 'Pending OMC Approval';
        update qu;
        
       
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.Id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
       
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        //Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        //insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.GST_VAT_Rate__c = 3;
        oli.Discount__c = 1;
        oli.Pro_Rate_Amount__c = 3;
        insert oli;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu1.id;
        qli.Product2Id = prod.id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 3;
        qli.UnitPrice =3;
        qli.SNo__c = 1.00;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
        qli.Product_Category__c = 'Subscription';
        insert qli;
        
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Adyen (SG)',CurrencyIsoCode='SGD');
        insert paymethod;
        
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = qu.Id;
        payment.Opportunity_Record__c = qu.OpportunityId;
        payment.Reference_Number__c = qu.Payment_Reference__c;
        payment.Payment_Gateway__c = '2c2p';
        payment.Payment_Mode__c = 'offline';
        payment.Amount2__c = 4;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = paymethod.Id;
        insert payment;
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        string requestQuote = '{"Id":"'+qu1.Opp_Quote_Ref_num__c+'","Agent_Accepted_Time__c": "2018-09-24T14:23:47+00:00","Payment_Amount" : 0,"Bank_Name":"DBSSG","Installment_Period":"6","Payment_Gateway": "enets","Quote_Ref":"'+ qu1.Opp_Quote_Ref_num__c + '"}';
        req2.requestURI = '/services/apexrest/Payment/';  //Request URL
        req2.httpMethod = 'post';//HTTP Request Type
        req2.requestBody = blob.valueOf(requestQuote);
        RestContext.request = req2;
        RestContext.response= res2;
        PaymentsAPI.upsertPayment();
        resp = res2.responseBody.toString();
        system.debug('resp$$$>>> '+resp);
    	RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
       	PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
        
        PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
		PaymentsAPI.isEligibleForAutoApproved(qu,1);
        Test.stopTest();
    }
    
    @isTest
    static void runTestMethod5(){
        
         String resp = '';
        
        Account a = [Select Id,FirstName FROM Account Where FirstName = 'abc' LIMIT 1];
        User u = [Select Id, Email From User Where Email = 'giantest@testorg.com' LIMIT 1];
        subsidiary__c sb = [Select Id , Tax_Label__c FRom subsidiary__c Where Tax_Label__c = 'taxLabel' LIMIT 1];
		Tax_Code__c taxcode = [Select Id, Name From Tax_Code__c Where Name = 'SG - 7% GST' LIMIT 1];    
        PGOpportunityTriggerHandler.isFirstTimeSub = false;
        
        sb.Country__c = 'Malaysia';
        Update sb;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        insert opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        //qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Agent_Accepted_Time__c = system.now();
        insert qu;
        
        Quote qu1 = [Select Id, Opp_Quote_Ref_num__c, Country__c,Account.Name, Owner.Name, Owner.Phone, Owner.Email, Account.personEmail, 
                     Agent_Accepted_Time__c From Quote Where Id =: qu.Id];
        
        Test.StartTest();

        qu.Approval_Status__c = 'OMC Approval Submitted';
        qu.Status = 'Pending OMC Approval';
        update qu;
        
       
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.Id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
       
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        //Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        //insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.GST_VAT_Rate__c = 3;
        oli.Discount__c = 1;
        oli.Pro_Rate_Amount__c = 3;
        insert oli;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu1.id;
        qli.Product2Id = prod.id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 3;
        qli.UnitPrice =3;
        qli.SNo__c = 1.00;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
        qli.Product_Category__c = 'Subscription';
        insert qli;
        
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Adyen (SG)',CurrencyIsoCode='SGD');
        insert paymethod;
        
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = qu.Id;
        payment.Opportunity_Record__c = qu.OpportunityId;
        payment.Reference_Number__c = qu.Payment_Reference__c;
        payment.Payment_Gateway__c = '2c2p';
        payment.Payment_Mode__c = 'offline';
        payment.Amount2__c = 4;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = paymethod.Id;
        insert payment;
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        string requestQuote = '{"Id":"'+qu1.Opp_Quote_Ref_num__c+'","Agent_Accepted_Time__c": "2018-09-24T14:23:47+00:00","Payment_Amount" : 0,"Bank_Name":"DBSSG","Installment_Period":"12","Payment_Gateway": "enets","Quote_Ref":"'+ qu1.Opp_Quote_Ref_num__c + '"}';
        req2.requestURI = '/services/apexrest/Payment/';  //Request URL
        req2.httpMethod = 'post';//HTTP Request Type
        req2.requestBody = blob.valueOf(requestQuote);
        RestContext.request = req2;
        RestContext.response= res2;
        PaymentsAPI.upsertPayment();
        resp = res2.responseBody.toString();
        system.debug('resp$$$>>> '+resp);
    	RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
       	PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
        
        PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
		PaymentsAPI.isEligibleForAutoApproved(qu,1);
        Test.stopTest();
    }
    
    @isTest
    static void runTestMethod6(){
        
         String resp = '';
        
        Account a = [Select Id,FirstName FROM Account Where FirstName = 'abc' LIMIT 1];
        User u = [Select Id, Email From User Where Email = 'giantest@testorg.com' LIMIT 1];
        subsidiary__c sb = [Select Id , Tax_Label__c FRom subsidiary__c Where Tax_Label__c = 'taxLabel' LIMIT 1];
		Tax_Code__c taxcode = [Select Id, Name From Tax_Code__c Where Name = 'SG - 7% GST' LIMIT 1];    
        PGOpportunityTriggerHandler.isFirstTimeSub = false;
        
        sb.Country__c = 'Thailand';
        Update sb;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        insert opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        //qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Agent_Accepted_Time__c = system.now();
        insert qu;
        
        Quote qu1 = [Select Id, Opp_Quote_Ref_num__c, Country__c,Account.Name, Owner.Name, Owner.Phone, Owner.Email, Account.personEmail, 
                     Agent_Accepted_Time__c From Quote Where Id =: qu.Id];
        
        Test.StartTest();

        qu.Approval_Status__c = 'OMC Approval Submitted';
        qu.Status = 'Pending OMC Approval';
        update qu;
        
       
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.Id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
       
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        //Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        //insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.GST_VAT_Rate__c = 3;
        oli.Discount__c = 1;
        oli.Pro_Rate_Amount__c = 3;
        insert oli;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu1.id;
        qli.Product2Id = prod.id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 3;
        qli.UnitPrice =3;
        qli.SNo__c = 1.00;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
        qli.Product_Category__c = 'Subscription';
        insert qli;
        
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Adyen (SG)',CurrencyIsoCode='SGD');
        insert paymethod;
        
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = qu.Id;
        payment.Opportunity_Record__c = qu.OpportunityId;
        payment.Reference_Number__c = qu.Payment_Reference__c;
        payment.Payment_Gateway__c = '2c2p';
        payment.Payment_Mode__c = 'offline';
        payment.Amount2__c = 4;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = paymethod.Id;
        payment.Reference_Number__c = '12';
        insert payment;
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        string requestQuote = '{"Id":"'+qu1.Opp_Quote_Ref_num__c+'","Agent_Accepted_Time__c": "2018-09-24T14:23:47+00:00","Payment_Amount" : 0,"Bank_Name":"DBSSG","Installment_Period":"6","Payment_Gateway": "enets","Quote_Ref":"'+ qu1.Opp_Quote_Ref_num__c + '"}';
        req2.requestURI = '/services/apexrest/Payment/';  //Request URL
        req2.httpMethod = 'post';//HTTP Request Type
        req2.requestBody = blob.valueOf(requestQuote);
        RestContext.request = req2;
        RestContext.response= res2;
        PaymentsAPI.upsertPayment();
        resp = res2.responseBody.toString();
        system.debug('resp$$$>>> '+resp);
    	RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
       	PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
        
        PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
		PaymentsAPI.isEligibleForAutoApproved(qu,1);
        Test.stopTest();
    }
    
    @isTest
    static void runTestMethod7(){
        
        String resp = '';
        
        Account a = [Select Id,FirstName FROM Account Where FirstName = 'abc' LIMIT 1];
        User u = [Select Id, Email From User Where Email = 'giantest@testorg.com' LIMIT 1];
        subsidiary__c sb = [Select Id , Tax_Label__c FRom subsidiary__c Where Tax_Label__c = 'taxLabel' LIMIT 1];
		Tax_Code__c taxcode = [Select Id, Name From Tax_Code__c Where Name = 'SG - 7% GST' LIMIT 1];    
        PGOpportunityTriggerHandler.isFirstTimeSub = false;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        insert opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        //qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Agent_Accepted_Time__c = system.now();
        insert qu;
        
        Quote qu1 = [Select Id, Opp_Quote_Ref_num__c, Country__c,Account.Name, Owner.Name, Owner.Phone, Owner.Email, Account.personEmail, 
                     Agent_Accepted_Time__c From Quote Where Id =: qu.Id];
        
        Test.StartTest();

        qu.Approval_Status__c = 'OMC Approval Submitted';
        qu.Status = 'Pending OMC Approval';
        update qu;
        
       
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.Id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
       
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        //Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        //insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.GST_VAT_Rate__c = 3;
        oli.Discount__c = 1;
        oli.Pro_Rate_Amount__c = 3;
        insert oli;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu1.id;
        qli.Product2Id = prod.id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 3;
        qli.UnitPrice =3;
        qli.SNo__c = 1.00;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
        qli.Product_Category__c = 'Subscription';
        insert qli;
        
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Adyen (SG)',CurrencyIsoCode='SGD');
        insert paymethod;
        
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = qu.Id;
        payment.Opportunity_Record__c = qu.OpportunityId;
        payment.Reference_Number__c = qu.Payment_Reference__c;
        payment.Payment_Gateway__c = '2c2p';
        payment.Payment_Mode__c = 'offline';
        payment.Amount2__c = 4;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = paymethod.Id;
        insert payment;
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        string requestQuote = '{"Id":"'+qu1.Opp_Quote_Ref_num__c+'","Agent_Accepted_Time__c": "2018-09-24T14:23:47+00:00","Payment_Amount" : null,"Bank_Name":"KBANK","Installment_Period":"6","Payment_Gateway": "kbank","Quote_Ref":"'+ qu1.Opp_Quote_Ref_num__c + '"}';
        req2.requestURI = '/services/apexrest/Payment/';  //Request URL
        req2.httpMethod = 'post';//HTTP Request Type
        req2.requestBody = blob.valueOf(requestQuote);
        RestContext.request = req2;
        RestContext.response= res2;
        PaymentsAPI.upsertPayment();
        resp = res2.responseBody.toString();
        system.debug('resp$$$>>> '+resp);
    	RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
       	PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
		PaymentsAPI.isEligibleForAutoApproved(qu,null);
        Test.stopTest();
    }
     @isTest
    static void runTestMethod8(){
        
        String resp = '';
        
        Account a = [Select Id,FirstName FROM Account Where FirstName = 'abc' LIMIT 1];
        User u = [Select Id, Email From User Where Email = 'giantest@testorg.com' LIMIT 1];
        subsidiary__c sb = [Select Id , Tax_Label__c FRom subsidiary__c Where Tax_Label__c = 'taxLabel' LIMIT 1];
		Tax_Code__c taxcode = [Select Id, Name From Tax_Code__c Where Name = 'SG - 7% GST' LIMIT 1];    
        PGOpportunityTriggerHandler.isFirstTimeSub = false;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        insert opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        //qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Agent_Accepted_Time__c = system.now();
        insert qu;
        
        Quote qu1 = [Select Id, Opp_Quote_Ref_num__c, Country__c,Account.Name, Owner.Name, Owner.Phone, Owner.Email, Account.personEmail, 
                     Agent_Accepted_Time__c From Quote Where Id =: qu.Id];
        
        Test.StartTest();

        qu.Approval_Status__c = 'OMC Approval Submitted';
        qu.Status = 'Pending OMC Approval';
        update qu;
        
       
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.Id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
       
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        //Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        //insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.GST_VAT_Rate__c = 3;
        oli.Discount__c = 1;
        oli.Pro_Rate_Amount__c = 3;
        insert oli;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu1.id;
        qli.Product2Id = prod.id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 3;
        qli.UnitPrice =3;
        qli.SNo__c = 1.00;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
        qli.Product_Category__c = 'Subscription';
        insert qli;
        
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Adyen (SG)',CurrencyIsoCode='SGD');
        insert paymethod;
        
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = qu.Id;
        payment.Opportunity_Record__c = qu.OpportunityId;
        payment.Reference_Number__c = qu.Payment_Reference__c;
        payment.Payment_Gateway__c = '2c2p';
        payment.Payment_Mode__c = 'offline';
        payment.Amount2__c = 4;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = paymethod.Id;
        insert payment;
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        string requestQuote = '{"Id":"'+qu1.Opp_Quote_Ref_num__c+'","Agent_Accepted_Time__c": "2018-09-24T14:23:47+00:00","Payment_Amount" : null,"Bank_Name":"DBSSG","Installment_Period":"6","Payment_Gateway": "enets","Quote_Ref":"'+ qu1.Opp_Quote_Ref_num__c + '"}';
        req2.requestURI = '/services/apexrest/Payment/';  //Request URL
        req2.httpMethod = 'post';//HTTP Request Type
        req2.requestBody = blob.valueOf(requestQuote);
        RestContext.request = req2;
        RestContext.response= res2;
        PaymentsAPI.upsertPayment();
        resp = res2.responseBody.toString();
        system.debug('resp$$$>>> '+resp);
    	RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
       	PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
		PaymentsAPI.isEligibleForAutoApproved(qu,null);
        Test.stopTest();
    }
    @isTest
    static void runTestMethod9(){
        
        String resp = '';
        
        Account a = [Select Id,FirstName FROM Account Where FirstName = 'abc' LIMIT 1];
        User u = [Select Id, Email From User Where Email = 'giantest@testorg.com' LIMIT 1];
        subsidiary__c sb = [Select Id , Tax_Label__c FRom subsidiary__c Where Tax_Label__c = 'taxLabel' LIMIT 1];
		Tax_Code__c taxcode = [Select Id, Name From Tax_Code__c Where Name = 'SG - 7% GST' LIMIT 1];    
        PGOpportunityTriggerHandler.isFirstTimeSub = false;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = sb.Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        insert opp;
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        //qu.Agent_Accepted_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'All';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        qu.Agent_Accepted_Time__c = system.now();
        insert qu;
        
        Quote qu1 = [Select Id, Opp_Quote_Ref_num__c, Country__c,Account.Name, Owner.Name, Owner.Phone, Owner.Email, Account.personEmail, 
                     Agent_Accepted_Time__c From Quote Where Id =: qu.Id];
        
        Test.StartTest();

        qu.Approval_Status__c = 'OMC Approval Submitted';
        qu.Status = 'Pending OMC Approval';
        update qu;
        
       
        Pricebook2 standardPB = new Pricebook2(Name = 'Standard Pricebook', Description = 'Price Book', Subsidiary__c = sb.Id,  IsActive = true, CurrencyIsoCode = 'MYR');
        insert standardPB;
        
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
       
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true,Item_Type__c = 'Kit Item');
        insert prod;
        //Product2 prod2 = new Product2(Name = 'Test prod2', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test prod', Product_Class__c = productClass.Id, Tax_Code__c = taxcode.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        //insert prod2;
        Id StdpricebookId = Test.getStandardPricebookId();
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=standardPB.Id, product2id=prod.id, unitprice=100.0, isActive=true, currencyisocode = 'SGD', useStandardPrice = false);
        insert pbe2;
        
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.OpportunityId = opp.id;
        oli.Product2Id = prod.id;
        oli.PricebookEntryId = pbe.id;
        oli.Quantity = 3;
        oli.UnitPrice =3;
        oli.GST_VAT_Rate__c = 3;
        oli.Discount__c = 1;
        oli.Pro_Rate_Amount__c = 3;
        insert oli;
        
        QuoteLineItem qli = new QuoteLineItem();
        qli.QuoteId = qu1.id;
        qli.Product2Id = prod.id;
        qli.PricebookEntryId = pbe.id;
        qli.Quantity = 3;
        qli.UnitPrice =3;
        qli.SNo__c = 1.00;
        qli.GST_VAT_Rate__c = 7;
        qli.Push_to_NetSuite__c = true;
        qli.Product_Category__c = 'Subscription';
        insert qli;
        
        Payment_Method__c paymethod = new Payment_Method__c(NS_Internal_ID__c  = '1', Name = 'Adyen (SG)',CurrencyIsoCode='SGD');
        insert paymethod;
        
        Payment__c payment = new Payment__c(); 
        payment.Quote_Record__c = qu.Id;
        payment.Opportunity_Record__c = qu.OpportunityId;
        payment.Reference_Number__c = qu.Payment_Reference__c;
        payment.Payment_Gateway__c = '2c2p';
        payment.Payment_Mode__c = 'offline';
        payment.Amount2__c = 4;
        payment.Payment_Date__c = system.today();
        payment.Payment_Method__c = paymethod.Id;
        insert payment;
        
        RestRequest req2 = new RestRequest(); 
        RestResponse res2 = new RestResponse();
        string requestQuote = '{"Id":"'+qu1.Opp_Quote_Ref_num__c+'","Agent_Accepted_Time__c": "2018-09-24T14:23:47+00:00","Payment_Amount" : null,"Bank_Name":"UOB","Installment_Period":"12","Payment_Gateway": "2c2p","Quote_Ref":"'+ qu1.Opp_Quote_Ref_num__c + '"}';
        req2.requestURI = '/services/apexrest/Payment/';  //Request URL
        req2.httpMethod = 'post';//HTTP Request Type
        req2.requestBody = blob.valueOf(requestQuote);
        RestContext.request = req2;
        RestContext.response= res2;
        PaymentsAPI.upsertPayment();
        resp = res2.responseBody.toString();
        system.debug('resp$$$>>> '+resp);
    	RestRequest req3 = new RestRequest(); 
        RestResponse res3 = new RestResponse();
       	PaymentsAPI.sendEmailToAgentAndSPForOfflinePayment(qu1);
		PaymentsAPI.isEligibleForAutoApproved(qu,null);
        Test.stopTest();
    }
}