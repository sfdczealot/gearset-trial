@isTest
public class BatchToUpdateAccountLSD_Test {
    @isTest
    public static void updateLSD(){
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGLSDUpdateTrigger';
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
            
            PGTestDataFactory_v2.initSetupData();    
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
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
            a.BillingPostalCode = '83735';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = '123';
            a.PersonEmail = 'test@test.com';
            a.Country__c = 'Singapore';
            a.Status__c = 'Active';
            a.Next_Subscription_Activation_Date__c=System.todAY()-9;
            a.CEA_Salesperson_Number__c = 'S215463K';
            a.PersonBirthdate = system.today();
            a.Agency__c = agency.id;
            a.Subsidiary__c = subId;
            a.Loyalty_Start_Date__c = Date.newInstance(2017, 12, 9);
            insert a;
            
            LSD_Update__c lsd = new LSD_Update__c();
            lsd.Approval_Status__c ='Approved';
            lsd.Account__c =a.id;
            lsd.Loyalty_Start_Date__c = system.today();
            lsd.LastModifiedById = '0057F000005TAluQAG';
            insert lsd;
            
            Test.startTest();
            
            BatchToUpdateAccountLSD obj = new BatchToUpdateAccountLSD();
            DataBase.executeBatch(obj);
            
            Test.stopTest();
        }
    }
}