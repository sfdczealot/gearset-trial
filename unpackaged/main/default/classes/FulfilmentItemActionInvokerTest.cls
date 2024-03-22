@isTest
private class FulfilmentItemActionInvokerTest {
    
    @isTest 
    static void test_method_one() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        List<Id> adSlotIdList = new List<Id>();
        List<Id> siteList = new List<Id>();
        List<Id> operatingSystemsList = new List<Id>();
        List<Id> operatingSystemVersionsList = new List<Id>();

        Account acc = TestDataSetupBasic.createAccount();
        insert acc;
        
        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;

        csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
        insert testAdServer;

        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Ad_Server__c = testAdServer.Id;
        insert so;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);
        testFulfilment.csdf__Ad_Server__c = testAdServer.Id;
        insert testFulfilment;
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,so,testFulfilment); 
        testFulfilmentItem.Product_Configuration__c = null;
        testFulfilment.csdf__Ad_Server__c = testAdServer.Id;
        insert testFulfilmentItem;

        csdf__Site__c testSite = TestDataSetupTargetables.createSite(testAdServer);
        insert testSite;
        
        csdf__Site_Targeting__c testSiteTarget = TestDataSetupTargetables.createSiteTarget(testSite,testFulfilmentItem);
        insert testSiteTarget;

        csdf__Operating_System__c testOS = TestDataSetupTargetables.createOS(testAdServer);
        insert testOS;
        csdf__Operating_System_Version__c testOSVer = TestDataSetupTargetables.createOSVer(testOS);
        insert testOSVer;

        csdf__Ad_Slot__c testAdSlot = TestDataSetupTargetables.createAdSlot();
        testAdSlot.csdf__Ad_Server__c = testAdServer.Id;
        testAdSlot.csdf__Ad_Server_Id__c = '0';
        testAdSlot.csdf__Sizes__c= '24/s*25';
        insert testAdSlot;

        adSlotIdList.add(testAdSlot.Id);
        siteList.add(testSite.Id);
        operatingSystemsList.add(testOS.Id);
        operatingSystemVersionsList.add(testOSVer.Id);
        
        Test.startTest();
        //CS_FulfilmentService.getParentAdServer();
        CS_FulfilmentService.DigitalFulfilmentAttributes attr = new CS_FulfilmentService.DigitalFulfilmentAttributes();
        
        //attr.fulfilmentItemId = testFulfilmentItem.Id;
        attr.accountId = acc.Id;
        attr.adSlotIdsInclude = adSlotIdList;
        attr.sites = siteList;
        attr.salesOrderId = so.Id;
        attr.flightBeginning = testFulfilmentItem.csdf__Flight_Beginning__c;
        attr.flightEnd = testFulfilmentItem.csdf__Flight_End__c;
        attr.quantity = testFulfilmentItem.csdf__Quantity__c;
        attr.dayPartTargeting = 'testdayPartTargeting ';
        attr.customKeyTargeting = 'testcustomKeyTargeting is 123456789012345';
        attr.displayCreatives  = 'testdisplayCreatives ';
        attr.notes = 'testnotes';
        attr.priority = '5';
        attr.rotateCreatives = 'testrotateCreatives';
        attr.targetPlatform = 'targetPlatform';
        attr.type = 'testtype';
        attr.frequencyCaps = 'DAY,10,10';
        attr.operatingSystemVersionsIncludedExcludedString = 'INCLUDE:'+testOSVer.Id+';EXCLUDE:;';

        String parameters = JSON.serialize(attr);

        CS_FulfilmentService.DigitalFulfilmentAttributes dfAttributes = 
            (CS_FulfilmentService.DigitalFulfilmentAttributes) 
            JSON.deserialize(parameters, CS_FulfilmentService.DigitalFulfilmentAttributes.class);


        FulfilmentItemActionInvoker fulItemActionInvokeClass = new FulfilmentItemActionInvoker ();
        fulItemActionInvokeClass.performAction(parameters);

        CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
        dispatcher.addWorker(new FulfilmentItemActionInvoker.CS_FulfilmentInvokerWorker(new Map<String, Object>{'retry' => 0, 'param' => parameters}));
        dispatcher.dispatch();

        Test.stopTest();        
    }

    
    @isTest 
    static void test_method_two() {
        
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        Account acc = TestDataSetupBasic.createAccount();
        insert acc;
        
        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        insert so;

        String dummyFiJson = FulfilmentItemActionInvoker.makeDummyFI(so.Id);
    }

    @isTest 
    static void test_method_three() {
        
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        List<Id> adSlotIdList = new List<Id>();
        List<Id> siteList = new List<Id>();
        List<Id> operatingSystemsList = new List<Id>();
        List<Id> operatingSystemVersionsList = new List<Id>();

        Account acc = TestDataSetupBasic.createAccount();
        insert acc;
        
        Contact con = TestDataSetupBasic.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
        insert opp;

        csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
        insert testAdServer;

        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Ad_Server__c = testAdServer.Id;
        insert so;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;
        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);
        testFulfilment.csdf__Ad_Server__c = testAdServer.Id;     
        insert testFulfilment;
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        insert prodConfig;

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,so,testFulfilment); 
        testFulfilmentItem.Product_Configuration__c = null;
        testFulfilment.csdf__Ad_Server__c = testAdServer.Id;
        insert testFulfilmentItem;

        csdf__Site__c testSite = TestDataSetupTargetables.createSite(testAdServer);
        insert testSite;
        
        csdf__Site_Targeting__c testSiteTarget = TestDataSetupTargetables.createSiteTarget(testSite,testFulfilmentItem);
        insert testSiteTarget;

        csdf__Operating_System__c testOS = TestDataSetupTargetables.createOS(testAdServer);
        insert testOS;
        csdf__Operating_System_Version__c testOSVer = TestDataSetupTargetables.createOSVer(testOS);
        insert testOSVer;

        csdf__Ad_Slot__c testAdSlot = TestDataSetupTargetables.createAdSlot();
        testAdSlot.csdf__Ad_Server__c = testAdServer.Id;
        testAdSlot.csdf__Ad_Server_Id__c = '0';
        testAdSlot.csdf__Sizes__c= '24/s*25';
        insert testAdSlot;

        adSlotIdList.add(testAdSlot.Id);
        siteList.add(testSite.Id);
        operatingSystemsList.add(testOS.Id);
        operatingSystemVersionsList.add(testOSVer.Id);
        
        Test.startTest();
        //CS_FulfilmentService.getParentAdServer();
        CS_FulfilmentService.DigitalFulfilmentAttributes attr = new CS_FulfilmentService.DigitalFulfilmentAttributes();
        
        //attr.fulfilmentItemId = testFulfilmentItem.Id;
        attr.accountId = acc.Id;
        attr.adSlotIdsInclude = adSlotIdList;
        attr.sites = siteList;
        attr.salesOrderId = so.Id;
        attr.flightBeginning = testFulfilmentItem.csdf__Flight_Beginning__c;
        attr.flightEnd = testFulfilmentItem.csdf__Flight_End__c;
        attr.quantity = testFulfilmentItem.csdf__Quantity__c;
        attr.dayPartTargeting = 'testdayPartTargeting ';
        attr.customKeyTargeting = 'testcustomKeyTargeting is 123456789012345';
        attr.displayCreatives  = 'testdisplayCreatives ';
        attr.notes = 'testnotes';
        attr.priority = '5';
        attr.rotateCreatives = 'testrotateCreatives';
        attr.targetPlatform = 'targetPlatform';
        attr.type = 'testtype';
        attr.frequencyCaps = 'DAY,10,10';
        attr.operatingSystemVersionsIncludedExcludedString = 'INCLUDE:'+testOSVer.Id+';EXCLUDE:;';

        String parameters = JSON.serialize(attr);

        CS_FulfilmentService.DigitalFulfilmentAttributes dfAttributes = 
            (CS_FulfilmentService.DigitalFulfilmentAttributes) 
            JSON.deserialize(parameters, CS_FulfilmentService.DigitalFulfilmentAttributes.class);

        FulfilmentItemActionInvoker fulItemActionInvokeClass = new FulfilmentItemActionInvoker ();
        fulItemActionInvokeClass.invoke(parameters);      
        Test.stopTest();
    }
}