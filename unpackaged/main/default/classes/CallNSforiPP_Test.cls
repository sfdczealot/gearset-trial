@isTest
public class CallNSforiPP_Test {

    @isTest
    public static void unitTest(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        user u = [select id,Subsidiary__c from user where id = :userinfo.getuserID()];
       // u.Subsidiary__c=''
     Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'iProperty.com Malaysia Sdn Bhd';
        sb.NS_Subsidiary_Internal_ID__c = '11';
        sb.Subsidiary_Code__c  ='iPP';
        sb.CurrencyIsoCode = 'MYR';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Malaysia';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
        Subsidiary__c sb1 = PGTestDataFactory_v2.createMYSubsidiary(u);
       
        //sb.Subsidiary_Code__c = 'ipp';
      
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
         opp.Subsidiary__c = sb.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = b2boppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        //opp.Order_Type_Clone__c   = 'Contract - Renewal';
       // opp.Opportunity_Type__c='B2C - Renewal';
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = 'Bill by item';
        insert so;
        
        CSPOFA__Orchestration_Process_Template__c ProTemp = new CSPOFA__Orchestration_Process_Template__c();
        ProTemp.Name = 'temp';
        insert ProTemp;
        
        CSPOFA__Orchestration_Process__c process = new CSPOFA__Orchestration_Process__c();
        process.Name = 'process';
        process.CSPOFA__Orchestration_Process_Template__c = ProTemp.Id;
        process.Sales_Order__c = so.id;
        insert process;
        
        CSPOFA__Orchestration_Step__c step = new CSPOFA__Orchestration_Step__c();
        step.Name = 'step';
        //step.Sales_Order__c = so.id;
        step.CSPOFA__Orchestration_Process__c = process.Id;
        insert step;
         List<CSPOFA__Orchestration_Step__c> steps = [
            SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
            Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
            FROM CSPOFA__Orchestration_Step__c where id= :step.id
        ];
        list<CSPOFA__Orchestration_Step__c> steplist = new list<CSPOFA__Orchestration_Step__c>();
        //steplist.add(steps);
        
        CallNSforiPP call = new CallNSforiPP();
        call.performCallouts(steps);
        call.process(steplist);
        
        Test.stopTest();
    }
}