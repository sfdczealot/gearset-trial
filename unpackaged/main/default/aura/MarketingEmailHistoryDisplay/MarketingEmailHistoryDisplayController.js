({
	doInit : function(component, event, helper) {
		
        var action  = component.get('c.getMarketingEmail');
        action.setParams({
            accId : component.get('v.recordId')
        });
        action.setCallback(this,(result)=>{
            component.set('v.MarketingEmailList',result.getReturnValue());
          
        })
        $A.enqueueAction(action);
	},
    selectedEmailContent : function(component, event, helper) {
       var marketingConId = event.getSource().get('v.title');
       helper.getEmailContent(component, event,marketingConId);   
    }
})