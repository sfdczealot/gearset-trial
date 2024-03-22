//TEST CLASS: QuoteLineItemTriggerHandler_Test,PGQuoteTriggerHandler_Test
public class QuoteLineItemTriggerHandler implements PGTriggerInterface
{
    List<QuoteLineItem> listQli = new List<QuoteLineItem>();
    List<QuoteLineItem> oldListQli = new List<QuoteLineItem>();
    Map<Id,QuoteLineItem> triggerOldMap = new Map<Id,QuoteLineItem>();
    Map<Id,QuoteLineItem> triggerNewMap = new Map<Id,QuoteLineItem>();
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
     
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    
    //Update QLI fields in Before Insert        
    public void beforeInsert(List<sObject> newList) {       
        for(Sobject qliObj : newList){
            QuoteLineItem qli = (QuoteLineItem)qliObj;
            listQli.add(qli);
        }
        QuoteLineItemTriggerHelper.prepopulateQliFields(listQli);
         QuoteLineItemTriggerHelper.updateOLIStandardDiscount(listQli,null);
        
        listQli.clear();
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        for(Sobject qliObj : newList){
            QuoteLineItem qli = (QuoteLineItem)qliObj;
            listQli.add(qli);            
        }        
        QuoteLineItemTriggerHelper.summarizeLineItem(listQli);
        QuoteLineItemTriggerHelper.oliSynicngFields(listQli,null,true);
        QuoteLineItemTriggerHelper.updateQuoteFloorType(listQli,null,false);
         QuoteLineItemTriggerHelper.updatePackageType(newList);
        listQli.clear();
    }
    
	public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        for(Sobject qliObj : newList){
            QuoteLineItem qli = (QuoteLineItem)qliObj;
            listQli.add(qli);            
        }
         for(Sobject qliObjMapInstance : oldMap.values()){
            QuoteLineItem qli2 = (QuoteLineItem)qliObjMapInstance;
            triggerOldMap.put(qli2.Id,qli2);        
            
        }
        QuoteLineItemTriggerHelper.prepopulateQliFields(listQli);
        QuoteLineItemTriggerHelper.updateOLIStandardDiscount(listQli,triggerOldMap);
        
        listQli.clear();
        triggerOldMap.clear();
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        for(Sobject qliObj : newList){
            QuoteLineItem qli1 = (QuoteLineItem)qliObj;
            listQli.add(qli1);			            
        }
        for(Sobject qliObjMapInstance : oldMap.values()){
            QuoteLineItem qli2 = (QuoteLineItem)qliObjMapInstance;
            triggerOldMap.put(qli2.Id,qli2);			            
        }
        QuoteLineItemTriggerHelper.summarizeLineItem(listQli);
        QuoteLineItemTriggerHelper.oliSynicngFields(listQli, triggerOldMap,false);
        QuoteLineItemTriggerHelper.updateQuoteFloorType(listQli,triggerOldMap,false);
        QuoteLineItemTriggerHelper.trackHistory(listQli, triggerOldMap);
        QuoteLineItemTriggerHelper.updatePackageType(newList);
        listQli.clear();
        triggerOldMap.clear();
    }
    
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {  
        for(Sobject qliObj : oldList){
            QuoteLineItem qli = (QuoteLineItem)qliObj;
            oldListQli.add(qli);			            
        }
        
        for(Sobject qliObjMapInstance : oldMap.values()){
            QuoteLineItem qli2 = (QuoteLineItem)qliObjMapInstance;
            triggerOldMap.put(qli2.Id,qli2);			            
        }
        
        QuoteLineItemTriggerHelper.updateQuoteFloorType(oldListQli,triggerOldMap,true);
        oldListQli.clear();
        triggerOldMap.clear();
    }
    
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        for(Sobject qliObj : oldList){
            QuoteLineItem qli = (QuoteLineItem)qliObj;
            listQli.add(qli);			            
        }
         QuoteLineItemTriggerHelper.summarizeLineItem(listQli);
         QuoteLineItemTriggerHelper.DeletedQLI(listQli);
         listQli.clear();
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {         
    } 
   
}