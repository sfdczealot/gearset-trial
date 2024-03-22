/**
 * @description Sales Order hook implementation that enables Sales Order to a custom Apex code bridge. The class can be
 * invoked from a JavaScript code in a Sales Order, e.g.:
 * <pre>
 * Visualforce.remoting.Manager.invokeAction(
 *   'csmso.CSRemoteActionDelegation.performAction',
 *   'AvailabilityCheckActionInvoker',
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
global without sharing class AvailabilityCheckActionInvoker implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
   
    /**
     * @description Implementation of the interface. The method receives JSON serialised request and responses with a
     * JSON structure that can be processed from JavaScript code within a Sales Order.
     *
     * @param parameters serialised JSON structure as a request
     * @return serialised JSON structure as a response
     */
    global String performAction(String parameters) {
        Id fulfilmentItemId = (Id) JSON.deserialize(parameters, Id.class);
        
        DigitalFulfilmentAdapterUtil.invokeAvailabilityCheck(fulfilmentItemId);
        return JSON.serialize(fulfilmentItemId);
    }
}