@isTest
public class CreateOfflinePaymentController_Test {
    
    @isTest
    static void runTestMethod(){
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'QuoteLineItemTrigger';
        insert TE;
 PGTestDataFactory_v2.initSetupData();            
      /*  QliToOliFieldMapping__c objcustomsetting = new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;*/
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                         );
        
        insert u;
        
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
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
      //  a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate=system.today();
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.ownerid = u.id;
        opp.Agent_Accepted_Time__c = system.now();
        opp.Guruland_Link_Created_Date__c = datetime.valueOf('2018-09-26 00:00:00');
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        opp.Payment_Type__c = 'Offline';
        opp.Opportunity_Type__c = 'B2C - Standard';
        insert opp;
        
        opp.StageName = 'Pending Online Payment';
        update opp;
        
        
        Quote qu = new Quote();
        qu.Name = 'Test Quote';
        qu.Status = 'Proposal';
        qu.From_Button__c = true;
        qu.CreatedDate__c = system.today().AddDays(30);
        qu.Payment_Time__c = system.now();
        qu.Last_Outbound_Sync__c = system.now();
        qu.Outbound_Sync_Error__c = 'test';
        qu.OpportunityId = Opp.id;
        qu.Allowed_Payment_Type__c = 'Offline only';
        qu.Count_of_Referral_Agent_Promotion__c = 1;
        qu.Payment_Amount__c = null;
        qu.CurrencyIsoCode = 'SGD';
        qu.PriceBook2Id = Test.getStandardPricebookId();
        insert qu;
        
        qu.status = 'Pending OMC approval';
        qu.Approval_Status__c = 'OMC Approval Submitted';
        update qu;
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2C Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc',CurrencyIsoCode = 'SGD');
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true,CurrencyIsoCode = 'SGD');
        insert pbe;
        
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
        
        Test.startTest();
        CreateOfflinePaymentController.getUserInfoAndOppRecord(qu.Id);
        CreateOfflinePaymentController.savePayment(payment);
        CreateOfflinePaymentController.getPaymentMethod();
        Test.stopTest();
    }
}