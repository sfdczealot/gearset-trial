@isTest
public class BirthdayVerificationController_Test {
    
    @isTest
    static void runTest(){
         PGTestDataFactory_v2.initSetupData();
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
        a.BillingPostalCode = '83735';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = 'CEACHECK1';
        a.Status__c = 'Active';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Test.startTest();
        BirthdayVerificationController.createActivityRecord(a.Id); 
        BirthdayVerificationController.getAccount(a.Id);
        Test.stopTest();
    }
}