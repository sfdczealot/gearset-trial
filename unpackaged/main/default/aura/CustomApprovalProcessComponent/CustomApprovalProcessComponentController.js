({
    init: function(component, event, helper) {
        helper.checkApprovalProcessExists(component);
        let sobjectNameAccount = component.get('v.sObjectName');
        if(sobjectNameAccount == 'Account'){
            helper.CampaignList(component,event);
            helper.CampaignName(component,event);
        }
    },
    
    saveApprovalProcess : function(component, event, helper) {
        let sobjectNameAccount = component.get('v.sObjectName');
        if( sobjectNameAccount == 'Account' && (component.get("v.VIPCampaignName") == '' || component.get("v.VIPCampaignName") == undefined)){
            helper.showToast(component,event,'ERROR', 'Please fill VIP Campaign Name');
            return;
        }
        helper.checkApprovalProcessExists(component);
        console.log('comment: ',component.get("v.comment"));
        let action = component.get("c.runApproval");
        action.setParams({
            recordId : component.get("v.recordId"),
            approvalComment : component.get("v.comment"),
            VIPCampaignName : component.get("v.VIPCampaignName"),
            objectName : component.get("v.sObjectName")
        });
        action.setCallback(this, function(resp){
            console.log("inside callback");
            console.log('state: ',resp.getState());
            console.log('resp: ',resp.getReturnValue());
            if(resp.getState() == "SUCCESS") {
                let responseValue = typeof(resp.getReturnValue());
                console.log(responseValue);
                if(resp.getReturnValue() == 'Discount Approval Request Submitted') {
                    helper.showToast(component,event,'SUCCESS', resp.getReturnValue());
                    if(component.get("v.sObjectName")=='Quote'){
                        var navEvt = $A.get("e.force:navigateToSObject");
                        navEvt.setParams({
                            "recordId": component.get("v.oppId"),
                            "slideDevName": "related"
                        });
                        navEvt.fire();
                    }
                    component.set("v.approvalProcessStatus", false);
                }else if(resp.getReturnValue().includes('Approval Request Submitted')){
                    helper.showToast(component,event,'SUCCESS', resp.getReturnValue());
                    component.set("v.approvalProcessStatus", false);
                }else {
                        helper.showToast(component,event,'ERROR', resp.getReturnValue());
                        component.set("v.approvalProcessStatus", false);
                    }
            }
            else if(resp.getState() == "ERROR"){
                helper.showToast(component,event,'ERROR', resp.getError()[0].message);
                component.set("v.approvalProcessStatus", false);
            }
            if(component.get("v.approvalProcessStatus") == false) {
                $A.get("e.force:closeQuickAction").fire(); 
            }
            
        });
        $A.enqueueAction(action);
    }
})