public class SOPaymentTermRestriction  extends CS_ProcessBase {   
    @TestVisible 
    Map<Id, csmso__Sales_Order__c> applicableObjects;
    
    @TestVisible
    Map<Id, csmso__Sales_Order__c> oldObjects;
    
    @testVisible 
    set<String> oppSet = new set<String>();
    public SOPaymentTermRestriction(Map<Id, csmso__Sales_Order__c> newObjects,Map<Id, csmso__Sales_Order__c> oldObjects) {
        super(CS_ProcessDefinition.OPPORTUNITY_PAYMENTTERMSCHANGE, 'SOPaymentTermRestriction');
        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, csmso__Sales_Order__c>(); 
    }
    public override void isRecordEligible(SObject obj) {
        system.debug('@@obj::'+obj);
        csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
        csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id);
        list<Payment_Term__c> paymentMethodList = [select id,name from Payment_Term__c where name='Monthly'];
        
        system.debug('@@newSalesOrder::'+newSalesOrder);
        system.debug('@@oldSalesOrder::'+oldSalesOrder);
        system.debug('@@paymentMethodList::'+paymentMethodList);
        
        if(newSalesOrder.NetSuite_Payment_Term__c != oldSalesOrder.NetSuite_Payment_Term__c && newSalesOrder.NetSuite_Payment_Term__c == paymentMethodList[0].id) {
            applicableObjects.put(newSalesOrder.Id, newSalesOrder);
            oppSet.add(newSalesOrder.csmso__Opportunity__c);
        }
        this.runProcess = !applicableObjects.isEmpty();
    }
    public override void logic() {   
        
        List<String> SOList = new list<String>();
        Map<String,Opportunity> oppMap = new Map<String,Opportunity>([select id, RecordType.Name from opportunity where id in: oppSet]);
        List<cscfga__Product_Basket__c> basket = [
            SELECT Id, csmso__Sales_Order__c, (SELECT Id, Name,Aggregated_Status__c, cscfga__Description__c, cscfga__Product_Family__c FROM cscfga__Product_Configurations__r)
            FROM cscfga__Product_Basket__c
            WHERE csmso__Sales_Order__c = : applicableObjects.keySet() 
        ];
        for(cscfga__Product_Basket__c prodBasket : basket){
            for(cscfga__Product_Configuration__c config : prodBasket.cscfga__Product_Configurations__r){
                if(config.cscfga__Product_Family__c == 'MPD Subscriptions' || config.cscfga__Product_Family__c == 'MPD Custom Solutions'){
                    SOList.add(prodBasket.csmso__Sales_Order__c);
                    break;
                }
            }
        }
        for(String soId: applicableObjects.keySet()){
            if(oppMap.get(applicableObjects.get(soId).csmso__opportunity__c).RecordType.Name == 'B2B'){
                if(!SOList.contains(soId)){
                    applicableObjects.get(soId).addError('Monthly payment term is only applicable to MPD Products only.');
                }
            }
        }
    }
}