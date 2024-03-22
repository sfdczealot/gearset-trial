({
    showToast : function(component, event, helper, title,message,type) {
        component.set("v.ShowSpinner",false);
       
        
          /*  var toastEvent = $A.get("e.force:showToast");
            
            if(type=='success'){
                var dismissActionPanel = $A.get("e.force:closeQuickAction");
                dismissActionPanel.fire();
                $A.get('e.force:refreshView').fire();
            }
            toastEvent.setParams({
                title : title,
                message: message,
                duration:' 5000',
                key: 'info_alt',
                type: type,
                mode: 'dismissible'
            });
            toastEvent.fire();*/
        
        
            component.set("v.isToast",true);
                        
            let delay = 4000;
            setTimeout(() => {
                this.closePopUpHelper(component, event, helper);
            }, delay );
                
                var toastClass = component.find('toastDiv');
                if(title=='Success'){
                component.set("v.toastButton","utility:check");
                $A.util.addClass(toastClass, 'slds-notify slds-notify_toast slds-theme_success');
                $A.util.removeClass(toastClass, 'slds-notify slds-notify_toast slds-theme_error');
                
            }else if(title=='Error'){
                component.set("v.toastButton","utility:error");
                $A.util.removeClass(toastClass, 'slds-notify slds-notify_toast slds-theme_success');
                $A.util.addClass(toastClass, 'slds-notify slds-notify_toast slds-theme_error');
                
             } 
             component.set("v.endResult",title);
            component.set("v.message",message);

          
                
            },
            closePopUpHelper : function(component, event, helper) {
                    component.set("v.isToast","false");
                    sforce.one.navigateToSObject(component.get("v.recordId"));
                }
  })