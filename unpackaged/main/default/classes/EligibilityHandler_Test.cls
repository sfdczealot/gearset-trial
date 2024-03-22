@isTest
public class EligibilityHandler_Test {
    public testMethod static void runEligibleTest() {
        CountryCode__c cc = new CountryCode__c();
        cc.Name = 'singapore';
        cc.code__c = 'sg';
        insert cc;
        map<string, string> testCountryCode = EligibilityHandler.getMapCountryCode();
        system.assertEquals(testCountryCode.get('singapore'), 'sg');
        map<string, Country_Attribute__mdt> testMapCountryAtt = EligibilityHandler.getCountryAttribute();
        system.assert(testMapCountryAtt.keySet().contains('Singapore'));
        list<string> testCountryEligibility = EligibilityHandler.getCountryEligibility('AT_PGOpportunityTrigger');
        system.assert(testCountryEligibility.contains('Singapore'));
        
        list<Account> testListAcc = new list<Account>();
        String agentRT = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        Account testAcc = new Account();
        testAcc.Country__c = 'Singapore';
        testAcc.FirstName = 'TestAgentFirst';
        testAcc.LastName = 'TestAgentLast';
        testAcc.RecordTypeId = agentRT;
        testListAcc.add(testAcc);
        EligibilityHandler.assignValue(testListAcc, 'Singapore');
        system.assert(testListAcc[0].Record_Eligibility__c.contains('AT_PGAccountTrigger'));
    }
}