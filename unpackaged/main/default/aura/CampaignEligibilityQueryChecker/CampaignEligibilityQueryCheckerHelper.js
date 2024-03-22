({
	 showToastMessage : function(cmp,event,title,message,mode,type){
        
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            title : title,
            message: message,
            duration:'5000',
            type: type,
            mode: mode,
            key: 'info_alt'
        });
        toastEvent.fire();
    }
})