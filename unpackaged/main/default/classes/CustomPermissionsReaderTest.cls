@IsTest(SeeAllData=false)
private class CustomPermissionsReaderTest {

	/**
	 * This will need to be modified to reflect a Custom Permission in the org,
	 *   since DML in test code cannot create them :-(
	 **/
	private static final String TEST_CUSTOM_PERMISSION = 'Sales_Order_Edit_Header';

	@IsTest
	private static void testCustomPermissionAssigned() {
		// Create PermissionSet with Custom Permission and assign to test user
		PermissionSet ps = new PermissionSet();
		ps.Name = 'CustomPermissionsReaderTest';
		ps.Label = 'CustomPermissionsReaderTest';
		insert ps;
		SetupEntityAccess sea = new SetupEntityAccess();
		sea.ParentId = ps.Id;
		sea.SetupEntityId = [SELECT Id FROM CustomPermission WHERE DeveloperName = :TEST_CUSTOM_PERMISSION][0].Id;
		insert sea;
		PermissionSetAssignment psa = new PermissionSetAssignment();
		psa.AssigneeId = UserInfo.getUserId();
		psa.PermissionSetId = ps.Id;
		insert psa;

		// Create reader
		//   Note: SObjectType for managed package developers should be a Custom Object from that package
		CustomPermissionsReader cpr = new CustomPermissionsReader(Account.SObjectType);

		// Assert the CustomPermissionsReader confirms custom permission assigned
		System.assertEquals(true, cpr.hasPermission(TEST_CUSTOM_PERMISSION));
	}

	@IsTest
	private static void testCustomPermissionNotAssigned() {
		// Setup test data
		// This code runs as the system user
		User u = getDummyUser();

		System.runAs(u) {
			// The following code runs as user 'u'
			System.debug('Current User: ' + UserInfo.getUserName());
			// Assert the CustomPermissionsReader confirms custom permission not assigned
			System.assertEquals(false, new CustomPermissionsReader(Account.SObjectType).hasPermission(TEST_CUSTOM_PERMISSION));
		}
	}

	@IsTest
	private static void testCustomPermissionDefaultConstructor() {
		User u = getDummyUser();

		System.runAs(u) {
			// Assert the CustomPermissionsReader confirms custom permission not assigned
			System.assertEquals(false, new CustomPermissionsReader().hasPermission(TEST_CUSTOM_PERMISSION));
		}
	}

	private static User getDummyUser() {
		// Setup test data
		// This code runs as the system user
		Profile p = [SELECT Id FROM Profile WHERE Name IN ('Standard User', 'Standaardgebruiker') LIMIT 1];

		String uniqueName = UserInfo.getOrganizationId() + '@csmediaTestclasses.com';

		User u = new User(Alias = String.valueOf(p.Id).right(6), Email = uniqueName,
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id,
				TimeZoneSidKey = 'America/Los_Angeles', Username = uniqueName);

		return u;
	}
}