global with sharing class ArchiveNonServedLineController implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    global String performAction(String parameters) {
    	if (String.isEmpty(parameters)){
    		return JSON.serialize('error');
    	}
        
        // update BSI status 
        List<CS_Billing_Schedule_Item__c> billingSchedulesToUpdate = new List<CS_Billing_Schedule_Item__c>();
        for (CS_Billing_Schedule_Item__c currentBSI : [SELECT Id, Status__c
                                                       FROM CS_Billing_Schedule_Item__c
                                                       WHERE Product_Configuration__c = :parameters
                                                             AND Valid_for_Auto_Cancellation__c = true]) {
	        currentBSI.Status__c = CS_const_SalesOrder.ScheduleStatus_Cancelled;
            billingSchedulesToUpdate.add(currentBSI);
	    }
	    if (billingSchedulesToUpdate.size() > 0) {
	    	UPDATE billingSchedulesToUpdate;
	    }

	    // update RSI status 
        List<CS_Revenue_Schedule_Item__c> revenueSchedulesToUpdate = new List<CS_Revenue_Schedule_Item__c>();
        for (CS_Revenue_Schedule_Item__c currentRSI : [SELECT Id, Status__c
                                                       FROM CS_Revenue_Schedule_Item__c
                                                       WHERE Product_Configuration__c = :parameters
                                                             AND Valid_for_Auto_Cancellation__c = true]) {
	        currentRSI.Status__c = CS_const_SalesOrder.ScheduleStatus_Cancelled;
            revenueSchedulesToUpdate.add(currentRSI);
	    }
	    if (revenueSchedulesToUpdate.size() > 0) {
	    	UPDATE revenueSchedulesToUpdate;
	    }

        // update FI status 
        List<csdf__Fulfilment_Item__c> fulfilmentItemsToUpdate = new List<csdf__Fulfilment_Item__c>();
        for (csdf__Fulfilment_Item__c currentFI : [SELECT id, csdf__Status__c 
                                                   FROM csdf__Fulfilment_Item__c 
                                                   WHERE Product_Configuration__c=:parameters 
                                                         AND csdf__Status__c != :CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased]) {
	        currentFI.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased;
            fulfilmentItemsToUpdate.add(currentFI);
	    }
	    if (fulfilmentItemsToUpdate.size() > 0) {
	    	UPDATE fulfilmentItemsToUpdate;
	    }

    	return JSON.serialize('Success');
    }
}