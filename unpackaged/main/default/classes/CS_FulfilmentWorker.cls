public class CS_FulfilmentWorker extends CS_QueueableWorker implements Database.AllowsCallouts {
	public static final String PushHandler = 'Fulfilment Item Push';
	
	public CS_FulfilmentWorker(Object params) {
		super('CS_FulfilmentWorker', params);
	}
	
	public override void doWork() {
		Map<String, Object> paramsType = (Map<String, Object>) this.params;
        String handlerType = (String)paramsType.get('handlerType');
        Long spinWaitBeforeCallout_ms = (Long)paramsType.get('spinWaitBeforeCallout_ms');
        if (spinWaitBeforeCallout_ms > 0) {
            CS_Util.spinWait(spinWaitBeforeCallout_ms);
        }
		csam.ObjectGraphCalloutHandler.createAndSendFromIds(handlerType, 
                                                            (List<Id>)paramsType.get('fulfilmentItemIds'));
	}
	
	public static void prepareWork(String handlerType, Id fulfilmentId, Set<Id> fulfilmentItems) {
        prepareWork(handlerType, fulfilmentId, fulfilmentItems, 
                    CS_Custom_Settings__c.getInstance().Integration_Chunk_Size__c.intValue(), 
                    CS_Custom_Settings__c.getInstance().Integration_Delay_Between_Callouts__c.longValue());
    }

	public static void prepareWork(String handlerType, Id fulfilmentId, Set<Id> fulfilmentItems, Integer chunkSize, Long spinWaitBeforeCallout_ms) {
		CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
		List<Id> fulfilmentItemIds = new List<Id>(fulfilmentItems);
		Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsMap = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Queued_Action__c FROM csdf__Fulfilment_Item__c
                                                                                                    WHERE Id =:fulfilmentItems]);
		List<Id> currentFulfilmentItemIds = new List<Id>();
		List<csdf__Fulfilment_Item__c> fulfilmentItemListToUpdate = new List<csdf__Fulfilment_Item__c>();
		Integer currentFulfilmentSize = fulfilmentItemIds.size();
		for(Integer i = 0; i < chunkSize && i < currentFulfilmentSize; i++) {
            Id fulfilmentItemId = fulfilmentItemIds.remove(0);
			currentFulfilmentItemIds.add(fulfilmentItemId);
			if(handlerType == fulfilmentItemsMap.get(fulfilmentItemId).Queued_Action__c){
				fulfilmentItemListToUpdate.add(new csdf__Fulfilment_Item__c(Id = fulfilmentItemId, Queued_Action__c = null));
			}
		}
		
		if(!fulfilmentItemListToUpdate.isEmpty()) {
			UPDATE fulfilmentItemListToUpdate;
		}
		
		dispatcher.addWorker(new CS_FulfilmentWorker(new Map<String, Object> {
			'handlerType' => handlerType,
			'fulfilmentItemIds' => currentFulfilmentItemIds,
            'spinWaitBeforeCallout_ms' => spinWaitBeforeCallout_ms
		}));
		
		dispatcher.dispatch();
	}
}