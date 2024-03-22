@isTest
public class DeveloperListingInventoriesCheck_Test {
    
    @TestSetup
    static void setupData() {
        Trigger_Execute__c PGTriggerOppSplit =new Trigger_Execute__c();
        PGTriggerOppSplit.Name='Trigger_OpportunitySplit';
        PGTriggerOppSplit.Enable_del__c=true;
        insert PGTriggerOppSplit;
        
        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Integration_Chunk_Size__c = 10.0;
        settings.Integration_Delay_Between_Callouts__c = 300.0;
        insert settings;
        DeveloperListingInventoriesCheck.increaseCoverage();        
        Id recordTypeId =Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('B2B_Account').getRecordTypeId();
        Account testAccount = TestDataSetupSO.createAccount();
        testAccount.RecordTypeId = recordTypeId;
        testAccount.Email__c='test@test.com';
        testAccount.country__c='Malaysia';
        insert testAccount;
        csmso__Node_Advert_Assignment__c naa = new csmso__Node_Advert_Assignment__c();
        naa.Name = 'Test Premium Project Listing NAA';
        naa.Product_Name__c = 'Test prod';
        naa.Bundle_Only__c = false; 
        naa.Ad_Location_Description__c = 'Desktop';
        naa.Line_Item_Category__c= 'Sponsorship	';
        naa.Product_Family__c = 'Display';
        naa.Product_Group__c = 'Leaderboard';
        naa.Line_Item_Type__c = 'Network';
        naa.Rate_Type__c = 'CPM';
        naa.Priority__c = '11';
        naa.Rate_Type_Display__c = 'CPM';
        naa.Served_by__c = 'DFP';
        naa.Unique_Id__c = 'DDprop ROS MPU 01';
        insert naa;
        Contact testContact = TestDataSetupSO.createContact(testAccount);
        insert testContact;
        
        Opportunity testOpportunity = TestDataSetupSO.createOpportunity(testAccount, testContact);
        //testOpportunity.country__c='Malaysia';
        insert testOpportunity;
        
        csmso__Sales_Order__c testSalesOrder = TestDataSetupSO.createSalesOrder(testAccount, testOpportunity);
        insert testSalesOrder;
        
        csdf__Fulfilment__c testFulfilment = [SELECT Id FROM csdf__Fulfilment__c WHERE Sales_Order__c = :testSalesOrder.Id];
        
        cscfga__Product_Configuration__c testConfiguration = TestDataSetupSO.createproductConfigAndDef('Test Config');
        testConfiguration.Sales_Order__c = testSalesOrder.Id;
        testConfiguration.Ad_Type__c = 'Standard';
        testConfiguration.Insertion_Unit_Type_Display__c = 'CPD';
        testConfiguration.Served_By__c = 'Developer Listings';
        testConfiguration.csmso__Flight_End__c = Date.today().addDays(5);
        testConfiguration.Fulfilment_Item_Status__c = 'Draft';
        testConfiguration.Digital_Product__c = naa.Id;
        update testConfiguration;
        
        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(testConfiguration, testSalesOrder, testFulfilment);
        testFulfilmentItem.Product_Configuration__c = testConfiguration.Id;
        testFulfilmentItem.DistrictCode__c='qw00';
        testFulfilmentItem.Regioncode__c='rg11';
        testFulfilmentItem.listing_id__c='12,121';
        testFulfilmentItem.Flight_Beginning_Line_Item__c=system.today();
        testFulfilmentItem.Flight_End_Line_Item__c=system.today().addDays(-10);
        testFulfilmentItem.Listing_JSON__c='{"userID":13399210,"totalPages":4,"regionName":"Surat Thani","regionCode":"TH84","propertyTypeGroup":"B","listingType":"SALE","ListingTitle":"Beyond Residence","listingID":9941003,"districtName":"Ko Samui","districtCode":"TH8404","agentName":"Beyond Samui CO., LTD"}';
        
        testFulfilmentItem.csdf__Availability_Check_Status__c = 'Completed';
        insert testFulfilmentItem;
        
        CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
        testProcess.Sales_Order__c = testSalesOrder.Id;
        testProcess.Name = 'Check Availability';
        insert testProcess;
        CSPOFA__Orchestration_Process__c testProcess1 = new CSPOFA__Orchestration_Process__c();
        testProcess1.Sales_Order__c = testSalesOrder.Id;
        testProcess1.Name = 'Reserve Inventory';
        insert testProcess1;
        CSPOFA__Orchestration_Process__c testProcess2 = new CSPOFA__Orchestration_Process__c();
        testProcess2.Sales_Order__c = testSalesOrder.Id;
        testProcess2.Name = 'inventory release';
        insert testProcess2;
        CSPOFA__Orchestration_Process__c testProcess3 = new CSPOFA__Orchestration_Process__c();
        testProcess3.Sales_Order__c = testSalesOrder.Id;
        testProcess3.Name = 'Status Push to GAM';
        insert testProcess3;
        CSPOFA__Orchestration_Process__c testProcess4 = new CSPOFA__Orchestration_Process__c();
        testProcess4.Sales_Order__c = testSalesOrder.Id;
        testProcess4.Name = 'Push to GAM';
        insert testProcess4;
        List <CSPOFA__Orchestration_Step__c> oStep = new List<CSPOFA__Orchestration_Step__c>();
        oStep.add(new CSPOFA__Orchestration_Step__c(CSPOFA__Orchestration_Process__c = testProcess.Id) );
        oStep.add(new CSPOFA__Orchestration_Step__c(CSPOFA__Orchestration_Process__c = testProcess1.Id) );
        oStep.add(new CSPOFA__Orchestration_Step__c(CSPOFA__Orchestration_Process__c = testProcess2.Id) );
        oStep.add(new CSPOFA__Orchestration_Step__c(CSPOFA__Orchestration_Process__c = testProcess3.Id) );
        
        oStep.add(new CSPOFA__Orchestration_Step__c(CSPOFA__Orchestration_Process__c = testProcess4.Id) );
        insert oStep;
    }
    @isTest
    static void testPerformAction(){
        List<Object> oList =new List<Object>();
        Map<String,Object> params = new Map<String,Object>();
        csdf__Fulfilment_Item__c fi = [select id from csdf__Fulfilment_Item__c ];        
        DeveloperListingInventoriesCheck DLIC = new DeveloperListingInventoriesCheck();
        DLIC.performAction('[{"regionCode":"IDBT","country":"THB","districtCode":"IDBT07","check":"getActiveBookings"}]');
        DLIC.performAction('[{"regionCode":"IDBT","country":"IDR","districtCode":"IDBT07","check":"check slots","keywordDate":"2022-01-22"}]');
        DLIC.performAction('[{"check":"Release Inventory","fulfilmentItem":"'+fi.id+'"}]');
        DLIC.performAction('[{"pageNumber":4,"keyWord":"proj","country":"MYR","check":"getListings"}]');
    }
    @IsTest
    static void testForCheckAvails() {
        List<CSPOFA__Orchestration_Step__c> steps = [
            SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
            Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
            FROM CSPOFA__Orchestration_Step__c where Orchestration_Process_Name__c ='Check Availability'
        ];
        
        
        update steps;
        Test.startTest();
        DeveloperListingHandler handler = new DeveloperListingHandler();
        handler.performCallouts(steps);
        Test.stopTest();
    }
    
    @IsTest 
    static void testForInventoryRelease() {
        csdf__Fulfilment_Item__c fi = [select id from csdf__Fulfilment_Item__c];
        fi.csdf__Status__c='Reserved';
        update fi;
        List<CSPOFA__Orchestration_Step__c> steps = [
            SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
            Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
            FROM CSPOFA__Orchestration_Step__c where Orchestration_Process_Name__c='inventory release'
        ];
        
        
        Test.startTest();
        DeveloperListingHandler handler = new DeveloperListingHandler();
        handler.performCallouts(steps);
        Test.stopTest();
    }
    @IsTest
    static void testForStatusPushToGAM() {
        csdf__Fulfilment_Item__c fi = [select id from csdf__Fulfilment_Item__c];
        fi.csdf__Status__c='Reserved';
        update fi;
        List<CSPOFA__Orchestration_Step__c> steps = [
            SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
            Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
            FROM CSPOFA__Orchestration_Step__c where Orchestration_Process_Name__c='Status Push to GAM'
        ];
        
        
        Test.startTest();
        DeveloperListingHandler handler = new DeveloperListingHandler();
        handler.performCallouts(steps);
        Test.stopTest();
    }
    @IsTest
    static void testForPushToGAM() {
        csdf__Fulfilment_Item__c fi = [select id from csdf__Fulfilment_Item__c];
        fi.csdf__Status__c='Reserved';
        update fi;
        List<CSPOFA__Orchestration_Step__c> steps = [
            SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
            Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
            FROM CSPOFA__Orchestration_Step__c where Orchestration_Process_Name__c='Push to GAM'
        ];
        csmso__Sales_Order__c so =[select id from csmso__Sales_Order__c];
        so.sold__c=true;
        update so;
        Test.startTest();
        DeveloperListingHandler handler = new DeveloperListingHandler();
        handler.performCallouts(steps);
        handler.process(steps);
        Test.stopTest();
    }
    @IsTest
    static void testForReservation() {
        
        List<CSPOFA__Orchestration_Step__c> steps = [
            SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
            Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
            FROM CSPOFA__Orchestration_Step__c where Orchestration_Process_Name__c='Reserve Inventory'
        ];
        Test.startTest();
        DeveloperListingHandler handler = new DeveloperListingHandler();
        handler.performCallouts(steps);
        
        Test.stopTest();
    }
    
}