public class UpdateOpportunitiesOfAgent {
    @InvocableMethod(label='Update Related Opportunities' description='To update related Opportunities')
    public static void updateDefaultEntitlements(List<id> accIds) {
        list<opportunity> oppsToUpdate = new list<Opportunity>();
        for(Opportunity opp : [select id,Name,Agent_Accepted_Time__c,StageName from Opportunity where accountId IN : accIds limit 50000]){
        
            if((opp.Agent_Accepted_Time__c == null && opp.StageName == 'Pending Online Payment') || opp.StageName == 'Proposal'){
            
                opp.stageName = 'Closed Lost';
                opp.Loss_Reason__c = 'Agent is suspended or cancelled';
                oppsToUpdate.add(opp);    
            }
        }
        
        if(!oppsToUpdate.isEmpty()){
           
            Database.update(oppsToUpdate,false);
            //update oppsToUpdate;
            
        }       
    }   
}