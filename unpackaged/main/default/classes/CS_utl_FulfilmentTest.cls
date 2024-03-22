/**
 * Created by tvrtko.matosevic on 15/02/2019.
 */

@IsTest
private class CS_utl_FulfilmentTest {
    @IsTest
    static void testGetStatus() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
	    insert soapi;
        
        Account acc = TestDataSetupTargetables.createAccount();
        string accRecTypeID = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        acc.RecordTypeId = accRecTypeID;
        insert acc;

        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        insert so;

        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;

        csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
        insert testAdServer;

        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);
        insert testFulfilment;

        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;

        csam__Integration_Endpoint__c custSetting = new csam__Integration_Endpoint__c();
        custSetting.Name = 'Ad Server Availability Check';
        custSetting.csam__Callout_Host__c = 'cs-digital-fulfilment-sandbox.herokuapp.com';
        insert custSetting;

        csam__ObjectGraph_Callout_Handler__c testObjGrph = TestDataSetupTargetables.createObjGrph();
        testObjGrph.Name = 'Fulfilment Item Refresh';
        testObjGrph.csam__Integration_Endpoint_Name__c = 'Ad Server Availability Check';
        testObjGrph.csam__Status_Field__c = 'csdf__Fulfilment_Message_Status__c';
        insert testObjGrph;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,so,testFulfilment);
        testFulfilmentItem.Product_Configuration__c = prodConfig.Id;
        testFulfilmentItem.Served_By__c = 'DFP';
        testFulfilmentItem.Booking_Timezone__c = 'Europe/London';
        testFulfilmentItem.csdf__Flight_Beginning__c = System.now().addDays(-1);
        testFulfilmentItem.csdf__Flight_End__c = System.now().addDays(2);
        insert testFulfilmentItem;

        testFulfilmentItem.csdf__Status__c  ='Delivering';
        testFulfilmentItem.csdf__Fulfilment_Message_Status__c = 'Waiting';
        update testFulfilmentItem;

        String status = CS_utl_Fulfilment.getStatus('Fulfilment Item Refresh', testFulfilmentItem);
        System.assertEquals('Waiting', status);

        Boolean isCallOutCompleted = CS_utl_Fulfilment.isCalloutCompleted('Fulfilment Item Refresh', new List<csdf__Fulfilment_Item__c> {testFulfilmentItem});
        System.assertEquals(false, isCallOutCompleted);
        
        CS_utl_Fulfilment.setFulfilmentItemsToPausedInventoryReleased(new List<csdf__Fulfilment_Item__c> {testFulfilmentItem});

        Map<Id, List<csdf__Fulfilment_Item__c>> fulfilmentItemMap = CS_utl_Fulfilment.getFulfilmentItems(new Set<Id>{testFulfilment.Id});
        System.assert(!fulfilmentItemMap.isEmpty());
    }
}