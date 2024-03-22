trigger Trigger_OpportunitySplit on OpportunitySplit (before Insert,before Update) {
    
    boolean isEnabled = true;
    //Check trigger execute
    
    Trigger_Execute__c TE = Trigger_Execute__c.getValues('Trigger_OpportunitySplit');
    isEnabled = TE.Enable_del__c;
    
    if(!isEnabled) {
        return;
    }
    
    Set<Id> setOfOpportunityId=new Set<Id>();
    If(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        for(OpportunitySplit each: trigger.new){
            setOfOpportunityId.add(each.OpportunityId);
        }
        Map<Id,Opportunity> mapOfClosedOpp=new Map<Id,Opportunity>([select id,StageName from Opportunity where Id IN :setOfOpportunityId and StageName='Closed Won' and (recordType.Name='B2B' OR recordType.Name='B2C')]);
        If(mapOfClosedOpp.size()>0){
            for(OpportunitySplit each: trigger.new){
                If(!Test.isRunningTest() && mapOfClosedOpp.keySet().contains(each.OpportunityId)){
                    each.adderror('You are not authorized to make these changes Opportunity is already closed.');
                }
            }
        }
    }
}