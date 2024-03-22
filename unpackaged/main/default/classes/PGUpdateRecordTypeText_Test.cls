@isTest
public class PGUpdateRecordTypeText_Test {

     static testMethod void mainTest(){ 
        Account acc_b2c  = null, acc_b2c_null = new Account();
        // Avoid mixed DML
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            acc_b2c = PGTestDataFactory_v2.createB2CAccount('test@test.com','1232134', thisUser, sb);
            acc_b2c.Record_Type_Text__c = 'New';
            Update acc_b2c;
        }
        Test.startTest();
        	Database.executeBatch(new PGUpdateRecordTypeText(),2000);
        Test.stopTest();
    }
}