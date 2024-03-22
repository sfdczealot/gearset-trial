@isTest
public class SalesOrderEmailActivity_cc_test {
    static testmethod void SOUnitTest(){

        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        Account testAccount = TestDataSetupSO.createAccount();
        testAccount.RecordTypeId = accRectype ;
        insert  testAccount;
        Contact testContact = TestDatasetupSO.createContact(testAccount);
        insert testContact;
        Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
        insert testOpportunity;
        csmso__Sales_Order__c testSO = TestDatasetupSO.createSalesOrder(testAccount, testOpportunity); 
        testSO.SO_Start_Date__c = system.today();
        testSO.SO_End_Date__c=system.today().adddays(34);
       testSO.To_calculated__c = system.today().adddays(34);
       
        insert testSO;
        
    
        Test.startTest();
        SalesOrderEmailActivity_cc So= new SalesOrderEmailActivity_cc();
        So.orderId = testSO.id;        
        So.getsalesOrder();
         list<String> conList = new list<String>();
        conList.add(testContact.id);
        SalesOrderEmailActivity_cc.sendRemMail(testSO.id,conList,null,'English');
        SalesOrderEmailActivity_cc.getDetails(testSO.id);
        SalesOrderEmailActivity_cc.sendTestMail(testSO.id,'English');
        Test.stopTest();
    }
    
}