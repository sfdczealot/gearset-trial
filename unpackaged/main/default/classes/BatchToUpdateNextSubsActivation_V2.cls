public class BatchToUpdateNextSubsActivation_V2 implements DataBase.Batchable<Sobject> {
    
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'select Id,Next_Subscription_Activation_Date__c,Subscription_Start_Date__c,(select Id,StageName,Count_of_Subscription_Item_new__c,OMC_Approved_Date__c  from Opportunities where StageName = \'Closed Won\' and Count_of_Subscription_Item_new__c > 1 order by OMC_Approved_Date__c desc limit 1 ) from Account where RecordType.DeveloperName= \'Agent\'';
        return DataBase.getQueryLocator(query);      
    }
    
    public void execute(Database.BatchableContext bc, List<Account> updateAccountList){
        
        Set<Id> oppId = new Set<Id>();
        List<Account> accListToUpdate = new List<Account>();
        
        system.debug(updateAccountList);
        for(Account acc : updateAccountList){
            
            if(acc.Opportunities.size()>0 && !acc.Opportunities.isEmpty() && acc.Opportunities[0].Count_of_Subscription_Item_new__c >1)
                oppId.add(acc.Opportunities[0].Id);
        }
        system.debug('**'+oppId);
        integer i=0;
        for(Opportunity opp : [select id, Name, AccountId, CloseDate, Account.Next_Subscription_Activation_Date__c,OMC_Approved_Date__c,
                               (select id, SNO__c, Actual_Start_date__c from OpportunityLineItems where Actual_Start_date__c != null 
                                AND SNO__c != null AND Product2.Product_Category__c='Subscription' Order By SNO__c ASC)
                               from Opportunity where id IN :oppId  ]){
                                   system.debug(opp.OpportunityLineItems);
                                   OpportunityLineItem getOLI = BatchToUpdateNextSubscriptionActivation.getOLIwithLowestSnoWhole(opp.OpportunityLineItems);
                                   if(getOLI != null){
                                       if(opp.Account.Next_Subscription_Activation_Date__c <= getOLI.Actual_Start_date__c
                                          && opp.account.Next_Subscription_Activation_Date__c != getOLI.Actual_Start_date__c
                                          && opp.closeDate <= getOLI.Actual_Start_date__c){
                                              Date t = date.newinstance(opp.OMC_Approved_Date__c.year(), 
                                                                        opp.OMC_Approved_Date__c.month(), opp.OMC_Approved_Date__c.day());
                                              //Update Account
                                              System.debug('Account '+Opp.Accountid +' opp '+opp.id);
                                              
                                              accListToUpdate.add(new Account(id=opp.AccountId,
                                                                              Next_Subscription_Activation_Date__c = getOLI.Actual_Start_date__c));
                                          }
                                   }
                               }
        System.debug('account Size' +accListToUpdate.size());
        update accListToUpdate;      
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
    
}