// BatchToUpdateProRate_Test

public class BatchToUpdateProRate implements Database.Batchable<sObject>{
    
    public Database.QueryLocator start(Database.BatchableContext BC)  {
        
        string stageName2 = 'Closed Won';
        list<string> countryList = new list<string>{'Singapore','Malaysia'};
        string recordTypeName = 'Agent';
        list<string> statList = new list<string>{'Downgraded'};
            return Database.getQueryLocator('select id,Pro_Rate_Amount__c, (select id,Order_Type_Clone__c,Count_of_Subscription_Item__c, OMC_Approved_Date__c,Pro_Rate__c from OPportunities where Count_of_Subscription_Item__c > 0 AND stageName =: stageName2 AND OMC_Approved_Date__c != null Order By OMC_Approved_Date__c DESC Limit 1) from Account where Country__c IN :countryList  AND RecordType.Name =: recordTypeName AND Status__C In : statList');
    }
    
    public void execute(Database.BatchableContext BC, List<Account> accList) {
        List<Account> filteredList = new List<Account>();
        //list<Account> accList = [select id,Pro_Rate_Amount__c, (select id,Order_Type_Clone__c,Count_of_Subscription_Item__c, OMC_Approved_Date__c,Pro_Rate__c from OPportunities where Count_of_Subscription_Item__c > 1 AND stageName = 'Closed Won' AND OMC_Approved_Date__c != null Order By OMC_Approved_Date__c DESC Limit 1) from Account where Country__c = 'Singapore'AND OwnerID = '0057F000004F2PaQAK' AND RecordType.Name = 'Agent' Order By CreatedDate Limit 100 OFFSET 400];
        for(Account acc : accList){
            if(acc.Opportunities != null && !acc.Opportunities.isEmpty()){
                acc.Pro_Rate_Amount__c = acc.Opportunities[0].Pro_Rate__c;
                filteredList.add(acc);
            }
        }
        if(!filteredList.isEmpty()) {
            Update filteredList;
            system.debug('update succeeded for ' + filteredList.size() + 'accounts');
        } else {
            system.debug('No account to update');
        }
    }
    
    public void finish(Database.BatchableContext BC) {
        
    }
}