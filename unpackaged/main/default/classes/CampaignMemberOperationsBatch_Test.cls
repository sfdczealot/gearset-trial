@isTest
public class CampaignMemberOperationsBatch_Test {
    
    
    @isTest
    static void CampaignMemberOperationsMethod(){
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TECM = new Trigger_Execute__c();
        TECM.Name = 'PGCampMemberTrigger';
        TECM.Enable_del__c = true;
        insert TECM;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';  
        cma.IsActive = true;
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com'; 
        insert con;
        
        Lead ld = new Lead();
        ld.LastName = 'ldName';
        ld.Company = 'testCompany';
        insert ld;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Revoked';
        cmp.CampaignId = cma.Id;
        
        insert cmp;
        system.debug('>>>>'+cmp.Status);
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id,Status__c='Active');     
        insert ce1;
        
        Map<id,list<Contact>> idVsListOfObjectMap = new Map<id,list<Contact>>();
        idVsListOfObjectMap.put(ce1.Id,[select Id,Name from Contact]);
        Test.startTest();
        DataBase.executeBatch(new CampaignMemberOperationsBatch(idVsListOfObjectMap),1);
        Test.stopTest();
        
    }
    @isTest
    static void CampaignMemberOperationsMethod1(){
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TECM = new Trigger_Execute__c();
        TECM.Name = 'PGCampMemberTrigger';
        TECM.Enable_del__c = true;
        insert TECM;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        insert cma;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        Lead ld = new Lead();
        ld.LastName = 'ldName';
        ld.Company = 'testCompany';
        insert ld;
        
        CampaignMember cmp = new CampaignMember();
        cmp.LeadId = ld.Id;
        cmp.Status = 'Eligible';
        cmp.CampaignId = cma.Id;
        insert cmp;
        system.debug('>>>>'+cmp.Status);
        
        Campaign_Eligibility__c ce2 = new Campaign_Eligibility__c(Name='test2',Rule_Name_Extension__c='DynamicMethodCall;multiplyNumbers',Criteria_Type__c = 'Apex Method',Priority__c=2,Campaign__c=cma.Id,Status__c='Active');     
        insert ce2;
        
        Map<id,list<Lead>> idVsListOfObjectMap = new Map<id,list<Lead>>();
        idVsListOfObjectMap.put(ce2.Id,[select Id,Name from Lead]);
        Test.startTest();
        //CampaignMemberOper_BatchSchedulable objcls=new CampaignMemberOper_BatchSchedulable();
        //SchedulableContext SC;
        //objcls.execute(SC);
        DataBase.executeBatch(new CampaignMemberOperationsBatch(idVsListOfObjectMap));
        Test.stopTest();
        
    }
    
}