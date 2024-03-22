({
    doInit : function(cmp, event, helper) {
		
        helper.accountRecord(cmp, event);
	},
	doSave : function(cmp, event, helper) {
		
        helper.createRecord(cmp, event);
	},
    handleCheckbox : function(cmp, event, helper) {
        
        let eventCheck = event.getSource().get('v.checked');
        if(eventCheck){
            cmp.set('v.isdisabled',false);
        }else{
           cmp.set('v.isdisabled',true); 
        }
    }
})