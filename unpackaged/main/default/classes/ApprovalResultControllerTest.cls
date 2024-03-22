@isTest
private class ApprovalResultControllerTest {

    @testSetup static void testSetup(){

	    CS_utl_User.disableAllTriggers(UserInfo.getUserId());
	    
	    Account[] accs = TestDataSetupBasic.createAccounts(5);   
	    
		Account testAccount = TestDataSetupSO.createAccount();
		insert  testAccount;
		Contact testContact = TestDatasetupSO.createContact(testAccount);
		insert testContact;
		Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
		insert testOpportunity;
		csmso__Sales_Order__c testSO = TestDatasetupSO.createSalesOrder(testAccount, testOpportunity);
		insert testSO;
        System.debug('soid'+ testSO.id);
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
        
        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDef =  TestDataSetupSO.createAttributeDefinitions(1,prodDef);
        
        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,new List<csmso__Sales_Order__c>{testSO});
        
        Attachment attach=new Attachment();   	
    	attach.Name='PricingApprovalSnapshot_LineResult.json';
    	//Blob bodyBlob=Blob.valueOf('[{"ProductConfigurationId":"a676E0000008gMbQAI","ProductBasketId":"a4u6E0000005pEsQAI","AttributeMap":{"Overbook":{"Sales2":false,"Sales1":false,"Legal":false,"Inventory":true,"Finance":false,"EvaluateLists":false,"Customer":false,"Compliance":false,"AttributeValue":"Yes","AttributeName":"Overbook"}}}]');
        Blob bodyBlob=Blob.valueOf('[{"ProductConfigurationId":"a6d1w000000M0DsAAK","ProductBasketId":"a6a1w0000000RwoAAE","ApprovalResultList":[{"propertyName":"Sales_Order__r.Order_Type__c","oldValue":"Direct Commercial","newValue":"Direct Commercial","message":"","approvalType":"Pricing"},{"propertyName":"Price","oldValue":"0.0542","newValue":"0.0000","message":"Price less than Minimum Line Value","approvalType":"Pricing"},{"propertyName":"Price","oldValue":"0.0542","newValue":"0.0000","message":"","approvalType":"Pricing"}]},{"ProductConfigurationId":"a6d1w000000M0DOAA0","ProductBasketId":"a6a1w0000000RwoAAE","ApprovalResultList":[{"propertyName":"Sales_Order__r.Order_Type__c","oldValue":"Direct Commercial","newValue":"Direct Commercial","message":"","approvalType":"Pricing"},{"propertyName":"Price","oldValue":"0.0542","newValue":"0.0553","message":"Price less than Minimum Line Value","approvalType":"Pricing"},{"propertyName":"Price","oldValue":"0.0542","newValue":"0.0553","message":"","approvalType":"Pricing"}]}]');
        attach.Body=bodyBlob;
        attach.parentId=prodBaskets[0].id;
        insert attach;
    }

    @isTest
    public static void controllerTest() {
        
        csmso__Sales_Order__c salesOrder = [SELECT Id from csmso__Sales_Order__c];
        
        Test.startTest();
        PageReference pageRef = Page.ApprovalResult;
        pageRef.getParameters().put('Id', String.valueOf(salesOrder.Id));
        Test.setCurrentPage(pageRef);
        ApprovalResultController testController = new ApprovalResultController();
        
        testController.loadData(salesOrder.Id);
        Test.stopTest();

    }
}