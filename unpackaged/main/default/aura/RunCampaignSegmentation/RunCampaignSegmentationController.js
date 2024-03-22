({
    Confirm : function(component, event, helper) {
        
        var action = component.get("c.runCRE");
      
        action.setParams({
            campId : component.get("v.recordId")            
        });
        
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                var result = response.getReturnValue();
                if(result == false) {
                    var msg = $A.get("$Label.c.GENERAL_ERROR_EDIT"); 
                    helper.showtoast(component, event, helper,'Error',msg);
                }
                else {
                 helper.showtoast(component, event, helper,'Success','Campaign segmentation ran successfully');
                } 
            }else{
                 var errors = response.getError(); 
                 helper.showtoast(component, event, helper,'Error', errors[0].message);
               }
            
            helper.closePopup(component, event, helper);   
        });
        
        $A.enqueueAction(action);
        
    },closeModel: function(component, event, helper) {
        helper.closePopup(component, event, helper);
    }
})