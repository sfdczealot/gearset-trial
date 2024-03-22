@isTest
public class ClosedRenewal_UpdateCloseDate_Test {
    /*
* Created by : Yuni
* Company    : Viseo Asia PTE LTD
* created Date : 27/07/2018
*/
    
    static testMethod void runTest() {
        Test.StartTest();
        id subId = PGTestDataFactory.createSubsidiary().Id;
         PGTestDataFactory_v2.initSetupData();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.Subscription_End_Date__c = system.today().addMonths(1);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'alkjha@yaho.com';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.Country__c = 'Singapore';
        a.Subsidiary__c = subId;
        a.Status__c = 'Active';
        a.Account_Rule_Code__c = 'test';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = '51231231';
        a.PersonBirthdate=system.today();
        a.Current_Subscription_Spending_Amount__c = 200;
        a.Commando_Sales_Rep__c = UserInfo.getUserId();
        insert a;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'New';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().addMonths(1).addDays(1);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = true;
        opp.Subsidiary__c = subId;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.RecordTypeId = oppRectype;
        insert opp;
        opp.StageName = 'Proposal';
        update opp;
        
        //AccountAssignment_BatchSchedulable sh1 = new AccountAssignment_BatchSchedulable();      
        String sch = '0 0 0 * * ? *';
        // system.schedule('Test Schedule', sch, sh1);
        
        system.debug('end_date:' + system.today().addMonths(1));
        system.debug('closeddate:' + system.today().addMonths(1).addDays(1));
        system.debug('stagename:' + opp.StageName);
        system.debug('renewal:' +opp.Order_Type_Clone__c);
        database.executeBatch(new ClosedRenewal_UpdateCloseDate(),1);
        Test.stopTest();
    }
    
}