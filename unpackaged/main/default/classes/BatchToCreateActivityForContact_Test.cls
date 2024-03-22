@isTest
public class BatchToCreateActivityForContact_Test {

    static testMethod void runTest() {
        
        Date startDate = system.today(); 
        Date endDate = system.today().AddDays(30);
        User runUsser = [Select id, Webuser_ID__c From User where id =: UserInfo.getUserId()];
        runUsser.Webuser_ID__c= 1;  
        update runUsser;   
        string resp = '';   
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
        Account a = new Account();
         PGTestDataFactory_v2.initSetupData();    
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
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.Birthdate_Verified__c = true;
        a.CEA_Salesperson_Number__c='qwerty';
        a.PersonBirthdate=system.today();
        insert a;
        Test.startTest();
        Database.executeBatch(new BatchToCreateActivityForContact(),100);
        Test.stopTest();
        
    }     
}