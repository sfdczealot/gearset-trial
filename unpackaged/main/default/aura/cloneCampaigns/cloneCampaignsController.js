({
    
    cloneConfirm : function(component, event, helper) {
        
        let button = event.getSource();
        button.set('v.disabled',true);
        
        var object;
        var action = component.get("c.cloneChild");
        console.log(component.get("v.recordId"));
        var recordId =[];
        recordId.push(component.get("v.recordId"));
        action.setParams({ objectAPIName : 'Campaign',
                          recordIds : recordId
                         });
        action.setCallback(this, function(response) {
            var state = response.getState();
            if (state === "SUCCESS") {
                object = response.getReturnValue();
                if(object == null) {
                  var msg = $A.get("$Label.c.GENERAL_ERROR_EDIT");
                  helper.showtoast(component, event, helper,'ERROR',msg);
                }
                else {
                helper.showtoast(component, event, helper,'SUCCESS','Records have been successfully cloned');
                var currentURL = 'lightning/r/Campaign/'+object.Id+'/view?0.source=alohaHeader';
                console.log(currentURL) ;
                
                var urlEvent = $A.get("e.force:navigateToURL");
                urlEvent.setParams({
                    "url": '/'+currentURL
                });
                console.log(currentURL);
                
                window.open('https://'+window.location.hostname+'/'+currentURL);
            }
                
            }else{
                helper.showtoast(component, event, helper,'Error','Records failed to clone');   
            }
            
            helper.closePopup(component, event, helper);
        });
        
        $A.enqueueAction(action);
        
    },
    closeModel: function(component, event, helper) {
        helper.closePopup(component, event, helper);
    }
})