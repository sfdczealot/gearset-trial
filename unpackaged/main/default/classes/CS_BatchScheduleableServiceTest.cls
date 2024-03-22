/**
 * Created by jameshladek on 2/18/20.
 */

@isTest
public with sharing class CS_BatchScheduleableServiceTest {

    @testSetup static void dataSetup(){
        Account acct = TestDataSetupSO.createAccount();
        ACCT.recordtypeid = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId(); 
        insert acct;
        Contact testCon = TestDataSetupSO.createContact(acct);
        insert testCon;
        Opportunity testOpp = TestDataSetupSO.createOpportunity(acct, testCon);
        testOpp.recordtypeid=Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId();  
        insert testOpp;
        csmso__Sales_Order__c salesOrder = TestDataSetupSO.createSalesOrder(acct, testOpp);
        salesOrder.Advertiser_Final__c = acct.id;
        insert salesOrder;
        cscfga__Product_Configuration__c config = TestDataSetupSO.createproductConfigAndDef('Test config');
        config.Sales_Order__c = salesOrder.id;
        update config;

    }

    @isTest static void test1(){
        csmso__Sales_Order__c testSO = [SELECT Id FROM csmso__Sales_Order__c];

        Test.startTest();
        CS_BatchScheduleableService batch = new CS_BatchScheduleableService(testSO.id);
        Database.executeBatch(batch);
        Test.stopTest();
    }

}