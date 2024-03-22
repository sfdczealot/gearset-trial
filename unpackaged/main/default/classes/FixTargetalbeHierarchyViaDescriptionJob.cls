public with sharing class FixTargetalbeHierarchyViaDescriptionJob implements Database.Batchable<SObject> { 

    public FixTargetalbeHierarchyViaDescriptionJob() {
    }

    public Iterable<SObject> start(Database.BatchableContext batchCont) {

        return Database.getQueryLocator([SELECT Id, csdf__Description__c, csdf__Ad_Server_Id__c, Targetable_Parent__c, csdf__Ad_Server__c
                                         FROM csdf__Targetable__c
                                         WHERE csdf__Description__c != null
                                               AND Targetable_Parent__c = null]);
    }

    public void execute(Database.BatchableContext batchCont, List<csdf__Targetable__c> scope) {

        // select all targetables with parent in desciription 
        Set<string> adServersToSearch = new Set<string>();
        for(csdf__Targetable__c target : scope) {
            if(!target.csdf__Description__c.isNumeric()) {
                continue;
            }
            adServersToSearch.add(target.csdf__Description__c);
        }

        // map of Ad Server SFDC ID -> (map of Targetable Ad Server ID string -> Targetable SFDC ID)
        Map<Id, Map<String, Id>> sortedTargetables = new Map<Id, Map<String, Id>>();
        for(csdf__Targetable__c target : [SELECT Id, csdf__Description__c, csdf__Ad_Server_Id__c, Targetable_Parent__c, csdf__Ad_Server__c
                                          FROM csdf__Targetable__c
                                          WHERE csdf__Ad_Server_Id__c IN :adServersToSearch]) {

            if (!sortedTargetables.containsKey(target.csdf__Ad_Server__c)){
                sortedTargetables.put(target.csdf__Ad_Server__c, 
                                      new Map<String, Id> { target.csdf__Ad_Server_Id__c => target.Id });
            }
            else {
                sortedTargetables.get(target.csdf__Ad_Server__c)
                                 .put(target.csdf__Ad_Server_Id__c, target.Id);
            }
        }

        // update parent field
        List<csdf__Targetable__c> targetsToUpdate = new List<csdf__Targetable__c>();
        for(csdf__Targetable__c target : scope){
            if(!target.csdf__Description__c.isNumeric() 
               || !sortedTargetables.containsKey(target.csdf__Ad_Server__c)
               || !sortedTargetables.get(target.csdf__Ad_Server__c).containsKey(target.csdf__Description__c)) {

                continue;
            }
            
            target.Targetable_Parent__c = sortedTargetables.get(target.csdf__Ad_Server__c).get(target.csdf__Description__c);
            targetsToUpdate.add(target);
        }

        if(!targetsToUpdate.isEmpty()){
            update targetsToUpdate;
        }
    }

    public void finish(Database.BatchableContext batchCont) {
    }
}