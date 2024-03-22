@isTest
public class BillingScheduleUpdate_Test {

    @isTest
    public static void unitTest1(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=true;
        insert oppTrigger;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        Test.startTest();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        //  opp.Subsidiary__c = sb1.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = b2boppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c   = 'Contract - Renewal';
        opp.Opportunity_Type__c='B2C - Renewal';
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = 'Bill by item';
        insert so;
        
        
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Test Product';
        pro.cscfga__Quantity__c = 34556;
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
        testFulfilmentItem.Status_Manual_Tracking__c = 'Delivering';
        insert testFulfilmentItem;
        
        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = so.Id;
		insert salesOrderSchedule;

		CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
		bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert bs;
        
        CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
		bsItem.Sales_Order__c = so.Id;
	//	bsItem.Product_Configuration__c = prodConfig.Id;
		bsItem.Billing_Schedule__c = bs.Id;
		bsItem.Status__c = 'Forecast';
        bsItem.Fulfilment_Item__c = testFulfilmentItem.id;
		insert bsItem;
        
        list<String> IdList = new list<String>();
        IdList.add(testFulfilmentItem.Id);
        
        BillingScheduleUpdate.updateSchedules(IdList);
        try{
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        }catch(exception e){}
        Test.stopTest();
        
    }
    
    @isTest
    public static void unittest2(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=true;
        insert oppTrigger;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        Test.startTest();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        //  opp.Subsidiary__c = sb1.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = b2boppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c   = 'Contract - Renewal';
        opp.Opportunity_Type__c='B2C - Renewal';
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = 'Full bill upon delivery';
        insert so;
        
        
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Test Product';
        pro.cscfga__Quantity__c = 34556;
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
        testFulfilmentItem.Status_Manual_Tracking__c = 'Delivering';
        insert testFulfilmentItem;
        
        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = so.Id;
		insert salesOrderSchedule;

		CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
		bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert bs;
        
        CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
		bsItem.Sales_Order__c = so.Id;
	//	bsItem.Product_Configuration__c = prodConfig.Id;
		bsItem.Billing_Schedule__c = bs.Id;
		bsItem.Status__c = 'Forecast';
        bsItem.Fulfilment_Item__c = testFulfilmentItem.id;
		insert bsItem;
        
        list<String> IdList = new list<String>();
        IdList.add(testFulfilmentItem.Id);
        
        BillingScheduleUpdate.updateSchedules(IdList);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.stopTest();
        
    }
    
    @isTest
    public static void unittest3(){
        
        Trigger_Execute__c customsetting=new Trigger_Execute__c();
        customsetting.Name='PGAccountTrigger';
        customsetting.Enable_del__c=true;
        insert customsetting;
        
        Trigger_Execute__c oppTrigger = new Trigger_Execute__c();
        oppTrigger.Name='PGOpportunityTrigger';
        oppTrigger.Enable_del__c=true;
        insert oppTrigger;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        string b2boppRectype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        
        Account acc = new Account();
        acc.Name = 'Acc Dunning';
        acc.Country__c = 'Malaysia';
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        Test.startTest();
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = acc.id;
        opp.CloseDate = system.today().AddDays(30);
        //  opp.Subsidiary__c = sb1.id;
        opp.Total_Spending__c = 100;
        opp.RecordTypeId = b2boppRectype;
        opp.PG_Tenure__c = 1;
        opp.count_of_subscription_item_new__c = 100.0;
        opp.Order_Type_Clone__c   = 'Contract - Renewal';
        opp.Opportunity_Type__c='B2C - Renewal';
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
        so.csmso__Advertiser__c = acc.Id;
        so.csmso__Status__c = 'Delivered';
        so.csmso__Opportunity__c = opp.Id;
        so.Primary_Sales_Order__c = true;
        so.Advertiser_Final__c = acc.Id;
        so.Billing_schedule__c = '3 Months';
        insert so;
        
        
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = acc.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Test Product';
        pro.cscfga__Quantity__c = 34556;
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
        testFulfilmentItem.Status_Manual_Tracking__c = 'Delivering';
        insert testFulfilmentItem;
        
        CS_Sales_Order_Schedule__c salesOrderSchedule = new CS_Sales_Order_Schedule__c();
		salesOrderSchedule.Sales_Order__c = so.Id;
		insert salesOrderSchedule;

		CS_Billing_Schedule__c bs = new CS_Billing_Schedule__c();
		bs.CS_Sales_Order_Schedule__c = salesOrderSchedule.Id;
		insert bs;
        
        CS_Billing_Schedule_Item__c bsItem = new CS_Billing_Schedule_Item__c();
		bsItem.Sales_Order__c = so.Id;
	//	bsItem.Product_Configuration__c = prodConfig.Id;
		bsItem.Billing_Schedule__c = bs.Id;
		bsItem.Status__c = 'Forecast';
      //  bsItem.Fulfilment_Item__c = testFulfilmentItem.id;
		insert bsItem;
        
        list<String> IdList = new list<String>();
        IdList.add(testFulfilmentItem.Id);
        
        BillingScheduleUpdate.updateSchedules(IdList);
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        Test.stopTest();
        
    }
}