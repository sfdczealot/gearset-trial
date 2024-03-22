@isTest
public class Test_runRewardCalculatorController {
    
    private static testmethod void checkCurrenttBatchTest(){
        
        Id foldId = [select id from folder where name = 'BatchToComputeTotalSpending_BulkResult'].id;
        String csvFile = 'Test CSV';
        // Insert doc
        Document doc = new Document(Name = 'Test doc', Body = Blob.valueOf(csvFile), Type = 'csv',FolderId = foldId, ContentType='application/vnd.ms-excel');
        insert doc;
        
        Test.startTest();
        runRewardCalculatorController.checkCurrenttBatch('Singapore');
        runRewardCalculatorController.runBatch('Singapore');
        Test.stopTest(); 
    }
}