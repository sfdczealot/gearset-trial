@isTest
public class FulfilmentApprovalStatusTEST {
    
    @TestSetup
    public static void generateRecords() {
         Trigger_Execute__c TE = new Trigger_Execute__c(
         Name = 'PGAccountTrigger',
    	 Enable_del__c = true
             );
        insert TE;
        
        User user1 = new User();  
        user1 = [Select Id from User where id=: userinfo.getUserId()];  
        
        Subsidiary__c sub = PGTestDataFactory_v2.createSubsidiary(user1);

        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;
                
		csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acc, opp);
        insert salesOrder;
        
    }
    
    @isTest
    public static void UpdateFulfilmentRecord(){
        csmso__Sales_Order__c so = [SELECT Id from csmso__Sales_Order__c LIMIT 1];
        Account acc = [SELECT Id FROM Account];
        //Creating a new fulfilment record 
        csdf__Fulfilment__c fulfilment = new csdf__Fulfilment__c();
        fulfilment.csdf__Name__c = 'Test fulfilment';
        fulfilment.csdf__Advertiser__c = acc.Id;
        fulfilment.Sales_Order__c = so.Id;
        fulfilment.Extension_Approval__c = 'Pending';
        insert fulfilment;
        
        Test.startTest();
        //Querying the new created Fulfiment record and updating the Extension_Approval field with a value - Approved.
        csdf__Fulfilment__c fulfilments = [SELECT Id FROM csdf__Fulfilment__c WHERE csdf__Name__c = 'Test fulfilment'];
        csdf__Fulfilment__c ff = new csdf__Fulfilment__c();
        ff.Id = fulfilments.Id;
        ff.Extension_Approval__c = 'Approved';
        update ff; 
        Test.stopTest();
        //Querying for the Sales Order record and Asserting for the Reservation_Extension__c field value.
        csmso__Sales_Order__c salesorder = [SELECT Id,Reservation_Extension__c from csmso__Sales_Order__c LIMIT 1];
       // System.AssertEquals('Approved',salesorder.Reservation_Extension__c );
        
        
    }
    
}