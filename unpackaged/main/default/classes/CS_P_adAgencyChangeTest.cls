@isTest 
private class CS_P_adAgencyChangeTest {

	/**
	 * Tests isRecordEligible method, non applicable
	 */
	 
    @testSetup 
    static void testSetup() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        Account acc = TestDataSetupTargetables.createAccount();
         acc.recordtypeid = accRectype;
        
        
        acc.Phone = '2345';
        insert acc;
        
        Account agency = TestDataSetupTargetables.createAccount();
        agency.Type = 'Media Agency';
        agency.recordtypeid = accRectype;
        agency.Phone = '2345';
        insert agency;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Media_Agency2__c = agency.id;
        opp.Agency_Client_del__c = acc.id;
        opp.Subsidiary_Type__c = 'iPP';
         opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        insert opp;
    
        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        insert so;
        
	}

	@isTest()
	public static void testAdAgencyChange() {
	    
        Opportunity opp = 
        [
            SELECT  Id, 
                    name, 
                    Media_Agency2__c,
                    Agency_Client_del__c
            FROM    Opportunity 
            LIMIT   1
        ];      
        
        Test.startTest();
        Map<Id, Opportunity> mapOld = new Map<Id, Opportunity>();
        mapOld.put(opp.Id, opp);
        CS_P_adAgencyChange process = new CS_P_adAgencyChange(mapOld);

        Account accTwo = TestDataSetupTargetables.createAccount();
        insert accTwo;
        
        Account agencyTwo = TestDataSetupTargetables.createAccount();
        agencyTwo.Type = 'Media Agency';
        insert agencyTwo;
    
        opp.Media_Agency2__c = agencyTwo.Id;
        opp.Agency_Client_del__c = accTwo.Id;
        update opp;
    
        process.isRecordEligible(opp);
        process.logic();
        
        csmso__Sales_Order__c so = 
        [
            SELECT  Id, 
                    name, 
                    Agency_Final__c,
                    Advertiser_Final__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];   
        
        //System.assertEquals(agencyTwo.Id, so.Agency_Final__c);
        //System.assertEquals(accTwo.Id, so.Advertiser_Final__c);
		Test.stopTest();
    }

}