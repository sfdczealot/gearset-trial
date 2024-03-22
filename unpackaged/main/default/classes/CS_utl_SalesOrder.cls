/**
 * @name CS_utl_SalesOrder
 * @description Utility methods for Sales Order
 * @revision
 *
 */
public class CS_utl_SalesOrder {
    @TestVisible
    static List<CS_utl_Rollup.RollupDefinition> CONFIG_TO_SALES_ORDER_TOTALS = new List<CS_utl_Rollup.RollupDefinition> {
            new CS_utl_Rollup.RollupDefinition('Net_Cost__c', 'Total_Price_Calculated__c', CS_utl_Rollup.Operation.SUM, null, 0),
            new CS_utl_Rollup.RollupDefinition('Total_Price_before_Discount__c', 'Total_Price_before_Discount__c', CS_utl_Rollup.Operation.SUM, null, 0),
            new CS_utl_Rollup.RollupDefinition('Gross_Cost__c', 'SO_Lines_Gross_Total__c', CS_utl_Rollup.Operation.SUM, null, 0),
            new CS_utl_Rollup.RollupDefinition('Net_Rate_Adjustment_Flat__c', 'SO_Lines_Total_Discount__c', CS_utl_Rollup.Operation.SUM, null, 0),
            new CS_utl_Rollup.RollupDefinition('Id', 'SO_Lines_Number_of_lines__c', CS_utl_Rollup.Operation.COUNT, null, 0),
            new CS_utl_Rollup.RollupDefinition('Ad_Server_Item__c', 'SO_Lines_Ad_Server_Items__c', CS_utl_Rollup.Operation.COUNT, true, 0),
            new CS_utl_Rollup.RollupDefinition('Ad_Server_Inventory_Available__c', 'SO_Lines_Ad_Server_Inventory_Avail_Ov__c', CS_utl_Rollup.Operation.COUNT, true, 0),
            new CS_utl_Rollup.RollupDefinition('Flight_Begin__c', 'From_Calculated__c', CS_utl_Rollup.Operation.MIN, null, null), 
            new CS_utl_Rollup.RollupDefinition('Flight_End__c', 'To_Calculated__c', CS_utl_Rollup.Operation.MAX, null, null),
            new CS_utl_Rollup.RollupDefinition('Flight_Begin__c', 'csmso__From__c', CS_utl_Rollup.Operation.MIN, null, null),
            new CS_utl_Rollup.RollupDefinition('Flight_End__c', 'csmso__To__c', CS_utl_Rollup.Operation.MAX, null, null), 
            new CS_utl_Rollup.RollupDefinition('Maximum_IO_Volume_Discount_Range__c', 'Maximum_IO_Volume_Discount_Range__c', CS_utl_Rollup.Operation.MAX, null, 0),
            new CS_utl_Rollup.RollupDefinition('csmso__Availability_Check_Status__c', 'Flighting_Pending_Check_Avail__c', CS_utl_Rollup.Operation.LOGICAL_OR, 'From Flighting', false),
            new CS_utl_Rollup.RollupDefinition('Configuration_Status_Tmp__c', 'SO_Lines_All_Valid__c', CS_utl_Rollup.Operation.LOGICAL_AND, 'Valid', true),
            new CS_utl_Rollup.RollupDefinition('FLAG_Price_Recalculated__c', 'SO_Lines_Price_Recalculated__c', CS_utl_Rollup.Operation.COUNT, 'Yes', 0),
            new CS_utl_Rollup.RollupDefinition('Total_ProdCost__c', 'SO_Lines_Total_ProdCost__c', CS_utl_Rollup.Operation.SUM, null, 0),
            new CS_utl_Rollup.RollupDefinition('Total_CoR__c', 'SO_Lines_Total_CoR__c', CS_utl_Rollup.Operation.SUM, null, 0),
            new CS_utl_Rollup.RollupDefinition('Cost_Adjustment_Applied__c', 'SO_Lines_Number_of_lines_CA__c', CS_utl_Rollup.Operation.COUNT, true, 0),
            new CS_utl_Rollup.RollupDefinition('Line_Item_Category__c', 'SO_Lines_Number_of_lines_CoR__c', CS_utl_Rollup.Operation.COUNT, 'Cost of Revenue', 0),
            new CS_utl_Rollup.RollupDefinition('Reserve_Inventory__c', 'SO_Lines_Number_lines_RI__c', CS_utl_Rollup.Operation.COUNT, true, 0),
            new CS_utl_Rollup.RollupDefinition('Market__c', 'Total_Markets__c', CS_utl_Rollup.Operation.COUNT_DISTINCT, null, new Set<String>()),
            new CS_utl_Rollup.RollupDefinition('Agency_Commission_Amount__c', 'SO_Lines_Total_Commission_Amount__c', CS_utl_Rollup.Operation.SUM, null, 0),
            new CS_utl_Rollup.RollupDefinition('Flight_Begin_Logged_User_Timezone__c', 'From_Date_Time_Calculated__c', CS_utl_Rollup.Operation.MIN, null, null),
            new CS_utl_Rollup.RollupDefinition('Flight_End_Logged_User_Timezone__c', 'To_Date_Time_Calculated__c', CS_utl_Rollup.Operation.MAX, null, null),
            new CS_utl_Rollup.RollupDefinition('FLAG_Buyer_Acceptance_Required__c', 'FLAG_Buyer_Acceptance_Required__c', CS_utl_Rollup.Operation.COUNT, true, 0),
            new CS_utl_Rollup.RollupDefinition('Ad_Server_Pushed__c', 'So_Lines_Pushed__c', CS_utl_Rollup.Operation.COUNT, true, 0),
            new CS_utl_Rollup.RollupDefinition('Impressions__c', 'Total_Impressions__c', CS_utl_Rollup.Operation.SUM, null, 0),
            new CS_utl_Rollup.RollupDefinition('Total_Delivered_To_Date__c', 'Total_Delivered__c', CS_utl_Rollup.Operation.SUM, null, 0),
            new CS_utl_Rollup.RollupDefinition('Total_Spent_To_Date__c', 'Total_Spend__c', CS_utl_Rollup.Operation.SUM, null, 0),
            new CS_utl_Rollup.RollupDefinition('Developer_listing__c', 'SO_Lines_Developer_Listing_Items__c', CS_utl_Rollup.Operation.COUNT, true, 0),
            new CS_utl_Rollup.RollupDefinition('DeveloperListing_Inventory_Available__c', 'SO_Lines_developer_Listing_Inven_Avail__c', CS_utl_Rollup.Operation.COUNT, true, 0)

        };

    /**
     * Checks if Sales Order is in progress
     * @param salesOrder csmso__Sales_Order__c
     * @return           Boolean
     */
    public static Boolean isInProgress(csmso__Sales_Order__c salesOrder) {
        return salesOrder != null && String.isNotBlank(salesOrder.csmso__Status__c) && (salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_InProgress)
                || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_Draft) || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_Retracted)
                || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_Rejected) || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_PriceRecalculationRequired)
                || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_PendingBooking) || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_ReservationRejected)
                || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_ReadyForCustomerApproval) || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_PendingCustomerApproval)
                || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_PendingComplianceApproval) || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_PendingCountersignIOApproval)
                || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_AccountCheck) || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_PendingLegalApproval)
                || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_PendingApprovals));
    }

    /**
     * Checks if Sales Order is retracted
     * @param salesOrder csmso__Sales_Order__c
     * @return           Boolean
     */
    public static Boolean isRetracted(csmso__Sales_Order__c salesOrder) {
        return salesOrder != null && String.isNotBlank(salesOrder.csmso__Status__c) && salesOrder.Last_Date_Booked__c != null &&
                (salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_Retracted)
                        || salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_Rejected));
    }

    /**
     * Checks if Sales Order is killed
     * @param salesOrder csmso__Sales_Order__c
     * @return           Boolean
     */
    public static Boolean isKilled(csmso__Sales_Order__c salesOrder) {
        return salesOrder != null && String.isNotBlank(salesOrder.csmso__Status__c) &&
                (salesOrder.csmso__Status__c.equals(CS_const_SalesOrder.Status_Killed));
    }

    /**
     * Checks if Sales Order is applicable for schedules
     * @param salesOrder csmso__Sales_Order__c
     * @return           Boolean
     */
    public static Boolean areSchedulesApplicable(csmso__Sales_Order__c salesOrder) {
        return !isKilled(salesOrder) && (!isInProgress(salesOrder) || (isInProgress(salesOrder) && salesOrder.Primary_Sales_Order__c && !isRetracted(salesOrder)) ||
                isRetracted(salesOrder) || salesOrder.Last_Date_Booked__c != null);
    }

    /**
     * Checks if Sales Order header fields have changed
     * @param salesOrder csmso__Sales_Order__c
     * @return           Boolean
     */
    public static Boolean hasHeaderChanged(csmso__Sales_Order__c salesOrder) {
        return true;
    }

    public static csmso__Sales_Order__c getSalesOrder(Id salesOrderId) {
        return [
                SELECT Id, Name, SO_Lines_Number_of_lines__c, SO_Lines_Ad_Server_Items__c, Is_Programmatic__c,SD_Approval__c, CM_Approval__c,
                 HOB_FastKey_Approval__c, HOB_Fintech_Approval__c, HOB_MaaS_Approval__c, HOB_Events_Approval__c, HOB_Awards_Approval__c, 
                 HOB_CNS_Approval__c, CBO_Approval__c,  OMC_Approval__c, so_end_date__c,Product_Subsidiary__c, Billing_Schedule__c,
SO_Lines_Ad_Server_Inventory_Avail_Ov__c, Total_Price_Calculated__c, Last_Date_Retracted__c,Current_User_Profile_Name__c,
                        SO_Lines_Gross_Total__c, SO_Lines_Total_Discount__c, Flighting_Pending_Check_Avail__c,
                        SO_Lines_All_Valid__c, From_Calculated__c, To_Calculated__c, csmso__From__c, csmso__To__c, csmso__Status__c, Customer_Approval__c, Total_Price_before_Discount__c,
                        Total_Before_IO_Volume_Discount__c, SO_Lines_Price_Recalculated__c, Maximum_IO_Volume_Discount_Range__c,
                        SO_Lines_Total_CoR__c, SO_Lines_Total_ProdCost__c, SO_Lines_Number_of_lines_CA__c, SO_Lines_Number_of_lines_CoR__c,
                        SO_Lines_Total_Commission_Amount__c, To_Date_Time_Calculated__c, From_Date_Time_Calculated__c, FLAG_Buyer_Acceptance_Required__c,
                        Agency_Final__r.Type, Advertiser_Final__r.Type,csmso__Opportunity__r.Recordtype.Name,csmso__Opportunity__r.stageName,
                        csmso__Opportunity__c, csmso__Opportunity__r.Primary_Salesperson__r.csdf__Ad_Server__r.Name, Counter_Sign_IO__c,csmso__Opportunity__r.Amount,
                        csmso__Opportunity__r.RecordType.DeveloperName, csmso__Opportunity__r.Agreement_Status__c, csmso__Opportunity__r.Agreement_Status_Date__c,
                        Comments__c, Order_Type__c, csmso__Purchase_Order_Number__c, Bill_To_Account_Final__c, Advertiser_Final__c,
                        IO_Template__c, csmso__Booking_Contact__c, T_C_Type__c, Billing_Email__c, Approval_Custom_Button__c, Submitted_By__c,
                        Reason_for_Retraction__c, Last_Date_Booked__c, Recall_Retract_Counter__c, Reason_for_Cancellation__c, Order_Synced_before_final_approval__c,
                        In_Retraction__c, Primary_Sales_Order__c, Approval_Inventory_Required__c, Approval_Sales_1_Required__c, Approval_Sales_2_Required__c,
                        Negotiation_Status__c, Proposal_Status__c, Sold__c, Last_Button_Clicked__c, NetSuite_Payment_Term__c,NetSuite_Payment_Term__r.NS_Payment_Term_ID__c , Is_Archived__c,
                        Synchronized_with_Opportunity__c, Approval_Requester_Comment__c, csmso__Opportunity__r.Account.B2B_ipp_REA__c,csmso__Opportunity__r.Subsidiary_Code__c, (
                        SELECT
                                Id, Name, Ad_Server_Item__c, Developer_listing__c,DeveloperListing_Inventory_Available__c,Overbook__c, Inventory_Available__c, Line_ID__c, Order_Line_ID__c, cscfga__Configuration_Status__c,
                                Net_Cost__c, Gross_Cost__c, Net_Rate_Adjustment_Flat__c, Sales_Order__c, Eligible_for_Check_Availability__c,
                                csmso__Availability_Check_Status__c, Configuration_Status_Tmp__c, Market__c, Total_Price_before_Discount__c,
                                Flight_Begin__c, Flight_End__c, Net_Total_Before_IO_Volume_Discount__c, Reservation_Status__c,
                                Ad_Server_Inventory_Available__c, Maximum_IO_Volume_Discount_Range__c, FLAG_Price_Recalculated__c, Opportunity_Subsidiary_Code__c,
                                Total_ProdCost__c, Total_CoR__c, Cost_Adjustment_Applied__c, Line_Item_Category__c, Reserve_Inventory__c, Number_of_Targetings__c,cscfga__Product_Family__c,
                                Agency_Commission_Amount__c, Flight_End_Logged_User_Timezone__c, Flight_Begin_Logged_User_Timezone__c, FLAG_Buyer_Acceptance_Required__c,
                                csmso__Flight_Begin__c, csmso__Flight_End__c, Digital_Product__r.Expiration_Date__c, Served_By__c, cscfga__package_guid__c, Fulfilment_Item_Status__c, Availability_Check__c
                        FROM
                                Product_Configurations__r
                )
                FROM csmso__Sales_Order__c
                WHERE Id = :salesOrderId
                LIMIT 1
        ];
    }

    /**
     * Gets Product Configurations based on Sales Order Ids
     * @param salesOrderIds Set<Id>
     * @return              Map<Id, List<cscfga__Product_Configuration__c>>
     */
    public static Map<Id, List<cscfga__Product_Configuration__c>> getProductConfigurations(Set<Id> salesOrderIds) {
        Map<Id, List<cscfga__Product_Configuration__c>> configsBySalesOrder = new Map<Id, List<cscfga__Product_Configuration__c>>();
        String queryString = CS_utl_Soql.buildQuery(
                Schema.cscfga__Product_Configuration__c.getSObjectType(),
                new Map<String, Set<Id>>{'Sales_Order__c' => salesOrderIds},
                CS_utl_Array.join(new List<String>{
                        CS_utl_SObject.getFieldList(csmso__Sales_Order__c.getSobjectType(), 'Sales_Order__r.'),
                        CS_utl_SObject.getFieldList(Billing_Schedule_Rule__c.getSobjectType(), 'Billing_Schedule_Rule__r.'),
                        CS_utl_SObject.getFieldList(Billing_Schedule_Rule__c.getSobjectType(), 'Revenue_Schedule_Rule__r.'),
                        'Billing_Schedule_Rule__r.RecordType.Name',
                        'Billing_Schedule_Rule__r.RecordType.DeveloperName',
                        'Revenue_Schedule_Rule__r.RecordType.Name',
                        'Revenue_Schedule_Rule__r.RecordType.DeveloperName',
                        'X3rd_Party_Ad_Server__r.X3rd_Party_Ad_Server__c'
                }, ','
                )
        );

        for(cscfga__Product_Configuration__c config : (List<cscfga__Product_Configuration__c>) Database.Query(queryString)) {
            if(!configsBySalesOrder.containsKey(config.Sales_Order__c)) {
                configsBySalesOrder.put(config.Sales_Order__c, new List<cscfga__Product_Configuration__c>());
            }

            configsBySalesOrder.get(config.Sales_Order__c).add(config);
        }

        return configsBySalesOrder;
    }

    /**
     * Gets Sales Order Schedules based on Sales Order Ids
     * @param salesOrderIds  Set<Id>
     * @param opportunityIds Set<Id>
     * @return               Map<Id, CS_Sales_Order_Schedule__c>
     */
    public static Map<Id, CS_Sales_Order_Schedule__c> getSalesOrderSchedules(Set<Id> salesOrderIds, Set<Id> opportunityIds) {
        Map<Id, CS_Sales_Order_Schedule__c> salesOrderSchedulesBySalesOrder = new Map<Id, CS_Sales_Order_Schedule__c>();
        String queryString = CS_utl_Soql.buildQuery(
                Schema.CS_Sales_Order_Schedule__c.getSObjectType(),
                new Map<String, Set<Id>>{
                        'Sales_Order__c' => salesOrderIds,
                        'Sales_Order__r.csmso__Opportunity__c' => opportunityIds
                },
                CS_utl_SObject.getFieldList(csmso__Sales_Order__c.getSobjectType(), 'Sales_Order__r.')
        );

        for(CS_Sales_Order_Schedule__c salesOrderSchedule : (List<CS_Sales_Order_Schedule__c>) Database.Query(queryString)) {
            salesOrderSchedulesBySalesOrder.put(salesOrderSchedule.Sales_Order__c, salesOrderSchedule);
        }

        return salesOrderSchedulesBySalesOrder;
    }

    /**
     * Do rollup summary on sales orders based on product configurations
     * @param salesOrders           Map<Id, csmso__Sales_Order__c>
     * @param productConfigurations Map<Id, List<cscfga__Product_Configuration__c>>
     * @return                      Map<Id, CS_Sales_Order_Schedule__c>
     */
    public static Map<Id, csmso__Sales_Order__c> doRollup(Map<Id, csmso__Sales_Order__c> salesOrders, Map<Id, List<cscfga__Product_Configuration__c>> productConfigurations) {
        for (csmso__Sales_Order__c salesOrder : salesOrders.values()) {
            List<CS_utl_Rollup.RollupDefinition> rollupDefinitions = CS_utl_Rollup.init(CONFIG_TO_SALES_ORDER_TOTALS);

            List<cscfga__Product_Configuration__c> configs = productConfigurations.containsKey(salesOrder.Id) ? productConfigurations.get(salesOrder.Id) : new List<cscfga__Product_Configuration__c>();
            for(CS_utl_Rollup.RollupDefinition definition : rollupDefinitions) {
                for(cscfga__Product_Configuration__c config : configs) {
                    definition.calculate(config);
                }
            }

            for(CS_utl_Rollup.RollupDefinition definition : rollupDefinitions) {
                salesOrder.put(definition.toField, definition.getValue());
            }
        }

        return salesOrders;
    }

    /**
     * Set SO Status to Killed and update SO Kill date
     * @param csmso__Sales_Order__c salesOrder
     */
    public static void killSalesOrder(csmso__Sales_Order__c salesOrder, Map<Id, cscfga__Product_Configuration__c> configs,
            List<csdf__Fulfilment_Item__c> fulfilmentItems, List<CS_Billing_Schedule_Item__c> bScheduleItems,
            List<CS_Revenue_Schedule_Item__c> rScheduleItems) {

        if(configs == null || configs.values().isEmpty()) {
            configs = new Map<Id, cscfga__Product_Configuration__c>([SELECT Id
            FROM cscfga__Product_Configuration__c
            WHERE Sales_Order__c = :salesOrder.Id]);
        }

        for (cscfga__Product_Configuration__c pc : configs.values()) {
            pc.Fulfilment_Item_Status__c = CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased;
        }
        update configs.values();

        //Delete BSI and RSI
        if (salesOrder.Sold__c) {
            CS_ScheduleService.cancelScheduleItems(bScheduleItems);
            CS_ScheduleService.cancelScheduleItems(rScheduleItems);
        }
        //Cancel BSI and RSI
        else {
            CS_ScheduleService.deleteScheduleItems(bScheduleItems);
            CS_ScheduleService.deleteScheduleItems(rScheduleItems);
        }

        List<csdf__Fulfilment_Item__c> fulfilmentItemsToUpdate = new List<csdf__Fulfilment_Item__c>();
        for (csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems) {
            fulfilmentItem.Last_Action_from_DFP__c = DateTime.now();
            fulfilmentItemsToUpdate.add(fulfilmentItem);
        }

        if(!fulfilmentItemsToUpdate.isEmpty()) {
            CS_utl_Fulfilment.setFulfilmentItemsToPausedInventoryReleased(fulfilmentItemsToUpdate);
        }

        Boolean primarySalesOrder = salesOrder.Primary_Sales_Order__c;

        List<Approval_Type__mdt> approvalTypeList = [
                SELECT Id, Field_Name__c
                FROM Approval_Type__mdt
                WHERE Field_Name__c != ''
        ];

        for(Approval_Type__mdt approvalType : approvalTypeList) {
            salesOrder.put(approvalType.Field_Name__c, null);
        }

        salesOrder.Primary_Sales_Order__c = false;
        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_KILLED;
        salesOrder.SO_Kill_date__c = Datetime.now();
        salesOrder.Callout_Type__c = null;
        update salesOrder;

        if (primarySalesOrder) {
            setPrimarySO(salesOrder);
        }
    }

    /**
     * Update Primary SO on Opp after previous Primary was killed
     * @param csmso__Sales_Order__c salesOrder
     */
    public static void setPrimarySO(csmso__Sales_Order__c killedSalesOrder) {
        List<csmso__Sales_Order__c> salesOrders = [
                SELECT Id
                FROM csmso__Sales_Order__c
                WHERE csmso__Status__c != :CS_const_SalesOrder.Status_Killed
                AND  Id != :killedSalesOrder.Id
                AND  csmso__Opportunity__c = :killedSalesOrder.csmso__Opportunity__c
                ORDER BY LastModifiedDate DESC
        ];

        if(!salesOrders.isEmpty()) {
            salesOrders.get(0).Primary_Sales_Order__c = true;
            update salesOrders.get(0);
        }
        else {
            update new Opportunity(Id = killedSalesOrder.csmso__Opportunity__c, Primary_Sales_Order__c = null);
        }
    }
}