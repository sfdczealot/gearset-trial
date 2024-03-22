({
    doInit : function(component, event, helper) {
          component.set("v.ShowSpinner","true");
        var det = component.get("c.updateCase");
        console.log(component.get("v.recordId"));
      det.setParams({
          "caseID":   component.get("v.recordId") 
      });
      
      det.setCallback(this, function(response) { 
          if (response.getState() === "SUCCESS") {
              if(response.getReturnValue()=='SUCCESS'){
                  helper.showToast(component, event, helper,'Success','Case is closed!','success'); 
              }else{
               helper.showToast(component, event, helper,'Error',response.getReturnValue(),'error');
                  
              }
          }
          else{
              helper.showToast(component, event, helper,'Error',response.getError()[0].message,'error');
              
          }
          component.set("v.ShowSpinner","false");
      });
      $A.enqueueAction(det);
      
  },
  closePopUp : function(component, event, helper) {
      helper.closePopUpHelper(component, event, helper);
  }
})