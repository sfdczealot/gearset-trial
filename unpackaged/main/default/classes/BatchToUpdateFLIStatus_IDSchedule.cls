public class BatchToUpdateFLIStatus_IDSchedule implements Schedulable {
    public static void execute(SchedulableContext SC) {
        
        BatchToUpdateFLIStatus indonesia_batch = new BatchToUpdateFLIStatus('Indonesia');
        
        Database.executeBatch(indonesia_batch);
        
    }
}