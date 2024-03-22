@isTest 
private class CS_P_SORejectCommentTest {

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
        so.csmso__Status__c = StandardSalesOrderStateManager.SO_RESERVED;
        so.Legal_Check__c = CS_const_SalesOrder.ApprovalStatus_Pending;
        so.Compliance_Check__c = CS_const_SalesOrder.ApprovalStatus_Pending;
        so.Comments__c = '';
        insert so;
        
	}

	@isTest()
	public static void testLegalRejected() {
	    
        csmso__Sales_Order__c oldSo = 
        [
            SELECT  Id, 
                    name, 
                    csmso__Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Comments__c,
                    Legal_Check__c,
                    Compliance_Check__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];   

        csmso__Sales_Order__c newso = 
        [
            SELECT  Id, 
                    name, 
                    csmso__Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Comments__c,
                    Legal_Check__c,
                    Compliance_Check__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];   
        

        
        Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
        mapOld.put(oldSo.Id, oldSo);

        newso.Legal_Check__c = CS_const_SalesOrder.ApprovalStatus_Rejected;
        update newso;

        Test.startTest();

        CS_P_SORejectComment process = new CS_P_SORejectComment(mapOld);
        process.isRecordEligible(newso);

        System.assertEquals(process.applicableObjects.size(), 1, 'Expecting one SO in applicable objects!');

        process.logic();

        System.assertEquals(CS_const_SalesOrder.ApprovalStatus_Pending, process.applicableObjects.get(newso.Id).Legal_Check__c, 'Expected Pending Status for Legal Check');
        System.assertEquals('warning', process.applicableObjects.get(newso.Id).csmso__Process_Message_Type__c, 'Expected "warning" in Process Message Type field');
        System.assertEquals(Label.SO_Compliance_Legal_Reject_No_Comment, process.applicableObjects.get(newso.Id).csmso__Process_Message__c, 'Expected warning message in Process Message field');

        Test.stopTest();
    }

    @isTest()
	public static void testComplianceRejected() {
	    
        csmso__Sales_Order__c oldSo = 
        [
            SELECT  Id, 
                    name, 
                    csmso__Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Comments__c,
                    Legal_Check__c,
                    Compliance_Check__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];   

        csmso__Sales_Order__c newso = 
        [
            SELECT  Id, 
                    name, 
                    csmso__Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Comments__c,
                    Legal_Check__c,
                    Compliance_Check__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];   
        

        
        Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
        mapOld.put(oldSo.Id, oldSo);

        newso.Compliance_Check__c = CS_const_SalesOrder.ApprovalStatus_Rejected;
        update newso;

        Test.startTest();
        CS_P_SORejectComment process = new CS_P_SORejectComment(mapOld);
        process.isRecordEligible(newso);

        System.assertEquals(process.applicableObjects.size(), 1, 'Expecting one SO in applicable objects!');

        process.logic();

        System.assertEquals(CS_const_SalesOrder.ApprovalStatus_Pending, process.applicableObjects.get(newso.Id).Compliance_Check__c, 'Expected Pending Status for Legal Check');
        System.assertEquals('warning', process.applicableObjects.get(newso.Id).csmso__Process_Message_Type__c, 'Expected "warning" in Process Message Type field');
        System.assertEquals(Label.SO_Compliance_Legal_Reject_No_Comment, process.applicableObjects.get(newso.Id).csmso__Process_Message__c, 'Expected warning message in Process Message field');

        Test.stopTest();
    }

    @isTest()
	public static void testLegalRejectSuccess() {
	    
        csmso__Sales_Order__c oldSo = 
        [
            SELECT  Id, 
                    name, 
                    csmso__Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Comments__c,
                    Legal_Check__c,
                    Compliance_Check__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];   

        csmso__Sales_Order__c newso = 
        [
            SELECT  Id, 
                    name, 
                    csmso__Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Comments__c,
                    Legal_Check__c,
                    Compliance_Check__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];   
        
        oldSo.csmso__Process_Message_Type__c = 'warning';
        oldSo.csmso__Process_Message__c = Label.SO_Compliance_Legal_Reject_No_Comment;
        update oldSo;

        Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
        mapOld.put(oldSo.Id, oldSo);

        newso.Compliance_Check__c = CS_const_SalesOrder.ApprovalStatus_Rejected;
        newso.csmso__Status__c = StandardSalesOrderStateManager.SO_RESERVE_REJECTED;
        newso.Comments__c = 'random comment';
        newso.csmso__Process_Message_Type__c = 'warning';
        newso.csmso__Process_Message__c = Label.SO_Compliance_Legal_Reject_No_Comment;
        update newso;

        Test.startTest();
        CS_P_SORejectComment process = new CS_P_SORejectComment(mapOld);
        process.isRecordEligible(newso);

        System.assertEquals(process.applicableObjects.size(), 1, 'Expecting one SO in applicable objects!');

        process.logic();

        System.assertEquals(CS_const_SalesOrder.ApprovalStatus_Rejected, process.applicableObjects.get(newso.Id).Compliance_Check__c, 'Expected Rejected Status for Compliance Check');
        System.assertEquals('', process.applicableObjects.get(newso.Id).csmso__Process_Message_Type__c, 'Expected "warning" in Process Message Type field');
        System.assertEquals('', process.applicableObjects.get(newso.Id).csmso__Process_Message__c, 'Expected warning message in Process Message field');
        System.assertEquals(StandardSalesOrderStateManager.SO_RESERVE_REJECTED, process.applicableObjects.get(newso.Id).csmso__Status__c, 'Expected So to have status'+StandardSalesOrderStateManager.SO_RESERVE_REJECTED);

        Test.stopTest();
    }

    @isTest()
	public static void testLegalComplianceApproveSuccess() {
	    
        csmso__Sales_Order__c oldSo = 
        [
            SELECT  Id, 
                    name, 
                    csmso__Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Comments__c,
                    Legal_Check__c,
                    Compliance_Check__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];   

        csmso__Sales_Order__c newso = 
        [
            SELECT  Id, 
                    name, 
                    csmso__Status__c,
                    csmso__Process_Message_Type__c,
                    csmso__Process_Message__c,
                    Comments__c,
                    Legal_Check__c,
                    Compliance_Check__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];   
        
        oldSo.csmso__Process_Message_Type__c = 'warning';
        oldSo.csmso__Process_Message__c = Label.SO_Compliance_Legal_Reject_No_Comment;
        oldSo.Comments__c = 'random comment';
        update oldSo;

        Map<Id, csmso__Sales_Order__c> mapOld = new Map<Id, csmso__Sales_Order__c>();
        mapOld.put(oldSo.Id, oldSo);

        newso.Compliance_Check__c = CS_const_SalesOrder.ApprovalStatus_Approved;
        newso.Legal_Check__c = CS_const_SalesOrder.ApprovalStatus_Approved;
        newso.Comments__c = 'random comment';
        newso.csmso__Process_Message_Type__c = 'warning';
        newso.csmso__Process_Message__c = Label.SO_Compliance_Legal_Reject_No_Comment;
        update newso;

        Test.startTest();
        CS_P_SORejectComment process = new CS_P_SORejectComment(mapOld);
        process.isRecordEligible(newso);

        System.assertEquals(process.applicableObjects.size(), 1, 'Expecting one SO in applicable objects!');

        process.logic();

        System.assertEquals(CS_const_SalesOrder.ApprovalStatus_Approved, process.applicableObjects.get(newso.Id).Compliance_Check__c, 'Expected Approved Status for Compliance Check');
        System.assertEquals(CS_const_SalesOrder.ApprovalStatus_Approved, process.applicableObjects.get(newso.Id).Legal_Check__c, 'Expected Approved Status for Legal Check');
        System.assertEquals('', process.applicableObjects.get(newso.Id).csmso__Process_Message_Type__c, 'Expected empty Process Message Type field');
        System.assertEquals('', process.applicableObjects.get(newso.Id).csmso__Process_Message__c, 'Expected warning message in Process Message field');

        Test.stopTest();
    }
}