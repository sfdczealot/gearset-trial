@isTest
public class updateSOApprovalCheckbox_test {
    	@testSetup 
    public static void  setupCommonData() {  

        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        Account acc = TestDataSetupTargetables.createAccount();
         acc.RecordTypeId=schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.RecordTypeId=schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        so.SO_Lines_Gross_Total__c = 6;
        so.Flighting_Pending_Check_Avail__c = false;
        so.SO_Lines_All_Valid__c = true;                                
        insert so;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
        insert prodBasket;
                        
        csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc); 
        insert testFulfilment;
    }
        
    @isTest
    public static void CS_P_StatusUpdateTest_method4() {
        csdf__Fulfilment__c testFulfilment = [SELECT id, name
                                              FROM csdf__Fulfilment__c LIMIT 1];
        
        csmso__Sales_Order__c salesOrder = [SELECT id, name
                                            FROM csmso__Sales_Order__c LIMIT 1];
        
        cscfga__Product_Basket__c prodBasket = [SELECT id, name from cscfga__Product_Basket__c LIMIT 1];
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.Insertion_Quantity__c = 5;
        prodConfig.csmso__Availability_Check_Status__c = 'From Flighting';
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        prodConfig.Flight_Begin__c = null;
        prodConfig.Flight_End__c = null;
        prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_Draft;
        insert prodConfig;  
        
        csdf__Fulfilment_Item__c fulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig, salesOrder, testFulfilment);
        fulfilmentItem.csdf__Status__c = CS_const_SalesOrder.Status_Draft;
        insert fulfilmentItem;
        
        //prodConfig.Fulfilment_Item__c = fulfilmentItem.Id;
        prodConfig.cscfga__Configuration_Status__c = 'Requires Update';
        prodConfig.FLAG_Running_in_MLE__c = true;
         prodConfig.Insertion_Quantity__c = 9;
        update prodConfig;
        
        Test.startTest();
        // update prodConfig;
        delete prodConfig;
        Test.stopTest(); 
        

    }
    
}