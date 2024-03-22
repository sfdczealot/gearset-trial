@isTest 
private class CS_P_UpdateOpenQuantityRevenueTest {
	private static CS_Revenue_Schedule_Item__c rSchedule;
	private static CS_Revenue_Schedule_Item__c rSchedule2;
	private static Set<Id> rScheduleIds;
	private static Map<Id, CS_Revenue_Schedule_Item__c> rScheduleMap;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
	    insert soapi;

		//Account Creation.
		List<Account> Acc = TestDataSetupSO.createAccounts(1);
		
		//Contact Creation.
		List<Contact> con = TestDataSetupSO.createContacts(1,Acc);
		
		//Opportunity Creation.
		List<Opportunity> opp = TestDataSetupSO.createOpportunities(1,Acc,con);
		
		//SalesOrder Creation.
		List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1,Acc,opp);
		
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
        bSchedule.Billing_Period_Start_Date__c = Date.Today().addDays(-4);
        bschedule.billing_schedule__c=bScheduleHeader.id;
        insert bSchedule;

        //CS Revenue Schedule
        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
		rScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.id;
		insert rScheduleHeader;

		rScheduleIds = new Set<Id>();
		rScheduleIds.add(rScheduleHeader.Id);

		//CS Revenue Schedule Item
        rSchedule = new CS_Revenue_Schedule_Item__c();
		rSchedule.Sales_Order__c = prodConfigs[0].Sales_Order__c;
		rSchedule.Product_Configuration__c = prodConfigs[0].id;
		rSchedule.Status__c = 'Open';
		rSchedule.Total_Open_Qty__c = 10;
		rSchedule.Rev_Rec_Period_Start_Date__c = Date.Today().addDays(-4);
        rSchedule.Rev_Rec_Period_End_Date__c = Date.Today().addDays(4);
        rSchedule.Revenue_Schedule__c = rScheduleHeader.Id;
		insert rSchedule;

		//CS Revenue Schedule Item
        rSchedule2 = new CS_Revenue_Schedule_Item__c();
		rSchedule2.Sales_Order__c = prodConfigs[0].Sales_Order__c;
		rSchedule2.Product_Configuration__c = prodConfigs[0].id;
		rSchedule2.Status__c = 'Open';
		rSchedule2.Total_Open_Qty__c = 12;
		rSchedule2.Rev_Rec_Period_Start_Date__c = Date.Today().addDays(-4);
        rSchedule2.Rev_Rec_Period_End_Date__c = Date.Today().addDays(4);
        rSchedule2.Revenue_Schedule__c = rScheduleHeader.Id;
		insert rSchedule2;

		rScheduleMap = new Map<Id, CS_Revenue_Schedule_Item__c>();
		rScheduleMap.put(rSchedule.Id, rSchedule);
        
	}

	@isTest()
	public static void testUpdateOpenQuantityRevenue() {    
		createTestData();

        Test.startTest();
        CS_P_UpdateOpenQuantityRevenue process = new CS_P_UpdateOpenQuantityRevenue(rScheduleMap);
        rSchedule.Total_Open_Qty__c = 15;
        //update rSchedule;

        process.isRecordEligible(rSchedule);
        process.applicableObjects = rScheduleMap;
        process.revenueScheduleIds = rScheduleIds;
        process.logic();
		Test.stopTest();
    }
}