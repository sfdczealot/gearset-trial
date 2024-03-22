@isTest
public class publishRewardsToAgents_Test {
    
    private static testmethod void publishPointsTest(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='A123476Y';
        acc.PG_Reward_Points__c = 50;
        acc.PGF_Reward_Points__c = 50;
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 100;
        acc.Reward_Tier__c = 'Gold';
        listAccount.add(acc);
        insert listAccount;
        
        Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.PG_Reward_Points__c = 50;
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='H453678J';
        acc1.PGF_Reward_Points__c = 50;
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 3000;
        Ar1.Reward_Tier__c = 'Gold';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 3000;
        Ar3.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 3000;
        Ar2.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar2);
        insert ARList;
        
        Ar3.Approval_Status__c ='rejected';
        update Ar3;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        publishRewardsToAgents.publishPoints(ARList,accMap,'Malaysia',false);
        publishRewardsToAgents.calculateTier(400,acc.Id,'singapore');
         publishRewardsToAgents.calculateTier(400,acc.Id,'Malaysia');
       
        //publishRewardsToAgents.calculateTier(800,acc.Id,'singapore');
        //publishRewardsToAgents.calculateTier(1300,acc.Id,'singapore');
        //publishRewardsToAgents.calculateTier(2600,acc.Id,'singapore');
        Test.stopTest();
        }
    }
    
    private static testmethod void publishPointsTest1(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        Map<Id,Account> accMap = new Map<Id,Account>();
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='F342563H';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 300;
        acc.Reward_Tier__c = 'Gold';
        listAccount.add(acc);
        insert listAccount;
        
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='T342636J';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 3000;
        Ar1.Reward_Tier__c = 'Gold';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 3000;
        Ar3.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 300;
        Ar6.Reward_Tier__c = 'Gold';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    
    private static testmethod void publishPointsTest2(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='K456378A';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 3000;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
         
        
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 300;
        Ar6.Reward_Tier__c = 'Gold';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 3000;
        Ar2.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    
    private static testmethod void publishPointsTest4(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='D233458K';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        //acc.Reward_Points__c = 100;
        acc.Reward_Tier__c = 'Gold';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='A453627L';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 300;
        Ar5.Reward_Tier__c = 'Gold';
        ARList.add(Ar5);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest5(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='B123456B';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 3000;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='A332536K';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);  
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 3000;
        Ar1.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 3000;
        Ar3.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 3000;
        Ar6.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 3000;
        Ar2.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest6(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='S856745L';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 200;
        acc.Reward_Tier__c = 'Silver';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='V231323N';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 3000;
        Ar1.Reward_Tier__c = 'Gold';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 3000;
        Ar3.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 200;
        Ar6.Reward_Tier__c = 'Silver';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest3(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='U453645B';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 300;
        acc.Reward_Tier__c = 'Gold';
        listAccount.add(acc);
        insert listAccount;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 300;
        Ar6.Reward_Tier__c = 'Gold';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 3000;
        Ar2.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    
    private static testmethod void publishPointsTest7(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='E342536N';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 200;
        acc.Reward_Tier__c = 'Silver';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='I453645B';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 3000;
        Ar1.Reward_Tier__c = 'Gold';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 3000;
        Ar3.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 3000;
        Ar6.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    
    private static testmethod void publishPointsTest8(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='V232534N';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 300;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
         
        
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 3000;
        Ar6.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 3000;
        Ar2.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    
    private static testmethod void publishPointsTest9(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='P453846B';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 3000;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        
         Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 300;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 4000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 300;
        Ar6.Reward_Tier__c = 'Gold';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    
   private static testmethod void publishPointsTest10(){
       User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='A458936N';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 3000;
        acc.Reward_Tier__c = 'Gold';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='F342534K';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 3000;
        Ar1.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 3000;
        Ar3.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 3000;
        Ar6.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 3000;
        Ar2.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest11(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='E234123K';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        //acc.Reward_Points__c = 100;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='G463589G';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 300;
        Ar5.Reward_Tier__c = 'Gold';
        ARList.add(Ar5);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    
    private static testmethod void publishPointsTest12(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='D765676H';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 3000;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='K564538L';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 300;
        Ar1.Reward_Tier__c = 'Gold';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 5000;
        Ar3.Reward_Tier__c = 'Gold';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 5000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 5000;
        Ar5.Reward_Tier__c = 'Gold';
        ARList.add(Ar5);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        //Ar5.Account__c = acc1.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 5000;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Ar3.Approval_Status__c ='rejected';
        update Ar3;
        
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        publishRewardsToAgents.calculateTier(400,acc.Id,'singapore');
        publishRewardsToAgents.calculateTier(800,acc.Id,'singapore');
        publishRewardsToAgents.calculateTier(1300,acc.Id,'singapore');
        publishRewardsToAgents.calculateTier(2600,acc.Id,'singapore');
        Test.stopTest();
        }
    }
    
    private static testmethod void publishPointsTest13(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='Y235634O';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 3000;
        acc.Reward_Tier__c = 'Silver';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='W2343561L';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 300;
        Ar1.Reward_Tier__c = 'Gold';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 5000;
        Ar3.Reward_Tier__c = 'Gold';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 5000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 5000;
        Ar5.Reward_Tier__c = 'Gold';
        ARList.add(Ar5);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        //Ar5.Account__c = acc1.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 5000;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Ar3.Approval_Status__c ='rejected';
        update Ar3;
        
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        publishRewardsToAgents.calculateTier(400,acc.Id,'singapore');
        publishRewardsToAgents.calculateTier(800,acc.Id,'singapore');
        publishRewardsToAgents.calculateTier(1300,acc.Id,'singapore');
        publishRewardsToAgents.calculateTier(2600,acc.Id,'singapore');
        Test.stopTest();
        }
    }
    
   private static testmethod void publishPointsTest14(){
       User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='P456374J';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 200;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='Q253645P';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 5000;
        Ar1.Reward_Tier__c = 'Gold';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 5000;
        Ar3.Reward_Tier__c = 'Silver';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 5000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 5000;
        Ar5.Reward_Tier__c = 'Silver';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 200;
        Ar6.Reward_Tier__c = 'Silver';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        publishRewardsToAgents.publishPoints(ARList,accMap,'Malaysia',true);
        
        Test.stopTest();
        }
    }
    
    private static testmethod void publishPointsTest15(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='T345243U';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 300;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='O567435M';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 3000;
        Ar1.Reward_Tier__c = 'Gold';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 3000;
        Ar3.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 300;
        Ar6.Reward_Tier__c = 'Gold';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    
    private static testmethod void publishPointsTest16(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='P456347O';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 200;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='P536245B';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        Agent_reward__c Ar1 = new Agent_reward__c();
        Ar1.Account__c = acc.id;
        Ar1.Status__c = 'New Quarter';
        Ar1.Discretionary_Spending__c =1000;
        Ar1.Subscription_Spending__c = 2322;
        Ar1.Reward_Points__c = 3000;
        Ar1.Reward_Tier__c = 'Gold';
        ARList.add(Ar1);
        
        Agent_reward__c Ar3 = new Agent_reward__c();
        Ar3.Account__c = acc.id;
        Ar3.Status__c = 'New Quarter';
        Ar3.Discretionary_Spending__c =1000;
        Ar3.Subscription_Spending__c = 2322;
        Ar3.Reward_Points__c = 3000;
        Ar3.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar3);
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 3000;
        Ar6.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest17(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='R345243L';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 3000;
        acc.Reward_Tier__c = 'Gold';
        listAccount.add(acc);
        insert listAccount;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
         
        
        Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = 'AgentNet_ID__c test1';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '83731';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test@1yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='Y345289K';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        acc1.Reward_Points__c = 13000;
        acc1.Reward_Tier__c = 'Platinum';
        insert acc1;
         accMap.put(acc1.id,acc1);
     
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);

        Agent_reward__c Ar10 = new Agent_reward__c();
        Ar10.Account__c = acc1.id;
        Ar10.Status__c = 'New Quarter';
        Ar10.Discretionary_Spending__c =1000;
        Ar10.Subscription_Spending__c = 2322;
        Ar10.Reward_Points__c = 3000;
        Ar10.Reward_Tier__c = 'Gold';
        ARList.add(Ar10);  
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 300;
        Ar6.Reward_Tier__c = 'Gold';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 3000;
        Ar2.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
         publishRewardsToAgents.publishPoints(ARList,accMap,'Malaysia',true);
       
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest18(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='E245735J';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 300;
        acc.Reward_Tier__c = 'Gold';
        listAccount.add(acc);
        insert listAccount;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
         
        
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 80;
        Ar6.Reward_Tier__c = 'elite';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 30;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        publishRewardsToAgents.calculateTier(160,listAccount[0].id,'singapore');
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest19(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='C467534K';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 300;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
         
        
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 80;
        Ar6.Reward_Tier__c = 'elite';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 30;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        publishRewardsToAgents.calculateTier(160,listAccount[0].id,'singapore');
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest20(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
       Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='D3452437G';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 3000;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        
         Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 300;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 4000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 300;
        Ar6.Reward_Tier__c = 'Gold';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 4000;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest21(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
       Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='V3452378L';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 3000;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        
         Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 300;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 4000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 4000;
        Ar6.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 4000;
        Ar2.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar2);
        
        
        Agent_reward__c Ar14 = new Agent_reward__c();
        Ar14.Account__c = acc.id;
        Ar14.Status__c = 'New Quarter';
        Ar14.Discretionary_Spending__c =1000;
        Ar14.Subscription_Spending__c = 2322;
        Ar14.Reward_Points__c = 300;
        Ar14.Reward_Tier__c = 'Gold';
        ARList.add(Ar14);
        insert ARList;
        
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        publishRewardsToAgents.publishPoints(ARList,accMap,'Malaysia',true);
        
        Test.stopTest();
        }
    }
     private static testmethod void publishPointsTest22(){
         User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='E234123K';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        //acc.Reward_Points__c = 100;
        acc.Reward_Tier__c = 'Platinum';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='G463589G';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        acc1.Reward_Tier__c = 'Platinum';
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 300;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest23(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='E234123K';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        //acc.Reward_Points__c = 100;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        
         Account acc1 = new Account();
        PGTestDataFactory_v2.initSetupData();
        acc1.FirstName = 'TestMe';
        acc1.LastName = 'Lasting';
        acc1.AgentNet_ID__c = '76886';
        acc1.Salutation = 'Mrs.';
        acc1.CurrencyIsoCode = 'SGD';
        acc1.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc1.BillingStreet = 'test';
        acc1.BillingCity = 'test';
        acc1.BillingCountry = 'Singapore';
        acc1.BillingPostalCode = '8373';
        //  acc.BillingState = 'test';
        acc1.Current_Subscription_Code__c = 'abc';
        acc1.PersonEmail = 'test1@yuni.com';
        acc1.Account_Rule_Code__c = 'Standard';
        acc1.Status__c = 'Active';
        acc1.Country__c = 'Singapore';
        acc1.Agency__c = agency.id;
        acc1.Subsidiary__c = subId;
        acc1.CEA_Salesperson_Number__c='G463589G';
        acc1.PersonBirthdate=system.today();
        acc1.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc1.VIP_Campaign__c = 'VIP Advance SC';
        acc1.Approval_Status__c = 'Test';
        
        insert acc1;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 300;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 300;
        Ar2.Reward_Tier__c = 'Gold';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        }
    }
    private static testmethod void publishPointsTest24(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
         Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        id subId = PGTestDataFactory.createSubsidiary().Id;
        list<Account> listAccount = new list<Account>();
        Account agency = new Account();
        PGTestDataFactory_v2.initSetupData();
        agency.name = 'Unit Test Agency';
        agency.Agency_Id__c = '40574';
        agency.CEA_License__c = 'CEAUNittest1';
        agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        agency.Country__c = 'Singapore';
        agency.Subsidiary__c = subId;
        insert agency;
        
        
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
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'Standard';
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='U453645B';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
        acc.Reward_Points__c = 300;
        acc.Reward_Tier__c = 'Solitaire';
        listAccount.add(acc);
        insert listAccount;
        Map<Id,Account> accMap = new Map<Id,Account>();
        accMap.put(listAccount[0].id,listAccount[0]);
        
        list<agent_reward__c> ARList = new list<agent_reward__C>();
        
        Agent_reward__c Ar4 = new Agent_reward__c();
        Ar4.Account__c = acc.id;
        Ar4.Status__c = 'New Quarter';
        Ar4.Discretionary_Spending__c =1000;
        Ar4.Subscription_Spending__c = 2322;
        Ar4.Reward_Points__c = 3000;
        Ar4.Reward_Tier__c = 'Gold';
        ARList.add(Ar4);
        
        Agent_reward__c Ar5 = new Agent_reward__c();
        Ar5.Account__c = acc.id;
        Ar5.Status__c = 'New Quarter';
        Ar5.Discretionary_Spending__c =1000;
        Ar5.Subscription_Spending__c = 2322;
        Ar5.Reward_Points__c = 3000;
        Ar5.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar5);
        
        Agent_reward__c Ar6 = new Agent_reward__c();
        Ar6.Account__c = acc.id;
        Ar6.Status__c = 'Published';
        Ar6.Discretionary_Spending__c =1000;
        Ar6.Subscription_Spending__c = 2322;
        Ar6.Reward_Points__c = 300;
        Ar6.Reward_Tier__c = 'Gold';
        ARList.add(Ar6);
        
        Agent_reward__c Ar2 = new Agent_reward__c();
        Ar2.Account__c = acc.id;
        Ar2.Status__c = 'Published';
        Ar2.Discretionary_Spending__c =1000;
        Ar2.Subscription_Spending__c = 2322;
        Ar2.Reward_Points__c = 3000;
        Ar2.Reward_Tier__c = 'Solitaire';
        ARList.add(Ar2);
        insert ARList;
        
        Test.startTest();
        publishRewardsToAgents.publishPoints(ARList,accMap,'Singapore',true);
        Test.stopTest();
        
        }
    }
    
}