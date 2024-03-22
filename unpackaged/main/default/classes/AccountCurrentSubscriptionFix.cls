global class AccountCurrentSubscriptionFix implements Database.Batchable<sObject>{

    String query;

    global Database.QueryLocator start(Database.BatchableContext BC)  {
        query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\')';
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> AcctSubs) {

        list<Opportunity> ListOpportunity = new list<Opportunity>();
        system.debug('AcctSubs: ' + AcctSubs);
        if(AcctSubs.size() > 0){
            for(Account acct: AcctSubs){
        		system.debug('AccountId: ' + acct);
                List<Opportunity> obj = [SELECT id,OMC_Approved_Date__c, Is_Current_Subscription__c from Opportunity where AccountId = :acct.Id and Is_Current_Subscription__c =true and StageName ='Closed Won' ORDER BY OMC_Approved_Date__c DESC];
                Integer ctr = 0;
        		system.debug('Opportunity size: ' + obj.size());
                for(Opportunity row: obj){
                    if(ctr!=0){
                        row.Is_Current_Subscription__c = false;
                        ListOpportunity.add(row);
                    }
                    ctr++;
                }
            }
            
            if(ListOpportunity.size() > 0) {
                Database.SaveResult[] srList = Database.update(ListOpportunity, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        system.debug('succeed sr.getId():'+sr.getId());
                    } 
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {

    }
    
}