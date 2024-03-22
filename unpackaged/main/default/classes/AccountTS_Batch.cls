global class AccountTS_Batch implements Database.Batchable<sObject>{

    String query, strParameter;
    
    public AccountTS_Batch(String AccountId) {
        strParameter = AccountId;
    }

    global Database.QueryLocator start(Database.BatchableContext BC)  {
        list<Id> listAccountId;
        set<Id> setAccountId = new set<Id>(); 
        setAccountId.add(strParameter);
        system.debug('batchjob account:' + setAccountId);
        listAccountId = new list<Id>(setAccountId);
        system.debug('listAccountId.size:'+listAccountId.size());
        string criteria = string.join(listAccountId, '\', \'');
        query = 'select AccountId, Id, Total_Spending_on_Discretionary_Product__c,Total_Spending_on_Discretionary_Prod_new__c  from Opportunity where AccountId in (\''+criteria+'\') and Months_Included__c = true';
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Opportunity> TSOppty) {
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
    
    global void finish(Database.BatchableContext BC) {
        //css
        AccountCSS_Batch w = new AccountCSS_Batch(strParameter);
        database.executeBatch(w);
    }
    
}