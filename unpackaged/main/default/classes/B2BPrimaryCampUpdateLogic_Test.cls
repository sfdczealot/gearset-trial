@isTest
public class B2BPrimaryCampUpdateLogic_Test {
    public static testMethod void unitTest(){
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        Account a = new Account();
          PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true); 
        a.RecordTypeId = accRectype;
        a.Name = 'Unit Test Agency';
        a.Customer_Type__c = 'Developer';
        a.BillingStreet = 'test street';
        a.BillingCity = 'city';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        a.Country__c = 'Singapore';
        insert a;
        
        Contact c = new Contact();
        c.AccountId = a.Id;
        c.email = 'b2b@unittest.com';
        c.Title = 'Mr.';
        c.LastName = 'Unit Test Last Name';
        c.FirstName = 'Unit Test First Name';
        insert c;
        
        string campRectype = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('B2B TM Events').getRecordTypeId();
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.RecordTypeId = campRectype;
        cma.Country__c = 'Singapore';
        cma.StartDate = system.today();
        cma.IsActive = true;
        insert cma;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = c.Id;
        cmp.Status = 'Revoked';
        cmp.CampaignId = cma.Id;
        
        Payment_Term__c payment_term = new Payment_Term__c(
            Name = 'B2B PAY',
            CurrencyIsoCode = 'SGD',
            NS_Payment_Term_ID__c = 445344.0);
        insert payment_term;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.Billing_Street_new__c = 'test';
        opp.Billing_City_new__c = 'citytest';
        opp.Billing_Country_new__c = 'Singapore';
        opp.Billing_Contact__c = c.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.recordTypeId = oppRectype;
        opp.Payment_Term__c =payment_term.id;
        insert opp;
        system.assertNotEquals(null, opp.Id);
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
        
        system.debug('-opp.Billing_Contact__c-'+opp.Billing_Contact__c+'-opp.Billing_Country_new__c-'+opp.Billing_Country_new__c+'-opp.Billing_City_new__c-'+opp.Billing_City_new__c);
        Opportunity opp_1 = new Opportunity();
        opp_1.Id=opp.Id;
        opp_1.stageName ='Negotiation';
        update opp_1; 
        opp_1.stageName ='Pending Client Signatory';
        update opp_1;
    } 
}