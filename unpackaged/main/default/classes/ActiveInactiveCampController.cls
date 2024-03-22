// Test Class: Test_ActiveInactiveCampController
public class ActiveInactiveCampController {
    
    @AuraEnabled
    public static Campaign getCampInfo(String campId) {
        
        List<Campaign> campList = [SELECT Id, IsActive, 
                                   StartDate, EndDate 
                                   FROM Campaign 
                                   WHERE Id =: campId
                                  ];
        if(campList.size()>0) {
            return campList[0];
        }
        else {
            return null;
        }
    }
    
    @AuraEnabled
    public static LightningResponse getResponse(String campRec) {
        try {
            Campaign camp = (Campaign) JSON.deserializeStrict(campRec, Campaign.Class);
            LightningResponse objResponse = updateCampaign(camp);
            return new LightningResponse(objResponse.isSuccess, objResponse.message, '');
            
        } catch (Exception ex) {
            String strException = ex.getMessage();
            if(strException.contains('FIELD_CUSTOM_VALIDATION_EXCEPTION')) {
                strException = strException.split('FIELD_CUSTOM_VALIDATION_EXCEPTION, ')[1].split(':')[0];
            }
            return new LightningResponse(false, strException, '');
        } 
    }
    
    // To active/inactive campaign 
    private static LightningResponse updateCampaign(Campaign camp) {
        LightningResponse campaignRes = new LightningResponse(false,null,'');
        Id currentUserId = UserInfo.getUserId();
        String msg = '';
        Boolean success = false;
        Date currentDate = system.today();
        // To check if current user can edit Campaign or not
        List<UserRecordAccess> currentUserRecAccess = [SELECT HasEditAccess,RecordId 
                                                       FROM UserRecordAccess 
                                                       WHERE UserId =: currentUserId
                                                       AND RecordId =: camp.Id 
                                                      ];
        
        
        if(currentUserRecAccess.size()>0 && !currentUserRecAccess[0].HasEditAccess) {
            success = false;
            msg = System.Label.GENERAL_ERROR_EDIT;
        } 
        else if(camp!=null) {
            if(camp.IsActive == true) {
                camp.IsActive = false;
                success = true;
                msg = System.Label.CAMP_SUCCESS_INACTIVE;
            } else {
                camp.IsActive = true;
                success = true;
                msg = System.Label.CAMP_SUCCESS_ACTIVE;
            }
                update camp;
        }
        
        campaignRes.isSuccess = success;
        campaignRes.message = msg;
        return campaignRes;
    }
    
}