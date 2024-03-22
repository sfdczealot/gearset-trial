@IsTest
private class CS_P_SOReadyToBookTest {

	/**
	 * Tests isRecordEligible method, non applicable
	 */
	@TestSetup
	static void testSetup() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		insert testProDef;

		cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		insert testAttrDef;

		Account acc = TestDataSetupTargetables.createAccount();
		insert acc;

		Account agency = TestDataSetupTargetables.createAccount();
		agency.Type = 'Media Agency';
		insert agency;

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		opp.Media_Agency2__c = agency.Id;
		opp.Agency_Client_del__c = acc.Id;
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;
	}

	@IsTest
	public static void testBook() {
		csmso__Sales_Order__c so = [
				SELECT Id,
						Name,
						csmso__Status__c,
						Legal_Check__c,
						Rejection_Count__c
				FROM csmso__Sales_Order__c
				LIMIT 1
		];

		Test.startTest();
		Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
		mapOld.put(so.Id, so);
		CS_P_SOReadyToBook process = new CS_P_SOReadyToBook(mapOld);

		so.csmso__Status__c = CS_const_SalesOrder.Status_Reserved;
		so.Legal_Check__c = CS_const_SalesOrder.ApprovalStatus_Rejected;
		so.Compliance_Check__c = CS_const_SalesOrder.ApprovalStatus_Approved;
		so.Counter_Sign_IO__c = CS_const_SalesOrder.ApprovalStatus_Approved;
		update so;

		process.isRecordEligible(so);
		process.logic();

		System.assert(so.csmso__Status__c != CS_const_SalesOrder.Status_Booked);
		Test.stopTest();
	}

	@IsTest
	public static void testBook2() {
		csmso__Sales_Order__c so = [
				SELECT Id,
						Name,
						csmso__Status__c,
						Legal_Check__c,
						Rejection_Count__c
				FROM csmso__Sales_Order__c
				LIMIT 1
		];

		Test.startTest();
		Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
		mapOld.put(so.Id, so);
		CS_P_SOReadyToBook process = new CS_P_SOReadyToBook(mapOld);

		so.csmso__Status__c = CS_const_SalesOrder.Status_Reserved;
		so.Legal_Check__c = CS_const_SalesOrder.ApprovalStatus_Approved;
		so.Compliance_Check__c = CS_const_SalesOrder.ApprovalStatus_Approved;
		so.Counter_Sign_IO__c = CS_const_SalesOrder.ApprovalStatus_Approved;
		update so;

		process.isRecordEligible(so);
		process.logic();

		System.assert(so.csmso__Status__c == CS_const_SalesOrder.Status_Booked);
		Test.stopTest();
	}

	@IsTest
	public static void testBook3() {
		csmso__Sales_Order__c so = [
				SELECT Id,
						Name,
						csmso__Status__c,
						Legal_Check__c,
						Rejection_Count__c
				FROM csmso__Sales_Order__c
				LIMIT 1
		];

		Opportunity opp = [
				SELECT Id,
						Name
				FROM Opportunity
				LIMIT 1
		];

		Test.startTest();
		Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
		mapOld.put(so.Id, so);
		CS_P_SOReadyToBook process = new CS_P_SOReadyToBook(mapOld);

		so.csmso__Opportunity__c = opp.Id;
		so.Total_Price_Calculated__c = 10;
		so.csmso__Status__c = CS_const_SalesOrder.Status_Reserved;
		so.Legal_Check__c = CS_const_SalesOrder.ApprovalStatus_Approved;
		so.Compliance_Check__c = CS_const_SalesOrder.ApprovalStatus_Approved;
		so.Counter_Sign_IO__c = CS_const_SalesOrder.ApprovalStatus_Approved;
		update so;

		process.isRecordEligible(so);
		process.logic();

		System.assert(so.csmso__Status__c == CS_const_SalesOrder.Status_Booked);
		Test.stopTest();
	}
}