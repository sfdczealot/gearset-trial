/**
 * @description Sales Order hook implementation that enables Sales Order to a custom Apex code bridge. The class can be
 * invoked from a JavaScript code in a Sales Order, e.g.:
 * <pre>
 * Visualforce.remoting.Manager.invokeAction(
 *   'csmso.CSRemoteActionDelegation.performAction',
 *   'FulfilmentItemActionInvoker',
 *   JSON.stringify(dfParams),
 *   function(result, event) {
 *   callback(result, event);
 *   },
 *   {escape: false}
 * );
 * </pre>
 * Where <em>dfParams</em> is an object that has to be serialised and sent to the Apax class,
 * <em>callback</em> is a function that handles the response. Important: the hook class must be global!
 *
 */
global with sharing class CS_UserPermission implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {

    /**
     * @description Implementation of the interface. The method receives JSON serialised request and responses with a
     * JSON structure that can be processed from JavaScript code within a Sales Order.
     * This method returns all Permission Sets assigned to user, returned as serialised JSON Set<String>
     *
     * @param parameters serialised JSON structure as a request
     * @return serialised JSON structure as a response
     */
    global String performAction(String params) {
        Set<String> permissionSetNames = new Set<String>();

        List<PermissionSetAssignment> permissionSets = [SELECT AssigneeId, PermissionSet.Name FROM PermissionSetAssignment WHERE AssigneeId = :Userinfo.getUserId()];

        for(PermissionSetAssignment permissionSet : permissionSets) {
            permissionSetNames.add(permissionSet.PermissionSet.Name);
        }

        return JSON.serialize(permissionSetNames);
    }

}