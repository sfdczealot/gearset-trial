@isTest
public class CampaignEligibilityEventHandler_Test {

    @isTest
    static void runTest(){ 
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
       
        update runningUser;
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
         PGTestDataFactory_v2.initSetupData();
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
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
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Trial';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        insert cma;
        
        Campaign cma1 = new Campaign();
        cma1.Name = 'TestNameCampaign';
        cma1.Country__c = 'Singapore';
        cma1.IsActive = true;
        cma1.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('First Timer').getRecordTypeId();
        cma1.ParentId = cma.Id;
        insert cma1;
        
        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.Label = 'Eligible';
        cms.CampaignId = cma1.Id;
        insert cms;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cma1.Id;
        cm.Status = 'Eligible';
        cm.ContactId = [select personContactId from Account where Id =: a.Id].personContactId;
        Insert cm;
        
        Test.startTest();
        List<Account> accountList = [select Id,Status__c,Country__c,personContactId from Account where Id =: a.Id];
        Map<Id,Account> oldMap = new Map<Id,Account>();
        oldMap.put(a.Id,a);
        CampaignEligibilityEventHandler.addContactToFirstTimerCampaign(accountList, oldMap);
        oldMap.get(a.Id).Status__c = 'Pending';
        update oldMap.values();
        Test.stopTest();
    }
     @isTest
    static void runTest1(){
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
       
        update runningUser;
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
         PGTestDataFactory_v2.initSetupData();
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
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
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Trial';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        insert cma;
        
        Campaign cma1 = new Campaign();
        cma1.Name = 'TestNameCampaign';
        cma1.Country__c = 'Singapore';
        cma1.IsActive = true;
        cma1.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('First Timer').getRecordTypeId();
        cma1.ParentId = cma.Id;
        insert cma1;
        
        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.Label = 'Eligible';
        cms.CampaignId = cma1.Id;
        insert cms;
        
        CampaignMember cm = new CampaignMember();
        cm.CampaignId = cma1.Id;
        cm.Status = 'Eligible';
        cm.ContactId = [select personContactId from Account where Id =: a.Id].personContactId;
        Insert cm;
        
        Test.startTest();
        List<Account> accountList = [select Id,Status__c,Country__c,personContactId from Account where Id =: a.Id];
        Map<Id,Account> oldMap = new Map<Id,Account>();
        CampaignEligibilityEventHandler.addContactToFirstTimerCampaign(accountList, oldMap);
        Test.stopTest();
    }
}