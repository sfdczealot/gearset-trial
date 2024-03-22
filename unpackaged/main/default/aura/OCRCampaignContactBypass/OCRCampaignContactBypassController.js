({
	    doInit : function(cmp, event, helper) {
        
        let action = cmp.get('c.checkValidations');
        action.setParams({
            oppId : cmp.get('v.recordId')
        });
        action.setCallback(this,result=>{
            if (result.getState() === "SUCCESS") {
                helper.showToastMessage(cmp,event,'Success','Validation successful.','pester','success');
                $A.get('e.force:refreshView').fire();
            }else{
                var errors = result.getError(); 
                helper.showToastMessage(cmp,event,'Error',errors[0].message,'sticky','error');
            }
    		$A.get("e.force:closeQuickAction").fire(); 
        });
        $A.enqueueAction(action);
    }
})