({
    afterRecordUpdate : function(component, event, helper) {
        console.log('--HandleRecordUpdated called--'+component.get("v.simpleRecord.Opportunity_Type__c"));
        var eventParams = event.getParams();
        if(eventParams.changeType === "LOADED") {
            var dismissActionPanel = $A.get("e.force:closeQuickAction");
            var refresh = $A.get("e.force:refreshView");
        
            if(component.get("v.simpleRecord.StageName")=='Closed Won' || component.get("v.simpleRecord.StageName")=='Closed Lost'){
                component.set("v.recordError",'Cannot created quote for closed opportunity.');
                return;
            }else if(component.get("v.simpleRecord.Opportunity_Type__c")=='undefined' || component.get("v.simpleRecord.Opportunity_Type__c")==null || component.get("v.simpleRecord.Opportunity_Type__c")=='' ){
                component.set("v.recordError",'Not a valid B2C opportunity.');
                return;
            }else if(component.get("v.simpleRecord.Opportunity_Type__c")=='B2C - Upgrade' ){
                component.set("v.recordError",'Cannot create quote for B2C-Upgrade opportunity.');
                return;
            }else if(component.get("v.simpleRecord.Opportunity_Type__c")=='B2C - Standard' ){
                component.set("v.recordError",'Cannot create quote for B2C-Standard opportunity.');
                return;
            }
            var action = component.get("c.createRenewalQuoteMethod");
            action.setParams({"oppId": component.get("v.recordId"), "oppName": component.get("v.simpleRecord.Opportunity_Type__c")});
            action.setCallback(this, function(response) {
                if (response.getState() === "SUCCESS") {
                    dismissActionPanel.fire(); 
                    refresh.fire();
                    helper.showToastMessage(component,event,'Success','Quote Successfully Saved.','pester','success'); 
                    
                }else{
                    var errors = response.getError(); 
                    helper.showToastMessage(component,event,'Error',errors[0].message,'sticky','error');
                }
            });
            $A.enqueueAction(action);
            
        }
        
    }
})