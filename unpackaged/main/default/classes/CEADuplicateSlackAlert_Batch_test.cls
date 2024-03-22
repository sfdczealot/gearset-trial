@isTest
public class CEADuplicateSlackAlert_Batch_test {
    
    @isTest
    public static void executeBatchTest(){
        List<Account> accList = new List<Account>();
        PGTestDataFactory_v2.initSetupData();
        string Rectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        for(integer i=0;i< 2;i++){
            accList.add(new account( FirstName = 'test',
                                    LastName = 'ABC '+ i,
                                    CEA_Salesperson_Number__c = '1234',
                                    PersonEmail = 'test@gmail.com',
                                    personBirthdate= system.today(),
                                    Salutation = 'Ms.',
                                    recordtypeid=RecType,AgentNet_ID__c = 'AgentNet_ID__c test',
                                    CurrencyIsoCode = 'SGD',
                                    Subscription_Start_Date__c = system.today().addMonths(-10),
                                    BillingStreet = 'test',
                                    BillingCity = 'test',
                                    BillingCountry = 'Singapore',
                                    BillingPostalCode = '8373',
                                    //BillingState = 'test',
                                    Current_Subscription_Code__c = 'abc',
                                    
                                    Account_Rule_Code__c = 'test',
                                    Previous_Account_Rule__c = 'test',
                                    Status__c = 'Active',
                                    Country__c = 'Singapore',
                                    Subscription_End_Date__c = system.today().addMonths(-9),
                                    Loyalty_Start_Date__c = system.today().addMonths(-1),
                                    Is_Qualify_Agent_Referral_Program__c = true));
        }
        insert accList;
     
        test.startTest();
     System.schedule('Job from test class 5', '0 0 0 * * ? *', new CEADuplicateSlackAlert_BatchSchedulable());
       // database.executeBatch(new CEADuplicateSlackAlert_BatchSchedulable());
      //  CEADuplicateSlackAlert_BatchSchedulable.execute(sc);
        Test.stopTest();
    }
}