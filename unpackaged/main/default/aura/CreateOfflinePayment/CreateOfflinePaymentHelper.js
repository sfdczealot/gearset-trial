({
    getData : function(cmp){
        
        let init0 = cmp.get("c.getUserInfoAndOppRecord");
        init0.setParams({"oppId": cmp.get("v.quoteId")});
        init0.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                let quoteObj = response.getReturnValue().quo;
                cmp.set("v.quoteObj", quoteObj);
                cmp.set("v.oppObj", response.getReturnValue().opp);
                cmp.set("v.userProfile", response.getReturnValue().userProfile);
                cmp.set("v.createPayment", response.getReturnValue().payment);
                
            }
        });
        $A.enqueueAction(init0);  
    },
	getPaymentMethodRecord : function(cmp) {
		
        let action = cmp.get('c.getPaymentMethod');
        action.setCallback(this,result=>{
            cmp.set('v.paymentMethodList',result.getReturnValue());
        });
        $A.enqueueAction(action);
	},    
    createPaymentRec : function(cmp){
        
       cmp.set('v.isLoading',true);
       let action = cmp.get('c.savePayment');
        action.setParams({
            payment : cmp.get('v.createPayment')
        });
        action.setCallback(this,result=>{
            if(result.getState() == "SUCCESS") {
            	cmp.set('v.isLoading',false);
            	if (!result.getReturnValue().includes('Error')) {
                this.showToast(cmp,'SUCCESS', 'Success');
                if(result.getReturnValue() == 0){
                   window.location = '/'+cmp.get('v.oppId');
            	}
                this.getData(cmp);
        	}else{
        		  this.showToast(cmp,'ERROR', result.getReturnValue());   
                  this.getData(cmp);
                 }
        }else if(result.getState() == "ERROR"){
            	cmp.set('v.isLoading',false);
                this.showToast(component,'ERROR', result.getError()[0].message);
                this.getData(cmp);
            }
        });
        $A.enqueueAction(action);
    },
    showToast : function(cmp, title, message) {
            
            let toastEvent = $A.get("e.force:showToast");
            toastEvent.setParams({
                "type": title,
                "title": title,
                "message": message
            });
            toastEvent.fire();
   },
})