/*----------------------------------------------------
* Created By : 
* Created On : November 17,2020
* Description : To update Next_Subscription_Activation_Date__c on Account
* UnitTest : UpdateNextSubsDateOnAccount_Batch_Test.apxc
* --------------------------------------------------
*/
global class UpdateNextSubsDateOnAccount_Batch implements Database.Batchable<sObject> {
 
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        String query = 'Select id,AccountId,createdDate,Count_of_Subscription_Item_new__c,Account.Next_Subscription_Activation_Date__c,OMC_Approved_Date__c from Opportunity where Count_of_Subscription_Item_new__c = 1 and stageName=\'Closed Won\' and Account.Next_Subscription_Activation_Date__c = null order by createdDate Desc';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Opportunity> scope)  {
        
        Set<Id> oppIdSet = new Set<Id>();
        
        //fetch all ids and store in set
        for(Opportunity opp:scope){oppIdSet.add(opp.Id);}
        
        Map<Id,Account> accUpdateList = new Map<Id,Account>();
        
        List<Opportunity> oppList = new List<Opportunity>([Select Id,stageName,Name,OMC_Approved_Date__c,Account.RecordType.DeveloperName,
                                                           AccountId,
                                                           (select id, SNo__c, OpportunityId,Start_date__c 
                                                           from OpportunityLineItems where  SNO__c != null AND
                                                           Product2.Product_Category__c ='Subscription' Order By SNO__c ASC) 
                                                           from Opportunity where id =:oppIdSet]);
        Date startDate = null;
        Date approvedDate = null;
        System.debug('#opplist# '+oppList);
        if(!oppList.isEmpty()){
        for(Opportunity newOpp:oppList){
				System.debug('#inside opplist loop# '+oppList);
                if(newOpp.OMC_Approved_Date__c!=null) {
                    approvedDate = date.newInstance(newOpp.OMC_Approved_Date__c.year(),newOpp.OMC_Approved_Date__c.Month(),
                                                    newOpp.OMC_Approved_Date__c.Day());
                }
            
                if(newOpp.OpportunityLineItems.size() >= 1){
                    //check for lowest Integer SNO
                    OpportunityLineItem oli = BatchToUpdateNextSubscriptionActivation.getOLIwithLowestSnoWhole(newOpp.OpportunityLineItems);
                    
                    //DEPENDENCY of field Actual start date (Actual_Start_Date__c on OLI)
                    //Please update logic below if there is any change in Actual_Start_Date__c.
                    if(oli != null){
                        if(oli.Start_Date__c > approvedDate ){
                            startDate =  oli.Start_date__c; 
                        }
                        else {
                            startDate =  approvedDate;
                        }
                        
                    }
                }
                if(startDate !=null){
                    
                    //set Next Subscription Activation Date for all the accounts whose oppty is closed won with above conditions.
                    if(newOpp.Account.RecordType.DeveloperName == 'Agent'){
                        Account acc = new Account(Id = newOpp.AccountId,Next_Subscription_Activation_Date__c = startDate);
                        accUpdateList.put(acc.Id,acc);
                    }    
                }
        }//for loop ends
        Database.update(accUpdateList.values(),false);
    	}
        
    }
    global void finish(Database.BatchableContext BC)  {
        
    }
}