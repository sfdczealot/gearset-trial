// Test Class : Trigger_OpportunityLineItem_Test
public class oppLineItemTriggerHandler implements PGTriggerInterface{
    List<OpportunityLineItem> listOli = new List<OpportunityLineItem>();
    List<OpportunityLineItem> oldListOli = new List<OpportunityLineItem>();
    Map<Id,OpportunityLineItem> triggerOldMap = new Map<Id,OpportunityLineItem>();
    Map<Id,OpportunityLineItem> triggerNewMap = new Map<Id,OpportunityLineItem>();

    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;

    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }

    public void beforeInsert(List<sObject> newList) {
        for(Sobject oliObj : newList){
            OpportunityLineItem oli = (OpportunityLineItem)oliObj;
            listOli.add(oli);
        }
        oppLineItemTriggerHelper.updateOppLineItem(listOli);
        oppLineItemTriggerHelper.updateOLIStandardDiscount(listOli,null);

        listOli.clear();
    }

    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        for(Sobject oliObj : newList){
            OpportunityLineItem oli = (OpportunityLineItem)oliObj;
            listOli.add(oli);
        }

        for(Sobject oliObjMapInstance : newMap.values()){
            OpportunityLineItem oli2 = (OpportunityLineItem)oliObjMapInstance;
            triggerNewMap.put(oli2.Id,oli2);

        }
        oppLineItemTriggerHelper.trackHistoryAndSummarizeLineItem(listOli,triggerNewMap);
        oppLineItemTriggerHelper.selfServeNotification(listOli);
        listOli.clear();
        triggerNewMap.clear();
    }

    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        for(Sobject oliObj : newList){
            OpportunityLineItem oli = (OpportunityLineItem)oliObj;
            listOli.add(oli);
        }
          for(Sobject oliObjMapInstance : oldMap.values()){
            OpportunityLineItem oli2 = (OpportunityLineItem)oliObjMapInstance;
            triggerOldMap.put(oli2.Id,oli2);

        }
        oppLineItemTriggerHelper.updateOppLineItem(listOli);
        oppLineItemTriggerHelper.updateOLIStandardDiscount(listOli,triggerOldMap);

        listOli.clear();
        triggerOldMap.clear();
    }

    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        for(Sobject oliObj : newList){
            OpportunityLineItem oli = (OpportunityLineItem)oliObj;
            listOli.add(oli);
        }
        for(Sobject oliObj : oldList){
            OpportunityLineItem oli = (OpportunityLineItem)oliObj;
            oldListOli.add(oli);
        }
        for(Sobject oliObjMapInstance : newMap.values()){
            OpportunityLineItem oli2 = (OpportunityLineItem)oliObjMapInstance;
            triggerNewMap.put(oli2.Id,oli2);
        }
        for(Sobject oliObjMapInstance : oldMap.values()){
            OpportunityLineItem oli2 = (OpportunityLineItem)oliObjMapInstance;
            triggerOldMap.put(oli2.Id,oli2);
        }
        oppLineItemTriggerHelper.trackHisSummarizeOLISyncQLI(listOli,oldListOli,triggerNewMap,triggerOldMap);

        listOli.clear();
        oldListOli.clear();
        triggerNewMap.clear();
        triggerOldMap.clear();

    }

    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {

        for(Sobject oliObj : oldList){
            OpportunityLineItem oli = (OpportunityLineItem)oliObj;
            listOli.add(oli);
        }
        for(Sobject oliObjMapInstance : oldMap.values()){
            OpportunityLineItem oli2 = (OpportunityLineItem)oliObjMapInstance;
            triggerOldMap.put(oli2.Id,oli2);
        }
        oppLineItemTriggerHelper.trackHistoryAndCheckValidation(listOli,triggerOldMap);
        listOli.clear();
        triggerOldMap.clear();
    }

    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        for(Sobject oliObj : oldList){
            OpportunityLineItem oli = (OpportunityLineItem)oliObj;
            listOli.add(oli);
        }
        oppLineItemTriggerHelper.summarizeOppLineItem(listOli);
        listOli.clear();
    }

    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {
    }
}