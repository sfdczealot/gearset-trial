@isTest
public class DailyBatchToActivateCampaign_Test {
    @isTest
    public static void DailyBatchToActivateCampaign_Test_Method_1(){
        String sched = '0 00 10 * * ?';
        Campaign cmp = new Campaign();
        cmp.Name='Test Campaign';
        cmp.StartDate=system.today();
        cmp.EndDate=system.today();
        cmp.Campaign_Start_DateTime__c= system.now().addhours(-1);
        cmp.Country__c = 'Singapore';
        cmp.CurrencyIsoCode = 'SGD';
        cmp.Campaign_End_DateTime__c=system.now();
        insert cmp;
        
        Test.startTest();
        
        DailyBatchToActivateCampaign obj = new DailyBatchToActivateCampaign();
        DataBase.executeBatch(obj); 
        system.schedule('Test campaign datetime Schedule Job', sched, obj);
        
        Test.stopTest();
        
    }
    
    @isTest
    public static void DailyBatchToActivateCampaign_Test_Method_2(){
        String sched = '0 00 11 * * ?';
        Id recTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('VIP_Promotion').getRecordTypeId();
        Campaign cmp = new Campaign();
        cmp.Name='Test Campaign1';
        cmp.StartDate=system.today();
        cmp.EndDate=system.today();
        cmp.RecordTypeId = recTypeId;
        cmp.Country__c = 'Thailand';
        cmp.Campaign_Start_DateTime__c= system.now().addhours(+1);
        cmp.Campaign_End_DateTime__c= system.now().addhours(+1);
        cmp.CurrencyIsoCode = 'THB';
        insert cmp;
        
        Test.startTest();
        
        DailyBatchToActivateCampaign obj = new DailyBatchToActivateCampaign();
        DataBase.executeBatch(obj); 
        Test.stopTest();
        
    }
    
    @isTest
    public static void SchedulerToActivateCamp_Test_Method(){
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        List<Id> listOfCampIds = new List<Id>();
        
        String sched = '0 00 10 * * ?';
        
        Campaign cmp = new Campaign();
        cmp.Name='Test Campaign';
        cmp.StartDate= system.today();
        cmp.Campaign_Start_DateTime__c= system.now().addhours(+1);
        cmp.Country__c = 'Singapore';
        cmp.CurrencyIsoCode = 'SGD';
        insert cmp;
        
        Campaign_Eligibility__c campEligibility=PGTestDataFactory_v2.CreateCampaignEligibility(cmp.id);
        campEligibility.Run_Frequency__c='Weekly';
        insert campEligibility;
        
        listOfCampIds.add(cmp.Id);
        
        Test.startTest();
        
        SchedulerToActivateCamp obj = new SchedulerToActivateCamp(listOfCampIds,'Active');
        system.schedule('Test Activate Camp Schedule Job', sched, obj);
        
        Test.stopTest();
    }
    
     @isTest
     public static void SchedulerToActivateCamp_Test_Method1(){
        
        List<Id> listOfCampIds = new List<Id>();
        
        String sched = '0 00 10 * * ?';
        
        Campaign cmp = new Campaign();
        cmp.Name='Test Campaign';
        cmp.StartDate=system.today();
        cmp.Campaign_End_DateTime__c = system.now().addhours(+1);
        cmp.Country__c = 'Singapore';
        cmp.CurrencyIsoCode = 'SGD';
        insert cmp;
        
        listOfCampIds.add(cmp.Id);
        
        Test.startTest();
        
        SchedulerToActivateCamp obj = new SchedulerToActivateCamp(listOfCampIds,'InActive');
        system.schedule('Test Activate Camp Schedule Job1', sched, obj);
        
        Test.stopTest();
    }
    
    @isTest
    public static void DailyBatchToActivateCampaign_Test_Method_3(){
        String sched = '0 00 11 * * ?';
        Id recTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('VIP_Promotion').getRecordTypeId();
        Campaign cmp = new Campaign();
        cmp.Name='Test Campaign1';
        cmp.StartDate=system.today();
        cmp.EndDate=system.today();
        cmp.RecordTypeId = recTypeId;
        cmp.Country__c = 'Singapore';
        cmp.Campaign_Start_DateTime__c= system.now().addhours(+1);
        cmp.Campaign_End_DateTime__c= system.now().addhours(+1);
        insert cmp;
        
        Test.startTest();
        
        DailyBatchToActivateCampaign obj = new DailyBatchToActivateCampaign();
        DataBase.executeBatch(obj); 
        Test.stopTest();
        
    }
    
}