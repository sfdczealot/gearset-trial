/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle logic when Primary Trafficker changes
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2019-11-04      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_OppPrimaryTraffickerChange extends CS_ProcessBase {   
    @TestVisible 
    Map<Id, Opportunity> applicableObjects;
    
    @TestVisible
    Map<Id, Opportunity> oldObjects;

    public CS_P_OppPrimaryTraffickerChange(Map<Id, Opportunity> oldObjects) {
        super(CS_ProcessDefinition.OPPORTUNITY_PRIMARYTRAFFICKERCHANGE, 'CS_P_OppPrimaryTraffickerChange');
        
        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, Opportunity>(); 
    }
 
    public override void isRecordEligible(SObject obj) {
        Opportunity newOpp = (Opportunity) obj;
        Opportunity oldOpp = oldObjects != null ? (Opportunity) oldObjects.get(newOpp.Id) : null;
        
/*        if(newOpp.Primary_Trafficker__c != oldOpp.Primary_Trafficker__c && newOpp.Primary_Trafficker__r.csdf__Ad_Server__r.Id == newOpp.Ad_Server__r.Id && newOpp.Primary_Trafficker__c != null){
            applicableObjects.put(newOpp.Id, newOpp);
        }*/

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
/*        List<csmso__Sales_Order__c> applicableSalesOrders = [
                                                SELECT  Id, 
                                                        Ad_Server_Trafficker__c, 
                                                        csmso__Opportunity__r.Id
                                                   FROM csmso__Sales_Order__c
                                                   WHERE csmso__Opportunity__c IN :applicableObjects.keySet()];

        for(csmso__Sales_Order__c currSalesOrder : applicableSalesOrders) {
            Opportunity currOpp = applicableObjects.get(currSalesOrder.csmso__Opportunity__r.Id);
            currSalesOrder.Ad_Server_Trafficker__c = currOpp.Primary_Trafficker__c;
        }

        if(!applicableSalesOrders.isEmpty()) {
            update applicableSalesOrders;
        }*/
    }
}