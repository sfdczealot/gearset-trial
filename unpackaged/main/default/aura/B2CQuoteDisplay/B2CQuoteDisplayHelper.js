({
	construct : function(component, event, helper) {
		var action = component.get("c.getQutoes");
        action.setParams({"oppId": component.get("v.recordId")});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                var allrecords = response.getReturnValue();
                component.set("v.AllQuotes", allrecords);
            }
        });
        $A.enqueueAction(action);
	},
    handleSelectStatus : function(component, event, stepName,idx,recordId,lossReason,lostSubReason) {
        
        var action = component.get("c.changeQuoteStatus");
        action.setParams({
            "quoteID": idx,
            "quoteStatus": stepName,
            "oppId":recordId,
            "lossReason" : lossReason,
            "lostSubReason" : lostSubReason
        });
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                this.showToastMessage(component,event,'Success','Quote Successfully Saved.','pester','success');
                $A.get('e.force:refreshView').fire();
            }else{
                var errors = response.getError(); 
                this.showToastMessage(component,event,'Error',errors[0].message,'sticky','error');
            }
        });
        $A.enqueueAction(action);
        //navEvt.fire();
    },
    createQuote : function(component,event,quoteId){
        
        let resultStatus = component.get('v.resultStatus');
        let lostSubReason = component.get('v.lostSubReasonSelectedValue');
        let lossReason = component.get('v.lossReasonSelectedValue');
        if(lostSubReason.includes('--- None ---')){
            lostSubReason = '';
        }
        let stepName = component.get('v.stepName');
        let idx = component.get('v.quoteId');
        let recordId = component.get("v.recordId");
        let action = component.get('c.createQuoteMethod');
        action.setParams({
            quoId : quoteId
        });
        action.setCallback(this,result=>{
            if (result.getState() === "SUCCESS") {
                this.showToastMessage(component,event,'Success','New quote creation is successful.','pester','success');
            	this.handleSelectStatus(component, event, stepName,idx,recordId,lossReason,lostSubReason);
            }else{
                let errors = result.getError(); 
                this.showToastMessage(component,event,'Error',errors[0].message,'sticky','error');
            }
        });
        $A.enqueueAction(action);
    },
    handleCloneRecord : function (component, event,helper, quoId) {
        
        let resultStatus = component.get('v.resultStatus');
        let lostSubReason = component.get('v.lostSubReasonSelectedValue');
        let lossReason = component.get('v.lossReasonSelectedValue');
        if(lostSubReason.includes('--- None ---')){
            lostSubReason = '';
        }
        let stepName = component.get('v.stepName');
        let idx = component.get('v.quoteId');
        let recordId = component.get("v.recordId");
        var action = component.get("c.cloneQuote");
        action.setParams({"quoteID": quoId,
                          "step" : stepName});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                this.construct(component, event, helper);
                this.showToastMessage(component,event,'Success','Cloned Quote Successfully Saved.','pester','success');
                this.handleSelectStatus(component, event, stepName,idx,recordId,lossReason,lostSubReason);
            }else{
                var errors = response.getError(); 
                this.construct(component, event, helper);
                this.showToastMessage(component,event,'Error',errors[0].message,'sticky','error');
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
    displayMessageQuote : function(component,event,quoteId,oppId){
        
        let action = component.get('c.checkQuoteStatusExpiredAndInvalid');
        action.setParams({
            quoId : quoteId,
            oppId : oppId
        });
        action.setCallback(this,result=>{
            let status = result.getReturnValue();
            if(status != true){
             	 component.set('v.displayMessage','Are you sure you want to invalidate the quote?');
        	}else{
                 component.set('v.displayMessage','This is the last valid quote available for this Opportunity.Are you sure you want to invalidate the quote?');                      
                 }
        });
        $A.enqueueAction(action);
    },
    QuoteValidation : function(component,event,stepName,quoId){
            
        let action = component.get('c.invalidQuoteValidation');
        action.setParams({
            newStepName : stepName,
            quoteId : quoId
        });
        action.setCallback(this,result=>{
            let status = result.getReturnValue();
            console.log('status>>> ',status);
            if (result.getState() === "SUCCESS") {
                component.set('v.stepName',stepName);
                component.set('v.quoteId',quoId);
                component.set('v.isModal',true);
                this.displayMessageQuote(component,event,quoId,component.get("v.recordId"));
                //this.showToastMessage(component,event,'Success','Cloned Quote Successfully Saved.','pester','success');
            }else{
                var errors = result.getError(); 
                this.showToastMessage(component,event,'Error',errors[0].message,'sticky','error');
            }
        });
        $A.enqueueAction(action);
   },
   getPickListValueMethod : function(component,event,fieldApiName){
           
       let action = component.get('c.getPickListValue');
       action.setParams({
           objectApiName : 'Quote',
           fieldApiName : fieldApiName
       });
       action.setCallback(this,result=>{
           	if(fieldApiName == 'Loss_Reason__c'){
               component.set('v.lossReasonList',result.getReturnValue());
       		}
            if(fieldApiName == 'Lost_Sub_Reason__c'){
               component.set('v.lostSubReasonList',result.getReturnValue());
       		}
       });
       $A.enqueueAction(action);
  },
  fetchPicklistValues: function(component,lossReason, lostSubReason) {
        
        let action = component.get("c.getDependentMap");
        action.setParams({
            'contrfieldApiName': lossReason,
            'depfieldApiName': lostSubReason 
        });
        action.setCallback(this,response=> {
            if (response.getState() == "SUCCESS") {
                let StoreResponse = response.getReturnValue();
                component.set("v.depnedentFieldMap",StoreResponse);
                
                let listOfkeys = []; 
                let ControllerField = []; 
                
                for (let singlekey in StoreResponse) {
                    listOfkeys.push(singlekey);
                }
                
                if (listOfkeys != undefined && listOfkeys.length > 0) {
                    ControllerField.push('--- None ---');
                }
                
                for (let i = 0; i < listOfkeys.length; i++) {
                    ControllerField.push(listOfkeys[i]);
                }  
                component.set("v.lossReasonList", ControllerField);
            }else{
                alert('Something went wrong..');
            }
        });
        $A.enqueueAction(action);
    },
    
    fetchDepValues: function(component, ListOfDependentFields) {

        let dependentFields = [];
        dependentFields.push('--- None ---');
        for (let i = 0; i < ListOfDependentFields.length; i++) {
            dependentFields.push(ListOfDependentFields[i]);
        }
        component.set("v.lostSubReasonList", dependentFields);
    },
    fetchProfileName : function(component,event){
      
        let action = component.get('c.getProfileName');
        action.setCallback(this,result=>{
            component.set('v.profileName',result.getReturnValue());
        });
        $A.enqueueAction(action);
   }
})