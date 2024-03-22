@isTest
public class BatchToUpdateCampaignMemberStatus_Test {
    
    @isTest
    static void BatchToUpdateCampaignMemberStatusMethod(){
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.EndDate = system.today().addDays(-2);
        insert cma;
        
        Campaign cma2 = new Campaign();
        cma2.Name = 'TestNameCampaign2';
        cma2.Country__c = 'Singapore';
        cma2.IsActive = true;
        cma2.EndDate = system.today().addDays(-2);
        insert cma2;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'testLname';
        con.Email = 'test@nmail.com';
        insert con;
        
        CampaignMember cmp = new CampaignMember();
        cmp.ContactId = con.Id;
        cmp.Status = 'Revoked';
        cmp.CampaignId = cma.Id;
        insert cmp;
        
        Test.startTest();
        //DataBase.executeBatch(new BatchToUpdateCampaignMemberStatus());
        system.schedule('Change CampaignMemberStatus', '0 0 12 * * ?', new BatchToUpdateCampaignMemberStatus());
        Test.stopTest();
    }
}