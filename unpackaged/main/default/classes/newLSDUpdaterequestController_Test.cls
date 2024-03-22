@istest
public class newLSDUpdaterequestController_Test {
     public testMethod static void runTest() {
         User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){    
		Test.startTest();
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
         
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGLSDUpdateTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1; 
         
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
        acc.Current_Subscription_Code__c = 'abc';
        acc.PersonEmail = 'test@yuni.com';
        acc.Account_Rule_Code__c = 'test';
        acc.Status__c = 'Active';
        acc.Mobile_Country__c = '65';
        acc.Country__c = 'Singapore';
        acc.Agency__c = agency.id;
        acc.Subsidiary__c = subId;
        acc.CEA_Salesperson_Number__c='F435246U';
        acc.PersonBirthdate=system.today();
        acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
        acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        acc.VIP_Campaign__c = 'VIP Advance SC';
        acc.Approval_Status__c = 'Test';
      
        insert acc;
         
         LSD_Update__c lsd = new LSD_Update__c(Approval_Status__c ='Submit for approval',account__C = acc.id,Loyalty_Start_Date__c= system.today());
         insert lsd;
        
        newLSDUpdaterequestController.validateApprovalCap(acc.id);      
        Test.stopTest();
        }
    }
}