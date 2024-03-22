@isTest
public class PGAccountTrigger_Test {
        static testMethod void testAgentTrigger_prof_admin() {
     PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        boolean firstRun = true;
        integer ctrRun = 1;
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string agencyRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        
        Test.startTest();
        User runUsser = [Select id, Sales_Head__c, Webuser_ID__c,Subsidiary__c From User where id =: UserInfo.getUserId()];
        Subsidiary__c sb = PGTestDataFactory.createSubsidiary();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'PGAccount';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
      //  a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = 'test@test.com';
        a.Country__c = sb.Country__c;
        a.Status__c = 'Active';
        a.OwnerId = runUsser.Id;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
		a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        a.Subsidiary__c = sb.id;
        
        update a;
        System.debug('test 1');
        
        Account acommando = new Account();
        acommando.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        acommando.Name = 'Unit Test Agency';
        acommando.CurrencyIsoCode = 'SGD';
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
        a2.BillingPostalCode = '83731';
       // a2.BillingState = 'test';
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
        a2.country__c='thailand';
        a2.PersonMobilePhone='45345454';
        a2.Mobile_Country__c='Thailand';
        a2.LastName = 'last';
        a2.FirstName = 'first';
            try{
                update a2;
            }catch(DMLException e){}
        Test.stopTest();     
    }
    @isTest
    static void runTest() {
    
        boolean firstRun = true;
        integer ctrRun = 1;
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string agencyRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        
        
        User runUsser = [Select id, Sales_Head__c, Webuser_ID__c,Subsidiary__c From User where id =: UserInfo.getUserId()];
        Subsidiary__c sb = PGTestDataFactory.createSubsidiary();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.LastName = 'PGAccount';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = 'test@test.com';
        a.Country__c = sb.Country__c;
        a.Status__c = 'Active';
        a.OwnerId = runUsser.Id;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
		a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        a.Subsidiary__c = sb.id;
        update a;
        System.debug('test 1');
        
        Account acommando = new Account();
        acommando.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        acommando.Name = 'Unit Test Agency';
        acommando.CurrencyIsoCode = 'SGD';
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
        a2.BillingPostalCode = '83731';
        //a2.BillingState = 'test';
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
        a2.country__c='thailand';
        a2.PersonMobilePhone='45345454';
        a2.Mobile_Country__c='Thailand';
        a2.Status__c = 'Pending';
         Test.startTest();    
            try{
                update a2;
                a2.Status__c = 'Trial';
                update a2;
                a2.country__c='Indonesia';
                update a2;
            }catch(DMLException e){}
        Test.stopTest();     
    }
}