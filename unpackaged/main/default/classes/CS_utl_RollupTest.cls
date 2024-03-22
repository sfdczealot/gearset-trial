/**
 * Created by tvrtko.matosevic on 15/02/2019.
 */

@IsTest
private class CS_utl_RollupTest {
	public static cscfga__Product_Configuration__c config;
	public static csmso__Sales_Order__c salesOrder;

	static void setupData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account account = TestDataSetupSO.createAccount();
		insert account;

		Contact contact = TestDataSetupSO.createContact(account);
		insert contact;

		Opportunity opportunity = TestDataSetupSO.createOpportunity(account, contact);
		insert opportunity;

		salesOrder = TestDataSetupSO.createSalesOrder(account, opportunity);
		insert salesOrder;

		cscfga__Product_Basket__c basket = new cscfga__Product_Basket__c();
		basket.csmso__Sales_Order__c = salesOrder.Id;
		insert basket;

		// create geo targeting
		csdf__Geo_Item__c geoItem = new csdf__Geo_Item__c();
		geoItem.Name = 'United States';
		geoItem.csdf__Ad_Server_Id__c = '2840';
		insert geoItem;

		// create Business Unit (csmso__Business_Unit__c)
		csmso__Business_Unit__c businessUnit = new csmso__Business_Unit__c();
		businessUnit.Name = 'Test Business Unit';
		businessUnit.csmso__Sales_Ledger_Code__c = 'Test Sales Ledger Code';
		businessUnit.Unique_Id__c = 'Test Unique Id Business Unit';
		insert businessUnit;

		Booking_Time_Zone__c bookingTimeZone = new Booking_Time_Zone__c();
		bookingTimeZone.Booking_Time_Zone_Country__c = 'Europe/London';
		bookingTimeZone.Time_Zone_Code__c = 'GMT+01:00';
		insert bookingTimeZone;

		csmso__Product_Node__c market = new csmso__Product_Node__c();
		market.Name = 'Test Market';
		market.csmso__Description__c = 'Test Market Description';
		market.csmso__Business_Unit__c = businessUnit.Id;
		market.CurrencyIsoCode = 'USD';
		market.Unique_Id__c = 'Test Market Unique Id';
		market.csmso__Media_Types__c = 'Desktop';
		market.Geo_Targeting__c = geoItem.Id;
		market.Sponsorship_Booking_Timezone__c = bookingTimeZone.Id;
		market.NAA_supported_currency__c = 'SGD';
		insert market;

		config = TestDataSetupSO.createproductConfigAndDef('test');
		config.Sales_Order__c = salesOrder.Id;
		config.cscfga__Product_Basket__c = basket.Id;
		config.Price__c = 100;
		config.Total_Quantity__c = 1;
		config.Sales_Discount_Percentage__c = 10;
		config.Rate_Card__c = 100;
		config.Calculation_Type__c = 'Net';
		config.Agency_Commission_Percentage__c = 10;
		config.Served_By__c = 'DFP';
		config.Inventory_Available__c = 'Yes';
		config.Flight_Begin__c = Date.today().addMonths(-1);
		config.Flight_End__c = Date.today().addMonths(1);
		config.FLAG_Package_Item__c = 'Yes';
		config.csmso__Availability_Check_Status__c = 'From Flighting';
		config.Overbook__c = true;
		config.Configuration_Status_Tmp__c = 'Valid';
		config.FLAG_Price_Recalculated__c = 'Yes';
		config.Product_Category__c = 'Production';
		config.Line_Item_Category__c = 'Cost of Revenue';
		config.Net_Total_before_Cost_Adjustment__c = 100;
		config.Cost_Adjustment__c = 'Added Value';
		config.Line_Item_Category__c = 'House';
		config.Reserve_Inventory__c = false;
		config.Market__c = market.Id;
		update config;
	}

	@IsTest
	static void testRollUp() {
		setupData();

		List<CS_utl_Rollup.RollupDefinition> CONFIG_TO_SALES_ORDER_TOTALS = new List<CS_utl_Rollup.RollupDefinition>{
				new CS_utl_Rollup.RollupDefinition('Price__c', 'Total_Price_Calculated__c', CS_utl_Rollup.Operation.SUM, null, 0),
				new CS_utl_Rollup.RollupDefinition('Gross_Total__c', 'SO_Lines_Gross_Total__c', CS_utl_Rollup.Operation.SUM, null, 0),
				new CS_utl_Rollup.RollupDefinition('Sales_Discount_Amount__c', 'SO_Lines_Total_Discount__c', CS_utl_Rollup.Operation.SUM, null, 0),
				new CS_utl_Rollup.RollupDefinition('Net_Total_Before_IO_Volume_Discount__c', 'Total_Before_IO_Volume_Discount__c', CS_utl_Rollup.Operation.SUM, null, 0),
				new CS_utl_Rollup.RollupDefinition('Id', 'SO_Lines_Number_of_lines__c', CS_utl_Rollup.Operation.COUNT, null, 0),
				new CS_utl_Rollup.RollupDefinition('Ad_Server_Item__c', 'SO_Lines_Ad_Server_Items__c', CS_utl_Rollup.Operation.COUNT, true, 0),
				new CS_utl_Rollup.RollupDefinition('Ad_Server_Inventory_Available__c', 'SO_Lines_Ad_Server_Inventory_Avail_Ov__c', CS_utl_Rollup.Operation.COUNT, true, 0),
				new CS_utl_Rollup.RollupDefinition('Flight_Begin__c', 'From_Calculated__c', CS_utl_Rollup.Operation.MIN, null, null),
				new CS_utl_Rollup.RollupDefinition('Flight_End__c', 'To_Calculated__c', CS_utl_Rollup.Operation.MAX, null, null),
				new CS_utl_Rollup.RollupDefinition('Maximum_IO_Volume_Discount_Range__c', 'Maximum_IO_Volume_Discount_Range__c', CS_utl_Rollup.Operation.MAX, null, 0),
				new CS_utl_Rollup.RollupDefinition('csmso__Availability_Check_Status__c', 'Flighting_Pending_Check_Avail__c', CS_utl_Rollup.Operation.LOGICAL_OR, 'From Flighting', false),
				new CS_utl_Rollup.RollupDefinition('Configuration_Status_Tmp__c', 'SO_Lines_All_Valid__c', CS_utl_Rollup.Operation.LOGICAL_AND, 'Valid', true),
				new CS_utl_Rollup.RollupDefinition('FLAG_Price_Recalculated__c', 'SO_Lines_Price_Recalculated__c', CS_utl_Rollup.Operation.COUNT, 'Yes', 0),
				new CS_utl_Rollup.RollupDefinition('Total_ProdCost__c', 'SO_Lines_Total_ProdCost__c', CS_utl_Rollup.Operation.SUM, null, 0),
				new CS_utl_Rollup.RollupDefinition('Total_CoR__c', 'SO_Lines_Total_CoR__c', CS_utl_Rollup.Operation.SUM, null, 0),
				new CS_utl_Rollup.RollupDefinition('Cost_Adjustment_Applied__c', 'SO_Lines_Number_of_lines_CA__c', CS_utl_Rollup.Operation.COUNT, true, 0),
				new CS_utl_Rollup.RollupDefinition('Line_Item_Category__c', 'SO_Lines_Number_of_lines_CoR__c', CS_utl_Rollup.Operation.COUNT, 'Cost of Revenue', 0),
				new CS_utl_Rollup.RollupDefinition('Market__c', 'Total_Markets__c', CS_utl_Rollup.Operation.COUNT_DISTINCT, null, new Set<String>())
		};

		List<CS_utl_Rollup.RollupDefinition> rollupDefinitions = CS_utl_Rollup.init(CONFIG_TO_SALES_ORDER_TOTALS);
		for (CS_utl_Rollup.RollupDefinition definition : rollupDefinitions) {
			System.debug('definition => ' + definition);
			for (cscfga__Product_Configuration__c config : new List<cscfga__Product_Configuration__c>{
					config
			}) {
				System.debug('config => ' + config);
				definition.calculate(config);
			}
		}

		for (CS_utl_Rollup.RollupDefinition definition : rollupDefinitions) {
			salesOrder.put(definition.toField, definition.getValue());
		}

		System.assertEquals(100, salesOrder.Total_Price_Calculated__c);
		System.assertEquals(0, salesOrder.SO_Lines_Gross_Total__c);
		System.assertEquals(0, salesOrder.SO_Lines_Total_Discount__c);
		System.assertEquals(0, salesOrder.Total_Before_IO_Volume_Discount__c);
		System.assertEquals(1, salesOrder.SO_Lines_Number_of_lines__c);
		System.assertEquals(0, salesOrder.SO_Lines_Ad_Server_Items__c);
		System.assertEquals(0, salesOrder.SO_Lines_Ad_Server_Inventory_Avail_Ov__c);
		System.assertEquals(0, salesOrder.Maximum_IO_Volume_Discount_Range__c);
		System.assertEquals(true, salesOrder.Flighting_Pending_Check_Avail__c);
		System.assertEquals(true, salesOrder.SO_Lines_All_Valid__c);
		System.assertEquals(0, salesOrder.SO_Lines_Total_ProdCost__c);
		System.assertEquals(0, salesOrder.SO_Lines_Total_CoR__c);
		System.assertEquals(0, salesOrder.SO_Lines_Number_of_lines_CA__c);
		System.assertEquals(0, salesOrder.SO_Lines_Number_of_lines_CoR__c);
		System.assertEquals(1, salesOrder.Total_Markets__c);
		System.assertEquals(1, salesOrder.SO_Lines_Price_Recalculated__c);
	}
}