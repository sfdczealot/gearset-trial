@isTest
public class PGAccountTriggerHandler_Test {
    public testMethod static void runTest() {
        Test.startTest();
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGCampMemberTrigger';
            TE.Enable_del__c = true;
            insert TE;
            
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
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
            list<Account> listAccount = new list<Account>();
            Account acc = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc.FirstName = 'TestMe';
            acc.LastName = 'Lasting';
            acc.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc.Salutation = 'Mrs.';
            acc.CurrencyIsoCode = 'SGD';
            //acc.Lead_BirthDate__c =system.today();
            acc.PersonBirthdate = system.today().addDays(-30);
            acc.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc.BillingStreet = 'test';
            acc.BillingCity = 'test';
            acc.Reward_Points__c = 700;
            acc.Reward_Tier__c = 'Gold';
            acc.BillingCountry = 'Singapore';
            acc.BillingPostalCode = '8373';
            //  acc.BillingState = 'test';
            acc.Current_Subscription_Code__c = 'abc';
            acc.PersonEmail = 'test@yuni.com';
            acc.Account_Rule_Code__c = 'test';
            acc.Status__c = 'Active';
            acc.Country__c = 'Singapore';
            acc.Agency__c = agency.id;
            acc.Subsidiary__c = subId;
            acc.CEA_Salesperson_Number__c='R123456H';
            acc.PersonBirthdate=system.today();
            acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc.VIP_Campaign__c = 'VIP Advance SC';
            acc.Approval_Status__c = 'Test';
            acc.Mobile_Country__c='65';
            acc.Created_From_AdminNet__c = true;
            
            Account accReward = new Account();
            PGTestDataFactory_v2.initSetupData();
            accReward.FirstName = 'TestMe';
            accReward.LastName = 'Lasting';
            accReward.AgentNet_ID__c = 'AgentNet_ID__c test';
            accReward.Salutation = 'Mrs.';
            accReward.CurrencyIsoCode = 'SGD';
            accReward.Subscription_Start_Date__c = system.today().addMonths(-10);
            accReward.BillingStreet = 'test';
            accReward.BillingCity = 'test';
            //accReward.Lead_BirthDate__c =system.today();
            accReward.BillingCountry = 'Singapore';
            accReward.BillingPostalCode = '8373';
            //  acc.BillingState = 'test';
            accReward.Current_Subscription_Code__c = 'abc';
            accReward.PersonEmail = 'accReward@yuni.com';
            accReward.Account_Rule_Code__c = 'test';
            accReward.Status__c = 'Active';
            accReward.Country__c = 'Singapore';
            accReward.Agency__c = agency.id;
            accReward.Subsidiary__c = subId;
            accReward.CEA_Salesperson_Number__c='A678996A';
            accReward.PersonBirthdate=system.today();
            accReward.Subscription_End_Date__c = Date.newInstance(2030, 12, 9);
            accReward.Subscription_Start_Date__c = System.today();
            accReward.Account_Rule_Code__c ='Standard';
            accReward.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            accReward.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            accReward.VIP_Campaign__c = 'VIP Advance SC';
            accReward.Approval_Status__c = 'Test';
            accReward.Created_From_AdminNet__c = true;
            accReward.Mobile_Country__c='65';
            listAccount.add(accReward);
            listAccount.add(acc); 
            
            Account acc2 = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc2.FirstName = 'TestMe';
            acc2.LastName = 'Lasting';
            
            acc2.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc2.Salutation = 'Mrs.';
            acc2.CurrencyIsoCode = 'SGD';
            acc2.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc2.BillingStreet = 'test';
            acc2.BillingCity = 'test';
            acc2.BillingCountry = 'Singapore';
            //acc2.Lead_BirthDate__c =system.today();
            acc2.BillingPostalCode = '83273';
            //acc2.BillingState = 'test';
            acc2.Current_Subscription_Code__c = 'abc';
            acc2.PersonBirthdate = system.today();
            acc2.PersonEmail = 'test@yuwni.com';
            acc2.Account_Rule_Code__c = 'test';
            acc2.Status__c = 'Pending';
            acc2.Country__c = 'Singapore';
            acc2.Agency__c = agency.id;
            acc2.Subsidiary__c = subId;
            acc2.CEA_Salesperson_Number__c='R123456H';
            acc2.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc2.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc2.VIP_Campaign__c = 'VIP Advance SC-1';
            acc2.Approval_Status__c = '';
            acc2.Mobile_Country__c='65';
            listAccount.add(acc2);
            PGAccountTriggerHandler.setQualifyAgentReferral(listAccount);
            insert listAccount;
            PGAccountTriggerHandler.markAsTestAccount(listAccount,null);
            
            listAccount[0].Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            listAccount[0].Loyalty_Start_Date__c = Date.newInstance(2017, 12, 9);
            update listAccount;
            
            Account ac = [Select Id,PersonContactId,VIP_Campaign__c from Account where Id = : acc2.Id limit 1];
            
            Campaign cma = new Campaign();
            cma.Name = 'VIP Advance SC-1';
            cma.Country__c = 'Singapore';
            cma.IsActive = true;
            cma.CurrencyIsoCode = 'SGD';
            cma.EndDate = system.today().addDays(-2);
            cma.VIP_Quota__c = 2;
            insert cma;
            
            CampaignMember cmp = new CampaignMember();
            cmp.ContactId = ac.PersonContactId;
            cmp.Status = 'Approved';
            cmp.CampaignId = cma.Id;
            insert cmp;
            
            
            Contact con = new Contact();
            con.FirstName = 'TestFName';
            con.LastName = 'testLname';
            con.Email = 'test@nmail.com';
            insert con;
            
            CampaignMember cmp1 = new CampaignMember();
            cmp1.ContactId = con.Id;
            cmp1.Status = 'Approved';
            cmp1.CampaignId = cma.Id;
            insert cmp1;
            
            PGAccountTriggerHandler.accountTriggerRecursion = false;
            
            Map<Id,Account> oldMap = new Map<Id,Account>();
            PGAccountTriggerHandler.updatePGTenure(listAccount, oldMap);
            PGAccountTriggerHandler.increasecoverage();
            acc2.Approval_Status__c = acc2.VIP_Campaign__c+'Approved';
            acc2.VIP__c = true;
            acc2.Status__c = 'Trial';
            update acc2;
        }
        Test.stopTest();
    }
    public testMethod static void runTest1() {
        Test.startTest();
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGCampMemberTrigger';
            TE.Enable_del__c = true;
            insert TE;
            
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
            
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
            list<Account> listAccount = new list<Account>();
            Account acc = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc.FirstName = 'TestMe';
            acc.LastName = 'Lasting';
            acc.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc.Salutation = 'Mrs.';
            acc.CurrencyIsoCode = 'SGD';
            acc.PersonBirthdate = system.today().addDays(-30);
            acc.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc.BillingStreet = 'test';
            // acc.Lead_BirthDate__c =system.today();
            acc.BillingCity = 'test';
            acc.Reward_Points__c = 700;
            acc.Reward_Tier__c = 'Gold';
            acc.BillingCountry = 'Singapore';
            acc.BillingPostalCode = '8373';
            //  acc.BillingState = 'test';
            acc.Current_Subscription_Code__c = 'abc';
            acc.PersonEmail = 'test@yuni.com';
            acc.Account_Rule_Code__c = 'test';
            acc.Status__c = 'Active';
            acc.Country__c = 'Singapore';
            acc.Agency__c = agency.id;
            acc.Subsidiary__c = subId;
            acc.CEA_Salesperson_Number__c='R123456H';
            acc.PersonBirthdate=system.today();
            acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc.VIP_Campaign__c = 'VIP Advance SC';
            acc.Approval_Status__c = 'Test';
            acc.Created_From_AdminNet__c = true;
            acc.Mobile_Country__c = '65';
            
            Account accReward = new Account();
            PGTestDataFactory_v2.initSetupData();
            accReward.FirstName = 'TestMe';
            accReward.LastName = 'Lasting';
            accReward.AgentNet_ID__c = 'AgentNet_ID__c test';
            accReward.Salutation = 'Mrs.';
            accReward.CurrencyIsoCode = 'SGD';
            accReward.Subscription_Start_Date__c = system.today().addMonths(-10);
            accReward.BillingStreet = 'test';
            accReward.BillingCity = 'test';
            //accReward.Lead_BirthDate__c =system.today();
            accReward.BillingCountry = 'Singapore';
            accReward.BillingPostalCode = '8373';
            //  acc.BillingState = 'test';
            accReward.Current_Subscription_Code__c = 'abc';
            accReward.PersonEmail = 'accReward@yuni.com';
            accReward.Account_Rule_Code__c = 'test';
            accReward.Status__c = 'Active';
            accReward.Country__c = 'Singapore';
            accReward.Agency__c = agency.id;
            accReward.Subsidiary__c = subId;
            accReward.CEA_Salesperson_Number__c='A678996A';
            accReward.PersonBirthdate=system.today();
            accReward.Subscription_End_Date__c = Date.newInstance(2030, 12, 9);
            accReward.Subscription_Start_Date__c = System.today();
            accReward.Account_Rule_Code__c ='Standard';
            accReward.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            accReward.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            accReward.VIP_Campaign__c = 'VIP Advance SC';
            accReward.Approval_Status__c = 'Test';
            accReward.Created_From_AdminNet__c = true;
            accReward.Mobile_Country__c = '65';
            listAccount.add(accReward);
            listAccount.add(acc); 
            
            Account acc2 = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc2.FirstName = 'TestMe';
            acc2.LastName = 'Lasting';
            
            acc2.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc2.Salutation = 'Mrs.';
            acc2.CurrencyIsoCode = 'SGD';
            acc2.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc2.BillingStreet = 'test';
            acc2.BillingCity = 'test';
            acc2.BillingCountry = 'Singapore';
            acc2.BillingPostalCode = '83273';
            //acc2.BillingState = 'test';
            //acc2.Lead_BirthDate__c =system.today();
            acc2.Current_Subscription_Code__c = 'abc';
            acc2.PersonBirthdate = system.today();
            acc2.PersonEmail = 'test@yuwni.com';
            acc2.Account_Rule_Code__c = 'test';
            acc2.Status__c = 'Active';
            acc2.Country__c = 'Singapore';
            acc2.Agency__c = agency.id;
            acc2.Subsidiary__c = subId;
            acc2.CEA_Salesperson_Number__c='R123456H';
            acc2.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc2.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc2.VIP_Campaign__c = 'VIP Advance SC-1';
            acc2.Approval_Status__c = '';
            acc2.Mobile_Country__c = '65';
            listAccount.add(acc2);
            PGAccountTriggerHandler.setQualifyAgentReferral(listAccount);
            insert listAccount;
            /*acc3.LocalLanguage_last_name__c ='testLast';
acc3.localLanguage_First_name__c ='testFirst';
acc3.FirstName = 'First';
acc3.LastName = 'Last';
acc3.Customer_Type__c='Owner';
update acc3;*/
            listAccount[0].Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            listAccount[0].Loyalty_Start_Date__c = Date.newInstance(2017, 12, 9);
            update listAccount;
            
            Account ac = [Select Id,name,PersonContactId,VIP_Campaign__c from Account where Id = : acc2.Id limit 1];
            
            Campaign cma = new Campaign();
            cma.Name = ac.Name;
            cma.Country__c = 'Singapore';
            cma.IsActive = true;
            cma.CurrencyIsoCode = 'SGD';
            cma.EndDate = system.today().addDays(-2);
            cma.VIP_Quota__c = 1;
            insert cma;
            
            CampaignMember cmp = new CampaignMember();
            cmp.ContactId = ac.PersonContactId;
            cmp.Status = 'Approved';
            cmp.CampaignId = cma.Id;
            insert cmp;
            
            Map<Id,Account> oldMap = new Map<Id,Account>();
            PGAccountTriggerHandler.updatePGTenure(listAccount, oldMap);
            PGAccountTriggerHandler.increasecoverage();
            
        }
        Test.stopTest();
        
    }
    
    public testMethod static void runTest2() {
        User thisUser = [SELECT Id,Subsidiary__c,profile.name FROM User WHERE country = 'Malaysia' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs (thisUser) {
            Test.startTest();
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGCampMemberTrigger';
            TE.Enable_del__c = true;
            insert TE;
            
            id subId = PGTestDataFactory.createMYSubsidiary().Id;
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '000000';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Malaysia';
            agency.Subsidiary__c = subId;
            listAccount1.add(agency);
            
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
            list<Account> listAccount = new list<Account>();
            Account acc = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc.FirstName = 'TestMe';
            acc.LastName = 'Lasting';
            acc.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc.Salutation = 'Mrs.';
            acc.CurrencyIsoCode = 'MYR';
            acc.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc.BillingStreet = 'test';
            acc.BillingCity = 'test';
            acc.BillingCountry = 'Malaysia';
            acc.BillingPostalCode = '83712';
            // acc.BillingState = 'test';
            acc.Current_Subscription_Code__c = 'abc';
            acc.PersonEmail = 'test@yuni.com';
            acc.Account_Rule_Code__c = 'test';
            acc.Status__c = 'Active';
            acc.Country__c = 'Malaysia';
            acc.Agency__c = agency.id;
            acc.Subsidiary__c = subId;
            acc.CEA_Salesperson_Number__c='K123456H';
            acc.PersonBirthdate=system.today();
            acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc.Mobile_Country__c = '60';
            listAccount.add(acc); 
            Account acc2 = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc2.FirstName = 'TestMe';
            acc2.LastName = 'Lasting';
            acc2.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc2.Salutation = 'Mrs.';
            acc2.CurrencyIsoCode = 'MYR';
            acc2.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc2.BillingStreet = 'test';
            acc.BillingCity = 'test';
            acc.BillingCountry = 'Malaysia';
            acc2.BillingPostalCode = '83210';
            // acc2.BillingState = 'test';
            acc2.Current_Subscription_Code__c = 'abc';
            acc2.PersonEmail = 'test@yuwni.com';
            acc2.Account_Rule_Code__c = 'test';
            acc2.Status__c = 'Active';
            acc2.Country__c = 'Malaysia';
            acc2.Agency__c = agency.id;
            acc2.Subsidiary__c = subId;
            acc2.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc2.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc2.VIP_Campaign__c = 'VIP Advance SC-1';
            acc2.Approval_Status__c = '';
            acc2.CEA_Salesperson_Number__c='N123456H';
            acc2.Mobile_Country__c = '60';
            listAccount.add(acc2);
            
            Account acc3 = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc3.FirstName = 'TestMe';
            acc3.LastName = 'Lasting';
            acc3.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc3.Salutation = 'Mrs.';
            acc3.CurrencyIsoCode = 'MYR';
            acc3.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc3.BillingStreet = 'test';
            acc3.BillingCity = 'test';
            acc3.BillingCountry = 'Malaysia';
            acc3.BillingPostalCode = '83210';
            // acc3.BillingState = 'test';
            acc3.Current_Subscription_Code__c = 'abc';
            acc3.PersonEmail = 'test@yuwni.com';
            acc3.Account_Rule_Code__c = 'test';
            acc3.Status__c = 'Active';
            acc3.Country__c = 'Malaysia';
            acc3.Agency__c = agency.id;
            acc3.Subsidiary__c = subId;
            acc3.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc3.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc3.VIP_Campaign__c = 'VIP Advance SC-1';
            acc3.Approval_Status__c = '';
            acc3.CEA_Salesperson_Number__c='G123456U';
            acc.PersonBirthdate=system.today();
            acc3.PersonMobilePhone='132453678';
            acc3.Mobile_Country__c='66';
            
            listAccount.add(acc3);
            
            PGAccountTriggerHandler.setQualifyAgentReferral(listAccount);
            insert listAccount;
            acc3.LocalLanguage_last_name__c ='testLast';
            acc3.localLanguage_First_name__c ='testFirst';
            acc3.FirstName = 'First';
            acc3.LastName = 'Last';
            acc3.Customer_Type__c='Owner';
            update acc3;
            listAccount[0].Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            listAccount[0].Loyalty_Start_Date__c = Date.newInstance(2017, 12, 9);
            update listAccount;
            
            Account ac = [Select Id,name,PersonContactId,VIP_Campaign__c from Account where Id = : acc2.Id limit 1];
            
            Campaign cma = new Campaign();
            cma.Name = ac.Name;
            cma.Country__c = 'Malaysia';
            cma.IsActive = true;
            cma.EndDate = system.today().addDays(-2);
            cma.CurrencyIsoCode = 'MYR';
            cma.VIP_Quota__c = 1;
            insert cma;
            
            CampaignMember cmp = new CampaignMember();
            cmp.ContactId = ac.PersonContactId;
            cmp.Status = 'Approved';
            cmp.CampaignId = cma.Id;
            insert cmp;
            
            
            
            Map<Id,Account> oldMap = new Map<Id,Account>();
            PGAccountTriggerHandler.updatePGTenure(listAccount, oldMap);
            // PGAccountTriggerHandler.updatePGTenure(listAccount4, oldMap);
            PGAccountTriggerHandler.increasecoverage();
            Test.stopTest();
        }
    }
    
    public testMethod static void runTest3() {
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Thailand' and isActive = true and profile.name = 'TH B2C Sales User' Limit 1];
        System.runAs (thisUser) {
            Test.startTest();
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGCampMemberTrigger';
            TE.Enable_del__c = true;
            insert TE;
            
            User usr = new User();
            usr.Id = UserInfo.getUserId();
            
            id subId = PGTestDataFactory_v2.createTHSubsidiary(usr).Id;
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '000000';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Thailand';
            agency.Subsidiary__c = subId;
            listAccount1.add(agency);
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
            list<Account> listAccount = new list<Account>();
            Account acc = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc.FirstName = 'TestMe';
            acc.LastName = 'Lasting';
            acc.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc.Salutation = 'Mrs.';
            acc.CurrencyIsoCode = 'THB';
            acc.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc.BillingStreet = 'test';
            acc.BillingCity = 'test';
            acc.BillingCountry = 'Thailand';
            acc.BillingPostalCode = '83712';
            // acc.BillingState = 'test';
            acc.Current_Subscription_Code__c = 'abc';
            acc.PersonEmail = 'test@yuni.com';
            acc.Account_Rule_Code__c = 'test';
            acc.Status__c = 'Active';
            acc.Country__c = 'Thailand';
            acc.Agency__c = agency.id;
            acc.Subsidiary__c = subId;
            acc.CEA_Salesperson_Number__c='P12345678H';
            acc.PersonBirthdate=system.today();
            acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc.PersonMobilePhone = '876544';
            acc.Mobile_Country__c='66';
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            listAccount.add(acc); 
            Account acc2 = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc2.FirstName = 'TestMe';
            acc2.LastName = 'Lasting';
            acc2.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc2.Salutation = 'Mrs.';
            acc2.CurrencyIsoCode = 'THB';
            acc2.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc2.BillingStreet = 'test';
            acc2.BillingCity = 'test';
            acc2.BillingCountry = 'Thailand';
            acc2.BillingPostalCode = '83210';
            // acc2.BillingState = 'test';
            acc2.Current_Subscription_Code__c = 'abc';
            acc2.PersonEmail = 'test@yuwni.com';
            acc2.Account_Rule_Code__c = 'test';
            acc2.Status__c = 'Active';
            acc2.Country__c = 'Thailand';
            acc2.Agency__c = agency.id;
            acc2.Subsidiary__c = subId;
            acc2.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc2.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc2.VIP_Campaign__c = 'VIP Advance SC-1';
            acc2.Approval_Status__c = '';
            acc2.PersonMobilePhone = '876544';
            acc2.Mobile_Country__c='66';
            acc2.CEA_Salesperson_Number__c='J123456H';
            listAccount.add(acc2);
            
            Account acc3 = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc3.FirstName = 'TestMe';
            acc3.LastName = 'Lasting';
            acc3.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc3.Salutation = 'Mrs.';
            acc3.CurrencyIsoCode = 'THB';
            acc3.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc3.BillingStreet = 'test';
            acc3.BillingCity = 'test';
            acc3.BillingCountry = 'Thailand';
            acc3.BillingPostalCode = '83210';
            // acc3.BillingState = 'test';
            acc3.Current_Subscription_Code__c = 'abc';
            acc3.PersonEmail = 'test@yuwni.com';
            acc3.Account_Rule_Code__c = 'test';
            acc3.Status__c = 'Active';
            acc3.Country__c = 'Thailand';
            acc3.Agency__c = agency.id;
            acc3.Subsidiary__c = subId;
            acc3.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc3.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc3.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc3.VIP_Campaign__c = 'VIP Advance SC-1';
            acc3.Approval_Status__c = '';
            acc3.CEA_Salesperson_Number__c='X123456R';
            acc.PersonBirthdate=system.today();
            acc3.PersonMobilePhone='132453678';
            acc3.Mobile_Country__c='66';
            acc3.PersonMobilePhone = '876544';
            listAccount.add(acc3);
            
            PGAccountTriggerHandler.setQualifyAgentReferral(listAccount);
            insert listAccount;
            acc3.LocalLanguage_last_name__c ='testLast';
            acc3.localLanguage_First_name__c ='testFirst';
            acc3.FirstName = 'First';
            acc3.LastName = 'Last';
            //acc3.Customer_Type__c='Owner';
            update acc3;
            listAccount[0].Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            listAccount[0].Loyalty_Start_Date__c = Date.newInstance(2017, 12, 9);
            update listAccount;
            
            Account ac = [Select Id,name,PersonContactId,VIP_Campaign__c from Account where Id = : acc2.Id limit 1];
            
            Campaign cma = new Campaign();
            cma.Name = ac.Name;
            cma.Country__c = 'Thailand';
            cma.IsActive = true;
            cma.EndDate = system.today().addDays(-2);
            cma.CurrencyIsoCode = 'THB';
            cma.VIP_Quota__c = 1;
            insert cma;
            
            CampaignMember cmp = new CampaignMember();
            cmp.ContactId = ac.PersonContactId;
            cmp.Status = 'Approved';
            cmp.CampaignId = cma.Id;
            insert cmp;
            
            Map<Id,Account> oldMap = new Map<Id,Account>();
            PGAccountTriggerHandler.updatePGTenure(listAccount, oldMap);
            PGAccountTriggerHandler.increasecoverage();
            Test.stopTest();
        }
    }
    public testMethod static void runTest4() {
        Test.startTest();
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGCampMemberTrigger';
            TE.Enable_del__c = true;
            insert TE;
            
            Rewards_Calculator__c customsetting1  = new Rewards_Calculator__c();
            customsetting1.Name='Singapore';
            customsetting1.X_factor__c=8;
            customsetting1.Y_factor__c=5;
            customsetting1.country__c='Singapore';
            insert customsetting1;
            
            Trigger_Execute__c PGAgentRewardTrigger=new Trigger_Execute__c();
            PGAgentRewardTrigger.Name='PGAgentRewardTrigger';
            PGAgentRewardTrigger.Enable_del__c=true;
            insert PGAgentRewardTrigger;
            
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
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
            list<Account> listAccount = new list<Account>();
            
            Account accReward = new Account();
            PGTestDataFactory_v2.initSetupData();
            accReward.FirstName = 'TestMe';
            accReward.LastName = 'Lasting';
            accReward.AgentNet_ID__c = 'AgentNet_ID__c test';
            accReward.Salutation = 'Mrs.';
            accReward.CurrencyIsoCode = 'SGD';
            accReward.Subscription_Start_Date__c = system.today().addMonths(-10);
            accReward.BillingStreet = 'test';
            accReward.BillingCity = 'test';
            accReward.BillingCountry = 'Singapore';
            accReward.BillingPostalCode = '8373';
            //  acc.BillingState = 'test';
            accReward.Current_Subscription_Code__c = 'abc';
            accReward.PersonEmail = 'accReward@yuni.com';
            accReward.Account_Rule_Code__c = 'test';
            accReward.Status__c = 'Trial';
            accReward.Country__c = 'Singapore';
            accReward.Agency__c = agency.id;
            accReward.Subsidiary__c = subId;
            accReward.CEA_Salesperson_Number__c='A678996A';
            accReward.Reward_Points__c = 600;
            accReward.Reward_Tier__c = 'Gold';
            accReward.PersonBirthdate=system.today();
            accReward.Subscription_End_Date__c = Date.newInstance(2030, 12, 9);
            accReward.Subscription_Start_Date__c = System.today();
            accReward.Account_Rule_Code__c ='Standard';
            accReward.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            accReward.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            accReward.VIP_Campaign__c = 'VIP Advance SC';
            accReward.Approval_Status__c = 'Test';
            accReward.Created_From_AdminNet__c = true;
            accReward.Mobile_Country__c = '60';
            listAccount.add(accReward);
            
            insert listAccount;
            accReward.Status__c = 'Active';
            update accReward;
            
            Account accReward1 = new Account();
            PGTestDataFactory_v2.initSetupData();
            accReward1.FirstName = 'TestMe1';
            accReward1.LastName = 'Lasting1';
            accReward1.AgentNet_ID__c = 'AgentNet_ID__c test1';
            accReward1.Salutation = 'Mrs.';
            accReward1.CurrencyIsoCode = 'SGD';
            accReward1.Subscription_Start_Date__c = system.today().addMonths(-10);
            accReward1.BillingStreet = 'test';
            accReward1.BillingCity = 'test';
            accReward1.BillingCountry = 'Singapore';
            accReward1.BillingPostalCode = '8373';
            //  acc.BillingState = 'test';
            accReward1.Current_Subscription_Code__c = 'abc';
            accReward1.PersonEmail = 'accReward@yuni.com';
            accReward1.Account_Rule_Code__c = 'test';
            accReward1.Status__c = 'Trial';
            accReward1.Country__c = 'Singapore';
            accReward1.Agency__c = agency.id;
            accReward1.Subsidiary__c = subId;
            accReward1.CEA_Salesperson_Number__c='A678996A';
            accReward1.Reward_Points__c = 700;
            accReward1.Reward_Tier__c = 'Gold';
            accReward1.PersonBirthdate=system.today();
            accReward1.Subscription_End_Date__c = Date.newInstance(2030, 12, 9);
            accReward1.Subscription_Start_Date__c = System.today();
            accReward1.Account_Rule_Code__c ='Beginner';
            accReward1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            accReward1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            accReward1.VIP_Campaign__c = 'VIP Advance SC';
            accReward1.Approval_Status__c = 'Test';
            accReward1.Created_From_AdminNet__c = true;
            accReward1.Status__c = 'Active';
            accReward1.Mobile_Country__c = '65';
            listAccount.add(accReward1);
            PGAccountTriggerHandler.publishRewardPoints(listAccount,null);
        }
        Test.stopTest();
    }
    
    public testMethod static void runTest5() {
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Thailand' and isActive = true and profile.name = 'TH B2C Sales User' Limit 1];
        System.runAs (thisUser) {
            Test.startTest();
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGCampMemberTrigger';
            TE.Enable_del__c = true;
            insert TE;
            
            id subId = PGTestDataFactory.createSubsidiary().Id;
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Thailand';
            agency.Subsidiary__c = subId;
            listAccount1.add(agency);
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
            list<Account> listAccount = new list<Account>();
            Account acc = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc.FirstName = 'TestMe';
            acc.LastName = 'Lasting';
            acc.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc.Salutation = 'Mrs.';
            acc.CurrencyIsoCode = 'THB';
            acc.PersonMobilePhone = '476867687';
            acc.PersonBirthdate = system.today().addDays(-30);
            acc.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc.BillingStreet = 'test';
            acc.BillingCity = 'test';
            acc.Reward_Points__c = 700;
            acc.Reward_Tier__c = 'Gold';
            acc.BillingCountry = 'Thailand';
            acc.BillingPostalCode = '83736';
            //  acc.BillingState = 'test';
            acc.Current_Subscription_Code__c = 'abc';
            acc.PersonEmail = 'test@yuni.com';
            acc.Account_Rule_Code__c = 'Standard';
            acc.Status__c = 'Active';
            acc.Country__c = 'Thailand';
            acc.Mobile_Country__c = '66';
            acc.Agency__c = agency.id;
            acc.Subsidiary__c = subId;
            acc.CEA_Salesperson_Number__c='R123456H';
            acc.PersonBirthdate=system.today();
            acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc.VIP_Campaign__c = 'VIP Advance SC';
            acc.Approval_Status__c = 'Test';
            acc.Created_From_AdminNet__c = true;
            
            Account accReward = new Account();
            PGTestDataFactory_v2.initSetupData();
            accReward.FirstName = 'TestMe';
            accReward.LastName = 'Lasting';
            accReward.AgentNet_ID__c = 'AgentNet_ID__c test';
            accReward.Salutation = 'Mrs.';
            accReward.CurrencyIsoCode = 'THB';
            accReward.Subscription_Start_Date__c = system.today().addMonths(-10);
            accReward.BillingStreet = 'test';
            accReward.BillingCity = 'test';
            accReward.PersonMobilePhone = '479867687';
            accReward.BillingCountry = 'Thailand';
            accReward.BillingPostalCode = '83723';
            //  acc.BillingState = 'test';
            accReward.Mobile_Country__c = '66';
            accReward.Current_Subscription_Code__c = 'abc';
            accReward.PersonEmail = 'accReward@yuni.com';
            accReward.Account_Rule_Code__c = 'Business';
            accReward.Status__c = 'Active';
            accReward.Country__c = 'Thailand';
            accReward.Agency__c = agency.id;
            accReward.Reward_Points__c = 600;
            accReward.Reward_Tier__c = 'Gold';
            accReward.Subsidiary__c = subId;
            accReward.CEA_Salesperson_Number__c='A678996A';
            accReward.PersonBirthdate=system.today();
            accReward.Subscription_End_Date__c = Date.newInstance(2030, 12, 9);
            accReward.Subscription_Start_Date__c = System.today();
            accReward.Account_Rule_Code__c ='Standard';
            accReward.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            accReward.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            accReward.VIP_Campaign__c = 'VIP Advance SC';
            accReward.Approval_Status__c = 'Test';
            accReward.Created_From_AdminNet__c = true;
            listAccount.add(accReward);
            listAccount.add(acc); 
            
            Account acc2 = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc2.FirstName = 'TestMe';
            acc2.LastName = 'Lasting';
            
            acc2.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc2.Salutation = 'Mrs.';
            acc2.CurrencyIsoCode = 'THB';
            acc2.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc2.BillingStreet = 'test';
            acc2.PersonMobilePhone = '476869687';
            acc.BillingCity = 'test';
            acc.BillingCountry = 'Thailand';
            acc2.Mobile_Country__c = '66';
            acc2.BillingPostalCode = '83273';
            //acc2.BillingState = 'test';
            acc2.Current_Subscription_Code__c = 'abc';
            acc2.PersonBirthdate = system.today();
            acc2.PersonEmail = 'test@yuwni.com';
            acc2.Status__c = 'Active';
            acc2.Country__c = 'Thailand';
            acc2.Agency__c = agency.id;
            acc2.Subsidiary__c = subId;
            acc2.Account_Rule_Code__c = 'PRO';
            acc2.CEA_Salesperson_Number__c='R123456H';
            acc2.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc2.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc2.VIP_Campaign__c = 'VIP Advance SC-1';
            acc2.Approval_Status__c = '';
            acc2.Reward_Points__c = 700;
            acc2.Reward_Tier__c = 'Gold';
            listAccount.add(acc2);
            PGAccountTriggerHandler.setQualifyAgentReferral(listAccount);
            insert listAccount;
            PGAccountTriggerHandler.markAsTestAccount(listAccount,null);
            
            listAccount[0].Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            listAccount[0].Loyalty_Start_Date__c = Date.newInstance(2017, 12, 9);
            
            update listAccount;
            
            Account ac = [Select Id,PersonContactId,VIP_Campaign__c from Account where Id = : acc2.Id limit 1];
            listAccount[2].Account_Rule_Code__c = 'CORP';
            update listAccount[2];
            
            
            PGAccountTriggerHandler.accountTriggerRecursion = false;
            
            Map<Id,Account> oldMap = new Map<Id,Account>();
            PGAccountTriggerHandler.updatePGTenure(listAccount, oldMap);
            PGAccountTriggerHandler.publishRewardPoints(listAccount,null);
            acc2.Approval_Status__c = acc2.VIP_Campaign__c+'Approved';
            acc2.VIP__c = true;
            update acc2;
            acc.Status__c = 'Active';
            update acc;
            Test.stopTest();
        }
    }
    
    public testMethod static void runTest6() {
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Thailand' and isActive = true and profile.name = 'TH B2C Sales User' Limit 1];
        System.runAs (thisUser) {
            Test.startTest();
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGCampMemberTrigger';
            TE.Enable_del__c = true;
            insert TE;
            
            Rewards_Calculator__c customsetting1  = new Rewards_Calculator__c();
            customsetting1.Name='Thailand';
            customsetting1.X_factor__c=8;
            customsetting1.Y_factor__c=5;
            customsetting1.country__c='Thailand';
            insert customsetting1;
            
            Trigger_Execute__c PGAgentRewardTrigger=new Trigger_Execute__c();
            PGAgentRewardTrigger.Name='PGAgentRewardTrigger';
            PGAgentRewardTrigger.Enable_del__c=true;
            insert PGAgentRewardTrigger;
            
            id subId = PGTestDataFactory.createSubsidiary().Id;
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Thailand';
            agency.Subsidiary__c = subId;
            listAccount1.add(agency);
            
            Media__c newMedia = new Media__c();
            newMedia.Account__c = listAccount1[0].id;
            newMedia.CurrencyIsoCode = 'SGD';
            newMedia.IsActive__c = True;
            insert newMedia;
            
            Blob bodyblob = Blob.valueOf('PG Agency default');
            Contentversion cv = new contentversion(title ='PG Agency default',PathOnClient ='PG Agency default.jpg',versiondata = bodyblob,origin ='H');
            insert cv;
            
            ContentVersion conVersion = [SELECT Id, ContentSize ,PathOnClient,Title,ContentDocumentId FROM ContentVersion WHERE Id =: cv.id];
            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = conVersion.ContentDocumentId;
            cdl.LinkedEntityId = newMedia.id;
            cdl.ShareType = 'V';
            cdl.Visibility = 'AllUsers'; 
            insert cdl;
            insert listAccount1;
            
            list<Account> listAccount = new list<Account>();
            
            Account accReward = new Account();
            PGTestDataFactory_v2.initSetupData();
            accReward.FirstName = 'TestMe';
            accReward.LastName = 'Lasting';
            accReward.AgentNet_ID__c = 'AgentNet_ID__c test';
            accReward.Salutation = 'Mrs.';
            accReward.CurrencyIsoCode = 'THB';
            accReward.Subscription_Start_Date__c = system.today().addMonths(-10);
            accReward.BillingStreet = 'test';
            accReward.BillingCity = 'test';
            accReward.BillingCountry = 'Thailand';
            accReward.BillingPostalCode = '83473';
            //  acc.BillingState = 'test';
            accReward.Current_Subscription_Code__c = 'abc';
            accReward.PersonEmail = 'accReward@yuni.com';
            accReward.Account_Rule_Code__c = 'test';
            accReward.Status__c = 'Trial';
            accReward.Country__c = 'Thailand';
            accReward.Agency__c = agency.id;
            accReward.Subsidiary__c = subId;
            accReward.CEA_Salesperson_Number__c='A678996A';
            accReward.Reward_Points__c = 600;
            accReward.Reward_Tier__c = 'Gold';
            accReward.PersonBirthdate=system.today();
            accReward.Subscription_End_Date__c = Date.newInstance(2030, 12, 9);
            accReward.Mobile_Country__c = '66';
            accReward.PersonMobilePhone = '986576878';
            accReward.Subscription_Start_Date__c = System.today();
            accReward.Account_Rule_Code__c ='Pro';
            accReward.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            accReward.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            accReward.VIP_Campaign__c = 'VIP Advance SC';
            accReward.Approval_Status__c = 'Test';
            accReward.Created_From_AdminNet__c = true;
            listAccount.add(accReward);
            
            insert listAccount;
            accReward.Status__c = 'Active';
            update accReward;
            
            Account accReward1 = new Account();
            PGTestDataFactory_v2.initSetupData();
            accReward1.FirstName = 'TestMe1';
            accReward1.LastName = 'Lasting1';
            accReward1.AgentNet_ID__c = 'AgentNet_ID__c test1';
            accReward1.Salutation = 'Mrs.';
            accReward1.CurrencyIsoCode = 'THB';
            accReward1.Subscription_Start_Date__c = system.today().addMonths(-10);
            accReward1.BillingStreet = 'test';
            accReward1.BillingCity = 'test';
            accReward1.BillingCountry = 'Thailand';
            accReward1.BillingPostalCode = '83373';
            //  acc.BillingState = 'test';
            accReward1.Current_Subscription_Code__c = 'abc';
            accReward1.PersonEmail = 'accReward@yuni.com';
            accReward1.Account_Rule_Code__c = 'test';
            accReward1.Status__c = 'Trial';
            accReward1.Country__c = 'Thailand';
            accReward1.Agency__c = agency.id;
            accReward1.Subsidiary__c = subId;
            accReward1.CEA_Salesperson_Number__c='A678996A';
            accReward1.Reward_Points__c = 700;
            accReward1.Reward_Tier__c = 'Gold';
            accReward1.PersonBirthdate=system.today();
            accReward1.Subscription_End_Date__c = Date.newInstance(2030, 12, 9);
            accReward1.Subscription_Start_Date__c = System.today();
            accReward1.Account_Rule_Code__c ='Pro';
            accReward1.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            accReward1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            accReward1.VIP_Campaign__c = 'VIP Advance SC';
            accReward1.Approval_Status__c = 'Test';
            accReward1.Created_From_AdminNet__c = true;
            accReward1.Status__c = 'Active';
            listAccount.add(accReward1);
            PGAccountTriggerHandler.publishRewardPoints(listAccount,null);            
            Test.stopTest();   
        }  
    }   
}