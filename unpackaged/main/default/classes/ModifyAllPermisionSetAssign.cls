public class ModifyAllPermisionSetAssign{
    public static PermissionSet permissionSet = [SELECT Id FROM PermissionSet WHERE Name =: 'Modify_All_Permissions'];
    public static  List<PermissionSetAssignment> updatePermissionSet = new  List<PermissionSetAssignment>();
    
    //ModifyAllPermisionSetAssign.addPermissionSet('danielkoon@propertyguru.com.sg.pgramdev', 1);
    
    public static void addPermissionSet(String urName, Integer hr){ 
        List<PermissionSetAssignment> expiredPsaList = [SELECT Id, Assignee.Name, PermissionSet.Name, PermissionSet.Label, PermissionSet.Description, PermissionSetId, AssigneeId, ExpirationDate FROM PermissionSetAssignment WHERE ExpirationDate >= TODAY AND PermissionSet.IsOwnedByProfile = FALSE ALL ROWS];
        User ur = [SELECT  Id, Name, Username, Profile.UserLicense.Name FROM User WHERE Username =: urName];
        // system.debug('expiredPsaList count' + expiredPsaList);
        if(expiredPsaList.size() == 0  && ur.Profile.UserLicense.Name == 'Salesforce'){
           // system.debug('it is if condition');
            PermissionSetAssignment psa = new PermissionSetAssignment();
            psa.AssigneeId = ur.Id;
            psa.PermissionSetId = permissionSet.Id;
            psa.ExpirationDate = DateTime.now().addHours(hr); 
            Database.SaveResult sr = Database.insert(psa);
        }
        else{
            // system.debug('duplicate value');
            for(PermissionSetAssignment exp :expiredPsaList){
                //  system.debug('usId = ' + ur.Id + ', assignedId = ' + exp.AssigneeId);
                if(exp.AssigneeId ==  ur.Id  && ur.Profile.UserLicense.Name == 'Salesforce'){
                    //  system.debug('duplicate value');
                    exp.ExpirationDate = DateTime.now().addHours(hr);
                    updatePermissionSet.add(exp);
                }
            }
            Update updatePermissionSet;
        }
    }
}