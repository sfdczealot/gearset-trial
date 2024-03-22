global class SlackAlert_BatchSchedulable implements System.Schedulable {
    
    global Void execute(System.SchedulableContext context) {
        SlackAlert_Batch b = new SlackAlert_Batch(); 
        database.executeBatch(b);
    
    }
}