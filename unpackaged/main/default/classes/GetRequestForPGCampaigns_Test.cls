@isTest
public class GetRequestForPGCampaigns_Test {
    
    @isTest
    static void runTest1(){
        
        user runUser = [Select Id,Name from user where Id =: userinfo.getUserId()];
        Subsidiary__c sub = PGTestDataFactory_v2.createSubsidiary(RunUser);
          Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = false;
        insert TE;
          Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'PGCampaignEligibilityTrigger';
        TE2.Enable_del__c = false;
        insert TE2;
         Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = false;
        insert TEPromoMech;
          Trigger_Execute__c TEEntPromo = new Trigger_Execute__c();
        TEEntPromo.Name = 'PGEntitlementPromoTrigger';
        TEEntPromo.Enable_del__c = false;
        insert TEEntPromo;
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        Contact con = PGTestDataFactory_v2.createContact('FirstName','LastName','test@mail.com');
        CampaignMember cmp = PGTestDataFactory_v2.CreateCampaignMember(con.Id, cma.Id);
        Campaign_Eligibility__c ce = PGTestDataFactory_v2.CreateCampaignEligibility(cma.Id);
        insert ce;
        
        Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
        Product_Class__c productClass = PGTestDataFactory_v2.CreateProductClass('Prod Class Name',sub);
        Product2 prod = PGTestDataFactory_v2.CreateProduct('ProdName', 'B2C Only', 'Discretionary', 'SKU', productClass, taxcode);
        insert prod;
        
        Promo_Mechanic__c prm = PGTestDataFactory_v2.CreatePromoMechanic(prod.Id,ce.Id);
        
        Entitlement_Promotion__c ep = PGTestDataFactory_v2.CreateEntitlementPromotion(prm.Id);
        
        //unable to insert custom setting due to null RecordTypeId
        CamMemberStatusValue__c setting = new CamMemberStatusValue__c();
        setting.Name = 'null';
        setting.Values__c = cma.RecordTypeId;
        insert setting;
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/getactivecampaigns/'+cma.Id;
        req.httpMethod = 'GET';
                
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        GetRequestForPGCampaigns.getCampaignAndRelatedDetails();
        Test.stopTest();
    }
    @isTest
    static void runTest2(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/getactivecampaigns/';
        req.httpMethod = 'GET';
                
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        GetRequestForPGCampaigns.getCampaignAndRelatedDetails();
        Test.stopTest();
    }
    @isTest
    static void runTest3(){
        
        Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        cma.IsActive = false;
        update cma;
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/getactivecampaigns/'+cma.Id;
        req.httpMethod = 'GET';
                
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        GetRequestForPGCampaigns.getCampaignAndRelatedDetails();
        Test.stopTest();
    }
    
    //case to cover empty camplist
    @isTest
    static void runTest4(){
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/getactivecampaigns/null';
        req.httpMethod = 'GET';
                
        RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        GetRequestForPGCampaigns.getCampaignAndRelatedDetails();
        Test.stopTest();
    }
    
    
    // case to cover various if else
    @isTest
    static void runTest5(){
        
        user runUser = [Select Id,Name from user where Id =: userinfo.getUserId()];
        Subsidiary__c sub = PGTestDataFactory_v2.createSubsidiary(RunUser);
          Trigger_Execute__c TE = new Trigger_Execute__c();
        TE.Name = 'PGCampMemberTrigger';
        TE.Enable_del__c = false;
        insert TE;
         Trigger_Execute__c TE2 = new Trigger_Execute__c();
        TE2.Name = 'PGCampaignEligibilityTrigger';
        TE2.Enable_del__c = false;
        insert TE2;
         Trigger_Execute__c TEPromoMech = new Trigger_Execute__c();
        TEPromoMech.Name = 'PGPromoMechanicTrigger';
        TEPromoMech.Enable_del__c = false;
        insert TEPromoMech;
          Trigger_Execute__c TEEntPromo = new Trigger_Execute__c();
        TEEntPromo.Name = 'PGEntitlementPromoTrigger';
        TEEntPromo.Enable_del__c = false;
        insert TEEntPromo;
        //Campaign cma = PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        // need some specific data and campaign cannot be updated as well thus creating required data here only
        Campaign cma = new Campaign();
        cma.Name = 'Test Campaign';
        cma.IsActive = true;
        cma.StartDate = System.today();
        cma.EndDate = null;
        cma.Country__c = '';
        cma.Type = null;
        cma.Coupon_code__c = 'Not Null';
        cma.PG_Campaign_Id__c = 'Not Null';
        cma.Theme__c ='Test';
        insert cma; 
        
        Contact con = PGTestDataFactory_v2.createContact('FirstName','LastName','test@mail.com');
        CampaignMember cmp = PGTestDataFactory_v2.CreateCampaignMember(con.Id, cma.Id);
        //Campaign_Eligibility__c ce = PGTestDataFactory_v2.CreateCampaignEligibility(cma.Id);
        Campaign_Eligibility__c ce = new Campaign_Eligibility__c(status__c='',Next_run_scheduled__c=null,Run_Frequency__c='',Name='Test Camapign',Rule_Name_Extension__c='Select Id From Contact where Account.RecordType.developerName = \'Agency\'',Criteria_Type__c = '',Priority__c=1,Campaign__c = cma.Id);
        insert ce;
        Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
        Product_Class__c productClass = PGTestDataFactory_v2.CreateProductClass('Prod Class Name',sub);
        Product2 prod = PGTestDataFactory_v2.CreateProduct('ProdName', 'B2C Only', 'Discretionary', 'SKU', productClass, taxcode);
        insert prod;
        
        //Promo_Mechanic__c prm = PGTestDataFactory_v2.CreatePromoMechanic(prod.Id,ce.Id);
        Promo_Mechanic__c prm = new Promo_Mechanic__c();
        prm.Name = '';
        prm.Status__c ='Active';
        prm.Eligible_Product__c = prod.Id;
        prm.Campaign_Eligibility__c = ce.Id;
        prm.Usage__c = 1;
        prm.Min_Qty__c = 1;
        prm.Max_Qty__c = 1;
        prm.Denomination__c = 100;
        prm.Minimum_Spend__c = 10;
        prm.Renewal_Type__c='Upgrade';
        prm.Discount_Reason__c = 'Others';
        prm.Opportunity_Type__c = 'B2C - Standard';
        //prm.eCommerceCatalogueProductReference__c = 
        insert prm;
        
        
        Entitlement_Promotion__c ep = PGTestDataFactory_v2.CreateEntitlementPromotion(prm.Id);
        
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/api/pgcampaign/getactivecampaigns/'+cma.Id;
        req.httpMethod = 'GET';
                
        RestContext.request = req;
        RestContext.response= res;
        
        
        Test.startTest();
        GetRequestForPGCampaigns.getCampaignAndRelatedDetails();
        Test.stopTest();
    }
}