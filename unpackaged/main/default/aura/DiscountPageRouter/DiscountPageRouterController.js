({
	doInit : function(component, event, helper) {
        var oppId = component.get("v.recordId");
        var init0 = component.get("c.getOppRecord");
        init0.setParams({"oppId": oppId});
        init0.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var oppObj = response.getReturnValue();
                component.set("v.oppObj", oppObj);
            }
        });
        $A.enqueueAction(init0);
	}
})