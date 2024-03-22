@isTest
public class UpdateFulfilment_SO_Test {
    
    @isTest
    public static void unitTest(){
        CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = true;
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        thisuser.Subsidiary__c = 'PropertyGuru International (Malaysia) Sdn Bhd'; //'PropertyGuru Pte Ltd'
        update thisuser;
        System.runAs(thisuser){
             Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'iProperty.com Malaysia Sdn Bhd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'MYR';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Malaysia';
        sb.Subsidiary_Code__c = 'iPP';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
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
            
            Trigger_Execute__c customsetting1=new Trigger_Execute__c();
            customsetting1.Name='PGBillingEntityTrigger';
            customsetting1.Enable_del__c=true;
            insert customsetting1;
            
            string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
            string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            
           // User runningUser = [Select id, Subsidiary__c,CurrencyIsoCode From user where id =: UserInfo.getUserId() LIMIT 1];
            
            
           /* Subsidiary__c sb1 = new Subsidiary__c();
            sb1.Name = 'PropertyGuru Pte Ltd';
            sb1.NS_Subsidiary_Internal_ID__c = '2';
            sb1.CurrencyIsoCode = 'MYR';
            sb1.Tax_Label__c = 'taxLabel';
            sb1.Country__c = 'Malaysia';
            sb1.Subsidiary_Code__c = 'iPP';
            insert sb1;*/
             Subsidiary__c sb1 = new Subsidiary__c();
        sb1.Name = 'PropertyGuru International (Malaysia) Sdn Bhd';
        sb1.NS_Subsidiary_Internal_ID__c = '2';
        sb1.CurrencyIsoCode = 'MYR';
        sb1.Tax_Label__c = 'taxLabel';
        sb1.Country__c = 'Malaysia';
        sb1.Subsidiary_Code__c = 'iPP';
        sb1.Logo_url__c='https://google.com';
        insert sb1;
        
            
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
            
            csmso__Sales_Order__c so = new csmso__Sales_Order__c();
            so.csmso__Advertiser__c = acc.Id;
            so.csmso__Status__c = 'Delivered';
            so.csmso__Opportunity__c = opp.Id;
            so.Primary_Sales_Order__c = true;
            so.Advertiser_Final__c = acc.Id;
            so.Billing_schedule__c = 'Bill by item';
            insert so;
            
            Billing_Entity__c be = new Billing_Entity__c();
            be.Account__c = acc.Id;
            be.Credit_Status_Auto__c = 'Active';
            be.Subsidiary__c = sb1.Id;
            insert be;
            
            list<id> SOid = new list<id>();
            SOid.add(so.id);
            
            UpdateFulfilment_SO.updateFulfilmentAllowed(SOid);
            
            Test.stopTest();
        }
    }
}