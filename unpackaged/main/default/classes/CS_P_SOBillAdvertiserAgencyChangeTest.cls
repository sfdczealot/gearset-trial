@isTest 
private class CS_P_SOBillAdvertiserAgencyChangeTest {

	private static String productConfigId;
    private static List<csmso__Sales_Order__c> salesOrders;
	//private static List<Billing_Schedule__c> bSchedules = new List<Billing_Schedule__c>();

	private static void createTestData(){
		//CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
	    insert soapi;

		//Account Creation.
		List<Account> Acc = TestDataSetupSO.createAccounts(1);
		
		//Contact Creation.
		List<Contact> con = TestDataSetupSO.createContacts(1,Acc);
		
		//Opportunity Creation.
		List<Opportunity> opp = TestDataSetupSO.createOpportunities(1,Acc,con);
		
		//SalesOrder Creation.
		salesOrders = TestDataSetupSO.createSalesOrders(1,Acc,opp);
		
		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
		
		//Attribute definition Creation.
		List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);
		
		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,salesorders);
		
		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);
		
		//Fulfilment Creation.
		List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,salesorders,Acc);
		Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
		Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
		
		for(cscfga__product_Configuration__c pConfig: prodConfigs){
			if(salesOrders.size()>0)
				pConfig.Sales_Order__c = salesOrders[0].id;
				pConfig.Billing_Schedule_Rule__c = bScheduleRule.id;
				pConfig.Revenue_Schedule_Rule__c = rScheduleRule.id;
				pConfig.Requires_Rescheduling__c= true;
				pConfig.cscfga__Configuration_Status__c ='Valid';
		}
		update prodConfigs;
		List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,ProdConfigs);
		fulfilmentItem[0].csdf__Status__c = 'Reserved';
		update fulfilmentItem;

		// Billing
		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.sales_order__c = salesOrders[0].id;
        insert salesOrderSchedule;

		CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
        bScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.id;
        bScheduleHeader.Under_IFC__c = false;
        insert bScheduleHeader;

		CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = prodConfigs[0].id;
        bSchedule.Status__c = 'Open';
        bSchedule.Sales_Order__c = prodConfigs[0].Sales_Order__c;
        bSchedule.DFP_Actuals__c = 100;
        bSchedule.Net_Rate__c = 100.0;
		bSchedule.Billing_Date__c = Date.Today().addDays(-4);
        bSchedule.Billing_Period_Start_Date__c = Date.Today().addDays(-4);
        bschedule.billing_schedule__c = bScheduleHeader.id;
        insert bSchedule;

        //CS Revenue Schedule
        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
		rScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.id;
		insert rScheduleHeader;

		//CS Revenue Schedule Item
        CS_Revenue_Schedule_Item__c rSchedule = new CS_Revenue_Schedule_Item__c();
		rSchedule.Sales_Order__c = prodConfigs[0].Sales_Order__c;
		rSchedule.Product_Configuration__c = prodConfigs[0].id;
		rSchedule.Status__c = 'Open';
		rSchedule.Rev_Rec_Date__c = Date.Today().addDays(-4);
		rSchedule.Rev_Rec_Period_Start_Date__c = Date.Today().addDays(-4);
        rSchedule.Rev_Rec_Period_End_Date__c = Date.Today().addDays(4);
        rSchedule.Revenue_Schedule__c = rScheduleHeader.Id;
		insert rSchedule;

		
		productConfigId = prodConfigs[0].Id;
	}

	@isTest 
	public static void agencyChangeTest() {
		createTestData();
		
		List<Account> Acc2 = TestDataSetupSO.createAccounts(1);
		Test.startTest();
		salesOrders[0].Advertiser_Final__c = Acc2[0].Id;
		update salesOrders;
		Test.stopTest();
			
		List<CS_Revenue_Schedule_Item__c> rScheduleItems  = new List<CS_Revenue_Schedule_Item__c>();
		rScheduleItems = [select id, Advertiser__c, Agency__c, Bill_To_Account__c, Sales_Order__c  FROM CS_Revenue_Schedule_Item__c
			                                                      WHERE Sales_Order__c = :salesOrders[0].Id
			                                                      AND (Status__c =:CS_const_SalesOrder.ScheduleStatus_Forecast OR 
			                                                      	   Status__c =:CS_const_SalesOrder.ScheduleStatus_Open)];

		//test
		System.assertEquals(rScheduleItems[0].Advertiser__c, Acc2[0].Id);
	}

}