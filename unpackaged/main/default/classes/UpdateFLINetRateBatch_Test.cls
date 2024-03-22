@IsTest
public class UpdateFLINetRateBatch_Test {
    @IsTest
	static void testUpdateFLINetRateBatch() {
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        Account testAccount = TestDataSetupSO.createAccount();
        testAccount.recordtypeid=[SELECT Id,Name FROM RecordType WHERE SObjectType='Account' and Name='B2B - Account'].id;
        insert testAccount;
        
        Contact testContact = TestDataSetupSO.createContact(testAccount);
        insert testContact;
        
        Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
        testOpportunity.recordtypeid=[SELECT Id,Name FROM RecordType WHERE SObjectType='Opportunity' and Name='B2B'].id;
        insert testOpportunity;
        
        csmso__Sales_Order__c testSalesOrder = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
        insert testSalesOrder;
        
        List<cscfga__Product_Basket__c> testProductBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{testSalesOrder});
        
        csdf__Fulfilment__c testFulfilment = [SELECT Id FROM csdf__Fulfilment__c WHERE Sales_Order__c = :testSalesOrder.Id];
        
        cscfga__Product_Configuration__c testConfiguration = TestDataSetupSO.createproductConfigAndDef('Test Config'); 
        testConfiguration.Name = 'Developer Listings';
        testConfiguration.Sales_Order__c = testSalesOrder.Id;
        testConfiguration.Ad_Type__c = 'Standard';
        testConfiguration.Insertion_Unit_Type_Display__c = 'CPD';
        testConfiguration.Served_By__c = 'DFP';
        testConfiguration.Line_ID__c = '0046546458';
        testConfiguration.csmso__Flight_End__c = Date.today().addDays(5);
        testConfiguration.Fulfilment_Item_Status__c = 'Draft';
        update testConfiguration;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
		insert testProdCateg;

		cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
		testProDef.cscfga__Allow_progress_from_incomplete_screens__c = true;
		insert testProDef;

		cscfga__Configuration_Screen__c screenFlow = TestDataSetupTargetables.createConfigurationScreen(testProDef, 'Default Screen');
		insert screenFlow;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
		testAttrDef.cscfga__Configuration_Screen__c = screenFlow.Id;
		testAttrDef.cscfga__Column__c = 0;
		testAttrDef.cscfga__Row__c = 1;
		testAttrDef.Name = 'Description';
        Insert testAttrDef;
        
        cscfga__Attribute__c attDesc = new cscfga__Attribute__c(cscfga__Product_Configuration__c = testConfiguration.Id, Name = 'Description', cscfga__Value__c = '10000', cscfga__Price__c = 10000, cscfga__Is_Line_Item__c = true, cscfga__Attribute_Definition__c = testAttrDef.Id);
        Insert attDesc;
        
        List<csdf__Fulfilment_Item__c> fliList = new List<csdf__Fulfilment_Item__c>();
        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(testConfiguration, testSalesOrder, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = testConfiguration.Id;
        testFulfilmentItem.csdf__Availability_Check_Status__c = 'Completed';
        testFulfilmentItem.csdf__Rate__c = 290;
        testFulfilmentItem.csdf__Quantity__c = 12;
        //testFulfilmentItem.New_Line_ID__c = testConfiguration.Line_ID__c;
        fliList.add(testFulfilmentItem);
        insert fliList;
        
        Map<csdf__Fulfilment_Item__c, String> failedFLIMap = new Map<csdf__Fulfilment_Item__c, String>();
        failedFLIMap.put(testFulfilmentItem, 'Error');
        
        Test.startTest();
		UpdateFLINetRateBatch objBatch = new UpdateFLINetRateBatch();
        Database.executeBatch(objBatch);
        objBatch.execute(null, fliList);
        UpdateFLINetRateBatch.PrepareAndSendEmail(failedFLIMap, null);
		Test.stopTest();
    }
}