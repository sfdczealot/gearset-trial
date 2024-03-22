@isTest
public class CloneCampaignsController_Test {
    @isTest
    public static void Test1(){
        Product_Class__c productClass = new Product_Class__c(Name = 'Tier1UnitSubNew', CurrencyIsoCode = 'SGD');
        insert productClass;
        
        Tax_code__c taxcd= new Tax_code__c(Active__c =true);
        insert taxcd;
        
        Trigger_Execute__c TECampEligibility = new Trigger_Execute__c();
        TECampEligibility.Name = 'PGCampaignEligibilityTrigger';
        TECampEligibility.Enable_del__c = true;
        insert TECampEligibility;
        
        Product2 prod = new Product2(Name = 'Test ala carte Prod5', CurrencyIsoCode = 'SGD',IsActive = true, Segment__c = 'B2C Only',Can_Be_Sold_Stand_Alone__c=true, Product_Category__c = 'Subscription', SKU_Code__c = 'Test', Product_Class__c = productClass.Id, Tax_Code__c = taxcd.Id,Product_Type__c='PG',Description='DummyText',Is_Bundle__c=true);
        insert prod;
        
        string abc='12345';
        Campaign cma = new Campaign();
        cma.Name = 'TestNameCampaign';
        cma.Country__c = 'Singapore';
        cma.StartDate = system.today().addDays(-2);
        cma.EndDate = system.today().addDays(2);
        cma.IsActive = true;
        insert cma;
        
        Campaign_Eligibility__c cmp1 = new Campaign_Eligibility__c();
        cmp1.Name = 'Test Eligibility';
        cmp1.Campaign__c= cma.id;
        cmp1.Criteria_Type__c = 'SOQL';
        cmp1.Rule_Name_Extension__c = 'Select id from Contact';
        insert cmp1;
        
/*cscfga__Attribute_Group_Template__c agt = new cscfga__Attribute_Group_Template__c ();
        agt.name='test';
        insert agt;
        */
        string demo1= cma.id;
        // List<id> demo = [select id from campaign where id iN: cma.id];
        Map<String , String> childRelatedListObjects = new Map<String , String> ();
        childRelatedListObjects.put('Campaign__c','Campaign_Eligibilities__r');
        childRelatedListObjects.put('Criteria_Type__c','Campaign_Eligibilities__r');
        
        
        Map<Id,sobject> orginialCloned = new Map<Id,sobject>();
        
        test.startTest();
        try{
        CloneCampaignsController.cloneChild('Campaign',orginialCloned,new List<Id>{cma.Id});
        //CloneCampaignsController.fetchUserProfile();
        CloneCampaignsController.cloneChildren(cma,cmp1,childRelatedListObjects,childRelatedListObjects);
        }
        catch(Exception e){
            system.debug('error '+e);
        }
        test.stopTest();
        
        
    }
}