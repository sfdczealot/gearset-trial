({
    construct: function (component, event, helper) {
        var oppId = component.get("v.recordId");
        var init0 = component.get("c.construct");
        init0.setParams({"oppId": oppId});
        init0.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var oppTmp = response.getReturnValue();
                component.set("v.oppObj", oppTmp.oppObj);
                this.getDiscountInfo(component, event, oppTmp.oppObj);
            }
        });
        $A.enqueueAction(init0);
    },
    getDiscountInfo: function(component, event, oppObj) {
        var getDiscount = component.get("c.getListEligiblePromotion");
        getDiscount.setParams({"oppObj": oppObj});
        getDiscount.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var listDiscountDetail = component.get("v.listDiscountDetail");
                var tmp;
                var conts = response.getReturnValue();
                for (var idx in conts) {
                    if (!conts[idx].IsTier) {
                        listDiscountDetail.push(conts[idx]);
                    }
                }
                component.set("v.listDiscountDetail", listDiscountDetail);
            }
        });
        $A.enqueueAction(getDiscount);
    },
})