/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle logic when Booking Contact changes
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2019-07-19      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_OppBookingContactChange extends CS_ProcessBase {   
    @TestVisible 
    Map<Id, Opportunity> applicableObjects;
    
    @TestVisible
    Map<Id, Opportunity> oldObjects;

    public CS_P_OppBookingContactChange(Map<Id, Opportunity> oldObjects) {
        super(CS_ProcessDefinition.OPPORTUNITY_BOOKINGCONTACTCHANGE, 'CS_P_OppBookingContactChange');
        
        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, Opportunity>(); 
    }
 
    public override void isRecordEligible(SObject obj) {
        Opportunity newOpp = (Opportunity) obj;
        Opportunity oldOpp = oldObjects != null ? (Opportunity) oldObjects.get(newOpp.Id) : null;
        
        if(newOpp.SO_Booking_Contact__c != oldOpp.SO_Booking_Contact__c) {
            applicableObjects.put(newOpp.Id, newOpp);
        }

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        List<csmso__Sales_Order__c> applicableSalesOrders = [
                                                SELECT  Id, 
                                                        csmso__Booking_Contact__c, 
                                                        csmso__Opportunity__r.Id
                                                   FROM csmso__Sales_Order__c
                                                   WHERE csmso__Opportunity__c IN :applicableObjects.keySet()];

        for(csmso__Sales_Order__c currSalesOrder : applicableSalesOrders) {
            Opportunity currOpp = applicableObjects.get(currSalesOrder.csmso__Opportunity__r.Id);
            currSalesOrder.csmso__Booking_Contact__c = currOpp.SO_Booking_Contact__c;
        }

        if(!applicableSalesOrders.isEmpty()) {
            update applicableSalesOrders;
        }
    }
}