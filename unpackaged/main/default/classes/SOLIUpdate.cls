public class SOLIUpdate  extends CS_ProcessBase {   
    @TestVisible 
    List<cscfga__Product_Configuration__c> applicableObjects;
    
    @TestVisible
    List<cscfga__Product_Configuration__c> oldObjects;

    public SOLIUpdate(List<cscfga__Product_Configuration__c> oldObjects) {
        super(CS_ProcessDefinition.CONFIGURATION_STATUSUPDATE, 'SOLIUpdate');
        
        applicableObjects = new List<cscfga__Product_Configuration__c>();
        this.oldObjects = oldObjects;
    }
 
    public override void isRecordEligible(SObject obj) {
        cscfga__Product_Configuration__c newPC = (cscfga__Product_Configuration__c) obj;
        
        applicableObjects.add(newPC);

        this.runProcess = !applicableObjects.isEmpty();
    }
 
    public override void logic() {  
          Set<String> basketIdSet = new Set<String>();
        list<Opportunity> OppToUpdateList = new List<Opportunity>();
        for(cscfga__Product_Configuration__c pc : oldObjects){
            basketIdSet.add(pc.cscfga__Product_Basket__c);
        }
        List<cscfga__Product_Basket__c> prodbasketList = [SELECT id, csmso__Sales_Order__r.csmso__Opportunity__c,csmso__Sales_Order__r.csmso__Opportunity__r.stageName,
                                                          csmso__Sales_Order__c, csmso__Sales_Order__r.Primary_Sales_Order__c 
                                                          FROM cscfga__Product_Basket__c WHERE id in :basketIdSet and csmso__Sales_Order__r.Primary_Sales_Order__c=true];
        for(cscfga__Product_Basket__c prodBasket: prodbasketList){
            if(prodbasket.csmso__Sales_Order__c != null && prodbasket.csmso__Sales_Order__r.csmso__Opportunity__c !=null){
                if(prodbasket.csmso__Sales_Order__r.csmso__Opportunity__r.stageName != 'Closed Won' && prodbasket.csmso__Sales_Order__r.csmso__Opportunity__r.stageName != 'Pending Client Signatory' 
                && prodbasket.csmso__Sales_Order__r.csmso__Opportunity__r.stageName != 'Pending OMC Approval' ){
                OppToUpdateList.add(New Opportunity(id=prodbasket.csmso__Sales_Order__r.csmso__Opportunity__c,
                                                    re_print_contract__c=true));
                }
            }
        }
        update OppToUpdateList;

    }
}