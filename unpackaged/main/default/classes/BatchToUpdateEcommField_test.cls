@isTest
public class BatchToUpdateEcommField_test {
  static testmethod void test() {
        // Create test accounts to be updated by batch
          Opportunity opp = null;
        Account acc_b2c  = null;
        Account acc_b2b  = null;
        // Avoid mixed DML
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
             Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            //data setup
         acc_b2c = PGTestDataFactory_v2.createB2CAccount('email@test.com', '1234', thisUser, sb);
         
         }

        Test.startTest();

        Database.executeBatch(new BatchToUpdateEcommField());
        Test.stopTest();
        // Verify accounts updated
   
    }
}