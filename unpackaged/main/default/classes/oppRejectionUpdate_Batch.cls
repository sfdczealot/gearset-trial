//TEST CLASS:oppRejectionUpdate_Batch_Test
global class oppRejectionUpdate_Batch implements Database.Batchable<sObject>, Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        String query ='SELECT Id ,OMC_Submitted_Time__c,OMC_Rejected_Reason__c FROM Opportunity WHERE Opportunity_Type__c !=\'\' AND (StageName = \'Closed Won\' OR StageName =\'Closed Lost\') AND (Recordtype.developerName =\'B2C\' OR Recordtype.developerName =\'B2C Closed Lost\')';
        
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Opportunity> scope){
        
        Map<ID,Opportunity> opportunityToUpdate = new Map<ID,Opportunity>();
        Map<ID,Quote> relatedQuotes = new Map<ID,Quote>();
        
        for(Opportunity opp : scope){
            opportunityToUpdate.put(opp.id,opp);
        }
        
        for(Quote q :[SELECT Id, OMC_Submitted_Time__c,OMC_Rejected_Reason__c,OpportunityId FROM Quote WHERE OMC_Submitted_Time__c !=null AND OMC_Rejected_Reason__c !=null AND OpportunityId IN : opportunityToUpdate.keyset() order by OMC_Submitted_Time__c desc]){
            
            if(!relatedQuotes.containskey(q.OpportunityId)){
                relatedQuotes.put(q.OpportunityId,q);
            }
            
        }       	   
        for(Quote q :relatedQuotes.values()){
            opportunityToUpdate.get(q.OpportunityId).OMC_Rejected_Reason__c = q.OMC_Rejected_Reason__c;
            
        }
        
        update opportunityToUpdate.values();
        
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}