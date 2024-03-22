@isTest
private class CS_SalesOrderStateManagerBaseTest {
    private static User standardUser;
    private static User systemAdminUser;
    private static User ssystemAdminUser;
    private static User financeUser;

    private static void createStandardUser() {
        Profile standardUserProfile =[SELECT ID FROM Profile Where Name = 'Standard User' limit 1];
        standardUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = standardUserProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standamarkorduser1234@testorg.com');
        insert standardUser;
    }

    private static void createSystemAdminUser() {
        Profile systemAdminProfile =[SELECT ID FROM Profile Where Name in ('System Administrator', 'Systeembeheerder') limit 1];
        systemAdminUser = new User(Alias = 'standta', Email='standardusear@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = systemAdminProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standamarkordusera1234@testorg.com');
        insert systemAdminUser;
    }

    private static void createSSystemAdminUser() {
        Profile ssystemAdminProfile =[SELECT ID FROM Profile Where Name in ('S: Systems Administrator') limit 1];
        ssystemAdminUser = new User(Alias = 'standta', Email='standardusear@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = ssystemAdminProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standamarkordusera1234@testorg.com');
        insert ssystemAdminUser;
    }

    private static void createFinanceUser() {
        Profile financeUserProfile =[SELECT ID FROM Profile Where Name = 'S: Finance User' limit 1];
        financeUser = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = financeUserProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='standamarkorduser1234@testorg.com');
        insert financeUser;
    }

    @isTest
    static void testSalesOrderStateManagerBase() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;

        Contact con = TestDataSetupSO.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];

        Test.startTest();
        Type stateManagerType = Type.forName(so.State_Manager_Class__c);
        CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
        stateManager.init(so);
        stateManager.validateChange();
        Map<String, String> fieldProperties = stateManager.getFieldProperties();
        //stateManager.updateSpecificFieldAttributesForSalesOrder(attribs);
        Test.stopTest();
    }

    @isTest
    static void testSalesOrderStateManagerBaseNonPrimary() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;

        Contact con = TestDataSetupSO.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.Primary_Sales_Order__c = false;
        so.csmso__Opportunity__c = opp.Id;
        insert so;

        csmso__Sales_Order__c so2 = TestDataSetupSO.createSalesOrder(acc, opp);
        so2.Order_Type__c = 'Direct Commercial';
        so.Primary_Sales_Order__c = true;
        so.Last_Date_Booked__c = Date.Today();
        so.csmso__Opportunity__c = opp.Id;
        insert so2;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];

        Test.startTest();
        Type stateManagerType = Type.forName(so.State_Manager_Class__c);
        CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
        stateManager.init(so);
        stateManager.validateChange();
        Map<String, String> fieldProperties = stateManager.getFieldProperties();
        Test.stopTest();
    }

    @isTest
    static void testSOSMBRejectedInRetraction() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;

        Contact con = TestDataSetupSO.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
        so.Last_Date_Retracted__c = Date.today();
        so.Applicable_IO_Volume_Discount_Range__c = 1;
        so.Applied_IO_Volume_Discount_Range__c = 0;
        so.Total_Markets__c = 1;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
        FROM    cscfga__Product_Configuration__c
        LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    /*
    @isTest 
    static void testSalesOrderStateManagerBase() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        Account acc = TestDataSetupSO.createAccount();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        insert so;
        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        Test.startTest();
        Type stateManagerType = Type.forName(so.State_Manager_Class__c);
        CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
        stateManager.init(so);
        stateManager.validateChange();
        Map<String, String> fieldProperties = stateManager.getFieldProperties();
        Test.stopTest();
    }
     */

    @isTest 
    static void testSOSMBStandardUserNoPermission() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBSystemAdminNoPermission() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createSystemAdminUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        System.runAs(systemAdminUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBSSystemAdminLegal() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createSSystemAdminUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
        so.Last_Date_Retracted__c = Date.today();
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];
        
        System.runAs(ssystemAdminUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBSSystemAdminCounter() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createSSystemAdminUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
        so.Last_Date_Retracted__c = Date.today();
        so.Legal_Check__c = 'Approved';
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];
        
        System.runAs(ssystemAdminUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBSSystemAdminCompliance() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createSSystemAdminUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_PENDING_BOOKING;
        so.Last_Date_Retracted__c = Date.today();
        so.Legal_Check__c = 'Approved';
        so.Counter_Sign_IO__c = 'Approved';
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];
        
        System.runAs(ssystemAdminUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBStandardUserWithPC() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = CS_const_SalesOrder.Status_InProgress;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        System.debug('****** prodDef');
        System.debug(prodDef);

        System.debug('****** prodConfigs');
        System.debug(prodConfigs);


        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }
    /*
    @isTest 
    static void testSOSMBRejectedInRetraction() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        createStandardUser();
        Account acc = TestDataSetupSO.createAccount();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
        so.Last_Date_Retracted__c = Date.today();
        so.Applicable_IO_Volume_Discount_Range__c = 1;
        so.Applied_IO_Volume_Discount_Range__c = 0;
        so.Total_Markets__c = 1;
        insert so;
        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);
        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});
        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;
        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});
        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;
        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];
        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }
     */

    @isTest 
    static void testSOSMBDiscounts() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
        so.Last_Date_Retracted__c = Date.today();
        so.Applicable_IO_Volume_Discount_Range__c = 1;
        so.Applied_IO_Volume_Discount_Range__c = 2;
        so.Total_Markets__c = 1;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBPendingCheckAvail() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = CS_const_SalesOrder.Status_ReadyForCustomerApproval;
        so.Flighting_Pending_Check_Avail__c = true;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBPendingCheckAvail2() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = CS_const_SalesOrder.Status_ReadyForCustomerApproval;
        so.Flighting_Pending_Check_Avail__c = true;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBArchived() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = CS_const_SalesOrder.Status_ReadyForCustomerApproval;
        so.Is_archived__c = true;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBPending() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = CS_const_SalesOrder.Status_ReadyForCustomerApproval;
        so.Loading_Screen__c = 'On';
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBMessage1() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
        so.Last_Date_Retracted__c = Date.today();
        so.Applicable_IO_Volume_Discount_Range__c = 1;
        so.Applied_IO_Volume_Discount_Range__c = 2;
        so.Total_Markets__c = 1;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBMessage2() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
        so.Last_Date_Retracted__c = Date.today();
        so.Applicable_IO_Volume_Discount_Range__c = 0;
        so.Applied_IO_Volume_Discount_Range__c = 2;
        so.Total_Markets__c = 1;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBMessage3() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
        so.Last_Date_Retracted__c = Date.today();
        so.Applicable_IO_Volume_Discount_Range__c = 10;
        so.Applied_IO_Volume_Discount_Range__c = 2;
        so.Total_Markets__c = 2;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBMessage4() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        CS_Custom_Settings__c setting = new CS_Custom_Settings__c();
        setting.IO_Volume_Discount_Tolerance__c = 1000;
        insert setting;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        so.Last_Date_Booked__c = Date.today();
        so.Primary_Sales_Order__c = true;
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
        so.Last_Date_Retracted__c = Date.today();
        so.Applicable_IO_Volume_Discount_Range__c = 3;
        so.Applied_IO_Volume_Discount_Range__c = 1;
        so.Total_Before_IO_Volume_Discount__c = -30;
        so.Total_Markets__c = 2;
        so.Total_Price_Calculated__c = 1000;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBMessagePrimaryChecked() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createStandardUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.csmso__Opportunity__c = opp.Id;
        so.Order_Type__c = 'Direct Commercial';
        so.csmso__Process_Message__c = CS_const_SalesOrder.PRIMARY_SO_ALREADY_CHECKED;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];

        opp.Primary_Sales_Order__c = so.Id;
        update so;

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];

        System.runAs(standardUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }

    @isTest 
    static void testSOSMBFinanceUser() {     
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        createFinanceUser();

        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        
        Contact con = TestDataSetupSO.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
        so.Order_Type__c = 'Direct Commercial';
        so.SO_Lines_Ad_Server_Items__c = 0;
        insert so;

        so = (csmso__Sales_Order__c)sObjectHelper.getSelectStarFrom('csmso__Sales_Order__c','Id= \'' + so.Id + '\'',1, true)[0];

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1, prodDef);

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{so});

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
        }
        update prodConfigs;

        List<csdf__Fulfilment__c> fulfilment = testDataSetupBilling.createFulfilment(1,new List<csmso__Sales_Order__c>{so},new List<Account>{acc});

        List<csdf__Fulfilment_Item__c> fulfilmentItem = testDataSetupBilling.createFulfilmentItem(1,fulfilment,prodConfigs);
        fulfilmentItem[0].csdf__Flight_Beginning__c = Date.Today().addDays(4);
        fulfilmentItem[0].csdf__Type__c = 'Standard';
        fulfilmentItem[0].Served_By__c = 'DFP';
        update fulfilmentItem;

        cscfga__Product_Configuration__c pc = [SELECT       Id, Sales_Order__c
                                                    FROM    cscfga__Product_Configuration__c
                                                    LIMIT   1][0];
        
        System.runAs(financeUser){
            Test.startTest();
            Type stateManagerType = Type.forName(so.State_Manager_Class__c);
            CS_SalesOrderStateManagerBase stateManager = (CS_SalesOrderStateManagerBase)stateManagerType.newInstance();
            stateManager.init(so);
            stateManager.validateChange();
            Map<String, String> fieldProperties = stateManager.getFieldProperties();
            Test.stopTest();
        }
    }
}