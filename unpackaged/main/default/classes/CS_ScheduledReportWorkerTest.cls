/**
 * Created by tvrtko.matosevic on 19/02/2019.
 */

@IsTest
private class CS_ScheduledReportWorkerTest {

    @IsTest
    static void testScheduledReportWorker() {
        csdf__Ad_Server__c testAdserver = new csdf__Ad_Server__c(
                Name = 'Ad-Juster',
                csdf__Type__c = 'DFP',
                csdf__Description__c = 'Description',
                csdf__Network_Code__c = 'Code',
                csdf__Network_Name__c = 'Network',
                csdf__Client_Id__c = 'clientID',
                csdf__Client_Secret__c = 'Secret',
                csdf__Refresh_Token__c = 'Token'
        );
        insert testAdserver;

        csdf__Custom_Report_Definition__c testDefinition = new csdf__Custom_Report_Definition__c(
                Name = 'Test Def',
                csdf__Ad_Server__c = testAdserver.Id,
                csdf__Query_Id__c = 'id',
                csdf__Result_Object_Name__c = 'obj',
                Scheduled_Execution__c = true
        );
        insert testDefinition;

        csdf__Custom_Report_Execution__c testReport = new csdf__Custom_Report_Execution__c(
                Name = 'Report',
                csdf__Custom_Report_Definition__c = testDefinition.Id,
                csdf__Report_Status__c = 'Completed',
                csdf__Map_Parameters__c = '{"startDate": { "year": 2018, "month": 10, "day": 28 }, "endDate": { "year": 2018, "month": 10, "day": 31 }}'
        );
        insert testReport;

        Test.startTest();
        CS_ScheduledReportWorker scheduledReportWorker = new CS_ScheduledReportWorker();
        scheduledReportWorker.execute(null);
        Test.stopTest();
    }
}