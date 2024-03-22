@isTest 
private class CS_P_OpportunityNameChangeTest {

	/**
	 * Tests isRecordEligible method, non applicable
	 */
	 
    @testSetup 
    static void testSetup() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());

		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
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
        insert so;
        
	}

	@isTest()
	public static void testNameChange() {
	    
        Opportunity opp = 
        [
            SELECT  Id, 
                    Name
            FROM    Opportunity 
            LIMIT   1
        ];      
        
        Test.startTest();
        Map<Id, Opportunity> mapOld = new Map<Id, Opportunity>();
        mapOld.put(opp.Id, opp);
        CS_P_OpportunityNameChange process = new CS_P_OpportunityNameChange(mapOld);

        opp.Name = 'process test';
        update opp;
    
        process.isRecordEligible(opp);
        process.logic();
        
        csmso__Sales_Order__c so = 
        [
            SELECT  Id, 
                    name, 
                    Opportunity_Name__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];   
        
        //System.assertEquals(so.Opportunity_Name__c, opp.Name);
		Test.stopTest();
    }

}