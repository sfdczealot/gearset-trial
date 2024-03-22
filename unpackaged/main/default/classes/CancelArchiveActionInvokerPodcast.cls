global with sharing class CancelArchiveActionInvokerPodcast implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    global String performAction(String parameters) {
        system.debug('## in CancelArchiveActionInvokerPodcast ');
        Id fulfilmentItemId = (Id)JSON.deserialize(parameters, Id.class);
        csdf__Fulfilment_Item__c fulfilmentItem = [SELECT Served_By__c, Product_Configuration__c 
                                                   FROM csdf__Fulfilment_Item__c 
                                                   WHERE Id =:fulfilmentItemId];
        if (fulfilmentItem.Served_By__c == 'DFP') {
            csam.ObjectGraphCalloutHandler.createAndSend('Fulfilment Item Archive', fulfilmentItemId);
        }
        else {
            // Update BSI status
            List<CS_Billing_Schedule_Item__c> billingScheduleListToUpdate = new List<CS_Billing_Schedule_Item__c>();
            for (CS_Billing_Schedule_Item__c currentBSI : [SELECT Id, Status__c
                                                           FROM CS_Billing_Schedule_Item__c
                                                           WHERE Product_Configuration__c = :fulfilmentItem.Product_Configuration__c
                                                                 AND Valid_for_Auto_Cancellation__c = true]) {
                currentBSI.Status__c = CS_const_SalesOrder.ScheduleStatus_Cancelled;
                billingScheduleListToUpdate.add(currentBSI);
            }
            if (!billingScheduleListToUpdate.isEmpty()) {
                UPDATE billingScheduleListToUpdate;    
            }

            // Update RSI status
            List<CS_Revenue_Schedule_Item__c> revenueScheduleListToUpdate = new List<CS_Revenue_Schedule_Item__c>();
            for (CS_Revenue_Schedule_Item__c currentRSI : [SELECT Id, Status__c
                                                           FROM CS_Revenue_Schedule_Item__c
                                                           WHERE Product_Configuration__c = :fulfilmentItem.Product_Configuration__c
                                                                 AND Valid_for_Auto_Cancellation__c = true]) {
                currentRSI.Status__c = CS_const_SalesOrder.ScheduleStatus_Cancelled;
                revenueScheduleListToUpdate.add(currentRSI);
            }
            if (!revenueScheduleListToUpdate.isEmpty()) {
                UPDATE revenueScheduleListToUpdate;    
            }

            // Update FI status
            List<csdf__Fulfilment_Item__c> fiListToUpdate = new List<csdf__Fulfilment_Item__c>();
            for (csdf__Fulfilment_Item__c currentFI : [SELECT id, csdf__Status__c 
                                                       FROM csdf__Fulfilment_Item__c 
                                                       WHERE Product_Configuration__c = :fulfilmentItem.Product_Configuration__c
                                                             AND csdf__Status__c != :CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased]) {
                currentFI.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased;
                currentFI.csdf__Cancel_Message_Status__c = 'Completed';
                fiListToUpdate.add(currentFI);
            }
            if (!fiListToUpdate.isEmpty()) {
                UPDATE fiListToUpdate;    
            }

            update new cscfga__Product_Configuration__c(Id = fulfilmentItem.Product_Configuration__c, 
                                                        Fulfilment_Item_Status__c = CS_Constants.STATUS_PAUSED_INVENTORY_RELEASED);
        }

        return JSON.serialize(fulfilmentItemId);
    }
}