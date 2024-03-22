global class AccountTS_Batch_DF implements Database.Batchable<sObject>{
    
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        
        String def_query = label.PG_LABEL_AccountTS_q;
        if(def_query != ''){
            query = def_query;
        }
        else{
            query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\')';    
        }
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> AccList) {
        
        system.debug('size:'+AccList.size());
        if(AccList.size() > 0){
            for(Account acct: AccList){
                system.debug('acct: ' + acct.id);
                for(list<Opportunity> TSOppty:[select AccountId, Id, Total_Spending_on_Discretionary_Product__c,Total_Spending_on_Discretionary_Prod_new__c  from Opportunity where AccountId =: acct.id and Months_Included__c = true]){
                    Decimal TSAmount = 0.00;
                    Id AccountId = null;
                    list<Account> listAccountId = new list<Account>();
                    system.debug('TS:' + TSOppty);
                    if(TSOppty.size() > 0){
                        for (Opportunity row: TSOppty) {
                            TSAmount += (row.Total_Spending_on_Discretionary_Prod_new__c!=null)?row.Total_Spending_on_Discretionary_Prod_new__c:0.00;
                            AccountId = row.AccountId;
                        }
                        if(TSAmount > 0){
                            for(Account data:[select Total_Spending_Amount_last_12_months__c  from Account where id =: AccountId]){
                                data.Total_Spending_Amount_last_12_months__c  = TSAmount;
                                listAccountId.add(data);
                            }
                        }
                        if(AccountId != null) {
                            Database.SaveResult[] srList = Database.update(listAccountId, false);
                            
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
            }
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
        
    }
    
}