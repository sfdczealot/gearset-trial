public class TagUnTagCase_cc {
    
    @auraEnabled
    public static String updateCase(String caseID){
        String error; 
        try{
            Profile prof = [select id,Name from profile where id =: UserInfo.getProfileId()];
            if(!Label.PG_LABEL_ProfilesToTagOrUntag.containsIgnoreCase(prof.Name)){
                error = 'You do not have access to perform this action!';
                return error;   
            }
            case oCase = [select id,Subject,accountid,Status,account.Overlap_Agent__c,account.Brickz_Agent__c,Account_Temp_ExternalField__c  from case where id=: caseID];
            if(oCase.Status == 'Closed'){
                error = 'Case is already Closed';
                return error;
            }
            if(oCase.Subject != 'Tag overlapping agent' && oCase.Subject != 'Tag Brickz Only agent' &&
               oCase.Subject != 'Un-Tag overlapping agent' && oCase.Subject != 'Un-Tag Brickz Only agent'){
                   error = 'This action cannot be performed for this case type';
                   return error;   
               }
            
            Account acc = new Account();
            acc.id = oCase.AccountId;
            if(oCase.subject == 'Tag overlapping agent'){
                
                SearchRecord_cc.tagUntagRecord(oCase.AccountId,oCase.Account_Temp_ExternalField__c ,'tag','Overlapping',oCase.AccountId);
                acc.External_field__c = oCase.Account_Temp_ExternalField__c;
                acc.Overlap_Agent__c = true;
            }
            if(oCase.subject == 'Un-Tag overlapping agent'){
                
                
                if(oCase.Account.Brickz_Agent__c == false){
                    SearchRecord_cc.tagUntagRecord(oCase.AccountId,oCase.Account_Temp_ExternalField__c ,'un-tag','Overlapping',null );
                    acc.External_field__c = null;
                } else
                    SearchRecord_cc.tagUntagRecord(oCase.AccountId,oCase.Account_Temp_ExternalField__c ,'un-tag','Overlapping',oCase.AccountId  );
                acc.Overlap_Agent__c = false;
            }
            if(oCase.subject == 'Tag Brickz Only agent'){
                
                SearchRecord_cc.tagUntagRecord(oCase.AccountId,oCase.Account_Temp_ExternalField__c ,'tag','Brickz Only',oCase.AccountId );
                acc.External_field__c = oCase.Account_Temp_ExternalField__c;
                acc.Brickz_Agent__c = true;
            }
            if(oCase.subject == 'un-Tag Brickz Only agent'){
                
                if(oCase.Account.Overlap_Agent__c == false){
                    acc.External_field__c = null;
                    SearchRecord_cc.tagUntagRecord(oCase.AccountId,oCase.Account_Temp_ExternalField__c ,'un-tag','Brickz Only',null );
                }else
                    SearchRecord_cc.tagUntagRecord(oCase.AccountId,oCase.Account_Temp_ExternalField__c ,'un-tag','Brickz Only',oCase.AccountId  );
                acc.Brickz_Agent__c = false;
            }
            oCase.Status='Closed';
            
            update oCase;
            update acc;
            
            return 'SUCCESS';
        }
        catch(Exception e){
            if(error==null){
                error = e.getMessage();
            }
            return error;
            //Throw new AuraHandledException(e.getMessage());
        }
        
    }
}