global with sharing class MediaTargetingWidgetSO implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    
    @RemoteAction
    @AuraEnabled
    global static String performAction(String parameters) {
        System.debug('##### Calling performAction');
        return MediaTargetingWidget.performAction(parameters);
    }
    
    @ReadOnly
    @RemoteAction
    @AuraEnabled
    global static String performReadOnlyAction(String parameters) {
        System.debug('##### Calling performReadOnlyAction');
        return MediaTargetingWidget.performAction(parameters);
    }
}