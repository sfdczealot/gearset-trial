/**
 * Created by tvrtko.matosevic on 30/05/2019.
 */

@IsTest
private class CS_UserPermissionTest {

    @IsTest
    static void testGettingUsersPermissions() {
        CS_UserPermission userPermission = new CS_UserPermission();
        String permissionSetNames = userPermission.performAction(null);
    }
}