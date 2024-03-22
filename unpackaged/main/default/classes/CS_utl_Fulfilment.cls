public class CS_utl_Fulfilment {
    public static final Set<String> incompleteStatuses = new Set<String> {
        'Waiting', 'Executing', 'Pending', 'Waiting For Response', 'Received'
    };
    
    public static Map<String, csam__ObjectGraph_Callout_Handler__c> calloutHandlers {
        get {
            if(calloutHandlers == null) {
                calloutHandlers = new Map<String, csam__ObjectGraph_Callout_Handler__c>();
                for(csam__ObjectGraph_Callout_Handler__c handler : [SELECT Id, Name, csam__Status_Field__c
                                                                       FROM csam__ObjectGraph_Callout_Handler__c]) {
                    calloutHandlers.put(handler.Name, handler);
                }
            }
            return calloutHandlers;
        }
        set;
    }
    
    public static String getStatus(String messageType, csdf__Fulfilment_Item__c fulfilmentItem) {
        String statusField = calloutHandlers.get(messageType).csam__Status_Field__c;
        return String.valueOf(fulfilmentItem.get(statusField));
    }
    
    public static void setStatus(String messageType, csdf__Fulfilment_Item__c fulfilmentItem, string newStatusValueStr) {
        String statusField = calloutHandlers.get(messageType).csam__Status_Field__c;
        fulfilmentItem.put(statusField, newStatusValueStr);
    }

    public static Boolean isCalloutCompleted(String messageType, List<csdf__Fulfilment_Item__c> fulfilmentItems) {
        Boolean isCompleted = true;
        
        String statusField = calloutHandlers.get(messageType).csam__Status_Field__c;
        if(fulfilmentItems != null) {
            for(csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems) {
                if(fulfilmentItem.Served_By__c == 'DFP' &&
                   (incompleteStatuses.contains(String.valueOf(fulfilmentItem.get(statusField))) ||
                   (String.isNotBlank(fulfilmentItem.Queued_Action__c) && fulfilmentItem.Queued_Action__c != messageType))) {
                    isCompleted = false;
                }
            }
        }
        
        return isCompleted;
    }
    
    public static Map<Id, List<csdf__Fulfilment_Item__c>> getFulfilmentItems(Set<Id> fulfilmentIds) {
        Map<Id, List<csdf__Fulfilment_Item__c>> fulfilmentItemsByFulfilment = new Map<Id, List<csdf__Fulfilment_Item__c>>();
        for(Id fulfilmentId : fulfilmentIds) {
            fulfilmentItemsByFulfilment.put(fulfilmentId, new List<csdf__Fulfilment_Item__c>());
        }
        
        if(!fulfilmentIds.isEmpty()) {
            List<csdf__Fulfilment_Item__c> allFulfilmentItems = [SELECT Id, Name, csdf__Availability_Check_Status__c, csdf__Cancel_Message_Status__c,
                                                                        csdf__Fulfilment_Message_Status__c, csdf__Pause_Resume_Message_Status__c,
                                                                        csdf__Performance_Gathering_Status__c, csdf__Status_Update_Message_Status__c,
                                                                        csdf__Status__c, csdf__Fulfilment__c, csdf__Fulfilment__r.Message_Type__c, Inventory_Available__c,
                                                                        Sales_Order__c, csdf__Ad_Server_Id__c, Product_Configuration__c, Reservation_Status__c, Product_Configuration__r.Overbook__c,
                                                                        Served_By__c, Product_Configuration__r.Reserve_Inventory__c, Product_Configuration__r.Line_ID__c, Product_Configuration__r.Ad_Server_Inventory_Available__c,
                                                                        Queued_Action__c, Is_Archived__c, Product_Configuration__r.Fulfilment_Item_Status__c
                                                                 FROM csdf__Fulfilment_Item__c
                                                                 WHERE csdf__Fulfilment__c = :fulfilmentIds];
            for(csdf__Fulfilment_Item__c fulfilmentItem : allFulfilmentItems) {
                fulfilmentItemsByFulfilment.get(fulfilmentItem.csdf__Fulfilment__c).add(fulfilmentItem);
            }
        }
        
        return fulfilmentItemsByFulfilment;
    }

    /**
	 * Set Fulfilment Item Status to 'Paused Inventory Released'
	 * @param List<csdf__Fulfilment_Item__c> fulfilmentItems
	 */
    public static void setFulfilmentItemsToPausedInventoryReleased(List<csdf__Fulfilment_Item__c> fulfilmentItems){
        for(csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems) {
            fulfilmentItem.csdf__Status__c = CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased; 
            if(fulfilmentItem.Served_By__c != null && fulfilmentItem.Served_By__c != 'DFP')
                fulfilmentItem.Status_Manual_Tracking__c = CS_const_SalesOrder.FulfilmentItemManualTrackingStatus_Cancelled;
        }

        update fulfilmentItems;
    }
}