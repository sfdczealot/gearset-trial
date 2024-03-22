({
    accountRecord : function(cmp, event) {
		
        cmp.set('v.isLoading',true);
        let recordId = cmp.get('v.recordId');
        let action = cmp.get('c.getAccount');
        action.setParams({
            recordId : recordId
        });
        action.setCallback(this,result=>{
            cmp.set('v.accountData',result.getReturnValue());
            setTimeout(()=>{
            	cmp.set('v.isLoading',false);
        	}, 2000);
        });
        $A.enqueueAction(action); 
	},
	createRecord : function(cmp, event) {
		
        let recordId = cmp.get('v.recordId');
        let action = cmp.get('c.createActivityRecord');
        action.setParams({
            acId : recordId
        });
        action.setCallback(this,result=>{
            if (result.getState() === "SUCCESS") {
                this.navigate(cmp, event, recordId);
                this.showToastMessage(cmp,event,'Success','Activity Record Successfully Created.','pester','success');
                $A.get('e.force:refreshView').fire();
            }else{
                this.navigate(cmp, event, recordId);
                this.showToastMessage(cmp,event,'Error','Error Record not Created.','sticky','error');
            }
        });
        $A.enqueueAction(action); 
	},
    showToastMessage : function(component,event,title,message,mode,type){
        
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:' 5000',
            type: type,
            mode: mode,
            key: 'info_alt'
        });
        toastEvent.fire();
    },
    navigate : function(cmp, event, recordId) {
        let nagigateLightning = cmp.find('navigate');
        let pageReference = {    
           "type": "standard__recordPage",
           "attributes": {
               "recordId": recordId,
               "objectApiName": "Account",
               "actionName": "view"
           }
        }
        nagigateLightning.navigate(pageReference);
    }
})