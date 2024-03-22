@isTest
public class trigger_MarketingEmailHis_Test {
    
    public static testMethod void unitTest(){
        
        Trigger_Execute__c objcustomsett=new Trigger_Execute__c();
        objcustomsett.Name='MarketingEmailHistoryTracker';
        objcustomsett.Enable_del__c=true;
        insert objcustomsett;
        
        AWS_Credential__c customsetting=new AWS_Credential__c();
        customsetting.Name='AwsCredential';
        customsetting.Key__c='TESSTEE';
        customsetting.Secret__c='ESSWTEST';
        customsetting.BucketName__c='aws-test';
        customsetting.Host__c='s3.test.com';
        customsetting.Folder__c='/test/';
        insert customsetting;
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        string Abc ='acs';
        Blob test = Blob.valueOf('o');
        
        
        SendFileToAwsClass.getPermUrlAWS(Abc, test);
        
        MarketingEmailHistoryTracker__c obj=new MarketingEmailHistoryTracker__c();
        obj.CampaignName__c='test';
        obj.EmailName__c='test_email';
        obj.OriginalURL__c='http://example.com/example/test';
        insert obj;
        obj.PermURL__c=null;
        update obj;
        system.debug('--testclass-obj-'+obj);
        SchBatchToUpdPermUrlMarkEmailHis objclass=new SchBatchToUpdPermUrlMarkEmailHis();
        objclass.execute(null);
    }
    public static testMethod void unitTest1(){
        
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        
        SendFileToAwsClass.getContentFromUrl('http://example.com/example/test');
        
        Test.StopTest();
    }
}