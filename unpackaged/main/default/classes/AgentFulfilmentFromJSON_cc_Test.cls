/*
 * Created by : Yuni
 * Company    : Viseo Asia PTE LTD
 * created Date : 27/07/2018
 */
@isTest
public class AgentFulfilmentFromJSON_cc_Test {
    private static final String FIRST_NAME='TestAgent';
    private static final String LAST_NAME='Account';
    private static final String TEST_USER_PROFILE_NAME='System Administrator';
    private static final String AGENT_MOBILE_NUMBER='3423422';
    private static final String TEST_USER_NAME=FIRST_NAME+'.'+LAST_NAME+'@'+UserInfo.getOrganizationId()+'.com';
    
    @testSetup
    static void setup(){
        Profile p=[select id from Profile where Name=:TEST_USER_PROFILE_NAME];
        
        //Standard Profile User
        User testUser=PGTestDataFactory_v2.createUser(p.Id,FIRST_NAME,LAST_NAME);
        testUser.Country=Label.SINGAPORE_REGION;
        insert testUser;
    }
    static testMethod void runTest() {
        User objUser= [select id,Country from User where UserName=:TEST_USER_NAME ];
        System.runAs(objUser){
            Test.StartTest();
            PGTestDataFactory_v2.CreateTriggerExecuteCS('PGAccountTrigger',true);
            string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();        
            Account a = new Account();
            a.ownerId=objUser.id;
            a.RecordTypeId = accRectype;
            a.LastName = 'TestYuni';
            a.salutation = 'Mr.';
            a.FirstName = 'abc';
            a.CurrencyIsoCode = 'SGD';
            a.Subscription_Start_Date__c = system.today().addMonths(-10);
            a.BillingStreet = 'test';
            a.BillingCity = 'test';
            a.BillingCountry = objUser.Country;
            a.BillingPostalCode = '8373';
            a.Mobile_Country__c = AGENT_MOBILE_NUMBER;
            a.Current_Subscription_Code__c = 'abc';
            a.Account_Rule_Code__c = 'test';
            a.AgentNet_ID__c = '123';
            a.PersonEmail = '12121assas@yahoo.com';
            a.PersonBirthdate = system.today();
            a.CEA_Salesperson_Number__c = 'R062100G';
            insert a;
            
            AgentFulfilmentFromJSON_cc.JsonTmp js = new AgentFulfilmentFromJSON_cc.JsonTmp();
            js.Name = '';
            js.Status = '';
            js.BalanceQuantity = 0;
            js.EndDate = System.today();
            js.SequenceNumber = 1;
            js.StartDate = System.today();
            js.IsGrouping = false;
            js.PurchasedQuantity = '1000';

            AgentFulfilmentFromJSON_cc.getAgentFulfilment(a.Id,false);
            
            Test.stopTest();
        }
    }
}