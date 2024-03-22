({
    sendApproval : function(component) {
        var action = component.get("c.sendApporval");
        action.setParams({ recordId : component.get("v.quoteId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var header = component.find("modalHeader");
                $A.util.addClass(header, 'slds-theme_success slds-theme_alert-texture');
                component.set("v.headerText", "Success to Submit OMC Approval");                
                //show error meesage
                var error = component.find("errorMessagePanel");
                $A.util.removeClass(error, 'slds-hide');
                component.set("v.errorMessage", "Your Quote has been submitted to OMC.");  
            }else{
                var errors = response.getError();           
                var header = component.find("modalHeader");
                $A.util.addClass(header, 'slds-theme_error slds-theme_alert-texture');
                component.set("v.headerText", "Failed to submit OMC approval");                
                //show error meesage
                var error = component.find("errorMessagePanel");
                $A.util.removeClass(error, 'slds-hide');
                component.set("v.errorMessage", errors[0].message);     
            }
            // hide spinner
            var spinner = component.find("spinner");
            $A.util.addClass(spinner, "slds-hide");
            //show footer
            var footer = component.find("modalFooter");
            $A.util.removeClass(footer, 'slds-hide');
        });
        $A.enqueueAction(action);        
    },
    checkApprovalProcessExists: function(component) {
        let oppId = component.get('v.oppId');
        let action = component.get("c.beforeApprovalValidation");
        action.setParams({
            recordId : component.get("v.quoteId")
        });
        action.setCallback(this, function(resp){
            if(resp.getState() == "SUCCESS") {
                if(resp.getReturnValue() == 'SUCCESS') {
                    component.set("v.approvalProcessStatus", true);
                }
                else {
                    this.navigate(component,event,oppId);
                    this.showToast(component,event,'ERROR', resp.getReturnValue());
                    component.set("v.approvalProcessStatus", false);
                }
            }
            else if(resp.getState() == "ERROR"){
                this.navigate(component,event,oppId);
                this.showToast(component,event,'ERROR', resp.getError()[0].message);
                component.set("v.approvalProcessStatus", false);
            }
        });
        $A.enqueueAction(action); 
    },
    showToast : function(component, event, title, message) {

        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": title,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },
    navigate : function(component, event, recordId) {
        let nagigateLightning = component.find('navigate');
        let pageReference = {    
           "type": "standard__recordPage",
           "attributes": {
               "recordId": recordId,
               "objectApiName": "Opportunity",
               "actionName": "view"
           }
        }
        nagigateLightning.navigate(pageReference);
    }
})