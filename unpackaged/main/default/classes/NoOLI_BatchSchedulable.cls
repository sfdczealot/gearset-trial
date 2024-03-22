global class NoOLI_BatchSchedulable implements System.Schedulable {
    
    global void execute(System.SchedulableContext context) {
        NoOLI_Batch b = new NoOLI_Batch(); 
        database.executeBatch(b);
    }
}