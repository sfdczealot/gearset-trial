@isTest
private class TestDataSetupSOTest {
	
	@isTest static void TestDataSetupSOTest() {
        
        
        QliToOliFieldMapping__c objcustomsetting=new QliToOliFieldMapping__c();
        objcustomsetting.Name='Start_Date__c';
        objcustomsetting.OliField__c='Start_Date__c';
        insert objcustomsetting;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;

        
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
		Account acc = TestDataSetupSO.createAccount();
		Account[] accounts = TestDataSetupSO.createAccounts(1);

		Contact con = TestDataSetupSO.createContact(acc);
		Contact[] contacts = TestDataSetupSO.createContacts(1, accounts);

		Opportunity opp = TestDataSetupSO.createOpportunity(acc,con);
		Opportunity[] opportunities = TestDataSetupSO.createOpportunities(1, accounts, contacts);
		Test.startTest();
		Account acc1 = TestDataSetupSO.createB2BAcc();
		csmso__Sales_Order__c[] salesOrders = TestDataSetupSO.createSalesOrders(1,accounts,opportunities);
		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc,opp);
		csmso__Upload_Approval__c uploadApproval = TestDataSetupSO.createUploadApproval(salesOrders[0]);
		cscfga__Product_Definition__c[] productDefinitions = TestDataSetupSO.createProductDefinitions(1);
		cscfga__Attribute_Definition__c[] attributeDefinitions = TestDataSetupSO.createAttributeDefinitions(1,productDefinitions);
		cscfga__Product_Basket__c[] productBaskets = TestDataSetupSO.createProdBaskets(1,salesOrders);
		cscfga__Product_Configuration__c[] prodConfigurations = TestDataSetupSO.createProdConfigs(1,productBaskets,productDefinitions);
		cscfga__Attribute__c[] attributes = TestDataSetupSO.createAttributes(1,prodConfigurations,attributeDefinitions);
		cscfga__product_Configuration__c prodConAndDef = TestDataSetupSO.createproductConfigAndDef('test');

        Test.stopTest();
	}
	
	
}