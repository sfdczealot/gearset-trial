@isTest
public class Test_ActiveInactiveCampController {

    public static testmethod void getCampInfoTest(){
        
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.IsActive = true;
        cma.StartDate = system.today();
        cma.EndDate = system.today().addDays(+1);
        cma.Campaign_Start_DateTime__c = system.now();
        cma.Campaign_End_DateTime__c = system.now().addDays(+1);
        cma.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Promo').getRecordTypeId();
        insert cma;
        
        Campaign camp = new Campaign();
        camp.Name = 'TestNameCampaign';
        camp.Country__c = 'Singapore';
        camp.IsActive = false;
        camp.StartDate = system.today().addDays(+1);
        camp.EndDate = system.today().addDays(+2);
        camp.Campaign_Start_DateTime__c = system.now().addDays(+1);
        camp.Campaign_End_DateTime__c = system.now().addDays(+2);
        camp.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('Marketing Promo').getRecordTypeId();
        insert camp;
        
        Test.startTest();
        ActiveInactiveCampController.getCampInfo(cma.Id);
        ActiveInactiveCampController.getCampInfo(camp.Id);
        ActiveInactiveCampController.getResponse(JSON.serialize(cma));
        ActiveInactiveCampController.getResponse(JSON.serialize(camp));
        Test.stopTest();
    }
}