@isTest
public class UploadAgencyLogoCont_Test {
    public static testMethod void unitTest(){
      PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        String accRectype2 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
        Account a = new Account();
        a.RecordTypeId = accRectype2;
        a.Name = 'Unit Test Agency';
        a.Customer_Type__c = 'Agency';
        a.Agency_Id__c = '1234';
        a.CEA_License__c = 'Test';
        insert a;
        
        Account a2 = new Account();
        a2.RecordTypeId = accRectype2;
        a2.Name = 'Unit Test Agency';
        a2.Customer_Type__c = 'Agency';
        a2.Agency_Id__c = '1234';
        a2.CEA_License__c = 'Test';
        insert a2;
        
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        media__c media = new media__c ();
        media.isActive__c= true; 
        media.Account__c=a.Id ;
                insert media ; 

        
        
        
         media__c media2 = new media__c ();
        media2.isActive__c= true; 
        media2.Account__c=a.Id ;
        
        
        
       
     
        insert media2 ; 
       
        ContentVersion cv = new ContentVersion();
        cv.versionData =  blob.valueOf('test');
        cv.title ='TEST_FILE1.png' ;
        cv.pathOnClient ='TEST_FILE1.png' ;
        cv.FirstPublishLocationId = media.Id;
        
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        
        //create ContentDocumentLink  record 
        ContentDocumentLink cdl = New ContentDocumentLink();
        cdl.LinkedEntityId = media2.id;
        cdl.ContentDocumentId = documents[0].Id;
        cdl.shareType = 'V';
        insert cdl;
        
        
        
        
        req.requestURI = '/services/apexrest/api/agency/logo?id='+a.id;  
        req.httpMethod = 'GET';
        req.addParameter('id', a.id);
        RestContext.request = req;
        RestContext.response= res;
        
        AgencyAPI_Logo.getAgencyLogo();
        
        test.startTest();
             id m=  UploadAgencyLogoCont.createAgencyLogo(a.Id);
        UploadAgencyLogoCont.getActiveContentDoc(a.Id);
         UploadAgencyLogoCont.getActiveContentDoc(a2.Id);

      boolean b=  UploadAgencyLogoCont.notifyBiforst(a2.Id,m); 
        test.stopTest();

            
        
    }
}