@isTest
public class PGBatchToActivateCampaign_Test {
	
    @isTest
    public static void PGBatchToActivateCampaignTest(){
    	
    	Campaign c = new campaign();
        //c.RecordTypeId = campaignPromoRectype;
        c.Name = 'test campaign';
        c.Country__c = 'Singapore';
        c.IsActive = true;
        c.StartDate = system.today();
        c.EndDate = system.today().addDays(2);
        insert c;
        
        Campaign renewal_c = new campaign();
        renewal_c.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Renewal Promotion').getRecordTypeId();
        renewal_c.Name = 'test renewal campaign';
        renewal_c.Country__c = 'Singapore';
        renewal_c.IsActive = true;
        c.StartDate = system.today().addDays(-5);
        c.EndDate = System.today().addDays(-1);
        insert renewal_c;
        
        Test.startTest();
        PGBatchToActivateCampaign sh1 = new PGBatchToActivateCampaign();
		String sch = '0 0 23 * * ?'; system.schedule('Call Active Campaign Batch', sch, sh1); 
        Test.stopTest();
    }
}