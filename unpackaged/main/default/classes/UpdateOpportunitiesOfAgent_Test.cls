@isTest
public class UpdateOpportunitiesOfAgent_Test{
    
    
    @isTest static void method1(){
        
        
        /*User u = new User(
         ProfileId = [SELECT Id FROM Profile].Id,
         LastName = 'last',
         Email = 'puser000@amamama.com',
         Username = 'puser000@amamama.com' + System.currentTimeMillis(),
         CompanyName = 'TEST',
         Title = 'title',
         Alias = 'alias',
         TimeZoneSidKey = 'America/Los_Angeles',
         EmailEncodingKey = 'UTF-8',
         LanguageLocaleKey = 'en_US',
         LocaleSidKey = 'en_US'
       );*/
        list<id> accIds = new list<id>();
    
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string agencyRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        
        Test.startTest();
        User runUsser = [Select id, Sales_Head__c, Webuser_ID__c,Subsidiary__c From User where id =: UserInfo.getUserId()];
        Subsidiary__c sb = PGTestDataFactory.createMYSubsidiary();
        /*Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'PGAccount';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'test';
        a.BillingPostalCode = '8373';
        a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = 'test@test.com';
        a.Country__c = sb.Country__c;
        a.Status__c = 'Active';
        a.OwnerId = runUsser.Id;
        insert a;
        a.Subsidiary__c = sb.id;
        update a;
        System.debug('test 1');*/
        PGTestDataFactory_v2.initSetupData();
        Account acommando = new Account();
        acommando.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        acommando.Name = 'Unit Test Agency';
        acommando.CurrencyIsoCode = 'MYR';
        acommando.Customer_Type__c = 'Agency';
        acommando.CEA_License__c = 'testcea';
        acommando.Agency_Id__c = '12313123';
        acommando.Commandos_Team_Lead__c = runUsser.Id;
       
        insert acommando;
         
        
        Account a2 = new Account();
        a2.RecordTypeId = accRectype;
        a2.LastName = 'PGAccount';
        a2.salutation = 'Mr.';
        a2.FirstName = 'abc';
        a2.CurrencyIsoCode = 'MYR';
        a2.Subscription_Start_Date__c = system.today().addMonths(-10);
        a2.BillingStreet = 'test';
        a2.BillingCity = 'test';
        a2.BillingCountry = 'Singapore';
        a2.BillingPostalCode = '83743';
      //  a2.BillingState = 'test';
        a2.Current_Subscription_Code__c = 'abc';
        a2.Account_Rule_Code__c = 'test';
        a2.AgentNet_ID__c = '123_2';
        a2.PersonEmail = 'test@test.com2';
        a2.Country__c = 'Malaysia';
        a2.Status__c = 'Active';
        a2.OwnerId = runUsser.Id;
        a2.Subsidiary__c = sb.id;
        a2.Agency__c = acommando.Id;
        insert a2;
        if(a2.id != null)
        accIds.add(a2.id);
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.AccountId = a2.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb.id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = false;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = false;
        
        insert opp;
       
        if(a2.id != null && opp.id != null) 
        UpdateOpportunitiesOfAgent.updateDefaultEntitlements(accIds);   
        
        Test.stopTest(); 
        
       
    }
    

}