@isTest
public class Test_PGPromoMechanicHandler {

    public static testmethod void checkCREDTest() {
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Map<Id,Campaign> mapOfCampIdVsCamp = new Map<Id,Campaign>();
        List<Campaign> campList = new List<Campaign>();
        Campaign camp = new Campaign();
        camp.Name = 'TestCampaign';
        camp.IsActive = false;
        camp.Country__c = 'Singapore';
        camp.CurrencyIsoCode = 'SGD';
        camp.Source_Campaign_Reference__c='camp1';
        camp.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByDeveloperName().get('Marketing_Promo').getRecordTypeId();
        camp.StartDate = system.today();
        camp.Campaign_Start_DateTime__c = system.now();
        camp.Campaign_End_DateTime__c = system.now().addDays(+1);
        camp.EndDate = system.today().addDays(+1);
        insert camp;
        mapOfCampIdVsCamp.put(camp.Id,camp);

        Campaign_Eligibility__c campElig = new Campaign_Eligibility__c();
        campElig.Name = 'Test Elig';
        campElig.CurrencyIsoCode ='SGD';
        campElig.Campaign__c =camp.Id ;
        insert campElig;
        
        Test.startTest();
        camp.IsActive = true;
        update camp;
        
        Promo_Mechanic__c promoMech = new Promo_Mechanic__c();
        promoMech.Name = 'Test PM';
        promoMech.CurrencyIsoCode ='SGD';
        promoMech.Campaign_Eligibility__c =campElig.Id ;
        insert promoMech;
        update promoMech; 
        
        Test.stopTest();
    }
}