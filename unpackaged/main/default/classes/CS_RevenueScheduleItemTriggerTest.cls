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
public class CS_RevenueScheduleItemTriggerTest {
	@isTest
	private static void CS_RevenueScheduleItemTriggerTest(){

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

		//CS Revenue Schedule
        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
		rScheduleHeader.CS_Sales_Order_Schedule__c = salesOrderSchedule.id;
		insert rScheduleHeader;

		//CS Revenue Schedule Item
        CS_Revenue_Schedule_Item__c rSchedule = new CS_Revenue_Schedule_Item__c();
		rSchedule.Sales_Order__c = prodConfigs[0].Sales_Order__c;
		rSchedule.Product_Configuration__c = prodConfigs[0].id;
		rSchedule.Status__c = 'Open';
		rSchedule.Rev_Rec_Period_Start_Date__c = Date.Today().addDays(-4);
        rSchedule.Rev_Rec_Period_End_Date__c = Date.Today().addDays(4);
        rSchedule.Revenue_Schedule__c = rScheduleHeader.Id;
        rSchedule.Rev_Rec_Date__c = Date.Today().addDays(-4);
		insert rSchedule;

		Test.startTest();
		update rSchedule;
		Test.stopTest();
	}

}