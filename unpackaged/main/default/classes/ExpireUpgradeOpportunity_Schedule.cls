//TEST CLASS:ExpireRenewalQuoteStinger_Test
global class ExpireUpgradeOpportunity_Schedule implements Schedulable{
	global void execute(SchedulableContext sc) {
        ExpireUpgradeOpportunity_Batch b = new ExpireUpgradeOpportunity_Batch(); 
        database.executeBatch(b,10);
    }   
}