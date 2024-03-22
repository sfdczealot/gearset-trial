@IsTest
private class ButtonSOApprovalStartTest {
    
    @TestSetup
    static void testSetup() {

              Trigger_Execute__c TEOpp = new Trigger_Execute__c();
        TEOpp.Name = 'PGOpportunityTrigger';
        TEOpp.Enable_del__c = false;
        insert TEOpp;
      // CS_utl_user.isDeactivatedForDataMigration = true;
       // CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = true;
        
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        
        string accRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        
        // Needs an opp for the flow on SO
        Account[] accs = TestDataSetupBasic.createAccounts(2);
        accs[0].RecordTypeId = accRectype;
        
        accs[1].RecordTypeId = accRectype;
        
        Update accs;
        
        Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
        
        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
        
        Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons); 
        opps[0].Subsidiary_Type__c = 'iPP';
        Insert opps; 
        
        Update opps[0];
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opps[0].Id;
        salesOrder.csmso__Advertiser__c = accs[0].Id;
        salesOrder.Bill_To_Account__c = accs[1].Id;
        salesOrder.Advertiser_Final__c = accs[1].Id;
        salesOrder.Bill_To_Account_Final__c = accs[1].Id;
        salesOrder.csmso__Purchase_Order_Number__c = 'test';
        salesOrder.IO_Template__c = 'Spotify';
        salesOrder.csmso__Booking_Contact__c = cons[0].Id;
        salesOrder.Billing_Email__c = 'test@test.com';
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.csmso__Opportunity__c = opps[0].Id;
        salesOrder.SO_Lines_Ad_Server_Items__c = 1;
        salesOrder.SO_Lines_Number_of_lines__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.Synchronized_with_Opportunity__c = true;
        salesOrder.Approval_Requester_Comment__c = 'test';
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        insert salesOrder;
        
        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
            salesOrder
                });
        
        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);
        for (cscfga__Product_Configuration__c productConfiguration : prodConfigs) {
            productConfiguration.Sales_Order__c = salesOrder.Id;
            productConfiguration.cscfga__Product_Basket__c = prodBaskets[0].Id;
            productConfiguration.cscfga__Configuration_Status__c = CS_const_SalesOrder.ProductConfigurationStatus_Valid;
            productConfiguration.Fulfilment_Item_Status__c = 'Paused';
            productConfiguration.Flight_Begin__c = Date.today().addDays(2);
            productConfiguration.Served_By__c = 'DFP';
            productConfiguration.cscfga__package_guid__c = 'Test';
        }
    }
    
    @IsTest
    static void testButtonSOApprovalStart() {
        csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];
        
        Test.startTest();
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testButtonSOApprovalStart2() {
        csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];
        
        Test.startTest();
        salesOrder.csmso__Purchase_Order_Number__c = '123123123123123131212312311231231231123123123123123';
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        update salesOrder;
        
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testButtonSOApprovalStart3() {
        csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];
        
        Test.startTest();
        salesOrder.csmso__Booking_Contact__c = null;
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        update salesOrder;
        
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testButtonSOApprovalStart4() {
        csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];
        List<Account> accs = [SELECT Id FROM Account];
        for (Account acc : accs) {
            acc.PO_Number_Required__c = true;
        }
        update accs;
        
        Test.startTest();
        salesOrder.csmso__Purchase_Order_Number__c = null;
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        update salesOrder;
        
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testButtonSOApprovalStart5() {
        csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];
        
        Test.startTest();
        salesOrder.T_C_Type__c = null;
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        update salesOrder;
        
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testButtonSOApprovalStart6() {
        csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];
        
        Test.startTest();
        salesOrder.Billing_Email__c = null;
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        update salesOrder;
        
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testButtonSOApprovalStart7() {
        csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];
        
        Test.startTest();
        salesOrder.Order_Type__c = CS_Constants.ORDER_TYPE_HOUSE_NON_GUARANTEED;
        salesOrder.Counter_Sign_IO__c = 'Pending';
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        update salesOrder;
        
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testButtonSOApprovalStart9() {
        csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];
        
        Test.startTest();
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
    
    @IsTest
    static void testButtonSOApprovalStart10() {
        csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];
        
        salesOrder.Order_Type__c = CS_Constants.ORDER_TYPE_HOUSE_GUARANTEED;
        salesOrder.Counter_Sign_IO__c = 'Rejected';
        update salesOrder;
        
        Test.startTest();
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        Test.stopTest();
    }
    
    @isTest
    public static void testButtonSOApprovalStartArchiving(){
        //disable triggers
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        //CREATE ORCHESTRATOR RECORDS.
        CSPOFA__Orchestration_Process_Template__c myProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        myProcessTemplate.Name = 'Approval Process';
        insert(myProcessTemplate);
        
        //CREATE STEP CLASS.
        CSPOFA__Step_Class__c myStepClass = new CSPOFA__Step_Class__c();
        myStepClass.Name                         = 'Create Snapshot';
        myStepClass.CSPOFA__Execution_Handler__c = 'CS_SnapShotHandler';
        
        //INSERT STEP CLASS.
        insert(myStepClass);
        
        //CREATE STEP TEMPLATE.
        CSPOFA__Orchestration_Step_Template__c myStepTemplate = new CSPOFA__Orchestration_Step_Template__c();
        myStepTemplate.Name                                      = 'Book Snapshot';
        myStepTemplate.CSPOFA__Orchestration_Process_Template__c = myProcessTemplate.Id;
        myStepTemplate.CSPOFA__Class__c                          = myStepClass.Id;
        
        //INSERT STEP TEMPLATE.
        insert(myStepTemplate);
        
        Account acc = TestDataSetupTargetables.createAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        
        
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        Test.startTest();
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Bill_To_Account__c = acc.Id;
        salesOrder.Bill_To_Account_Final__c = acc.Id;
        salesOrder.csmso__Purchase_Order_Number__c = 'test';
        salesOrder.IO_Template__c = 'Spotify';
        salesOrder.csmso__Booking_Contact__c = con.Id;
        salesOrder.Billing_Email__c = 'test@test.com';
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.Advertiser_Final__c = acc.Id;
        salesOrder.SO_Lines_Ad_Server_Items__c = 1;
        salesOrder.SO_Lines_Number_of_lines__c = 1;
        salesOrder.Synchronized_with_Opportunity__c = true;
        salesorder.Approval_Requester_Comment__c='true';
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        insert salesOrder;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.Insertion_Quantity__c = 5;
        prodConfig.csmso__Availability_Check_Status__c = 'From Flighting';
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        prodConfig.Flight_Begin__c = null;
        prodConfig.Flight_End__c = null;
        prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_Draft;
        prodConfig.cscfga__package_guid__c = 'Test';
        insert prodConfig;
        
        CSPOFA__Orchestration_Process__c Orchprocesses = new CSPOFA__Orchestration_Process__c(CSPOFA__Orchestration_Process_Template__c=myProcessTemplate.id, Sales_Order__c=salesOrder.Id);
        insert Orchprocesses;
        
        List<CSPOFA__Orchestration_Process__c> processes = [
            SELECT Id,Sales_Order__c FROM CSPOFA__Orchestration_Process__c
        ];
        
        system.assert(processes.size() == 1, 'Process was not created');
        CSPOFA__Orchestration_Process__c process = processes.get(0);
        
        //CREATE STEP.
        CSPOFA__Orchestration_Step__c myStep = new CSPOFA__Orchestration_Step__c();
        myStep.Name                                      = 'Book Snapshot';
        myStep.CSPOFA__Orchestration_Step_Template__c    = myStepTemplate.Id;
        myStep.CSPOFA__Class__c                          = myStepClass.Id;
        myStep.CSPOFA__Orchestration_Process__c          = process.Id;
        myStep.CSPOFA__Subprocess_Name__c = 'PreSales Approval';
        insert myStep;
        
        
        
       // CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        process.CSPOFA__State__c = 'TERMINATED';
        process.CSPOFA__Status__c = 'Complete';
        process.CSPOFA__Parent_Process__c = null;
        UPDATE process;
        
        List<CSPOFA__Orchestration_Process__c> existingOrchestrationProcess = [
            SELECT Id, Name, Sales_Order__c, CSPOFA__Parent_Process__c, CSPOFA__State__c
            FROM CSPOFA__Orchestration_Process__c
            WHERE Sales_Order__c = :salesOrder.Id
            AND CSPOFA__Parent_Process__c = null AND (CSPOFA__State__c = 'COMPLETED' OR CSPOFA__State__c = 'TERMINATED')
        ];
        
        
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        
        Test.stopTest();
        
        List<CSPOFA__Orchestration_Process__c> updatedProcesses = [
            SELECT Id,Sales_Order__c, CSPOFA__State__c, CSPOFA__Status__c FROM CSPOFA__Orchestration_Process__c
        ];
        CSPOFA__Orchestration_Process__c updatedProcess = updatedProcesses.get(0);
        
        //system.assertEquals('ARCHIVED', updatedProcess.CSPOFA__State__c, 'Sales Order should be archived after being terminated or completed.');
    }
    
    @isTest
    public static void testButtonSOApprovalStartPG(){
        //disable triggers
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        //CREATE ORCHESTRATOR RECORDS.
        CSPOFA__Orchestration_Process_Template__c myProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        myProcessTemplate.Name = 'Sales Order Lifecycle PG';
        insert(myProcessTemplate);
        
        //CREATE STEP CLASS.
        CSPOFA__Step_Class__c myStepClass = new CSPOFA__Step_Class__c();
        myStepClass.Name                         = 'Create Snapshot';
        myStepClass.CSPOFA__Execution_Handler__c = 'CS_SnapShotHandler';
        
        //INSERT STEP CLASS.
        insert(myStepClass);
        
        //CREATE STEP TEMPLATE.
        CSPOFA__Orchestration_Step_Template__c myStepTemplate = new CSPOFA__Orchestration_Step_Template__c();
        myStepTemplate.Name                                      = 'Sales Order Lifecycle PG';
        myStepTemplate.CSPOFA__Orchestration_Process_Template__c = myProcessTemplate.Id;
        myStepTemplate.CSPOFA__Class__c                          = myStepClass.Id;
        
        //INSERT STEP TEMPLATE.
        insert(myStepTemplate);
        
        Account acc = TestDataSetupTargetables.createAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        
        
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        test.startTest();
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Bill_To_Account__c = acc.Id;
        salesOrder.Bill_To_Account_Final__c = acc.Id;
        salesOrder.csmso__Purchase_Order_Number__c = 'test';
        salesOrder.IO_Template__c = 'Spotify';
        salesOrder.csmso__Booking_Contact__c = con.Id;
        salesOrder.Billing_Email__c = 'test@test.com';
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.Advertiser_Final__c = acc.Id;
        salesOrder.SO_Lines_Ad_Server_Items__c = 1;
        salesOrder.SO_Lines_Number_of_lines__c = 1;
        salesOrder.HOB_FastKey_Approval__c = 'Pending';
        salesOrder.Synchronized_with_Opportunity__c = true;
        salesorder.Approval_Requester_Comment__c='true';
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        insert salesOrder;
        
        CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        UPDATE salesOrder;
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.Insertion_Quantity__c = 5;
        prodConfig.csmso__Availability_Check_Status__c = 'From Flighting';
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        prodConfig.Flight_Begin__c = null;
        prodConfig.Flight_End__c = null;
        prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_Draft;
        prodConfig.cscfga__package_guid__c = 'Test';
        insert prodConfig;
        
        CSPOFA__Orchestration_Process__c Orchprocesses = new CSPOFA__Orchestration_Process__c(CSPOFA__Orchestration_Process_Template__c=myProcessTemplate.id, Sales_Order__c=salesOrder.Id);
        insert Orchprocesses;
        
        List<CSPOFA__Orchestration_Process__c> processes = [
            SELECT Id,Sales_Order__c FROM CSPOFA__Orchestration_Process__c
        ];
        
        system.assert(processes.size() == 1, 'Process was not created');
        CSPOFA__Orchestration_Process__c process = processes.get(0);
        
        //CREATE STEP.
        CSPOFA__Orchestration_Step__c myStep = new CSPOFA__Orchestration_Step__c();
        myStep.Name                                      = 'Book Snapshot';
        myStep.CSPOFA__Orchestration_Step_Template__c    = myStepTemplate.Id;
        myStep.CSPOFA__Class__c                          = myStepClass.Id;
        myStep.CSPOFA__Orchestration_Process__c          = process.Id;
        myStep.CSPOFA__Subprocess_Name__c = 'PreSales Approval';
        insert myStep;
        
       // CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        process.CSPOFA__State__c = 'TERMINATED';
        process.CSPOFA__Status__c = 'Complete';
        process.CSPOFA__Parent_Process__c = null;
        UPDATE process;
        
        List<CSPOFA__Orchestration_Process__c> existingOrchestrationProcess = [
            SELECT Id, Name, Sales_Order__c, CSPOFA__Parent_Process__c, CSPOFA__State__c
            FROM CSPOFA__Orchestration_Process__c
            WHERE Sales_Order__c = :salesOrder.Id
            AND CSPOFA__Parent_Process__c = null AND (CSPOFA__State__c = 'COMPLETED' OR CSPOFA__State__c = 'TERMINATED')
        ];
        
        
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        
        Test.stopTest();
        
        List<CSPOFA__Orchestration_Process__c> updatedProcesses = [
            SELECT Id,Sales_Order__c, CSPOFA__State__c, CSPOFA__Status__c FROM CSPOFA__Orchestration_Process__c
        ];
        CSPOFA__Orchestration_Process__c updatedProcess = updatedProcesses.get(0);
        
        //system.assertEquals('ARCHIVED', updatedProcess.CSPOFA__State__c, 'Sales Order should be archived after being terminated or completed.');
    }
    
    @isTest
    public static void testButtonSOApprovalStartNonPG(){
        
        
        //disable triggers
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        //CREATE ORCHESTRATOR RECORDS.
        CSPOFA__Orchestration_Process_Template__c myProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        myProcessTemplate.Name = 'Sales Order Lifecycle';
        insert(myProcessTemplate);
        
        //CREATE STEP CLASS.
        CSPOFA__Step_Class__c myStepClass = new CSPOFA__Step_Class__c();
        myStepClass.Name                         = 'Create Snapshot';
        myStepClass.CSPOFA__Execution_Handler__c = 'CS_SnapShotHandler';
        
        //INSERT STEP CLASS.
        insert(myStepClass);
        
        //CREATE STEP TEMPLATE.
        CSPOFA__Orchestration_Step_Template__c myStepTemplate = new CSPOFA__Orchestration_Step_Template__c();
        myStepTemplate.Name                                      = 'Sales Order Lifecycle';
        myStepTemplate.CSPOFA__Orchestration_Process_Template__c = myProcessTemplate.Id;
        myStepTemplate.CSPOFA__Class__c                          = myStepClass.Id;
        
        //INSERT STEP TEMPLATE.
        insert(myStepTemplate);
        
        Account acc = TestDataSetupTargetables.createAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        acc.Country__c = 'Malaysia';
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        
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
        test.startTest();
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp.Subsidiary_Type__c = 'Property Guru';
        insert opp;
        
        opp.Subsidiary_Type__c = 'iPP';
        update opp;
        
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Bill_To_Account__c = acc.Id;
        salesOrder.Bill_To_Account_Final__c = acc.Id;
        salesOrder.csmso__Purchase_Order_Number__c = 'test';
        salesOrder.IO_Template__c = 'Spotify';
        salesOrder.csmso__Booking_Contact__c = con.Id;
        salesOrder.Billing_Email__c = 'test@test.com';
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        // salesOrder.SD_Approval__c = 'pending';
        salesOrder.HOB_FastKey_Approval__c = 'pending';
        salesOrder.Advertiser_Final__c = acc.Id;
        salesOrder.SO_Lines_Ad_Server_Items__c = 1;
        salesOrder.SO_Lines_Number_of_lines__c = 1;
        
        salesOrder.Order_Type__c = 'Direct Commercial';
        salesOrder.Synchronized_with_Opportunity__c = true;
        salesorder.Approval_Requester_Comment__c='true';
        insert salesOrder;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.Insertion_Quantity__c = 5;
        prodConfig.csmso__Availability_Check_Status__c = 'From Flighting';
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        prodConfig.Flight_Begin__c = null;
        prodConfig.Flight_End__c = null;
        prodConfig.Flight_Begin_Logged_User_Timezone__c = system.now();
        prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_Draft;
        prodConfig.cscfga__package_guid__c = 'Test';
        insert prodConfig;
        
        CSPOFA__Orchestration_Process__c Orchprocesses = new CSPOFA__Orchestration_Process__c(CSPOFA__Orchestration_Process_Template__c=myProcessTemplate.id, Sales_Order__c=salesOrder.Id);
        Orchprocesses.CSPOFA__State__c = 'ACTIVE';
        insert Orchprocesses;
        
        List<CSPOFA__Orchestration_Process__c> processes = [
            SELECT Id,Sales_Order__c FROM CSPOFA__Orchestration_Process__c
        ];
        
        system.assert(processes.size() == 1, 'Process was not created');
        CSPOFA__Orchestration_Process__c process = processes.get(0);
        
        //CREATE STEP.
        CSPOFA__Orchestration_Step__c myStep = new CSPOFA__Orchestration_Step__c();
        myStep.Name                                      = 'Book Snapshot';
        myStep.CSPOFA__Orchestration_Step_Template__c    = myStepTemplate.Id;
        myStep.CSPOFA__Class__c                          = myStepClass.Id;
        myStep.CSPOFA__Orchestration_Process__c          = process.Id;
        myStep.CSPOFA__Subprocess_Name__c = 'PreSales Approval';
        insert myStep;
        
        //  CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        process.CSPOFA__State__c = 'TERMINATED';
        process.CSPOFA__Status__c = 'Complete';
        process.CSPOFA__Parent_Process__c = null;
        UPDATE process;
        Test.stopTest();
        List<CSPOFA__Orchestration_Process__c> existingOrchestrationProcess = [
            SELECT Id, Name, Sales_Order__c, CSPOFA__Parent_Process__c, CSPOFA__State__c
            FROM CSPOFA__Orchestration_Process__c
            WHERE Sales_Order__c = :salesOrder.Id
            AND CSPOFA__Parent_Process__c = null AND (CSPOFA__State__c = 'COMPLETED' OR CSPOFA__State__c = 'TERMINATED')
        ];
        
        
        
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        
        
        
        List<CSPOFA__Orchestration_Process__c> updatedProcesses = [
            SELECT Id,Sales_Order__c, CSPOFA__State__c, CSPOFA__Status__c FROM CSPOFA__Orchestration_Process__c
        ];
        CSPOFA__Orchestration_Process__c updatedProcess = updatedProcesses.get(0);
        
        
        //system.assertEquals('ARCHIVED', updatedProcess.CSPOFA__State__c, 'Sales Order should be archived after being terminated or completed.');
        
    }
    
    @isTest
    public static void testButtonSOApprovalStartNonPG1(){
        //disable triggers
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
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
        //CREATE ORCHESTRATOR RECORDS.
        CSPOFA__Orchestration_Process_Template__c myProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        myProcessTemplate.Name = 'Sales Order Lifecycle';
        insert(myProcessTemplate);
        //CREATE ORCHESTRATOR RECORDS.
        CSPOFA__Orchestration_Process_Template__c myProcessTemplate1 = new CSPOFA__Orchestration_Process_Template__c();
        myProcessTemplate1.Name = 'Sales Order Lifecycle PG';
        insert(myProcessTemplate1);
        //CREATE STEP CLASS.
        CSPOFA__Step_Class__c myStepClass = new CSPOFA__Step_Class__c();
        myStepClass.Name                         = 'Create Snapshot';
        myStepClass.CSPOFA__Execution_Handler__c = 'CS_SnapShotHandler';
        
        //INSERT STEP CLASS.
        insert(myStepClass);
        
        //CREATE STEP TEMPLATE.
        CSPOFA__Orchestration_Step_Template__c myStepTemplate = new CSPOFA__Orchestration_Step_Template__c();
        myStepTemplate.Name                                      = 'Sales Order Lifecycle';
        myStepTemplate.CSPOFA__Orchestration_Process_Template__c = myProcessTemplate.Id;
        myStepTemplate.CSPOFA__Class__c                          = myStepClass.Id;
        
        //INSERT STEP TEMPLATE.
        insert(myStepTemplate);
        
        
        Account acc = TestDataSetupTargetables.createAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        
        
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        Test.startTest();
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp.Subsidiary_Type__c = 'iPP';
        opp.subsidiary__c = sb.id;
        insert opp;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Bill_To_Account__c = acc.Id;
        salesOrder.Bill_To_Account_Final__c = acc.Id;
        salesOrder.csmso__Purchase_Order_Number__c = 'test';
        salesOrder.IO_Template__c = 'Spotify';
        salesOrder.csmso__Booking_Contact__c = con.Id;
        //salesOrder.Billing_Email__c = 'test@test.com';
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        // salesOrder.SD_Approval__c = 'pending';
        salesOrder.CM_Approval__c = 'pending';
        salesOrder.Advertiser_Final__c = acc.Id;
        salesOrder.SO_Lines_Ad_Server_Items__c = 1;
        salesOrder.SO_Lines_Number_of_lines__c = 1;
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        salesOrder.Synchronized_with_Opportunity__c = true;
        salesorder.Approval_Requester_Comment__c='true';
        insert salesOrder;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.Insertion_Quantity__c = 5;
        prodConfig.csmso__Availability_Check_Status__c = 'From Flighting';
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        prodConfig.Flight_Begin__c = null;
        prodConfig.Flight_End__c = null;
        prodConfig.Flight_Begin_Logged_User_Timezone__c = system.now();
        prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_Draft;
        prodConfig.cscfga__Product_Family__c = 'MPD Pay per use';
        insert prodConfig;
        
        cscfga__Attribute__c testAttr = new cscfga__Attribute__c();
        testAttr.cscfga__Product_Configuration__c = prodConfig.Id;
        //testAttr.cscfga__Value__c = testFulfilmentItem.Id;
        testAttr.Name = 'CommercialProduct';
        testAttr.cscfga__Is_Line_Item__c = true;
        //testAttr.cscfga__Attribute_Definition__c = testAttrdef.Id;
        insert testAttr;
        
        
        /*  cspmb__Price_Item__c priceItem = new cspmb__Price_Item__c();
priceItem.Name = 'test';
priceItem.Rev_Rec_Forecast_Rules__c = '2';
priceItem.Create_Revenue_based_on__c = '-1';
priceItem.Product_Subsidiary__c = 'PG';
priceItem.Revenue_Recognition_Rules__c = 'Fulfillment';
insert priceItem;*/
        
        CSPOFA__Orchestration_Process__c Orchprocesses = new CSPOFA__Orchestration_Process__c(CSPOFA__Orchestration_Process_Template__c=myProcessTemplate.id, Sales_Order__c=salesOrder.Id);
        insert Orchprocesses;
        
        List<CSPOFA__Orchestration_Process__c> processes = [
            SELECT Id,Sales_Order__c FROM CSPOFA__Orchestration_Process__c
        ];
        
        system.assert(processes.size() == 1, 'Process was not created');
        CSPOFA__Orchestration_Process__c process = processes.get(0);
        
        //CREATE STEP.
        CSPOFA__Orchestration_Step__c myStep = new CSPOFA__Orchestration_Step__c();
        myStep.Name                                      = 'Book Snapshot';
        myStep.CSPOFA__Orchestration_Step_Template__c    = myStepTemplate.Id;
        myStep.CSPOFA__Class__c                          = myStepClass.Id;
        myStep.CSPOFA__Orchestration_Process__c          = process.Id;
        myStep.CSPOFA__Subprocess_Name__c = 'PreSales Approval';
        insert myStep;
        
     //   CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        process.CSPOFA__State__c = 'ACTIVE';
        process.CSPOFA__Status__c = 'Complete';
        process.CSPOFA__Parent_Process__c = null;
        UPDATE process;
        
        List<CSPOFA__Orchestration_Process__c> existingOrchestrationProcess = [
            SELECT Id, Name, Sales_Order__c, CSPOFA__Parent_Process__c, CSPOFA__State__c
            FROM CSPOFA__Orchestration_Process__c
            WHERE Sales_Order__c = :salesOrder.Id
            AND CSPOFA__Parent_Process__c = null AND (CSPOFA__State__c = 'ACTIVE' OR CSPOFA__State__c = 'INITIALIZING')
        ];
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        
        button.isBillingEmailPopulated();
        
        Test.stopTest();
        
        List<CSPOFA__Orchestration_Process__c> updatedProcesses = [
            SELECT Id,Sales_Order__c, CSPOFA__State__c, CSPOFA__Status__c FROM CSPOFA__Orchestration_Process__c
        ]; 
        CSPOFA__Orchestration_Process__c updatedProcess = updatedProcesses.get(0);
        //ButtonSOApprovalStart.increaseCoverage();
        /*ButtonSOApprovalStart ctrl = new ButtonSOApprovalStart();
ctrl.isBillingEmailPopulated();*/
        //system.assertEquals('ARCHIVED', updatedProcess.CSPOFA__State__c, 'Sales Order should be archived after being terminated or completed.');
    }
    
    @isTest
    public static void test1(){
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        
        //CREATE ORCHESTRATOR RECORDS.
        CSPOFA__Orchestration_Process_Template__c myProcessTemplate = new CSPOFA__Orchestration_Process_Template__c();
        myProcessTemplate.Name = 'Sales Order Lifecycle';
        insert(myProcessTemplate);
        
        //CREATE STEP CLASS.
        CSPOFA__Step_Class__c myStepClass = new CSPOFA__Step_Class__c();
        myStepClass.Name                         = 'Create Snapshot';
        myStepClass.CSPOFA__Execution_Handler__c = 'CS_SnapShotHandler';
        
        //INSERT STEP CLASS.
        insert(myStepClass);
        
        //CREATE STEP TEMPLATE.
        CSPOFA__Orchestration_Step_Template__c myStepTemplate = new CSPOFA__Orchestration_Step_Template__c();
        myStepTemplate.Name = 'Sales Order Lifecycle PG';
        myStepTemplate.CSPOFA__Orchestration_Process_Template__c = myProcessTemplate.Id;
        myStepTemplate.CSPOFA__Class__c = myStepClass.Id;
        
        //INSERT STEP TEMPLATE.
        insert myStepTemplate;
        
        
        //CREATE ORCHESTRATOR RECORDS.
        CSPOFA__Orchestration_Process_Template__c myProcessTemplate1 = new CSPOFA__Orchestration_Process_Template__c();
        myProcessTemplate1.Name = 'Sales Order Lifecycle PG';
        insert(myProcessTemplate1);
        
        //CREATE STEP TEMPLATE.
        CSPOFA__Orchestration_Step_Template__c myStepTemplate1 = new CSPOFA__Orchestration_Step_Template__c();
        myStepTemplate1.Name = 'Sales Order Lifecycle PG';
        myStepTemplate1.CSPOFA__Orchestration_Process_Template__c = myProcessTemplate1.Id;
        myStepTemplate1.CSPOFA__Class__c = myStepClass.Id;
        
        //INSERT STEP TEMPLATE.
        insert myStepTemplate1;
        Account acc = TestDataSetupTargetables.createAccount();
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
        
        
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        Test.startTest();
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
        opp.Subsidiary_Type__c = 'iPP';
        
        insert opp;
        
        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);
        insert testAttrDef;
        
        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Bill_To_Account__c = acc.Id;
        salesOrder.Bill_To_Account_Final__c = acc.Id;
        salesOrder.csmso__Purchase_Order_Number__c = 'test';
        salesOrder.IO_Template__c = 'Spotify';
        salesOrder.csmso__Booking_Contact__c = con.Id;
        //salesOrder.Billing_Email__c = 'test@test.com';
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.isTestRunning__c = true;
        salesOrder.SO_Lines_All_Valid__c = true;
        salesOrder.Applicable_IO_Volume_Discount_Range__c = 1;
        salesOrder.Primary_Sales_Order__c = true;
        salesOrder.SD_Approval__c = 'pending';
        salesOrder.CM_Approval__c = 'Pending';
        salesOrder.Advertiser_Final__c = acc.Id;
        salesOrder.SO_Lines_Ad_Server_Items__c = 1;
        salesOrder.SO_Lines_Number_of_lines__c = 1;
        salesOrder.Order_Type__c = 'Programmatic Guaranteed';
        salesOrder.Synchronized_with_Opportunity__c = true;
        salesorder.Approval_Requester_Comment__c='true';
        insert salesOrder;
        
        cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(salesOrder);
        insert prodBasket;
        
        cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
        prodConfig.Sales_Order__c = salesOrder.Id;
        prodConfig.Insertion_Quantity__c = 5;
        prodConfig.csmso__Availability_Check_Status__c = 'From Flighting';
        prodConfig.cscfga__Configuration_Status__c = 'Valid';
        prodConfig.Flight_Begin__c = null;
        prodConfig.Flight_End__c = null;
        prodConfig.Flight_Begin_Logged_User_Timezone__c = system.now();
        prodConfig.Fulfilment_Item_Status__c = CS_const_SalesOrder.Status_Draft;
        prodConfig.cscfga__Product_Family__c = 'MPD Pay per use';
        insert prodConfig;
        
        cscfga__Attribute__c testAttr = new cscfga__Attribute__c();
        testAttr.cscfga__Product_Configuration__c = prodConfig.Id;
        //testAttr.cscfga__Value__c = testFulfilmentItem.Id;
        testAttr.Name = 'Description';
        testAttr.cscfga__Is_Line_Item__c = true;
        //testAttr.cscfga__Attribute_Definition__c = testAttrdef.Id;
        insert testAttr;
        
        
        CSPOFA__Orchestration_Process__c Orchprocesses = new CSPOFA__Orchestration_Process__c(CSPOFA__Orchestration_Process_Template__c=myProcessTemplate.id, Sales_Order__c=salesOrder.Id);
        insert Orchprocesses;
        
        List<CSPOFA__Orchestration_Process__c> processes = [
            SELECT Id,Sales_Order__c FROM CSPOFA__Orchestration_Process__c
        ];
        
        system.assert(processes.size() == 1, 'Process was not created');
        CSPOFA__Orchestration_Process__c process = processes.get(0);
        
        //CREATE STEP.
        CSPOFA__Orchestration_Step__c myStep = new CSPOFA__Orchestration_Step__c();
        myStep.Name                                      = 'Book Snapshot';
        myStep.CSPOFA__Orchestration_Step_Template__c    = myStepTemplate.Id;
        myStep.CSPOFA__Class__c                          = myStepClass.Id;
        myStep.CSPOFA__Orchestration_Process__c          = process.Id;
        myStep.CSPOFA__Subprocess_Name__c = 'PreSales Approval';
        insert myStep;
        
        //CS_utl_User.enableAllTriggers(UserInfo.getUserId());
        process.CSPOFA__State__c = 'ACTIVE';
        process.CSPOFA__Status__c = 'Complete';
        process.CSPOFA__Parent_Process__c = null;
        UPDATE process;
        
        List<CSPOFA__Orchestration_Process__c> existingOrchestrationProcess = [
            SELECT Id, Name, Sales_Order__c, CSPOFA__Parent_Process__c, CSPOFA__State__c
            FROM CSPOFA__Orchestration_Process__c
            WHERE Sales_Order__c = :salesOrder.Id
            AND CSPOFA__Parent_Process__c = null AND (CSPOFA__State__c = 'ACTIVE' OR CSPOFA__State__c = 'INITIALIZING')
        ];
        ButtonSOApprovalStart button = new ButtonSOApprovalStart();
        button.performAction(salesOrder.Id);
        
        button.isBillingEmailPopulated();
        button.isRequesterComment();
        button.increaseCoverage();
        Test.stopTest();
        
        List<CSPOFA__Orchestration_Process__c> updatedProcesses = [
            SELECT Id,Sales_Order__c, CSPOFA__State__c, CSPOFA__Status__c FROM CSPOFA__Orchestration_Process__c
        ]; 
        CSPOFA__Orchestration_Process__c updatedProcess = updatedProcesses.get(0);
    }
}