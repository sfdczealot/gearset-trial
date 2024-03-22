public class BatchToUpdateFLIStatus_THSchedule implements Schedulable {
    public static void execute(SchedulableContext SC) {
        
        BatchToUpdateFLIStatus Thailand_batch = new BatchToUpdateFLIStatus('Thailand');
        
        Database.executeBatch(Thailand_batch);
        
    }

}