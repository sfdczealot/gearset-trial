({
    doInit : function(component, event, helper) {
        
        var det = component.get("c.publishEventforCampaign");
        det.setParams({
            "recordId":   component.get("v.recordId") 
        });
        
        det.setCallback(this, function(response) { 
            if (response.getState() === "SUCCESS") {
                component.set("v.message",'Event published successfully')
               // helper.showToast(component, event, helper,'Success','SMS send successfully','success');       
            }
            else{
                 component.set("v.message",response.getError()[0].message)
               // helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
                
            }
        });
        $A.enqueueAction(det);
        
        
    },
})