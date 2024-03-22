global class RootPathBatchScheduler implements Schedulable {
    
    global void execute(SchedulableContext sc){
    
        for(Targeting_Widget_Root_Path__c twRootPathJob : Targeting_Widget_Root_Path__c.getAll().values()){

            Integer hierarchyDepthLimit = Integer.valueOf(twRootPathJob.Targeting_Widget_Hierarchy_Depth_Limit__c);

            database.executeBatch(new RootPathBatch(twRootPathJob.Object_API_Name__c,
                                                    hierarchyDepthLimit), 
                                  200 / (hierarchyDepthLimit + 1)); 
        }
    }
    
    public static void scheduleIt(){
        System.schedule('Targeting Widget Root Path ' + System.currentTimeMillis(), 
                        '0 0 22 * * ?', // schedule to run RootPathBatchScheduler class at 10PM daily
                        new RootPathBatchScheduler());
    }
}