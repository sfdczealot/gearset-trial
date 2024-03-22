global class AccountCSS_Batch_DF implements Database.Batchable<sObject>{
    
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        
        String def_query = label.PG_LABEL_AccountCSS_q;
        if(def_query != '-'){
            query = def_query;
        }
        else{
            if(!test.isRunningTest()){
                query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\' AND Status__c != \'Pending\')';   
            }else {
                query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\' AND Status__c != \'Pending\')';   
            }  
        }
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> AccList) {
        
        system.debug('size:'+AccList.size());
        if(AccList.size() > 0){
            for(Account acct: AccList){
                system.debug('acct: ' + acct.id);
                system.debug('data: ' + [select Id, AccountId, Summary_Of_Subscription_Item_new__c,Pro_rate__c,Count_of_subscription_item_new__c,isWon,Is_Current_Subscription__c,Include_Subscription_Ext__c from Opportunity where AccountId =: acct.id]);
                for(list<Opportunity> CSSOppty:[select Id, AccountId, Summary_Of_Subscription_Item_new__c,Pro_rate__c from Opportunity where AccountId =: acct.id   and isWon = true and (Is_Current_Subscription__c = true AND Include_Subscription_Ext__c  = true) and Count_of_subscription_item_new__c > 0 ORDER BY OMC_Approved_Date__c DESC]){
                    Decimal CSSAmount = 0.00, ProRate = 0.00;
                    Id AccountId = acct.id;
                    list<Account> listAccountId = new list<Account>();
                    system.debug('CSS:' + CSSOppty);
                    system.debug('CSS size:' + CSSOppty.size());
                    if(CSSOppty.size() > 0){
                        for (Opportunity row: CSSOppty) {
                            if(row.Summary_Of_Subscription_Item_new__c != null){
                                CSSAmount += row.Summary_Of_Subscription_Item_new__c;
                            }
                            
                            ProRate += (row.Pro_rate__c>0)?row.Pro_rate__c:0;
                            AccountId = row.AccountId;
                        }
                        system.debug('CSSAmount'+CSSAmount);
                        //if(CSSAmount > 0){
                        for(Account data:[select Current_Subscription_Spending_Amount__c   from Account where id =: AccountId]){
                            Decimal curCSS = (data.Current_Subscription_Spending_Amount__c!=null)?data.Current_Subscription_Spending_Amount__c:0.00;
                            
                            if(CSSAmount.setScale(2) != curCSS.setScale(2)){
                                //data.Current_Subscription_Spending_Amount__c = CSSAmount;
                                //data.Pro_Rate_Amount__c = ProRate;
                            }
                            listAccountId.add(data);
                        }
                        //}
                    }
                    else{
                        for(Account data:[select Current_Subscription_Spending_Amount__c,Pro_Rate_Amount__c   from Account where id =: AccountId]){
                            Decimal curCSS = (data.Current_Subscription_Spending_Amount__c!=null)?data.Current_Subscription_Spending_Amount__c:0.00;
                            //commented on 8th oct, PGAUTO-6399
                            //if(CSSAmount.setScale(2) != curCSS.setScale(2)){
                                //data.Current_Subscription_Spending_Amount__c = CSSAmount;
                                //data.Pro_Rate_Amount__c = ProRate;
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