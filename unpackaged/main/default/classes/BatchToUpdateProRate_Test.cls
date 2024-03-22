@isTest
public class BatchToUpdateProRate_Test {

    @isTest
    public static void BatchToUpdateProRateMethod(){ 
        PGTestDataFactory_v2.initSetupData();    
        
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
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = 'test@test.com';
        a.Country__c = 'Singapore';
        a.Status__c = 'Downgraded';
        a.Pro_Rate_Amount__c = 3;
        a.PersonBirthdate = system.today();
        a.CEA_Salesperson_Number__c = 'qwerty';
        insert a;
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Pro_Rate__c = 2.9;
        insert opp;
        
        Test.startTest();
        update a;
        DataBase.executeBatch(new BatchToUpdateProRate());
        Test.stopTest();
    }
}