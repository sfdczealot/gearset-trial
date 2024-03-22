/**
 * Created by ivan.ravnjak on 29.4.2020..
 */

global with sharing class CS_ArchiveActionInvoker {

    global String performAction(String parameters) {

        ArchiveRequest ArchiveRequestObject = (ArchiveRequest) JSON.deserialize(parameters, ArchiveRequest.class);
        if (ArchiveRequestObject.configurationIds == null
                || ArchiveRequestObject.configurationIds.isEmpty()) {
            throw new CS_ArchiveException('ArchiveRequest object is invalid! Property configurationIds is not populated!');
        }

        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([
                SELECT Id, csdf__Fulfilment__c, Served_By__c, Product_Configuration__c
                FROM csdf__Fulfilment_Item__c
                WHERE Product_Configuration__c IN :ArchiveRequestObject.configurationIds
        ]);

        if (fulfilmentItems.isEmpty() || fulfilmentItems.size() != ArchiveRequestObject.configurationIds.size()) {
            throw new CS_ArchiveException('Something went wrong! Some of selected line items doesn\'t have fulfilment items.');
        }

        Map<Id, csdf__Fulfilment_Item__c> dfpServedFulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>();
        Map<Id, csdf__Fulfilment_Item__c> nonDfpServedFulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>();
        for (csdf__Fulfilment_Item__c fi : fulfilmentItems.values()) {
            if (fi.Served_By__c == 'DFP') {
                dfpServedFulfilmentItems.put(fi.Id, fi);
            } else {
                nonDfpServedFulfilmentItems.put(fi.Id, fi);
            }
        }

        if (!dfpServedFulfilmentItems.isEmpty()) {
            for (csdf__Fulfilment_Item__c fi : dfpServedFulfilmentItems.values()) {
                fi.csdf__Cancel_Message_Status__c = 'Waiting';
            }
            update dfpServedFulfilmentItems.values();


            if (!Test.isRunningTest()) {
                CS_FulfilmentWorker.prepareWork('Fulfilment Item Archive', dfpServedFulfilmentItems.values().get(0).csdf__Fulfilment__c, dfpServedFulfilmentItems.keySet());
            }
        }

        if (!nonDfpServedFulfilmentItems.isEmpty()) {
            List<CS_Billing_Schedule_Item__c> billingScheduleListToUpdate = new List<CS_Billing_Schedule_Item__c>();
            List<CS_Revenue_Schedule_Item__c> revenueScheduleListToUpdate = new List<CS_Revenue_Schedule_Item__c>();
            List<csdf__Fulfilment_Item__c> fiListToUpdate = new List<csdf__Fulfilment_Item__c>();

            for (csdf__Fulfilment_Item__c fulfilmentItem : nonDfpServedFulfilmentItems.values()) {
                // Update BSI status
                for (CS_Billing_Schedule_Item__c currentBSI : [
                        SELECT Id, Status__c
                        FROM CS_Billing_Schedule_Item__c
                        WHERE Product_Configuration__c = :fulfilmentItem.Product_Configuration__c
                        AND Valid_for_Auto_Cancellation__c = true
                ]) {
                    currentBSI.Status__c = CS_const_SalesOrder.ScheduleStatus_Cancelled;
                    billingScheduleListToUpdate.add(currentBSI);
                }

                // Update RSI status
                for (CS_Revenue_Schedule_Item__c currentRSI : [
                        SELECT Id, Status__c
                        FROM CS_Revenue_Schedule_Item__c
                        WHERE Product_Configuration__c = :fulfilmentItem.Product_Configuration__c
                        AND Valid_for_Auto_Cancellation__c = true
                ]) {
                    currentRSI.Status__c = CS_const_SalesOrder.ScheduleStatus_Cancelled;
                    revenueScheduleListToUpdate.add(currentRSI);
                }

                // Update FI status
                for (csdf__Fulfilment_Item__c currentFI : [
                        SELECT id, csdf__Status__c
                        FROM csdf__Fulfilment_Item__c
                        WHERE Product_Configuration__c = :fulfilmentItem.Product_Configuration__c
                        AND csdf__Status__c != :CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased
                ]) {
                    currentFI.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased;
                    currentFI.csdf__Cancel_Message_Status__c = 'Completed';
                    fiListToUpdate.add(currentFI);
                }


                update new cscfga__Product_Configuration__c(Id = fulfilmentItem.Product_Configuration__c,
                        Fulfilment_Item_Status__c = CS_Constants.STATUS_PAUSED_INVENTORY_RELEASED);
            }

            if (!billingScheduleListToUpdate.isEmpty()) {
                UPDATE billingScheduleListToUpdate;
            }
            if (!revenueScheduleListToUpdate.isEmpty()) {
                UPDATE revenueScheduleListToUpdate;
            }
            if (!fiListToUpdate.isEmpty()) {
                UPDATE fiListToUpdate;
            }
        }

        return JSON.serialize(ArchiveRequestObject);
    }

    public class ArchiveRequest {
        // mandatory params
        public String action { get; set; }
        public List<Id> configurationIds { get; set; }
    }

    public class CS_ArchiveException extends Exception {

    }
}