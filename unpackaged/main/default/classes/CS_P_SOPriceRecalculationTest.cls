@isTest 
private class CS_P_SOPriceRecalculationTest {

	/**
	 * Tests isRecordEligible method, non applicable
	 */
	 
    @testSetup 
    static void testSetup() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Account agency = TestDataSetupTargetables.createAccount();
        agency.Type = 'Media Agency';
        insert agency;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Media_Agency2__c = agency.id;
        opp.Agency_Client_del__c = acc.id;
        insert opp;
    
        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        so.Media_Agency_Commission__c = 10;
        insert so;

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
        
	}

	@isTest()
	public static void testRecalculation() {
	    
        csmso__Sales_Order__c so = 
        [
            SELECT  Id, 
                    name, 
                    Advertiser_Final__c,
                    Agency_Final__c,
                    csmso__Status__c,
                    SO_Lines_Number_Of_Lines__c,
                    Sold__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];      
        
        Test.startTest();
        Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
        mapOld.put(so.Id, so);
        CS_P_SOPriceRecalculation process = new CS_P_SOPriceRecalculation(mapOld);

        Account accTwo = TestDataSetupTargetables.createAccount();
        insert accTwo;
        
        so.Advertiser_Final__c = accTwo.Id;
        so.csmso__Status__c = CS_const_SalesOrder.Status_PriceRecalculationRequired;
        so.SO_Lines_Price_Recalculated__c = 2;
        so.SO_Lines_Number_of_lines__c = 1;
        so.Sold__c = true;
        update so;
        
        so = 
        [
            SELECT  Id, 
                    name, 
                    Advertiser_Final__c,
                    Agency_Final__c,
                    csmso__Status__c,
                    SO_Lines_Number_Of_Lines__c,
                    Media_Agency_Commission__c,
                    SO_Lines_Price_Recalculated__c,
                    Previous_Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Sold__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];      
        
        process.isRecordEligible(so);
        process.logic();
		Test.stopTest();
    }

    @isTest()
    public static void testRecalculation2() {
        
        csmso__Sales_Order__c so = 
        [
            SELECT  Id, 
                    name, 
                    Advertiser_Final__c,
                    Agency_Final__c,
                    csmso__Status__c,
                    SO_Lines_Number_Of_Lines__c,
                    Sold__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];      
        
        Test.startTest();
        Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
        mapOld.put(so.Id, so);
        CS_P_SOPriceRecalculation process = new CS_P_SOPriceRecalculation(mapOld);

        Account accTwo = TestDataSetupTargetables.createAccount();
        insert accTwo;
        
        so.Advertiser_Final__c = accTwo.Id;
        so.csmso__Status__c = CS_const_SalesOrder.Status_InProgress;
        so.SO_Lines_Price_Recalculated__c = 2;
        so.SO_Lines_Number_of_lines__c = 1;
        update so;
        
        so = 
        [
            SELECT  Id, 
                    name, 
                    Advertiser_Final__c,
                    Agency_Final__c,
                    csmso__Status__c,
                    SO_Lines_Number_Of_Lines__c,
                    Media_Agency_Commission__c,
                    SO_Lines_Price_Recalculated__c,
                    Previous_Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Sold__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];      
        
        process.isRecordEligible(so);
        process.logic();
        Test.stopTest();
    }

	@isTest()
	public static void testTwo() {
	    
        csmso__Sales_Order__c so = 
        [
            SELECT  Id, 
                    name, 
                    Advertiser_Final__c,
                    Agency_Final__c,
                    csmso__Status__c,
                    SO_Lines_Number_Of_Lines__c,
                    Media_Agency_Commission__c,
                    Sold__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];      
        
        
        Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
        mapOld.put(so.Id, so);
        CS_P_SOPriceRecalculation process = new CS_P_SOPriceRecalculation(mapOld);
        
        so.Media_Agency_Commission__c = 20;
        so.csmso__Status__c = CS_const_SalesOrder.Status_Draft;
        so.SO_Lines_Number_of_lines__c = 1;
        update so;
        
        Test.startTest();
        so = 
        [
            SELECT  Id, 
                    name, 
                    Advertiser_Final__c,
                    Agency_Final__c,
                    csmso__Status__c,
                    SO_Lines_Number_Of_Lines__c,
                    Media_Agency_Commission__c,
                    SO_Lines_Price_Recalculated__c,
                    Previous_Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Billing_Calendar__c,
                    Sold__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];      
        
        process.isRecordEligible(so);
        process.logic();

		Test.stopTest();
    }

}