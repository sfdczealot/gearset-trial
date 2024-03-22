//TEST CLASS:QuoteRejection_Batch_Test
global class QuoteRejection_Batch implements Database.Batchable<sObject>, Database.Stateful{
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        String query ='SELECT Id, OpportunityId FROM Quote WHERE Quote_Type__c != \'\' AND (Opportunity.StageName = \'Closed Won\' OR Opportunity.StageName =\'Closed Lost\') AND (Opportunity.Recordtype.developerName =\'B2C\' OR Opportunity.Recordtype.developerName =\'B2C Closed Lost\')';
            
            return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<Quote> scope){
        Map<Id,String> quoteRejectReason = new Map<Id,String>();
        Map<ID,quote> quoteToUpdate = new Map<ID,quote>();
        list<Quote> quoteList = new list<Quote>();
        for(Quote q : scope){
            quoteToUpdate.put(q.id,q);
        }
        
        for (ProcessInstanceStep rowApproval : [SELECT ProcessInstance.TargetObjectId, StepStatus, comments  
                                                FROM ProcessInstanceStep 
                                                WHERE ProcessInstance.TargetObjectId =:quoteToUpdate.KeySet() 
                                                AND stepStatus='Rejected' order by createddate asc]) {
                                                    quoteRejectReason.put(rowApproval.ProcessInstance.TargetObjectId,rowApproval.comments);
                                                }  
        for(quote q : scope) {
         if(quoteRejectReason.containsKey(q.Id)){
                q.OMC_Rejected_Reason__c = quoteRejectReason.get(q.Id);
                quoteList.add(q);
            }
          
            
        }    
        update quoteList;
    }
    global void finish(Database.BatchableContext BC) {
        
    }
}