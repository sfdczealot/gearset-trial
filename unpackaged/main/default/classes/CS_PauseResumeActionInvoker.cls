/**
 * Created by ivan.ravnjak on 29.4.2020..
 */

global with sharing class CS_PauseResumeActionInvoker  {

    global String performAction(String parameters) {

        PauseResumeRequest PauseResumeRequestObject = (PauseResumeRequest) JSON.deserialize(parameters, PauseResumeRequest.class);
        if (PauseResumeRequestObject.configurationIds == null
                || PauseResumeRequestObject.configurationIds.isEmpty()){
            throw new CS_PauseResumeException('PauseResumeRequest object is invalid! Property configurationIds is not populated!');
        }

        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([
                SELECT Id, csdf__Fulfilment__c
                FROM csdf__Fulfilment_Item__c
                WHERE Product_Configuration__c IN :PauseResumeRequestObject.configurationIds
        ]);

        if (fulfilmentItems.isEmpty() || fulfilmentItems.size() != PauseResumeRequestObject.configurationIds.size()){
            throw new CS_PauseResumeException('Something went wrong! Some of selected line items doesn\'t have fulfilment items.' );
        }

        for (csdf__Fulfilment_Item__c fi : fulfilmentItems.values()) {
            fi.csdf__Pause_Resume_Message_Status__c = 'Waiting';
        }
        update fulfilmentItems.values();

        if (!Test.isRunningTest()){
            CS_FulfilmentWorker.prepareWork('Fulfilment Item Pause Resume', fulfilmentItems.values().get(0).csdf__Fulfilment__c, fulfilmentItems.keySet());
        }

        return JSON.serialize(PauseResumeRequestObject);
    }

    public class PauseResumeRequest {
        // mandatory params
        public String action { get; set; }
        public List<Id> configurationIds { get; set; }
    }

    public class CS_PauseResumeException extends Exception {

    }
}