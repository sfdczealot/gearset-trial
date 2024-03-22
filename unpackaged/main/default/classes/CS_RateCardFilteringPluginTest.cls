@IsTest
public class CS_RateCardFilteringPluginTest {
	private static String salesOrderId;
	private static Sales_Order_Filtering__c sof;

	@IsTest
	public static void test_rateCardPerformAction() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		testProDef.Name = 'Non-Ad Served';
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
		salesOrderId = so.Id;

		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;

		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		prodConfig.Sales_Order__c = so.Id;
		prodConfig.cscfga__Product_Definition__c = testProDef.Id;
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

		csmso__Sales_Order__c oldSalesOrder = [SELECT Id, Snapshot_Inventory__c,Approval_Inventory_Required__c,Snapshot_Sales_1__c,Approval_Sales_1_Required__c,Snapshot_Sales_2__c,Approval_Sales_2_Required__c,Snapshot_Finance__c,Approval_Finance_Required__c,csmso__Status__c,Legal_Check__c,Compliance_Check__c, Name FROM csmso__Sales_Order__c WHERE Id = :so.Id];
		so.csmso__Status__c = 'Reserved';
		so.Compliance_Check__c = 'Approved';

		update so;

		Sales_Order_Filtering__c sof = new Sales_Order_Filtering__c();

		sof.Name = 'Test sof';
		sof.Linked_Sales_Order__c = so.Id;
		insert sof;

		Map<String, String> fields = new Map<String, String>();
		fields.put('Ad Slot', 'Ad Slot');
		String parentFieldValue = String.valueOf(sof.Id);

		Test.startTest();

		CS_RateCardFilteringPlugin rateCard = new CS_RateCardFilteringPlugin();
		rateCard.query(fields, parentFieldValue);

		Test.stopTest();

		System.assertNotEquals(so, null);
		System.assertNotEquals(sof, null);
	}
}