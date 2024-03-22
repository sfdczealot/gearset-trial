@isTest
public class OppChatterSuspendedStatus_Test {

    @isTest
    public static void unitTest(){
        
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
        
        list<String> OppIds = new list<String>();
        OppIds.add(opp.Id);
        
        OppChatterSuspendedStatus.sendChatter(OppIds);
        
        Test.stopTest();
    }
}