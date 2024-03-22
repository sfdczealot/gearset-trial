@isTest
public class BatchToPopulateExistingCampaigns_Test {
    @isTest
    public static void BatchToPopulateExistingCampaigns_Test_Method(){
        
        // Insert Campaign records
        
        Campaign cmp = new Campaign();
        cmp.Name='Test Campaign';
        cmp.StartDate=system.today();
        insert cmp;
        
        Campaign cmp1 = new Campaign();
        cmp1.Name='Test Campaign1';
        cmp1.EndDate=system.today().adddays(1);
        insert cmp1;
        
        
        Test.startTest();
        
        BatchToPopulateExistingCampaigns obj = new BatchToPopulateExistingCampaigns();
        DataBase.executeBatch(obj); 
        
        Test.stopTest();
        
    }
    
    
    
}