/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Doing calculations on SOLI
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsensesolutions.com>
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_SOLIRollup extends CS_ProcessBase {
    Set<Id> applicableObjectIds;
    Set<Id> deletedObjectIds;
    Boolean isDelete;

    public CS_P_SOLIRollup(Boolean isDeleted) {
        super(CS_ProcessDefinition.SOLI_ROLLUP, 'CS_P_SOLIRollup');

        applicableObjectIds = new Set<Id>();
        deletedObjectIds = new Set<Id>();
        this.isDelete = isDeleted;
    }

    public override void isRecordEligible(SObject obj) {
        cscfga__Product_Configuration__c newProductConfiguration = (cscfga__Product_Configuration__c) obj;

        System.debug('newProductConfiguration.FLAG_Running_in_MLE__c => ' + newProductConfiguration.FLAG_Running_in_MLE__c);
        if(newProductConfiguration.Sales_Order__c != null && !newProductConfiguration.FLAG_Running_in_MLE__c) {
            applicableObjectIds.add(newProductConfiguration.Sales_Order__c);
        }

        if(this.isDelete) {
            deletedObjectIds.add(newProductConfiguration.Id);
        }

        this.runProcess = !applicableObjectIds.isEmpty() && !CS_P_SOPriceRecalculation.skipRollup;
    }

    public void addApplicableSalesOrderId(Id salesOrderId){
        applicableObjectIds.add(salesOrderId);
    }

    public override void logic() {
        try {
            doRollup();
        }
        catch (Exception e){
        }
    }

    public void doRollup() {
        System.debug('****** doing Rollup! ******');
        List<csmso__Sales_Order__c> salesOrders = [
                SELECT
                        Id, Name, SO_Lines_Number_of_lines__c, SO_Lines_Ad_Server_Items__c,
                        SO_Lines_Ad_Server_Inventory_Avail_Ov__c, Total_Price_Calculated__c, Total_Delivered__c, Total_Spend__c,
                        SO_Lines_Gross_Total__c, SO_Lines_Total_Discount__c, Flighting_Pending_Check_Avail__c, Total_Impressions__c,
                        SO_Lines_All_Valid__c, From_Calculated__c, To_Calculated__c, csmso__From__c, csmso__To__c, csmso__Status__c, Total_Price_before_Discount__c,
                        Total_Before_IO_Volume_Discount__c, SO_Lines_Price_Recalculated__c, Maximum_IO_Volume_Discount_Range__c, So_Lines_Pushed__c,
                        SO_Lines_Total_CoR__c, SO_Lines_Total_ProdCost__c, SO_Lines_Number_of_lines_CA__c, SO_Lines_Number_of_lines_CoR__c, SO_Lines_Number_lines_RI__c, 
                        SO_Lines_Total_Commission_Amount__c, To_Date_Time_Calculated__c, From_Date_Time_Calculated__c, FLAG_Buyer_Acceptance_Required__c, (
                        SELECT
                                Id, Name, Ad_Server_Item__c, Overbook__c, Inventory_Available__c,Developer_listing__c,DeveloperListing_Inventory_Available__c,
                                Net_Cost__c, Gross_Cost__c, Net_Rate_Adjustment_Flat__c, Sales_Order__c,
                                csmso__Availability_Check_Status__c, Configuration_Status_Tmp__c, Market__c, Total_Price_before_Discount__c,
                                Flight_Begin__c, Flight_End__c, Net_Total_Before_IO_Volume_Discount__c,
                                Ad_Server_Inventory_Available__c, Maximum_IO_Volume_Discount_Range__c, FLAG_Price_Recalculated__c,
                                Total_ProdCost__c, Total_CoR__c, Cost_Adjustment_Applied__c, Line_Item_Category__c, Ad_Server_Pushed__c,
                                Agency_Commission_Amount__c, Flight_End_Logged_User_Timezone__c, Flight_Begin_Logged_User_Timezone__c, FLAG_Buyer_Acceptance_Required__c,
                                Reserve_Inventory__c, Insertion_Unit_Type__c, Impressions__c, Total_Delivered_To_Date__c, Total_Spent_To_Date__c, cscfga__Description__c
                        FROM
                                Product_Configurations__r
                        WHERE
                                Rollup_to_SO__c = TRUE
                                AND Id NOT IN :deletedObjectIds
                )
                FROM csmso__Sales_Order__c
                WHERE Id IN :applicableObjectIds
                FOR UPDATE
        ];
        Map<Id, List<cscfga__Product_Configuration__c>> configsBySalesOrder = new Map<Id, List<cscfga__Product_Configuration__c>>();
        for(csmso__Sales_Order__c salesOrder : salesOrders) {
            configsBySalesOrder.put(salesOrder.Id, salesOrder.Product_Configurations__r);
        }

        update CS_utl_SalesOrder.doRollup(new Map<Id, csmso__Sales_Order__c>(salesOrders), configsBySalesOrder).values();
    }
}