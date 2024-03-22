({
    checkConditionsBeforePayment : function(component) {
        var action = component.get("c.checkConditionsBeforePayment");
        action.setParams({ recordId : component.get("v.quoteId") });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state == "SUCCESS") {
                var obj= component.get("v.quoteObj");
                component.set("v.emailID",obj.Account_Email__c);
                if(!$A.util.isUndefinedOrNull(obj.Account.Tax_Reg_Number__c)){
                    component.set("v.showEmail",true);
                    //spinner false
                }
                else {
                    this.sendToGuruland(component);
                }
            }else{
                var errors = response.getError();
                var header = component.find("modalHeader");
                $A.util.addClass(header, 'slds-theme_error slds-theme_alert-texture');
                component.set("v.headerText", "Failed send to AdminNet");
                //show error meesage
                var error = component.find("errorMessagePanel");
                $A.util.removeClass(error, 'slds-hide');
                component.set("v.errorMessage", errors[0].message+".");
                // hide spinner
                var spinner = component.find("spinner");
                $A.util.addClass(spinner, "slds-hide");
                //show footer
                var footer = component.find("modalFooter");
                $A.util.removeClass(footer, 'slds-hide');
                if(
                    errors[0].message.includes('CEA expired on') ||
                    errors[0].message.includes('CEA Check')
                ){
                    var actionFeed = component.get("c.createFeeditem");
                    actionFeed.setParams({ 
                        OppId : component.get("v.oppId"),
                        feedData :errors[0].message 
                    });
                    actionFeed.setCallback(this, function(response) {
                        var state = response.getState();
                        if (state == "SUCCESS") {
                            component.set("v.showSendAnywayButton", true);
                        }
                    });
                    $A.enqueueAction(actionFeed);
                }
            }
        });
        $A.enqueueAction(action);
    },
    sendToGuruland : function(component, recordId){
        //OppID
        var action = component.get("c.sendtoGuruland");
        action.setParams({ quoteId : component.get("v.quoteId")});
        action.setCallback(this, function(response) {
            var state = response.getState();
            //alert("state: " + state);
            if (state == "SUCCESS") {
                var header = component.find("modalHeader");
                $A.util.addClass(header, 'slds-theme_success slds-theme_alert-texture');
                component.set("v.headerText", "Success send to AdminNet");
                //show error meesage
                var error = component.find("errorMessagePanel");
                $A.util.removeClass(error, 'slds-hide');
                component.set("v.errorMessage", "Payment link has been created for your quote");
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