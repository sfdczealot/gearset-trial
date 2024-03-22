/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Batch job to exclude opportunity from total spending(last 12 months) calculation.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
global class ExcludeFromSpending_Batch implements Database.Batchable<sObject>, Database.Stateful{
    global date ExcludedDate = date.today();
    global string query;
    global String paramId = null;
    
    global ExcludeFromSpending_Batch(String AccountId, String BatchName){
        
        if(!Test.isRunningTest()){
            if(BatchName!=null && BatchName!= ''){
                system.abortJob(BatchName);
            }
        }
        System.debug('ExcludeFromSpending Batch Start');
        paramId = AccountId;
        query = label.PG_LABEL_OppExclude_q;
        if(AccountId != null && AccountId != ''){
            this.query = 'select Id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\' AND Status__c != \'Pending\') and Customer_Type__c = \'Agent\' and Id in (\''+paramId+'\')';
        }
        else{
            if(query == 'null'){
                this.query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\' AND Status__c != \'Pending\') and Customer_Type__c = \'Agent\'';
            }
        }
        system.debug('query:' + query);
    }
    global System.Iterable<sObject> start(Database.BatchableContext jobId) {
        return Database.getQueryLocator(query);
    }
    
    global Void execute(Database.BatchableContext jobId, List<Account> AcctList) {
        system.Debug('Execute: ExcludeFromSpending_Batch');
        List<Opportunity> ToUpdateOpp = new List<Opportunity>();
        Map<String,String> MapOppRT = new Map<String,String>();
        
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Opportunity']){
            MapOppRT.put(rt.Name,rt.Id);
        }
        for(Account acct : AcctList){
            for(Opportunity Opp: [SELECT id,Recordtypeid,Months_Included__c,Exclude_from_Spending_at__c,total_spending_on_Discretionary_Product__c,Account.Status__c FROM Opportunity WHERE isWON= TRUE and Months_Included__c = TRUE and Exclude_from_Spending_at__c < :ExcludedDate and AccountId = :acct.id]){
                //for(Opportunity Opp : recordList) {
                //Opportunity Opp = (Opportunity)obj;
                system.debug('Opp.Months_Included__c:' + Opp.Months_Included__c);
                system.debug('Opp.recordtypeid:' + Opp.recordtypeid);
                system.debug('mapOppRT.get(\'B2C\'):' + mapOppRT.get('B2C'));
                system.debug('Exclude_from_Spending_at__c:' + Opp.Exclude_from_Spending_at__c);
                system.debug('ExcludedDate:' + ExcludedDate);
                system.debug('Opp.total_spending_on_Discretionary_Product__c:' + Opp.total_spending_on_Discretionary_Product__c);
                if(Opp.recordtypeid == mapOppRT.get('B2C')){ 
                    Opp.Months_Included__c = FALSE;
                    ToUpdateOpp.add(Opp);
                }
            }
            if(toUpdateOpp.size()>0){
                Update toUpdateOpp;
            }
            //}
        }
    }
    global Void finish(Database.BatchableContext jobId) {
        
        //include
        if(paramId!=null && paramId != ''){
            OppIncludeSubscription_Batch x = new OppIncludeSubscription_Batch(paramId);
            database.executeBatch(x);
        }
    }
}