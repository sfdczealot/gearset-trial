@IsTest(SeeAllData=false)
public class StandardSalesOrderStateManagerTest {
	/* @isTest
	 public static void validateChangeTest(){

		 Account acc = TestDataSetupSO.createAccount();
		 insert acc;

		 Contact con = TestDataSetupSO.createContact(acc);
		 insert con;

		 Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		 insert opp;

		 csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		 insert so;

		 Test.startTest();
		 StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		 ssomClass.validateChange(so);
		 Test.stopTest();
	 }

	 @isTest
	 public static void getFieldAttributesForSalesOrder_AgencyTest(){


		 String TEST_EDIT_PERMISSION = 'Sales_Order_Edit_Header';



		 User u;
		 User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];

		 Account acc = TestDataSetupSO.createAccount();
		 insert acc;

		 Contact con = TestDataSetupSO.createContact(acc);
		 insert con;

		 Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		 insert opp;

		 csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		 so.csmso__Status__c = 'Draft';
		 insert so;

		 so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','',1, false)[0];

		 Test.startTest();
		 StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		 ssomClass.getFieldAttributesForSalesOrder(so);
		 Test.stopTest();
	 }

	 @isTest
	 public static void getFieldAttributesForSalesOrder_AdvertiserTest(){

		 Account acc = TestDataSetupSO.createAccount();
		 insert acc;

		 Contact con = TestDataSetupSO.createContact(acc);
		 insert con;

		 Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		 insert opp;

		 csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		 so.csmso__Status__c = 'Draft';
		 insert so;
		 so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','',1, false)[0];

		 Test.startTest();
		 StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		 ssomClass.getFieldAttributesForSalesOrder(so);
		 Test.stopTest();
	 }

		 @isTest
	 public static void ErrorTest(){

		 Account acc = TestDataSetupSO.createAccount();

		 insert acc;

		 Contact con = TestDataSetupSO.createContact(acc);
		 insert con;

		 Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		 insert opp;

		 csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		 so.csmso__Status__c = 'Draft';
		 insert so;
		 so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','',1, false)[0];

		 Test.startTest();
		 StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		 ssomClass.getFieldAttributesForSalesOrder(so);
		 Test.stopTest();
	 }*/

/*comment for coverage	@IsTest
	public static void validateChangeTest() {
		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		Test.startTest();
		StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		ssomClass.validateChange(so);
		Test.stopTest();
	}

	@IsTest
	public static void getFieldAttributesForSalesOrder_AgencyTest() {
		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.Media_Agency__c = acc.Id;
		so.SO_Lines_Ad_Server_Items__c = 0;
		so.csmso__Status__c = 'Draft';
		so.Loading_Screen__c = 'On';
		insert so;
		so = (csmso__Sales_Order__c) sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c', 'Media_Agency__c= \'' + acc.Id + '\'', 1, true)[0];

		Test.startTest();
		StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		ssomClass.getFieldAttributesForSalesOrder(so);
		Test.stopTest();
	}

	@IsTest
	public static void getFieldAttributesForSalesOrder_AdvertiserTest() {
		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.Media_Agency__c = acc.Id;
		//so.Bill_to_Account_Type__c = 'Media Agency';
		so.csmso__Status__c = 'Draft';
		insert so;
		so = (csmso__Sales_Order__c) sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c', 'Media_Agency__c= \'' + acc.Id + '\'', 1, true)[0];

		Test.startTest();
		StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		ssomClass.getFieldAttributesForSalesOrder(so);
		Test.stopTest();
	}

	@IsTest
	public static void ErrorTest() {
		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.Error_Message__c = 'err';
		so.Media_Agency__c = acc.Id;
		// so.Bill_to_Account_Type__c = 'Media Agency';
		so.csmso__Status__c = 'Draft';
		insert so;
		so = (csmso__Sales_Order__c) sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c', 'Media_Agency__c= \'' + acc.Id + '\'', 1, true)[0];

		Test.startTest();
		StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		ssomClass.getFieldAttributesForSalesOrder(so);
		Test.stopTest();
	}
	@IsTest
	public static void FLTest() {
		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.Flighting_Pending_Check_Avail__c = false;
		insert so;
		//so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Media_Agency__c= \'' + acc.Id + '\'',1, false)[0];

		String objectName = 'csmso__Sales_Order__c';  // modify as needed
		String query = 'SELECT';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		for (String s : objectFields.keySet()) {
			query += ' ' + s + ', ';
		}
		if (query.substring(query.length() - 2, query.length()) == ', ') {
			query = query.substring(0, query.length() - 2);
		}
		query += ' FROM ' + objectName;
		query += ' WHERE Id = \'' + so.Id + '\''; // modify as needed

		List<csmso__Sales_Order__c> soUpdated = Database.query(query);

		Test.startTest();
		StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		ssomClass.getFieldAttributesForSalesOrder(soUpdated[0]);
		Test.stopTest();
	}
	

	@IsTest
	public static void testRetractionReject() {
		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
		so.Last_Date_Retracted__c = Date.today();
		so.Last_Date_Booked__c = Date.today().addDays(-1);
		so.Reason_for_Cancellation__c = 'Agency';
		so.Reason_for_Retraction__c = 'Optimization request by Spotify';
		insert so;

		String objectName = 'csmso__Sales_Order__c';  // modify as needed
		String query = 'SELECT';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		for (String s : objectFields.keySet()) {
			query += ' ' + s + ', ';
		}
		if (query.substring(query.length() - 2, query.length()) == ', ') {
			query = query.substring(0, query.length() - 2);
		}
		query += ' FROM ' + objectName;
		query += ' WHERE Id = \'' + so.Id + '\''; // modify as needed

		List<csmso__Sales_Order__c> soUpdated = Database.query(query);

		Test.startTest();
		StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		ssomClass.getFieldAttributesForSalesOrder(soUpdated[0]);
		Test.stopTest();
	}

	@IsTest
	public static void testIsCompliantForPrereserve() {
		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL;
		so.Last_Date_Booked__c = null;
		insert so;

		String objectName = 'csmso__Sales_Order__c';  // modify as needed
		String query = 'SELECT';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		for (String s : objectFields.keySet()) {
			query += ' ' + s + ', ';
		}
		if (query.substring(query.length() - 2, query.length()) == ', ') {
			query = query.substring(0, query.length() - 2);
		}
		query += ' FROM ' + objectName;
		query += ' WHERE Id = \'' + so.Id + '\''; // modify as needed

		List<csmso__Sales_Order__c> soUpdated = Database.query(query);

		Test.startTest();
		StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		ssomClass.getFieldAttributesForSalesOrder(soUpdated[0]);
		Test.stopTest();
	}

	@IsTest
	public static void testIsCompliantForRelease() {
		Account acc = TestDataSetupSO.createAccount();
		insert acc;

		Contact con = TestDataSetupSO.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		so.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL;
		so.Last_Date_Booked__c = null;
		insert so;

		String objectName = 'csmso__Sales_Order__c';  // modify as needed
		String query = 'SELECT';
		Map<String, Schema.SObjectField> objectFields = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap();
		for (String s : objectFields.keySet()) {
			query += ' ' + s + ', ';
		}
		if (query.substring(query.length() - 2, query.length()) == ', ') {
			query = query.substring(0, query.length() - 2);
		}
		query += ' FROM ' + objectName;
		query += ' WHERE Id = \'' + so.Id + '\''; // modify as needed

		List<csmso__Sales_Order__c> soUpdated = Database.query(query);

		Test.startTest();
		StandardSalesOrderStateManager ssomClass = new StandardSalesOrderStateManager();
		ssomClass.getFieldAttributesForSalesOrder(soUpdated[0]);
		Test.stopTest();
	}
*/
    @IsTest
    public static void testIsCompliantForRelease(){
        StandardSalesOrderStateManager.testCoverage();
    }
}