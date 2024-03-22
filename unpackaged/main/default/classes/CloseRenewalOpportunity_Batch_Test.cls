@IsTest
public class CloseRenewalOpportunity_Batch_Test {
    static testMethod void runTest() {
        Test.startTest();
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
 PGTestDataFactory_v2.initSetupData();        
        Subsidiary__c sb = PGTestDataFactory.createSubsidiary();
        
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
        a.Subsidiary__pc = sb.Id;
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = '51231231';
        a.PersonBirthdate =system.today();
        a.Current_Subscription_Spending_Amount__c = 200;
        insert a;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb.id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = false;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = false;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
        
        CloseRenewalOpportunity_BatchSchedulable schedulable = new CloseRenewalOpportunity_BatchSchedulable();
        String sch = '0 0 0 * * ? *';
        system.schedule('Test Schedule', sch, schedulable);
        
        Test.stopTest();
    }
    
}