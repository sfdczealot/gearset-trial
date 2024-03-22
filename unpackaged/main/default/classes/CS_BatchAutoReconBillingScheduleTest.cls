/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Test Class for CS_BatchAutoReconBillingSchedule
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/

@isTest
public class CS_BatchAutoReconBillingScheduleTest {
    
    
	/**
	 * Tests getQueryMethod with Bill Runs
	 */
	@IsTest
	private static void test_getQueryString() {
	    
	   	//Account Creation.	   
		List<Account> acc = TestDataSetupSO.createAccounts(1);
	   
		//Contact Creation.
		List<Contact> con = TestDataSetupSO.createContacts(1, acc);
	   
		//Opportunity Creation.
		List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = salesOrder.Id;
		salesOrderSchedule.CurrencyIsoCode = 'USD';
		insert salesOrderSchedule;

		CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
		billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		billingSchedule.CurrencyIsoCode = 'USD';
		billingSchedule.Sales_Order__c = billingSchedule.Id;
		insert billingSchedule;
		
		CS_th_Worker.create();
		String INITIAL_QUERY_TEMPLATE = 'SELECT Id FROM csmso__Sales_Order__c WHERE Id IN ' +
			   		   					   '(SELECT Sales_Order__c FROM CS_Billing_Schedule_Item__c ' +
			   		   					   'WHERE Status__c = {0} AND ({1}) AND Manual_Hold__c = false)';
			   		   					   
	    String QUERY_TEMPLATE = 'SELECT Id, Name, Status__c, Billing_Calendar__c, Billing_Date__c, Valid_for_Auto_Reconciliation__c ' +
			   		   					   'FROM CS_Billing_Schedule_Item__c ' +
			   		   					   'WHERE Status__c = {0} AND ({1}) AND Manual_Hold__c = false';
			   		   					   
		List<CS_Billing_Schedule_Item__c> billingSchedules = new List<CS_Billing_Schedule_Item__c>();
		for(Integer i = 0; i < 5; i++) {
			// Billing Schedules with Manual Hold = false, Valid_for_Auto_Reconciliation__c = true
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-10), false, false));
		}
		for(Integer i = 0; i < 5; i++) {
	    	billingSchedules[i].Billing_Schedule__c = billingSchedule.id;
		}
		insert billingSchedules;
		
		CS_th_BillRun.create(CS_const_BillRun.Status_LockingBillSchedules, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(-1));

		Test.startTest();
		
		CS_BatchAutoReconBillingSchedule batch = new CS_BatchAutoReconBillingSchedule();
		batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
		String query = batch.getQueryString(QUERY_TEMPLATE,'');
		
		Test.stopTest();
    
		System.assert(String.isNotBlank(query));
	}

	/**
	 * Tests getQueryMethod without Bill Runs
	 */	
	@IsTest
	private static void test_getQueryStringNoBillRun() {
	    
	    //Account Creation.	   
		List<Account> acc = TestDataSetupSO.createAccounts(1);
	   
		//Contact Creation.
		List<Contact> con = TestDataSetupSO.createContacts(1, acc);
	   
		//Opportunity Creation.
		List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = salesOrder.Id;
		salesOrderSchedule.CurrencyIsoCode = 'USD';
		insert salesOrderSchedule;

		CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
		billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		billingSchedule.CurrencyIsoCode = 'USD';
		billingSchedule.Sales_Order__c = billingSchedule.Id;
		insert billingSchedule;
		
		CS_th_Worker.create();
		String INITIAL_QUERY_TEMPLATE = 'SELECT Id FROM csmso__Sales_Order__c WHERE Id IN ' +
			   		   					   '(SELECT Sales_Order__c FROM CS_Billing_Schedule_Item__c ' +
			   		   					   'WHERE Status__c = {0} AND ({1}) AND Manual_Hold__c = false)';
			   		   					   
	    String QUERY_TEMPLATE = 'SELECT Id, Name, Status__c, Billing_Calendar__c, Billing_Date__c, Valid_for_Auto_Reconciliation__c ' +
			   		   					   'FROM CS_Billing_Schedule_Item__c ' +
			   		   					   'WHERE Status__c = {0} AND ({1}) AND Manual_Hold__c = false';
			   		   					   
		List<CS_Billing_Schedule_Item__c> billingSchedules = new List<CS_Billing_Schedule_Item__c>();
		for(Integer i = 0; i < 5; i++) {
			// Billing Schedules with Manual Hold = false, Valid_for_Auto_Reconciliation__c = true
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-10), false, false));
		}
		
	    for(Integer i = 0; i < 5; i++) {
	    	billingSchedules[i].Billing_Schedule__c = billingSchedule.id;
		}
		
		insert billingSchedules;

		Test.startTest();
		
		CS_BatchAutoReconBillingSchedule batch = new CS_BatchAutoReconBillingSchedule();
		batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
		String query = batch.getQueryString(QUERY_TEMPLATE,'');
		
		Test.stopTest();

		System.assert(String.isNotBlank(query));
		System.assert(!query.contains('Billing_Date__c <= '));
	}

	/**
	 * Tests onStart method
	 */	
	@IsTest
	private static void test_onStart() {
	    
	    //Account Creation.	   
		List<Account> acc = TestDataSetupSO.createAccounts(1);
	   
		//Contact Creation.
		List<Contact> con = TestDataSetupSO.createContacts(1, acc);
	   
		//Opportunity Creation.
		List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = salesOrder.Id;
		salesOrderSchedule.CurrencyIsoCode = 'USD';
		insert salesOrderSchedule;

		CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
		billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		billingSchedule.CurrencyIsoCode = 'USD';
		billingSchedule.Sales_Order__c = billingSchedule.Id;
		insert billingSchedule;
		
		CS_th_Worker.create();
		
		List<CS_Billing_Schedule_Item__c> billingSchedules = new List<CS_Billing_Schedule_Item__c>();
		for(Integer i = 0; i < 5; i++) {
			// Billing Schedules with Manual Hold = false, Valid_for_Auto_Reconciliation__c = true
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-10), false, false));
		}
		
		for(Integer i = 0; i < 5; i++) {
	    	billingSchedules[i].Billing_Schedule__c = billingSchedule.id;
		}
		
		insert billingSchedules;
		
		CS_th_BillRun.create(CS_const_BillRun.Status_LockingBillSchedules, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(-1));

		Test.startTest();
		
		CS_BatchAutoReconBillingSchedule batch = new CS_BatchAutoReconBillingSchedule();
		batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
		Database.QueryLocator query = batch.onStart();
		
		Test.stopTest();

		System.assert(String.isNotBlank(query.getQuery()));
		System.assert(query.getQuery().contains('Id FROM AsyncApexJob'));
	}

	/**
	 * Tests onFinish method
	 */		
	@IsTest
	private static void test_onFinish() {
	    
	    //Account Creation.	   
		List<Account> acc = TestDataSetupSO.createAccounts(1);
	   
		//Contact Creation.
		List<Contact> con = TestDataSetupSO.createContacts(1, acc);
	   
		//Opportunity Creation.
		List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = salesOrder.Id;
		salesOrderSchedule.CurrencyIsoCode = 'USD';
		insert salesOrderSchedule;

		CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
		billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		billingSchedule.CurrencyIsoCode = 'USD';
		billingSchedule.Sales_Order__c = billingSchedule.Id;
		insert billingSchedule;
		
		CS_th_Worker.create();
		
		List<CS_Billing_Schedule_Item__c> billingSchedules = new List<CS_Billing_Schedule_Item__c>();
		for(Integer i = 0; i < 5; i++) {
			// Billing Schedules with Manual Hold = false, Valid_for_Auto_Reconciliation__c = true
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-10), false, false));
		}
		
		for(Integer i = 0; i < 5; i++) {
	    	billingSchedules[i].Billing_Schedule__c = billingSchedule.id;
		}
		
		
		insert billingSchedules;
		
		Bill_Run__c billRun = CS_th_BillRun.create(CS_const_BillRun.Status_LockingBillSchedules, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(-1));
		billRun.Auto_Reconciliation_Offset__c = '0';
		update billRun;

		Test.startTest();
		
		CS_BatchAutoReconBillingSchedule batch = new CS_BatchAutoReconBillingSchedule();
		batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
		batch.onFinish();
		
		Test.stopTest();

		List<Bill_Run__c> billRuns = [SELECT Id, Status__c FROM Bill_Run__c WHERE Status__c = :CS_const_BillRun.Status_AutoReconciliating];
		System.assertEquals(1, billRuns.size());
	}
	
	/**
	 * Tests doWork method
	 */		
	@IsTest
	private static void test_doWork() {
	    
	    //Account Creation.	   
		List<Account> acc = TestDataSetupSO.createAccounts(1);
	   
		//Contact Creation.
		List<Contact> con = TestDataSetupSO.createContacts(1, acc);
	   
		//Opportunity Creation.
		List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = salesOrder.Id;
		salesOrderSchedule.CurrencyIsoCode = 'USD';
		insert salesOrderSchedule;

		CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
		billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		billingSchedule.CurrencyIsoCode = 'USD';
		billingSchedule.Sales_Order__c = billingSchedule.Id;
		insert billingSchedule;
		
		CS_th_Worker.create();
		
		List<CS_Billing_Schedule_Item__c> billingSchedules = new List<CS_Billing_Schedule_Item__c>();
		for(Integer i = 0; i < 5; i++) {
			// Billing Schedules with Manual Hold = false, Valid_for_Auto_Reconciliation__c = true
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-10), false, false));
			// Billing Schedules with Manual Hold = true, Valid_for_Auto_Reconciliation__c = false
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-10), true, false));
		}
		
		for(Integer i = 0; i < billingSchedules.size(); i++) {
	    	billingSchedules[i].Billing_Schedule__c = billingSchedule.id;
		}
		
		
		insert billingSchedules;

		billingSchedules = [SELECT 
								Id, Name, Status__c, Billing_Calendar__c, 
								Billing_Date__c, Valid_for_Auto_Reconciliation__c 
							FROM 
								CS_Billing_Schedule_Item__c];
		
		CS_th_BillRun.create(CS_const_BillRun.Status_LockingBillSchedules, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(-1));

		Test.startTest();
		
		CS_BatchAutoReconBillingSchedule batch = new CS_BatchAutoReconBillingSchedule();
		batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
		batch.doWork(billingSchedules);
		
		Test.stopTest();

		List<CS_Billing_Schedule_Item__c> billSchedulesPending = [SELECT Id, Status__c, Valid_for_Auto_Reconciliation__c, Manual_Hold__c FROM CS_Billing_Schedule_Item__c WHERE Status__c = :CS_const_BillingScheduleItem.Status_Pending];
		System.assertEquals(0, billSchedulesPending.size());

		List<CS_Billing_Schedule_Item__c> billSchedulesReady = [SELECT Id, Status__c FROM CS_Billing_Schedule_Item__c WHERE Status__c = :CS_const_BillingScheduleItem.Status_Ready];
		System.assertEquals(0, billSchedulesReady.size());
	}
	
	/**
	 * Tests execute method
	 */		
	@IsTest
	private static void test_execute() {
	    
	    //Account Creation.	   
		List<Account> acc = TestDataSetupSO.createAccounts(1);
	   
		//Contact Creation.
		List<Contact> con = TestDataSetupSO.createContacts(1, acc);
	   
		//Opportunity Creation.
		List<Opportunity> opp = TestDataSetupSO.createOpportunities(1, acc, con);

		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc[0], opp[0]);

		CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = salesOrder.Id;
		salesOrderSchedule.CurrencyIsoCode = 'USD';
		insert salesOrderSchedule;

		CS_Billing_Schedule__c billingSchedule = new CS_Billing_Schedule__c();
		billingSchedule.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		billingSchedule.CurrencyIsoCode = 'USD';
		billingSchedule.Sales_Order__c = billingSchedule.Id;
		insert billingSchedule;
		
		CS_th_Worker.create();
		
		List<CS_Billing_Schedule_Item__c> billingSchedules = new List<CS_Billing_Schedule_Item__c>();
		for(Integer i = 0; i < 50; i++) {
			// Billing Schedules with Manual Hold = false, Valid_for_Auto_Reconciliation__c = true
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-10), false, false));
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(10), false, false));
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Ready,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-15), false, false));
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-2), false, false));
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Broadcast,
								 Date.today().addDays(-15), false, false));

			// Billing Schedules with Manual Hold = true, Valid_for_Auto_Reconciliation__c = false
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-10), true, false));
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(10), true, false));
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Ready,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-15), true, false));
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Standard,
								 Date.today().addDays(-2), true, false));
			billingSchedules.add(CS_th_BillingScheduleItem.create(CS_const_BillingScheduleItem.Status_Locked,
								 CS_const_BillingScheduleItem.BillingCalendar_Broadcast,
								 Date.today().addDays(-15), true, false));
		}
		
		for(Integer i = 0; i < billingSchedules.size(); i++) {
	    	billingSchedules[i].Billing_Schedule__c = billingSchedule.id;
		}
		insert billingSchedules;

		billingSchedules = [SELECT 
								Id, Name, Status__c, Billing_Calendar__c, 
								Billing_Date__c, Valid_for_Auto_Reconciliation__c 
							FROM 
								CS_Billing_Schedule_Item__c];
		
		List<Bill_Run__c> billRuns = new List<Bill_Run__c>{
			CS_th_BillRun.create(CS_const_BillRun.Status_LockingBillSchedules, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(-12), false),
			CS_th_BillRun.create(CS_const_BillRun.Status_LockingBillSchedules, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(-5), false),
			CS_th_BillRun.create(CS_const_BillRun.Status_LockingBillSchedules, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(15), false),
			CS_th_BillRun.create(CS_const_BillRun.Status_AutoReconciliating, CS_const_BillRun.CalendarType_Standard, Date.today().addDays(-2), false),
			CS_th_BillRun.create(CS_const_BillRun.Status_AutoReconciliating, CS_const_BillRun.CalendarType_Broadcast, Date.today().addDays(25), false)
		};
		insert billRuns;

		Test.startTest();
		
		CS_BatchAutoReconBillingSchedule batch = new CS_BatchAutoReconBillingSchedule();
		batch.salesOrderScheduleBatches = new List<Sales_Order_Schedule_Batch__mdt>();
		batch.execute();
		
		Test.stopTest();

		List<CS_Billing_Schedule_Item__c> billSchedulesReady = [SELECT Id, Status__c FROM CS_Billing_Schedule_Item__c WHERE Status__c = :CS_const_BillingScheduleItem.Status_Ready];
		System.assertEquals(100, billSchedulesReady.size());

		List<CS_Billing_Schedule_Item__c> billSchedulesPending = [SELECT Id, Status__c FROM CS_Billing_Schedule_Item__c WHERE Status__c = :CS_const_BillingScheduleItem.Status_Pending];
		System.assertEquals(0, billSchedulesPending.size());
		
		List<Bill_Run__c> billRunsLocked = [SELECT Id, Status__c FROM Bill_Run__c WHERE Status__c = :CS_const_BillRun.Status_AutoReconciliating];
		System.assertEquals(4, billRunsLocked.size());
	}
}