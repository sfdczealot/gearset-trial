/**
 * Created by ivan.ravnjak on 17.6.2020..
 */
@IsTest
private class CS_P_approvalSnapshotNewTest {

	/**
	 * Tests isRecordEligible method, non applicable
	 */
	@IsTest
	public static void test_isRecordEligibleNonApplicable() {
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

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		insert so;

		Map<Id, csmso__Sales_Order__c> oldSalesOrders = new Map<Id, csmso__Sales_Order__c>();
		oldSalesOrders.put(so.Id, so);

		Test.startTest();
		CS_P_approvalSnapshotNew processClass = new CS_P_approvalSnapshotNew(oldSalesOrders);
		processClass.isRecordEligible(so);

		System.assert(processClass.applicableObjects.isEmpty(), 'No records to process expected.');
		System.assert(!processClass.runProcess, 'Process should not run.');
		Test.stopTest();
	}

	/**
	 * Tests isRecordEligible method, applicable
	 */
	@IsTest
	public static void test_isRecordEligibleApplicable() {
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

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.Compliance_Approval__c = 'Pending';
		insert so;

		Map<Id, csmso__Sales_Order__c> oldSalesOrders = new Map<Id, csmso__Sales_Order__c>();
		oldSalesOrders.put(so.Id, so);

		csmso__Sales_Order__c oldSalesOrder = [
				SELECT
						Id,
						Inventory_Approval__c,
						Account_Check_Approval__c,
						ARM_Approval__c, Compliance_Approval__c,
						Countersign_IO_Approval__c,
						Customer_Approval__c,
						Legal_Approval__c,
						Pricing_Approval__c,
						Name,
						Snapshot_Inventory__c,
						SD_Approval__c,
                        CM_Approval__c,
                        HOB_Approval__c,
                        CBO_Approval__c,
                        OMC_Approval__c,
						HOB_Awards_Approval__c,
						HOB_CNS_Approval__c,
						HOB_FastKey_Approval__c,
						HOB_Fintech_Approval__c,
						HOB_MaaS_Approval__c,
						HOB_Events_Approval__c
				FROM csmso__Sales_Order__c
				WHERE Id = :so.Id
		];
		so.csmso__Status__c = 'Reserved';
		so.SD_Approval__c = 'Approved';
		//so.Approval_Required__c = false;
		update so;

		Test.startTest();
		CS_P_approvalSnapshotNew processClass = new CS_P_approvalSnapshotNew(new Map<Id, csmso__Sales_Order__c>{
				oldSalesOrder.Id => oldSalesOrder
		});
		processClass.isRecordEligible(so);
		System.assert(!processClass.applicableObjects.isEmpty(), 'Expecting records to process.');
		System.assert(processClass.runProcess, 'Process should run.');
		Test.stopTest();
	}

	/**
	 * Tests isRecordEligible method, applicable
	 */
	@IsTest
	public static void test_TestLogic() {
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

		Contact con = TestDataSetupTargetables.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
		so.Compliance_Approval__c = 'Pending';
		insert so;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = so.Id;
		insert prodConfig;

		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so, acc);
		insert testFulfilment;

		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, so, testFulfilment);
		insert testFulfilmentItem;

		List<cscfga__Attribute__c> attributeList = new List<cscfga__Attribute__c>();
		cscfga__Attribute__c testAttr1 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr1.Name = 'Available Amount';
		attributeList.add(testAttr1);

		cscfga__Attribute__c testAttr2 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr2.Name = 'Ad Slot';
		testAttr2.cscfga__Value__c = 'INCLUDE:a5B6E0000004NXDUA2;EXCLUDE:a5B6E0000004NXDUA2;';
		attributeList.add(testAttr2);

		cscfga__Attribute__c testAttr3 = TestDataSetupTargetables.createAttr(prodConfig, so, testAttrDef, testFulfilmentItem);
		testAttr3.Name = 'Unavailable Amount';

		attributeList.add(testAttr3);
		insert attributeList;

		Map<Id, csmso__Sales_Order__c> oldSalesOrders = new Map<Id, csmso__Sales_Order__c>();
		oldSalesOrders.put(so.Id, so);

		csmso__Sales_Order__c oldSalesOrder = [
				SELECT
						Id,
						Inventory_Approval__c,
						Account_Check_Approval__c,
						ARM_Approval__c, Compliance_Approval__c,
						Countersign_IO_Approval__c,
						Customer_Approval__c,
						Legal_Approval__c,
						Pricing_Approval__c,
						Name,
						Snapshot_Inventory__c,
						SD_Approval__c,
                        CM_Approval__c,
                        HOB_Approval__c,
                        CBO_Approval__c,
                        OMC_Approval__c,
						HOB_Awards_Approval__c,
						HOB_CNS_Approval__c,
						HOB_FastKey_Approval__c,
						HOB_Fintech_Approval__c,
						HOB_MaaS_Approval__c,
						HOB_Events_Approval__c
				FROM csmso__Sales_Order__c
				WHERE Id = :so.Id
		];
		so.csmso__Status__c = 'Reserved';
		so.SD_Approval__c = 'Approved';
		update so;

		Test.startTest();
		CS_P_approvalSnapshotNew processClass = new CS_P_approvalSnapshotNew(new Map<Id, csmso__Sales_Order__c>{
				oldSalesOrder.Id => oldSalesOrder
		});
		processClass.isRecordEligible(so);
		System.assert(!processClass.applicableObjects.isEmpty(), 'Expecting records to process.');
		System.assert(processClass.runProcess, 'Process should run.');

		List<Attachment> attachmentListQueried = new List<Attachment>(
		[
				SELECT Id,
						Name,
						Body
				FROM Attachment
				WHERE ParentId = :prodConfig.Id
				ORDER BY CreatedDate DESC
		]);

		System.assert(attachmentListQueried.size() == 0, 'No attachments should be attached to this records');
		processClass.logic();
		Test.stopTest();

		List<Attachment> attachmentListAfterTest = new List<Attachment>(
		[
				SELECT Id,
						Name,
						Body,
						ParentId
				FROM Attachment
				WHERE ParentId = :prodConfig.Id
		]);
		System.assert(attachmentListAfterTest.size() == 1, 'One attachment should be attached to this records');
		System.assertEquals(attachmentListAfterTest[0].Name, CS_Constants.FILE_NAME_SD_APPROVAL_SNAPSHOT);
		System.assert(attachmentListAfterTest[0].Name == CS_Constants.FILE_NAME_SD_APPROVAL_SNAPSHOT, 'Wrong attachment name');
	}
}