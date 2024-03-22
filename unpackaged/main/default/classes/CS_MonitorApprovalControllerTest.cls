/**
 * Created by jameshladek on 2/20/20.
 */
@isTest
public with sharing class CS_MonitorApprovalControllerTest {

    @isTest static void testAll(){
        Account testAccount = TestDataSetupSO.createAccount();
        insert testAccount;

        Contact testContact = TestDataSetupSO.createContact(testAccount);
        insert testContact;

        Opportunity testOpp = TestDataSetupSO.createOpportunity(testAccount, testContact);
        insert testOpp;

        csmso__Sales_Order__c testSalesOrder = TestDataSetupSO.createSalesOrder(testAccount, testOpp);
        testSalesOrder.Advertiser_Final__c = testAccount.id;
        insert testSalesOrder;

        Test.startTest();
        CS_MonitorApprovalController.findMonitorValues(testSalesOrder.id);
        Test.stopTest();

    }

}