@isTest
public class PGCampaignTrigger_Test {
    
    @isTest
    static void PGCampaignTriggerMethod(){
        
        CamMemberStatusValue__c cms = new CamMemberStatusValue__c();
        cms.Name = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('B2B Developer Online Form').getRecordTypeId();
        cms.Values__c = 'Test';
        insert cms;
		
        Campaign cm = new Campaign();
        cm.Name = 'TestCampaign';
        cm.IsActive = true;
        cm.Source_Campaign_Reference__c='camp1';
        cm.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('B2B Developer Online Form').getRecordTypeId();
        cm.EndDate = system.today().addDays(-2);
        insert cm;
		      
        Campaign cm1 = new Campaign();
        cm1.Name = 'TestCampaign1';
        cm1.IsActive = true;
        cm1.Source_Campaign_Reference__c='camp1';
        //cm1.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('B2B Developer Online Form').getRecordTypeId();
        cm1.EndDate = system.today().addDays(-2);
        insert cm1;
       
        
        Test.startTest();
        List<CampaignMemberStatus> CampaignMemberStatusList = [select Id from CampaignMemberStatus where CampaignId = : cm.Id];
        system.assert(CampaignMemberStatusList.size() != null);
        system.debug('CampaignMemberStatusList$$$$ '+CampaignMemberStatusList);
        Test.stopTest();
    }
    @isTest
    static void PGCampaignTriggerMethod_ErrorCase(){
        
        Campaign cm = new Campaign();
        cm.Name = 'TestCampaign';
        cm.IsActive = true;
        cm.Source_Campaign_Reference__c='camp1';
        cm.RecordTypeId =Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('B2B Developer Online Form').getRecordTypeId();
        cm.EndDate = system.today().addDays(-2);
        insert cm;
		      
        Campaign cm1 = new Campaign();
        cm1.Name = 'TestCampaign1';
        cm1.IsActive = true;
        cm1.Source_Campaign_Reference__c='camp1';
        cm1.RecordTypeId = Schema.SObjectType.Campaign.getRecordTypeInfosByName().get('B2B Developer Online Form').getRecordTypeId();
        cm1.EndDate = system.today().addDays(-2);
        
        Test.startTest();
        try{
        insert cm1;
        }
        catch(exception ex){
            Boolean expectedExceptionThrown =  ex.getMessage().contains('Campaign with same Source Campaign Reference already Activated.') ? true : false;
   			System.assertEquals(expectedExceptionThrown, true);
        }
        Test.stopTest();
    }
    
    public static testmethod void afterUpdateTest() {
        
        Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampaignEligibilityTrigger';
        TE.Enable_del__c = true;
        insert TE;
        
        Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = true;
        insert TEPromoMech;
        
        Trigger_Execute__c TEEntPromo = new Trigger_Execute__c();
        TEEntPromo.Name = 'PGEntitlementPromoTrigger';
        TEEntPromo.Enable_del__c = true;
        insert TEEntPromo;
        
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
        
        Entitlement_Promotion__c entPromo1 = new Entitlement_Promotion__c();
        entPromo1.Name = 'Test EntPromo1';
        entPromo1.Promo_Mechanic__c = promoMech.Id;
        entPromo1.Discount__c = 10;
        insert entPromo1;
     
        camp.IsActive = false;
        camp.Country__c = 'Thailand';
        camp.CurrencyIsoCode = 'THB';
        update camp;
        Test.stopTest();
    }
}