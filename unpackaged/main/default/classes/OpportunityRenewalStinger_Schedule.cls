//TEST CLASS :OpportunityRenwalStingerBatch_Test
global class OpportunityRenewalStinger_Schedule implements Schedulable{
	global void execute(SchedulableContext sc) {
        OpportunityRenewalStinger_Batch b = new OpportunityRenewalStinger_Batch(); 
        database.executeBatch(b, 10);
    }    
}