@isTest
public class BatchToPostChatterforDunningTest {
    @testSetup
    public static void setup(){
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            sb.Country__c = 'Malaysia';
             sb.subsidiary_code__c='ipp';
            update sb;
            Trigger_Execute__c obj = new Trigger_Execute__c(name='Trigger_OpportunitySplit');
            insert obj;
            
            Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
           
            Account acc = TestDataSetupBasic.createAccount();
            acc.recordTypeId = recordTypeId;
           
            insert acc;
            
            Trigger_Execute__c customsetting1=new Trigger_Execute__c();
            customsetting1.Name='PGBillingEntityTrigger';
            customsetting1.Enable_del__c=true;
            insert customsetting1;
            
            Billing_Entity__c  nsDetail = new Billing_Entity__c (account__c= acc.id,Subsidiary__c=sb.ID, Customer_Status__c='Suspended');
            insert nsDetail;
            Contact con = TestDataSetupBasic.createContact(acc);
            insert con;
            
            Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
            opp.Suspended_chatter_Date__c = system.today();
            
            opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
            
            insert opp;
            
            csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
            insert so;
            csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
            insert testAdServer;
            
            cscfga__Product_Basket__c  ProdBasket = TestDataSetupTargetables.createProdBasket(so);
            cscfga__Product_Configuration__c ProdConfig = TestDataSetupTargetables.createProdConfig(ProdBasket);
            
            csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);
            testFulfilment.csdf__Ad_Server_Id__c = '123499';
            testFulFilment.csdf__Ad_server__c = testAdServer.Id;
            testFulfilment.csdf__Status__c = 'Ready';
            
            
            insert testFulfilment;
            csdf__Fulfilment_Item__c FulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,so,testFulfilment);
            FulfilmentItem.Flight_Beginning_Line_Item__c = System.today();
            FulfilmentItem.csdf__Status__c = 'ready';
            FulfilmentItem.Served_By__c = 'developer listings';
            FulfilmentItem.Listing_ID__c = '12345';
            insert FulfilmentItem;
        }
    }
    @isTest
    public static void test(){
             test.startTest();
        Opportunity opp =[select id from opportunity];
        opp.Approval_Status__c ='OMC Approval Approved';
        opp.stagename = 'Closed won';
        update opp;
   
        database.executeBatch(new BatchToPostChatterforDunning());
        test.stopTest();
    } 
    
}