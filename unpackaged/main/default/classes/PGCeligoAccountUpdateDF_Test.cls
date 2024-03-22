@isTest
class PGCeligoAccountUpdateDF_Test 
{
    static testmethod void test() {
        User thisUser = [SELECT Id,Subsidiary__c FROM User WHERE Id =: UserInfo.getUserId()];
        System.runAs (thisUser) {
            // Call method to insert test records
            PGTestDataFactory_v2.initSetupData();
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            //data setup
            system.debug('DML TestDataFactory');
            Subsidiary__c sb = PGTestDataFactory_v2.createSubsidiary(thisUser);
            Tax_Code__c taxcode = PGTestDataFactory_v2.createSGTaxCode();
            Account a = new Account();
            a.RecordTypeId = PGtUtils.getRecordTypeId('Agent', 'Account', null);
            a.LastName = 'PGAccount';
            a.salutation = 'Mr.';
            a.FirstName = 'abc';
            a.CurrencyIsoCode = 'SGD';
            a.Subscription_Start_Date__c = system.today().addMonths(-10);
            a.BillingStreet = 'test';
            a.BillingCity = 'test';
            a.billingcountryCode='SG';
            a.BillingPostalCode = '83737';
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'STANDARD';
            a.AgentNet_ID__c = '12321';
            a.PersonEmail = 'test@test.com';
            a.Country__c = sb.Country__c;
            a.Mobile_Country__c = '65';
            a.PersonMobilePhone ='9876543210';
            a.et4ae5__Mobile_Country_Code__pc = 'US';   
            a.Status__c = 'Active';
            a.netsuite_conn__Days_Overdue__c = 2;
            if(thisUser!=null){
                a.OwnerId = thisUser.id;
            }
            a.CEA_Salesperson_Number__c = '85638';
            a.PersonBirthdate = system.today();
            insert a;
            
            Test.startTest();
            PGCeligoAccountUpdateDF b = new PGCeligoAccountUpdateDF();
            Database.executeBatch(b);
            Test.stopTest();
            
            
        }
    }
}