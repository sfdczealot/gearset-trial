@isTest
public class Test_PGCampMemberTrigger {

    public static testmethod void credValidationTest(){
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        List<CampaignMember> campMemberList = new List<CampaignMember>();
        Campaign camp = new Campaign();
        camp.Name = 'TestCampaign';
        camp.IsActive = true;
        camp.Country__c = 'Singapore';
        camp.CurrencyIsoCode = 'SGD';
        camp.Source_Campaign_Reference__c='camp1';
        camp.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Marketing_Promo').getRecordTypeId();
        camp.StartDate = system.today();
        camp.Campaign_Start_DateTime__c = system.now();
        camp.Campaign_End_DateTime__c = system.now().addDays(+1);
        camp.EndDate = system.today().addDays(+1);
        insert camp;
        
        Contact con = new Contact();
        con.FirstName = 'TestFName';
        con.LastName = 'TestLName';
        con.Email = 'test@mail.com'; 
        insert con;
      
        CampaignMember campMember = new CampaignMember();
        campMember.ContactId = con.Id;
        campMember.Status = 'Eligible';
        campMember.CampaignId = camp.Id;
        campMemberList.add(campMember);
        insert campMemberList;
        
        Test.startTest();
        PGCampMemberTriggerHandler.credValidation(campMemberList);
        update campMemberList;        
        PGCampMemberTriggerHandler.credValidation(campMemberList);
        delete campMemberList;
        PGCampMemberTriggerHandler.credValidation(campMemberList);
        Test.stopTest();
    }
}