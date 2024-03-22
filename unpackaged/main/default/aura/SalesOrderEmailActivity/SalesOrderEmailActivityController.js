({
	doInit : function(component, event, helper) {

		helper.getDets(component, event, helper);
	},
    SendEmail: function(component, event, helper){
        if(component.find("PicklistId").get("v.value") == null || component.find("PicklistId").get("v.value")=='' || component.find("PicklistId").get("v.value") == undefined){
                helper.showToast(component, event, helper,'Error','Please select Recipient','error');
            return;
        }
         var det = component.get("c.sendRemMail");
        det.setParams({"SOId":    component.get("v.recordId")  ,
                       "conId": component.find("PicklistId").get("v.value"),
                       "ccRecipient": component.find("ccId").get("v.value"),
                       "language": component.get("v.language")});
        component.get("v.recordId")  
        det.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.wrapper", response.getReturnValue());
                  helper.showToast(component, event, helper,'Success','Mail has been sent successfully','success')
                  helper.getDets(component, event, helper);
            } else{
                var errors = response.getError();    
                helper.showToast(component, event, helper,'Error',errors[0].message,'error');
            }
        });
        $A.enqueueAction(det);
   
    },
    emailTemp: function (component, event, helper) {       

       
         var det = component.get("c.sendTestMail");
        det.setParams({"SOId":    component.get("v.recordId")  ,
                      
                       "language": component.get("v.language")});

        det.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
               // component.set("v.wrapper", response.getReturnValue());
                  helper.showToast(component, event, helper,'Success','Mail has been sent successfully','success')
                  helper.getDets(component, event, helper);
            } else{
                var errors = response.getError();    
                helper.showToast(component, event, helper,'Error',errors[0].message,'error');
            }
        });
        $A.enqueueAction(det);
        
    }
})