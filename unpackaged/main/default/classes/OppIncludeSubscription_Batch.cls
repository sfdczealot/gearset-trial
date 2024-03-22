/*------------------------------------------------------------
Author:        Whisnu Satriya Wardhana
Company:       Viseo Asia PTE LTD
Description:   Batch class to sync between Include_Subscription and Include_Subscription_Ext when Include_Subscription is changed
Inputs:        
               
Test Class:    
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
global class OppIncludeSubscription_Batch implements Database.Batchable<sObject>{
    String query, strParameter = null;
    
    public OppIncludeSubscription_Batch(String AccountId) {
        strParameter = AccountId;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        query = label.PG_LABEL_OppIncludeSubscription_q;
        if(strParameter != null && strParameter != ''){
            query = 'select Id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\' AND Status__c != \'Pending\') and Customer_Type__c = \'Agent\' and Id in (\''+strParameter+'\')';
        }
        else{
            if(query == 'null'){
                query = 'select id from Account where (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\' AND Status__c != \'Pending\') and Customer_Type__c = \'Agent\'';
            }
        }
        //query = 'select Id from Account where Id in (\''+criteria+'\')';
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<Account> batchAgent) {
        list<String> listAccountId = new list<String>();
        list<Opportunity> listOppUpdate = new list<Opportunity>();
        map<string, integer> mapCountOppAgent = new map<string, integer>();
        integer counter;
        system.debug('batchAgent.size:'+batchAgent.size());
        if(batchAgent.size() > 0){
            for (Account row: batchAgent) {
                system.debug('AccountId:'+row.Id);
                listAccountId.add(row.Id);
            }
            //system.debug(today);
            //system.debug('iki batch:' + [select Id, Name, AccountId, Include_Subscription__c, Include_Subscription_Ext__c, ByAuto__c, CloseDate, Is_Current_Subscription__c,OMC_Approved_Date__c from Opportunity where RecordType.Name='B2C' and IsWon=true and Summary_Of_Subscription_Item_new__c>0 and Account.Status__c!='Cancelled' and AccountId in :listAccountId and ((Include_Subscription__c=true and Include_Subscription_Ext__c=false) or (Include_Subscription__c=false and Include_Subscription_Ext__c=true) or (Is_Current_Subscription__c=true)) order by OMC_Approved_Date__c desc]);
            for (Opportunity row: [select Id, Name, AccountId, Include_Subscription__c, Include_Subscription_Ext__c, ByAuto__c, CloseDate, Is_Current_Subscription__c,OMC_Approved_Date__c from Opportunity where RecordType.Name='B2C' and IsWon=true and Summary_Of_Subscription_Item_new__c>0 and Account.Status__c!='Cancelled' and AccountId in :listAccountId and ((Include_Subscription__c=true and Include_Subscription_Ext__c=false) or (Include_Subscription__c=false and Include_Subscription_Ext__c=true) or (Is_Current_Subscription__c=true and DAY_ONLY(OMC_Approved_Date__C)<=today)) order by OMC_Approved_Date__c desc]) {
                // To check whether particular Agent has more than 1 active Subscription.
                counter = mapCountOppAgent.keySet().contains(row.AccountId)?mapCountOppAgent.get(row.AccountId):0;
                mapCountOppAgent.put(row.AccountId, ++counter);
                // Only proceed to update if Include_Subscription__c & Include_Subscription_Ext__c are different
                // OR Agent has multiple active Subscription
                if (row.Include_Subscription_Ext__c != row.Include_Subscription__c || mapCountOppAgent.get(row.AccountId) > 1 || test.isRunningTest()) {
                    system.debug('AccountId: '+row.AccountId+', OpportunityId: '+row.Id);
                    row.Include_Subscription_Ext__c = row.Include_Subscription__c;
                    row.ByAuto__c = true;
                    // If listAccountIdHasInitialSubscription contains row.AccountId, means this particular Agent already has upgrade & already has initial subscription.
                    // Only 1 subscription shall active (latest/upgrade).
                    row.Is_Current_Subscription__c = mapCountOppAgent.get(row.AccountId)==1;
                    // SF showing strange behavior: if below system debug is commented/removed, this function isn't working.
                    //system.debug('listAccountIdHasInitialSubscription:'+listAccountIdHasInitialSubscription);
                    listOppUpdate.add(row);
                }
            }
            system.debug('listOppUpdate.size:'+listOppUpdate.size());
            if(listOppUpdate.size() > 0) {
                Database.SaveResult[] srList = Database.update(listOppUpdate, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        system.debug('succeed sr.getId():'+sr.getId());
                    } else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Fields that affected this error: ' + err.getFields());
                        }
                    }
                }
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        //ts
        if(strParameter != null && strParameter != ''){
            AccountTS_Batch z = new AccountTS_Batch(strParameter); 
            Database.executeBatch(z);
        }
    }
}