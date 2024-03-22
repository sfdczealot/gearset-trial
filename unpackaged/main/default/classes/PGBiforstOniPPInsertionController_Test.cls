@istest
public class PGBiforstOniPPInsertionController_Test {
  @isTest
    public static void testmethod1(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c PGTrigger =new Trigger_Execute__c();
            PGTrigger.Name='PGAccountTrigger';
            PGTrigger.Enable_del__c=true;
            insert PGTrigger;
            /* Trigger_Execute__c PGTriggerOpp =new Trigger_Execute__c();
PGTriggerOpp.Name='PGOpportunityTrigger';
PGTriggerOpp.Enable_del__c=true;
insert PGTriggerOpp;*/
            
            Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
            PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
            PGTriggerOppSplit.Enable_del__c=true;
            insert PGTriggerOppSplit;
            
            Trigger_Execute__c PGBiforstOniPPInsertion =new Trigger_Execute__c();
            PGBiforstOniPPInsertion.Name='PGBiforstOniPPInsertion';
            PGBiforstOniPPInsertion.Enable_del__c=true;
            insert PGBiforstOniPPInsertion;
            
            Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
            User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                              EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                              LocaleSidKey='en_US', ProfileId = p.Id,
                              TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru Pte Ltd'
                             );
            
            insert u;
            //id subId = PGTestDataFactory.createSubsidiary().Id;
            subsidiary__c sb = new Subsidiary__c();
            sb.Name = thisuser.Subsidiary__c;
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'SGD';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Singapore';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
            
            list<Account> listAccount1 = new list<Account>();
            Account agency = new Account();
            PGTestDataFactory_v2.initSetupData();
            agency.name = 'Unit Test Agency';
            agency.Agency_Id__c = '40574';
            agency.CEA_License__c = 'CEAUNittest1';
            agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
            agency.Country__c = 'Singapore';
            agency.Subsidiary__c = sb.id;
            listAccount1.add(agency);
            
            Tax_Code__c taxcode = new Tax_Code__c();
            taxcode.Name = 'SG - 7% GST';
            taxcode.Tax_Rate__c =  7;
            taxcode.Country__c = 'Singapore';
            insert taxcode;
            
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
            
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
            Account a = new Account();
            a.RecordTypeId = accRectype;
            a.LastName = 'TestYuni';
            a.salutation = 'Mr.';
            a.FirstName = 'abc';
            a.CurrencyIsoCode = 'SGD';
            a.Subscription_Start_Date__c = system.today().addMonths(-10);
            a.BillingStreet = 'test';
            a.BillingCity = 'test';
            a.BillingCountry = 'Singapore';
            a.BillingPostalCode = '83735';
            //a.BillingState = 'test';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = '123';
            a.PersonEmail = '12121assas@yahoo.com';
            a.Country__c = 'Singapore';
            a.Status__c = 'Active';
            a.CEA_Salesperson_Number__c = 'E458652L';
            a.PersonBirthdate = system.today();
            a.Subsidiary__c = sb.id;
            a.Agency__c = agency.id;
            a.External_Field__c = 'Check';
            a.Test_Account__c = False;
            a.NetSuite_Id__c = null;
            insert a;
           Test.startTest();
             Biforst_Sync__e biforstSync = new Biforst_Sync__e();
                    biforstSync.AccountId__c = a.id;
                    Eventbus.publish(biforstSync);
            Test.stopTest();
        }
    }
  
}