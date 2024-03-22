//TEST CLASS:ExpireRenewalQuoteStinger_Test
global class ExpireRenewalQuoteStinger_Batch implements Database.Batchable<sObject> {
   
     public Database.QueryLocator start(Database.BatchableContext bC) {
        string query='select Id,Name,Opportunity.CloseDate,Status from Quote WHERE Opportunity.Opportunity_Type__c = \'B2C - Renewal\' and Opportunity.CloseDate < Today and (Opportunity.StageName  = \'Proposal\' OR Opportunity.StageName  = \'New\' OR (Opportunity.StageName  = \'Pending Online Payment\' AND Opportunity.Agent_Accepted_Time__c = null))';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bC, List<Quote> recordList) {
        List<Quote> toUpdateQuote = new List<Quote>();
        for(Quote each : recordList) {
            Quote obj=new Quote(ID=each.Id); 
            obj.Status='Expired';
            obj.Loss_Reason__c='Expired Offer';
            toUpdateQuote.add(obj);
            
        }
        if(toUpdateQuote.size()>0){
            system.debug('Update');
            Database.update(toUpdateQuote, false) ;
        }
    }
    
    public void finish(Database.BatchableContext bC) {
        CloseLostRenewalStinger_Batch objBatch= new CloseLostRenewalStinger_Batch();
        Database.executeBatch(objBatch,10);
    }
}