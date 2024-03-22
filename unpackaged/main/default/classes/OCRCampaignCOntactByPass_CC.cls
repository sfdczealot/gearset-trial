public class OCRCampaignCOntactByPass_CC {
    
    @auraEnabled
    public static void checkValidations(String oppId){
        Boolean hasCustomPermission = FeatureManagement.checkPermission('System_Admin_Compliance_Access');
        if(!hasCustomPermission){
            throw new AuraHandledException('You are not Authorized');
        }
        List<OCR_Campaign_Contact_Bypass__c> campContList = [select id 
                                                             from OCR_Campaign_Contact_Bypass__c 
                                                             where Opportunityid__c =: oppID];
        if(campContList.isEmpty()){
            OCR_Campaign_Contact_Bypass__c campCon = new OCR_Campaign_Contact_Bypass__c(name=oppID,Opportunityid__c =oppID);
            insert campCon;
        } else{
            throw new AuraHandledException('Opportunity is already added to list');
        }
        
    }
}