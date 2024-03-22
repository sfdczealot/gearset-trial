global with sharing class ConnectToRootController{

    Id adServerId;

    public ConnectToRootController(ApexPages.StandardController stdController) {

        adServerId = stdController.getId();
    }
    
    public pageReference connectRoots(){

        csdf__Ad_Slot__c adUnitsRoot = [SELECT id, csdf__Name__c 
                                        FROM csdf__Ad_Slot__c 
                                        WHERE csdf__name__c = 'Ad Units' 
                                              AND csdf__Ad_Server__r.Id = :adServerId][0];

        csdf__Ad_Slot__c placementsRoot = [SELECT id, csdf__Name__c 
                                           FROM csdf__Ad_Slot__c 
                                           WHERE csdf__name__c = 'Placements' 
                                                 AND csdf__Ad_Server__r.Id = :adServerId][0];

        List<csdf__Ad_Slot__c> listOfRootAdUnits = [SELECT id, name 
                                                    FROM csdf__Ad_Slot__c 
                                                    WHERE csdf__Type__c = 'Ad Unit' 
                                                          AND csdf__Active__c = true 
                                                          AND id NOT IN (SELECT csdf__Ad_Slot_Child__c 
                                                                         FROM csdf__Ad_Slot_Assignment__c 
                                                                         WHERE csdf__Ad_Slot_Parent__r.csdf__Active__c = true 
                                                                               AND csdf__Ad_Slot_Parent__r.csdf__Type__c = 'Ad Unit' 
                                                                               AND csdf__Ad_Slot_Parent__r.csdf__Ad_Server__r.Id = :adServerId) 
                                                          AND csdf__Ad_Server__r.Id = :adServerId];

        List<csdf__Ad_Slot__c> listOfPlacements = [SELECT id, csdf__Name__c 
                                                   FROM csdf__Ad_Slot__c 
                                                   WHERE csdf__Active__c = true 
                                                         AND csdf__Type__c = 'Placement' 
                                                         AND id NOT IN (SELECT csdf__Ad_Slot_Child__c 
                                                                        FROM csdf__Ad_Slot_Assignment__c 
                                                                        WHERE csdf__Ad_Slot_Parent__r.csdf__Active__c = true 
                                                                              AND csdf__Ad_Slot_Parent__r.csdf__Ad_Server__r.Id = :adServerId) 
                                                         AND csdf__Ad_Server__r.Id = :adServerId];

        List<csdf__Ad_Slot_Assignment__c> assignmentsToAdd = new List<csdf__Ad_Slot_Assignment__c>();
        for(csdf__Ad_Slot__c tmpAdUnit :listOfRootAdUnits){
            if(tmpAdUnit.id == adUnitsRoot.id){
                continue;
            }
            csdf__Ad_Slot_Assignment__c tmpAssignment = new csdf__Ad_Slot_Assignment__c();
            tmpAssignment.csdf__Ad_Slot_Child__c = tmpAdUnit.id;
            tmpAssignment.csdf__Ad_Slot_Parent__c = adUnitsRoot.id;
            assignmentsToAdd.add(tmpAssignment);
        }

        for(csdf__Ad_Slot__c tmpPlacement :listOfPlacements){
            if(tmpPlacement.id == placementsRoot.id){
                continue;
            }
            csdf__Ad_Slot_Assignment__c tmpAssignment = new csdf__Ad_Slot_Assignment__c();
            tmpAssignment.csdf__Ad_Slot_Child__c = tmpPlacement.id;
            tmpAssignment.csdf__Ad_Slot_Parent__c = placementsRoot.id;
            assignmentsToAdd.add(tmpAssignment);
        }

        insert assignmentsToAdd;
        return null;
    }  
}