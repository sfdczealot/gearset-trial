@isTest
public class CREQueueable_Test {
    
    @isTest
    static void testRun(){
        Trigger_Execute__c customSettintCE = new Trigger_Execute__c();
        customSettintCE.Name = 'PGCampaignEligibilityTrigger';
        customSettintCE.Enable_del__c = false;
        insert customSettintCE;
        
        Trigger_Execute__c customSettintCM = new Trigger_Execute__c();
        customSettintCM.Name = 'PGCampMemberTrigger';
        customSettintCM.Enable_del__c = false;
        insert customSettintCM;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.RecordTypeId = RecordTypeSelector.getRecordTypeId('Campaign', 'Renewal Promotion');
        insert cma;
        
        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.Label = 'Joined';
        cms.CampaignId = cma.Id;
        insert cms;
        
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
        
        CampaignMember cmp1 = new CampaignMember();
        cmp1.LeadId = ld.Id;
        cmp1.Status = 'Joined';
        cmp1.CampaignId = cma.Id;
        insert cmp1;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id,Status__c='Active');     
        insert ce1;
        list<Sobject> listLead=[select id from lead];
        
        list<Sobject> sObjectList = [Select Id From Contact];
        Test.startTest();
        system.enqueueJob(new CREQueueable(ce1.Id,sObjectList));
        system.enqueueJob(new CREQueueable(ce1.Id,listLead));
        Test.stopTest();
        
    }
    
    @isTest
    static void testRunSelfServe(){
        Trigger_Execute__c customSettintCE = new Trigger_Execute__c();
        customSettintCE.Name = 'PGCampaignEligibilityTrigger';
        customSettintCE.Enable_del__c = false;
        insert customSettintCE;
        
        Trigger_Execute__c customSettintCM = new Trigger_Execute__c();
        customSettintCM.Name = 'PGCampMemberTrigger';
        customSettintCM.Enable_del__c = false;
        insert customSettintCM;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.RecordTypeId = RecordTypeSelector.getRecordTypeId('Campaign', 'Self Serve Marketing Promotion');
        insert cma;
        
        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.Label = 'Joined';
        cms.CampaignId = cma.Id;
        insert cms;
        
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
        
        CampaignMember cmp1 = new CampaignMember();
        cmp1.LeadId = ld.Id;
        cmp1.Status = 'Joined';
        cmp1.CampaignId = cma.Id;
        insert cmp1;
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id,Status__c='Active');     
        insert ce1;
        list<Sobject> listLead=[select id from lead];
        
        list<Sobject> sObjectList = [Select Id From Contact];
        Test.startTest();
        system.enqueueJob(new CREQueueable(ce1.Id,sObjectList));
        system.enqueueJob(new CREQueueable(ce1.Id,listLead));
        Test.stopTest();
        
    }
}