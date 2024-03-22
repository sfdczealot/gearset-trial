global class AccountTS_BatchSchedulable implements System.Schedulable {
    
    global Void execute(System.SchedulableContext context) {
        AccountTS_Batch_DF b = new AccountTS_Batch_DF(); 
        database.executeBatch(b, 1);
    
    }
}