@isTest
public class Batch_IncomingSlackAlert_Test {
     
    @isTest
    public static void  createData(){
        csam__Outgoing_Message__c outMsg = new csam__Outgoing_Message__c();
        outMsg.Name = 'testoutmsg';
        outMsg.csam__Status__c = 'Waiting for Response';
        outMsg.csam__Content_Type__c = 'testtype';
        outMsg.csam__URL_Host__c = 'testhost';
        outMsg.csam__HTTP_Method__c = 'POST';
        outMsg.csam__Delivery_Tag__c = 1;
        outMsg.createdDate = system.today().addDays(-1);
		insert outMsg;
        
        Test.startTest();
        Batch_IncomingSlackAlert slack = new Batch_IncomingSlackAlert();
        Database.executeBatch(slack);
        Test.stopTest();
        
    }

}