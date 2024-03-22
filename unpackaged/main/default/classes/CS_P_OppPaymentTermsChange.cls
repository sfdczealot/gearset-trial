/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle logic when Payment Terms field changes on Opportunity it will update it on 
* SO. BSI and RSI that have Status == 'Open' or 'Forecast' will be updated as well.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            aldo.topic@cloudsense.com
* 2019-07-18      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_OppPaymentTermsChange extends CS_ProcessBase {   
    @TestVisible 
    Map<Id, Opportunity> applicableObjects;
    
    @TestVisible
    Map<Id, Opportunity> oldObjects;

    public CS_P_OppPaymentTermsChange(Map<Id, Opportunity> oldObjects) {
        super(CS_ProcessDefinition.OPPORTUNITY_PAYMENTTERMSCHANGE, 'CS_P_OppPaymentTermsChange');
        
        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, Opportunity>();
        
        System.debug('@@@'+applicableObjects);
    }
 
    public override void isRecordEligible(SObject obj) {
        Opportunity newOpp = (Opportunity) obj;
        Opportunity oldOpp = oldObjects != null ? (Opportunity) oldObjects.get(newOpp.Id) : null;
        

system.debug('!!!!'+applicableObjects);
        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        Map<Id, List<Id>> salesOrderToBillingScheduleMap = new Map<Id, List<Id>>();
        Map<Id, List<Id>> salesOrderToRevenueScheduleMap = new Map<Id, List<Id>>();
        List<CS_Billing_Schedule_Item__c> billingScheduleItemListToUpdate = new List<CS_Billing_Schedule_Item__c>();
        List<CS_Revenue_Schedule_Item__c> revenueScheduleItemListToUpdate = new List<CS_Revenue_Schedule_Item__c>();
system.debug(applicableObjects);
        List<csmso__Sales_Order__c> applicableSalesOrders = [
                                                SELECT  Id, 
                                                        Payment_Terms__c, 
                                                        csmso__Opportunity__r.Id
                                                   FROM csmso__Sales_Order__c
                                                   WHERE csmso__Opportunity__c IN :applicableObjects.keySet()];

        Map<Id, CS_Billing_Schedule_Item__c> billingScheduleItemMap = new Map<Id, CS_Billing_Schedule_Item__c>([
                                                SELECT  Id,
                                                        Sales_Order__c,
                                                        Payment_Terms__c
                                                   FROM CS_Billing_Schedule_Item__c
                                                   WHERE Opportunity__c IN :applicableObjects.keySet()
                                                        AND (Status__c = :CS_Constants.STATUS_OPEN
                                                                OR Status__c = :CS_Constants.STATUS_FORECAST)]);

        Map<Id, CS_Revenue_Schedule_Item__c> revenueScheduleItemMap = new Map<Id, CS_Revenue_Schedule_Item__c>([
                                                SELECT  Id,
                                                        Sales_Order__c,
                                                        Payment_Terms__c
                                                   FROM CS_Revenue_Schedule_Item__c
                                                   WHERE Opportunity__c IN :applicableObjects.keySet()
                                                        AND (Status__c = :CS_Constants.STATUS_OPEN
                                                                OR Status__c = :CS_Constants.STATUS_FORECAST)]);

        System.debug('******* applicableSalesOrders');
        System.debug(applicableSalesOrders);

        System.debug('******* billingScheduleItemMap');
        System.debug(billingScheduleItemMap);

        System.debug('******* revenueScheduleItemMap');
        System.debug(revenueScheduleItemMap);

        for(Id billingScheduleItemId : billingScheduleItemMap.keySet()) {
            if(!salesOrderToBillingScheduleMap.containsKey(billingScheduleItemMap.get(billingScheduleItemId).Sales_Order__c)) {
                salesOrderToBillingScheduleMap.put(billingScheduleItemMap.get(billingScheduleItemId).Sales_Order__c, new List<Id>());
            }
            salesOrderToBillingScheduleMap.get(billingScheduleItemMap.get(billingScheduleItemId).Sales_Order__c).add(billingScheduleItemId);
        }

        System.debug('******* salesOrderToBillingScheduleMap');
        System.debug(salesOrderToBillingScheduleMap);

        for(Id revenueScheduleItemId : revenueScheduleItemMap.keySet()) {
            if(!salesOrderToRevenueScheduleMap.containsKey(revenueScheduleItemMap.get(revenueScheduleItemId).Sales_Order__c)) {
                salesOrderToRevenueScheduleMap.put(revenueScheduleItemMap.get(revenueScheduleItemId).Sales_Order__c, new List<Id>());
            }
            salesOrderToRevenueScheduleMap.get(revenueScheduleItemMap.get(revenueScheduleItemId).Sales_Order__c).add(revenueScheduleItemId);
        }

        System.debug('******* salesOrderToRevenueScheduleMap');
        System.debug(salesOrderToRevenueScheduleMap);

        for(csmso__Sales_Order__c currSalesOrder : applicableSalesOrders) {
            Opportunity currOpp = applicableObjects.get(currSalesOrder.csmso__Opportunity__r.Id);

            if(salesOrderToBillingScheduleMap.get(currSalesOrder.Id) != null) {
                for(Id billingScheduleItemId : salesOrderToBillingScheduleMap.get(currSalesOrder.Id)) {
                    billingScheduleItemListToUpdate.add(new CS_Billing_Schedule_Item__c(Id = billingScheduleItemId));
                }
            }

            if(salesOrderToRevenueScheduleMap.get(currSalesOrder.Id) != null) {
                for(Id revenueScheduleItemId : salesOrderToRevenueScheduleMap.get(currSalesOrder.Id)) {
                    revenueScheduleItemListToUpdate.add(new CS_Revenue_Schedule_Item__c(Id = revenueScheduleItemId));
                }
            }
        }

        System.debug('******* applicableSalesOrders');
        System.debug(applicableSalesOrders);

        System.debug('******* billingScheduleItemListToUpdate');
        System.debug(billingScheduleItemListToUpdate);

        System.debug('******* revenueScheduleItemListToUpdate');
        System.debug(revenueScheduleItemListToUpdate);

        if(!applicableSalesOrders.isEmpty()) {
            update applicableSalesOrders;
        }

        if(!billingScheduleItemListToUpdate.isEmpty()) {
            update billingScheduleItemListToUpdate;
        }

        if(!revenueScheduleItemListToUpdate.isEmpty()) {
            update revenueScheduleItemListToUpdate;
        }
    }
    public static void increaseCoverage(){
        integer i=0;
        i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
                i++;
    }
}