@IsTest
public class CS_P_SOAgreementStatusDateModifiedTest {
    /**
      *  Checks if record is eligible
      */
    @IsTest
    public static void test_isRecordEligible() {
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

        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        insert salesOrder;

        Date fromdate = Date.valueOf('2018-01-01 00:00:00');
        opp.Agreement_Status_Date__c = fromdate;
        opp.Primary_Sales_Order__c = salesOrder.Id;
        opp.SO_for_Customer_Approval__c = salesOrder.Id;
        update opp;

        Opportunity oldOpp = [SELECT Id, Name, Agreement_Status_Date__c, Primary_Sales_Order__c FROM Opportunity WHERE Id = :opp.Id];
        Map<Id, Opportunity> oldObjects = new Map<Id, Opportunity>();
        oldObjects.put(oldOpp.Id, oldOpp);

        Datetime currentdate = System.now();
        opp.Agreement_Status_Date__c = currentdate;
        update opp;

        Test.startTest();
        CS_P_SOAgreementStatusDateModified soChange = new CS_P_SOAgreementStatusDateModified(oldObjects);
        soChange.isRecordEligible(opp);
        soChange.logic();

        List<csmso__Sales_Order__c> applicableSalesOrders = [
                SELECT Id,
                        csmso__Status__c,
                        csmso__Opportunity__r.Id
                FROM csmso__Sales_Order__c
                WHERE Id = :salesOrder.Id
        ];
        System.assertEquals(soChange.oldOpps.get(oldOpp.Id), oldOpp);
        System.assertEquals(!soChange.applicableObjects.isEmpty(), true);
        System.assertEquals(soChange.applicableObjects.get(opp.Id), opp);
        System.assertEquals(soChange.applicableObjects.size(), 1);

        Test.stopTest();
    }

    @IsTest
    public static void test_isReadyForCustomerApproval() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;

        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE DeveloperName = 'Ad_Sales' LIMIT 1];

        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        if(recordTypeList.size() != 0) {
                opp.RecordTypeId = recordTypeList[0].Id;
        }
        insert opp;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;

        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;

        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();

        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_ReadyForCustomerApproval;
        insert salesOrder;

        Date fromdate = Date.valueOf('2018-01-01 00:00:00');
        opp.Agreement_Status_Date__c = fromdate;
        opp.Primary_Sales_Order__c = salesOrder.Id;
        opp.SO_for_Customer_Approval__c = salesOrder.Id;
        opp.Agreement_Status__c = 'Out for Signature';
        update opp;

        Opportunity oldOpp = [SELECT Id, Name, Agreement_Status_Date__c, Primary_Sales_Order__c FROM Opportunity WHERE Id = :opp.Id];
        Map<Id, Opportunity> oldObjects = new Map<Id, Opportunity>();
        oldObjects.put(oldOpp.Id, oldOpp);

        Datetime currentdate = System.now();
        opp.Agreement_Status_Date__c = currentdate;
        opp.Agreement_Status__c = 'Signed';
        update opp;

        Test.startTest();
        CS_P_SOAgreementStatusDateModified soChange = new CS_P_SOAgreementStatusDateModified(oldObjects);
        soChange.isRecordEligible(opp);
        soChange.logic();

        List<csmso__Sales_Order__c> applicableSalesOrders = [
                SELECT Id,
                        csmso__Status__c,
                        csmso__Opportunity__r.Id
                FROM csmso__Sales_Order__c
                WHERE Id = :salesOrder.Id
        ];

        Test.stopTest();
    }

    @IsTest
    public static void test_isReadyForCustomerApprovalRejected() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;

        List<RecordType> recordTypeList = [SELECT Id FROM RecordType WHERE DeveloperName = 'Ad_Sales' LIMIT 1];

        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        if(recordTypeList.size() != 0) {
                opp.RecordTypeId = recordTypeList[0].Id;
        }
        insert opp;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;

        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;

        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();

        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_ReadyForCustomerApproval;
        salesOrder.Order_Synced_before_final_approval__c = true;
        insert salesOrder;

        Date fromdate = Date.valueOf('2018-01-01 00:00:00');
        opp.Agreement_Status_Date__c = fromdate;
        opp.Primary_Sales_Order__c = salesOrder.Id;
        opp.SO_for_Customer_Approval__c = salesOrder.Id;
        opp.Agreement_Status__c = 'Out for Signature';
        update opp;

        Opportunity oldOpp = [SELECT Id, Name, Agreement_Status_Date__c, Primary_Sales_Order__c FROM Opportunity WHERE Id = :opp.Id];
        Map<Id, Opportunity> oldObjects = new Map<Id, Opportunity>();
        oldObjects.put(oldOpp.Id, oldOpp);

        Datetime currentdate = System.now();
        opp.Agreement_Status_Date__c = currentdate;
        opp.Agreement_Status__c = 'Cancelled / Declined';
        update opp;

        Test.startTest();
        CS_P_SOAgreementStatusDateModified soChange = new CS_P_SOAgreementStatusDateModified(oldObjects);
        soChange.isRecordEligible(opp);
        soChange.logic();

        List<csmso__Sales_Order__c> applicableSalesOrders = [
                SELECT Id,
                        csmso__Status__c,
                        csmso__Opportunity__r.Id
                FROM csmso__Sales_Order__c
                WHERE Id = :salesOrder.Id
        ];

        Test.stopTest();
    }
}