({
	getEmailContent : function(component,event,marketingConId) {
		
        let action = component.get('c.getHtmlEmailContent');
        action.setParams({
            mId : marketingConId
        });
        action.setCallback(this,(result)=>{
            component.set('v.mapOfHtmlContent',result.getReturnValue());
           
        });
        $A.enqueueAction(action);
	}
})