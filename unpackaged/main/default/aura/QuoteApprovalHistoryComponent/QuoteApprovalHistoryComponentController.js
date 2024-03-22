({
	doInit : function(cmp, event, helper) {
		
        helper.approvalHistory(cmp);
        
	},
    approvalProcessRecall : function(cmp, event, helper){
        
        var action = cmp.get('c.recallApprovalProcess');
        action.setParams({
           recordId : cmp.get('v.quoteId'),
           rejectComment : cmp.get('v.comment')
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                cmp.set('v.isModal',false);
                helper.showToastMessage(cmp,'Success','Successfully Recalled.');
                cmp.set('v.comment','');
                helper.approvalHistory(cmp);
            }else{
                var errors = response.getError(); 
                cmp.set('v.isModal',false);
                helper.showToastMessage(cmp,'ERROR',errors[0].message);
                cmp.set('v.comment','');
                helper.approvalHistory(cmp);
            }
        });
        $A.enqueueAction(action);
    },
    openModal : function(cmp, event, helper){
        
        let eventName = event.getSource().get('v.label');
        
        if(eventName == 'Recall'){
            cmp.set('v.isModal',true);
        }
        if(eventName == 'Approve'){
            cmp.set('v.isModalApproved',true);
        }
        if(eventName == 'Reject'){
            cmp.set('v.isModalReject',true);
        }
       
    },
    closeModal : function(cmp, event, helper){
       
        let eventName = event.getSource().get('v.name');
        
        if(eventName == 'recallApprovel'){
            cmp.set('v.isModal',false);
        }
        if(eventName == 'ApproveApprovel'){
            cmp.set('v.isModalApproved',false);
        }
        if(eventName == 'rejectApprovel'){
            cmp.set('v.isModalReject',false); 
        }
        cmp.set('v.comment','');
        helper.approvalHistory(cmp);
    },
    approvalProcessApproved : function(cmp,event,helper){
        
        let eventMsg = event.getSource().get('v.label');
        let actionMsg = 'Approve';
        helper.approveAndRejectRecord(cmp,event,actionMsg,eventMsg);
    },
    approvalProcessReject : function(cmp,event,helper){
        
        let eventMsg = event.getSource().get('v.label');
        let actionMsg = 'Reject';
        helper.approveAndRejectRecord(cmp,event,actionMsg,eventMsg);
    }
})