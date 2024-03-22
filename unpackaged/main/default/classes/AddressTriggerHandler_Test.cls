@isTest
public class AddressTriggerHandler_Test {
    public static testMethod void unitTest(){
        Test.startTest();
        User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
            Trigger_Execute__c customsetting=new Trigger_Execute__c();
            customsetting.Name='PGAccountTrigger';
            customsetting.Enable_del__c=true;
            customsetting.IsTrackingEnable__c= true;
            customsetting.Sub_Enable__c = true;
            insert customsetting;
            
            
            Trigger_Execute__c TE = new Trigger_Execute__c();
            TE.Name = 'PGAddressTrigger';
            TE.Enable_del__c = true;
            TE.IsTrackingEnable__c = true;
            TE.Sub_Enable__c = true;
            insert TE;
            
            Trigger_Execute__c Tr = new Trigger_Execute__c();
            Tr.Name = 'Trigger_OpportunitySplit';
            Tr.Enable_del__c = true;
            Tr.IsTrackingEnable__c = true;
            Tr.Sub_Enable__c = true;
            insert Tr;
            
           // id subId = PGTestDataFactory.createSubsidiary().Id;
      
            Account acc = new Account();
            PGTestDataFactory_v2.initSetupData();
            acc.Name = 'TestMe';
            acc.AgentNet_ID__c = 'AgentNet_ID__c test';
            acc.CurrencyIsoCode = 'SGD';
            acc.Subscription_Start_Date__c = system.today().addMonths(-10);
            acc.BillingStreet = 'test';
            acc.BillingCity = 'test';
            acc.Reward_Points__c = 700;
            acc.Reward_Tier__c = 'Gold';
            acc.BillingCountry = 'Singapore';
            acc.BillingPostalCode = '83735';
            acc.Current_Subscription_Code__c = 'abc';
            acc.Account_Rule_Code__c = 'test';
            acc.Status__c = 'Active';
            acc.Country__c = 'Singapore';
            //acc.Subsidiary__c = subId;
            acc.CEA_Salesperson_Number__c='R123456H';
            acc.Subscription_End_Date__c = Date.newInstance(2019, 12, 9);
            acc.Loyalty_Start_Date__c = Date.newInstance(2018, 12, 9);
            acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
            acc.VIP_Campaign__c = 'VIP Advance SC';
            acc.Approval_Status__c = 'Test';
            acc.Mobile_Country__c='65';
            acc.Created_From_AdminNet__c = true;
            
            acc.Phone = '12345';
            
            insert acc;
        
        
            Address__c Addr = new Address__c();
            Addr.Name ='Test Address';
            Addr.Account__c = acc.Id;
            Addr.isActive__c = true;
            Addr.Billing_City__c = 'test';
            Addr.BillingCountry__c ='Singapore';
            Addr.Billing_Postal_Code__c ='83736';
            Addr.Billing_State__c = 'state';
            Addr.Billing_Street__c ='street';
            Addr.CurrencyIsoCode ='SGD';   
            insert Addr;
        
            Opportunity opp = new Opportunity();
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            opp.Name = 'Test Opp';
            opp.StageName = 'Prospecting';
            opp.AccountId = acc.id;
            opp.Product_Category__c = 'Awards';
            opp.CloseDate = system.today().AddDays(30);
            opp.Billing_Address__c = Addr.Id;
            insert opp;
        
        
            Addr.isActive__c = false;
            try{
            update Addr;
            }catch(exception e){
                System.debug(e);
            }
            Test.stopTest();
        }
        
    }

}