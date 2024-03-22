({
    doInit : function(component, event, helper) {
        var accId = component.get("v.recordId");
        var init0 = component.get("c.getAccRecord");
        init0.setParams({"accId": accId});
        init0.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var accObj = response.getReturnValue();
                component.set("v.accObj", accObj);
                let todayDate = new Date();
                let activationDate = new Date(accObj.Next_Subscription_Activation_Date__c);
                if(activationDate >todayDate) {
                    component.set("v.showError", true);
                }
            }
        });
        $A.enqueueAction(init0);
    }
})