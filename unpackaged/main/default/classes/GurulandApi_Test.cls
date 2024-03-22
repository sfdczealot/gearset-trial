@isTest
public class GurulandApi_Test {
    static testMethod void runTest() {
 PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'Unit Test';
        a.salutation = 'Mr.';
        a.FirstName = 'Resend email';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        //a.Current_Subscription__c = 'Advance Account';
        a.Current_Subscription_Code__c = 'ADVANCE';
        a.Account_Rule_Code__c = 'test';
        a.Status__c = 'Pending';
        a.AgentNet_ID__c ='10244901';
        a.AgentKey__c = 'SG10244901';
        a.PersonEmail = 'resendemail@unittest.com';
        a.Country__c = 'Singapore';
        a.PersonBirthdate = system.today();
        a.CEA_Salesperson_Number__c = 'est';
        insert a;

        Test.StartTest();
        string agentkey = GurulandApi.getAgentNetKey(a.id);
        System.debug('Agentkey is ' + agentkey);

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new GurulandApiMock());
        // This causes a fake response to be sent from the class that implements HttpCalloutMock.
        HttpResponse response = GurulandApi.callResendEndpoint(a.id);
        // Verify that the response received contains fake values
        String actualValue = response.getBody();
        system.debug(response.getBody());
        String expectedValue = '{"agentId":"10244901","code":"AG2000","message":"Resend verification email is successful."}';
        system.assertEquals(expectedValue, actualValue, 'Invalid HTTP Response body');
        system.assertEquals(200, response.getStatusCode(), 'Invalid Status Code');

        Test.stopTest();
    }

    static testMethod void runTest1() {
  PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'Unit Test';
        a.salutation = 'Mr.';
        a.FirstName = 'Resend email';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        //a.Current_Subscription__c = 'Advance Account';
        a.Current_Subscription_Code__c = 'ADVANCE';
        a.Account_Rule_Code__c = 'test';
        a.Status__c = 'Pending';
        a.AgentNet_ID__c ='10244901';
        a.AgentKey__c = 'SG10244901';
        a.PersonEmail = 'resendemail@unittest.com';
        a.Country__c = 'Singapore';
        a.PersonBirthdate = system.today();
        a.CEA_Salesperson_Number__c = 'est';
        insert a;

        Test.StartTest();
        GurulandApi.callResendApi(a.Id);
        Test.stopTest();
    }

    static testMethod void runTest3() {
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'Unit Test';
        a.salutation = 'Mr.';
        a.FirstName = 'Resend email';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Malaysia';
        a.BillingPostalCode = '83732';
        // a.BillingState = 'test';
        //a.Current_Subscription__c = 'Advance Account';
        a.Current_Subscription_Code__c = 'ADVANCE';
        a.Account_Rule_Code__c = 'test';
        a.Status__c = 'Pending';
        a.AgentNet_ID__c ='10244901';
        a.AgentKey__c = 'MY10244901';
        a.PersonEmail = 'resendemail@unittest.com';
        a.Country__c = 'Malaysia';
        a.PersonBirthdate = system.today();
        a.CEA_Salesperson_Number__c = 'est';
        insert a;

        Test.StartTest();
        string agentkey = GurulandApi.getAgentNetKey(a.id);
        System.debug('Agentkey is ' + agentkey);

        // Set mock callout class
        Test.setMock(HttpCalloutMock.class, new GurulandApiMock());
        // This causes a fake response to be sent from the class that implements HttpCalloutMock.
        HttpResponse response = GurulandApi.callResendEndpoint(a.id);
        // Verify that the response received contains fake values
        String actualValue = response.getBody();
        system.debug(response.getBody());
        String expectedValue = '{"agentId":"10244901","code":"AG2000","message":"Resend verification email is successful."}';
        system.assertEquals(expectedValue, actualValue, 'Invalid HTTP Response body');
        system.assertEquals(200, response.getStatusCode(), 'Invalid Status Code');

        Test.stopTest();
    }
}