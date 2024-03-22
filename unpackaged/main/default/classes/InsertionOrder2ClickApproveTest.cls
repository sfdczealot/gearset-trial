@isTest
private class InsertionOrder2ClickApproveTest {
    
    @isTest 
    static void test_method_one() {
        Account[] accounts = TestDataSetupSO.createAccounts(1);
        Contact[] contacts = TestDataSetupSO.createContacts(1, accounts);
        Opportunity[] opportunities = TestDataSetupSO.createOpportunities(1, accounts, contacts);

        csmso__Sales_Order__c[] salesOrders = TestDataSetupSO.createSalesOrders(1, accounts, opportunities);
        csmso__Upload_Approval__c uploadApproval =  TestDataSetupSO.createUploadApproval(salesOrders[0]);
        insert uploadApproval;
        ApexPages.currentPage().getParameters().put('soId', salesOrders[0].id);
        ApexPages.currentPage().getParameters().put('Id', uploadApproval.id);

        Attachment attach = new Attachment();
        attach.parentId = salesOrders[0].id;
        attach.name = 'Attachment Test';
        attach.body =Blob.valueOf('Test');
        insert attach;

        Attachment attach2 = new Attachment();
        attach2.parentId = uploadApproval.id;
        attach2.name = 'Attachment Test2';
        attach2.body =Blob.valueOf('Test');
        insert attach2;

        CSCAP__Click_Approve_Setting__c setting = new CSCAP__Click_Approve_Setting__c();
        setting.Name = 'Sites Approval default - Sales Order';
        insert setting;
        InsertionOrder2ClickApproveController testController = new InsertionOrder2ClickApproveController();
        testController.insertionOrder2ClickApprove();

    }

}