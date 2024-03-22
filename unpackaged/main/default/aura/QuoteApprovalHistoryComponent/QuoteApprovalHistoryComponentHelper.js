({
    approvalHistory : function(cmp) {
        
        let action = cmp.get('c.getApprovalHistory');
        if( typeof cmp.get('v.quoteId') === 'undefined'){
            cmp.set('v.quoteId',cmp.get('v.recordId'));
        }
        action.setParams({
            recordId : cmp.get('v.quoteId')
        });
        action.setCallback(this,result=>{
            let resultValue = result.getReturnValue();
            
            //cmp.set('v.processInstanceStepList',resultValue);
            let newprocessInstanceStepList = [];
            let userId = [];
            for(let i=0;i<resultValue.length;i++){
            cmp.set("v.SobjectType",resultValue[i].SobjectType);
                if(resultValue[i].stepStatus.includes('Started')){
                	resultValue[i].stepStatus = 'Submitted';
            	}
                if(resultValue[i].stepStatus.includes('Removed')){
                	resultValue[i].stepStatus = 'Recalled';
            	}
                newprocessInstanceStepList.push(resultValue[i]);
                if(resultValue[i].actorId != undefined || resultValue[i].actorId != null)
            	userId.push(resultValue[i].actorId);
        	}
            cmp.set('v.processInstanceStepList',newprocessInstanceStepList);
            //console.log('userId--->>> ',JSON.stringify(userId));  
            //console.log('userId--->>> ',userId.length);  
            this.getUserName(cmp,event,userId);
        });
        $A.enqueueAction(action);
    },
    showToastMessage : function(cmp,title,message){
        
        let toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": title,
            "title": title,
            "message": message
        });
        toastEvent.fire();
    },
    approveAndRejectRecord : function(cmp,event,actionMsg,eventMsg){
        
        let action = cmp.get('c.approveAndRejectApprovalProcess');
        action.setParams({
            recordId : cmp.get('v.quoteId'),
            actionMsg : actionMsg,
            commentMsg : cmp.get('v.comment')
        });
        action.setCallback(this,result=>{
            if (result.getState() === "SUCCESS") {
                if(eventMsg == 'Approve'){
                   cmp.set('v.isModalApproved',false);
               	   this.showToastMessage(cmp,'Success','Successfully Approved.');
            	}
                if(eventMsg == 'Reject'){
                    cmp.set('v.isModalReject',false);
                    this.showToastMessage(cmp,'Success','Successfully Rejected.');
            	}
                cmp.set('v.comment','');
                this.approvalHistory(cmp);
            }else{
                let errors = result.getError(); 
                if(eventMsg == 'Approve'){
                   cmp.set('v.isModalApproved',false);
            	}
                if(eventMsg == 'Reject'){
                    cmp.set('v.isModalReject',false);
            	}
                this.showToastMessage(cmp,'ERROR',errors[0].message);
                cmp.set('v.comment','');
                this.approvalHistory(cmp);
            }
        });
       	$A.enqueueAction(action);
    },
    getUserName : function(cmp,event,userId){
            
        let action = cmp.get('c.getUserProfile');
        action.setCallback(this,result=>{
            let resultValue = result.getReturnValue();
            let usId = resultValue.Id;
            cmp.set('v.profileName',resultValue.Profile.Name);
            //alert('ProfileName---> '+resultValue.Profile.Name);
            userId.find(item=>{
            if(item == usId){
            	cmp.set('v.approverName',resultValue.Name);
                if(resultValue && resultValue.DelegatedApproverId){
                	cmp.set('v.delegatedApproverId',resultValue.DelegatedApproverId);
                    //alert('delegatedApprover--->>> '+resultValue.DelegatedApproverId);
            	}
                //alert('Name--->>> '+resultValue.Name);
        	}
        	})
        });
        $A.enqueueAction(action);
    }
})