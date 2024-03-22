/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Schedulable class to run the batch job.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
global class ExcludeFromSpending_BatchSchedulable implements System.Schedulable {
    
    String paramId; boolean runparam;
    
    global ExcludeFromSpending_BatchSchedulable(String AccountId, Boolean RunOnce){
        paramId = AccountId;
        runparam = RunOnce;
    }
    
    global Void execute(System.SchedulableContext context) {
        system.debug('Schedulable Account:' + paramId);
        system.debug('Schedulable batchname:' + context.getTriggerId());
        if(runparam){
            Database.executeBatch(new ExcludeFromSpending_Batch(paramId, context.getTriggerId()),1);
        }
        else{
            Database.executeBatch(new ExcludeFromSpending_Batch(paramId, ''),1);
        }
    }
}