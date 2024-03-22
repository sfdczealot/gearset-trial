({
    doInit : function(component, event, helper) {
        
        var det = component.get("c.sendSMSToAgent");
        det.setParams({
            "recordId":   component.get("v.recordId"),
            "checkStageName": true
        });
        
        det.setCallback(this, function(response) { 
            if (response.getState() === "SUCCESS") {
                if(response.getReturnValue() == false){
                    component.set("v.checkOMC",true) ;
                }else{
                    //  component.set("v.message",'SMS send successfully')
                    helper.showToast(component, event, helper,'Success','SMS send successfully','success');       
                    helper.close(component, event, helper);
                }
            }
            else{
                // component.set("v.message",response.getError()[0].message)
                helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
                
            }
        });
        $A.enqueueAction(det);
        
        
    },
    publishOk : function(component, event, helper) {
        var det = component.get("c.sendSMSToAgent");
        det.setParams({
            "recordId":   component.get("v.recordId"),
            "checkStageName": false
        });
        
        det.setCallback(this, function(response) { 
            if (response.getState() === "SUCCESS") {
                if(response.getReturnValue() == false){
                    component.set("v.checkOMC",true) ;
                }else{
                    component.set("v.checkOMC",false) ;
                    
                    // component.set("v.message",'SMS send successfully')
                    helper.showToast(component, event, helper,'Success','SMS send successfully','success');       
                    helper.close(component, event, helper);
                }
            }
            else{
                component.set("v.message",response.getError()[0].message)
                //helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
                
            }
        });
        $A.enqueueAction(det);
    },
    closeModel: function(component, event, helper) {
        helper.close(component, event, helper);
    }
    
})