//TEST CLASS:ExpireRenewalQuoteStinger_Test
public class ExpireUpgradeOpportunity_Batch implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bC) {
        string query='select Id,Name,CloseDate,(select Id,status,Loss_Reason__c from Quotes order by createdDate Desc) from Opportunity WHERE Opportunity.Upgrade_Start_Date__c < Today and Opportunity_Type__c = \'B2C - Upgrade\' and StageName !=\'Closed Lost\'';
        return Database.getQueryLocator(query);
    }
    
    public void execute(Database.BatchableContext bC, List<Opportunity> recordList) {
        List<Opportunity> toUpdateOpp = new List<Opportunity>();
        for(Opportunity each : recordList) {
            If(each.Quotes.size()>0){
                Integer count=0;
                for(Quote eachQuote: each.Quotes){
                    IF(eachQuote.Status=='Expired' || eachQuote.Status=='Invalid'){
                        count++;
                    }
                }
                If(count == each.Quotes.size()){
                    Opportunity objOpp=new Opportunity(Id=each.Id,StageName='Closed Lost',Loss_Reason__c=each.Quotes[0].Loss_Reason__c);
                    toUpdateOpp.add(objOpp);
                }
            }
            
        }
        if(toUpdateOpp.size()>0){
            system.debug('Update--');
            database.Update(toUpdateOpp,false);
        }
    }
    
    public void finish(Database.BatchableContext bC) {
        
    }
}