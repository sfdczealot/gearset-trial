@isTest
public class VerifyEligibilityController_Test {
    
    @isTest static void method1(){  
        
        Campaign camp=null;
        Campaign_Eligibility__c campEligibility=null;
        camp= PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        
        campEligibility=PGTestDataFactory_v2.CreateCampaignEligibility(camp.id);
        campEligibility.Criteria_Type__c = 'SOQL';
        campEligibility.Status__c='Active';
        
        insert campEligibility;
        
        String className='test';
        String methodName='test123';
        
        test.startTest();
        try{
            VerifyEligibilityController.validateClassAndMethod(className, methodName);
            VerifyEligibilityController.validationCampaignEligibilityQuery(campEligibility.id);
        }
        catch (Exception e){}
        test.stopTest();
    }
    @isTest static void method2(){  
        Campaign camp=null;
        Campaign_Eligibility__c campEligibility=null;
        camp= PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        campEligibility=PGTestDataFactory_v2.CreateCampaignEligibility(camp.id);
        campEligibility.Criteria_Type__c = 'Apex Method';
        campEligibility.Rule_Name_Extension__c = 'Test;test23';
        campEligibility.Status__c='Active';
        
        insert campEligibility;
        
        String className='test';
        String methodName='test432;';
        
        test.startTest();
        try{
            VerifyEligibilityController.validateClassAndMethod('', '');
            VerifyEligibilityController.validationCampaignEligibilityQuery(campEligibility.id);
        }
        catch(Exception e){}
        test.stopTest();
    }
    
    @isTest static void method3(){  
        
        Campaign camp=null;
        Campaign_Eligibility__c campEligibility=null;
        camp= PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        
        campEligibility=PGTestDataFactory_v2.CreateCampaignEligibility(camp.id);
        campEligibility.Criteria_Type__c = 'SOQL';
        campEligibility.Rule_Name_Extension__c = 'Select id from Contact;';
        campEligibility.Status__c='Active';
        
        insert campEligibility;
        
        String className='test';
        String methodName='test123';
        
        test.startTest();
        try{
            VerifyEligibilityController.validateClassAndMethod(className, methodName);
            VerifyEligibilityController.validationCampaignEligibilityQuery(campEligibility.id);
        }
        catch (Exception e){}
        test.stopTest();
    }
    @isTest static void method4(){  
        
        Campaign camp=null;
        Campaign_Eligibility__c campEligibility=null;
        camp= PGTestDataFactory_v2.CreateCampaign(System.Today().addmonths(1));
        
        campEligibility=PGTestDataFactory_v2.CreateCampaignEligibility(camp.id);
        campEligibility.Criteria_Type__c = ''; 
        campEligibility.Status__c='Active';
        
        insert campEligibility;
        
        String className='test';
        String methodName='test123';
        
        test.startTest();
        try{
            VerifyEligibilityController.validateClassAndMethod(className, methodName);
            VerifyEligibilityController.validationCampaignEligibilityQuery(campEligibility.id);
        }
        catch (Exception e){}
        test.stopTest();
    }
    
}