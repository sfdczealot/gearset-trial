@isTest
public class BillingScheduleSO_Test {

    @testSetup
    public static void testData(){
        Subsidiary__c sb = new Subsidiary__c();
        sb.Name = 'iProperty.com Malaysia Sdn Bhd';
        sb.NS_Subsidiary_Internal_ID__c = '1';
        sb.CurrencyIsoCode = 'MYR';
        sb.Tax_Label__c = 'taxLabel';
        sb.Country__c = 'Malaysia';
        sb.Subsidiary_Code__c = 'iPP';
        sb.Logo_url__c='https://c.ap5.visual.force.com/resource/1525687701000/SG_Sales_Order_Header_v3_PGG';
        insert sb;
         Subsidiary__c sb1 = new Subsidiary__c();
        sb1.Name = 'PropertyGuru International (Malaysia) Sdn Bhd';
        sb1.NS_Subsidiary_Internal_ID__c = '2';
        sb1.CurrencyIsoCode = 'MYR';
        sb1.Tax_Label__c = 'taxLabel';
        sb1.Country__c = 'Malaysia';
        sb1.Subsidiary_Code__c = 'iPP';
        sb1.Logo_url__c='https://google.com';
        insert sb1;
        
        Subsidiary__c sb2 = new Subsidiary__c();
        sb2.Name = 'PropertyGuru Pte Ltd';
        sb2.NS_Subsidiary_Internal_ID__c = '3';
        sb2.CurrencyIsoCode = 'SGD';
        sb2.Tax_Label__c = 'taxLabel';
        sb2.Country__c = 'Singapore';
        sb2.Logo_url__c='https://facebook.com';
        insert sb2;
        
    }
    @isTest
    public static void unitTest(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=false;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=false;
        insert oppTrigger;
        
        Trigger_Execute__c oppTrigger1 = new Trigger_Execute__c();
        oppTrigger1.Name='Trigger_OpportunitySplit';
        oppTrigger1.Enable_del__c=false;
        insert oppTrigger1;
        
        
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        subsidiary__c sb = [select id from subsidiary__c where name='iProperty.com Malaysia Sdn Bhd' limit 1];
        Test.startTest();
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Oppo PgToiPP';
        opp1.StageName = 'Prospecting';
        opp1.AccountId = acc.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.RecordTypeId = b2boppRectype;
        opp1.Subsidiary_Type__c = '	iPP';
        opp1.Product_Category__c = 'Awards';
        opp1.Subsidiary_Type__c = 'iPP';
        opp1.Subsidiary__c = sb.Id;
        insert opp1;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp1.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = 'Full bill upon delivery';
        so.csmso__From__c = system.today();
        insert so;
        
        
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Test Product';
        pro.cscfga__Quantity__c = 34556;
        pro.cscfga__package_guid__c = 'package guid';
        pro.cscfga__Total_Price__c = 500;
       
        insert pro;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
		testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.Id;
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Name__c = 'testful';
		testFulfilmentItem.csdf__Availability_Check_Total_Amount__c = 1;
		testFulfilmentItem.csdf__Quantity__c = 20;
		testFulfilmentItem.csdf__Billing_Category__c = 'CPM';
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Quantity__c = 10;
        testFulfilmentItem.Product_Configuration__c = pro.Id;
        testFulfilmentItem.Insertion_Quantity__c = 2;
        insert testFulfilmentItem;
        
         
        CSPOFA__Orchestration_Process_Template__c temp = new CSPOFA__Orchestration_Process_Template__c();
        temp.Name = 'temp';
        insert temp;
        
        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Name = 'Approval Check';
        testProcess.CSPOFA__Orchestration_Process_Template__c = temp.Id;
        testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.Name = 'step';
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;
        
        list<CSPOFA__Orchestration_Step__c> steplist = [Select id,Name,Sales_Order__c,CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.Sales_Order__c From CSPOFA__Orchestration_Step__c];
       // steplist.add(testOrchestrationStep);
        
        BillingScheduleSO bs = new BillingScheduleSO();
        bs.performCallouts(steplist);
        
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest1(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=false;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=false;
        insert oppTrigger;
        
        Trigger_Execute__c oppTrigger1 = new Trigger_Execute__c();
        oppTrigger1.Name='Trigger_OpportunitySplit';
        oppTrigger1.Enable_del__c=false;
        insert oppTrigger1;
        
        
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        
        Test.startTest();
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Oppo PgToiPP';
        opp1.StageName = 'Prospecting';
        opp1.AccountId = acc.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.RecordTypeId = b2boppRectype;
        //opp1.Subsidiary_Type__c = '	iPP';
        opp1.Product_Category__c = 'Awards';
        opp1.Subsidiary_Type__c = 'iPP';
        //opp1.Subsidiary__c = sb.Id;
        insert opp1;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp1.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = 'Bill by item';
        so.csmso__From__c = system.today();
        insert so;
        
       
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Test Product';
        pro.cscfga__Quantity__c = 34556;
        pro.cscfga__package_guid__c = 'package guid';
        pro.cscfga__Total_Price__c = 500;
       
        insert pro;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
		testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.Id;
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Name__c = 'testful';
		testFulfilmentItem.csdf__Availability_Check_Total_Amount__c = 1;
		testFulfilmentItem.csdf__Quantity__c = 20;
		testFulfilmentItem.csdf__Billing_Category__c = 'CPM';
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Quantity__c = 10;
        testFulfilmentItem.Product_Configuration__c = pro.Id;
        testFulfilmentItem.Insertion_Quantity__c = 2;
        insert testFulfilmentItem;
        
         
        CSPOFA__Orchestration_Process_Template__c temp = new CSPOFA__Orchestration_Process_Template__c();
        temp.Name = 'temp';
        insert temp;
        
        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Name = 'Approval Check';
        testProcess.CSPOFA__Orchestration_Process_Template__c = temp.Id;
        testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.Name = 'step';
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;
        
        list<CSPOFA__Orchestration_Step__c> steplist = [Select id,Name,Sales_Order__c,CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.Sales_Order__c From CSPOFA__Orchestration_Step__c];
       // steplist.add(testOrchestrationStep);
        
        BillingScheduleSO bs = new BillingScheduleSO();
        bs.performCallouts(steplist);
        
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest2(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=false;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=false;
        insert oppTrigger;
        
        Trigger_Execute__c oppTrigger1 = new Trigger_Execute__c();
        oppTrigger1.Name='Trigger_OpportunitySplit';
        oppTrigger1.Enable_del__c=false;
        insert oppTrigger1;
        
        
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        
        Test.startTest();
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Oppo PgToiPP';
        opp1.StageName = 'Prospecting';
        opp1.AccountId = acc.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.RecordTypeId = b2boppRectype;
        //opp1.Subsidiary_Type__c = '	iPP';
        opp1.Product_Category__c = 'Awards';
        opp1.Subsidiary_Type__c = 'iPP';
        //opp1.Subsidiary__c = sb.Id;
        insert opp1;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp1.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = '3 months';
        so.csmso__From__c = system.today();
        insert so;
        
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Test Product';
        pro.cscfga__Quantity__c = 34556;
        pro.cscfga__package_guid__c = 'package guid';
        pro.cscfga__Total_Price__c = 500;
       
        insert pro;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
		testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.Id;
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Name__c = 'testful';
		testFulfilmentItem.csdf__Availability_Check_Total_Amount__c = 1;
		testFulfilmentItem.csdf__Quantity__c = 20;
		testFulfilmentItem.csdf__Billing_Category__c = 'CPM';
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Quantity__c = 10;
        testFulfilmentItem.Product_Configuration__c = pro.Id;
        testFulfilmentItem.Insertion_Quantity__c = 2;
        insert testFulfilmentItem;
        
         
        CSPOFA__Orchestration_Process_Template__c temp = new CSPOFA__Orchestration_Process_Template__c();
        temp.Name = 'temp';
        insert temp;
        
        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Name = 'Approval Check';
        testProcess.CSPOFA__Orchestration_Process_Template__c = temp.Id;
        testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.Name = 'step';
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;
        
        list<CSPOFA__Orchestration_Step__c> steplist = [Select id,Name,Sales_Order__c,CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.Sales_Order__c From CSPOFA__Orchestration_Step__c];
       // steplist.add(testOrchestrationStep);
        
        BillingScheduleSO bs = new BillingScheduleSO();
        bs.performCallouts(steplist);
        
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest3(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=false;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=false;
        insert oppTrigger;
        
        Trigger_Execute__c oppTrigger1 = new Trigger_Execute__c();
        oppTrigger1.Name='Trigger_OpportunitySplit';
        oppTrigger1.Enable_del__c=false;
        insert oppTrigger1;
        
        
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        
        Test.startTest();
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Oppo PgToiPP';
        opp1.StageName = 'Prospecting';
        opp1.AccountId = acc.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.RecordTypeId = b2boppRectype;
        //opp1.Subsidiary_Type__c = '	iPP';
        opp1.Product_Category__c = 'Awards';
        opp1.Subsidiary_Type__c = 'iPP';
        //opp1.Subsidiary__c = sb.Id;
        insert opp1;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp1.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = '6 months';
        so.csmso__From__c = system.today();
        insert so;
        
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Test Product';
        pro.cscfga__Quantity__c = 34556;
        pro.cscfga__package_guid__c = 'package guid';
        pro.cscfga__Total_Price__c = 500;
       
        insert pro;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
		testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.Id;
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Name__c = 'testful';
		testFulfilmentItem.csdf__Availability_Check_Total_Amount__c = 1;
		testFulfilmentItem.csdf__Quantity__c = 20;
		testFulfilmentItem.csdf__Billing_Category__c = 'CPM';
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Quantity__c = 10;
        testFulfilmentItem.Product_Configuration__c = pro.Id;
        testFulfilmentItem.Insertion_Quantity__c = 2;
        insert testFulfilmentItem;
        
         
        CSPOFA__Orchestration_Process_Template__c temp = new CSPOFA__Orchestration_Process_Template__c();
        temp.Name = 'temp';
        insert temp;
        
        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Name = 'Approval Check';
        testProcess.CSPOFA__Orchestration_Process_Template__c = temp.Id;
        testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.Name = 'step';
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;
        
        list<CSPOFA__Orchestration_Step__c> steplist = [Select id,Name,Sales_Order__c,CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.Sales_Order__c From CSPOFA__Orchestration_Step__c];
       // steplist.add(testOrchestrationStep);
        
        BillingScheduleSO bs = new BillingScheduleSO();
        bs.performCallouts(steplist);
        
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest4(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=false;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=false;
        insert oppTrigger;
        
        Trigger_Execute__c oppTrigger1 = new Trigger_Execute__c();
        oppTrigger1.Name='Trigger_OpportunitySplit';
        oppTrigger1.Enable_del__c=false;
        insert oppTrigger1;
        
        
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        
        Test.startTest();
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Oppo PgToiPP';
        opp1.StageName = 'Prospecting';
        opp1.AccountId = acc.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.RecordTypeId = b2boppRectype;
        //opp1.Subsidiary_Type__c = '	iPP';
        opp1.Product_Category__c = 'Awards';
        opp1.Subsidiary_Type__c = 'iPP';
        //opp1.Subsidiary__c = sb.Id;
        insert opp1;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp1.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = '12 months';
        so.csmso__From__c = system.today();
        insert so;
       
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Test Product';
        pro.cscfga__Quantity__c = 34556;
        pro.cscfga__package_guid__c = 'package guid';
        pro.cscfga__Total_Price__c = 500;
       
        insert pro;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
		testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.Id;
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Name__c = 'testful';
		testFulfilmentItem.csdf__Availability_Check_Total_Amount__c = 1;
		testFulfilmentItem.csdf__Quantity__c = 20;
		testFulfilmentItem.csdf__Billing_Category__c = 'CPM';
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Quantity__c = 10;
        testFulfilmentItem.Product_Configuration__c = pro.Id;
        testFulfilmentItem.Insertion_Quantity__c = 2;
        insert testFulfilmentItem;
        
         
        CSPOFA__Orchestration_Process_Template__c temp = new CSPOFA__Orchestration_Process_Template__c();
        temp.Name = 'temp';
        insert temp;
        
        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Name = 'Approval Check';
        testProcess.CSPOFA__Orchestration_Process_Template__c = temp.Id;
        testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.Name = 'step';
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;
        
        list<CSPOFA__Orchestration_Step__c> steplist = [Select id,Name,Sales_Order__c,CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.Sales_Order__c From CSPOFA__Orchestration_Step__c];
       // steplist.add(testOrchestrationStep);
        
        BillingScheduleSO bs = new BillingScheduleSO();
        bs.performCallouts(steplist);
        
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest6(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=false;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=false;
        insert oppTrigger;
        
        Trigger_Execute__c oppTrigger1 = new Trigger_Execute__c();
        oppTrigger1.Name='Trigger_OpportunitySplit';
        oppTrigger1.Enable_del__c=false;
        insert oppTrigger1;
        
        
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        
        Test.startTest();
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Oppo PgToiPP';
        opp1.StageName = 'Prospecting';
        opp1.AccountId = acc.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.RecordTypeId = b2boppRectype;
        //opp1.Subsidiary_Type__c = '	iPP';
        opp1.Product_Category__c = 'Awards';
        opp1.Subsidiary_Type__c = 'iPP';
        //opp1.Subsidiary__c = sb.Id;
        insert opp1;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp1.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = 'Full bill upon signing';
        so.csmso__From__c = system.today();
        insert so;
        
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Test Product';
        pro.cscfga__Quantity__c = 34556;
        pro.cscfga__package_guid__c = 'package guid';
        pro.cscfga__Total_Price__c = 500;
       
        insert pro;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
		testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.Id;
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Name__c = 'testful';
		testFulfilmentItem.csdf__Availability_Check_Total_Amount__c = 1;
		testFulfilmentItem.csdf__Quantity__c = 20;
		testFulfilmentItem.csdf__Billing_Category__c = 'CPM';
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Quantity__c = 10;
        testFulfilmentItem.Product_Configuration__c = pro.Id;
        testFulfilmentItem.Insertion_Quantity__c = 2;
        insert testFulfilmentItem;
        
         
        CSPOFA__Orchestration_Process_Template__c temp = new CSPOFA__Orchestration_Process_Template__c();
        temp.Name = 'temp';
        insert temp;
        
        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Name = 'Approval Check';
        testProcess.CSPOFA__Orchestration_Process_Template__c = temp.Id;
        testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.Name = 'step';
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;
        
        list<CSPOFA__Orchestration_Step__c> steplist = [Select id,Name,Sales_Order__c,CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.Sales_Order__c From CSPOFA__Orchestration_Step__c];
       // steplist.add(testOrchestrationStep);
        
        BillingScheduleSO bs = new BillingScheduleSO();
        bs.performCallouts(steplist);
        
        Test.stopTest();
    }
    
    @isTest
    public static void unitTest7(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=false;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=false;
        insert oppTrigger;
        
        Trigger_Execute__c oppTrigger1 = new Trigger_Execute__c();
        oppTrigger1.Name='Trigger_OpportunitySplit';
        oppTrigger1.Enable_del__c=false;
        insert oppTrigger1;
        
        
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        
        Test.startTest();
        Opportunity opp1 = new opportunity();
        opp1.Name = 'Oppo PgToiPP';
        opp1.StageName = 'Prospecting';
        opp1.AccountId = acc.id;
        opp1.CloseDate = system.today().AddDays(30);
        opp1.RecordTypeId = b2boppRectype;
        //opp1.Subsidiary_Type__c = '	iPP';
        opp1.Product_Category__c = 'Awards';
        opp1.Subsidiary_Type__c = 'iPP';
        //opp1.Subsidiary__c = sb.Id;
        insert opp1;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp1.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = 'Full bill upon delivery';
        so.csmso__From__c = system.today();
        insert so;
       
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Events';
        pro.cscfga__Quantity__c = 34556;
        pro.cscfga__package_guid__c = 'package guid';
        pro.cscfga__Total_Price__c = 500;
       
        insert pro;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = new csdf__Fulfilment_Item__c();
		testFulfilmentItem.csdf__Fulfilment__c = testFulfilment.Id;
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Name__c = 'testful';
		testFulfilmentItem.csdf__Availability_Check_Total_Amount__c = 1;
		testFulfilmentItem.csdf__Quantity__c = 20;
		testFulfilmentItem.csdf__Billing_Category__c = 'CPM';
		testFulfilmentItem.csdf__Flight_Beginning__c = System.now();
		testFulfilmentItem.csdf__Flight_End__c = System.now();
		testFulfilmentItem.csdf__Quantity__c = 10;
        testFulfilmentItem.Product_Configuration__c = pro.Id;
        testFulfilmentItem.Insertion_Quantity__c = 2;
        testFulfilmentItem.csdf__Rate__c = 5;
        
        insert testFulfilmentItem;
        
         
        CSPOFA__Orchestration_Process_Template__c temp = new CSPOFA__Orchestration_Process_Template__c();
        temp.Name = 'temp';
        insert temp;
        
        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
		testProcess.Name = 'Approval Check';
        testProcess.CSPOFA__Orchestration_Process_Template__c = temp.Id;
        testProcess.Sales_Order__c = so.Id;
		insert testProcess;

		CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
        testOrchestrationStep.Name = 'step';
		testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
		insert testOrchestrationStep;
        
        list<CSPOFA__Orchestration_Step__c> steplist = [Select id,Name,Sales_Order__c,CSPOFA__Orchestration_Process__c,CSPOFA__Orchestration_Process__r.Sales_Order__c From CSPOFA__Orchestration_Step__c];
       // steplist.add(testOrchestrationStep);
        
        BillingScheduleSO bs = new BillingScheduleSO();
        bs.performCallouts(steplist);
        
        Test.stopTest();
    }
}