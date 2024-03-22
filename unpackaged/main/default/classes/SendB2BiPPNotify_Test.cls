@isTest
public class SendB2BiPPNotify_Test {

    @isTest
    public static void unitTest1(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=true;
        insert oppTrigger;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
               
        
        Subsidiary__c sb1 = new Subsidiary__c();
        sb1.Name = 'PropertyGuru Pte Ltd';
        sb1.NS_Subsidiary_Internal_ID__c = '2';
        sb1.CurrencyIsoCode = 'MYR';
        sb1.Tax_Label__c = 'taxLabel';
        sb1.Country__c = 'Malaysia';
        sb1.Subsidiary_Code__c = 'iPP';
      //  insert sb1;
        
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        
        Test.startTest();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        //  opp.Subsidiary__c = sb1.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = b2boppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c   = 'Contract - Renewal';
        opp.Opportunity_Type__c='B2C - Renewal';
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        list<String> oppIds = new list<String>();
        oppIds.add(opp.Id);
        
        SendB2BiPPNotify.callWorkato(oppIds);
        
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest2(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
      //  string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
               
        
        Subsidiary__c sb1 = new Subsidiary__c();
        sb1.Name = 'PropertyGuru Pte Ltd';
        sb1.NS_Subsidiary_Internal_ID__c = '2';
        sb1.CurrencyIsoCode = 'MYR';
        sb1.Tax_Label__c = 'taxLabel';
        sb1.Country__c = 'Malaysia';
        sb1.Subsidiary_Code__c = 'iPP';
      //  insert sb1;
        
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        
        list<String> accIds = new list<String>();
        accIds.add(acc.Id);
        
        SendB2BiPPNotify.callWorkato(accIds);
        
    }
}