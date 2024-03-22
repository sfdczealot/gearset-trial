//TEST CLASS : UploadAgencyLogoCont_Test
@RestResource(urlMapping='/api/agency/logo/*')
global class AgencyAPI_Logo {
    @HttpGet
    global static void getAgencyLogo() {
        String Id = RestContext.request.params.get('id');
        system.debug('--Id--'+Id);
        RestResponse res = RestContext.response; //0017F00001JnE2SQAV 
        List<Media__c> lstmedia=[SELECT Id,Account__r.Agency_Id__c,createdDate FROM Media__c where Account__c=:Id and isActive__c=true  order By createdDate Desc limit:1];
        If(lstmedia.size()>0){//a1L6D000000Lh0dUAC
            ContentDocumentLink ObjContentDoc = [SELECT Id, LinkedEntityId, ContentDocumentId FROM ContentDocumentLink where LinkedEntityId=:lstmedia[0].Id];
        	Contentversion attach=[SELECT Id,Title,ContentDocumentId,VersionData FROM ContentVersion where ContentDocumentId=:ObjContentDoc.ContentDocumentId];
            RestContext.response.statusCode = 200;
            RestContext.response.responseBody = attach.VersionData;
        }else{
            RestContext.response.statusCode = 400;
            RestContext.response.responseBody =blob.valueOf('Logo is not present for requested agency id'+Id);
        }
        
    }
}