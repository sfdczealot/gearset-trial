/*
TestClass : BatchToUpdateNextSAD_Test
*/
public class BatchToUpdateNextSubscriptionActivation implements DataBase.Batchable<Sobject> {
    
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        
        String query = 'select Id,Next_Subscription_Activation_Date__c,Subscription_Start_Date__c,(select Id,StageName,Count_of_Subscription_Item_new__c,OMC_Approved_Date__c  from Opportunities where StageName = \'Closed Won\' and Count_of_Subscription_Item_new__c > 1 order by OMC_Approved_Date__c desc limit 1 ) from Account where RecordType.DeveloperName= \'Agent\' AND  Next_Subscription_Activation_Date__c = null';
        return DataBase.getQueryLocator(query);      
    }
    
    public void execute(Database.BatchableContext bc, List<Account> updateAccountList){
        
        Set<Id> oppId = new Set<Id>();
        List<Account> accListToUpdate = new List<Account>();
        for(Account acc : updateAccountList){
            if(acc.Opportunities.size()>0 && !acc.Opportunities.isEmpty() && acc.Opportunities[0].Count_of_Subscription_Item_new__c >1)
                oppId.add(acc.Opportunities[0].Id);
        }
        for(Opportunity opp : [select id,Name,AccountId,(select id, SNO__c,Actual_Start_date__c from OpportunityLineItems where Actual_Start_date__c != null AND SNO__c != null AND Product2.Product_Category__c='Subscription' Order By SNO__c ASC) from Opportunity where id IN :oppId  ]){
            
            OpportunityLineItem getOLI = getOLIwithLowestSnoWhole(opp.OpportunityLineItems);
            if(getOLI != null)
            accListToUpdate.add(new Account(id=opp.AccountId,Next_Subscription_Activation_Date__c = getOLI.Actual_Start_date__c));
        }
        if(!accListToUpdate.isEmpty())
        update accListToUpdate;
    }
    
    public void finish(Database.BatchableContext bc){
        
    }
    
    public static OpportunityLineItem getOLIwithLowestSnoWhole(list<OpportunityLineItem> SNoList){
        OpportunityLineItem oliReturn;
        for(OpportunityLineItem oli : SNoList){
            if(oli.Sno__c == Integer.valueOf(oli.Sno__c)){
                oliReturn = oli;
                break;
            }
        }
        
        return oliReturn;
    }
}