global without sharing class ButtonSOApprovalRecall extends CS_ButtonBase {

    global override void init() {
        this.calloutType = 'ButtonSOApprovalRecall';
        this.lastButtonClicked = 'Recall';
    }

    global override Boolean doAdditionalValidation() {
        if (!isInApprovalProcess()
                || !canCurrentUserRecall()) {
            return false;
        }
        return true;
    }

    private Boolean canCurrentUserRecall() {
        Boolean isUserSubmitter = UserInfo.getUserId() == salesOrder.Submitted_By__c;
        Boolean hasCustomPermission = FeatureManagement.checkPermission('System_Admin_Compliance_Access');
        if (!isUserSubmitter && profileName != 'S: Systems Administrator' && !hasCustomPermission) {
            returnMessage.setErrorMessage(Label.SO_Approval_Cannot_Recall);
            return false;
        }

        return true;
    }

    global override void doAction() {
        terminateOrchestratorProcesses();

        ProcessInstanceWorkitem[] workItemList = [
                SELECT p.Id
                FROM ProcessInstanceWorkitem p
                WHERE p.ProcessInstance.TargetObjectId = :salesOrder.Id
                AND (p.ProcessInstance.Status = 'Submitted' OR p.ProcessInstance.Status = 'Pending')
        ];

        if(!workItemList.isEmpty()) {
            ProcessInstanceWorkitem workItem = workItemList[0];

            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItem.Id);
            req.setComments(salesOrder.Comments__c);
            req.setAction('Removed');

            Approval.ProcessResult result = Approval.process(req);
            //fetch SO to pick up new status set by approval process
            salesOrder = getSalesOrder(this.salesOrder.Id);
            if (result.isSuccess()) {
                salesOrder.Comments__c = '';
                if (String.isBlank(String.valueOf(salesOrder.Last_Date_Booked__c))) {
                    salesOrder.Recall_Retract_Counter__c += 1;
                }
                returnMessage.setSuccessMessage(Label.SO_Approval_Recall_request);
            } else {
                returnMessage.setErrorMessage(result.getErrors()[0].getMessage());
            }
        }
        else {
            salesOrder.csmso__Status__c = CS_const_SalesOrder.ApprovalStatus_Rejected;
            salesOrder.Comments__c = '';
            if (String.isBlank(String.valueOf(salesOrder.Last_Date_Booked__c))) {
                salesOrder.Recall_Retract_Counter__c += 1;
            }
            
            returnMessage.setSuccessMessage(Label.SO_Approval_Recall_request);
        }
    }

    private Boolean isInApprovalProcess() {
        if (Approval.isLocked(this.salesOrder.Id) || salesOrder.csmso__Status__c == CS_const_SalesOrder.Status_AccountCheck) {
            return true;
        }
        returnMessage.setErrorMessage(Label.SO_Approval_Not_In_Progress);
        return false;
    }
}