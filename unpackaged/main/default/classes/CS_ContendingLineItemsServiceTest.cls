@isTest 
private class CS_ContendingLineItemsServiceTest {
	private static Set<Id> fulfilmentItemIds;
    private static csdf__Fulfilment_Item__c fulfilmentItemGlobal;

	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
    
        Account[] accs = TestDataSetupBasic.createAccounts(5);   
        Contact[] cons = TestDataSetupBasic.createContacts(5, accs);
        Opportunity o = TestDataSetupTargetables.createOpportunity(accs[0], cons[0]);
        insert o;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.SO_Lines_Number_lines_RI__c = 0;
        salesOrder.SO_Lines_Ad_Server_Items__c = 2;
        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_PRICE_RECALCULATION_REQUIRED;
        salesOrder.csmso__Opportunity__c = o.id;
        salesOrder.csmso__Advertiser__c = accs[0].Id;
        salesOrder.Bill_To_Account__c = accs[1].Id;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Purchase_Order_Number__c = null;
        salesOrder.IO_Template__c = 'Spotify';
        salesOrder.csmso__Booking_Contact__c = cons[0].Id;
        salesOrder.SO_Lines_All_Valid__c = false;
        salesOrder.SO_Lines_Number_of_lines__c = 1;
        salesOrder.SO_Lines_Ad_Server_Items__c = 2;
        salesOrder.SO_Lines_Ad_Server_Inventory_Avail_Ov__c = 10;
        insert salesOrder;

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
        
        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);
        
        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,new List<csmso__Sales_Order__c>{salesOrder});
        
        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{salesOrder},accs);

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(-4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        fulfilmentItem[0].csdf__Ad_Server_Id__c = '5059782654';
        fulfilmentItem[0].Contending_Items_Extended__c = '{"lineItemId":null,"orderId":null,"unitType":{"value":"IMPRESSIONS"},"availableUnits":271298,"deliveredUnits":0,"matchedUnits":283726,"possibleUnits":271298,"reservedUnits":1000000,"breakdowns":null,"targetingCriteriaBreakdowns":null,"contendingLineItems":[{"lineItemId":5059782654,"contendingImpressions":241},{"lineItemId":5060208656,"contendingImpressions":723},{"lineItemId":5060216546,"contendingImpressions":239},{"lineItemId":5023651198,"contendingImpressions":1146},{"lineItemId":4719898793,"contendingImpressions":1037},{"lineItemId":5043532039,"contendingImpressions":1148},{"lineItemId":5043532204,"contendingImpressions":1123},{"lineItemId":5044753196,"contendingImpressions":1114},{"lineItemId":5044753340,"contendingImpressions":1108},{"lineItemId":5034145673,"contendingImpressions":1148},{"lineItemId":5024327732,"contendingImpressions":1173},{"lineItemId":5043812138,"contendingImpressions":1119},{"lineItemId":5044356405,"contendingImpressions":1102}],"alternativeUnitTypeForecasts":[{"unitType":{"value":"IMPRESSIONS"},"matchedUnits":283726,"availableUnits":271305,"possibleUnits":271298},{"unitType":{"value":"VIEWABLE_IMPRESSIONS"},"matchedUnits":283726,"availableUnits":271305,"possibleUnits":271298}],"demographicBreakdowns":null,"totalContendingUnits":13}';
        update fulfilmentItem;

        fulfilmentItemGlobal = fulfilmentItem[0];

        fulfilmentItemIds = new Set<Id>();
        for(csdf__Fulfilment_Item__c fi : fulfilmentItem) {
        	fulfilmentItemIds.add(fi.Id);
        }

        List<CS_Sales_Order_Schedule__c> salesOrderSchedules = new List<CS_Sales_Order_Schedule__c>();
        
        CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
        sos.sales_order__c = salesOrder.id;
        insert sOs;
        
        CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
        bScheduleHeader.CS_Sales_Order_Schedule__c = sOs.id;
        bScheduleHeader.Under_IFC__c = true;
        insert bScheduleHeader;

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = salesOrder.id;
            pConfig.Flight_Begin__c = Date.today();
        }
        update prodConfigs;

        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c 
                                                    FROM cscfga__Product_Configuration__c 
                                                    LIMIT 1][0];
        
        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = pc.id;
        bSchedule.Status__c = 'Locked';
        bSchedule.Sales_Order__c = pc.Sales_Order__c;
        bSchedule.DFP_Actuals__c = 100;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.Billing_Period_Start_Date__c = Date.Today().addDays(-4);
        bschedule.billing_schedule__c=bScheduleHeader.id;
        insert bSchedule;
	}

	@isTest 
    static void testContendingLineItemsService() {
    	createTestData();

    	Test.startTest();
    	CS_ContendingLineItemsService.getContendingItems(fulfilmentItemIds);
    	Test.stopTest();
    }

    @isTest 
    static void testContendingLineItem() {
        createTestData();

        Test.startTest();
        CS_ContendingLineItemsService.ContendingLineItem contendingLineItem = new CS_ContendingLineItemsService.ContendingLineItem();
        contendingLineItem.setValues(fulfilmentItemGlobal);
        contendingLineItem.contendingImpressions = 2;
        Test.stopTest();
    }

    @isTest 
    static void testContendingLineItems() {
        createTestData();

        Test.startTest();
        CS_ContendingLineItemsService.ContendingLineItems contendingLineItem = new CS_ContendingLineItemsService.ContendingLineItems();
        contendingLineItem.totalContendingUnits = 2;
        Test.stopTest();
    }
}