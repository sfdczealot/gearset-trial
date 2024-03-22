@IsTest
public class CS_P_UpdatePrimarySOTest {

    @IsTest
    public static void testPrimarySOCheck() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');
        Account acc = TestDataSetupTargetables.createAccount();
        acc.RecordTypeId = recordTypeId;
        insert acc;

        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;

        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;

        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.SO_Start_Date__c = system.today();
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'In Progresws';
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Advertiser__c = acc.id;
        insert salesOrder;

        salesOrder = [SELECT Id, Primary_Sales_Order__c,SO_Start_Date_Manual__c,SO_Start_Date__c,Customer_Approval__c, csmso__Opportunity__c FROM csmso__Sales_Order__c LIMIT 1];

        Test.startTest();
        CS_P_UpdatePrimarySO soCheck = new CS_P_UpdatePrimarySO(null);

        soCheck.isRecordEligible((SObject) salesOrder);
        soCheck.logic();

        Test.stopTest();

        System.assertEquals(soCheck.applicableObjects.isEmpty(), false);
        Opportunity afterUpdateOpp = [SELECT Id, Primary_Sales_Order__c,Order_Date__c FROM Opportunity WHERE Id = :salesOrder.csmso__Opportunity__c];

        System.assertEquals(afterUpdateOpp.Primary_Sales_Order__c, salesOrder.Id);
    }
}