({
    getAgentNetKey : function(component) {
        var action = component.get("c.getAgentNetKey");
        action.setParams({ recordId : component.get("v.recordId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                this.callResendAPI(component);
            }else{
                var errors = response.getError();           
                var header = component.find("modalHeader");
                $A.util.addClass(header, 'slds-theme_error slds-theme_alert-texture');
                component.set("v.headerText", "Failure");                
                //show error message
                var error = component.find("errorMessagePanel");
                $A.util.removeClass(error, 'slds-hide');
                component.set("v.errorMessage", errors[0].message);                  
                // hide spinner
                var spinner = component.find("spinner");
                $A.util.addClass(spinner, "slds-hide");
                //show footer
                var footer = component.find("modalFooter");
                $A.util.removeClass(footer, 'slds-hide');
            }
        });
        $A.enqueueAction(action);                   
    },
    callResendAPI : function(component, recordId){
        //OppID
        var action = component.get("c.callResendApi");
        action.setParams({ accId : component.get("v.recordId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert("state: " + state);
            if (state == "SUCCESS") {
                var header = component.find("modalHeader");
                var statusCode = response.getReturnValue();
                if(statusCode == '200') {
                     $A.util.addClass(header, 'slds-theme_success slds-theme_alert-texture');
                	component.set("v.headerText", "Success");                
                    //show error meesage
                    var error = component.find("errorMessagePanel");
                    $A.util.removeClass(error, 'slds-hide');
                    component.set("v.errorMessage", "Resend verification email is successful");                   
                } else {
                    $A.util.addClass(header, 'slds-theme_error slds-theme_alert-texture');
                	component.set("v.headerText", "Failure");                
                    //show error meesage
                    var error = component.find("errorMessagePanel");
                    $A.util.removeClass(error, 'slds-hide');
                    component.set("v.errorMessage", "Resend verification email failed : " + statusCode);   
                }
            }else{
                var errors = response.getError();           
                var header = component.find("modalHeader");
                $A.util.addClass(header, 'slds-theme_error slds-theme_alert-texture');
                component.set("v.headerText", "Failure");                
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