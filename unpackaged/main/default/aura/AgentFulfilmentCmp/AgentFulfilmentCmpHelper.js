({
    construct: function (component, event, helper) {
        var agentId = component.get("v.recordId");
        var init0 = component.get("c.getAgentFulfilment");
        let primeCreditBalanceCall=component.get("v.isPrimeCreditTab");
        init0.setParams({"accId": agentId,"isPrimeCreditCall":primeCreditBalanceCall});
        init0.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var conts = response.getReturnValue();
                var count = 0;
                var totalRemaining = 0;
                for (var key in conts) {
                    if (!conts[key].IsGrouping) {
                        totalRemaining += conts[key].BalanceQuantity;
                        count++;
                    }
                }
                component.set("v.totalRemaining", totalRemaining);
                component.set("v.sizeResult", count);
                component.set("v.listResult", conts);
            }
            component.set("v.isLoading",false);
        });
        $A.enqueueAction(init0);
    }
})