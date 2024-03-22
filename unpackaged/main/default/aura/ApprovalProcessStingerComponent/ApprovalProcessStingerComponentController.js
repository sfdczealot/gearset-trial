({
    doInit : function(component, event, helper) {
        let isDisplayCmp = component.get('v.isDisplayCmp');
        if(isDisplayCmp){
            helper.checkApprovalProcessExists(component);
        }
        helper.sendApproval(component);
    },
    closeModal : function(component, event, helper) { 
        // Close the action panel 
        let dismissActionPanel = $A.get("e.force:closeQuickAction"); 
        dismissActionPanel.fire(); 
        let oppId = component.get('v.oppId');
        helper.navigate(component,event,oppId);
    },
    saveApprovalProcess : function(component, event, helper) {
        
        let oppId = component.get('v.oppId');
        helper.checkApprovalProcessExists(component);
        /*let commentApproval;
        let commentApproval2 = component.get("v.comment");
        if(commentApproval2 != undefined && commentApproval2 != null && commentApproval2 != ''){
            commentApproval = commentApproval2.replace(/<br>/gi, ' ');
            if(commentApproval.length > 255){
                helper.showToast(component,event,'ERROR', 'Approval request text too long. Max is 255 characters');
                return;
            }
        }*/
        
        let action = component.get("c.runApproval");
        action.setParams({
            recordId : component.get("v.quoteId"),
            approvalComment : component.get("v.comment")
        })
        action.setCallback(this, function(resp){
            
            if(resp.getState() == "SUCCESS") {
                let responseValue = typeof(resp.getReturnValue());
                if(resp.getReturnValue() == 'Discount Approval Request Submitted') {
                    helper.navigate(component,event,oppId);
                    helper.showToast(component,event,'SUCCESS', resp.getReturnValue());
                    component.set("v.approvalProcessStatus", false);
                }else {
                        helper.navigate(component,event,oppId);
                        helper.showToast(component,event,'ERROR', resp.getReturnValue());
                        component.set("v.approvalProcessStatus", false);
                    }
            }
            else if(resp.getState() == "ERROR"){
                helper.navigate(component,event,oppId);
                helper.showToast(component,event,'ERROR', resp.getError()[0].message);
                component.set("v.approvalProcessStatus", false);
            }
             
        });
        $A.enqueueAction(action);
    },
    redirectToOpp : function(component,event,helper){
        
       let oppId = component.get('v.oppId');
       helper.navigate(component,event,oppId);
    }
})