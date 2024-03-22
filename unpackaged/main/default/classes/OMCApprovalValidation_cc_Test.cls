/*
* Created by : Yuni
* Company    : Viseo Asia PTE LTD
* created Date : 21/09/2018
*/
@isTest
public class OMCApprovalValidation_cc_Test {
    static testMethod void runTest() {
        Test.startTest();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        PGTestDataFactory_v2.initSetupData();
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.Status__c = 'Active';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
      //  a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonBirthdate = system.today();
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = 'CEACHECK1';
        insert a;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.From_Button__c = true;
        opp.Payment_Time__c = system.now();
        //opp.Agent_Accepted_Time__c = system.now();
        opp.Last_Outbound_Sync__c = system.now();
        opp.approval_Status__c = 'OMC Approval Submitted';
        opp.Payment_Amount__c = 100;
        opp.Payment_Type__c = 'online';
        opp.payment_reference__c = '123s';
        opp.Outbound_Sync_Error__c = 'test';
        opp.Guruland_Quote_Link__c = '';
        opp.Payment_Type__c = 'Offline';
        opp.RecordTypeId = oppRectype;
/*      opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.Agent_Accepted_Time__c = system.now();
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = false;
        
*/
        insert opp;

        opp.RecordTypeId = oppRectype;
        update opp;
        
        /*OpportunityLineItem oppLine = new OpportunityLineItem();
        oppLine.OpportunityId = opp.id;
        oppLine.Product2Id = prod.id;
        oppLine.Quantity = 2;
        oppLine.Start_Date__c = system.today();
        oppLine.End_Date__c = system.today();
        oppLine.UnitPrice = 100;
        //oppLine.Amount__c = 200;
        oppLine.GST_VAT_Rate__c = 1;
        insert oppLine;
        */
   //     OMCApprovalValidation_cc.sendApporval(opp.id);
        
        update opp;
        try{
              OMCApprovalValidation_cc.sendApporval(opp.id);
        Test.stopTest();
        }
        catch(Exception e )
        {
            
        }
      
    }
    static testMethod void runTest1() {
        Test.startTest();
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account a = new Account();
        PGTestDataFactory_v2.initSetupData();
        a.Status__c = 'Active';
        a.RecordTypeId = accRectype;
        a.LastName = 'TestYuni';
        a.salutation = 'Mr.';
        a.FirstName = 'abc';
        a.CurrencyIsoCode = 'SGD';
        a.Subscription_Start_Date__c = system.today().addMonths(-10);
        a.BillingStreet = 'test';
        a.BillingCity = 'test';
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
      //  a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.PersonBirthdate = system.today();
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = 'CEACHECK1';
        insert a;
        
        string oppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.From_Button__c = true;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Last_Outbound_Sync__c = system.now();
        opp.Payment_Amount__c = 100;
        opp.Payment_Type__c = 'online';
        opp.payment_reference__c = '123s';
        opp.Outbound_Sync_Error__c = 'test';
        opp.Guruland_Quote_Link__c = '';
        opp.RecordTypeId = oppRectype;
/*      opp.Name = 'Test Opp';
        opp.StageName = 'Closed Won';
        opp.Agent_Accepted_Time__c = system.now();
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Months_Included__c = false;
        opp.Payment_Type__c = 'Offline';
*/
        insert opp;

        opp.RecordTypeId = oppRectype;
        update opp;
        
        /*OpportunityLineItem oppLine = new OpportunityLineItem();
        oppLine.OpportunityId = opp.id;
        oppLine.Product2Id = prod.id;
        oppLine.Quantity = 2;
        oppLine.Start_Date__c = system.today();
        oppLine.End_Date__c = system.today();
        oppLine.UnitPrice = 100;
        //oppLine.Amount__c = 200;
        oppLine.GST_VAT_Rate__c = 1;
        insert oppLine;
        */
        OMCApprovalValidation_cc.sendApporval(opp.id);
        
        update opp;
        OMCApprovalValidation_cc.sendApporval(opp.id);
        Test.stopTest();
    }
    
}