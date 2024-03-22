public class TestDataSetupBasic {
	/*method to create a test account*/
	public static Account createAccount() {
		insertPGAccountTrigger();

		String randomNumber = String.valueOf(Integer.valueOf((Math.random() * 100)));
		Corporate_Brand_Name__c corporateBrandName = new Corporate_Brand_Name__c();

		List<Corporate_Brand_Name__c> corporateBrandNameList = [SELECT Id FROM Corporate_Brand_Name__c];
		if (corporateBrandNameList.size() > 0) {
			corporateBrandName = corporateBrandNameList[0];
		} else {
			corporateBrandName = new Corporate_Brand_Name__c(Name = 'Test Corporate Brand Name ' + randomNumber,
					Global_Customer_Segment__c = 'Advertiser');
			insert corporateBrandName;
		}

		Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'AD Sales - Commercial');

		Account testAccount = new Account(Name = 'testAccountForSalesOrderSupportTest ' + randomNumber, Website = 'www.cloudsense.com',
				BillingCity = 'City', BillingCountry = 'United States', BillingCountryCode = 'US', BillingPostalCode = '10000',
				BillingState = 'Alabama', BillingStateCode = 'AL', BillingStreet = 'Some Street', Billing_email__c = 'some@some.com',
				Industry = 'Agency', Industry_Tier_2__c = 'Media Agency', Type = 'Advertiser', CurrencyIsoCode = 'EUR',
				Corporate_Brand_Name__c = corporateBrandName.Id, RecordTypeId = recordTypeId);
		return testAccount;
	}

	/*method to create a test contact*/
	public static Contact createContact(Account acc) {
		Contact testContact = new Contact(FirstName = 'test', LastName = 'Con', AccountId = acc.Id,email = 'test@test.com');
		return testContact ;
	}

	/*method to create a test opportunity*/
	public static Opportunity createOpportunity(Account acc, Contact con) {
		Opportunity testOpportunity = new Opportunity(Name = 'testOpportunityForSalesOrderSupportTest' + System.now().getTime(),
				AccountId = acc.Id,
				StageName = 'Prospecting',
				CloseDate = System.today()
		);

		return testOpportunity ;
	}

	public static List<Account> createAccounts(Integer count) {
		insertPGAccountTrigger();

		String randomNumber = String.valueOf(Integer.valueOf((Math.random() * 100)));
		Corporate_Brand_Name__c corporateBrandName = new Corporate_Brand_Name__c();

		List<Corporate_Brand_Name__c> corporateBrandNameList = [SELECT Id FROM Corporate_Brand_Name__c];
		if (corporateBrandNameList.size() > 0) {
			corporateBrandName = corporateBrandNameList[0];
		} else {
			corporateBrandName = new Corporate_Brand_Name__c(Name = 'Test Corporate Brand Name ' + randomNumber,
					Global_Customer_Segment__c = 'Advertiser');
			insert corporateBrandName;
		}

		Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'AD Sales - Commercial');

		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < count; i++) {
			Account acc = new Account(Name = 'Test Account' + i, Website = 'www.cloudsense.com',
					BillingCity = 'City', BillingCountry = 'United States', BillingCountryCode = 'US', BillingPostalCode = '10000',
					BillingState = 'Alabama', BillingStateCode = 'AL', BillingStreet = 'Some Street', Billing_email__c = 'some@some.com',
					Industry = 'Agency', Industry_Tier_2__c = 'Media Agency', Type = 'Advertiser', CurrencyIsoCode = 'EUR',
					Corporate_Brand_Name__c = corporateBrandName.Id, RecordTypeId = recordTypeId);
			accounts.add(acc);
		}

		if (!accounts.isEmpty()) {
			insert accounts;
		}

		return accounts;
	}

	/****************************************************************************
	* Method Name : createContacts
	* Description : Used to create contacts
	* Parameters  : Integer which specifies the number of contacts to be created.
	* Return      : List of contacts created
	****************************************************************************/
	public static List<Contact> createContacts(Integer count, List<Account> accounts) {
		List<Contact> contacts = new List<Contact>();
		for (Integer i = 0; i < count; i++) {
			Contact con = new Contact(FirstName = 'Test', LastName = 'Con' + i, AccountId = accounts[i].Id,Email = 'test'+i+'@test.com');
			contacts.add(con);
		}

		if (!contacts.isEmpty()) {
			insert contacts;
		}

		return contacts;
	}

	/*********************************************************************************
	* Method Name : createOpportunities
	* Description : Used to create opportunities
	* Parameters  : Integer which specifies the number of opportunities to be created.
	* Return      : List of opportunities created
	*********************************************************************************/
	public static List<Opportunity> createOpportunities(Integer count, List<Account> accounts, List<Contact> contacts) {
		List<Opportunity> opportunities = new List<Opportunity>();
		for (Integer i = 0; i < count; i++) {
			Opportunity opp = new Opportunity(Name = 'Test Opportunity' + i,
					AccountId = accounts[i].Id,
					SO_Booking_Contact__c = contacts[i].Id,
					StageName = 'Prospecting',
					CloseDate = System.today().addDays(10)
			);
			opportunities.add(opp);
		}

		/*if (!opportunities.isEmpty()) {
			insert opportunities;
		}*/
        
		return opportunities;
	}

	public static void insertPGAccountTrigger() {
		List<Trigger_Execute__c> pgAccountTriggerList = [
				SELECT Id, Enable_del__c
				FROM Trigger_Execute__c
				WHERE Name = 'PGAccountTrigger'
				LIMIT 1
		];

		if (pgAccountTriggerList.isEmpty()) {
			Trigger_Execute__c pgAccountTrigger = new Trigger_Execute__c(Name = 'PGAccountTrigger');
			pgAccountTrigger.Enable_del__c = false;
			insert pgAccountTrigger;
		} else if (pgAccountTriggerList[0].Enable_del__c == true) {
			pgAccountTriggerList[0].Enable_del__c = false;
			update pgAccountTriggerList;
		}
	}
   public static List<Account> createAccountForB2B(Integer count) {
		insertPGAccountTrigger();

		String randomNumber = String.valueOf(Integer.valueOf((Math.random() * 100)));
		Corporate_Brand_Name__c corporateBrandName = new Corporate_Brand_Name__c();

		List<Corporate_Brand_Name__c> corporateBrandNameList = [SELECT Id FROM Corporate_Brand_Name__c];
		if (corporateBrandNameList.size() > 0) {
			corporateBrandName = corporateBrandNameList[0];
		} else {
			corporateBrandName = new Corporate_Brand_Name__c(Name = 'Test Corporate Brand Name ' + randomNumber,
					Global_Customer_Segment__c = 'Advertiser');
			insert corporateBrandName;
		}

		Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');

		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < count; i++) {
			Account acc = new Account(Name = 'Test Account' + i, Website = 'www.cloudsense.com',
					BillingCity = 'City', BillingCountry = 'United States', BillingCountryCode = 'US', BillingPostalCode = '10000',
					BillingState = 'Alabama', BillingStateCode = 'AL', BillingStreet = 'Some Street', Billing_email__c = 'some@some.com',
					Industry = 'Agency', Industry_Tier_2__c = 'Media Agency', Type = 'Advertiser', CurrencyIsoCode = 'EUR',
					Corporate_Brand_Name__c = corporateBrandName.Id, RecordTypeId = recordTypeId);
			accounts.add(acc);
		}

		if (!accounts.isEmpty()) {
			insert accounts;
		}

		return accounts;
	}
}