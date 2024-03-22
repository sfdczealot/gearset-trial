public class CS_FulfilmentUpdateWorker extends CS_QueueableWorker implements Database.AllowsCallouts {
	public CS_FulfilmentUpdateWorker(Object params) {
		super('CS_FulfilmentUpdateWorker', params);
	}
	
	public override void doWork() {
		Map<String, Object> paramsType = (Map<String, Object>) this.params;
		List<csdf__Fulfilment_Item__c> fulfilmentItems = (List<csdf__Fulfilment_Item__c>) paramsType.get('fulfilmentItems');
		Map<Id, csmso__Sales_Order__c> salesOrders = new Map<Id, csmso__Sales_Order__c>((List<csmso__Sales_Order__c>) paramsType.get('salesOrders'));
		Map<Id, csdf__Fulfilment__c> fulfilments = new Map<Id, csdf__Fulfilment__c>((List<csdf__Fulfilment__c>) paramsType.get('fulfilments'));
		
		try {
			CS_DMLWorker dmlWorker = new CS_DMLWorker();
			dmlWorker.addForUpsert(fulfilmentItems);
			dmlWorker.doUpsert();
			
			Map<Id, List<csdf__Fulfilment_Item__c>> allFulfilmentItems = CS_utl_Fulfilment.getFulfilmentItems(fulfilments.keySet());					 
			List<csdf__Fulfilment__c> fulfilmentToUpdate = new List<csdf__Fulfilment__c>();
			List<csmso__Sales_Order__c> salesOrderToUpdate = new List<csmso__Sales_Order__c>();
			
			for(csdf__Fulfilment__c fulfilment : fulfilments.values()) {
				fulfilmentToUpdate.add(fulfilment);
				if(salesOrders.containsKey(fulfilment.Sales_Order__c)) salesOrderToUpdate.add(salesOrders.get(fulfilment.Sales_Order__c));
			}
			
			update fulfilmentToUpdate;
			update salesOrderToUpdate;
		}
		catch (Exception e) {
			CS_LogWorker log = CS_LogWorker.getInstance(); 
            
            if(salesOrders != null) {
                List<csmso__Sales_Order__c> soToUpdate = new List<csmso__Sales_Order__c>();
                for(Id salesOrderId : salesOrders.keySet()) {
                	log.addMessage(salesOrderId, e.getMessage(), e.getTypeName(), 'CS_FulfilmentUpdateWorker', e.getStackTraceString());
                    if(String.isNotBlank(salesOrderId)) {
                        csmso__Sales_Order__c so = new csmso__Sales_Order__c(
                            Id = salesOrderId,
                            Callout_Type__c = null,
                            csmso__Process_Message_Type__c = 'error',
                            Error_Message__c = 'Unknown Error - Contact your System Administrator',
                            csmso__Process_Message__c = 'Unknown Error - Contact your System Administrator',
                            Loading_Screen__c = 'Off'
                        );
                        
                        soToUpdate.add(so);
                    }
                }
                
                if(!soToUpdate.isEmpty()) {
                    update soToUpdate;
                    log.save('CS_FulfilmentUpdateWorker', 'Queueable', null, false);
                }
            }
        }
	}
	
	public static void prepareWork(List<csdf__Fulfilment_Item__c> fulfilmentItems, List<csdf__Fulfilment__c> fulfilments, List<csmso__Sales_Order__c> salesOrders) {
		CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
		
		Map<Id, csmso__Sales_Order__c> salesOrdersMap = new Map<Id, csmso__Sales_Order__c>(salesOrders);
		Map<Id, csdf__Fulfilment__c> fulfilmentsMap = new Map<Id, csdf__Fulfilment__c>(fulfilments);
		Map<Id, List<csdf__Fulfilment_Item__c>> fulfilmentItemsByFulfilment = new Map<Id, List<csdf__Fulfilment_Item__c>>();	
		for(csdf__Fulfilment_Item__c fi : fulfilmentItems) {
			if(!fulfilmentItemsByFulfilment.containsKey(fi.csdf__Fulfilment__c)) {
				fulfilmentItemsByFulfilment.put(fi.csdf__Fulfilment__c, new List<csdf__Fulfilment_Item__c>());
			}
			fulfilmentItemsByFulfilment.get(fi.csdf__Fulfilment__c).add(fi);
		}
		
		for(Id fulfilmentId : fulfilmentItemsByFulfilment.keySet()) {
			List<csdf__Fulfilment_Item__c> currentFulfilmentItems = fulfilmentItemsByFulfilment.get(fulfilmentId);
			List<csdf__Fulfilment__c> currentFulfilment = new List<csdf__Fulfilment__c>();
			List<csmso__Sales_Order__c> currentSalesOrder = new List<csmso__Sales_Order__c>();
			if(fulfilmentsMap.containsKey(fulfilmentId)) {
				currentFulfilment.add(fulfilmentsMap.get(fulfilmentId));
				if(salesOrdersMap.containsKey(fulfilmentsMap.get(fulfilmentId).Sales_Order__c)) {
					currentSalesOrder.add(salesOrdersMap.get(fulfilmentsMap.get(fulfilmentId).Sales_Order__c));
				}
			}
			
			dispatcher.addWorker(new CS_FulfilmentUpdateWorker(new Map<String, Object> {
				'fulfilmentItems' => currentFulfilmentItems,
				'salesOrders' => currentSalesOrder,
				'fulfilments' => currentFulfilment
			}));
		}
		
		dispatcher.dispatch();
	}
}