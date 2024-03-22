@IsTest
public with sharing class SalesOrder_HistoryControllerTest {

	@TestSetup
    static void testSetup() {
        Account acc = TestDataSetupBasic.createAccount();
        insert acc;

		Account account = (Account) TestFactory.createSObject(new Account(), 'TestFactory.AccountDefaults');
		account.Name = 'Opportunity account 01'; account.Industry = 'Industrial & Utilities'; account.BillingCountry = 'United States'; account.CurrencyIsoCode = 'USD'; account.Type = 'Advertiser';
		insert account;

		Contact con = TestDataSetupBasic.createContact(acc);
		insert con;

		Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
		insert opp;

		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;
	}

    @IsTest
    static void testHistoryWrapper() {
		Test.startTest();
		csmso__Sales_Order__c so = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];

		so.T_C_Type__c = 'Spotify';
		update so;

		so.T_C_Type__c = 'Client';
		update so;

		System.debug('type ' + so.T_C_Type__c);
		System.assertEquals('Client', so.T_C_Type__c);

		csmso__Sales_Order__History[] soHistoryList = [SELECT ParentId,Parent.Name, OldValue, NewValue, Field, CreatedById,CreatedBy.Name, CreatedDate FROM csmso__Sales_Order__History WHERE ParentId = :so.Id LIMIT 1];
		csmso__Sales_Order__History soHistory = new csmso__Sales_Order__History();
        if (soHistoryList.size() > 0) {
            soHistory = soHistoryList[0];
        }
		ApexPages.currentPage().getParameters().put('id', so.Id);
		SalesOrder_HistoryController.aTableRow soWrapper = new SalesOrder_HistoryController.aTableRow(soHistory.Parent.Name, soHistory.NewValue, soHistory.OldValue, soHistory.Field, soHistory.CreatedDate, soHistory.CreatedBy.Name);

		soWrapper.compareTo(soWrapper);

		SalesOrder_HistoryController soController = new SalesOrder_HistoryController();
		soController.doSort();
		Test.stopTest();
	}
}