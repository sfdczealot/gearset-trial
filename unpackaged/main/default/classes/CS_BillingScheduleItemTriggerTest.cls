/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for CS_RevenueScheduleItemTriggerTest
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v0.1            ivan.ravnjak@cloudsensesolutions.com
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
@isTest
public class CS_BillingScheduleItemTriggerTest {
	@isTest
	private static void CS_BillingScheduleItemTriggerTest(){

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
		List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1,Acc,opp);

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
		
		//Attribute definition Creation.
		List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);
		
		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,salesorders);
		
		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,prodDef);

		// Billing
		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
        salesOrderSchedule.sales_order__c = salesOrders[0].id;
        insert salesOrderSchedule;

		//CS Biling Schedule
        CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
        bScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.id;
        bScheduleHeader.Under_IFC__c = true;
        insert bScheduleHeader;

		//CS Biling Schedule Item
        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = prodConfigs[0].id;
        bSchedule.Status__c = 'Locked';
        bSchedule.Sales_Order__c = prodConfigs[0].Sales_Order__c;
        bSchedule.DFP_Actuals__c = 100;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.DFP_Order_Line_ID__c = salesOrders[0].Id;
        bSchedule.Billing_Period_Start_Date__c = Date.Today().addDays(-4);
        bSchedule.Billing_Period_End_Date__c = Date.Today().addDays(4);
        bschedule.billing_schedule__c = bScheduleHeader.id;
        bschedule.DFP_Order_Line_ID__c = 'External ID Test 123';
        bschedule.X3rd_Party_Ad_Server__c = 'Test Server Name';
        bschedule.Billing_Date__c = Date.Today().addDays(-4);
        insert bSchedule;

		Test.startTest();
		update bSchedule;
		Test.stopTest();
	}

}