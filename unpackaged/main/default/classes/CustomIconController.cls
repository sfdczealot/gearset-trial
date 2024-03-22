/*
 * TestClass : CustomIconController_Test 
 */
public class CustomIconController {
    
    @AuraEnabled
    public static RewardWrapper getCountryAndTier(String recordId){
        
        RewardWrapper rewardWrapperObj = new RewardWrapper();
        if(String.isNotBlank(recordId)){
            Account accountObj = [Select Id, Reward_Tier__c, Country__c from Account where Id = : recordId];
            rewardWrapperObj.country = accountObj.Country__c;
            rewardWrapperObj.rewardTier = accountObj.Reward_Tier__c;
        }
        if(rewardWrapperObj.rewardTier != null)
            return rewardWrapperObj;
        else
            return null;
    }
    
    public class RewardWrapper{
        
        @AuraEnabled
        public String country {get;set;}
        @AuraEnabled
        public String rewardTier {get;set;}
        
    }
}