/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description : Test Class for CS_P_PrimarySOChange
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author     : Kalyan Erraguntla <kalyan.erraguntla@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/

@isTest
public class CS_P_PrimarySOChangeTest {

    /**
     *  Checks if record is eligible
     */ 
    @isTest
    public static void testIsRecordEligible() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();

        salesOrder.csmso__Opportunity__c = opp.id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Booked';
        salesOrder.Applicable_IO_Volume_Discount_Range__c =1;
        salesOrder.Primary_Sales_Order__c = false;
        insert salesOrder;

        CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi2 = [SELECT Id FROM csmso__SalesOrderAPI__c LIMIT 1];
        delete soapi2;
        
        Map<id,csmso__Sales_Order__c> oldObjects = new Map<id,csmso__Sales_Order__c>();
        oldObjects.put(salesOrder.id,salesOrder);
        
        Test.startTest();
        
        salesOrder.Primary_Sales_Order__c = true;
        update salesOrder;
        
        Test.stopTest();
    }

    @isTest
    public static void testMultipleSOs() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Booked';
        salesOrder.Applicable_IO_Volume_Discount_Range__c =1;
        salesOrder.Primary_Sales_Order__c = false;
        insert salesOrder;

        csmso__Sales_Order__c salesOrder2 = new csmso__Sales_Order__c();
        salesOrder2.csmso__Opportunity__c = opp.id;
        salesOrder2.isTestRunning__c = true;
        salesOrder2.SO_Lines_All_Valid__c = true;
        salesOrder2.csmso__Status__c = 'Booked';
        salesOrder2.Applicable_IO_Volume_Discount_Range__c =1;
        salesOrder2.Primary_Sales_Order__c = true;
        insert salesOrder2;

        CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi2 = [SELECT Id FROM csmso__SalesOrderAPI__c LIMIT 1];
        delete soapi2;
        
        Map<id,csmso__Sales_Order__c> oldObjects = new Map<id,csmso__Sales_Order__c>();
        oldObjects.put(salesOrder.id,salesOrder);
        
        Test.startTest();
        
        salesOrder.Primary_Sales_Order__c = true;
        update salesOrder;
        
        Test.stopTest();
    }

    /**
     *  Checks if record is not eligible
     */	
	@isTest
    public static void testIsRecordNotEligible() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

    	Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();

        salesOrder.csmso__Opportunity__c = opp.id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Booked';
        salesOrder.Applicable_IO_Volume_Discount_Range__c =1;
    	salesOrder.Primary_Sales_Order__c = true;
    
    
        insert salesOrder;
        
        Map<id,csmso__Sales_Order__c> oldObjects = new Map<id,csmso__Sales_Order__c>();
        oldObjects.put(salesOrder.id,salesOrder);
        
        Test.startTest();
        CS_P_PrimarySOChange soChange = new CS_P_PrimarySOChange(oldObjects);
       
        salesOrder.Primary_Sales_Order__c = false;
        update salesOrder;
       
        soChange.isRecordEligible((sobject)salesOrder);
        soChange.logic();
        
        system.assertequals(soChange.oldObjects.get(salesOrder.id),salesOrder);
        system.assertequals(soChange.applicableObjects.isEmpty(),true);
        
        Test.stopTest();
    }
   
}