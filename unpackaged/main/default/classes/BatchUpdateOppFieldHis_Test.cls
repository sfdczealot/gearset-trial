@isTest
public class BatchUpdateOppFieldHis_Test {
    
    @isTest
    public static void testRun(){
        
        Subsidiary__c sb1 = PGTestDataFactory.createSubsidiary();

        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        PGTestDataFactory_v2.initSetupData();
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
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subsidiary__c = sb1.id;
        a.CEA_Salesperson_Number__c = 'CEACHECK1';
        a.PersonBirthdate = system.today();
    	insert a;
    
        Test.startTest();
        Database.executeBatch(new BatchUpdateOppFieldHis());
        Test.stopTest();

    }
}