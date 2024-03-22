@isTest
public class PGBillingEntityTriggerHandler_Test {

    @isTest
    public static void unitTest(){
       
        //Test.startTest();
        //
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(Alias = 'gtest', Email='giantest@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='GianTest', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = p.Id,
                          TimeZoneSidKey='America/Los_Angeles', UserName='giantest@testorg.com', Subsidiary__c='PropertyGuru International (Malaysia) Sdn Bhd'
                         );
        
        insert u;
        
      //  List<User> thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Malaysia' and isActive = true and profile.name = 'System Administrator' and Subsidiary__c = 'PropertyGuru International (Malaysia) Sdn Bhd' LIMIT 1];
      //  system.debug('thisuser-->'+thisuser);
        System.runAs(u){
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            insert customsetting;
            
            Trigger_Execute__c customsetting1=new Trigger_Execute__c();
            customsetting1.Name='PGBillingEntityTrigger';
            customsetting1.Enable_del__c=true;
            insert customsetting1;
            
            Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
            oppTrigger.Name='PGOpportunityTrigger';
            oppTrigger.Enable_del__c=true;
            insert oppTrigger;
            
            Trigger_Execute__c oppTrigger1 = new Trigger_Execute__c();
            oppTrigger1.Name='Trigger_OpportunitySplit';
            oppTrigger1.Enable_del__c=true;
            insert oppTrigger1;
            
            string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
            string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            //Test.startTest();
            
            Subsidiary__c sb = new Subsidiary__c();
            sb.Name = 'iProperty.com Malaysia Sdn Bhd';
            sb.NS_Subsidiary_Internal_ID__c = '1';
            sb.CurrencyIsoCode = 'MYR';
            sb.Tax_Label__c = 'taxLabel';
            sb.Country__c = 'Malaysia';
            sb.Subsidiary_Code__c = 'iPP';
            sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
            insert sb;
            
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
            Opportunity opp1 = new opportunity();
            opp1.Name = 'Oppo PgToiPP';
            opp1.StageName = 'Prospecting';
            opp1.AccountId = acc.id;
            opp1.CloseDate = system.today().AddDays(30);
            opp1.RecordTypeId = b2boppRectype;
            //opp1.Subsidiary_Type__c = '	iPP';
            opp1.Product_Category__c = 'Awards';
            opp1.Subsidiary_Type__c = 'iPP';
            opp1.Subsidiary__c = sb.Id;
            insert opp1;
            
            csmso__Sales_Order__c so = new csmso__Sales_Order__c();
            so.csmso__Advertiser__c = acc.Id;
            so.csmso__Status__c = 'Delivered';
            so.csmso__Opportunity__c = opp1.Id;
            so.Primary_Sales_Order__c = true;
            so.Advertiser_Final__c = acc.Id;
            so.Updated_From__c = 'Account Trigger';
            insert so;
            Test.stopTest();
            Billing_Entity__c be = new Billing_Entity__c();
            be.Account__c = acc.Id;
            be.Credit_Status_Auto__c = 'Active';
            be.Subsidiary__c = sb.id;
            insert be;
            
            be.Credit_Status_Auto__c = 'Suspension';
            update be;
            
            
        }
    }
}