global class OptyRollUpFieldUpd_Batch implements Database.Batchable<sObject>, Database.Stateful{
    global string query;
    global String paramId;
    global string acctid;
    
    global OptyRollUpFieldUpd_Batch(String OptyId){
        
        System.debug('OptyRollUpFieldUpd Start');
        paramId = OptyId;
        this.query = 'SELECT id,Discount_Reason__c,Amount_Despite_VIP__c, Product_Category__c, Amount__c,Product_Duration__c,Start_Date__c,Complimentary__c FROM OpportunityLineItem WHERE OpportunityId = \'' + OptyId + '\'';
        system.debug('query:' + query);
    }
    global System.Iterable<sObject> start(Database.BatchableContext jobId) {
        return Database.getQueryLocator(query);
    }
    
    global Void execute(Database.BatchableContext jobId, List<sObject> recordList) {
        system.Debug('Execute: OptyRollUpFieldUpd_Batch');
        List<Opportunity> ToUpdateOpp = new List<Opportunity>();
        Integer count_first = 0, count_subs_item = 0, count_vip_rel = 0, count_vip_spending = 0, count_vip_subs = 0; Decimal summary_subs_item = 0.00, summary_disc_item = 0.00;
        Date subs_activate = null;    
        for(sObject obj : recordList) {
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
        Opportunity OptyUpdate = [Select Is_Current_Subscription__c,Include_Subscription_Ext__c,Total_Spending_on_Discretionary_Prod_new__c, id,AccountId,Count_of_First_Timer_Promotion_new__c ,Pro_Rate__c,Count_of_Subscription_Item_new__c , Count_of_VIP_Relation_Request_new__c , Count_of_VIP_Spending_Request_new__c , Count_of_VIP_Subscription_new__c , Summary_Of_Subscription_Item_new__c from Opportunity where id =: paramId];
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
        
        if(acctid == null){
            acctid = OptyUpdate.AccountId;
        }
        update OptyUpdate;
        if(OptyUpdate.Is_Current_Subscription__c == true && OptyUpdate.Include_Subscription_Ext__c  == true){
            PGOpportunityTriggerHandler.updateAgentProRate(OptyUpdate);
        }
    }
    global Void finish(Database.BatchableContext jobId) {
        
    }
}