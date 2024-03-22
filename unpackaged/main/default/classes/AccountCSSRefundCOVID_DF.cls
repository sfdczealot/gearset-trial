global class AccountCSSRefundCOVID_DF implements Database.Batchable<sObject>{
    
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        
        /*String def_query = label.AccountCSS_q;
        if(def_query != ''){
            query = def_query;
        }
        else{*/
        if(!test.isRunningTest()){
            query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\') and id in (\'0017F00002Px8CBQAZ\',\'0017F00002Px4BWQAZ\',\'0017F00002PxQQ6QAN\',\'0017F00001JnzRaQAJ\',\'0017F00002PwfRkQAJ\',\'0017F00002Px5FeQAJ\',\'0017F00002PwewwQAB\',\'0017F00002PxipIQAR\',\'0017F00001JnylEQAR\',\'0017F00002PxjzfQAB\',\'0017F00001JnysnQAB\',\'0017F00002PxxviQAB\',\'0017F00002PwhzdQAB\',\'0017F00001Jny1MQAR\',\'0017F00001Jntw9QAB\',\'0017F00002LvDa0QAF\',\'0017F00002PvLq5QAF\',\'0017F000021G8GUQA0\',\'0017F00002O0jreQAB\',\'0017F00002Pwqk3QAB\',\'0017F00001JnxBgQAJ\',\'0017F00002Py9LPQAZ\',\'0017F00001Jnz3bQAB\',\'0017F00002PxluFQAR\',\'0017F00002Pwhq9QAB\',\'0017F00002PwEBAQA3\',\'0017F00002PxhGbQAJ\',\'0017F00002Py0TLQAZ\',\'0017F000028x3dzQAA\',\'0017F00002PweubQAB\',\'0017F00002PxiruQAB\',\'0017F00002O0UXOQA3\',\'0017F00001JnunRQAR\',\'0017F00002PwltZQAR\',\'0017F00002PwdtoQAB\',\'0017F00002Pwf8uQAB\',\'0017F00001JnuZXQAZ\',\'0017F00001MqNryQAF\',\'0017F00001JnslrQAB\',\'0017F00002PyPimQAF\',\'0017F00001Jnv1AQAR\',\'0017F00002PyHinQAF\',\'0017F00002PwtI9QAJ\',\'0017F00001JnvAIQAZ\',\'0017F00002Pxjc6QAB\',\'0017F00001mSJACQA4\',\'0017F00001JnwYjQAJ\',\'0017F00001Jnwf8QAB\',\'0017F00001MsFHZQA3\',\'0017F00002PxEANQA3\',\'0017F00002O08mGQAR\',\'0017F00001Ms38uQAB\',\'0017F00002PybVZQAZ\',\'0017F00001Jo053QAB\',\'0017F00002PxzHvQAJ\',\'0017F00002PxHBJQA3\',\'0017F00002Pxif4QAB\',\'0017F00002NyyyDQAR\',\'0017F00002PwetpQAB\',\'0017F00001Jny5cQAB\',\'0017F00002PyWqhQAF\')';   
        }else {
            query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\')';   
        }
            
        //}
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> AccList) {
        
        system.debug('size:'+AccList.size());
        if(AccList.size() > 0){
            for(Account acct: AccList){
                system.debug('acct: ' + acct.id);
                for(list<Opportunity> CSSOppty:[select Id, AccountId, Summary_Of_Subscription_Item_new__c from Opportunity where AccountId =: acct.id   and isWon = true and (Is_Current_Subscription__c = true AND Include_Subscription_Ext__c  = true) and Count_of_subscription_item_new__c > 0 ORDER BY OMC_Approved_Date__c DESC]){
                    Decimal CSSAmount = 0.00;
                    Id AccountId = acct.id;
                    list<Account> listAccountId = new list<Account>();
                    system.debug('CSS:' + CSSOppty);
                    if(CSSOppty.size() > 0){
                        for (Opportunity row: CSSOppty) {
                            if(row.Summary_Of_Subscription_Item_new__c != null){
                                CSSAmount += row.Summary_Of_Subscription_Item_new__c;
                            }
                            AccountId = row.AccountId;
                        }
                        system.debug('CSSAmount'+CSSAmount);
                        //if(CSSAmount > 0){
                        for(Account data:[select Current_Subscription_Spending_Amount__c   from Account where id =: AccountId]){
                            Decimal curCSS = (data.Current_Subscription_Spending_Amount__c!=null)?data.Current_Subscription_Spending_Amount__c:0.00;
                            
                            if(CSSAmount.setScale(2) != curCSS.setScale(2)){
                                data.Current_Subscription_Spending_Amount__c = CSSAmount;
                            }
                            listAccountId.add(data);
                        }
                        //}
                    }
                    else{
                        for(Account data:[select Current_Subscription_Spending_Amount__c   from Account where id =: AccountId]){
                            Decimal curCSS = (data.Current_Subscription_Spending_Amount__c!=null)?data.Current_Subscription_Spending_Amount__c:0.00;
                            
                            //if(CSSAmount.setScale(2) != curCSS.setScale(2)){
                                data.Current_Subscription_Spending_Amount__c = CSSAmount;
                            //}
                            listAccountId.add(data);
                        }
                    }
                    
                    if(listAccountId.size()>0) {
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
    
    global void finish(Database.BatchableContext BC) {
        
        
    }
    
}