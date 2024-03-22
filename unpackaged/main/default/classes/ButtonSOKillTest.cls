@IsTest
private class ButtonSOKillTest {
    public static string accRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();

	@IsTest
	static void testButtonSOKill() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		Account testAccount = TestDataSetupSO.createAccount();
        testAccount.RecordTypeId = accRecTypeID;
		insert testAccount;

		Contact testContact = TestDataSetupSO.createContact(testAccount);
		insert testContact;

		Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
		insert testOpportunity;

		csmso__Sales_Order__c testSO = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
		insert testSO;

		testSO.SO_Lines_Ad_Server_Items__c = 0;
		testSO.Last_Date_Booked__c = Date.newInstance(2020, 1, 17);
		update testSO;

		Test.startTest();
		ButtonSOKill button = new ButtonSOKill();
		button.performAction(testSO.Id);
		testSO.Reason_for_Cancellation__c = 'Duration';
		update testSO;

		button.performAction(testSO.Id);
		testSO.SO_Lines_Ad_Server_Items__c = 1;
		testSO.Last_Date_Booked__c = null;
		update testSO;

		button.performAction(testSO.Id);
		testSO.Last_Date_Booked__c = Date.newInstance(2020, 1, 17);
		update testSO;

		button.performAction(testSO.Id);
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOKill2() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		Account testAccount = TestDataSetupSO.createAccount();
        testAccount.RecordTypeId = accRecTypeID;
		insert testAccount;
		Contact testContact = TestDataSetupSO.createContact(testAccount);
		insert testContact;
		Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
		insert testOpportunity;
		csmso__Sales_Order__c testSO = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
		testSO.SO_Lines_Number_of_lines__c = 1;
		testSO.SO_Lines_Ad_Server_Items__c = 0;
		testSO.Last_Date_Booked__c = Date.today().addDays(-2);
		testSO.Primary_Sales_Order__c = true;
		insert testSO;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				testSO
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
		sOs.Sales_Order__c = testSO.Id;
		insert sOs;

		CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
		bScheduleHeader.CS_Sales_Order_Schedule__c = sOs.Id;
		bScheduleHeader.Under_IFC__c = true;
		insert bScheduleHeader;

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = testSO.Id;
			pConfig.Flight_Begin__c = Date.today().addDays(2);
			pConfig.cscfga__Configuration_Status__c = 'Valid';
			pConfig.Served_By__c = 'DFP';
			pConfig.Fulfilment_Item_Status__c = 'Ready';
		}
		update prodConfigs;

		cscfga__Product_Configuration__c pc = [
				SELECT Id, Sales_Order__c
				FROM cscfga__Product_Configuration__c
				LIMIT 1
		][0];

		CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
		bschedule.Product_Configuration__c = pc.Id;
		bschedule.Status__c = CS_Constants.STATUS_OPEN;
		bschedule.Sales_Order__c = pc.Sales_Order__c;
		bschedule.DFP_Actuals__c = 100;
		bschedule.Net_Rate__c = 100.0;
		bschedule.Billing_Period_Start_Date__c = Date.today().addDays(-4);
		bschedule.Billing_Schedule__c = bScheduleHeader.Id;
		insert bschedule;

		//CS Revenue Schedule
		CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
		rScheduleHeader.CS_Sales_Order_Schedule__c = sOs.Id;
		insert rScheduleHeader;

		//CS Revenue Schedule Item
		CS_Revenue_Schedule_Item__c rSchedule = new CS_Revenue_Schedule_Item__c();
		rSchedule.Sales_Order__c = pc.Sales_Order__c;
		rSchedule.Product_Configuration__c = pc.Id;
		rSchedule.Status__c = CS_Constants.STATUS_OPEN;
		rSchedule.Rev_Rec_Period_Start_Date__c = Date.today().addDays(-4);
		rSchedule.Rev_Rec_Period_End_Date__c = Date.today().addDays(4);
		rSchedule.Revenue_Schedule__c = rScheduleHeader.Id;
		insert rSchedule;

		testSO.Last_Date_Booked__c = Date.newInstance(2020, 1, 17);
		update testSO;

		Test.startTest();
		ButtonSOKill button = new ButtonSOKill();
		button.performAction(testSO.Id);
		testSO.Reason_for_Cancellation__c = 'Duration';
		update testSO;

		button.performAction(testSO.Id);
		testSO.Last_Date_Booked__c = null;
		update testSO;

		button.performAction(testSO.Id);
		testSO.Last_Date_Booked__c = Date.newInstance(2020, 1, 17);
		update testSO;

		button.performAction(testSO.Id);
		Test.stopTest();
	}

	@IsTest
	static void testButtonSOValidation() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		Account testAccount = TestDataSetupSO.createAccount();
        testAccount.RecordTypeId = accRecTypeID;
		insert testAccount;

		Contact testContact = TestDataSetupSO.createContact(testAccount);
		insert testContact;

		Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
		insert testOpportunity;

		csmso__Sales_Order__c testSO = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
		testSO.SO_Lines_Number_of_lines__c = 1;
		testSO.Last_Date_Booked__c = Date.today().addDays(-2);
		testSO.Primary_Sales_Order__c = true;
		insert testSO;

		//Product Definition Creation.
		List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

		//Product Baskets  Creation.
		List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
				testSO
		});

		//Product Configs creation.
		List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

		CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
		sOs.Sales_Order__c = testSO.Id;
		insert sOs;

		CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
		bScheduleHeader.CS_Sales_Order_Schedule__c = sOs.Id;
		bScheduleHeader.Under_IFC__c = true;
		insert bScheduleHeader;

		for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
			pConfig.Sales_Order__c = testSO.Id;
			pConfig.Flight_Begin__c = Date.today().addDays(2);
			pConfig.cscfga__Configuration_Status__c = 'Valid';
			pConfig.Served_By__c = 'DFP';
			pConfig.Fulfilment_Item_Status__c = 'Ready';
		}
		update prodConfigs;

		cscfga__Product_Configuration__c pc = [
				SELECT Id, Sales_Order__c
				FROM cscfga__Product_Configuration__c
				LIMIT 1
		][0];

		CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
		bschedule.Product_Configuration__c = pc.Id;
		bschedule.Status__c = 'Locked';
		bschedule.Sales_Order__c = pc.Sales_Order__c;
		bschedule.DFP_Actuals__c = 100;
		bschedule.Net_Rate__c = 100.0;
		bschedule.Billing_Period_Start_Date__c = Date.today().addDays(-4);
		bschedule.Billing_Schedule__c = bScheduleHeader.Id;
		insert bschedule;

		testSO.SO_Lines_Ad_Server_Items__c = 0;
		testSO.Last_Date_Booked__c = Date.newInstance(2020, 1, 17);
		update testSO;

		Test.startTest();
		ButtonSOKill button = new ButtonSOKill();
		button.performAction(testSO.Id);
		testSO.Reason_for_Cancellation__c = 'Duration';
		update testSO;

		button.performAction(testSO.Id);
		testSO.SO_Lines_Ad_Server_Items__c = 1;
		testSO.Last_Date_Booked__c = null;
		update testSO;

		button.performAction(testSO.Id);
		testSO.Last_Date_Booked__c = Date.newInstance(2020, 1, 17);
		update testSO;

		button.performAction(testSO.Id);
		Test.stopTest();
	}
}