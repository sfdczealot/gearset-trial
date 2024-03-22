// Schedule Class to run UpdateFulfilmentItemsBatch
global class UpdateFulfilmentItemsScheduler implements Schedulable{

    global void execute(SchedulableContext sc){
        Database.executeBatch(new UpdateFulfilmentItemsBatch(), 1);
    }
    
    public static void scheduleIt(){
        System.schedule('Update Fulfilments ' + System.currentTimeMillis(), 
                        '0 0 0/3 ? * * *', 
                        new UpdateFulfilmentItemsScheduler());
    }
}