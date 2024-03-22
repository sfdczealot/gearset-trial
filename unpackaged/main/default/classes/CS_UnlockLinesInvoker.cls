/**
 * Created by tvrtko.matosevic on 10/06/2019.
 *
 * Bulkified version of UnlockLineController class, it is used for Unlocking line items through MLE
 */

global with sharing class CS_UnlockLinesInvoker  {
    global String performAction(String parameters) {
        System.debug('parameters => ' + parameters);

        List<Id> configIds = (List<Id>) JSON.deserialize(parameters, List<Id>.class);

        Map<Id, List<CS_Billing_Schedule_Item__c>> billingScheduleItemListByConfigIdMap = getBillingScheduleItemListByConfigIdMap(configIds);

        List<String> attNames = new List<String>{
                'Flight Begin Date Time Selected', 'Flight End Date Time Selected'
        };
        List<cscfga__Attribute__c> attributeList = [
                SELECT
                        Id, Name, cscfga__Value__c, cscfga__Product_Configuration__c
                FROM
                        cscfga__Attribute__c
                WHERE
                cscfga__Product_Configuration__c = :configIds AND Name IN :attNames
        ];

        Map<Id, Boolean> isFlightBeginAfterTodayByConfigIdMap = new Map<Id, Boolean>();
        Map<Id, Boolean> isFlightEndBeforeTodayByConfigIdMap = new Map<Id, Boolean>();
        Datetime dateTimeNow = Datetime.now();
        for (cscfga__Attribute__c attribute : attributeList) {
            Boolean startDateAfterToday;
            Boolean endDateBeforeToday;

            if (attribute.Name == 'Flight Begin Date Time Selected') {
                Datetime flightBeginDateTime;

                if (attribute.cscfga__Value__c.split(' ').size() > 2) {
                    flightBeginDateTime = CS_utl_Datetime.getTimezoneOffset(attribute.cscfga__Value__c);
                } else {
                    flightBeginDateTime = Datetime.valueOf(attribute.cscfga__Value__c + ':00');
                }

                if (flightBeginDateTime > dateTimeNow) {
                    startDateAfterToday = true;
                } else {
                    startDateAfterToday = false;
                }

                isFlightBeginAfterTodayByConfigIdMap.put(attribute.cscfga__Product_Configuration__c, startDateAfterToday);
            }

            if (attribute.Name == 'Flight End Date Time Selected') {
                Datetime flightEndDateTime;

                if (attribute.cscfga__Value__c.split(' ').size() > 2) {
                    flightEndDateTime = CS_utl_Datetime.getTimezoneOffset(attribute.cscfga__Value__c);
                } else {
                    flightEndDateTime = Datetime.valueOf(attribute.cscfga__Value__c + ':00');
                }

                if (flightEndDateTime.addDays(14) > dateTimeNow) {
                    endDateBeforeToday = false;
                } else {
                    endDateBeforeToday = true;
                }

                isFlightEndBeforeTodayByConfigIdMap.put(attribute.cscfga__Product_Configuration__c, endDateBeforeToday);
            }
        }

        Map<Id, String> productConfigurationFulfilmentStatusByConfigIdMap = getPCFulfilmentItemStatusByConfigIdMap(configIds);
        List<ProductConfigurationLockingStatus> pcLockingStatusList = getPCLockingStatusList(productConfigurationFulfilmentStatusByConfigIdMap,
                                                                                   isFlightBeginAfterTodayByConfigIdMap,
                                                                                   isFlightEndBeforeTodayByConfigIdMap,
                                                                                   billingScheduleItemListByConfigIdMap);

        return JSON.serialize(pcLockingStatusList);
    }

    Map<Id, List<CS_Billing_Schedule_Item__c>> getBillingScheduleItemListByConfigIdMap(List<Id> configIds){
        List<CS_Billing_Schedule_Item__c> billingScheduleItemList = [
                SELECT
                        Id, Name, Sales_Order__c, Product_Configuration__c, 
                        Status__c, Is_Open__c, Is_Closed__c, IsForecast__c
                FROM
                        CS_Billing_Schedule_Item__c
                WHERE
                        Product_Configuration__c = :configIds
        ];

        Map<Id, List<CS_Billing_Schedule_Item__c>> billingScheduleItemListByConfigIdMap = new Map<Id, List<CS_Billing_Schedule_Item__c>>();
        for (CS_Billing_Schedule_Item__c billingScheduleItem : billingScheduleItemList) {
            if (!billingScheduleItemListByConfigIdMap.containsKey(billingScheduleItem.Product_Configuration__c)) {
                billingScheduleItemListByConfigIdMap.put(billingScheduleItem.Product_Configuration__c, new List<CS_Billing_Schedule_Item__c>{
                        billingScheduleItem
                });
            } else {
                billingScheduleItemListByConfigIdMap.get(billingScheduleItem.Product_Configuration__c).add(billingScheduleItem);
            }
        }

        return billingScheduleItemListByConfigIdMap;
    }

    Map<Id, String> getPCFulfilmentItemStatusByConfigIdMap (List<Id> configIds) {
        List<cscfga__Product_Configuration__c> productConfigurations = [
                SELECT Id, Fulfilment_Item_Status__c
                FROM cscfga__Product_Configuration__c
                WHERE Id = :configIds
        ];
        Map<Id, String> productConfigurationFulfilmentStatusByConfigIdMap = new Map<Id, String>();
        for (cscfga__Product_Configuration__c pc : productConfigurations) {
            productConfigurationFulfilmentStatusByConfigIdMap.put(pc.Id, pc.Fulfilment_Item_Status__c);
        }

        return productConfigurationFulfilmentStatusByConfigIdMap;
    }

    List<ProductConfigurationLockingStatus> getPCLockingStatusList(Map<Id, String> productConfigurationFulfilmentStatusByConfigIdMap,
            Map<Id, Boolean> isFlightBeginAfterTodayByConfigIdMap,
            Map<Id, Boolean> isFlightEndBeforeTodayByConfigIdMap,
            Map<Id, List<CS_Billing_Schedule_Item__c>> billingScheduleItemListByConfigIdMap) {

        List<ProductConfigurationLockingStatus> pcLockingStatusList = new List<ProductConfigurationLockingStatus>();
        List<Id> configIdsToUpdateSchedules = new List<Id>();
        for (Id configId : productConfigurationFulfilmentStatusByConfigIdMap.keySet()) {
            Boolean hasAllLinesClosed = true;
            Boolean hasAllLinesOpen = true;
            Boolean hasOpenBillSch = false;
            Boolean lockedForReconciliation = false;

            // process related Billing Schedules
            if (!billingScheduleItemListByConfigIdMap.isEmpty()){
                for (CS_Billing_Schedule_Item__c currentBillSchedule : billingScheduleItemListByConfigIdMap.get(configId)) {
                    if (currentBillSchedule.Is_Open__c) {
                        hasOpenBillSch = true;
                        hasAllLinesClosed = false;
                    }
                    if (currentBillSchedule.Is_Closed__c) {
                        hasAllLinesOpen = false;
                    }
                    if (currentBillSchedule.IsForecast__c) {
                        hasAllLinesOpen = false;
                    }

                    if (currentBillSchedule.Status__c == 'Pending' || currentBillSchedule.Status__c == 'Ready') {
                        lockedForReconciliation = true;
                    }
                }
            }

            // FI status
            Boolean isActiveLine = productConfigurationFulfilmentStatusByConfigIdMap.get(configId) != CS_const_SalesOrder.FulfilmentItemStatus_Draft
                    && productConfigurationFulfilmentStatusByConfigIdMap.get(configId) != CS_const_SalesOrder.FulfilmentItemStatus_Inactive
                    && productConfigurationFulfilmentStatusByConfigIdMap.get(configId) != CS_const_SalesOrder.FulfilmentItemStatus_Ready;

            // final status check
            String finalStatus = 'Locked';
            if ((isFlightEndBeforeTodayByConfigIdMap.get(configId) && isActiveLine)) {
                finalStatus = 'Locked';
            }
            // Partially Locked - Line is partially Invoiced & End date is in the future and Line is not locked for reconciliation
            if ((!isFlightEndBeforeTodayByConfigIdMap.get(configId) || !isActiveLine)) {
                finalStatus = 'Partially Locked';
            }
            // Unlocked - Line is NOT Invoiced & End date is in the future and Line is not locked for reconciliation
            if (hasAllLinesOpen && isFlightBeginAfterTodayByConfigIdMap.get(configId) && (!isFlightEndBeforeTodayByConfigIdMap.get(configId) || !isActiveLine) && !lockedForReconciliation) {
                finalStatus = 'Unlocked';
            }

            // IF Sales Order Line is Partially Locked or Unlocked ALL related Billing Schedule and Rev Rec Schedule with Status = Open is set On Hold for IFC
            if (finalStatus == 'Unlocked' || finalStatus == 'Partially Locked') {
                configIdsToUpdateSchedules .add(configId);
            }

            System.debug('#### Unlock Controller / hasAllLinesClosed - ' + hasAllLinesClosed + ' / lockedForReconciliation - ' + lockedForReconciliation);
            System.debug('#### Unlock Controller / hasOpenBillSch - ' + hasOpenBillSch + ' / endDateBeforeToday - ' + isFlightEndBeforeTodayByConfigIdMap.get(configId));
            System.debug('#### Unlock Controller / hasAllLinesOpen - ' + hasAllLinesOpen + ' / startDateAfterToday - ' + isFlightBeginAfterTodayByConfigIdMap.get(configId));
            System.debug('#### Unlock Controller / finalStatus - ' + finalStatus);

            pcLockingStatusList.add(new ProductConfigurationLockingStatus(configId, finalStatus));
        }

        if (!configIdsToUpdateSchedules .isEmpty()) {
            updateSchedules(configIdsToUpdateSchedules);
        }

        return pcLockingStatusList;
    }

    public static void updateSchedules(List<Id> configIds) {
        List<CS_Revenue_Schedule__c> revRecScheduleList = [
                SELECT
                        Id, Name, Under_IFC__c
                FROM
                        CS_Revenue_Schedule__c
                WHERE
                        Product_Configuration__c IN :configIds
        ];

        // NEW - We only need to update the billing schedule Headers here.
        // CPS 30/10/2018
        List<CS_Billing_Schedule__c> billingScheduleList = [
                SELECT
                        Id, Name, Under_IFC__c
                FROM
                        CS_Billing_Schedule__c
                WHERE
                        Product_Configuration__c IN :configIds
        ];

        List<CS_Revenue_Schedule__c> revRecSchedulesUpdate = new List<CS_Revenue_Schedule__c>();
        for (CS_Revenue_Schedule__c currentRevRecSch : revRecScheduleList) {
            if (currentRevRecSch.Under_IFC__c == false) {
                currentRevRecSch.Under_IFC__c = true;
                revRecSchedulesUpdate.add(currentRevRecSch);
            }
        }

        if (!revRecSchedulesUpdate.isEmpty()) {
            update revRecSchedulesUpdate;
        }


        // CPS 30/10/18 - We just need to update the Billing Schedule Headers here, not each item.
        List<CS_Billing_Schedule__c> billSchedulesUpdate = new List<CS_Billing_Schedule__c>();
        for (CS_Billing_Schedule__c currentBillSch : billingScheduleList) {
            if (currentBillSch.Under_IFC__c == false) {
                currentBillSch.Under_IFC__c = true;
                billSchedulesUpdate.add(currentBillSch);
            }
        }

        if (!billSchedulesUpdate.isEmpty()) {
            update billSchedulesUpdate;
        }
    }

    public class ProductConfigurationLockingStatus {
        public Id Id;
        public String LockingStatus;

        public ProductConfigurationLockingStatus(Id id, String lockingStatus){
            this.Id = id;
            this.LockingStatus = lockingStatus;
        }
    }
}