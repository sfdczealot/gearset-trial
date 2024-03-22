public class UpdateFulfilment_SO {
    @InvocableMethod
    public static void updateFulfilmentAllowed(list<id> recordId){
        
        id soId = recordId[0];
        
        csmso__Sales_Order__c so = [Select id,Name,csmso__Opportunity__c,csmso__Opportunity__r.AccountID,
                                    Fulfilment_Allowed__c From csmso__Sales_Order__c Where id =:soId];
  
        
        String AccId = so.csmso__Opportunity__r.AccountID;
        
        Map<id,Billing_Entity__c> AccIdvsEntityMap = new Map<id,Billing_Entity__c>();
       List<Billing_Entity__c> beList = new List<Billing_Entity__c>();
        beList = [Select id,Name,Subsidiary_Code__c,Account__c,Credit_Status_Auto__c From Billing_Entity__c
                                Where Account__c =:AccId and Subsidiary_Code__c ='iPP'];
        if(beList.size()>0){
        AccIdvsEntityMap.put(beList[0].Account__c, beList[0]);
        
        
        list<csmso__Sales_Order__c> updateSO = new list<csmso__Sales_Order__c>();
        
        if(AccIdvsEntityMap.containsKey(so.csmso__Opportunity__r.AccountID) && 
           AccIdvsEntityMap.get(so.csmso__Opportunity__r.AccountID).Credit_Status_Auto__c != 'Suspension' &&
           AccIdvsEntityMap.get(so.csmso__Opportunity__r.AccountID).Credit_Status_Auto__c != 'Pre Suspension' ){
               
               so.Fulfilment_Allowed__c = true;
               update so;
           } 
        }
    }
}