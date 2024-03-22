global class OpportunityRenewalUpd_Batch implements Database.Batchable<sObject>{
    
    String query;
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        map<string, string> MapAccRT = new map<string, string>();
        for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType='Opportunity' and Name='B2C']){
            MapAccRT.put(rt.Name, rt.Id);
        }
        query = 'select id,Renewal_State__c,Country__c,Account.Status__c,Account.Subscription_End_Date__c,Account.Previous_Acct_End_Date__c  from opportunity where StageName IN(\'New\', \'Proposal\',\'Pending Online Payment\',\'Pending OMC Approval\') AND (Order_Type_Clone__c = \'Contract - Renewal\' OR Opportunity_Type__c = \'B2C - Renewal\') AND RecordTypeId = \''+ MapAccRT.get('B2C') +'\'';
        system.debug(query);
        return Database.getQueryLocator(query);       
    }
    
    global void execute(Database.BatchableContext BC, List<Opportunity> batch) {        
        if(batch.size() > 0){
            Set<Id> OppIdSet = new Set<Id>();
            for(Opportunity op : batch){
                OppIdSet.add(op.id); 
            }
            Map<Id,Opportunity> mapOfIdVsOpportunity = new Map<Id,Opportunity>([Select id,(select id,Renewal_State__c,Opportunityid from quotes where Status not IN ('Invalid','Expired','Accepted') ) from Opportunity where id in : OppIdSet]);
            List<Quote> toUpdateQuote = new List<Quote>();
            List<Opportunity> toUpdate = new List<Opportunity>();
            system.debug('Batch:' + batch);
            Set<Id> setOfOppIds = new Set<Id>();
            
            for(sObject obj : batch) {
                Opportunity opty = (Opportunity)obj;
                boolean isAm = false; //= (opty.Account.Subscription_End_Date__c.month() == system.today().month() && opty.Account.Subscription_End_Date__c.year() == system.today().year());
                boolean isAmPlus1 = false; //= (opty.Account.Subscription_End_Date__c.addMonths(1).month() == system.today().month() && opty.Account.Subscription_End_Date__c.addMonths(1).year() == system.today().year());
                boolean isEB = false; //= (opty.Account.Subscription_End_Date__c.addMonths(-1).month() == system.today().month() && opty.Account.Subscription_End_Date__c.addMonths(-1).year() == system.today().year());
                if(opty.Country__c=='Singapore'){
                    if(opty.Account.Status__c=='Active' && opty.Account.Subscription_End_Date__c.month() == system.today().month() && opty.Account.Subscription_End_Date__c.year() == system.today().year()){
                        isAm=true;
                    } else if(opty.Account.Status__c=='Downgraded' && opty.Account.Previous_Acct_End_Date__c.month() == system.today().month() && opty.Account.Previous_Acct_End_Date__c.year() == system.today().year()){
                        isAm=true;
                    } else if(opty.Account.Status__c=='Suspended' && opty.Account.Subscription_End_Date__c.month() == system.today().month() && opty.Account.Subscription_End_Date__c.year() == system.today().year()){
                        //added the condition as part of change of Penny, PGAUTO-5441
                        isAm=true;
                    } else if(opty.Account.Status__c=='Active' && opty.Account.Subscription_End_Date__c.addMonths(1).month() == system.today().month() && opty.Account.Subscription_End_Date__c.addMonths(1).year() == system.today().year()){
                        isAmPlus1=true;
                    } else if(opty.Account.Status__c=='Downgraded' && opty.Account.Previous_Acct_End_Date__c.addMonths(1).month() == system.today().month() && opty.Account.Previous_Acct_End_Date__c.addMonths(1).year() == system.today().year()){
                        isAmPlus1=true;
                    } else if(opty.Account.Status__c=='Active' && opty.Account.Subscription_End_Date__c.month() == system.today().addMonths(1).month() && opty.Account.Subscription_End_Date__c.year() == system.today().addMonths(1).year()){
                        isEB=true;
                    }
                }else if(opty.Country__c=='Malaysia' || opty.Country__c=='Thailand'){
                    if(opty.Account.Subscription_End_Date__c.month() == system.today().month() && opty.Account.Subscription_End_Date__c.year() == system.today().year()){
                        isAm=true;
                    }else if(opty.Account.Subscription_End_Date__c.addMonths(1).month() == system.today().month() && opty.Account.Subscription_End_Date__c.addMonths(1).year() == system.today().year()){
                        isAmPlus1=true;
                    }else if(opty.Account.Status__c=='Active' && opty.Account.Subscription_End_Date__c.month() == system.today().addMonths(1).month() && opty.Account.Subscription_End_Date__c.year() == system.today().addMonths(1).year()){
                        isEB=true;
                    }
                }
                
                if(isAm && opty.Renewal_State__c != 'Actual Month'){
                    opty.Renewal_State__c = 'Actual Month';
                    toUpdate.add(opty);
                    setOfOppIds.add(opty.Id);
                }
                if(isAmPlus1 && opty.Renewal_State__c != 'Actual Month +1'){
                    opty.Renewal_State__c = 'Actual Month +1';
                    toUpdate.add(opty);
                    setOfOppIds.add(opty.Id);
                }
                if(isEB && opty.Renewal_State__c != 'Early Bird'){
                    opty.Renewal_State__c = 'Early Bird';
                    toUpdate.add(opty);
                    setOfOppIds.add(opty.Id);
                }
                Opportunity oppList = mapOfIdVsOpportunity.get(opty.id);
                if(oppList.quotes.size()>0){
                    for(Quote qu : oppList.quotes){
                        if(setOfOppIds.contains(qu.OpportunityId)){
                            if(opty.Renewal_State__c!=null && opty.Renewal_State__c!=''){
                                qu.Renewal_State__c = opty.Renewal_State__c;
                                toUpdateQuote.add(qu);
                            }
                        }
                    }
                }
            }
            if(toUpdate.size() > 0) {
                system.debug('toUpdate: ' + toUpdate);
                Database.update(toUpdate, false);
            }
            if(toUpdateQuote.size() > 0) {
                Database.update(toUpdateQuote, false);
            }
            
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }  
}