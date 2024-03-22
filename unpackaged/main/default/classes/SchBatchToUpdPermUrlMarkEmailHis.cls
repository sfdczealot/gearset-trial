//This is a scheduler class which send the blank permurl record Id to batch for updation
//TEST CLASS:trigger_MarketingEmailHis_Test
global class SchBatchToUpdPermUrlMarkEmailHis implements Schedulable {
   global void execute(SchedulableContext sc) {
       Map<ID,MarketingEmailHistoryTracker__c> mapofrecord=new Map<ID,MarketingEmailHistoryTracker__c>([Select ID, OriginalURL__c , Contact__c from MarketingEmailHistoryTracker__c where PermURL__c =null And OriginalURL__c!=null]);
       if(mapofrecord.keySet().size()>0){
           BatchToUpdPermUrlMarkEmailHis objBatch=new BatchToUpdPermUrlMarkEmailHis(mapofrecord.keySet());
           Database.executeBatch(objBatch, 20);
       }
   }
}