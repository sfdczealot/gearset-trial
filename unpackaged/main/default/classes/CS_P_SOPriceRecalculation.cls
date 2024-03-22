/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to update handle logic when Sales Order price recalculation is required
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic   <sasa.marjancic@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            sasa.marjancic@cloudsense.com
* 2019-02-22      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SOPriceRecalculation extends CS_ProcessBase {
    public static Boolean skipRollup = false;
    
    @TestVisible 
    Map<Id, csmso__Sales_Order__c> applicableObjects;
    
    @TestVisible
    Map<Id, csmso__Sales_Order__c> oldObjects;

    public CS_P_SOPriceRecalculation(Map<Id, csmso__Sales_Order__c> oldObjects) {
        super(CS_ProcessDefinition.SO_PRICERECALCULATION, 'CS_P_SOPriceRecalculation');
        
        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, csmso__Sales_Order__c>();
    }
 
    public override void isRecordEligible(SObject obj) {
        csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
        csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id);
        
        if((newSalesOrder.Advertiser_Final__c != oldSalesOrder.Advertiser_Final__c || newSalesOrder.Agency_Final__c != oldSalesOrder.Agency_Final__c ||
           newSalesOrder.Media_Agency_Commission__c != oldSalesOrder.Media_Agency_Commission__c || newSalesOrder.Billing_Calendar__c != oldSalesOrder.Billing_Calendar__c) && (newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_Draft || 
           newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_InProgress || newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_PriceRecalculationRequired || newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_Rejected || newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_Retracted)
           && newSalesOrder.SO_Lines_Number_Of_Lines__c > 0 && newSalesOrder.Sold__c == false) {
            applicableObjects.put(newSalesOrder.Id, newSalesOrder);
            skipRollup = true;
        }
        else if(newSalesOrder.csmso__Status__c == CS_const_SalesOrder.Status_PriceRecalculationRequired && newSalesOrder.SO_Lines_Price_Recalculated__c >= newSalesOrder.SO_Lines_Number_of_lines__c &&
                newSalesOrder.SO_Lines_Number_Of_Lines__c > 0) {
            applicableObjects.put(newSalesOrder.Id, newSalesOrder); 
        }

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        Set<Id> salesOrdersForRecalculation = new Set<Id>();
        for(csmso__Sales_Order__c salesOrder : applicableObjects.values()) {
              if(salesOrder.csmso__Status__c == CS_const_SalesOrder.Status_PriceRecalculationRequired && !skipRollup) {
                salesOrder.csmso__Status__c = salesOrder.Previous_Status__c;
                salesOrder.csmso__Process_Message_Type__c = null;
                salesOrder.csmso__Process_Message__c = null;
                salesOrder.Previous_Status__c = null;       
            }
            else {
                if(salesOrder.csmso__Status__c != CS_const_SalesOrder.Status_PriceRecalculationRequired) salesOrder.Previous_Status__c = salesOrder.csmso__Status__c;
                salesOrder.csmso__Process_Message_Type__c = CS_const_SalesOrder.ProcessMessageSeverity_Warning;
                salesOrder.csmso__Process_Message__c = Label.SO_Price_Recalculation_Required;
                salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_PriceRecalculationRequired;
                salesOrder.SO_Lines_Price_Recalculated__c = 0;
                
                salesOrdersForRecalculation.add(salesOrder.Id);
            }
        }
        
        if(!salesOrdersForRecalculation.isEmpty()) {
            List<cscfga__Product_Configuration__c> configs = [SELECT Id, FLAG_Price_Recalculated__c, cscfga__Configuration_Status__c
                                                      FROM cscfga__Product_Configuration__c
                                                      WHERE Sales_Order__c = :salesOrdersForRecalculation];
            
            for(cscfga__Product_Configuration__c config : configs) {
                config.FLAG_Price_Recalculated__c = 'No';
                config.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Incomplete;
            }
            
            update configs;
        }
    }
}