//Test Class : ExpireRenewalQuoteStinger_Test
global class ExpireRenewalQuoteStinger_Schedule implements Schedulable{
	global void execute(SchedulableContext sc) {
        ExpireRenewalQuoteStinger_Batch b = new ExpireRenewalQuoteStinger_Batch(); 
        database.executeBatch(b,10);
    }   
}