@isTest
public class TaskEmailTemplateController_test {
    @testSetup
    public static void testData(){
        
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            PGTestDataFactory_v2.initSetupData();
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Pricebook2 standardPB = PGTestDataFactory_v2.CreateStandardPricebook(sb);
            account acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232', thisUser, sb);
            account acc_b2b=PGTestDataFactory_v2.createAgencyAccount('abc def','1232', thisUser, sb);
            Opportunity opp = PGTestDataFactory_v2.createB2cSubscriptionOpty(acc_b2c,thisUser,sb,standardPB, 'B2C - Upgrade');
            csmso__Sales_Order__c so = new csmso__Sales_Order__c(Advertiser_Final__c = acc_b2b.id,Primary_Sales_Order__c = true,
                                                                 csmso__Opportunity__c = opp.Id, Sale_type__c = 'Sales', csmso__Advertiser__c = acc_b2b.Id, Billing_Email__c = 'test@abc.com', 
                                                                 Bill_To_Account_Final__c = acc_b2b.Id, Bill_To_Account__c = acc_b2b.Id, Bill_To_Account_Filter__c = acc_b2b.Id
                                                                );
            insert so;
                 Group g1 = new Group(Name='group name', type='Queue');
            insert g1;
             QueuesObject q1 = new QueueSObject(QueueID = g1.id, SobjectType = 'Task');
            insert q1;
          
            Task t = new Task(whatid=so.id,subject ='test',ownerid=g1.id);
            insert t;
        }
    }
    @isTest
    public static void test1(){
        /* PageReference pageRef = Page.success;
Test.setCurrentPage(pageRef);*/
        
        task t =[select id from task limit 1];
        TaskEmailTemplateController controller = new TaskEmailTemplateController();
        controller.taskId = t.id;
        controller.getObjectType();
    }
}