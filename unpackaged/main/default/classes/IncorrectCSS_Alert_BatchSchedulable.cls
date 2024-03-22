global class IncorrectCSS_Alert_BatchSchedulable implements System.Schedulable {
    
    global void execute(System.SchedulableContext context) {
        IncorrectCSS_Alert_Batch b = new IncorrectCSS_Alert_Batch(); 
        database.executeBatch(b);
    }
}