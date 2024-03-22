@isTest
public class Test_AgentRewardCalculatorController {
    
    private static testmethod void prePopulateFieldsTest() {
         User thisuser = [SELECT Id,Subsidiary__c FROM User WHERE country = 'Singapore' and isActive = true and profile.name = 'System Administrator' LIMIT 1];
        System.runAs(thisuser){
        //Insert custom setting
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGAccountTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        //Insert custom setting
        Rewards_Calculator__c RC = new Rewards_Calculator__c();
        RC.Name = 'Singapore';
        RC.Country__c = 'Singapore';
        RC.X_factor__c = 8;
        RC.Y_factor__c = 5;
        insert RC;
        
        Trigger_Execute__c customsetting1=new Trigger_Execute__c();
        customsetting1.Name='PGAgentRewardTrigger';
        customsetting1.Enable_del__c=true;
        insert customsetting1;
        
        // Insert account
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Agent').getRecordTypeId();
        Account acc = new Account();
        acc.Salutation = 'Mr.';
        acc.FirstName = 'Test';
        acc.LastName = 'Acc';
        acc.CurrencyIsoCode = 'SGD';
        acc.Subscription_Start_Date__c = system.today().addMonths(-10);
        acc.Subscription_End_Date__c = system.today().addMonths(+1);
        acc.BillingStreet = 'test';
        acc.BillingCity = 'test';
        acc.billingcountryCode='SG';
        acc.BillingPostalCode = '83737';
        acc.Account_Rule_Code__c = 'Standard';
        acc.PersonEmail = 'test@agentRewardCalculator.com';
        acc.CEA_Salesperson_Number__c = 'G856381G';
        acc.Mobile_Country__c = '65';
        acc.PersonBirthdate = system.today();
        acc.Status__c = 'Active';
        acc.Country__c = 'Singapore';
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        String json = '{"totalSpending":4526,"subsSpending":4637,"rewardTier":"Elite","rewardPoints":113,"discSpending":-111,"accId":"'+acc.Id+'"}';
        String json1 = '{"totalSpending":null,"subsSpending":null,"rewardTier":"","rewardPoints":"","discSpending":null,"accId":"'+acc.Id+'"}';
        
        Test.startTest();
        AgentRewardCalculatorController.prePopulateFields(acc.Id);
        AgentRewardCalculatorController.prePopulateFields('8499839383');
        AgentRewardCalculatorController.calculateTotalSpending(acc.Id,acc.Country__c,date.today(),date.today(),8,5,67,98,'SGD');
        AgentRewardCalculatorController.runRewardCalculation('test');
        AgentRewardCalculatorController.runRewardCalculation(json);
        AgentRewardCalculatorController.runRewardCalculation(json1);
       
        Test.stopTest(); 
        }    
    }
}