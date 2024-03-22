@isTest
public class ProcessingBatchSOQL_Test {
    
    @isTest
    static void runTest(){
        
     Trigger_Execute__c customSettintCE1 = new Trigger_Execute__c();
        customSettintCE1.Name = 'PGCampMemberTrigger';
    	customSettintCE1.Enable_del__c = false;
        insert customSettintCE1;
        Trigger_Execute__c customSettintCE = new Trigger_Execute__c();
        customSettintCE.Name = 'PGCampaignEligibilityTrigger';
    	customSettintCE.Enable_del__c = false;
        insert customSettintCE;
        
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
        
        Campaign_Eligibility__c ce = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id,Status__c='Active');     
        insert ce;
        
        
        Test.startTest();
        DataBase.executeBatch(new ProcessingBatchSOQL(new Map<Id,String>{ce.Id => ce.Rule_Name_Extension__c},new List<Id>{ce.Id}));
        Test.stopTest();
        
    }
    
    @isTest
    static void runTest1(){
        
        Trigger_Execute__c customSettintCE = new Trigger_Execute__c();
        customSettintCE.Name = 'PGCampaignEligibilityTrigger';
        customSettintCE.Enable_del__c = false;
        insert customSettintCE;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        String campRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Self Serve Marketing Promotion').getRecordTypeId();

        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.RecordTypeId = campRecordTypeId;
        insert cma;
        
        Contact con = new Contact(); 
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        Campaign_Eligibility__c ce = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id,Status__c='Active');     
        insert ce;
        
        List<CampaignMember> campMemberList = new List<CampaignMember>();
        CampaignMember campMember = new CampaignMember();
        campMember.ContactId = con.Id;
        campMember.Status = 'Eligible';
        campMember.CampaignId = cma.Id;
        campMemberList.add(campMember);
        insert campMemberList;
        
        Test.startTest();
        DataBase.executeBatch(new ProcessingBatchSOQL(new Map<Id,String>{ce.Id => ce.Rule_Name_Extension__c},new List<Id>{ce.Id}));
        Test.stopTest();
        
    }
      @isTest
    static void runTest2(){
        
        Trigger_Execute__c customSettintCE = new Trigger_Execute__c();
        customSettintCE.Name = 'PGCampaignEligibilityTrigger';
        customSettintCE.Enable_del__c = false;
        insert customSettintCE;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        String campRecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Self Serve Renewal campaigns').getRecordTypeId();

        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.RecordTypeId = campRecordTypeId;
        insert cma;
        
        Contact con = new Contact(); 
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        Campaign_Eligibility__c ce = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id,Status__c='Active');     
        insert ce;
        
        List<CampaignMember> campMemberList = new List<CampaignMember>();
        CampaignMember campMember = new CampaignMember();
        campMember.ContactId = con.Id;
        campMember.Status = 'Eligible';
        campMember.CampaignId = cma.Id;
        campMemberList.add(campMember);
        insert campMemberList;
        
        Test.startTest();
        DataBase.executeBatch(new ProcessingBatchSOQL(new Map<Id,String>{ce.Id => ce.Rule_Name_Extension__c},new List<Id>{ce.Id}));
        Test.stopTest();
        
    }
}