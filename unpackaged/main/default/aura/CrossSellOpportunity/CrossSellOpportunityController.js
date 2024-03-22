({
    doInit : function(component, event, helper) {
        var det = component.get("c.getCrossSellValue");
        det.setParams({
            "recordId":   component.get("v.recordId") 
        });
        
        det.setCallback(this, function(response) { 
            if (response.getState() === "SUCCESS") {
                console.log('getCrosssellvalue');
                component.set("v.Currency",response.getReturnValue().CurrencyISOCode);
                 component.set("v.redirectURL",response.getReturnValue().redirectURL);
                component.set("v.Amount",response.getReturnValue().amount);
                 component.set("v.showLink",true);
                //   helper.showToast(component, event, helper,'Success','Agent untagged successfully','success');
            } else{         
                //  helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
            }
        });
        $A.enqueueAction(det);
    }
})