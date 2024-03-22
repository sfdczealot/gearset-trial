/**
 * Created by petarmikic on 5/2/21.
 */
@IsTest
public  class CS_MigrationApprovalHandlerTest {


        @TestSetup
        static void testSetup() {
            CS_utl_User.disableAllTriggers(UserInfo.getUserId());

            CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();
            customSettings.Max_n_Templates_for_Sync_Execution__c = 5000;
            customSettings.Max_n_Lines_for_Sync_Execution__c = 50;
            update customSettings;

            // Needs an opp for the flow on SO
            Account[] accs = TestDataSetupBasic.createAccounts(2);
            Contact[] cons = TestDataSetupBasic.createContacts(1, accs);

            //Product Definition Creation.
            List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);

            Opportunity[] opps = TestDataSetupBasic.createOpportunities(1, accs, cons);
            update opps[0];

            csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
            salesOrder.csmso__Opportunity__c = opps[0].Id;
            salesOrder.csmso__Advertiser__c = accs[0].Id;
            salesOrder.Bill_To_Account__c = accs[1].Id;
            salesOrder.Advertiser_Final__c = accs[1].Id;
            salesOrder.Bill_To_Account_Final__c = accs[1].Id;
            salesOrder.csmso__Purchase_Order_Number__c = 'test';
            salesOrder.IO_Template__c = 'Client';
            salesOrder.csmso__Booking_Contact__c = cons[0].Id;
            salesOrder.Billing_Email__c = 'test@test.com';
            salesOrder.SO_Lines_All_Valid__c = true;
            salesOrder.csmso__Opportunity__c = opps[0].Id;
            salesOrder.SO_Lines_Ad_Server_Items__c = 1;
            salesOrder.SO_Lines_Number_of_lines__c = 1;
            salesOrder.Primary_Sales_Order__c = true;
            salesOrder.Synchronized_with_Opportunity__c = true;
            salesOrder.Order_Synced_before_final_approval__c = true;
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
                productConfiguration.Overbook__c = true;
            }
        }

        @IsTest
        static void MigrationApprovalTest() {
            csmso__Sales_Order__c salesOrder = [SELECT Id FROM csmso__Sales_Order__c LIMIT 1];

            CSPOFA__Orchestration_Process__c testProcess = new CSPOFA__Orchestration_Process__c();
            testProcess.Sales_Order__c = salesOrder.Id;
            insert testProcess;

            CSPOFA__Orchestration_Step__c testOrchestrationStep = new CSPOFA__Orchestration_Step__c();
            testOrchestrationStep.CSPOFA__Orchestration_Process__c = testProcess.Id;
            insert testOrchestrationStep;

            testOrchestrationStep = [
                    SELECT Id, CSPOFA__Orchestration_Process__c, CSPOFA__Orchestration_Process__r.Name, Sales_Order__c,
                            Orchestration_Process_Name__c, CSPOFA__Execute_Count__c, CSPOFA__Status__c
                    FROM CSPOFA__Orchestration_Step__c
                    LIMIT 1
            ];

            List<CSPOFA__Orchestration_Step__c> steps = new List<CSPOFA__Orchestration_Step__c>();
            steps.add(testOrchestrationStep);

            salesOrder.SD_Approval__c = 'Pending';
            update salesOrder;

            Test.startTest();
            CS_MigrationApprovalHandler handler = new CS_MigrationApprovalHandler();
            List<SObject> results = handler.process(steps);
            Test.stopTest();

            List<CSPOFA__Orchestration_Step__c> stepResults = (List<CSPOFA__Orchestration_Step__c>) results;

            String msg = 'Pending Sales Order Approvals were set as Approved';
            System.assertEquals( msg, stepResults[0].CSPOFA__Message__c );

            salesOrder = [SELECT Id,SD_Approval__c FROM csmso__Sales_Order__c LIMIT 1];
            System.assertEquals('Approved',salesOrder.SD_Approval__c,'Pending approval field is expected to be Approved');

        }

}