/*
* Test Class: VIPFlagSchedular_Test_v2
*/
public class VIPFlagSchedular implements Schedulable {
   public void execute(SchedulableContext SC) {
      updateVIPFlag();
   }
   public static void updateVIPFlag(){
        list<Opportunity> opportunityList =[Select id,AccountId,(Select Id, End_Date__c, Start_Date__c, Actual_Start_Date__c,Product_Category__c from OpportunityLineItems where Product_Category__c = 'Subscription'  LIMIT 1) from Opportunity where Account.VIP__c = true AND StageName = 'Closed Won' AND (Order_Type_Clone__c = 'Contract - Renewal' OR Opportunity_Type__c = 'B2C - Renewal') Order By OMC_Approved_Date__c DESC];
        set<id> accIds = new set<id>();
        list<Account> accListToUpdate = new list<Account>();
        for(Opportunity opp : opportunityList){
            if(!accIds.contains(opp.AccountId)){
                accIds.add(opp.AccountId);
                if(!opp.OpportunityLineItems.isEmpty()){
                    OpportunityLineItem oli = opp.OpportunityLineItems[0];
                    Date actualEndDate = oli.Start_Date__c == oli.Actual_Start_Date__c ? oli.End_Date__c : oli.Actual_Start_Date__c != null ? oli.Actual_Start_Date__c.addDays(oli.Start_Date__c.daysBetween(oli.End_Date__c)):null;
					if(actualEndDate != null && actualEndDate == system.today()){
                        Account ac = new Account();
                        ac.Id = opp.AccountId;
                        ac.VIP__c = false;
                        ac.VIP_Campaign__c = '';
                        ac.Approval_Status__c = '';
                        accListToUpdate.add(ac);
                    }     
                }
            }
        }
        if(!accListToUpdate.isEmpty())
            update accListToUpdate;
    }
    
}