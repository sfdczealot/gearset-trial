/**
 * @name CS_th_Account
 * @description Factory class for Account object
 * @revision
 *
 */
@IsTest
public class CS_th_Account {
	/**
	 * Create an account for test
	 * @param  name String
	 * @return      Account
	 */
	public static Account create(String name) {
		return create(name, true);
	}

	/**
	 * Create an account for test
	 * @param  name         String
	 * @param  insertRecord Boolean
	 * @return              Account
	 */
	public static Account create(String name, Boolean insertRecord) {
		Id recordTypeId = CS_utl_RecordType.getRecordTypesById(Account.getSObjectType()).values().get(0).getRecordTypeId();
		return create(name, recordTypeId, insertRecord);
	}

	/**
	 * Create an account for test
	 * @param  name         String
	 * @param  recordTypeId Id
	 * @param  insertRecord Boolean
	 * @return              Account
	 */
	public static Account create(String name, Id recordTypeId, Boolean insertRecord) {
        TestDataSetupBasic.insertPGAccountTrigger();

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

		Account account = new Account(
                Name = name,
				Phone = '12345',
				BillingStreet = 'Test Street',
				BillingCity = 'City',
				BillingPostalCode = '10000',
				BillingCountry = 'United States',
				BillingCountryCode = 'US',
				RecordTypeId = recordTypeId,
				Website = 'www.cloudsense.com',
				Industry = 'Agency',
				Industry_Tier_2__c = 'Media Agency',
				Type = 'Advertiser',
				CurrencyIsoCode = 'EUR',
				Corporate_Brand_Name__c = corporateBrandName.Id
        );

		if (insertRecord) {
			insert account;
		}

		return account;
	}

	/**
	 * Create an account for test
	 * @param  name         String
	 * @param  insertRecord Boolean
	 * @param  count        Integer
	 * @return              Account
	 */
	public static List<Account> createMultiple(String name, Boolean insertRecord, Integer count) {
		Id recordTypeId = CS_utl_RecordType.getRecordTypesById(Account.getSObjectType()).values().get(0).getRecordTypeId();
		return createMultiple(name, recordTypeId, insertRecord, count);
	}

	/**
	 * Create an account for test
	 * @param  name         String
	 * @param  recordTypeId Id
	 * @param  insertRecord Boolean
	 * @param  count        Integer
	 * @return              Account
	 */
	public static List<Account> createMultiple(String name, Id recordTypeId, Boolean insertRecord, Integer count) {
        TestDataSetupBasic.insertPGAccountTrigger();

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

		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < count; i++) {
			Account acc = new Account(
                    Name = name + String.valueOf(i),
					Phone = '12345',
					BillingStreet = 'Test Street',
					BillingCity = 'City',
					BillingPostalCode = '10000',
					BillingCountry = 'United States',
					BillingCountryCode = 'US',
					RecordTypeId = recordTypeId,
					Website = 'www.cloudsense.com',
					Industry = 'Agency',
					Industry_Tier_2__c = 'Media Agency',
					Type = 'Advertiser',
					CurrencyIsoCode = 'EUR',
					Corporate_Brand_Name__c = corporateBrandName.Id
            );
			accounts.add(acc);
		}

		if (!accounts.isEmpty() && insertRecord) {
			insert accounts;
		}

		return accounts;
	}
}