global without sharing class ButtonSOApprovalAccept extends CS_ButtonBase {
    private ProcessInstanceWorkitem[] workItems {
        get {
            if (workItems == null) {
                workItems = [
                        SELECT p.Id, p.ActorId, p.Actor.Type, p.Actor.Name, p.ProcessInstance.ProcessDefinition.DeveloperName
                        FROM ProcessInstanceWorkitem p
                        WHERE p.ProcessInstance.TargetObjectId = :salesOrder.Id
                              AND (p.ProcessInstance.Status = 'Submitted' OR p.ProcessInstance.Status = 'Pending')
                ];
            }
            return workItems;
        }
        set;
    }

    private List<CS_ApprovalService.WorkItemWrapper> sortedWorkItems {
        get {
            if(sortedWorkItems == null) {
                sortedWorkItems = CS_ApprovalService.getSortedWorkItems(workItems);
            }

            return sortedWorkItems;
        }
        set;
    }

    private Map<Id, GroupMember> groupMembership {
        get {
            if(groupMembership == null) {
                Set<Id> groupIds = new Set<Id>();
                for (ProcessInstanceWorkitem wi : this.workItems) {
                    if (wi.Actor.Type == 'Queue') {
                        groupIds.add(wi.ActorId);
                    }
                }

                groupMembership = new Map<Id, GroupMember>();
                for(GroupMember gm : [SELECT UserOrGroupId, GroupId FROM GroupMember WHERE (GroupId = :groupIds AND UserOrGroupId = :currentUser) OR UserOrGroupId =: currentUser]) {
                    groupMembership.put(gm.UserOrGroupId, gm);
                    if(gm.GroupId!=null){
                        groupMembership.put(gm.GroupId, gm);
                    }
                }
            }

            return groupMembership;
        }
        set;
    }

    global override void init() {
        this.calloutType = 'ButtonSOApprovalAccept';
        this.lastButtonClicked = 'Accept';
        this.className = ButtonSOApprovalAccept.class.getName();
    }

    global override Boolean doAdditionalValidation() {
        if (!areAllConfigurationStatusesValid()
            || isStartDateOfAnyLineInThePast()
            || hasAnyLineExpiredDigitalProduct()
            || !hasSOLineItems()
            || !isInApprovalProcess()
            || !isSOInApprovalProcess()
            || !canApprovalBeAcceptedByCurrentUser()) {
            return false;
        }

        return true;
    }

    global override void doAction() {
        CS_ApprovalService.WorkItemWrapper workItemWrapper;

        system.debug(sortedWorkItems);
        for (CS_ApprovalService.WorkItemWrapper wiw : sortedWorkItems) {
            if(wiw.isApprover(profileName, groupMembership)) {
                workItemWrapper = wiw;
                break;
            }
        }

        if (workItemWrapper != null) {
            Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
            req.setWorkitemId(workItemWrapper.wi.Id);
            req.setComments(salesOrder.Comments__c);
            req.setAction('Approve');

            Approval.ProcessResult result = Approval.process(req);
            if (result.isSuccess()) {
                salesOrder = getSalesOrder(this.salesOrder.Id);
                salesOrder.Comments__c = null;
                //T-58220 change
                //salesOrder.put(workItemWrapper.approvalType.Field_Name__c, result.getInstanceStatus()); 
                salesOrder.put(workItemWrapper.approvalType.Field_Name__c, 'Approved');
                returnMessage.setSuccessMessage(Label.SO_Approval_Accept_request);
            }
            else {
                returnMessage.setAndPersistErrorMessage(result.getErrors()[0].getMessage());
            }
        }
        else {
            returnMessage.setAndPersistErrorMessage('There are no Process Instance Workitems.');
        }
    }

    private Boolean canApprovalBeAcceptedByCurrentUser() {
        Boolean isUserApprover = false;
        for (CS_ApprovalService.WorkItemWrapper workItemWrapper : sortedWorkItems) {
            if(workItemWrapper.isApprover(profileName, groupMembership)) {
                isUserApprover = true;
                break;
            }
        }

        if (!isUserApprover) {
            returnMessage.setErrorMessage(Label.SO_Approval_Cannot_Accept);
            return false;
        }

        return true;
    }

    private Boolean isSOInApprovalProcess() {
        if (this.workItems.isEmpty()) {
            returnMessage.setErrorMessage(Label.SO_Approval_Not_In_Progress);
            return false;
        }
        return true;
    }

    private Boolean isInApprovalProcess() {
        if (Approval.isLocked(this.salesOrder.Id)) {
            return true;
        }
        returnMessage.setErrorMessage(Label.SO_Approval_Not_In_Progress);
        return false;
    }
}