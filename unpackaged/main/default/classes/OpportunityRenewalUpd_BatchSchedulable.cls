global class OpportunityRenewalUpd_BatchSchedulable implements Schedulable {

    global void execute(SchedulableContext sc) {
        OpportunityRenewalUpd_Batch b = new OpportunityRenewalUpd_Batch(); 
        database.executeBatch(b);
    }    
    
}