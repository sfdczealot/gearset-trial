public with sharing class RootPathBatch implements Database.Batchable<SObject>
{
    public class RootPathBatchException extends Exception {}


    private final String sObjectApiName;
    private final Integer hierarchyDepthLimit;
    Map<Id, Id> adServerIdToAdUnitsFolderIdMap = new Map<Id, Id>();
    Map<Id, Id> adServerIdToPlacementsFolderIdMap = new Map<Id, Id>();


    public RootPathBatch(String getSObjectApiName, Integer getHierarchyDepthLimit) {

        sObjectApiName = getSObjectApiName;
        hierarchyDepthLimit = getHierarchyDepthLimit;

        if (getSObjectApiName == 'csdf__Ad_Slot__c') {

            for (csdf__Ad_Slot__c adUnitsFolder : [SELECT id, csdf__Ad_Server__r.Id 
                                                   FROM csdf__Ad_Slot__c 
                                                   WHERE csdf__Ad_Server_Id__c = '0']){

                adServerIdToAdUnitsFolderIdMap.put(adUnitsFolder.csdf__Ad_Server__r.Id, adUnitsFolder.id);
            }
            
            for (csdf__Ad_Slot__c placementsFolder : [SELECT id, csdf__Ad_Server__r.Id 
                                                      FROM csdf__Ad_Slot__c 
                                                      WHERE csdf__Ad_Server_Id__c = '1']){

                adServerIdToPlacementsFolderIdMap.put(placementsFolder.csdf__Ad_Server__r.Id, placementsFolder.id);
            }
        }
    }

    public Database.QueryLocator start(Database.BatchableContext getBc) {

        if (sObjectApiName == 'csdf__Targetable__c') {

            return Database.getQueryLocator([SELECT Id, Parent_Node_Id__c, Root_Path__c, Top_Level_Node__c, csdf__Ad_Server__r.Id
                                             FROM csdf__Targetable__c
                                             WHERE Top_Level_Node__c = false
                                                   AND (Root_Path__c = null 
                                                        OR Root_Path__c = '')]);
        }
        else if (sObjectApiName == 'csdf__Operating_System_Version__c') {
        
            return Database.getQueryLocator([SELECT Id, Parent_Node_Id__c, Root_Path__c, Top_Level_Node__c, csdf__Operating_System__r.csdf__Ad_Server__r.Id
                                             FROM csdf__Operating_System_Version__c
                                             WHERE Top_Level_Node__c = false
                                                   AND (Root_Path__c = null 
                                                        OR Root_Path__c = '')]);
        }
        else if (sObjectApiName == 'csdf__Geo_Item__c') {
        
            return Database.getQueryLocator([SELECT Id, Root_Path__c, Top_Level_Node__c, csdf__Ad_Server__r.Id
                                             FROM csdf__Geo_Item__c
                                             WHERE Top_Level_Node__c = false
                                                   AND (Root_Path__c = null OR
                                                        Root_Path__c = '')]);
        }
        else if (sObjectApiName == 'csdf__Ad_Slot__c') {
        
            return Database.getQueryLocator([SELECT Id, csdf__Type__c, Root_Path__c, Top_Level_Node__c, csdf__Ad_Server__r.Id
                                             FROM csdf__Ad_Slot__c
                                             WHERE Top_Level_Node__c = false
                                                   AND (Root_Path__c = null OR
                                                        Root_Path__c = '')]);
        }

        throw new RootPathBatchException('Unsupported sObjectApiName: ' + sObjectApiName);
    }

    public void execute(Database.BatchableContext getBc, List<SObject> getScope) {
        
        List<SObject> objectsToUpdateList = new List<SObject>();

        if (sObjectApiName == 'csdf__Operating_System_Version__c'
            || sObjectApiName == 'csdf__Targetable__c') {
        
            for(SObject sObj : getScope){

                String parentNodeIdStr = String.valueOf(sObj.get('Parent_Node_Id__c'));
                if (String.isBlank(parentNodeIdStr)) {
                    sObj.put('Top_Level_Node__c', true);
                } else {
                    Id parentNodeId = parentNodeIdStr;
                    sObj.put('Root_Path__c', parentNodeId);
                }
                objectsToUpdateList.add(sObj);
            }
        }
        else if (sObjectApiName == 'csdf__Geo_Item__c') {
        
            for(csdf__Geo_Item__c geoItem : (List<csdf__Geo_Item__c>)getScope){
            
                String rootPathStr = '';
                Integer currentHierarchyLevel = 0;
                Boolean hierarchySearchComplete = false;
                Id currentNodeId = geoItem.Id;

                do {
                    if (currentHierarchyLevel > hierarchyDepthLimit){
                        break;
                    }   

                    List<csdf__Geo_Item_Assignment__c> geoItemAssignmentsList = [SELECT csdf__Geo_Item_Parent__c 
                                                                                 FROM csdf__Geo_Item_Assignment__c 
                                                                                 WHERE csdf__Geo_Item_Child__c = :currentNodeId];
                    if (geoItemAssignmentsList.size() > 0) {

                        currentHierarchyLevel++;

                        currentNodeId = geoItemAssignmentsList[0].csdf__Geo_Item_Parent__c;

                        rootPathStr = String.valueOf(currentNodeId) + (String.isBlank(rootPathStr) ? '' : 
                                                                                                     ',' + rootPathStr);
                    } else {
                        hierarchySearchComplete = true;
                        break;
                    }
                } while (true);

                if (hierarchySearchComplete){
                    
                    if (String.isBlank(rootPathStr)){
                        geoItem.Top_Level_Node__c = true;
                    } else {
                        geoItem.Root_Path__c = rootPathStr;
                    }
                    objectsToUpdateList.add(geoItem);
                }
            }
        }
        else if (sObjectApiName == 'csdf__Ad_Slot__c') {
        
            for(csdf__Ad_Slot__c adSlot : (List<csdf__Ad_Slot__c>)getScope) {

                if (adSlot.csdf__Type__c == 'Ad Unit'){
                
                    String rootPathStr = '';
                    Integer currentHierarchyLevel = 0;
                    Boolean hierarchySearchComplete = false;
                    Id currentNodeId = adSlot.Id;

                    do {
                        if (currentHierarchyLevel > hierarchyDepthLimit){
                            break;
                        }   

                        List<csdf__Ad_Slot_Assignment__c> adSlotAssignmentsList = [SELECT csdf__Ad_Slot_Parent__c 
                                                                                   FROM csdf__Ad_Slot_Assignment__c 
                                                                                   WHERE csdf__Ad_Slot_Parent__r.csdf__Type__c = :adSlot.csdf__Type__c
                                                                                         AND csdf__Ad_Slot_Child__c = :currentNodeId];
                        if (adSlotAssignmentsList.size() > 0) {

                            currentHierarchyLevel++;

                            currentNodeId = adSlotAssignmentsList[0].csdf__Ad_Slot_Parent__c;

                            rootPathStr = String.valueOf(currentNodeId) + (String.isBlank(rootPathStr) ? '' :
                                                                                                         ',' + rootPathStr);
                        } else {
                            hierarchySearchComplete = true;
                            break;
                        }
                    } while (true);

                    if (hierarchySearchComplete){
                        
                        adSlot.Root_Path__c = String.valueOf(adServerIdToAdUnitsFolderIdMap .get(adSlot.csdf__Ad_Server__r.Id))
                                              + (String.isBlank(rootPathStr) ? '' 
                                                                             : ',' + rootPathStr);
                        objectsToUpdateList.add(adSlot);
                    }

                } else if (adSlot.csdf__Type__c == 'Placement') {
                
                    adSlot.Root_Path__c = String.valueOf(adServerIdToPlacementsFolderIdMap.get(adSlot.csdf__Ad_Server__r.Id));
                    objectsToUpdateList.add(adSlot);
                }
            }
        }

        update objectsToUpdateList;
    }

    public void finish(Database.BatchableContext getBc){ }
}