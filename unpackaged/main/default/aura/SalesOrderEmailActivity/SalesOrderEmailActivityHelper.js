({
    showToast : function(component, event, helper, title,message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            key: 'info_alt',
            type: type,
            mode: 'dismissible'
        });
        toastEvent.fire();
    },
    getDets : function(component, event, helper, title,message,type) {
        var det = component.get("c.getDetails");
        det.setParams({"salesOrderId":   component.get("v.recordId")  });
        
        det.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                if(response.getReturnValue() == null){
                    component.set("v.isAuthorized",false); 
                }else{
                       component.set("v.wrapper", response.getReturnValue());
                    var startDate = new Date(); 
                    var endDate = new Date(component.get("v.wrapper").soDetails.SO_End_Date__c);
                    var timeDiffrence = Math.abs(endDate.getTime() - startDate.getTime());
                    var differDays = Math.ceil(timeDiffrence / (1000 * 3600 * 24)); 
                   component.set("v.differDays",differDays);
                 
                    component.set("v.isAuthorized",true);
                    var ATMList = [];
                    var ATMcheck =[];
                   for (var a in response.getReturnValue().ATMList){
                        
                         if(!ATMcheck.includes(response.getReturnValue().ATMList[a].User.Email)){
                              ATMcheck.push(response.getReturnValue().ATMList[a].User.Email)
                        ATMList.push({ 
                            "label":response.getReturnValue().ATMList[a].User.Name,
                            "value":response.getReturnValue().ATMList[a].User.Email})
                    }
                   }
                      for (var a in response.getReturnValue().OTMList){
                         
                         if(!ATMcheck.includes(response.getReturnValue().OTMList[a].User.Email)){
                               ATMcheck.push(response.getReturnValue().OTMList[a].User.Email)
                        ATMList.push({ 
                            "label":response.getReturnValue().OTMList[a].Name,
                            "value":response.getReturnValue().OTMList[a].User.Email})
                    }
                      }
                      component.set("v.options",ATMList);
                    var OCRList =[];
                      var OCRCheck =[];
                    for(var o in response.getReturnValue().OCRList){
                         
                         if(!OCRCheck.includes(response.getReturnValue().OCRList[o].ContactId)){
                              OCRCheck.push( 
                           response.getReturnValue().OCRList[o].ContactId)
                        OCRList.push({
                            "label":response.getReturnValue().OCRList[o].Contact.Name,
                            "value":response.getReturnValue().OCRList[o].ContactId})
                         }
                    }
                    component.set("v.OCR",OCRList);
                }
            }
            else{
                helper.showToast(component, event, helper,'Error','','error');
            }
        });
        $A.enqueueAction(det);
    }
})