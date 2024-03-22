public class RestrictSODeletionCreation extends CS_ProcessBase {   
    @TestVisible 
   List<csmso__Sales_Order__c> applicableObjects;
    
    @TestVisible
    List<csmso__Sales_Order__c> oldObjects;
    public RestrictSODeletionCreation(List<csmso__Sales_Order__c> oldObjects) {
        super(CS_ProcessDefinition.SO_BOOKED, 'RestrictSODeletionCreation');
        
        this.oldObjects = oldObjects;
        applicableObjects =new list<csmso__Sales_Order__c>(); 
    }
    public override void isRecordEligible(SObject obj) {
        csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) obj;
        //csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) oldObjects.get(oldSalesOrder.Id);
        //if( newSalesOrder.csmso__Status__c == 'Booked' && oldSalesOrder.csmso__Status__c != 'Booked') {
        applicableObjects.add(oldSalesOrder);
        //}
        
        this.runProcess = !applicableObjects.isEmpty();
    }
    public override void logic() {  
        list<String> oppIdList = new  list<String>();
        for(csmso__Sales_Order__c so : applicableObjects){
            oppIdList.add(so.csmso__Opportunity__c);
        }
        
        Map<Id,Opportunity> oppMap = new Map<id,Opportunity>([Select Id,stageName 
                                                              from Opportunity 
                                                              where id in : oppIdList ]);
        for(csmso__Sales_Order__c so : applicableObjects){
            opportunity opp = oppMap.get(so.csmso__Opportunity__c);
            if(trigger.isDelete){
                if(opp.stageName != 'Closed Won'){
                    system.debug('******delete');
                    so.addError('You do not have access to Delete the record');
                }
            }
            else if(trigger.isInsert){
                if(opp.stageName == 'Closed Won'){
                   // system.debug('******delete');
                    so.addError('You cannot create Sales Order for closed won Opportunity');
                }
            }
        }
    }
}