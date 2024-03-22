public class SendB2bNotify {
    
    @InvocableMethod 
    public static void callBifrost(List<String> IDList){
        String sobjectType =((ID)IDList[0]).getSObjectType().getDescribe().getName();
        String objId = IDList[0];
        if(sobjectType == 'Opportunity'){
            Opportunity opp = [Select id,Primary_Sales_Order__c,AccountId from opportunity where id =: objId];
            List<csdf__Fulfilment_Item__c> fliList = [Select id,Product_Configuration__c from csdf__Fulfilment_Item__c
                                                      where csdf__Fulfilment__r.Sales_Order__c  =: opp.Primary_Sales_Order__c
                                                      and Product_Configuration__r.Name like 'Developer Listings%'];
            if(fliList.size() > 0){
                List<String> temp = new List<String>();
                temp.add(opp.accountId);
                SendNotify.afterInsert(temp);
            }
        } else 
            SendNotify.afterInsert(IDList);
    }
}