global class AccountCSS_BatchSchedulable implements System.Schedulable {
    
    global Void execute(System.SchedulableContext context) {

        AccountCSS_Batch_DF b = new AccountCSS_Batch_DF(); 
        database.executeBatch(b, 1);
        
    }
}