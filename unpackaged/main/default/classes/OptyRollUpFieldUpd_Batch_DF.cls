global class OptyRollUpFieldUpd_Batch_DF implements Database.Batchable<sObject>{
    
    String query;
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        
        String def_query = label.PG_LABEL_OptyRollUpFieldUpd_Batch_DF_q;
        if(def_query != '-'){
            query = def_query;
        }
        else{
            if(!Test.isRunningTest()){
                query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\' AND Status__c != \'Pending\') and Customer_Type__c = \'Agent\'  and id in (\'0017F00002Px8CBQAZ\',\'0017F00002Px4BWQAZ\',\'0017F00002PxQQ6QAN\',\'0017F00001JnzRaQAJ\',\'0017F00002PwfRkQAJ\',\'0017F00002Px5FeQAJ\',\'0017F00002PwewwQAB\',\'0017F00002PxipIQAR\',\'0017F00001JnylEQAR\',\'0017F00002PxjzfQAB\',\'0017F00001JnysnQAB\',\'0017F00002PxxviQAB\',\'0017F00002PwhzdQAB\',\'0017F00001Jny1MQAR\',\'0017F00001Jntw9QAB\',\'0017F00002LvDa0QAF\',\'0017F00002PvLq5QAF\',\'0017F000021G8GUQA0\',\'0017F00002O0jreQAB\',\'0017F00002Pwqk3QAB\',\'0017F00001JnxBgQAJ\',\'0017F00002Py9LPQAZ\',\'0017F00001Jnz3bQAB\',\'0017F00002PxluFQAR\',\'0017F00002Pwhq9QAB\',\'0017F00002PwEBAQA3\',\'0017F00002PxhGbQAJ\',\'0017F00002Py0TLQAZ\',\'0017F000028x3dzQAA\',\'0017F00002PweubQAB\',\'0017F00002PxiruQAB\',\'0017F00002O0UXOQA3\',\'0017F00001JnunRQAR\',\'0017F00002PwltZQAR\',\'0017F00002PwdtoQAB\',\'0017F00002Pwf8uQAB\',\'0017F00001JnuZXQAZ\',\'0017F00001MqNryQAF\',\'0017F00001JnslrQAB\',\'0017F00002PyPimQAF\',\'0017F00001Jnv1AQAR\',\'0017F00002PyHinQAF\',\'0017F00002PwtI9QAJ\',\'0017F00001JnvAIQAZ\',\'0017F00002Pxjc6QAB\',\'0017F00001mSJACQA4\',\'0017F00001JnwYjQAJ\',\'0017F00001Jnwf8QAB\',\'0017F00001MsFHZQA3\',\'0017F00002PxEANQA3\',\'0017F00002O08mGQAR\',\'0017F00001Ms38uQAB\',\'0017F00002PybVZQAZ\',\'0017F00001Jo053QAB\',\'0017F00002PxzHvQAJ\',\'0017F00002PxHBJQA3\',\'0017F00002Pxif4QAB\',\'0017F00002NyyyDQAR\',\'0017F00002PwetpQAB\',\'0017F00001Jny5cQAB\',\'0017F00002PyWqhQAF\')';
            }else{
                query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\' AND Status__c != \'Pending\') '; 
            }
        }
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> AccList) {
        try{
            system.debug('size:'+AccList.size());
            if(AccList.size() > 0){ 
                for(Account acct: AccList){        
                    system.debug('acct: ' + acct.id);
                    system.debug('Query$$$ '+[select Id, AccountId,Account.Status__c,Total_Spending_on_Discretionary_Prod_new__c,Summary_Of_Subscription_Item_new__c,Include_Subscription_Ext__c,Include_Subscription__c,StageName from Opportunity where AccountId =: acct.id]);
                    for(Opportunity OptyUpd: [select Id, AccountId, Summary_Of_Subscription_Item_new__c from Opportunity WHERE  AccountId =: acct.id and StageName = 'Closed Won']){
                        
                        Integer count_first = 0, count_subs_item = 0, count_vip_rel = 0, count_vip_spending = 0, count_vip_subs = 0; Decimal summary_subs_item = 0.00, summary_disc_item = 0.00;
                        Date subs_activate = null;
                        for(sObject obj : [SELECT id,Discount_Reason__c,Amount_Despite_VIP__c, Product_Category__c,Amount__c,Product_Duration__c,Start_Date__c,Complimentary__c FROM OpportunityLineItem WHERE OpportunityId =: OptyUpd.id]) {
                            OpportunityLineItem OppItem = (OpportunityLineItem)obj;
                            if(OppItem.Discount_Reason__c == 'First-Timer Discount'){
                                ++count_first;
                            }
                            if(OppItem.Product_Category__c == 'Subscription'){
                                ++count_subs_item;
                                summary_subs_item += (OppItem.Amount_Despite_VIP__c!=null && OppItem.Amount_Despite_VIP__c>0)?OppItem.Amount_Despite_VIP__c:0.00;
                                if(Integer.valueOf(OppItem.Product_Duration__c)>=180 && OppItem.Complimentary__c == false){
                                    subs_activate = (OppItem.Start_Date__c!=null)?OppItem.Start_Date__c:null;
                                }
                            }
                            if(OppItem.Discount_Reason__c == 'VIP (Relationship)'){
                                ++count_vip_rel;
                            }
                            if(OppItem.Discount_Reason__c == 'VIP (Spending)'){
                                ++count_vip_spending;
                            }
                            if(OppItem.Product_Category__c == 'Subscription' && (OppItem.Discount_Reason__c == 'VIP (Relationship)' || OppItem.Discount_Reason__c == 'VIP (Spending)' || OppItem.Discount_Reason__c == 'VIP (migration)')){
                                ++count_vip_subs;
                                if(Integer.valueOf(OppItem.Product_Duration__c)>=180 && OppItem.Complimentary__c == true && subs_activate == null){
                                    subs_activate = (OppItem.Start_Date__c!=null)?OppItem.Start_Date__c:null;
                                }
                            }
                            if(OppItem.Product_Category__c == 'Discretionary'){
                                summary_disc_item += (OppItem.Amount__c!=null && OppItem.Amount__c>0)?OppItem.Amount__c:0.00;
                            }
                        }
                        Opportunity OptyUpdate = [Select Is_Current_Subscription__c, Include_Subscription_Ext__c, Total_Spending_on_Discretionary_Prod_new__c, id,AccountId,Count_of_First_Timer_Promotion_new__c ,Pro_Rate__c,Count_of_Subscription_Item_new__c , Count_of_VIP_Relation_Request_new__c , Count_of_VIP_Spending_Request_new__c , Count_of_VIP_Subscription_new__c , Summary_Of_Subscription_Item_new__c,Subscription_Activation_Date__c from Opportunity where id =:  OptyUpd.Id];
                        system.debug('count_first:' + count_first);
                        system.debug('count_subs_item:' + count_subs_item);
                        system.debug('summary_subs_item:' + summary_subs_item);
                        system.debug('count_vip_rel:' + count_vip_rel);
                        system.debug('count_vip_spending:' + count_vip_spending);
                        system.debug('count_vip_subs:' + count_vip_subs);
                        OptyUpdate.Count_of_First_Timer_Promotion_new__c = count_first;
                        
                        OptyUpdate.Count_of_Subscription_Item_new__c = count_subs_item;
                        
                        OptyUpdate.Summary_Of_Subscription_Item_new__c = summary_subs_item;
                        
                        OptyUpdate.Count_of_VIP_Relation_Request_new__c = count_vip_rel;
                        
                        OptyUpdate.Count_of_VIP_Spending_Request_new__c = count_vip_spending;
                        
                        OptyUpdate.Count_of_VIP_Subscription_new__c = count_vip_subs;
                        
                        OptyUpdate.Total_Spending_on_Discretionary_Prod_new__c = summary_disc_item;
                        
                        OptyUpdate.Subscription_Activation_Date__c = subs_activate;
                        update OptyUpdate;
                        if(OptyUpdate.Is_Current_Subscription__c == true && OptyUpdate.Include_Subscription_Ext__c  == true){
                            PGOpportunityTriggerHandler.updateAgentProRate(OptyUpdate);
                        }
                        
                    }
                }
            }
        }
        catch(Exception err){
            system.debug('Error:' + err);
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {
        
        
    }
    
}