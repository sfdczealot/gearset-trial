public class BatchToUpdateFLIStatus_MYSchedule implements Schedulable {
    public static void execute(SchedulableContext SC) {
        
        BatchToUpdateFLIStatus Malaysia_batch = new BatchToUpdateFLIStatus('Malaysia');
        
        Database.executeBatch(Malaysia_batch);
        
    }
}