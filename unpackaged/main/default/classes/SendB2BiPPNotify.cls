public class SendB2BiPPNotify {
    
    @InvocableMethod 
    public static void callWorkato(List<String> IDList){
        system.debug('callWorkato');
        String sobjectType =((ID)IDList[0]).getSObjectType().getDescribe().getName();
        String objId = IDList[0];
        iPP_ideveloper__e  ippEvent = new iPP_ideveloper__e();
       String payloadId;
        if(sobjectType == 'Opportunity'){
            Opportunity opp = [Select id,Primary_Sales_Order__c,AccountId from opportunity where id =: objId];
            List<csdf__Fulfilment_Item__c> fliList = [Select id,Product_Configuration__c from csdf__Fulfilment_Item__c
                                                      where csdf__Fulfilment__r.Sales_Order__c  =: opp.Primary_Sales_Order__c
                                                      and Product_Configuration__r.Name like 'Developer Listings%'];
            if(fliList.size() > 0){
               payloadId = IDList[0];
            }
            
            
        } else {
            Account acc = [select id, (Select id from opportunities
                                       where Subsidiary__r.Subsidiary_Code__c = 'iPP' 
                                       and StageName='Closed Won') 
                           from Account where id = :IDList[0] ];
            if(acc.opportunities.size() > 0)
               payloadId = acc.opportunities[0].Id;
        }
        if(payloadId != null){
            ippEvent.opp_Id__c = payloadId;
            system.debug(iPPEvent);
            EventBus.publish(ippEvent);
        }
        //SendNotify.afterInsert(IDList);
        
    }
}