@isTest
public class PreprocessorRuleEngine_Test {
    
    static{
        Object_Name__c obj = new Object_Name__c();
        obj.Name = 'Campaign Eligibility';
        obj.Enabled__c = true;
        insert obj;
        
        Trigger_Execute__c TECampEligibility = new Trigger_Execute__c();
        TECampEligibility.Name = 'PGCampaignEligibilityTrigger';
        TECampEligibility.Enable_del__c = true;
        insert TECampEligibility;

        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('VIP Promotion').getRecordTypeId();
        insert cma;
        
        Rule_Engine__c re = new Rule_Engine__c();
        re.Batch_Size__c = 200;
        re.Campaign_Ids__c = cma.Id;
        re.Name = 'Campaign Ids';
        insert re;
            
        list<Campaign_Eligibility__c> listCE = new list<Campaign_Eligibility__c>();
      	Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(status__c='Active',Next_run_scheduled__c=system.now(),Name='test1',Rule_Name_Extension__c='Select Id From Contact where Account.RecordType.developerName = \'Agency\'',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c = cma.Id );     
        listCE.add(ce1);
        /*Campaign_Eligibility__c ce2 = new Campaign_Eligibility__c(Name='test2',Rule_Name_Extension__c='DynamicMethodCall;multiplyNumbers',Criteria_Type__c = 'Apex Method',Priority__c=2,Campaign__c = cma.Id);     
        listCE.add(ce2);*/
        insert listCE;
    }
    
   
    @isTest static void method1(){
        PreprocessorRuleEngine.startPreProcessing('Campaign Eligibility','VIP Promotion',new list<string>());
        PreprocessorRuleEngine.increaseCoverage();
        Campaign c=[select id from campaign limit 1];
        PreprocessorRuleEngine.runCRE(c.id);
    }
}