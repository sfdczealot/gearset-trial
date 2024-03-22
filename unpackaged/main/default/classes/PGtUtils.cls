// PG Unit Test Utility Class
@isTest
public class PGtUtils {
    public static map<String, Id> mapRefProfileNameToProfileId = null;
    public static map<String, User> mapRefProfileNameToUser = null;
    public static map<String, Id> mapRefRoleDevNameToRoleId = null;
    public static map<String, User> mapRefRoleDevNameToUser = null;
    public static map<String, User> mapName2User = null;
    public static map<String, map<String, Id>> map_sObjType_2_mapRTDevName2Id = null;
    public static list<String> lstPriority = null;
    
    // Wrapper class representing a referenced user
    public class oneUser {
        public String name;
        public String communityNickname;
        public String profileName;
        public String roleName;

        public oneUser(String name, String communityNickname, String profileName, String roleName) {
            this.name = name;
            this.communityNickname = communityNickname;
            this.profileName = profileName;
            this.roleName = roleName;
        }
    }
    
    // Wrapper class representing a referenced record type
    public class oneRT {
        public String devName;
        public String objName;
        public String namespace;

        public oneRT(String devName, String objName, String namespace) {
            this.devName = devName;
            this.objName = objName;
            this.namespace = namespace;
        }
    }

    // Retrieve users
    public static Id getUserId(String name, String communityNickname, String profileName, String roleDevName) {
        User u = null;
        for (Integer i = 0; i < lstPriority.size(); i++) {
            if (u == null) {
                if (lstPriority[i].equalsIgnoreCase('Exact Match'))
                    u = getUserByName(name, communityNickname);
                else if(lstPriority[i].equalsIgnoreCase('By Profile'))
                    u = getUserByProfile(profileName);
                else if(lstPriority[i].equalsIgnoreCase('By Role'))
                    u = getUserByRole(roleDevName);
            }
            else
                break;
        }
        if (u != null)
            return u.Id;
        return null;
    }
    // Retrieve users by name
    public static User getUserByName(String name, String communityNickname) {
        return mapName2User.get(lc(name + communityNickname));
    }

    // Retrieve a user by profile
    public static User getUserByProfile(String profileName) {
        return mapRefProfileNameToUser.get(lc(profileName));
    }

    // Retrieve a user by role
    public static User getUserByRole(String roleDevName) {
        return mapRefRoleDevNameToUser.get(lc(roleDevName));
    }

    // Retrieve a role ID by developer name
    public static Id getRoleIdByDevName(String roleDevName) {
        return mapRefRoleDevNameToRoleId.get(lc(roleDevName));
    }

    // Retrieve a profile ID by name
    public static Id getProfileIdByName(String profileName) {
        if (! mapRefProfileNameToProfileId.containsKey(lc(profileName)))
            System.assert(false, 'Could not find a profile with name: ' + profileName);
        return mapRefProfileNameToProfileId.get(lc(profileName));
    }
    // Retrieve all users used in this project and store in the static map
    public static void retrieveUserInfo(list<oneUser> lstOU, String userPriority) {
        if (mapName2User == null) {
            lstPriority = (list<String>) JSON.deserialize(userPriority, list<String>.class);
            mapName2User = new map<String, User>();
            mapRefRoleDevNameToUser = new map<String, User>();
            mapRefRoleDevNameToRoleId = new map<String, Id>();
            mapRefProfileNameToUser = new map<String, User>();
            mapRefProfileNameToProfileId = new map<String, Id>();
            retrieveUserInfo(lstOU);
        }
        else {
        	list<oneUser> lstOULeft2Det = new list<oneUser>();
        	for (oneUser ou : lstOU) {
				if (getUserId(ou.name, ou.communityNickname, ou.profileName, ou.roleName) == null) {
					lstOULeft2Det.add(ou);
				}
        	}
        	retrieveUserInfo(lstOULeft2Det);
        }
    }
    
    // helper to retrieve user info for the data passed in
    private static void retrieveUserInfo(list<oneUser> lstOU)
    {
        if (lstOU.size() == 0)
			return;
			
        String dSoqlUsrs = '';
        set<String> stUserRoles = new set<String>();
        set<String> stProfiles = new set<String>();
        for (Integer i = 0; i < lstOU.size(); i++) {
            if(i > 0)
                dSoqlUsrs += ' OR ';
            if(String.isNotBlank(lstOU[i].Name) && String.isNotBlank(lstOU[i].communityNickname))
                dSoqlUsrs += '(Name = \'' + lstOU[i].Name + '\' and CommunityNickName = \'' + lstOU[i].communityNickname + '\')';
            if(String.isNotBlank(lstOU[i].roleName))
                stUserRoles.add(lstOU[i].roleName);
            if(String.isNotBlank(lstOU[i].profileName))
                stProfiles.add(lstOU[i].profileName);
        }
        if (String.isNotBlank(dSoqlUsrs)) {
            if(lstOU.size() > 1) {
                dSoqlUsrs = '(' + dSoqlUsrs + ')';
            }
            String dSoql = 'select u.Id, u.Name, u.CommunityNickname from User u where IsActive = true';
            if(String.isNotBlank(dSoqlUsrs)) {
                dSoql += ' and ' + dSoqlUsrs;
            }
            list<User> lstUsers = Database.query(dSoql);
            for (User usr : lstUsers) {
                mapName2User.put(lc(usr.Name + usr.CommunityNickname), usr);
            }
        }
        if (stUserRoles.size() > 0) {
            String userRoles = '';
            for(String userRole : stUserRoles) {
                userRoles += '\'' + userRole + '\',';
            }
            userRoles = userRoles.subString(0, userRoles.lastIndexOf(','));
            String dSoql = 'Select Id, DeveloperName, (select Id, Name from Users u where IsActive = true limit 1) from UserRole where DeveloperName IN (' + userRoles + ')';
            list<UserRole> lstRoles = Database.query(dSoql);
            for (UserRole usrRole : lstRoles) {
                if(usrRole.Users != null && usrRole.Users.size() == 1)
                    mapRefRoleDevNameToUser.put(lc(usrRole.DeveloperName), usrRole.Users[0]);
                mapRefRoleDevNameToRoleId.put(lc(usrRole.DeveloperName), usrRole.Id);
            }
        }
        if (stProfiles.size() > 0) {
            String userProfiles = '';
            for (String userProfile : stProfiles) {
                userProfiles += '\'' + userProfile + '\',';
            }
            userProfiles = userProfiles.subString(0, userProfiles.lastIndexOf(','));
            String dSoql = 'Select Id, Name, (select Id, Name from Users u where IsActive = true limit 1) from Profile where Name IN (' + userProfiles + ')';
            list<Profile> lstProfiles = Database.query(dSoql);
            for (Profile p : lstProfiles) {
                if (p.Users != null && p.Users.size() == 1)
                    mapRefProfileNameToUser.put(lc(p.Name), p.Users[0]);
                mapRefProfileNameToProfileId.put(lc(p.Name), p.Id);
            }
        }
    }
    
    // Get a record type ID from the static map
    public static String getRecordTypeId(String rtDevName, String objTypeName, String namespace) {
        map<String, Id> mapRTDevName2Id = map_sObjType_2_mapRTDevName2Id.get(lc(objTypeName));
        if (mapRTDevName2Id == null)
            System.assert(false, 'The Record Type for sObjectType = ' + objTypeName + ' is not configured in this environment.');
        String mskDevName = getRecTypeKey(rtDevName, namespace);
        Id recTypeId = mapRTDevName2Id.get(mskDevName);
        if (recTypeId == null)
            System.assert(false, 'The Record Type with DeveloperName = ' + rtDevName + ' and NamespacePrefix = ' + namespace + ' for sObjectType = ' + objTypeName + ' is not configured in this environment.');
        return recTypeId;
    }
    
    // Retrieve all record types used in this project and store in the static map
    public static void retrieveRecordTypes(list<oneRT> lstORT) {
        if (map_sObjType_2_mapRTDevName2Id == null) {
            map_sObjType_2_mapRTDevName2Id = new map<String, map<String, Id>>();
            retrieveRecordTypesFromDB(lstORT);
        }
        else {
        	list<oneRT> lstORTLeft2Det = new list<oneRT>();
        	for (oneRT ort : lstORT) {
        		if (	! map_sObjType_2_mapRTDevName2Id.containsKey(lc(ort.objName)) 
        			|| 	! map_sObjType_2_mapRTDevName2Id.get(lc(ort.objName)).containsKey(getRecTypeKey(ort.devName, ort.namespace))) {
					lstORTLeft2Det.add(ort);
				}
        	}
			retrieveRecordTypesFromDB(lstORTLeft2Det);
        }
    }
    //  helper to retrieve record types for the data passed in
    private static void retrieveRecordTypesFromDB(list<oneRT> lstORT) {
    	if (lstORT.size() == 0)
    		return;
    		
        String dSoqlRT = '';
        for (Integer i = 0; i < lstORT.size(); i++) {
            if (i > 0)
                dSoqlRT += ' OR ';
            dSoqlRT += '(sObjectType = \'' + lstORT[i].objName + '\' and DeveloperName = \'' + lstORT[i].devName + '\' and NamespacePrefix = ';
            if (String.isNotBlank(lstORT[i].namespace))
                dSoqlRT += '\'' + lstORT[i].namespace + '\')';
            else
                dSoqlRT += null + ')';
        }
        String dSoql = 'select r.Id, r.DeveloperName, r.NamespacePrefix, r.sObjectType from RecordType r';
        if (String.isNotBlank(dSoqlRT)) {
            dSoql += ' where ' + dSoqlRT;
        }
        list<RecordType> lstRTs = Database.query(dSoql);
        for (RecordType rt : lstRTs) {
            map<String, Id> mapRTDevName2Id = map_sObjType_2_mapRTDevName2Id.get(lc(rt.sObjectType));
            if (mapRTDevName2Id == null)
                mapRTDevName2Id = new map<String, Id>();
            String mskDevName = getRecTypeKey(rt.DeveloperName, rt.NamespacePrefix);
            mapRTDevName2Id.put(mskDevName, rt.Id);
            mapRTDevName2Id.put(lc(rt.DeveloperName), rt.Id);
            map_sObjType_2_mapRTDevName2Id.put(lc(rt.sObjectType), mapRTDevName2Id);
        }
    }
    // helper to make record type developer names unique if a namespace is present
    private static String getRecTypeKey(String rtDevName, String ns) {
        if (String.isNotBlank(ns))
            return lc(ns + '__'+ rtDevName);
		return lc(rtDevName);
    }
    
    
    //lowercase
    private static String lc(String sIn) {
    	if (String.isEmpty(sIn))
    		return null;
    	return sIn.toLowerCase();
    }
}