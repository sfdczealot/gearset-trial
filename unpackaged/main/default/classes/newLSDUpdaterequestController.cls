public class newLSDUpdaterequestController {
    /**
*  Method used to validate that only 1 request is made at a time
*  @name validateApprovalCap
*  @param List<LSD_Update__c>, Map<Id,LSD_Update__c>
*  @return void
*/
    @AuraEnabled(cacheable = true)
    public static LightningResponse validateApprovalCap(String accId) {
        try {
            WrapResponse objResponse = calculateInputFields(accId);
            return new LightningResponse(true, 'Success', JSON.serialize(objResponse));   
        } catch (Exception ex) {
            return new LightningResponse(false, ex.getMessage(), '');
        }
    } 
    public static WrapResponse calculateInputFields (String accId){
        Account acc = [SELECT Loyalty_Start_Date__c from Account where Id =: accId];
        Id currentUserId = UserInfo.getUserId();
        Boolean hasAccess = [SELECT RecordId, HasEditAccess FROM UserRecordAccess WHERE UserId =: currentUserId AND RecordId =: accId].HasEditAccess;
        WrapResponse wrapRes = new WrapResponse();
        wrapRes.loyaltyStartDate = acc.Loyalty_Start_Date__c;
        
        List<LSD_Update__c> LSDSubmitted = [SELECT Id,Approval_Status__c FROM LSD_Update__c WHERE Approval_Status__c ='Submit for approval' and account__C =:accId];
        
        if(LSDSubmitted.size() >=1 || !hasAccess) {
            wrapRes.allowRequest = false;
        }else{
            wrapRes.allowRequest = true;
        }
        
        return wrapRes;
    }
    
    public class WrapResponse {
        @AuraEnabled
        public date loyaltyStartDate;
        @AuraEnabled
        public boolean allowRequest;
    } 
     
}