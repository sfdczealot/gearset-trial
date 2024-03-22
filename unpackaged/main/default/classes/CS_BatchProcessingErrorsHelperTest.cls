/**
 * Created by jameshladek on 2/25/20.
 */
@IsTest
public with sharing class CS_BatchProcessingErrorsHelperTest {

	@IsTest
    static void testErrorHandling() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Profile p0 = [SELECT Id FROM Profile WHERE Name IN ('S: Systems Administrator', 'Systeembeheerder') LIMIT 1];
        User u0 = new User(Alias = 'standta', Email = 'standardusear@testorg.com',
                EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US', ProfileId = p0.Id,
                TimeZoneSidKey = 'America/Los_Angeles', Username = 'standamarkordusera1234@testorg.com');
        insert u0;

		Group reqGroup = [SELECT Id FROM Group WHERE Name = 'RecipientsOfProcessingErrorEmail'];
		Group newGroup = new Group();
		newGroup.Name = 'Test Group';
		newGroup.Type = 'Regular';
		insert newGroup;

        System.runAs(u0) {
            GroupMember newGm = new GroupMember();
            newGm.GroupId = reqGroup.Id;
            newGm.UserOrGroupId = newGroup.Id;
            insert newGm;

            GroupMember newGm2 = new GroupMember();
            newGm2.GroupId = reqGroup.Id;
            newGm2.UserOrGroupId = [SELECT Id FROM User WHERE IsActive = TRUE AND LastName != 'Process' LIMIT 1].Id;
            insert newGm2;

            GroupMember gm2 = new GroupMember();
            gm2.GroupId = newGroup.Id;
            gm2.UserOrGroupId = [SELECT Id FROM User WHERE IsActive = TRUE AND LastName != 'Process' LIMIT 1].Id;
            insert gm2;
        }

		Integer emailsSent;
		Test.startTest();
		CS_BatchProcessingErrorsHelper.checkForErrors();
		List<AsyncApexJob> erroredJobs = [
				SELECT Id, ApexClass.Name, MethodName, Status, ExtendedStatus, NumberOfErrors
				FROM AsyncApexJob
				WHERE Status != 'Completed'
				AND CreatedDate = TODAY
		];
		CS_BatchProcessingErrorsHelper.processForEmail(erroredJobs);
		emailsSent = Limits.getEmailInvocations();
		Test.stopTest();

		System.assertEquals(1, emailsSent);
	}

	@IsTest static void testSchedulable() {
		Test.startTest();
		CS_BatchProcessingErrors schedule = new CS_BatchProcessingErrors();
		String sch = '0 0 23 8 8 ?';
		System.schedule('Process Error Check', sch, new CS_BatchProcessingErrors());
		Test.stopTest();
	}
}