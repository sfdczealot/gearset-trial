@isTest
public class OCRCampaignCOntactByPass_CC_test {
    /*static testmethod void test()
{
Opportunity opp = new opportunity();
opp.Name = 'Test Opp';
opp.StageName = 'Proposal';
opp.CloseDate = system.today().AddDays(30);
opp.Order_Type__c = 'Contract - Renewal';
insert opp;
OCR_Campaign_Contact_Bypass__c cs = new OCR_Campaign_Contact_Bypass__c();
cs.Name = 'test';
cs.OpportunityID__c ='122726252';
string recordid ='test123';
test.startTest();
//   BypassOCRrestriction.getHiearchySettings(recordid);
test.stopTest();
}*/
    static testmethod void test2()
    {
        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'prospecting';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Order_Type__c = 'Contract - Renewal';
        insert opp;
        
        
        OCR_Campaign_Contact_Bypass__c cs = new OCR_Campaign_Contact_Bypass__c();
        cs.Name = 'test';
        
        
        string recordid ='test123';
        test.startTest();
        try {
            OCRCampaignCOntactByPass_CC.checkValidations(recordid);
        } catch(Exception ex) {}
        test.stopTest();
        
        
    }
    static testmethod void test3()
    {
        Account acc = TestDataSetupSO.createB2BAcc();
        insert acc;
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'prospecting';
        opp.AccountId = acc.Id;
        opp.CloseDate = system.today().AddDays(30);
        opp.Order_Type__c = 'Contract - Renewal';
        insert opp;
        
        
        OCR_Campaign_Contact_Bypass__c cs = new OCR_Campaign_Contact_Bypass__c();
        cs.Name = 'test';
        
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator']; 
        User u = new User(Alias = 'standt', Email='systemAdminPropertyGuru@test1org.com', 
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                          LocaleSidKey='en_US', ProfileId = p.Id, 
                          TimeZoneSidKey='America/Los_Angeles', UserName='systemAdminPropertyGuru@test1org.com');
        
        System.runAs(u) {
            string recordid ='test123';
            test.startTest();
            try {
                OCRCampaignCOntactByPass_CC.checkValidations(recordid);
            } catch(Exception ex) {}
            test.stopTest();
        }
        
    }
    
}