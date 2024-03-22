global with sharing class CS_ReserveReleaseActionInvoker {

    global String performAction(String parameters) {

        ReserveReleaseRequest reserveReleaseRequestObject = (ReserveReleaseRequest) JSON.deserialize(parameters, ReserveReleaseRequest.class);
        if (reserveReleaseRequestObject.configurationIds == null
            || reserveReleaseRequestObject.configurationIds.isEmpty()){
            throw new CS_ReserveReleaseException('ReserveReleaseRequest object is invalid! Property configurationIds is not populated!');
        }

        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([
                SELECT Id, csdf__Fulfilment__c
                FROM csdf__Fulfilment_Item__c
                WHERE Product_Configuration__c IN :reserveReleaseRequestObject.configurationIds
        ]);

        if (fulfilmentItems.isEmpty() || fulfilmentItems.size() != reserveReleaseRequestObject.configurationIds.size()){
            throw new CS_ReserveReleaseException('Something went wrong! Some of selected line items doesn\'t have fulfilment items.' );
        }

        for (csdf__Fulfilment_Item__c fi : fulfilmentItems.values()) {
            fi.csdf__Pause_Resume_Message_Status__c = 'Waiting';
        }
        update fulfilmentItems.values();

        if (!Test.isRunningTest()){
            CS_FulfilmentWorker.prepareWork('Fulfilment Item Reserve Release', fulfilmentItems.values().get(0).csdf__Fulfilment__c, fulfilmentItems.keySet());
        }

        return JSON.serialize(reserveReleaseRequestObject);
    }

    public class ReserveReleaseRequest {
        // mandatory params
        public String action { get; set; }
        public List<Id> configurationIds { get; set; }
    }

    public class CS_ReserveReleaseException extends Exception {

    }
}