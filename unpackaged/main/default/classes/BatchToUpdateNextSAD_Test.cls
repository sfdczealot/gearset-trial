@isTest
public class BatchToUpdateNextSAD_Test {
    
    @isTest
    static void UpdateNextSAD(){
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'PGAccount';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'test';
        a.BillingPostalCode = '8373';
        a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = 'test@test.com';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'CEACHECK1';
        try{
            insert a;
        }catch(Exception e){
            system.debug('### '+e.getMessage());
        }
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        try{
            insert opp;
        }catch(Exception e){
            system.debug('### '+e.getMessage());
        }
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        
        Product2 prod = new Product2(Name = 'Test Prod', IsActive = true, Segment__c = 'B2B Only', Product_Category__c = 'Subscription', SKU_Code__c = 'abc', Is_Bundle__c= true, CurrencyIsoCode = 'SGD');
        insert prod;
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod.id,unitprice=100.0, isActive=true, CurrencyIsoCode = 'SGD');
        insert pbe;
        
        OpportunityLineItem oplineItem = new OpportunityLineItem();
        oplineItem.OpportunityId = opp.id;
        oplineItem.Product2Id = prod.id;
        oplineItem.PricebookEntryId = pbe.id;
        oplineItem.Quantity = 2;
        oplineItem.UnitPrice = 1200;
        oplineItem.SNo__c = 1;
        oplineItem.Discount_Reason__c = 'Agent Referral: Referee';
        //insert oplineItem;
        BatchToUpdateNextSubscriptionActivation.getOLIwithLowestSnoWhole(new list<OpportunityLineItem>{oplineItem});
        
        Test.startTest();
        DataBase.executeBatch(new BatchToUpdateNextSubscriptionActivation(),1);
        Test.stopTest();
    }
}