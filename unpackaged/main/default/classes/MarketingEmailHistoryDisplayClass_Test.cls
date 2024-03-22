@isTest
public class MarketingEmailHistoryDisplayClass_Test {
    public static testmethod void unitTestL(){
        AWS_Credential__c customsetting=new AWS_Credential__c();
        customsetting.Name='AwsCredential';
        customsetting.Key__c='TESSTEE';
        customsetting.Secret__c='ESSWTEST';
        customsetting.BucketName__c='aws-test';
        customsetting.Host__c='s3.test.com';
        customsetting.Folder__c='/test/';
        insert customsetting;
PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.CurrencyIsoCode = 'SGD';
        a.AgentNet_ID__c = 'TestPurposeIdXX';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        a.PersonBirthdate= system.today();
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'asd131sfaa@yaho.com';
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'CEACHECK1';
        a.PersonBirthdate = system.today();
        insert a;
        
        Test.startTest();
       
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        MarketingEmailHistoryDisplayClass.getMarketingEmail(a.Id);
        MarketingEmailHistoryDisplayClass.getHtmlEmailContent(a.Id);
        
               Test.stopTest();
    }
}