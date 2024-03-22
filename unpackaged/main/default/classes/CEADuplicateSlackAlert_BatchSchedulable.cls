global class CEADuplicateSlackAlert_BatchSchedulable implements Schedulable{  
 
   global Void execute(System.SchedulableContext context) {
        CEADuplicateSlackAlert_Batch b = new CEADuplicateSlackAlert_Batch(); 
        database.executeBatch(b);
     }
}