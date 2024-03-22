@IsTest
public class UpdateFulfilmentItemSyncToNS_Test {
    @IsTest
    public static void test_isInProgress() {
        Account acc = TestDataSetupTargetables.createAccount();
        acc.recordtypeid =Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();

        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
         
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
       opp.recordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        insert opp;
        payment_term__c pm = new Payment_term__c(name='Monthly',NS_Payment_Term_ID__c=12);
        insert pm;
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        testProDef.name='MPD Subscriptions';
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Pending OMC Approval';
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.NetSuite_Payment_Term__c = pm.id;
        salesOrder.Advertiser_Final__c = acc.Id;
        salesorder.Approval_Requester_Comment__c='true';
        insert salesOrder;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        Billing_Schedule_Rule__c bScheduleRule = testDataSetupBilling.createBillingScheduleRule();
        Billing_Schedule_Rule__c rScheduleRule = testDataSetupBilling.createRevenueScheduleRule();
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Name='MPD Subscriptions'; 
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.IO_Volume_Discount_Range_1__c = 10;
        prodConfig.Revenue_Schedule_Rule__c = rScheduleRule.Id;
        insert prodConfig;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(salesOrder, acc);
        insert testFulfilment;
        csdf__Fulfilment_Item__c testFI = TestDataSetupTargetables.createFulfilmentItem(prodConfig,salesOrder,testFulfilment);
        testFI.csdf__Flight_Beginning__c = Date.today();
        testFI.csdf__Flight_End__c =  Date.Today().addMonths(11);
        testFI.Product_Configuration__c = prodConfig.id;
        testFI.Flight_Beginning_Line_Item__c = Date.today();
        testFI.Flight_End_Line_Item__c = Date.Today().addMonths(11);
        insert testFI;
        testFI.csdf__Status__c ='Completed';
        update testFI;
            salesOrder.csmso__Status__c = 'Booked';
        update salesOrder;
            }
    
    
}