@isTest
public class BatchTOUpdateAgencyLOGO_Test {
@isTest
    public static void fetchRecords(){
         PGTestDataFactory_v2.initSetupData();    
        account acc = new account(name='Test');
        insert acc;
        list<Media__c> med = new list<Media__c>();
        for(Integer i=0;i<10;i++){
            med.add(new Media__c(IsActive__c=false,Account__c=acc.id,URL__c='https://res-1.cloudinary.com/crunchbase-production/image/upload/c_lpad,h_120,w_120,f_auto,b_white,q_auto:eco/affmaxcmuywiatu2qrjk'));
        }
        insert med;
        Test.setMock(HttpCalloutMock.class, new BatchTOUpdateAgencyLOGO_Mockclass());
        Test.startTest();
        Database.executeBatch(new BatchTOUpdateAgencyLOGO());
        Test.stopTest();
        system.assertEquals(acc.name,'Test','Name does not match');
    }
}