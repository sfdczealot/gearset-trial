public class CS_FulfilmentWorkerStatusPush extends CS_QueueableWorker implements Database.AllowsCallouts {
	
	public CS_FulfilmentWorkerStatusPush(Object params) {
		super('CS_FulfilmentWorkerStatusPush', params);
	}
	
	public override void doWork() {
		Map<String, Object> paramsType = (Map<String, Object>) this.params;
        String handlerType = (String)paramsType.get('handlerType');
        Long spinWaitBeforeCallout_ms = (Long)paramsType.get('spinWaitBeforeCallout_ms');
        if (spinWaitBeforeCallout_ms > 0) {
            CS_Util.spinWait(spinWaitBeforeCallout_ms);
        }
		csam.ObjectGraphCalloutHandler.createAndSendFromIds(handlerType, 
                                                            (List<Id>)paramsType.get('fulfilmentIds'));
	}
	
	public static void prepareWork(String handlerType, Set<Id> fulfilments) {
        prepareWork(handlerType, fulfilments, 
                    CS_Custom_Settings__c.getInstance().Integration_Chunk_Size__c.intValue(), 
                    CS_Custom_Settings__c.getInstance().Integration_Delay_Between_Callouts__c.longValue());
    }

	public static void prepareWork(String handlerType, Set<Id> fulfilments, Integer chunkSize, Long spinWaitBeforeCallout_ms) {
		CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
		List<Id> fulfilmentIds = new List<Id>(fulfilments);
                
		List<Id> currentFulfilmentIds = new List<Id>();
		List<csdf__Fulfilment__c> fulfilmentListToUpdate = new List<csdf__Fulfilment__c>();
		Integer currentFulfilmentSize = fulfilmentIds.size();
		for(Integer i = 0; i < chunkSize && i < currentFulfilmentSize; i++) {
            Id fulfilmentId = fulfilmentIds.remove(0);
			currentFulfilmentIds.add(fulfilmentId);
			fulfilmentListToUpdate.add(new csdf__Fulfilment__c(Id = fulfilmentId));
		}
			
		if(!fulfilmentListToUpdate.isEmpty()) {
			UPDATE fulfilmentListToUpdate;
		}
		
		dispatcher.addWorker(new CS_FulfilmentWorkerStatusPush(new Map<String, Object> {
			'handlerType' => handlerType,
			'fulfilmentIds' => currentFulfilmentIds,
            'spinWaitBeforeCallout_ms' => spinWaitBeforeCallout_ms
		}));
		
		dispatcher.dispatch();
	}
}