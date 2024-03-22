global with sharing class PauseResumeActionInvoker implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {

    global String performAction(String parameters) {
        Id fulfilmentItemId = (Id) JSON.deserialize(parameters, Id.class);

        csam.ObjectGraphCalloutHandler.createAndSend('Fulfilment Item Pause Resume', fulfilmentItemId);

        return JSON.serialize(fulfilmentItemId);
    }
}