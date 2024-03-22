@istest
public class CREScheduleRun_test {
    
    @isTest static void method1(){
        Trigger_Execute__c TECampElig = new Trigger_Execute__c();
        TECampElig.Name = 'PGCampaignEligibilityTrigger';
        TECampElig.Enable_del__c = true;
        insert TECampElig;
        Campaign camp=null;
        Campaign_Eligibility__c campEligibility=null;
        camp= PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        campEligibility=PGTestDataFactory_v2.CreateCampaignEligibility(camp.id);
        campEligibility.Run_Frequency__c='Hourly';
        insert campEligibility;
        
        Test.startTest();
        CREScheduleRun sh1 = new CREScheduleRun();
        String sch = '0 0 2 * * ?'; 
        system.schedule('test CRE', sch, sh1); 
        Test.stopTest();
    }
    
    @isTest static void method2(){
        Trigger_Execute__c TECampElig = new Trigger_Execute__c();
        TECampElig.Name = 'PGCampaignEligibilityTrigger';
        TECampElig.Enable_del__c = true;
        insert TECampElig;
        Campaign camp=null;
        Campaign_Eligibility__c campEligibility=null;
        camp= PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        campEligibility=PGTestDataFactory_v2.CreateCampaignEligibility(camp.id);
        campEligibility.Run_Frequency__c='Hourly';
        campEligibility.Criteria_Type__c = 'Custom Metadata';
        insert campEligibility;
        
        Test.startTest();
        CREScheduleRun sh1 = new CREScheduleRun();
        String sch = '0 0 2 * * ?'; 
        system.schedule('test CRE', sch, sh1); 
        Test.stopTest();
    }
    @isTest static void method3(){
        Trigger_Execute__c TECampElig = new Trigger_Execute__c();
        TECampElig.Name = 'PGCampaignEligibilityTrigger';
        TECampElig.Enable_del__c = true;
        insert TECampElig;
        Campaign camp=null;
        Campaign_Eligibility__c campEligibility=null;
        camp= PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        campEligibility=PGTestDataFactory_v2.CreateCampaignEligibility(camp.id);
        campEligibility.Run_Frequency__c='Hourly';
        insert campEligibility;
        
        Test.startTest();
        CREScheduleRun sh1 = new CREScheduleRun();
        String sch = '0 0 2 * * ?'; 
        system.schedule('test CRE', sch, sh1); 
        Test.stopTest();
    }
    
}