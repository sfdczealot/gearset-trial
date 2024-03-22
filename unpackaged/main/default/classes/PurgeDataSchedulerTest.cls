@IsTest
private class PurgeDataSchedulerTest {
    
    /*method to test for single records in object */
    @IsTest
    static void testpurgeData_Single(){
        
        List<Purge_Batch_Job__c> objList = new List<Purge_Batch_Job__c>();
        
        csam__Incoming_Message__c inMsg = new csam__Incoming_Message__c(Name = 'testinmsg', csam__HTTP_Method__c = 'test');
        insert inMsg;
        
        csam__Outgoing_Message__c outMsg= new csam__Outgoing_Message__c(Name = 'testoutmsg', csam__Content_Type__c = 'testtype', csam__URL_Host__c = 'testhost');
        insert outMsg;
        
        Purge_Batch_Job__c pb = new Purge_Batch_Job__c();
        pb.Name = 'testName';
        pb.Object_API_Name__c = 'csam__Incoming_Message__c';
        pb.Number_of_Days_To_Purge__c = 0;
        objList.add(pb);
        
        Purge_Batch_Job__c pb1 = new Purge_Batch_Job__c();
        pb1.Name = 'testName1';
        pb1.Object_API_Name__c = 'csam__Outgoing_Message__c';
        pb1.Number_of_Days_To_Purge__c = 0;
        objList.add(pb1);
        insert objList;
        
        Test.startTest();
        PurgeDataScheduler.scheduleIt();
        Test.stopTest();
    }
    
    /*method to test for bulk records with multiple objects */
    @IsTest
    static void testpurgeData_Bulk(){
        List<csam__Incoming_Message__c> inMsgs = TestDataSetupTargetables.createInMsgs(100);
        TestDataSetupTargetables.createCSCustomSettings();
        TestDataSetupTargetables.createPurgeBatchJob();
        Test.startTest();
        PurgeDataScheduler.scheduleIt();
        Test.stopTest();
    }

    @IsTest
    static void purge_batchExecuteTest()
    {
        Account a = TestDataSetupTargetables.createAccount();
        a.AA_Completed_Date__c = Date.today().addDays(-2);
        insert a;

        Purge_Batch_Job__c pb1 = new Purge_Batch_Job__c();
        pb1.Name = 'testName1';
        pb1.Date_Filter__c = 'AA_Completed_Date__c';
        pb1.Object_API_Name__c = 'Account';
        pb1.Number_of_Days_To_Purge__c = 0;
        insert pb1;

        List<String> scope = new List<String>();
        scope.add(a.Id);

        Test.startTest();
        PurgeDataBatch batch = new PurgeDataBatch();
        Database.executeBatch( batch );
        Test.stopTest();
        
        Account[] accs = [SELECT Id FROM Account WHERE Id = :a.Id];
        System.assert(accs.size() == 0);
    }
}