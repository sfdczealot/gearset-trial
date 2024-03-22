@istest
public class AgentrewardTriggerHandler_test {
    @istest
    private static void insertAgentReward(){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        
        Trigger_Execute__c PGUpdatePGFPoints=new Trigger_Execute__c();
        PGUpdatePGFPoints.Name='PGUpdatePGFPoints';
        PGUpdatePGFPoints.Enable_del__c=true;
        insert PGUpdatePGFPoints;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        Test.startTest();
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount1 = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        listAccount1.add(agency);
        insert listAccount1;
        
        list<Account> listAccount = new list<Account>();
        Account acc = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc.FirstName = 'TestMe';
        acc.LastName = 'Lasting';
        acc.AgentNet_ID__c = 'AgentNet_ID__c test';
        acc.Salutation = 'Mrs.';
        acc.CurrencyIsoCode = 'SGD';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.BillingCountry = 'Singapore';
        acc.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test0@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='F000002G';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 100;
        acc.Reward_Tier__c = 'Gold';
        
        insert acc;
        
        Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe1';
        acc1.LastName = 'Lasting1';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test10@1yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='F000004K';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        
          Account acc2 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc2.FirstName = 'TestMe2';
        acc2.LastName = 'Lasting2';
        acc2.AgentNet_ID__c = '7886';
        acc2.Salutation = 'Mrs.';
        acc2.CurrencyIsoCode = 'SGD';
        acc2.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc2.BillingStreet = 'test';
        acc2.BillingCity = 'test';
        acc2.BillingCountry = 'Singapore';
        acc2.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc2.Current_Subscription_Code__c = 'abc';
        acc2.PersonEmail = 'test391@yuni.com';
        acc2.Account_Rule_Code__c = 'Standard';
        acc2.Status__c = 'Active';
        acc2.Country__c = 'Singapore';
        acc2.Agency__c = agency.id;
        acc2.Subsidiary__c = subId;
        acc2.CEA_Salesperson_Number__c='A000011D';
        acc2.PersonBirthdate=system.today();
        acc2.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc2.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc2.VIP_Campaign__c = 'VIP Advance SC';
        acc2.Approval_Status__c = 'Test';
        acc2.Reward_Tier__c ='Solitaire';
        
        insert acc2;
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'Published';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Solitaire';
        
        ARList.add(Ar4);
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc1.id;
        Ar5.Status__c = 'Published';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        
        ARList.add(Ar5);
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc2.id;
        Ar1.Status__c = 'Published';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 100;
        Ar1.Reward_Tier__c = 'Elite';
        
        ARList.add(Ar1);        
        Agent_reward__c Ar = new Agent_reward__c();
        Ar.Account__c = acc.id;
        Ar.Status__c = 'New Quarter';
        Ar.Discretionary_Spending__c =1000;
        Ar.Subscription_Spending__c = 2322;
        Ar.Reward_Points__c = 233;
        Ar.Reward_Tier__c = 'Silver';
        
        ARList.add(Ar);
              
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc1.id;
        Ar6.Status__c = 'New Quarter';
        Ar6.Discretionary_Spending__c =20000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 700;
        Ar6.Reward_Tier__c = 'Platinum';
        
        ARList.add(Ar6);
        
        Agent_reward__c Ar8 = new Agent_reward__c();
        Ar8.Account__c = acc2.id;
        Ar8.Status__c = 'New Quarter';
        Ar8.Discretionary_Spending__c =43;
        Ar8.Subscription_Spending__c = 12;
        Ar8.Reward_Points__c = 70;
        Ar8.Reward_Tier__c = 'Elite';
        
        ARList.add(Ar8);
        insert ARList;
        
        Agent_reward__c Ar7 = new Agent_reward__c();
        Ar7.Account__c = acc.id;
        Ar7.Status__c = 'New Quarter';
        Ar7.Discretionary_Spending__c =20000;
        Ar7.Subscription_Spending__c = 2322;
        Ar7.Reward_Points__c = 2000;
        Ar7.Reward_Tier__c = 'Solitaire';
        insert Ar7;
        ARList.add(Ar7);
        Ar7.Approval_Status__c ='Approved';
        update Ar7;
               
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc1.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =20000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 2000;
        Ar3.Reward_Tier__c = 'Solitaire';
        AR3.PGF_LoanId__c = '7797867';
        AR3.PGF_Loan_Reward_Points__c = 50;
        insert Ar3;
        
        Ar3.Approval_Status__c ='rejected';
        AR3.PGF_Loan_Reward_Points__c = 80;
        update Ar3;
        
         Ar8.Approval_Status__c ='approved';
        AR3.PGF_Loan_Reward_Points__c = 30;
        update Ar3;
        
        Account acc3 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc3.FirstName = 'TestMe11';
        acc3.LastName = 'Lasting11';
        acc3.AgentNet_ID__c = '17886';
        acc3.Salutation = 'Mrs.';
        acc3.CurrencyIsoCode = 'SGD';
        acc3.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc3.BillingStreet = 'tes1t';
        acc3.BillingCity = 'test1';
        acc3.BillingCountry = 'Singapore';
        acc3.BillingPostalCode = '128373';
        //  acc.BillingState = 'test';
        acc3.Current_Subscription_Code__c = '1abc';
        acc3.PersonEmail = 'test913@1yuni.com';
        acc3.Account_Rule_Code__c = 'Standard';
        acc3.Status__c = 'Active';
        acc3.Country__c = 'Singapore';
        acc3.Agency__c = agency.id;
        acc3.Subsidiary__c = subId;
        acc3.CEA_Salesperson_Number__c='A000234A';
        acc3.PersonBirthdate=system.today();
        acc3.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc3.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc3.VIP_Campaign__c = 'VIP Advance SC';
        acc3.Approval_Status__c = 'Test';
        acc3.Reward_Tier__c ='Gold';
        
        insert acc3;
        
         acc3.CEA_Salesperson_Number__c = '';
        
        
        Agent_reward__c Ar13 = new Agent_reward__c();
        Ar13.Account__c = acc3.id;
        Ar13.Status__c = 'New Quarter';
        Ar13.Discretionary_Spending__c =20000;
        Ar13.Subscription_Spending__c = 2322;
        Ar13.Reward_Points__c = 2000;
        Ar13.Reward_Tier__c = 'Solitaire';
        AR13.PGF_LoanId__c = '17797867';
        AR13.PGF_Loan_Reward_Points__c = 50;
        insert Ar13;
        
        List<Update_PGF_Reward_Points__e> eventPGFList = new List<Update_PGF_Reward_Points__e>();
        Update_PGF_Reward_Points__e pgfEvent = new Update_PGF_Reward_Points__e();
        pgfEvent.Account_Id__c = acc.Id;
        pgfEvent.PGF_Reward_Points__c = acc.PGF_Reward_Points__c;
        pgfEvent.Reward_Points__c = acc.Reward_Points__c;
        eventPGFList.add(pgfEvent);
        
        String AccountId = '001689754412345678';
        Update_PGF_Reward_Points__e pgfEvent1 = new Update_PGF_Reward_Points__e();
        pgfEvent1.Account_Id__c = acc1.Id;
        pgfEvent1.PGF_Reward_Points__c = 50.02;
        pgfEvent1.Reward_Points__c = acc1.Reward_Points__c;
        eventPGFList.add(pgfEvent1);
       
        EventBus.publish(eventPGFList);
        
        
        
        PGUpdatePGFPointsController.createErrorLog(Ar3.id,JSON.serialize(Ar3),'error');
        PGUpdatePGFPointsController.updateAgentPGFPoints(eventPGFList);
        Test.stopTest();
        
    }
}