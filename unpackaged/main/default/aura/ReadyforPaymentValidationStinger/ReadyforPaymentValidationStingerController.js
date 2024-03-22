({
    doInit : function(component, event, helper) {
        var action = component.get("c.getQuoteDetails");
        action.setParams({ quoteId : component.get("v.quoteId")});
        action.setCallback(this, function(response) {
            var state = response.getState();

            if (state == "SUCCESS") {
                component.set("v.quoteObj",response.getReturnValue());
        helper.checkConditionsBeforePayment(component);
            }else{
                var errors = response.getError();
                var header = component.find("modalHeader");
                $A.util.addClass(header, 'slds-theme_error slds-theme_alert-texture');
                component.set("v.headerText", "Failed send to AdminNet");
                //show error meesage
                var error = component.find("errorMessagePanel");
                $A.util.removeClass(error, 'slds-hide');
                component.set("v.errorMessage", errors[0].message);
            }

        });
        $A.enqueueAction(action);
    },
    closeModal : function(component, event, helper) {
        // Close the action panel
        var dismissActionPanel = $A.get("e.force:closeQuickAction");
        dismissActionPanel.fire();
        /*$A.get('e.force:refreshView').fire();
        var sObectEvent = $A.get("e.force:navigateToSObject");
        sObectEvent .setParams({
            "recordId": component.get('v.oppId') ,
            "slideDevName": "detail"
        });
        sObectEvent.fire();*/
        window.location = '/'+component.get('v.oppId');
    },
    updateEmailAddressonQuote : function(component, event, helper){
        var obj= component.get("v.quoteObj");

        var emailField = component.find('NewEmail');
        var emailFieldValue = emailField.get("v.value");
        // Store Regular Expression
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;

        if(!$A.util.isEmpty(emailFieldValue) && !(emailFieldValue.match(regExpEmailformat))){
            $A.util.addClass(emailField, 'slds-has-error');
            emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);

        }
        else if($A.util.isEmpty(emailFieldValue)){
            $A.util.addClass(emailField, 'slds-has-error');
            emailField.set("v.errors", [{message: "Email Address cannot be blank"}]);
        }
        else if(component.get("v.emailID") == obj.Account_Email__c){
            emailField.set("v.errors", [{message: null}]);
            $A.util.removeClass(emailField, 'slds-has-error');
            component.set("v.showEmail",false);
            helper.sendToGuruland(component);

            //spinner true
        }else{
            emailField.set("v.errors", [{message: null}]);
            $A.util.removeClass(emailField, 'slds-has-error');
            var action = component.get("c.updateEmailAddress");
            action.setParams({ quoteId : component.get("v.quoteId"),
                                Email : component.get("v.emailID")});
            action.setCallback(this, function(response) {
                var state = response.getState();
                if(state == "SUCCESS") {
                    component.set("v.showEmail",false);
                    helper.sendToGuruland(component);
                } else {
                    var errors = response.getError();
                    var header = component.find("modalHeader");
                    $A.util.addClass(header, 'slds-theme_error slds-theme_alert-texture');
                    component.set("v.headerText", "Failed send to AdminNet");
                    //show error meesage
                    var error = component.find("errorMessagePanel");
                    $A.util.removeClass(error, 'slds-hide');
                    component.set("v.errorMessage", errors[0].message);
                }

            });
            $A.enqueueAction(action);
        }
    },
    sendPaymentLinkAnyway : function(component, event, helper) {
        component.set("v.showSendAnywayButton", false);
        var header = component.find("modalHeader");
        $A.util.removeClass(header, 'slds-theme_error');
        component.set("v.headerText", "Sending To AdminNet");

        var error = component.find("errorMessagePanel");
        $A.util.addClass(error, 'slds-hide');

        var spinner = component.find("spinner");
        $A.util.removeClass(spinner, "slds-hide");

        var footer = component.find("modalFooter");
        $A.util.addClass(footer, 'slds-hide');

        var obj= component.get("v.quoteObj");
        component.set("v.emailID", obj.Account_Email__c);
        if(!$A.util.isUndefinedOrNull(obj.Account.Tax_Reg_Number__c)){
            component.set("v.showEmail",true);
        }
        else {
            helper.sendToGuruland(component);
        }
    }
})