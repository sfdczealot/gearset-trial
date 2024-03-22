({
    sendApproval : function(component) {
        var action = component.get("c.sendApporval");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var header = component.find("modalHeader");
                $A.util.addClass(header, 'slds-theme_success slds-theme_alert-texture');
                component.set("v.headerText", "Success to Submit OMC Approval");                
                //show error meesage
                var error = component.find("errorMessagePanel");
                $A.util.removeClass(error, 'slds-hide');
                component.set("v.errorMessage", "Your opportunity has been submitted to OMC.");  
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
    }
})