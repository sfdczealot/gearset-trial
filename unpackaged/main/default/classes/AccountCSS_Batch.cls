global class AccountCSS_Batch implements Database.Batchable<sObject>{
    
    String query, strParameter;
    
    public AccountCSS_Batch(String AccountId) {
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
        query = 'select Id,AccountId, Summary_Of_Subscription_Item_new__c,pro_rate__c   from Opportunity where AccountId in (\''+criteria+'\') and isWon = true and (Is_Current_Subscription__c = true AND Include_Subscription_Ext__c  = true) and count_of_subscription_item_new__c > 0 ORDER BY OMC_Approved_Date__c DESC';
        system.debug('query accountcss:' +query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Opportunity> CSSOppty) {
        Decimal CSSAmount = 0.00, ProRate = 0.00;
        Id AccountId = strParameter;
        list<Account> listAccountId = new list<Account>();
        system.debug('CSS:' + CSSOppty);
        if(CSSOppty.size() > 0){
            for (Opportunity row: CSSOppty) {
                if(row.Summary_Of_Subscription_Item_new__c != null){
                    CSSAmount += row.Summary_Of_Subscription_Item_new__c;
                }
                
                ProRate += (row.Pro_rate__c!=null && row.Pro_rate__c>0)?row.Pro_rate__c:0;
                AccountId = row.AccountId;
            }
            for(Account data:[select Current_Subscription_Spending_Amount__c,Pro_Rate_Amount__c   from Account where id =: AccountId]){
                //commented on 8th oct, PGAUTO-6399
                //data.Current_Subscription_Spending_Amount__c   = CSSAmount;

                //data.Pro_Rate_Amount__c = ProRate;
                //listAccountId.add(data);
            }
        }
        
        if(listAccountId.size()>0) {
            Database.SaveResult[] srList = Database.update(listAccountId, false);
            
            // Iterate through each returned result
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    system.debug([select Current_Subscription_Spending_Amount__c,Pro_Rate_Amount__c   from Account where id =: AccountId]);
                    // Operation was successful, so get the ID of the record that was processed
                    system.debug('succeed sr.getId():'+sr.getId());
                } 
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}