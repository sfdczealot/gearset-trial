@isTest
public class CREScheduleRunAtSix_test {
    
    
    static testMethod void mainTest(){
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Campaign camp=null;
        Campaign camp1=null;
        Campaign camp2=null;
        Campaign_Eligibility__c campEligibility=null;
        Campaign_Eligibility__c campEligibility1=null;
        Campaign_Eligibility__c campEligibility2=null;
        camp= PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        campEligibility=PGTestDataFactory_v2.CreateCampaignEligibility(camp.id);
        campEligibility.Run_Frequency__c='Weekly';
        insert campEligibility;
        camp1= PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(2));
        camp2= PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(3));
        campEligibility1=PGTestDataFactory_v2.CreateCampaignEligibility(camp1.id);
        campEligibility1.Run_Frequency__c='Daily';
        insert campEligibility1;
        campEligibility2=PGTestDataFactory_v2.CreateCampaignEligibility(camp2.id);
        campEligibility2.Run_Frequency__c='Monthly';
        insert campEligibility2;
        
        Test.startTest();
        CREScheduleRunAtSix sh1 = new CREScheduleRunAtSix();
        String sch = '0 0 2 * * ?'; 
        system.schedule('Test CRE', sch, sh1); 
        Test.stopTest();
    }
    
}