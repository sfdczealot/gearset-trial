@IsTest
private class BatchReleaseInventoryStartDate_test {
    
    @IsTest(SeeAllData=false)
    static void testBatchReleaseInventory() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        Account[] accs = TestDataSetupBasic.createAccounts(1);
        Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
        Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opps[0].Id;
        salesOrder.SO_Lines_All_Valid__c = true;
        insert salesOrder;
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
        
        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
            salesOrder
                });
        
        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
        prodConfigs.addAll(TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef));
        System.debug('prodConfigs === '+ prodConfigs);
        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1, new List<csmso__Sales_Order__c>{
            salesOrder
                }, accs);
        System.debug('Fulfilment ==='+ fulfilment);
        //fulfilment.addAll(fulfilment);
        
        List<csdf__Fulfilment_Item__c> fulfilmentItem = new List<csdf__Fulfilment_Item__c>();
        for(cscfga__Product_Configuration__c pc: prodConfigs){
            csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
            testFulfilmentItem.csdf__Fulfilment__c = fulfilment[0].id;
            testFulfilmentItem.product_configuration__c = pc.id;
            //testFulfilmentItem.Sales_Order__c =  testFulfilments[i].sales_order__c;
            testFulfilmentItem.csdf__Flight_Beginning__c = DateTime.valueof(System.now()-30);
            testFulfilmentItem.csdf__Flight_End__c = DateTime.valueof(System.now()+30);
            testFulfilmentItem.csdf__Name__c = 'FI FOR '+pc.id;
            testFulfilmentItem.Insertion_Quantity__c = 1600;
            testFulfilmentItem.csdf__Quantity__c = 1600;
            fulfilmentItem.add(testFulfilmentItem);
        }
        if(!fulfilmentItem.isEmpty()){
            insert fulfilmentItem;
        }
        
        
        //List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1, fulfilment, prodConfigs);
        
        
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        fulfilmentItem[1].csdf__Flight_Beginning__c = Date.today().addDays(4);
        fulfilmentItem[1].csdf__Type__c = 'Standard';
        fulfilmentItem[1].Served_By__c = 'DFP';
        update fulfilmentItem;
        
        for (cscfga__Product_Configuration__c pConfig : prodConfigs) {
            pConfig.Sales_Order__c = salesOrder.Id;
            pConfig.Reserve_Inventory__c = true;
            pConfig.Reservation_Status__c = 'RESERVED';
            pConfig.Inventory_Available__c = 'Yes';
            //pConfig.Fulfilment_Item__c = fulfilmentItem[0].Id;
        }
        update prodConfigs;
        
        prodConfigs = [SELECT Id FROM cscfga__Product_Configuration__c];
        fulfilmentItem = [
            SELECT
            Id, csdf__Flight_Beginning__c, csdf__Type__c, Served_By__c,
            Product_Configuration__c,
            Product_Configuration__r.Reservation_Status__c,
            Product_Configuration__r.Reserve_Inventory__c,
            Product_Configuration__r.Sales_Order__c
            FROM csdf__Fulfilment_Item__c];
        for (csdf__Fulfilment_Item__c fIItem : fulfilmentItem) {
            System.debug('FI=='+ fIItem);
        }
        Test.startTest();
        BatchReleaseInventoryStartDate batchReleaseInventory = new BatchReleaseInventoryStartDate();
        batchReleaseInventory.doWork(fulfilmentItem);
        Test.stopTest();
        
        List<cscfga__Product_Configuration__c> pcsAfterBatch = [SELECT Id, Reserve_Inventory__c FROM cscfga__Product_Configuration__c];
        System.assertEquals(pcsAfterBatch[0].Reserve_Inventory__c, true);
    }
}