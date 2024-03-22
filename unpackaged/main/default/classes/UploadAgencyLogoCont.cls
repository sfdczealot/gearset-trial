public class UploadAgencyLogoCont {
    //This method is used to get Id of media object to file upload component.
    @AuraEnabled
    public static Id createAgencyLogo(Id accId){
        Media__c objLogo=new Media__c();
        if(accId !=null){
            objLogo.Account__c=accId;
            insert objLogo;
        }
        return objLogo.Id;
    }
    //This method is used in ShowAgencyLogo.cmp component for displaying Agency Logo Images on detail page
    @AuraEnabled
    public static List<ContentVersion> getActiveContentDoc(Id accId){
        system.debug('--accId--'+accId);
        List<Media__c> lstmedia=[SELECT Id,Account__r.Agency_Id__c,createdDate FROM Media__c where isActive__c=true and Account__c=:accId order By createdDate Desc limit:1];
        if(lstmedia.size()>0){
        ContentDocumentLink ObjContentDoc = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId=:lstmedia[0].Id];
        List<Contentversion> attach=[SELECT Id,Title,ContentDocumentId FROM ContentVersion where ContentDocumentId=:ObjContentDoc.ContentDocumentId];
        return attach;
        }else{
            return null;
        }
            
    }
    // Call Biforst After file successufully uploaded in Media Object
    @AuraEnabled
    public static Boolean notifyBiforst(Id accId,Id mediaId){
        String RootEndpoint, RootEndpoint_Key;
        List<Media__c> inactiveListMedia=[select Id, Account__c,isActive__C from Media__c where Account__c=:accId AND Id <>:mediaId AND isActive__C=true];
        Map<string, string> mapCountryCode = EligibilityHandler.getMapCountryCode();
        system.debug('--inactiveListMedia--'+inactiveListMedia);
        system.debug('--mediaId--'+mediaId);
        Map<string,string> reqHeaders = new Map<string,string>();
        
        if (runningInASandbox()) {
            RootEndpoint = label.PG_LABEL_SendNotifyEndpoint_SB; 
            RootEndpoint_Key = label.PG_LABEL_sendNotifyKey_SB;
        }
        else{
            RootEndpoint = label.PG_LABEL_SendNotifyEndpoint;
            RootEndpoint_Key = label.PG_LABEL_sendNotifyKey; 
        }
        
        reqHeaders.put('Content-Type', 'application/json');
        reqHeaders.put('x-api-key', RootEndpoint_Key);
        reqHeaders.put('Content-Type', 'application/json');
        
        List <Account> acctoSend = new list<Account>();
        acctoSend = [SELECT Id, Country__c, Agency_Id__c  from Account where id  =: accId];
        AgencyLogo objlogo= new AgencyLogo();
        objlogo.id = acctoSend[0].id;
        objlogo.region = mapCountryCode.get(acctoSend[0].Country__c.toLowerCase());
        string requestt = system.JSON.serialize(objlogo);
        
        HTTPResponse res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,requestt,'POST',true,false,null,null);
        if(!Test.isRunningTest() && res.getStatusCode() == 200){
            If(inactiveListMedia.size()>0){
                for(Media__c each :inactiveListMedia){
                    each.isActive__c=false;
                }
                Update inactiveListMedia;
            }
            if(mediaId !=null){
                Media__c objMedia=new Media__c(Id=mediaId,isActive__c=true);
                Update objMedia;
                system.debug('--objMedia--'+objMedia);
            }
            return true;
        }
        return false;
    }
    //This method is used to check if code execution is from sandbox environment or production
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    public class AgencyLogo { 
        String id;     String region= '';     String entity = 'media' ;        String origin = 'sfsc';  
    }
}