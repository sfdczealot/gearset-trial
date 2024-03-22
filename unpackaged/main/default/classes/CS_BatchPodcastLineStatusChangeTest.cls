@IsTest
public class CS_BatchPodcastLineStatusChangeTest {

	@IsTest
	private static void testBatchPodcastLineStatusChange() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account[] accs = TestDataSetupBasic.createAccounts(2);
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
		Opportunity o = opps[0];

		accs[0].Type = 'Creative Agency';
		accs[1].Type = 'Advertiser';
		update accs;

		csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = o.Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.Order_Type__c = CS_Constants.ORDER_TYPE_HOUSE_GUARANTEED;
		salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
		salesOrder.SO_Lines_Number_of_lines__c = 2;
		salesOrder.Primary_Sales_Order__c = true;
		salesOrder.Agency_Final__c = accs[0].Id;
		salesOrder.Advertiser_Final__c = accs[1].Id;
		insert salesOrder;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Attribute definition Creation.

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				salesOrder
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
				salesOrder
		}, accs);

		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
		fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(-1);
		fulfilmentItem[0].csdf__Flight_End__c = Date.today().addDays(-1);
		fulfilmentItem[0].Served_By__c = 'Megaphone';
		update fulfilmentItem;

		Test.startTest();
		CS_BatchPodcastLineStatusChange batch = new CS_BatchPodcastLineStatusChange(10);
		batch.doWork(fulfilmentItem);
		Test.stopTest();
	}
}