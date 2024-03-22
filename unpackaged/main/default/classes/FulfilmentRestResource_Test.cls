@isTest
public class FulfilmentRestResource_Test {
    static testMethod void runTest() {
       /* Date startDate = system.today(); 
        Date endDate = system.today().AddDays(30);
        User runUsser = [Select id, Webuser_ID__c From User where id =: UserInfo.getUserId()];
        runUsser.Webuser_ID__c= 1;
        update runUsser;*/
        string resp = '';
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();        
        Account a = new Account();
        a.RecordTypeId = accRectype;
        PGTestDataFactory_v2.initSetupData();
        
        a.Name = 'test Acc';
        a.Customer_Type__c = 'Developer';
    
     
        insert a;
        
        Contact con = new Contact();
        con.LastName = 'test Contact';
        con.AccountId = a.Id;
        con.Email = 'con@gmail.com';
        insert con;
        
        Trigger_Execute__c TEOppSplit = new Trigger_Execute__c();
        TEOppSplit.Name = 'Trigger_OpportunitySplit';
        TEOppSplit.Enable_del__c = true;
        insert TEOppSplit;
        
         Test.StartTest();
        Id recTypeid = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName().get('B2B').getRecordTypeId();
    
        Opportunity opp = new opportunity();
        opp.Name = 'Test Opp';
        opp.StageName = 'Prospecting';
        opp.AccountId = a.id;
        opp.CloseDate = system.today().AddDays(30);
        opp.PG_Tenure__c = 4;
        opp.Total_Spending__c = 100;
        opp.Payment_Time__c = system.now();
        opp.Agent_Accepted_Time__c = system.now();
        opp.Subsidiary__c = PGTestDataFactory.createSubsidiary().Id;
        opp.RecordTypeId = recTypeid;
        opp.Start_Date__c = Date.today();
        opp.End_Date__c = Date.today().adddays(1);
        opp.Order_Type_Clone__c = 'Contract - Upgrade';
        opp.OMC_Approved_Date__c = Date.today().adddays(1);
        Opp.CurrencyIsoCode = 'IDR';
        insert opp;
        
        csmso__Sales_Order__c so = new csmso__Sales_Order__c();
		so.csmso__Advertiser__c = a.Id;
		so.csmso__Status__c = 'Delivered';
		so.csmso__Opportunity__c = opp.Id;
		so.Primary_Sales_Order__c = true;
		so.Advertiser_Final__c = a.Id;
        so.Billing_schedule__c = 'Bill by item';
        insert so;
        
        csdf__Fulfilment__c testFulfilment = new csdf__Fulfilment__c();
		testFulfilment.csdf__Advertiser__c = a.Id;
		testFulfilment.Sales_Order__c = so.Id;
		testFulfilment.csdf__Name__c = 'Test_' + Datetime.now();
        insert testFulfilment;
        
        cscfga__Product_Configuration__c pro = new cscfga__Product_Configuration__c();
        pro.Name = 'Test Product';
        pro.cscfga__Quantity__c = 34556;
        pro.cscfga__package_guid__c = 'package guid';
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
        
    /*    list<Product2> prod = new list <Product2>();
        prod.add(new product2(Name = 'Test Prod', IsActive = true, Product_Category__c = 'Subscription' ));
        prod.add(new product2(Name = 'Test Prod2', IsActive = true, Product_Category__c = 'Subscription'));
        insert prod;
        
        Id StdpricebookId = Test.getStandardPricebookId();
        
        PricebookEntry pbe = new PricebookEntry(pricebook2id=StdpricebookId,CurrencyIsoCode='IDR', product2id=prod[0].id,unitprice=100.0, isActive=true);
        insert pbe;
        PricebookEntry pbe2 = new PricebookEntry(pricebook2id=StdpricebookId, product2id=prod[1].id,unitprice=100.0, isActive=true);
        insert pbe2;
        
        list<OpportunityLineItem> oli = new list<OpportunityLineItem>();
        oli.add(new opportunityLineItem(OpportunityId = opp.id, Product2Id = prod[0].id,PricebookEntryId = pbe.id,Quantity = 3,UnitPrice =3,SNo__c = 1.00,GST_VAT_Rate__c = 7,Start_Date__c = startDate, End_Date__c = endDate));
       // oli.add(new opportunityLineItem(OpportunityId = opp.id, Product2Id = prod[1].id,PricebookEntryId = pbe.id,Quantity = 3,UnitPrice =3,SNo__c = 1.11,GST_VAT_Rate__c = 7,Start_Date__c = startDate, End_Date__c = endDate ));
        
        insert oli;*/
        
       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/services/apexrest/orders';  //Request URL
        req.httpMethod = 'GET';//HTTP Request Type
     //   req.addParameter('id', opp.id);
        RestContext.request = req;
        RestContext.response= res;
        FulfilmentRestResource.getFulfilment();
        resp = res.responseBody.toString();
        Test.stopTest();
        map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(resp);
    
       /* String internalId = '';         String created ='';     String externalId = '';        String parentInternalId = '';
        if(responseJson != null){
            created = (string) responseJson.get('purchasedDate');  
            externalId = (string) responseJson.get('externalId');       
            internalID = externalId + '_1';
            parentInternalId = externalId + '_1_11';
            
            
        }*/
        
    }
}