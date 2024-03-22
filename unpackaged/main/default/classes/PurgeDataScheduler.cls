//Schedule Class to run PurgeDataBatch class at 10PM daily
global class PurgeDataScheduler implements Schedulable{
    
    public static String CRON_EXP = '0 0 22 * * ?';
    
    /*Execute method */
    global void execute(SchedulableContext sc){
        PurgeDataBatch pdbatch = new PurgeDataBatch();
        database.executeBatch(pdbatch, 1000);
    }
    
    /* method to schedule the job  */
    public static void scheduleIt(){
        PurgeDataScheduler pdSch = new PurgeDataScheduler();
        String SchName = 'Purge Data' + System.currentTimeMillis();
        System.schedule(SchName , CRON_EXP, pdSch);
    }
    
}