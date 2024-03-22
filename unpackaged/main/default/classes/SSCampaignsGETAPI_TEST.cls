@isTest
public class SSCampaignsGETAPI_TEST {
    
    @isTest
    public static void test(){
        
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGCampaignEligibilityTrigger',false);
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGPromoMechanicTrigger',false);
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGEntitlementPromoTrigger',false);
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        Campaign_Eligibility__c ce = PGTestDataFactory_v2.CreateCampaignEligibility(cma.Id);
        insert ce;
        Promo_Mechanic__c prm = PGTestDataFactory_v2.CreatePromoMechanic(null,ce.Id);
        Entitlement_Promotion__c ep = PGTestDataFactory_v2.CreateEntitlementPromotion(prm.Id);
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/renewalsscampaign/'+cma.Id;
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        SSCampaignsGETAPI.getDetails();
        Test.stopTest();   
    }
    @isTest
    public static void test1(){
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/renewalsscampaign/';
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        SSCampaignsGETAPI.getDetails();
        Test.stopTest();   
    }
    @isTest
    public static void test2(){
        
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/renewalsscampaign/cmaId';
        req.httpMethod = 'GET';
        
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        SSCampaignsGETAPI.getDetails();
        Test.stopTest();   
    }
}