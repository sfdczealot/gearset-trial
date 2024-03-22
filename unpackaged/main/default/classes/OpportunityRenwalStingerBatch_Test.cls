@isTest
public class OpportunityRenwalStingerBatch_Test {
    
    @testSetup static void setup() {
        Payment_Term__c objPT=new Payment_Term__c();
        objPT.Name='Immediate';
        objPT.NS_Payment_Term_ID__c=123;
        insert objPT;
        
        // Avoid mixed DML
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            //data setup
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGOpportunityTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c customsetting1=new Trigger_Execute__c();
            customsetting1.Name='Trigger_OpportunitySplit';
            customsetting1.Enable_del__c=true;
            insert customsetting1;

            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            
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
            acc.BillingCity = 'test';
            acc.Reward_Points__c = 700;
            acc.Reward_Tier__c = 'Gold';
            acc.BillingCountry = 'Singapore';
            acc.BillingPostalCode = '8373';
            acc.Current_Subscription_Code__c = 'abc';
            acc.PersonEmail = 'test@yuni.com';
            acc.Account_Rule_Code__c = 'STANDARD';
            acc.Status__c = 'Active';
            acc.Country__c = 'Singapore';
            acc.Agency__c = agency.id;
            acc.Subsidiary__c = subId;
            acc.CEA_Salesperson_Number__c='R123456H';
            acc.PersonBirthdate=system.today();
            acc.Subscription_End_Date__c = system.today().addMonths(1);
            acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
            acc.VIP_Campaign__c = 'VIP Advance SC';
            acc.Approval_Status__c = 'Test';
            acc.Created_From_AdminNet__c = true;
            acc.Next_Subscription_Activation_Date__c  = system.today().addDays(-10);
            acc.VIP__c = true;
            acc.Commando_Sales_Rep__c = thisuser.id;
            acc.Renewal_Opportunity_User__c = thisuser.id;
            listAccount.add(acc);
            insert listAccount;
            
            Id recordTypeId =Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2C').getRecordTypeId();
            
            Opportunity opp = new opportunity();
            opp.Name = 'Test Opp';
            opp.StageName = 'Proposal';
            opp.AccountId = listAccount[0].id;
            opp.Payment_Term__c =objPT.id;
            opp.IsClone__c = 'abc';
            opp.CloseDate = system.today().AddDays(30);
            opp.Subsidiary__c = subId;
            opp.Total_Spending__c = 100;
            opp.RecordTypeId = recordTypeId;
            opp.Opportunity_Type__c = 'B2C - Upgrade' ;
            opp.PG_Tenure__c = 1;
            opp.count_of_subscription_item_new__c = 100.0;
            opp.Order_Type_Clone__c = 'Contract - Renewal';
            
            Search_and_tag_admin__c sd1 = new Search_and_tag_admin__c(Destination_Object_API__c ='Opportunity',Client__c='test',ClientID__c='test',
                                                                      Source_Object_API__c ='Opportunity',UserName__c='test',password__c='test',Search_Field__c='Name,Id,Country__c',
                                                                      EndPoint__c='test.com',Source_RecordTypeID__c =opp.RecordTypeId,
                                                                      Destination_Recordtype_Id__c =opp.RecordTypeId,active__c=true);
            insert sd1;
            insert opp;
        }
    }
    
    
    static testMethod void runTest() {
        Test.StartTest();
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;
        String sch = '0 0 0 * * ? *';    
        OpportunityRenewalStinger_Schedule orbs = new OpportunityRenewalStinger_Schedule();      
        sch = '0 0 0 * * ? *';
        system.schedule('Test Schedule Renewal', sch, orbs);
        Test.stopTest();
    }   
}