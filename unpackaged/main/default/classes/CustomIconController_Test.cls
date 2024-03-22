@isTest
public class CustomIconController_Test {
    
    @isTest
    static void runTest(){ 
        
        PGTestDataFactory_v2.initSetupData();
        User runningUser = [Select id, Subsidiary__c From user where id =: UserInfo.getUserId() LIMIT 1];
        Subsidiary__c subsidiary = PGTestDataFactory_v2.createSubsidiary(runningUser);
        Account account = PGTestDataFactory_v2.createB2CAccount('test@mail.com','agentnetId',runningUser,subsidiary);
        
        Test.startTest();
        CustomIconController.getCountryAndTier(account.Id); 
        Test.stopTest();
    }
    
}