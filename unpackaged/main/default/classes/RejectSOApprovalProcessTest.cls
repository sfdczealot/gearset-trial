@IsTest
public class RejectSOApprovalProcessTest {
    @IsTest
    public static void test_isInProgress() {
        Account acc = TestDataSetupTargetables.createAccount();
        acc.recordtypeid =Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();

        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
         
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        subsidiary__c subs = PGTestDataFactory.createSubsidiary();
        subs.Subsidiary_Code__c ='PG SG';
        update subs;
       opp.recordTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp.subsidiary__c = subs.Id;
        insert opp;
        payment_term__c pm = new Payment_term__c(name='Monthly',NS_Payment_Term_ID__c=12);
        insert pm; 
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        testProDef.name='MPD Subscriptions';
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Status__c = 'Pending SD Approval';
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.NetSuite_Payment_Term__c = pm.id;
        salesOrder.Advertiser_Final__c = acc.Id;
        salesOrder.Approval_Requester_Comment__c='true';
        salesOrder.SD_approval__c='pending'; 
        insert salesOrder;
     Approval.ProcessSubmitRequest app = new Approval.ProcessSubmitRequest();
		app.setObjectId(salesOrder.id);
		Approval.ProcessResult result = Approval.process(app);

            salesOrder.csmso__Status__c = 'rejected';
        update salesOrder;
            }
    
}