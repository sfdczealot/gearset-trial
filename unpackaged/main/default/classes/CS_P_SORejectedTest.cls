@isTest 
private class CS_P_SORejectedTest {

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
	public static void testSOrejected() {
	    
        csmso__Sales_Order__c so = 
        [
            SELECT  Id, 
                    name, 
                    csmso__Status__c,
                    Legal_Check__c,
                    Rejection_Count__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];      
        
        Test.startTest();
        Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
        mapOld.put(so.Id, so);
        CS_P_SORejected process = new CS_P_SORejected(mapOld);
        
        so.csmso__Status__c = CS_const_SalesOrder.Status_Reserved;
        so.Legal_Check__c = CS_const_SalesOrder.ApprovalStatus_Rejected;
        so.Rejection_Count__c = 0;
        update so;
        
        process.isRecordEligible(so);
        process.logic();
        
        so = 
        [
            SELECT  Id, 
                    name, 
                    csmso__Status__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];  
        
        System.assert(so.csmso__Status__c != CS_const_SalesOrder.Status_ReservationRejected);
		Test.stopTest();
    }

}