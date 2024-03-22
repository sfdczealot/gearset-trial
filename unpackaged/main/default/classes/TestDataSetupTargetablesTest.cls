@isTest
private class TestDataSetupTargetablesTest {
    
    @isTest static void TestDataSetupTargetablesTest() {
        Account acc = TestDataSetupTargetables.createAccount();
            Account[] accounts = TestDataSetupTargetables.createAccounts(1);

            Contact con = TestDataSetupTargetables.createContact(acc);
            Contact[] contacts = TestDataSetupTargetables.createContacts(1, accounts);

            Opportunity opp = TestDataSetupTargetables.createOpportunity(acc,con);
            Opportunity[] opportunities = TestDataSetupTargetables.createOpportunities(1, accounts, contacts);
            

            csmso__Sales_Order__c[] salesOrders = TestDataSetupTargetables.createSalesOrders(1,accounts,opportunities);
            csmso__Sales_Order__c salesOrder = TestDataSetupTargetables.createSalesOrder(acc,opp);
            csmso__Upload_Approval__c uploadApproval = TestDataSetupTargetables.createUploadApproval(salesOrders[0]);
            cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
            cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
            csdf__Fulfilment__c fulfilment = TestDataSetupTargetables.createFulfilment(salesOrder,acc);
            csdf__Fulfilment_Item__c fulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,salesOrder,fulfilment);
            cscfga__Product_Category__c prodCateg = TestDataSetupTargetables.createProdCateg();
            cscfga__Product_Definition__c prodDef = TestDataSetupTargetables.createProDef(prodCateg);
            cscfga__Attribute_Definition__c attributeDef = TestDataSetupTargetables.createAttrDef(prodDef);
            cscfga__Configuration_Screen__c configScreen = TestDataSetupTargetables.createConfigurationScreen(prodDef,'test');
            cscfga__Attribute__c attribute = TestDataSetupTargetables.createAttr(prodConfig,salesOrder,attributeDef, fulfilmentItem);
            csdf__Ad_Slot__c adSlot = TestDataSetupTargetables.createAdSlot();
            csdf__Ad_Server__c adServer = TestDataSetupTargetables.createAdServer();
            csdf__Site__c site = TestDataSetupTargetables.createSite(adServer);
            csdf__Site_Targeting__c siteTargeting = TestDataSetupTargetables.createSiteTarget(site, fulfilmentItem);
            csdf__Targeting_Template__c targetingTemplate = TestDataSetupTargetables.createTargetTemp(adServer);
            csdf__Geo_Item__c geoItem = TestDataSetupTargetables.createGeoItem();
            csdf__Geo_Item_Targeting_Template__c geoItemTargetTemp = TestDataSetupTargetables.createGeoItemTargetTemp(geoItem,targetingTemplate);
            csdf__Browser__c browser = TestDataSetupTargetables.createBrowser(adServer);
            csdf__Browser_Targeting_Template__c browsingTemplate = TestDataSetupTargetables.createBrowserTargetTemp(browser,targetingTemplate);
            csdf__Targetable__c targetable = TestDataSetupTargetables.createTargetable(adServer);
            csdf__Targetable_Targeting_Template__c targetableTargetingTemplate = TestDataSetupTargetables.createTargetableTargetTemp(targetable,targetingTemplate);
            csdf__Operating_System__c OS = TestDataSetupTargetables.createOS(adServer);
            csdf__Operating_System_Targeting_Template__c OSTargetingTemplate = TestDataSetupTargetables.createOSTargetTemp(OS,targetingTemplate);
            csdf__Operating_System_Version__c osVersion = TestDataSetupTargetables.createOSVer(OS);
            csdf__Operating_System_Version_Target_Template__c osVersionTT = TestDataSetupTargetables.createOSVerTargTemp(osVersion,targetingTemplate);
            CSCAP__Click_Approve_Setting__c cas = TestDataSetupTargetables.createClkAppSet();



        TestDataSetupTargetables.createTargetingQueryStrings();
        //TestDataSetupTargetables.createOS();
        TestDataSetupTargetables.createPerform();
        TestDataSetupTargetables.createad();
        TestDataSetupTargetables.createInMsgs(2);
        TestDataSetupTargetables.createCSCustomSettings();
        TestDataSetupTargetables.createPurgeBatchJob();


    }
    
    
}