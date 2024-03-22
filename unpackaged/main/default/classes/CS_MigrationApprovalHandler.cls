/**
 * Created by petarmikic on 5/2/21.
 */

global with sharing class CS_MigrationApprovalHandler extends CS_StepHandlerBase {

    global List<String> soApprovalFields = new List<String>{
            'SD_Approval__c',
            'CM_Approval__c',
            'HOB_FastKey_Approval__c',
            'HOB_MaaS_Approval__c',
            'HOB_Events_Approval__c',
            'HOB_Awards_Approval__c',
            'HOB_CNS_Approval__c',
            'CBO_Approval__c',
            'Customer_Approval__c',
            'OMC_Approval__c'
    };

    global CS_MigrationApprovalHandler() {
        this.action = 'Migration Approval';
    }

    global override CSPOFA__Orchestration_Step__c doWork(Object params) {
        Map<String, Object> paramsType = (Map<String, Object>) params;

        csmso__Sales_Order__c salesOrder = Database.query(
                        'SELECT ' +
                                CS_utl_Array.join(this.soApprovalFields, ',') +
                        ' FROM csmso__Sales_Order__c WHERE Id =\'' + paramsType.get('salesOrderId') + '\'');


        for (String str : soApprovalFields) {
            if (String.valueOf(salesOrder.get(str)) == 'Pending') {
                salesOrder.put(str, 'Approved');
            }
        }

        update salesOrder;

        CSPOFA__Orchestration_Step__c step = (CSPOFA__Orchestration_Step__c) paramsType.get('step');
        setStepProgress(step, 'Pending Sales Order Approvals were set as Approved');

        return step;
    }
}