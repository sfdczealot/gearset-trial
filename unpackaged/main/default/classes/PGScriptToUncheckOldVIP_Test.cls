@isTest
public class PGScriptToUncheckOldVIP_Test {
    
    @isTest
    static void removeVIPFlag(){
        
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        runningUser.Subsidiary__c = 'PropertyGuru Pte Ltd';
        update runningUser;
        PGTestDataFactory_v2.initSetupData();
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'PropertyGuru Pte Ltd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'SGD';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Singapore';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        PGTestDataFactory_v2.initSetupData();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'TestName';
        a.LastName = 'LastName';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
      //  a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonEmail = 'test@yuni.com';
        a.Account_Rule_Code__c = 'test';
        a.Previous_Account_Rule__c = 'test';
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subscription_End_Date__c = system.today().addMonths(-9);
        a.Loyalty_Start_Date__c = system.today().addMonths(-1);
        a.Is_Qualify_Agent_Referral_Program__c = true;
        a.CEA_Salesperson_Number__c = 'CEACHECK';
        a.PersonBirthdate=system.today();
        A.VIP_Campaign__c = 'TetsName';
        a.VIP__c = true;
        a.VIP_End_Date__c = System.today().addDays(-1);
        insert a;
        
        Test.startTest();
        system.schedule('TestingBatchClassToRemoveVIPFlag2', '0 0 22 * * ? *', new PGScriptToUncheckOldVIP());
        Test.stopTest();
        
        
	}
}