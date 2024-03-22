/**
 * @name CS_ScheduleService
 * @description Service class for handling schedules (billing and revenue)
 * @revision
 *
 */
public class CS_ScheduleService extends CS_DMLWorker {
    /**
     * List of possible objects for insert, determines the order based on hierarchy
     */
    public static List<SObjectType> SObjectTypes_Order = new List<SObjectType>{
            Schema.CS_Sales_Order_Schedule__c.getSObjectType(),
            Schema.CS_Billing_Schedule__c.getSObjectType(),
            Schema.CS_Revenue_Schedule__c.getSObjectType(),
            Schema.CS_Billing_Schedule_Item__c.getSObjectType(),
            Schema.CS_Revenue_Schedule_Item__c.getSObjectType()
    };

    /**
     * Map of Sales Orders
     */
    @TestVisible
    Map<Id, csmso__Sales_Order__c> salesOrders {
        get {
            if (salesOrders == null) {
                salesOrders = new Map<Id, csmso__Sales_Order__c>();
                for (List<cscfga__Product_Configuration__c> configs : productConfigurations.values()) {
                    salesOrders.put(configs.get(0).Sales_Order__c, configs.get(0).Sales_Order__r);
                }
            }
            return salesOrders;
        }
        set;
    }

    /**
     * List of Product Configurations for Sales Orders
     */
    public Map<Id, List<cscfga__Product_Configuration__c>> productConfigurations {
        get {
            if (productConfigurations == null) {
                productConfigurations = CS_utl_SalesOrder.getProductConfigurations(salesOrderIds);
            }
            return productConfigurations;
        }
        set;
    }

    public Map<Id, cscfga__Product_Configuration__c> productConfigurationsById {
        get {
            if (productConfigurationsById == null) {
                productConfigurationsById = new Map<Id, cscfga__Product_Configuration__c>();
                for (List<cscfga__Product_Configuration__c> configs : productConfigurations.values()) {
                    productConfigurationsById.putAll(configs);
                }
            }
            return productConfigurationsById;
        }
        set;
    }

    /**
     * List of Sales Order Schedules for Sales Orders
     */
    @TestVisible
    Map<Id, CS_Sales_Order_Schedule__c> salesOrderSchedules {
        get {
            if (salesOrderSchedules == null) {
                salesOrderSchedules = CS_utl_SalesOrder.getSalesOrderSchedules(salesOrderIds, opportunityIds);
            }
            return salesOrderSchedules;
        }
        set;
    }

    /**
     * List of Billing Schedule for Product Configurations
     */
    @TestVisible
    Map<Id, CS_Billing_Schedule__c> billingSchedules {
        get {
            if (billingSchedules == null) {
                billingSchedules = new Map<Id, CS_Billing_Schedule__c>();
                for (Id productConfigurationId : billingScheduleItems.keySet()) {
                    billingSchedules.put(productConfigurationId, billingScheduleItems.get(productConfigurationId).get(0).Billing_Schedule__r);
                }
            }
            return billingSchedules;
        }
        set;
    }

    /**
     * List of Billing Schedule Items for Product Configurations
     */
    public Map<Id, List<CS_Billing_Schedule_Item__c>> billingScheduleItems {
        get {
            if (billingScheduleItems == null) {
                billingScheduleItems = CS_utl_ProductConfiguration.getBillingScheduleItems(productConfigurationIds);
            }
            return billingScheduleItems;
        }
        set;
    }

    /**
     * List of Revenue Schedule for Product Configurations
     */
    @TestVisible
    Map<Id, CS_Revenue_Schedule__c> revenueSchedules {
        get {
            if (revenueSchedules == null) {
                revenueSchedules = new Map<Id, CS_Revenue_Schedule__c>();
                for (Id productConfigurationId : revenueScheduleItems.keySet()) {
                    revenueSchedules.put(productConfigurationId, revenueScheduleItems.get(productConfigurationId).get(0).Revenue_Schedule__r);
                }
            }
            return revenueSchedules;
        }
        set;
    }

    /**
     * List of Revenue Schedule Items for Product Configurations
     */
    @TestVisible
    Map<Id, List<CS_Revenue_Schedule_Item__c>> revenueScheduleItems {
        get {
            if (revenueScheduleItems == null) {
                revenueScheduleItems = CS_utl_ProductConfiguration.getRevenueScheduleItems(productConfigurationIds);
            }
            return revenueScheduleItems;
        }
        set;
    }

    /**
     * Set of all Product Configuration Ids
     */
    @TestVisible
    Set<Id> productConfigurationIds {
        get {
            if (productConfigurationIds == null) {
                productConfigurationIds = new Set<Id>();
                for (List<cscfga__Product_Configuration__c> configs : productConfigurations.values()) {
                    productConfigurationIds.addAll(new Map<Id, cscfga__Product_Configuration__c>(configs).keySet());
                }
            }
            return productConfigurationIds;
        }
        set;
    }

    /**
     * Set of all Opportunity Ids
     */
    @TestVisible
    Set<Id> opportunityIds {
        get {
            if (opportunityIds == null) {
                opportunityIds = new Set<Id>();
                for (csmso__Sales_Order__c salesOrder : salesOrders.values()) {
                    opportunityIds.add(salesOrder.csmso__Opportunity__c);
                }
            }
            return opportunityIds;
        }
        set;
    }

    /**
     * Set of all Sales Order Ids
     */
    @TestVisible
    Set<Id> salesOrderIds { get; set; }

    public CS_ScheduleService(Set<Id> salesOrderIds, Set<Id> productConfigurationIds) {
        super(false, SObjectTypes_Order);
        this.salesOrderIds = salesOrderIds;
        this.productConfigurationIds = productConfigurationIds;
    }

    /**
     * Delete forecast revenue schedules
     * @param salesOrderIds	Set<Id>
     */
    public static void deleteForecastSchedules(Set<Id> salesOrderIds) {
        Set<Id> opportunityIds = new Set<Id>();
        for (csmso__Sales_Order__c salesOrder : [SELECT csmso__Opportunity__c FROM csmso__Sales_Order__c WHERE Id = :salesOrderIds]) {
            opportunityIds.add(salesOrder.csmso__Opportunity__c);
        }

        delete [SELECT Id FROM CS_Revenue_Schedule_Item__c WHERE Sales_Order__r.csmso__Opportunity__c IN :opportunityIds AND IsForecast__c = true];
    }

    /**
     * Checks if the changes made are valid
     * @param salesOrderIds	Set<Id>
     */
    public static String validateSchedules(Set<Id> salesOrderIds, Set<Id> productConfigurationIds) {
        return CS_ScheduleService.validateSchedules(salesOrderIds, productConfigurationIds, null, true);
    }

    /**
     * Checks if the changes made are valid
     * @param salesOrderIds	Set<Id>
     */
    public static String validateSchedules(Set<Id> salesOrderIds, Set<Id> productConfigurationIds, Map<Id, List<cscfga__Product_Configuration__c>> configs, Boolean doUpsert) {
        CS_LogWorker log = CS_LogWorker.getInstance();

        try {
            CS_ScheduleService scheduleService = new CS_ScheduleService(salesOrderIds, productConfigurationIds);
            scheduleService.productConfigurations = configs;
            return scheduleService.validateSchedules(doUpsert);
        } catch (Exception e) {
            List<csmso__Sales_Order__c> salesOrdersToUpdate = new List<csmso__Sales_Order__c>();
            for (Id salesOrderId : salesOrderIds) {
                salesOrdersToUpdate.add(new csmso__Sales_Order__c(
                        Id = salesOrderId,
                        csmso__Process_Message__c = Label.Error_Validating_In_Flight_change_schedules,
                        csmso__Process_Message_Type__c = CS_const_SalesOrder.ProcessMessageSeverity_Warning
                ));
                log.addMessage(e, salesOrderId);
            }

            log.save('CS_ScheduleService', 'Synchronous', null, false);
            if (doUpsert)
                update salesOrdersToUpdate;

            return Label.Error_Validating_In_Flight_change_schedules;
        }
    }

    private static void generateSchedluesAsync(Set<Id> soIds) {
        CS_Custom_Settings__c setting = CS_Custom_Settings__c.getInstance();
        for (Id soId : soIds) {
            CS_BatchScheduleableService batch = new CS_BatchScheduleableService(soId);
            Database.executeBatch(batch, Integer.valueOf(setting.BillingBatchSize__c));
        }
    }

    public static void completeSteps(Set<Id> soIds) {
        List<CSPOFA__Orchestration_Step__c> stepsToUpdate = new List<CSPOFA__Orchestration_Step__c>();
        For(CSPOFA__Orchestration_Step__c step : [SELECT Id, Name, CSPOFA__Status__c, CSPOFA__External_Id__c FROM CSPOFA__Orchestration_Step__c WHERE CSPOFA__external_id__c IN :soIds AND CSPOFA__Status__c = 'Waiting For Feedback']) {
            step.CSPOFA__Status__c = 'Complete';
            step.CSPOFA__Message__c = 'Action completed.';
            step.CSPOFA__Completed_Date__c = Date.today();
            stepsToUpdate.add(step);
        }

        update stepsToUpdate;
    }

    /**
     * Generate Schedules based on Sales Orders and Product Configurations
     * @param salesOrderIds			  Set<Id>
     * @param productConfigurationIds Set<Id>
     * @return           			  Boolean
     */
    public static Boolean generateSchedules(Set<Id> salesOrderIds, Set<Id> productConfigurationIds) {
        List<csmso__Sales_Order__c> salesOrders = [SELECT Id, From_Calculated__c, To_Calculated__c FROM csmso__Sales_Order__c WHERE Id IN :salesOrderIds];
        Set<Id> asyncSoIds = new Set<Id>();
        CS_Custom_Settings__c setting = CS_Custom_Settings__c.getInstance();
        for (csmso__Sales_Order__c so : salesOrders) {
            if (so.From_Calculated__c != null && so.To_Calculated__c != null) {
                Integer days = so.From_Calculated__c.daysBetween(so.To_Calculated__c);
                if (days > setting.Days__c) {
                    salesOrderIds.remove(so.id);
                    asyncSoIds.add(so.id);
                }
            }
        }
        if (asyncSoIds.size() > 0) {
            CS_ScheduleService.generateSchedluesAsync(asyncSoIds);
        }

        if (salesOrderIds.size() > 0) {
            CS_LogWorker log = CS_LogWorker.getInstance();

            System.Savepoint sPoint = Database.setSavepoint();
            try {
                CS_ScheduleService scheduleService = new CS_ScheduleService(salesOrderIds, productConfigurationIds);
                scheduleService.generateSchedules();
                completeSteps(salesOrderIds);
            } catch (Exception e) {
                System.debug('Exception => ' + e);

                Database.rollback(sPoint);

                List<csmso__Sales_Order__c> salesOrdersToUpdate = new List<csmso__Sales_Order__c>();
                for (Id salesOrderId : salesOrderIds) {
                    salesOrdersToUpdate.add(new csmso__Sales_Order__c(
                            Id = salesOrderId,
                            csmso__Process_Message__c = Label.Error_generating_schedules,
                            csmso__Process_Message_Type__c = CS_const_SalesOrder.ProcessMessageSeverity_Warning
                    ));
                    log.addMessage(e, salesOrderId);
                }

                log.save('CS_ScheduleService', 'Synchronous', null, false);
                update salesOrdersToUpdate;

                return false;
            }
        }
        return true;
    }

    public static Boolean updateSchedules(Set<Id> salesOrderIds, Set<Id> productConfigurationIds) {
        CS_LogWorker log = CS_LogWorker.getInstance();

        System.Savepoint sPoint = Database.setSavepoint();
        try {
            CS_ScheduleService scheduleService = new CS_ScheduleService(salesOrderIds, productConfigurationIds);
            return scheduleService.updateSchedules();
        } catch (Exception e) {
            Database.rollback(sPoint);

            for (Id salesOrderId : salesOrderIds) {
                log.addMessage(e, salesOrderId);
            }

            return false;
        }
    }

    public String validateSchedules(Boolean doUpsert) {
        String result = null;

        List<cscfga__Product_Configuration__c> configToUpdate = new List<cscfga__Product_Configuration__c>();
        for (Id salesOrderId : salesOrderIds) {
            if (productConfigurations.containsKey(salesOrderId)) {
                for (cscfga__Product_Configuration__c config : productConfigurations.get(salesOrderId)) {
                    config.IFC_Validation_Message__c = validateConfiguration(config);
                    if (String.isNotBlank(config.IFC_Validation_Message__c)) {
                        result = config.IFC_Validation_Message__c;
                    }

                    configToUpdate.add(config);
                }
            }
        }

        if (doUpsert) update configToUpdate;

        return result;
    }

    public Map<Id, Map<String, Decimal>> calculateQuantity() {
        Map<Id, Map<String, Decimal>> quantities = new Map<Id, Map<String, Decimal>>();
        for (Id salesOrderId : salesOrderIds) {
            if (productConfigurations.containsKey(salesOrderId)) {
                for (cscfga__Product_Configuration__c cfg : productConfigurations.get(salesOrderId)) {
                    quantities.put(cfg.Id, calculateQuantity(cfg));
                }
            }
        }

        return quantities;
    }

    public Map<String, Decimal> calculateQuantity(cscfga__Product_Configuration__c config) {
        if (billingSchedules.containsKey(config.Id)) {
            CS_Billing_Schedule__c parent = getBillingSchedule(config);
            List<CS_Billing_Schedule_Item__c> scheduleItems = billingScheduleItems.get(config.Id);

            Map<String, Decimal> quantites = new Map<String, Decimal>{
                    'totalBilledToDate' => CS_utl_Sobject.getDecimalValue('Total_Billed_Quantity_To_Date__c', parent),
                    'dfpActuals' => CS_utl_Sobject.getDecimalValue('Total_Billed_Quantity_To_Date__c', parent),
                    'thirdPartyActuals' => CS_utl_Sobject.getDecimalValue('Total_Billed_Quantity_To_Date__c', parent),
                    'contractedActuals' => CS_utl_Sobject.getDecimalValue('Total_Billed_Quantity_To_Date__c', parent),
                    'scheduledQuantity' => CS_utl_Sobject.getDecimalValue('Total_Billed_Quantity_To_Date__c', parent),
                    'overwriteQuantity' => CS_utl_Sobject.getDecimalValue('Total_Billed_Quantity_To_Date__c', parent)
            };

            for (CS_Billing_Schedule_Item__c scheduleItem : scheduleItems) {
                if (!CS_utl_Schedule.isBilled(scheduleItem)) {
                    quantites.put('dfpActuals', quantites.get('dfpActuals') + CS_utl_Sobject.getDecimalValue('DFP_Actuals__c', scheduleItem));
                    quantites.put('thirdPartyActuals', quantites.get('thirdPartyActuals') + CS_utl_Sobject.getDecimalValue('X3rd_Party_Actuals__c', scheduleItem));
                    quantites.put('overwriteQuantity', quantites.get('overwriteQuantity') + CS_utl_Sobject.getDecimalValue('Overwrite_Quantity__c', scheduleItem));
                    if ((Boolean) scheduleItem.get('Is_Closed__c')) {
                        quantites.put('contractedActuals', quantites.get('contractedActuals') + CS_utl_Sobject.getDecimalValue('Billing_Quantity__c', scheduleItem));
                        quantites.put('scheduledQuantity', quantites.get('scheduledQuantity') + CS_utl_Sobject.getDecimalValue('Scheduled_Quantity__c', scheduleItem));
                    }
                }
            }

            return quantites;
        }

        return new Map<String, Decimal>();
    }

    public String validateConfiguration(cscfga__Product_Configuration__c config) {
        if (billingSchedules.containsKey(config.Id)) {
            CS_Billing_Schedule__c parent = getBillingSchedule(config);

            if (config.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased) {
                Boolean isActiveLine = config.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Draft && config.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Inactive &&
                        config.Fulfilment_Item_Status__c != CS_const_SalesOrder.FulfilmentItemStatus_Ready;
                String lineId = config.get('Line_ID__c') != null ? String.valueOf(config.get('Line_ID__c')) : '';
                Map<String, Decimal> quantites = calculateQuantity(config);
                CS_Billing_Schedule_Item__c lastScheduleItem;
                CS_Billing_Schedule_Item__c firstScheduleItem;

                List<CS_Billing_Schedule_Item__c> scheduleItems = billingScheduleItems.get(config.Id);
                for (CS_Billing_Schedule_Item__c scheduleItem : scheduleItems) {
                    lastScheduleItem = lastScheduleItem == null ? scheduleItem : lastScheduleItem.Billing_Date__c > scheduleItem.Billing_Date__c ? lastScheduleItem : scheduleItem;
                    firstScheduleItem = firstScheduleItem == null ? scheduleItem : firstScheduleItem.Billing_Date__c < scheduleItem.Billing_Date__c ? firstScheduleItem : scheduleItem;
                    if (scheduleItem.Billing_Period_Start_Date__c < Date.today()
                            && scheduleItem.Billing_Period_Start_Date__c < config.Flight_Begin__c
                            && isActiveLine
                            && scheduleItem.Status__c != CS_Constants.STATUS_CANCELLED
                            && !scheduleItem.Valid_for_Auto_Cancellation__c) {

                        return Label.SO_Billing_started_Start_Date_immutable + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : '');
                    }

                    if (!CS_utl_Schedule.isBilled(scheduleItem)) {
                        if (scheduleItem.Billing_Period_End_Date__c < Date.today() && scheduleItem.Billing_Period_End_Date__c > config.Flight_End__c)
                            return Label.SO_Billing_started_End_Date_before_today + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : '');
                        if ((Boolean) scheduleItem.get('Is_Closed__c')) {
                            if (scheduleItem.Billing_Period_End_Date__c > config.Flight_End__c)
                                return Label.SO_Billing_ended_End_date_earlier_than + scheduleItem.Billing_Period_End_Date__c.format() + '.' + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : '');
                        }
                    }
                }

                if (CS_utl_Datetime.getTimezoneOffset(config.Flight_Begin_Date_Time_Selected__c) < Datetime.now()
                        && isActiveLine
                        && lastScheduleItem.Status__c != CS_Constants.STATUS_CANCELLED
                        && !lastScheduleItem.Valid_for_Auto_Cancellation__c
                        && CS_utl_Datetime.getTimezoneOffset(config.Flight_Begin_Date_Time_Selected__c) != lastScheduleItem.Flight_Begin_GMT__c) {

                    return Label.Start_date_cannot_be_in_past + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : '');
                }

                if (((config.Ad_Server_Item__c == true && (String.isBlank(config.Order_Line_ID__c) || config.Fulfilment_Item_Status__c == CS_const_SalesOrder.FulfilmentItemStatus_Draft))
                        || (config.Ad_Server_Item__c == false && config.Fulfilment_Item_Status__c == CS_const_SalesOrder.FulfilmentItemStatus_Draft))
                        && CS_utl_Datetime.getTimezoneOffset(config.Flight_End_Date_Time_Selected__c) < Datetime.now() &&
                        CS_utl_Datetime.getTimezoneOffset(config.Flight_End_Date_Time_Selected__c) != lastScheduleItem.Flight_End_GMT__c) {
                    return Label.End_date_cannot_be_in_past + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : '');
                }

                if (config.Net_Rate_Final__c != lastScheduleItem.Net_Rate__c && CS_utl_Datetime.getTimezoneOffset(config.Flight_Begin_Date_Time_Selected__c) < Datetime.now()) {
                    return Label.SO_Price_affecting_fields_change + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : '');
                }
                if (config.Billing_Source__c != lastScheduleItem.Billing_Source__c && CS_utl_Datetime.getTimezoneOffset(config.Flight_Begin_Date_Time_Selected__c) < Datetime.now()) {
                    return Label.SO_Billing_Source_change + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : '');
                }

                if ((config.X3rd_Party_Verification__c != lastScheduleItem.X3rd_Party_Verification__c
                        || config.X3rd_Party_Tracking__c != lastScheduleItem.X3rd_Party_Tracking__c
                        || config.X3rd_Party_Ad_Server__r.X3rd_Party_Ad_Server__c != lastScheduleItem.X3rd_Party_Ad_Server__c)
                        && CS_utl_Datetime.getTimezoneOffset(config.Flight_Begin_Date_Time_Selected__c) < Datetime.now()) {
                    return Label.SO_3rd_Party_fields_change + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : '');
                }

                CS_Custom_Settings__c customSettings = CS_Custom_Settings__c.getInstance();
                if (!String.isBlank(customSettings.Ignore_Quantity_Validation__c) && !customSettings.Ignore_Quantity_Validation__c.contains(CS_utl_User.userProfile)) {
                    if (config.Insertion_Quantity__c != lastScheduleItem.Contracted_Quantity__c) {
                        if (quantites.get('overwriteQuantity') > config.Scheduled_Quantity__c)
                            return Label.Quantity_lower_than_delivered + ((quantites.get('overwriteQuantity')).format() + ').' + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : ''));
                        else if (lastScheduleItem.Billing_Source__c == CS_const_SalesOrder.BillingSource_DFPActuals) {
                            if (quantites.get('dfpActuals') > config.Scheduled_Quantity__c)
                                return Label.Quantity_lower_than_delivered + ((quantites.get('dfpActuals')).format() + ').' + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : ''));
                        } else if (lastScheduleItem.Billing_Source__c == CS_const_SalesOrder.BillingSource_Megaphone) {
                            if (quantites.get('dfpActuals') > config.Scheduled_Quantity__c)
                                return Label.Quantity_lower_than_delivered + ((quantites.get('dfpActuals')).format() + ').' + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : ''));
                        } else if (lastScheduleItem.Billing_Source__c == CS_const_SalesOrder.BillingSource_3rdPartyActuals) {
                            if (quantites.get('totalBilledToDate') > config.Scheduled_Quantity__c)
                                return Label.Quantity_lower_than_delivered + ((quantites.get('thirdPartyActuals')).format() + ').' + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : ''));
                        } else if (lastScheduleItem.Billing_Source__c == CS_const_SalesOrder.BillingSource_Contracted) {
                            if (quantites.get('contractedActuals') > config.Scheduled_Quantity__c)
                                return Label.Quantity_lower_than_delivered + ((quantites.get('contractedActuals')).format() + ').' + (String.isNotBlank(lineId) ? ' Line Id: ' + lineId : ''));
                        }
                    }
                }
            }
        }

        return null;
    }

    /**
     * Generate Schedules based on Sales Orders and Product Configurations
     * @return Boolean
     */
    public Boolean generateSchedules() {
        List<SObject> allSchedules = new List<SObject>();

        autoCancelSchedules();

        for (Id salesOrderId : salesOrderIds) {
            if (productConfigurations.containsKey(salesOrderId)) {
                for (cscfga__Product_Configuration__c config : productConfigurations.get(salesOrderId)) {
                    if (config.Configuration_Status_Tmp__c == CS_const_SalesOrder.ProductConfigurationStatus_Valid && productConfigurationIds.contains(config.Id)) {
                        if (CS_utl_ProductConfiguration.isBillingScheduleRequired(config, billingSchedules.get(config.Id))) {
                            CS_Billing_Schedule__c parent = getBillingSchedule(config);
							
                            CS_ScheduleBase scheduleBase = new CS_BillingSchedule();
                            List<SObject> schedules = scheduleBase.createSchedules(config, parent, billingScheduleItems.get(config.Id));

                            allSchedules.addAll(
                                    addForUpsert(
                                            putScheduleItems(billingScheduleItems, schedules, config.Id, config.Billing_Schedule_Rule__r.Schedule_Object__c)
                                    )
                            );
                            addForDelete(billingScheduleItems.get(config.Id));

                            if (parent.get('Id') != null) {
                                parent.put('Under_IFC__c', false);
                                addForUpsert(new List<SObject>{
                                        parent
                                });
                            }
                        }

                        if (CS_utl_ProductConfiguration.isRevenueScheduleRequired(config, revenueSchedules.get(config.Id))) {
                            CS_Revenue_Schedule__c parent = getRevenueSchedule(config);

                            if (CS_utl_ProductConfiguration.isBillingScheduleRequired(config, billingSchedules.get(config.Id))) {
                                parent.Billing_Schedule__r = getBillingSchedule(config);
                            }

                            CS_ScheduleBase scheduleBase = new CS_RevenueSchedule();
                            List<SObject> schedules = scheduleBase.createSchedules(config, parent, revenueScheduleItems.get(config.Id));

                            allSchedules.addAll(
                                    addForUpsert(
                                            putScheduleItems(revenueScheduleItems, schedules, config.Id, config.Revenue_Schedule_Rule__r.Schedule_Object__c)
                                    )
                            );
                            addForDelete(revenueScheduleItems.get(config.Id));

                            if (parent.get('Id') != null) {
                                parent.put('Under_IFC__c', false);
                                addForUpsert(new List<SObject>{
                                        parent
                                });
                            }
                        }
                    }
                }

                doPropertyMapping(productConfigurations.get(salesOrderId));
            }
        }

        processSalesOrderSchedules(salesOrderIds);

        doDelete();
        doUpsert();

        return true;
    }

    /**
    * Updates schedules where "Valid for Auto-Cancellation" flag is set to True setting their statuses to 'Cancelled'
    */
    private void autoCancelSchedules() {
        for (Id salesOrderId : salesOrderIds) {
            if (productConfigurations.containsKey(salesOrderId)) {
                for (cscfga__Product_Configuration__c config : productConfigurations.get(salesOrderId)) {
                    if (config.Configuration_Status_Tmp__c == CS_const_SalesOrder.ProductConfigurationStatus_Valid && productConfigurationIds.contains(config.Id)) {
                        CS_Billing_Schedule_Item__c[] bsiItems = billingScheduleItems.get(config.Id);
                        if (bsiItems != null) {
                            if (CS_utl_ProductConfiguration.isBillingScheduleRequired(config, billingSchedules.get(config.Id))) {
                                CS_ScheduleBase scheduleBase = new CS_BillingSchedule();
                                addForUpsert(scheduleBase.autoCancelSchedules(config, bsiItems));
                            }
                        }
                        CS_Revenue_Schedule_Item__c[] rsiItems = revenueScheduleItems.get(config.id);
                        if (rsiItems != null) {
                            if (CS_utl_ProductConfiguration.isRevenueScheduleRequired(config, revenueSchedules.get(config.Id))) {
                                CS_ScheduleBase scheduleBase = new CS_RevenueSchedule();
                                addForUpsert(scheduleBase.autoCancelSchedules(config, rsiItems));
                            }
                        }
                    }
                }
            }
        }
        doUpsert();
        // clearing schedules cache;
        billingScheduleItems = null;
        revenueScheduleItems = null;
        billingSchedules = null;
        revenueSchedules = null;
    }

    /**
     * Update existing Schedules
     * @return Boolean
     */
    public Boolean updateSchedules() {
        for (Id salesOrderId : salesOrderIds) {
            if (productConfigurations.containsKey(salesOrderId)) {
                for (cscfga__Product_Configuration__c config : productConfigurations.get(salesOrderId)) {
                    if (productConfigurationIds.contains(config.Id)) {
                        if (!salesOrderSchedules.get(salesOrderId).Sales_Order_Billing_On_Hold__c &&
                                billingScheduleItems.get(config.Id) != null && !billingScheduleItems.get(config.Id).isEmpty()) {
                            CS_Billing_Schedule__c parent = getBillingSchedule(config);

                            if (parent.get('Pending_Forecast_Recalculation__c') == true) {
                                CS_ScheduleBase scheduleBase = new CS_BillingSchedule();
                                List<SObject> schedules = scheduleBase.updateSchedules(config, parent, billingScheduleItems.get(config.Id));
                                addForUpsert(schedules);

                                parent.put('Pending_Forecast_Recalculation__c', false);
                                addForUpsert(new List<SObject>{
                                        parent
                                });
                            }
                        }
                        if (!salesOrderSchedules.get(salesOrderId).Sales_Order_Revenue_On_Hold__c &&
                                revenueScheduleItems.get(config.Id) != null && !revenueScheduleItems.get(config.Id).isEmpty()) {
                            CS_Revenue_Schedule__c parent = getRevenueSchedule(config);

                            if (parent.get('Pending_Forecast_Recalculation__c') == true) {
                                CS_ScheduleBase scheduleBase = new CS_RevenueSchedule();
                                List<SObject> schedules = scheduleBase.updateSchedules(config, parent, revenueScheduleItems.get(config.Id));
                                addForUpsert(schedules);

                                parent.put('Pending_Forecast_Recalculation__c', false);
                                addForUpsert(new List<SObject>{
                                        parent
                                });
                            }
                        }
                    }
                }
            }
        }
        doUpsert();

        return true;
    }

    /**
     * Do Property Mapping for Schedules
     * @param configs List<cscfga__Product_Configuration__c>
     * @return        List<SObject>
     */
    @TestVisible
    private List<SObject> doPropertyMapping(List<cscfga__Product_Configuration__c> configs) {
        List<SObject> result = new List<SObject>();
        CS_Custom_Settings__c customSettings = CS_Custom_Settings__c.getInstance();

        List<PropertyMappingEngine.FieldMappingPair> salesOrderMappings = new List<PropertyMappingEngine.FieldMappingPair>();
        List<PropertyMappingEngine.FieldMappingPair> productConfigurationMappings = new List<PropertyMappingEngine.FieldMappingPair>();

        for (cscfga__Product_Configuration__c config : configs) {
            if (billingScheduleItems.containsKey(config.Id)) {
                List<SObject> scheduleItems = new List<SObject>();
                for (SObject billingScheduleItem : billingScheduleItems.get(config.Id)) {
                    if (!CS_utl_Schedule.isAutoReconciled(billingScheduleItem)) {
                        scheduleItems.add(billingScheduleItem);
                    }
                }
                salesOrderMappings.add(new PropertyMappingEngine.FieldMappingPair(config.Sales_Order__r, scheduleItems));
                productConfigurationMappings.add(new PropertyMappingEngine.FieldMappingPair(config, scheduleItems));
            }

            if (revenueScheduleItems.containsKey(config.Id)) {
                List<SObject> scheduleItems = new List<SObject>();
                for (SObject revenueScheduleItem : revenueScheduleItems.get(config.Id)) {
                    if (!CS_utl_Schedule.isAutoReconciled(revenueScheduleItem)) {
                        scheduleItems.add(revenueScheduleItem);
                    }
                }
                salesOrderMappings.add(new PropertyMappingEngine.FieldMappingPair(config.Sales_Order__r, scheduleItems));
                productConfigurationMappings.add(new PropertyMappingEngine.FieldMappingPair(config, scheduleItems));
            }
        }

        result.addAll(PropertyMappingEngine.mapsObjectFields(customSettings.SO_Billing_Rev_Schedule_Property_Map__c, salesOrderMappings));
        result.addAll(PropertyMappingEngine.mapsObjectFields(customSettings.SOLI_Billing_Rev_Schedule_Property_Map__c, productConfigurationMappings));

        return result;
    }

    /**
     * Process Sales Order Schedules to check if some need to be deleted
     * @param salesOrderIds Set<Id>
     * @return        		List<SObject>
     */
    @TestVisible
    private List<SObject> processSalesOrderSchedules(Set<Id> salesOrderIds) {
        List<SObject> result = new List<SObject>();
        for (CS_Sales_Order_Schedule__c salesOrderSchedule : salesOrderSchedules.values()) {
            if (!CS_utl_SalesOrder.areSchedulesApplicable(salesOrderSchedule.Sales_Order__r)) {
                addForDelete(new List<SObject>{
                        salesOrderSchedule
                });
                result.add(salesOrderSchedule);
            }
        }

        for (CS_Billing_Schedule__c billingSchedule : [
                SELECT Id
                FROM CS_Billing_Schedule__c
                WHERE Sales_Order__c = :salesOrderIds
                AND (Product_Configuration__c = null OR Last_Billing_Period_End__c = null)
        ]) {
            addForDelete(new List<SObject>{
                    billingSchedule
            });
            result.add(billingSchedule);
        }

        for (CS_Revenue_Schedule__c revenueSchedule : [
                SELECT Id
                FROM CS_Revenue_Schedule__c
                WHERE Sales_Order__c = :salesOrderIds
                AND (Product_Configuration__c = null OR Last_Revenue_Period_End__c = null)
        ]) {
            addForDelete(new List<SObject>{
                    revenueSchedule
            });
            result.add(revenueSchedule);
        }

        return result;
    }

    /**
     * Put Schedule Items into maps
     * @param schedulesMap Map<Id, List<SObject>>
     * @param schedules    List<SObject>
     * @param configId 	   Id
     * @param objectType   String
     * @return        	   List<SObject>
     */
    @TestVisible
    private List<SObject> putScheduleItems(Map<Id, List<SObject>> schedulesMap, List<SObject> schedules, Id configId, String objectType) {
        if (!schedulesMap.containsKey(configId)) {
            schedulesMap.put(configId, (List<SObject>) CS_utl_Array.getInstance(objectType));
        }

        schedulesMap.get(configId).addAll(schedules);
        return schedules;
    }

    /**
     * Gets a Sales Order Schedule record for Sales Order, either an existing one or creates a new one
     * @param salesOrderId Id
     * @return    		   CS_Sales_Order_Schedule__c
     */
    @TestVisible
    private CS_Sales_Order_Schedule__c getSalesOrderSchedule(Id salesOrderId) {
        if (!salesOrderSchedules.containsKey(salesOrderId)) {
            CS_Sales_Order_Schedule__c schedule = CS_utl_Schedule.createSalesOrderSchedule(salesOrderId);
            addForUpsert(new List<SObject>{
                    schedule
            });
            salesOrderSchedules.put(salesOrderId, schedule);
        }

        return salesOrderSchedules.get(salesOrderId);
    }

    /**
     * Gets a Billing Schedule record for Product Configuration, either an existing one or creates a new one
     * @param salesOrderId Id
     * @return    		   CS_Billing_Schedule__c
     */
    @TestVisible
    private CS_Billing_Schedule__c getBillingSchedule(cscfga__Product_Configuration__c productConfiguration) {
        if (!billingSchedules.containsKey(productConfiguration.Id)) {
            CS_Billing_Schedule__c schedule = CS_utl_Schedule.createBillingSchedule(productConfiguration.Sales_Order__c,
                    getSalesOrderSchedule(productConfiguration.Sales_Order__c),
                    productConfiguration);
            addForUpsert(new List<SObject>{
                    schedule
            });
            billingSchedules.put(productConfiguration.Id, schedule);
        }

        return billingSchedules.get(productConfiguration.Id);
    }

    /**
     * Gets a Revenue Schedule record for Product Configuration, either an existing one or creates a new one
     * @param salesOrderId Id
     * @return    		   CS_Revenue_Schedule__c
     */
    @TestVisible
    private CS_Revenue_Schedule__c getRevenueSchedule(cscfga__Product_Configuration__c productConfiguration) {
        if (!revenueSchedules.containsKey(productConfiguration.Id)) {
            CS_Revenue_Schedule__c schedule = CS_utl_Schedule.createRevenueSchedule(productConfiguration.Sales_Order__c,
                    getSalesOrderSchedule(productConfiguration.Sales_Order__c),
                    productConfiguration);
            addForUpsert(new List<SObject>{
                    schedule
            });
            revenueSchedules.put(productConfiguration.Id, schedule);
        }

        return revenueSchedules.get(productConfiguration.Id);
    }

    /**
     * Adds objects for delete using sObject name
     * @param objs 		  List<SObject>
     * @return    		  List<SObject>
     */
    @TestVisible
    public override List<SObject> addForDelete(List<SObject> objs) {
        List<SObject> toDelete = new List<Sobject>();

        if (objs != null) {
            for (SObject obj : objs) {
                if (CS_utl_Schedule.isDeletable(obj)) {
                    toDelete.add(obj);
                }
            }
        }

        return super.addForDelete(toDelete);
    }

    /**
     * Deletes Billing and Revenue Schedule Items
     * @param List<SObject> scheduleItems
     */
    @TestVisible
    public static void deleteScheduleItems(List<SObject> scheduleItems) {
        if(scheduleItems != null && !scheduleItems.isEmpty()) {
            delete scheduleItems;
        }
    }

    /**
     * Cancels Billing and Revenue Schedule Items
     * @param List<SObject> scheduleItems
     */
    @TestVisible
    public static void cancelScheduleItems(List<SObject> scheduleItems) {
        for (SObject scheduleItem : scheduleItems) {
            if (Boolean.valueOf(CS_utl_SObject.getFieldValue(scheduleItem, 'Valid_for_Auto_Cancellation__c'))) {
                scheduleItem.put('Status__c', CS_Constants.STATUS_CANCELLED);
                String status = CS_utl_SObject.getFieldValue(scheduleItem, 'Status__c');
                if(status == CS_const_BillingScheduleItem.Status_PendingClosure || status == CS_const_BillingScheduleItem.Status_Closed) {
                    scheduleItem.put('Cancelled_after_Closing__c', true);
                }
            }
        }

        update scheduleItems;
    }
}