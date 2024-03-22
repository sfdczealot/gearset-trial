/*
Test Class -SychQuoteOppBatchClass_Test_v2
*/
public class SychQuoteOppBatchClass implements DataBase.Batchable<Id> {
    
    Map<Id,Id> OpporIdVsQuoteId;
    public SychQuoteOppBatchClass(Map<Id,Id> OpportunityIdVsQuoteId){
        
        system.debug('OpportunityIdVsQuoteId>>>$$$>>> '+OpportunityIdVsQuoteId);
        OpporIdVsQuoteId = new Map<Id,Id>();
        OpporIdVsQuoteId = OpportunityIdVsQuoteId;
        
    }
    public Iterable<Id> start(DataBase.BatchableContext Bc){
        
        return OpporIdVsQuoteId.values();
    }
    
    public void execute(DataBase.BatchableContext Bc,List<Id> quoteId ){
        
        system.debug('quoteId>>>@@@>>> '+quoteId);
        if(quoteId != null){
            Set<Id> setquoteId=new Set<Id>();
            List<Opportunity> updateOpportunityList = new List<Opportunity>();
            System.debug('Queryyyyyyy'+[select Id,OpportunityId from Quote where OpportunityId =: quoteId]);
            for(Quote qu : [select Id,OpportunityId,Quote_Type__c from Quote where Id = : quoteId]){
               if(qu.Quote_Type__c=='B2C - Renewal'){
                    updateOpportunityList.add(new Opportunity(id=qu.OpportunityId,syncedQuoteId=qu.Id,StageName='Proposal'));
                   setquoteId.add(qu.Id);
                }else{
                    updateOpportunityList.add(new Opportunity(id=qu.OpportunityId,syncedQuoteId=qu.Id));
                    setquoteId.add(qu.Id);
                }
            }
            
            system.debug('updateOpportunityList>>>###>>> '+updateOpportunityList);
            if(!updateOpportunityList.IsEmpty())
                
                update updateOpportunityList;
            system.debug('updateOpportunityList@@@>>>%%% ' +updateOpportunityList);
            if(setquoteId.size()>0)
                QuoteSyncHandler.isQLITriggerFire=false;
                PGQuoteOpportunityHelper.updateQliToOli(setquoteId);
        }
        
    }
    public void finish(DataBase.BatchableContext bc){
        
    }
}