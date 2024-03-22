@isTest
public class BatchToUpdateConfirmationDate_Test {
    
    @isTest
    public static void testMethodBatch(){
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        PGTestDataFactory_v2.initSetupData();    
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
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Pending';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c='qwerty';
        a.PersonBirthdate=system.today(); 	
        insert a;
       
        
        Test.startTest();
        AccountHistory[] ah =  [Select AccountId, Field, OldValue, NewValue from AccountHistory where AccountId = :a.Id];
        DataBase.executeBatch(new BatchToUpdateConfirmationDate());
        Test.stopTest();
    }
}