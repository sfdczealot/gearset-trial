/**
 * @description Sales Order hook implementation that enables Sales Order to a custom Apex code bridge. The class can be
 * invoked from a JavaScript code in a Sales Order, e.g.:
 * <pre>
 * Visualforce.remoting.Manager.invokeAction(
 *   'csmso.ContendingLineItemDisplay.performAction',
 *   'AvailabilityCheckPollActionInvoker',
 *   JSON.stringify(availabilityCheckParams),
 *   function(result, event) {
 *   callback(result, event);
 *   },
 *   {escape: false}
 * );
 * </pre>
 * Where <em>availabilityCheckParams</em> is an object that has to be serialised and sent to the Apax class,
 * <em>callback</em> is a function that handles the response. Important: the hook class must be global!
 *
 */
global with sharing class ContendingLineItemDisplay implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate  {
    global String performAction(String parameters) {
        try {           
            Id fulfilmentItemId = (Id)JSON.deserialize(parameters, Id.class);
            return JSON.serializePretty(
                CS_ContendingLineItemsService.getContendingItems(new Set<Id>{fulfilmentItemId}).get(fulfilmentItemId)
            );
        }
        catch (Exception e) {
            System.debug('ContendingLineItemDisplay>' + e.getMessage() + ' ' + e.getStackTraceString());
            System.debug('parameters>' + parameters);
            throw e;
        }
    }
}