/*
* Created by : Yuni
* Company    : Viseo Asia PTE LTD
* created Date : 27/07/2018
*/
@isTest
public class AccountAssignment_Batch_Test {
    static testMethod void runTest() {
        Test.StartTest();
PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
//        Group g = new Group();
//        g.Name = 'New Business Team';
//        g.Type = 'Queue';
//        insert g;
 PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);

        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com'
        );

        insert u;

        User uManager = new User(Alias = 'gManager', Email='giantestmanager@testorg.com',
                EmailEncodingKey='UTF-8', LastName='GianTestmanager', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='giantestmanager@testorg.com'
        );

        insert uManager;

        u.ManagerId = uManager.Id;
        update u;

        System.runAs(u){
            Group q = [SELECT Id, Name FROM Group WHERE Name = 'New Business Team' AND Type = 'Queue'];
            GroupMember gm = new GroupMember(GroupId = q.Id, UserOrGroupId = u.Id);
            insert gm;
        }

        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni1';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'Singapore';
        
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'aa123@yaho.com';
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = system.today();
        insert a;

        Account ac = new Account();
        ac.RecordTypeId = accRectype;
        ac.LastName = 'TestYuni222323323';
        ac.AgentNet_ID__c = 'TestPurposeId';
        ac.CurrencyIsoCode = 'SGD';
        ac.Subscription_Start_Date__c = system.today().addMonths(-10);
        ac.Subscription_End_Date__c = system.today().addMonths(1);
        ac.BillingStreet = 'test';
        ac.BillingCity = 'test';
        ac.BillingCountry = 'Singapore';
        ac.BillingPostalCode = '8373';
        //ac.BillingState = 'test';
        ac.Account_Rule_Code__c = 'Premier';
        
        ac.Current_Subscription_Code__c = 'abc';
        ac.personemail = 'aaaaaasadxx@yaho.com';
        ac.salutation = 'Mr.';
        ac.firstname = 'aaaa';
        ac.CEA_Salesperson_Number__c = 'CEACHECK';
        ac.PersonBirthdate = system.today();
        insert ac;
        
        
        Account acommando = new Account();
        acommando.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        acommando.Name = 'Unit Test Agency';
        acommando.CurrencyIsoCode = 'SGD';
        acommando.Customer_Type__c = 'Agency';
        acommando.CEA_License__c = 'testcea';
        acommando.Commandos_Team_Lead__c = u.Id;
       
        insert acommando;

        Account acommando2 = new Account();
        acommando2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        acommando2.Name = 'Dummy commando Unit Test Agency 2 test viseo';
        acommando2.CurrencyIsoCode = 'SGD';
        acommando2.Customer_Type__c = 'Agency';
        acommando2.CEA_License__c = 'testcea2233ss';
        
        insert acommando2;

        AccountAssignment_BatchSchedulable sh1 = new AccountAssignment_BatchSchedulable();
        String sch = '0 0 0 * * ? *';
        system.schedule('Test Schedule', sch, sh1);

        Test.stopTest();
    }
}