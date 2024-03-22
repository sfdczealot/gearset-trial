@IsTest
public class customLookupController_Test {
    @IsTest
    public static void method1(){
         Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='syncorg@m.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',country ='Singapore', 
            LocaleSidKey='en_US', ProfileId = p.Id, Subsidiary__c ='PropertyGuru Pte Ltd',
            TimeZoneSidKey='America/Los_Angeles', UserName='syncorg@m.com');
      insert u;
        System.runAs(u){
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
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.salutation = 'Mr.';
        a.firstname = 'aaaa';
        a.LastName = 'App';
        a.Agency__c = agency.Id;
        //a.Customer_Type__c = 'Agency';
        a.CurrencyIsoCode = 'SGD';
        a.AgentNet_ID__c = 'TestPurposeIdXX';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
       // a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.account_rule_code__c = 'Standard';
        a.personemail = 'asd131sfaa@yaho.com';
        a.Country__c = 'Singapore';
        a.Status__c = 'Active';
        a.CEA_Salesperson_Number__c = 'W567653H';
        a.PersonBirthdate = Date.newInstance(1996, 12, 21);
        insert a;
        
        Test.startTest();
        customLookupController.search('App','Account','Country__c = \'Malaysia\'','objPage');
        customLookupController.search('','Account','','objPage');
        customLookupController.search('','Account','Country__c = \'Malaysia\'','objPage');
        //customLookupController.search('App','Account','','objPage');  
        Test.stopTest();
    }
}
}