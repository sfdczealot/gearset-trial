@isTest
public class CMInsertCRE_Test {
    
    @isTest
    static void testRun(){
        
        Trigger_Execute__c customSettintCE = new Trigger_Execute__c();
        customSettintCE.Name = 'PGCampaignEligibilityTrigger';
    	customSettintCE.Enable_del__c = false;
        insert customSettintCE;
        Trigger_Execute__c customSettintCE1 = new Trigger_Execute__c();
        customSettintCE1.Name = 'PGCampMemberTrigger';
    	customSettintCE1.Enable_del__c = false;
        insert customSettintCE1;
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign'; 
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        insert cma;
        
        Campaign cma1 = new Campaign();
        cma1.Name = 'TestCampaignName';
        cma1.Country__c = 'Singapore';
        cma1.IsActive = true;
        insert cma1;
        
		        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        Lead ld = new Lead();
        ld.LastName = 'ldName';
        ld.Company = 'testCompany';
        insert ld;
        
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id,Status__c='Active');     
        insert ce1;
        
        Test.startTest();
        DataBase.executeBatch(new CMInsertCRE(ce1.Id,new Set<String>{con.Id}));
        Test.stopTest();
    }
    @isTest
    static void testRun1(){
        
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
        
        Campaign cma1 = new Campaign();
        cma1.Name = 'TestCampaignName';
        cma1.Country__c = 'Singapore';
        cma1.IsActive = true;
        insert cma1;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        Lead ld = new Lead();
        ld.LastName = 'ldName';
        ld.Company = 'testCompany';
        insert ld;
        
        
        
        Campaign_Eligibility__c ce1 = new Campaign_Eligibility__c(Name='test1',Rule_Name_Extension__c='Select Id From Contact',Criteria_Type__c = 'SOQL',Priority__c=1,Campaign__c=cma.Id,Status__c='Active');     
        insert ce1;
        
        Test.startTest();
        DataBase.executeBatch(new CMInsertCRE(ce1.Id,new Set<String>{ld.Id}));
        Test.stopTest();
    }
     @isTest
    static void testRun2(){
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
        
        Campaign cma1 = new Campaign();
        cma1.Name = 'TestCampaignName';
        cma1.Country__c = 'Singapore';
        cma1.IsActive = true;
        insert cma1;
        
		        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        Lead ld = new Lead();
        ld.LastName = 'ldName';
        ld.Company = 'testCompany';
        insert ld;
        
        CampaignMemberStatus cms = new CampaignMemberStatus();
        cms.Label = 'Eligible';
        cms.CampaignId = cma.Id;
        insert cms;
        
        List<CampaignMember> campaignMemberList = new List<CampaignMember>();
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Eligible';
        cmp.CampaignId = cma.Id;
        campaignMemberList.add(cmp);
        
        CampaignMember cmp2 = new CampaignMember();
        cmp2.ContactId = con.Id;
        cmp2.Status = 'Eligible';
        cmp2.CampaignId = cma.Id;
        campaignMemberList.add(cmp2);
                
        Database.SaveResult[] insertList = Database.insert(campaignMemberList,false);
        system.debug('insertList>>> '+insertList);
        system.debug('insertListSize>>> '+insertList.size());
        CMInsertCRE cre = new CMInsertCRE();
        
        cre.campaignMemberSlackAlert(cma.Id, insertList);    
        
        
    }
}