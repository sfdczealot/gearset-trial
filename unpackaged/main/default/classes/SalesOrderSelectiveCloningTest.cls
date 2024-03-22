@isTest
private class SalesOrderSelectiveCloningTest{
    
    @testSetup
    private static void setupData() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
    }
    
    @isTest
    static void testSelectiveCloningEmpty() {
        List<Account> accounts = TestDataSetupSO.createAccounts(1);
        List<Contact> contacts = TestDataSetupSO.createContacts(1, accounts);
        List<Opportunity> opportunities = TestDataSetupSO.createOpportunities(1, accounts, contacts);
        List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1, accounts, opportunities);
        List<cscfga__Product_Definition__c> prodDefinitions = TestDataSetupSO.createProductDefinitions(1);
        List<cscfga__Product_Definition__c> prodDefinitionsDFP = TestDataSetupSO.createProductDefinitions(1);
        List<cscfga__Attribute_Definition__c> attrDefinitions = TestDataSetupSO.createAttributeDefinitions(1, prodDefinitions);
        attrDefinitions[0].Custom_Cloning_Default_Value__c = SalesOrderSelectiveCloning.CUSTOM_CLONING_EMPTY;
        attrDefinitions[0].Custom_Cloning_Dynamic_Field__c = 'PO_Number__c';
        update attrDefinitions;
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, salesOrders);
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDefinitions);
        List<cscfga__Attribute__c> attributes = TestDataSetupSO.createAttributes(1, prodConfigs, attrDefinitions);
        Test.startTest();
            SalesOrderSelectiveCloning sClone = new SalesOrderSelectiveCloning();
            sClone.prepareReferences(salesOrders[0].Id);
            sClone.filter('csmso__Sales_Order__c', salesOrders[0], salesOrders[0].clone(true, false, false, false));
            cscfga__Attribute__c attrQ = [SELECT Id, Name, cscfga__Attribute_Definition__c, cscfga__Value__c, cscfga__Display_Value__c, Custom_Cloning_Default_Value__c, Custom_Cloning_Dynamic_Field__c FROM cscfga__Attribute__c WHERE Id = :attributes[0].Id];
            sClone.filter('cscfga__Attribute__c', attrQ, attrQ.clone());
            sClone.cloningFinished(true);
        Test.stopTest();
    }
    
    /************************************************************************************************
    * Method Name : testSelectiveCloningCurrent
    * Description : Testmethod to test clone process for attribute's cloning default value is Current
    * Parameters  : NA
    * Return      : NA
    ************************************************************************************************/
    @isTest
    static void testSelectiveCloningCurrent() {
        List<Account> accounts = TestDataSetupSO.createAccounts(1);
        List<Contact> contacts = TestDataSetupSO.createContacts(1, accounts);
        List<Opportunity> opportunities = TestDataSetupSO.createOpportunities(1, accounts, contacts);
        List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1, accounts, opportunities);
        List<cscfga__Product_Definition__c> prodDefinitions = TestDataSetupSO.createProductDefinitions(1);
        List<cscfga__Product_Definition__c> prodDefinitionsDFP = TestDataSetupSO.createProductDefinitions(1);
        List<cscfga__Attribute_Definition__c> attrDefinitions = TestDataSetupSO.createAttributeDefinitions(1, prodDefinitions);
        attrDefinitions[0].Custom_Cloning_Default_Value__c = SalesOrderSelectiveCloning.CUSTOM_CLONING_CURRENT;
        attrDefinitions[0].Custom_Cloning_Dynamic_Field__c = 'Agency_Commission_Amount__c';
        update attrDefinitions;
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, salesOrders);
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDefinitions);
        prodConfigs[0].Agency_Commission_Amount__c = 123;
        update prodConfigs;
        List<cscfga__Attribute__c> attributes = TestDataSetupSO.createAttributes(1, prodConfigs, attrDefinitions);
        Test.startTest();
            SalesOrderSelectiveCloning sClone = new SalesOrderSelectiveCloning();
            sClone.prepareReferences(salesOrders[0].Id);
            sClone.filter('csmso__Sales_Order__c', salesOrders[0], salesOrders[0].clone(true, false, false, false));
            cscfga__Attribute__c attrQ = [SELECT Id, cscfga__Product_Configuration__c, cscfga__Attribute_Definition__c, Name, cscfga__Value__c, cscfga__Display_Value__c, Custom_Cloning_Default_Value__c, Custom_Cloning_Dynamic_Field__c FROM cscfga__Attribute__c WHERE Id = :attributes[0].Id];
            cscfga__Attribute__c cloned = attrQ.clone();
            sClone.filter('cscfga__Attribute__c', attrQ, cloned);
            sClone.cloningFinished(true);
        Test.stopTest();
        
        System.assertEquals(attrQ.cscfga__Value__c, cloned.cscfga__Value__c, 'Values should be same');
    }
    
    /************************************************************************************************
    * Method Name : testSelectiveCloningDynamic
    * Description : Testmethod to test clone process for attribute's cloning default value is Dynamic
    * Parameters  : NA
    * Return      : NA
    ************************************************************************************************/
    @isTest
    static void testSelectiveCloningDynamic() {
        List<Account> accounts = TestDataSetupSO.createAccounts(2);
        List<Contact> contacts = TestDataSetupSO.createContacts(2, accounts);
        List<Opportunity> opportunities = TestDataSetupSO.createOpportunities(2, accounts, contacts);
        List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(2, accounts, opportunities);
        List<cscfga__Product_Definition__c> prodDefinitions = TestDataSetupSO.createProductDefinitions(1);
        List<cscfga__Product_Definition__c> prodDefinitionsDFP = TestDataSetupSO.createProductDefinitions(1);
        List<cscfga__Attribute_Definition__c> attrDefinitions = TestDataSetupSO.createAttributeDefinitions(1, prodDefinitions);
        attrDefinitions[0].Custom_Cloning_Default_Value__c = SalesOrderSelectiveCloning.CUSTOM_CLONING_DYNAMIC;
        attrDefinitions[0].Custom_Cloning_Dynamic_Field__c = 'cscfga__Contract_Term_Period_Description__c';
       //attrDefinitions[0].Custom_Cloning_Dynamic_Field__c = 'Test_Cloning_IMG__c';
        update attrDefinitions;
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, salesOrders);
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDefinitions);
        List<cscfga__Attribute__c> attributes = TestDataSetupSO.createAttributes(1, prodConfigs, attrDefinitions);
        Test.startTest();
            SalesOrderSelectiveCloning sClone = new SalesOrderSelectiveCloning();
            sClone.prepareReferences(salesOrders[0].Id);
            sClone.filter('csmso__Sales_Order__c', salesOrders[0], salesOrders[0].clone(true, false, false, false));
            cscfga__Attribute__c attrQ = [SELECT Id, Name, cscfga__Product_Configuration__c, cscfga__Attribute_Definition__c, cscfga__Value__c, cscfga__Display_Value__c, Custom_Cloning_Default_Value__c, Custom_Cloning_Dynamic_Field__c FROM cscfga__Attribute__c WHERE Id = :attributes[0].Id];
            sClone.filter('cscfga__Attribute__c', attrQ, attrQ.clone());
            List<cscfga__Product_Configuration__c> cfgQ = [SELECT Id, Name  FROM cscfga__Product_Configuration__c WHERE Id = :prodConfigs[0].Id];
            //sClone.filter('cscfga__Product_Configuration__c', cfgQ[0], cfgQ[0].clone());
            sClone.cloningFinished(true);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetOpportunitiesById() {
        SalesOrderSelectiveCloning cloningManager = new SalesOrderSelectiveCloning();
        Id oppId = Opportunity.sObjectType.getDescribe().getKeyPrefix() + '0'.repeat(15);
        
        Test.startTest();
            cloningManager.getOpportunitiesById(oppId);
        Test.stopTest();
    }
    
    @isTest
    private static void testGetOpportunitiesToSO() {
        SalesOrderSelectiveCloning cloningManager = new SalesOrderSelectiveCloning();
        Id soId = csmso__Sales_Order__c.sObjectType.getDescribe().getKeyPrefix() + '0'.repeat(15);
        
        Test.startTest();
            cloningManager.getOpportunitiesById(soId);
        Test.stopTest();
    }
    
    
    @isTest
    static void testSelectiveCloningDefault() {
        List<Account> accounts = TestDataSetupSO.createAccounts(1);
        List<Contact> contacts = TestDataSetupSO.createContacts(1, accounts);
        List<Opportunity> opportunities = TestDataSetupSO.createOpportunities(1, accounts, contacts);
        List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1, accounts, opportunities);
        List<cscfga__Product_Definition__c> prodDefinitions = TestDataSetupSO.createProductDefinitions(1);
        List<cscfga__Attribute_Definition__c> attrDefinitions = TestDataSetupSO.createAttributeDefinitions(1, prodDefinitions);
        attrDefinitions[0].Custom_Cloning_Default_Value__c = SalesOrderSelectiveCloning.CUSTOM_CLONING_DEFAULT;
        attrDefinitions[0].Custom_Cloning_Dynamic_Field__c = 'PO_Number__c';
        attrDefinitions[0].cscfga__Default_Value__c = 'blabla';
        attrDefinitions[0].Shadow_Default_Value__c = 'blabla';
        update attrDefinitions;
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, salesOrders);
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDefinitions);
        List<cscfga__Attribute__c> attributes = TestDataSetupSO.createAttributes(1, prodConfigs, attrDefinitions);
        attributes[0].cscfga__Value__c = 'blabla';
        update attributes;
        
        Test.startTest();
            SalesOrderSelectiveCloning sClone = new SalesOrderSelectiveCloning();
            sClone.prepareReferences(salesOrders[0].Id);
            sClone.filter('csmso__Sales_Order__c', salesOrders[0], salesOrders[0].clone(true, false, false, false));
            cscfga__Attribute__c attrQ = [SELECT Id, Name, cscfga__Attribute_Definition__c, cscfga__Value__c, cscfga__Display_Value__c, Custom_Cloning_Default_Value__c, Custom_Cloning_Dynamic_Field__c, AD_Default_Value__c FROM cscfga__Attribute__c WHERE Id = :attributes[0].Id];
            cscfga__Attribute__c cloned = attrQ.clone();
            sClone.filter('cscfga__Attribute__c', attrQ, cloned);
            sClone.cloningFinished(true);
        Test.stopTest();
        System.assertEquals(attrDefinitions[0].cscfga__Default_Value__c, cloned.cscfga__Value__c, 'Cloned attribute should have a value equal to original default value');
    }    
}