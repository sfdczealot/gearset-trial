/**
 * Created by tvrtko.matosevic on 13/06/2019.
 */
global with sharing class CS_UserCustomPermissionInvoker implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {

    global String performAction(String params) {
        Set<String> customPermissionNames = new Set<String>();
        Set<String> customPermissionsForCurrentUser = new Set<String>();

        // Query the full set of Custom Permissions for the given namespace
        Map<Id, String> customPermissionNamesById = new Map<Id, String>();
        List<CustomPermission> customPermissions = [SELECT Id, DeveloperName FROM CustomPermission WHERE NamespacePrefix = NULL];
        for (CustomPermission customPermission : customPermissions) {
            customPermissionNames.add(customPermission.DeveloperName);
            customPermissionNamesById.put(customPermission.Id, customPermission.DeveloperName);
        }

        // Query to determine which of these custom settings are assigned to this user
        List<SetupEntityAccess> setupEntities = [
                SELECT SetupEntityId
                FROM SetupEntityAccess
                WHERE SetupEntityId in :customPermissionNamesById.keySet() AND
                ParentId
                        IN (
                                SELECT PermissionSetId
                                FROM PermissionSetAssignment
                                WHERE AssigneeId = :UserInfo.getUserId()
                        )
        ];
        for (SetupEntityAccess setupEntity : setupEntities) {
            customPermissionsForCurrentUser.add(customPermissionNamesById.get(setupEntity.SetupEntityId));
        }

        return JSON.serialize(customPermissionsForCurrentUser);
    }
}