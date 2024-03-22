@isTest
public class PGUserTrigger_Test {
    
    static testMethod void UserRec() {
        
        Test.StartTest();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User usr = new User(LastName = 'Test',
                            FirstName='Name',
                            Alias = 'jliv',
                            Email = 'test.name@asdf.com',
                            Username = 'test.name@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        User runUser = [Select id, DefaultCurrencyISOCode From User where id =: UserInfo.getUserId()];
        runUser.DefaultCurrencyISOCode = 'THB';
        update runUser;
        Test.stopTest();
    }
    static testMethod void coverTransferRecord(){
       Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Trigger_Execute__c TE1 = new Trigger_Execute__c();
        TE1.Name = 'Trigger_OpportunitySplit';
        TE1.Enable_del__c = true;
        insert TE1;
       User usr1 = new User(LastName = 'lName1',
                            FirstName= 'fName1',
                            Alias = 'jliv',
                            Email = 'test.name@gmail.com',
                            Username = 'uName' + String.valueOf(Crypto.getRandomInteger()).replace('-', '.') + '@gmail.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            Transfer_Account_Opportunity__c = true,
                            IsActive = true,
                            Subsidiary__c = 'PropertyGuru Pte Ltd'
                           );
        System.Debug('usr1Name###' + usr1.UserName);
        insert usr1;
        User usr = new User(LastName = 'lName',
                            FirstName= 'fName',
                            Alias = 'jliv',
                            Email = 'test.name@asdf.com',
                            Username = 'uName' + String.valueOf(Crypto.getRandomInteger()).replace('-', '.') + '@gmail.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            ManagerId = usr1.id,
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US',
                            Transfer_Account_Opportunity__c = true,
                            IsActive = true,
                            Subsidiary__c = 'PropertyGuru Pte Ltd'
                           );
        System.Debug('usrName###' + usr.UserName);
        insert usr;
        
        system.runas(usr){
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
        //a.Customer_Type__c = 'Agency';
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
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'A5473687B';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        a.Mobile_Country__c = '65';
        insert a;
        /*Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Stinger__c = true;
        opp.Opportunity_Type__c = 'B2C - Renewal';
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;*/
            Test.startTest();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Proposal';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = oppRectype;
        opp.PG_Tenure__c = 1;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        insert opp;
            List<Opportunity> oppList = new List<Opportunity>();
            oppList.add(opp);
            Test.stopTest();
        system.assertEquals(opp.Id,opp.Id,'1');
        
       
        
        OpportunityOwnerTransfer_Batch oppTransBatch = New OpportunityOwnerTransfer_Batch(usr,'finalaccstr');
        
        //Database.QueryLocator ql = oppTransBatch.start(usr,'finalaccstr');
        oppTransBatch.execute(null,oppList);
        //oppTransBatch.Finish(null);
        }
        //update usr;
  /*  User runUser = [Select id,IsActive,Transfer_Account_Opportunity__c From User where id =: UserInfo.getUserId()];
        
        runUser.IsActive=false;
        runUser.Transfer_Account_Opportunity__c=true;
        update runUser;
*/
        //Test.stopTest();
       
    }

    static testMethod void UserRecRefresh() {
        
        Test.StartTest();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        
        User usr = new User(LastName = 'Test 2',
                            FirstName='Name 2',
                            Alias = 'jliv',
                            Email = 'test2.name@asdf.com.invalid',
                            Username = 'test2.name@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        User runUser = [Select id, DefaultCurrencyISOCode From User where id =: UserInfo.getUserId()];
        runUser.DefaultCurrencyISOCode = 'THB';
        update runUser;
        database.executeBatch(new PGUserSandboxRefresh_Batch());
        Test.stopTest();
    }
    static testMethod void UserRecRefresh1() {
        
        Test.StartTest();
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User userRecord = new User(LastName = 'Test 2',
                            FirstName='Name 2',
                            Alias = 'jliv',
                            Email = 'test2.name@gmail.com',
                            Username = 'test2.name@gmail.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert userRecord;
        User usr = new User(LastName = 'Test 2',
                            FirstName='Name 2',
                            Alias = 'jliv',
                            Email = 'test2.name@asdf.com',
                            Username = 'test2.name@asdf.com',
                            ProfileId = profileId.id,
                            TimeZoneSidKey = 'GMT',
                            LanguageLocaleKey = 'en_US',
                            Managerid = userRecord.id,
                            EmailEncodingKey = 'UTF-8',
                            LocaleSidKey = 'en_US'
                           );
        insert usr;
        usr.IsActive=false;
        usr.Transfer_Account_Opportunity__c=true;
        update usr;
        
        //database.executeBatch(new PGUserSandboxRefresh_Batch());
        Test.stopTest();
    }
}