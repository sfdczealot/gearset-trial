public class PGScriptToUncheckOldVIP implements Schedulable {
   public void execute(SchedulableContext SC) {
      updateVIPFlag();
   }
    public static void updateVIPFlag(){
        list<Account> accListToUpdate = [Select Id,VIP__c from Account where VIP_End_Date__c < Today AND VIP__c = true limit 50000];
        for(Account acc : accListToUpdate){
            acc.VIP__c = false;
        }
        
        if(!accListToUpdate.isEmpty()){
            update accListToUpdate;
        }
        
    } 
}