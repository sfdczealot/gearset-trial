@isTest
public class CustomRetriggerSMSNotification_ccTest {
	@isTest
    public static void testmethod1(){
        
         Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
          id subId = PGTestDataFactory.createSubsidiary().Id;
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
        a.Subsidiary__c = subId;
        a.BillingCountry = 'Singapore';
        a.BillingPostalCode = '8373';
        //a.BillingState = 'test';
        a.Current_Subscription_Code__c = 'abc';
        a.Account_Rule_Code__c = 'test';
        a.AgentNet_ID__c = '123';
        a.PersonEmail = '12121assas@yahoo.com';
        a.Status__c = 'Expired';
        a.Country__c = 'Singapore';
        a.CEA_Salesperson_Number__c = 'A212312B';
        a.PersonBirthdate= System.today();
        insert a; 
        Opportunity opp = new opportunity();
        opp.RecordTypeId = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C');
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.From_Button__c = true;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Last_Outbound_Sync__c = system.now();
        opp.Outbound_Sync_Error__c = 'test';
        opp.Guruland_Quote_Link__c = '';
        opp.Subsidiary__c = subId;
        opp.Allowed_Payment_Type__c = 'All';
        opp.Count_of_Referral_Agent_Promotion__c = 1;
        opp.CurrencyIsoCode = 'SGD';
        opp.Opportunity_Type__c='B2C - Renewal';
        insert opp;
        CustomRetriggerSMSNotification_cc.sendSMSToAgent(opp.id,false);
    }
}