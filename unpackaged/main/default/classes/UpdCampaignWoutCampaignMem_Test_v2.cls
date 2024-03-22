@isTest
public class UpdCampaignWoutCampaignMem_Test_v2 {
	
    static testMethod void mainTest(){
        Campaign cam = null;
		// Avoid mixed DML
		User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
		System.runAs (thisUser) {
			// Call method to insert test records
			PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            DateTime dt = system.today()-30;
            Date endDt = date.newinstance(dt.year(), dt.month(), dt.day());
            cam = PGTestDataFactory_v2.CreateCampaign(endDt);
            system.debug(cam);
		}

		Test.startTest();
        Database.executeBatch(new UpdateCampaignWithoutCampaignMember());
		Test.stopTest();
        //assert
        system.assertEquals(false, [select id,isactive from campaign where id = :cam.id].isactive);
        
    }
    
}