@isTest
public class BatchUpdateBillAddOnOpp_Test {
    public static testmethod void unitTest(){
        
        CountryCode__c cc = new CountryCode__c();
        cc.Name = 'singapore';
        cc.code__c = 'sg';
        insert cc;
        
        list<Opportunity> listOpp = new list<Opportunity>();
        
        User runUser = [Select id, Sales_Head__c, Webuser_ID__c,Subsidiary__c From User where id =: UserInfo.getUserId()];        
        Subsidiary__c sb1 = PGTestDataFactory.createSubsidiary();
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        PGTestDataFactory_v2.initSetupData();
        Account a = new Account();
        a.RecordTypeId = accRectype;
        a.FirstName = 'IsYuni';
        a.LastName = 'TestYuni';
        a.AgentNet_ID__c = 'AgentNet_ID__c test';
        a.Salutation = 'Mrs.';
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
        a.Status__c = 'Active';
        a.Country__c = 'Singapore';
        a.Subsidiary__c = sb1.id;
        a.CEA_Salesperson_Number__c = 'CEACHECK1';
        a.PersonBirthdate = system.today();
    	insert a;
    
        Tax_Code__c taxcode = new Tax_Code__c();
        taxcode.Name = 'SG - 7% GST';
        taxcode.Tax_Rate__c =  7;
        taxcode.Country__c = 'Singapore';
        insert taxcode;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(-30);
        opp.Subsidiary__c = sb1.id;
        opp.PG_Tenure__c = 4;
        opp.Order_Type_Clone__c = 'Contract - Renewal';
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = false;
        opp.Is_Current_Subscription__c = true;
        opp.RecordTypeId =oppRectype;
        opp.Include_Subscription_Ext__c = false;
        opp.OwnerId = runUser.Id;
        listOpp.add(opp);
        insert listOpp;
        Test.startTest();
        BatchUpdateBillAddOnOpp objBatch=new BatchUpdateBillAddOnOpp();
        Database.executeBatch(objBatch);
        objBatch.execute(null, listOpp);
        Test.stopTest();

    }
}