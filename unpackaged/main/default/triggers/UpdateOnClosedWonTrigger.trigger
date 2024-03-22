trigger UpdateOnClosedWonTrigger on Updates_On_Closed_Won__e (after insert) {
    map<String, Trigger_Execute__c> mapOfAction = Trigger_Execute__c.getAll();
    if(
        mapOfAction != null &&
        mapOfAction.containsKey('UpdateOnClosedWonTrigger') &&
        mapOfAction.get('UpdateOnClosedWonTrigger').Enable_del__c
    ) {
        new UpdateOnClosedWonTriggerHandler().runTrigger();
    }
}