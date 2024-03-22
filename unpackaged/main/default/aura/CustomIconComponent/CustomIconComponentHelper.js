({
	getIconImage : function(cmp, event) {
	
        let recordId = cmp.get('v.recordId');
        let action = cmp.get('c.getCountryAndTier');
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this,result=>{
            
            let resultValue = result.getReturnValue();
            
            if(resultValue && resultValue.rewardTier != undefined && resultValue.rewardTier != null)
            	cmp.set('v.rewardTier',result.getReturnValue().rewardTier);
            
            if(resultValue && resultValue.country != undefined && resultValue.country != null)
            	cmp.set('v.country',resultValue.country);
            
        });
        $A.enqueueAction(action);
	}
})