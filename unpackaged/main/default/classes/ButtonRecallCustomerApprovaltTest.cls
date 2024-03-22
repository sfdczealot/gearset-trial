@isTest
private class ButtonRecallCustomerApprovaltTest {
    @isTest
    static void testButtonRecallCustomerApproval(){
        
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        ButtonRecallCustomerApproval button = new ButtonRecallCustomerApproval();
        
        Account acc = TestDataSetupTargetables.createAccount();
        Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'Trigger_OpportunitySplit';
        TE.Enable_del__c = true;
        Insert TE;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Agreement_Status__c = 'Out for Signature';
        opp.Agreement_Status_Date__c = System.now().adddays(-2);
        opp.Subsidiary_Type__c = 'ipp';
        insert opp;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        
        salesOrder.csmso__Opportunity__c = opp.Id;
        insert salesOrder;
        opp.Primary_Sales_Order__c = salesOrder.Id;
        update opp;
        
        String soID = salesOrder.id;
        
        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
        salesOrder.Customer_Approval__c = 'Approved';
        update salesOrder;
        
        Test.startTest();
        button.performAction(soID);
        
        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL;
        update salesOrder;
        button.performAction(soID);
        
        salesOrder.csmso__From__c = Date.today() ;
        salesOrder.csmso__To__c = Date.today().addMonths(3);
        salesOrder.csmso__Status__c = 'Pending Booking';
        
        update salesOrder;
        button.performAction(soID);
        Test.stopTest();
    }
    @isTest
    static void testButtonRecallCustomerApproval2(){
        
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        ButtonRecallCustomerApproval button = new ButtonRecallCustomerApproval();
        
        Account acc = TestDataSetupTargetables.createAccount();
        Id recordTypeId = CS_utl_RecordType.getRecordTypeId(Account.getSObjectType(), 'B2B - Account');
        acc.RecordTypeId = recordTypeId;
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'Trigger_OpportunitySplit';
        TE.Enable_del__c = true;
        Insert TE;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Agreement_Status__c = 'Signed via Client IO Link';
        opp.Agreement_Status_Date__c = System.now().adddays(-2);
        opp.Subsidiary_Type__c = 'ipp';
        insert opp;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        
        salesOrder.csmso__Opportunity__c = opp.Id;
        insert salesOrder;
        opp.Primary_Sales_Order__c = salesOrder.Id;
        update opp;
        
        String soID = salesOrder.id;
        
        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_REJECTED;
        salesOrder.Customer_Approval__c = 'Approved';
        update salesOrder;
        
        csmso__Upload_Approval__c TestCSCAPUP = new csmso__Upload_Approval__c();
        TestCSCAPUP.Name = 'TestCSCAPUP123';
        TestCSCAPUP.csmso__Sales_Order__c = salesorder.id;
        
        insert TestCSCAPUP;
        
        CSCAP__Customer_Approval__c TestCSCAP = new CSCAP__Customer_Approval__c();
        TestCSCAP.CSCAP__Rejected_By_Customer__c = false;
        TestCSCAP.CSCAP__Opportunity__c = opp.Id;
        TestCSCAP.Upload_Approval__c = TestCSCAPUP.id;
        TestCSCAP.CSCAP__Approved_By_Customer__c = false;
        TestCSCAP.CSCAP__Status__c = 'Active';
        
        insert TestCSCAP;
        
        Test.startTest();
        button.performAction(soID);
        
        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_CUSTOMER_APPROVAL;
        update salesOrder;
        button.performAction(soID);
        
        Test.stopTest();
    }
}