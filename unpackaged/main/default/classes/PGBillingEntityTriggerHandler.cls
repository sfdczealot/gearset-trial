public class PGBillingEntityTriggerHandler implements PGTriggerInterface{
             public static boolean isExecutedFromBETrigger = false;

  List<Billing_Entity__c> listBE;
    List<Billing_Entity__c> oldListBE ;
    Map<Id,Billing_Entity__c> triggerOldMap;
    Map<Id,Billing_Entity__c> triggerNewMap;
    
    public PGBillingEntityTriggerHandler() {  
        listBE = new  List<Billing_Entity__c>();
        oldListBE = new List<Billing_Entity__c>();
        triggerOldMap = new Map<Id,Billing_Entity__c>();
        triggerNewMap = new Map<Id,Billing_Entity__c>();
    }
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    public void beforeInsert(List<sObject> newList) { 
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        List<Billing_Entity__c> newBEList= new List<Billing_Entity__c>();
        newBEList = (List<Billing_Entity__c>)newList;
        
        updateFulfilmentAllowed(newBEList,null,(Map<Id, Billing_Entity__c>) newMap);
    }
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
       
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        List<Billing_Entity__c> newBEList= new List<Billing_Entity__c>();
        newBEList = (List<Billing_Entity__c>)newList;
        
        updateFulfilmentAllowed(newBEList,(Map<Id, Billing_Entity__c>) oldMap,(Map<Id, Billing_Entity__c>) newMap);
    }
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) { 
        
    }
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {         
    } 
    
    // update fulfilment Allowed field on sales force
    public static void updateFulfilmentAllowed(List<Billing_Entity__c> beList,Map<Id, Billing_Entity__c> oldMap,Map<Id, Billing_Entity__c> newMap){
        Set<id> accId = new Set<id>();
        Set<id> oppId = new Set<id>();
        String iPP_Sub = label.MY_SUBSIDIARY_IPP_NAME;
        List<csmso__Sales_Order__c> updateSOList = new list<csmso__Sales_Order__c>();
        System.debug('###'+beList);
        Map<id,string> AcctoBEMap = new Map<id,string>();
        
        for(Billing_Entity__c be: beList){
            if( (oldMap!= null && be.Credit_Status_Auto__c != oldMap.get(be.Id).Credit_Status_Auto__c && be.Subsidiary_Code__c =='iPP')||(oldMap == null && be.Subsidiary_Code__c =='iPP') ){
                 accId.add(be.Account__c);
                AcctoBEMap.put(be.Account__c,be.Credit_Status_Auto__c);
            }
           
        }
        System.debug('###'+accId);
        System.debug('###'+iPP_Sub);
       // list<Account> acc = [Select id,Name,(Select id from Opportunities) From Account Where id IN:accId];
        list<Opportunity> Opplist = [Select id,Name,AccountId,Subsidiary__r.Name, RecordType.DeveloperName From Opportunity Where AccountId IN: accId AND RecordType.DeveloperName = 'B2B' AND Subsidiary__r.Name =: iPP_Sub ];
      //  Map<id,list<Opportunity>> AccToOppMap = new Map<id,list<Opportunity>>();
      //  Map<id,list<csmso__Sales_Order__c>> OppToSOMap = new Map<id,list<csmso__Sales_Order__c>>();
        System.debug('@@@ opp list'+Opplist.size());
        
        for(Opportunity op: Opplist){
            oppId.add(op.id);
        }
       
        list<csmso__Sales_Order__c> solist = [Select Id,Fulfilment_Allowed__c,Updated_From__c,csmso__Opportunity__c,csmso__Opportunity__r.accountID from csmso__Sales_Order__c 
                                              where csmso__Opportunity__c IN :oppId and Updated_From__c != 'Manual'];
         System.debug('$$$'+solist.size());                               
        for(csmso__Sales_Order__c so: solist){
           // System.debug('&&&'+so.csmso__Opportunity__r.account.Credit_Status_Auto__c);
            if(AcctoBEMap.get(so.csmso__Opportunity__r.accountID) == 'Suspension'||
               AcctoBEMap.get(so.csmso__Opportunity__r.accountID) == 'Pre Suspension'){
                //   if(so.Fulfilment_Allowed__c!=false){
                so.Fulfilment_Allowed__c = false;
                so.Updated_From__c = 'Account Trigger';
                updateSOList.add(so);
                //   }
            }
            else if(AcctoBEMap.get(so.csmso__Opportunity__r.accountID) != 'Suspension' &&
                    AcctoBEMap.get(so.csmso__Opportunity__r.accountID) != 'Pre Suspension'){
                   //        if(so.Fulfilment_Allowed__c!=true){
                so.Fulfilment_Allowed__c = true;
                so.Updated_From__c = 'Account Trigger';
                updateSOList.add(so);
                    //       }
            }
            
        }           
        isExecutedFromBETrigger = true;
       update updateSOList;
        
        
    }
    
}