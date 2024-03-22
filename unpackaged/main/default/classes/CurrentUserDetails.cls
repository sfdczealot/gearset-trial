public class CurrentUserDetails {
     
    public class getAllDetails{
        @AuraEnabled
        public String profileName{get;set;}
        @AuraEnabled
        public String recordType{get;set;}
    }
    
    @auraEnabled
    public static getAllDetails getDetails(){
        Id profileId=UserInfo.getProfileId();
        String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
        system.debug('ProfileName'+profileName);
        
        List<String> recordTypeNameList = new List<String>();
        Schema.DescribeSObjectResult R = Account.SObjectType.getDescribe();
        List<Schema.RecordTypeInfo> RT = R.getRecordTypeInfos();
        for( Schema.RecordTypeInfo recordType : RT )
        {
            if(recordType.isAvailable())
            { 
                if(recordType.Name!='Master') {
                   recordTypeNameList.add(recordType.recordTypeId);
                    
                }
            }
        }
        getAllDetails getAll=new getAllDetails();
        getAll.profileName=profileName;
        if(recordTypeNameList.size() == 1){
            getAll.RecordType = recordTypeNameList[0];
        }
        return getAll;
    }
}