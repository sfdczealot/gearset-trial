({
    doInit : function(component, event, helper) {
        
        helper.construct(component, event, helper);
        helper.fetchProfileName(component,event);
        
        
        var init0 = component.get("c.getUserInfoAndOppRecord");
        init0.setParams({"oppId": component.get("v.recordId")});
        init0.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                component.set("v.oppObj", response.getReturnValue().opp);
                let opportunityType = response.getReturnValue().opp.Opportunity_Type__c;
                if(opportunityType == 'B2C - Upgrade'){
                    component.set('v.dropdownValue',['Proceed','Clone quote and proceed']);
                }
            }
        });
        $A.enqueueAction(init0);
    },
    handleIsSynced : function (component, event, helper) {
        var idx = event.getSource().get("v.name");
        var toggleVal = component.get("v.AllQuotes");
        console.log('toggleVal'+toggleVal[idx]);
        var action = component.get("c.changeIsSyncingQuote");
        action.setParams({"objQuote": toggleVal[idx]});
        action.setCallback(this, function(response) {
            if (response.getState() === "SUCCESS") {
                helper.construct(component, event, helper);
                helper.showToastMessage(component,event,'Success','Quote Successfully Saved.','pester','success'); 
                $A.get('e.force:refreshView').fire();
            }else{
                var errors = response.getError(); 
                helper.construct(component, event, helper);
                helper.showToastMessage(component,event,'Error',errors[0].message,'sticky','error');
            }
        });
        $A.enqueueAction(action);
    },
    handleSelect : function (component, event, helper) {
        
        var stepName = event.getParam("detail").value;
        var idx = event.getSource().get("v.recordId");
        var recordId = component.get("v.recordId");
        if(stepName == 'Invalid'){
            //validation rule
            helper.QuoteValidation(component,event,stepName,idx);
            //helper.displayMessageQuote(component,event,idx,recordId);
            return;
        }else{
            helper.showToastMessage(component,event,'Error','You can not change Status Directly.','sticky','error');
            return;
        }
        //if(stepName == 'Expired'){
         //   helper.showToastMessage(component,event,'Error','You can not change Status to Expired.','sticky','error');
         //   return;
        //}
        //helper.handleSelectStatus(component, event, stepName,idx,recordId,'','');
    },
    handleClone : function (component, event, helper) {
        var quoId = event.getSource().get('v.value');
        helper.handleCloneRecord(component, event,helper, quoId);
    },
    handleSuccess: function(component, event, helper) {
        helper.showToastMessage(component,event,'Success','Quote Successfully Saved.','pester','success'); 
        helper.construct(component, event, helper);
        $A.get('e.force:refreshView').fire();
    },
    handleError : function(component, event, helper) {
        var error = event.getParam("error");
        var msg = event.getParam('detail');
        console.log('--------'+error);
        console.log('--msg--'+msg);
        var toastEvent = $A.get("e.force:showToast");
        component.find('notifLib').showToast({
            "title": "Error!",
            "message": msg
        });
    },
    goToAddProduct:function(component,event,helper){
        var quoteRecord = event.getSource().get('v.value');
        var evt = $A.get("e.force:navigateToComponent");
        var device = $A.get("$Browser.formFactor");
        if(device==='DESKTOP'){
            evt.setParams({
                componentDef: "c:ProductSelectionLightningPageStinger",
                componentAttributes: {
                    quoteId : quoteRecord.Id,
                    oppId : quoteRecord.OpportunityId,
                    quoteObj : quoteRecord,
                    oppObj : component.get("v.oppObj")
                }
            });
        }
        else {
          evt.setParams({
                componentDef: "c:CloneProductSelectionLightningPageStinger",
                componentAttributes: {
                    quoteId : quoteRecord.Id,
                    oppId : quoteRecord.OpportunityId,
                    quoteObj : quoteRecord,
                    oppObj : component.get("v.oppObj")
                }
              
                
            });    
                    
        }        
        
        evt.fire();
    },
    onProceedClick:function(component,event,helper){
        var quoteRecord = event.getSource().get('v.value');
        var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:ReadyforPaymentValidationStinger",
                componentAttributes: {
                    quoteId : quoteRecord.Id,
                    oppId : quoteRecord.OpportunityId
                }
            });
            
            evt.fire();
       
    },
    goToReadyForPayment:function(component,event,helper){
        
        var quoteRecord = event.getSource().get('v.value');
        console.log('----gotoreadyforpayment--'+quoteRecord.Tax_Reg_Number__c);
        if(quoteRecord.Country__c=='Thailand'){
            component.set("v.isPaymentModal", true);
            component.set("v.quoteObj",quoteRecord);
            console.log('----gotoreadyforpayment--'+component.get("v.quoteObj").AdditionalName);
        }else{
            var evt = $A.get("e.force:navigateToComponent");
            evt.setParams({
                componentDef: "c:ReadyforPaymentValidationStinger",
                componentAttributes: {
                    quoteId : quoteRecord.Id,
                    oppId : quoteRecord.OpportunityId
                }
            });
            
            evt.fire();
        }
    },
    closeModel: function(component, event, helper) {
      component.set("v.isPaymentModal", false);
   },
    onCheckboxChange:  function(component, event, helper) {
      var checkVal=component.get("v.checkPayment");
      
   },
    goToSubmitForApproval:function(component,event,helper){
        var quoteRecord = event.getSource().get('v.value');
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ApprovalProcessStingerComponent",
            componentAttributes: {
                quoteId : quoteRecord.Id,
                oppId : quoteRecord.OpportunityId,
                isDisplayCmp : true
            }
        });
        
        evt.fire();
    },
    goToAddPayment:function(component,event,helper){
        var quoteRecord = event.getSource().get('v.value');
        var evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:CreateOfflinePayment",
            componentAttributes: {
                quoteId : quoteRecord.Id,
                oppId : quoteRecord.OpportunityId
            }
        });
        
        evt.fire();
    },
    gotoRelatedList : function (component, event, helper) {
        var quoteRecord = event.getSource().get('v.value');
        var relatedListEvent = $A.get("e.force:navigateToRelatedList");
        relatedListEvent.setParams({
            "relatedListId": "ProcessSteps",
            "parentRecordId": quoteRecord
        });
        relatedListEvent.fire();
    },
    goToApprovalProcess : function(component,event,helper){
        let quoteRecord = event.getSource().get('v.value');
        console.log('quoteRecord>>>',quoteRecord);
        let evt = $A.get("e.force:navigateToComponent");
        evt.setParams({
            componentDef: "c:ApprovalProcessStingerComponent",
            componentAttributes: {
                quoteId : quoteRecord.Id,
                oppId : quoteRecord.OpportunityId,
                quoteObj : quoteRecord
            }
        });
        evt.fire();
    },
    closeModal : function(component,event,helper){
        
        component.set('v.isModal',false);
        helper.construct(component, event, helper);
        $A.get('e.force:refreshView').fire();
    },
    handleChangeEvent : function(component,event,helper){
        
        let lossReasonFieldApiName = component.get('v.lossReasonFieldApiName');
        let lostSubReasonFieldApiName = component.get('v.lostSubReasonFieldApiName');
        let eventName = event.getSource().get('v.value');
        if(eventName){
           helper.fetchPicklistValues(component,lossReasonFieldApiName, lostSubReasonFieldApiName);
           //helper.getPickListValueMethod(component,event,lostSubReasonFieldApiName);
           //helper.getPickListValueMethod(component,event,lossReasonFieldApiName);
           component.set('v.btnStatus',false);
           component.set('v.displayLossAndLossSubReason',true);
           component.set('v.pilkListValueName',eventName);
        }
        if(eventName == ''){
           component.set('v.btnStatus',true); 
           component.set('v.displayLossAndLossSubReason',false);
        }
    },
    handleSaveResult : function(component,event,helper){
        
        let stepName = component.get('v.stepName');
        let idx = component.get('v.quoteId');
        let recordId = component.get("v.recordId");
        let eventName = component.get('v.pilkListValueName');
        if(eventName == 'Proceed'){
            component.set('v.resultStatus',true);
            component.set('v.isModal',false);
            $A.get('e.force:refreshView').fire();
        }
        if(eventName == 'Clone quote and proceed'){
            component.set('v.isModal',false);
            helper.handleCloneRecord(component, event,helper, idx);
            $A.get('e.force:refreshView').fire();
        }
        if(eventName == 'Create new quote and proceed'){
            component.set('v.isModal',false);
            helper.createQuote(component,event,idx); 
            $A.get('e.force:refreshView').fire();
        }
        let resultStatus = component.get('v.resultStatus');
        let lostSubReason = component.get('v.lostSubReasonSelectedValue');
        let lossReason = component.get('v.lossReasonSelectedValue');
        if(lostSubReason.includes('--- None ---')){
            lostSubReason = '';
        }
        console.log('lostSubReason>>> ',lostSubReason);
        console.log('lossReason>>> ',lossReason);
        if(resultStatus){
            helper.handleSelectStatus(component, event, stepName,idx,recordId,lossReason,lostSubReason);
        }
        helper.construct(component, event, helper);
    },
    changeControlField : function(component, event, helper) {     
        var controllerValueKey = event.getSource().get("v.value"); 
        var depnedentFieldMap = component.get("v.depnedentFieldMap");
        
        if (controllerValueKey != '--- None ---') {
            var ListOfDependentFields = depnedentFieldMap[controllerValueKey];
            
            if(ListOfDependentFields.length > 0){
                component.set("v.isDisabledDependentField" , false);  
                helper.fetchDepValues(component, ListOfDependentFields);    
            }else{
                component.set("v.isDisabledDependentField" , true); 
                component.set("v.lostSubReasonSelectedValue", ['--- None ---']);
            }  
            
        } else {
            component.set("v.lostSubReasonSelectedValue", ['--- None ---']);
            component.set("v.isDisabledDependentField" , true);
        }
    },
    showEmailPopup: function(component, event, helper) {
        //true 
        component.set('v.showEmail',true);
        component.set("v.emailID",event.getSource().get('v.value').Account_Email__c);
        component.set("v.currentQuoteID",event.getSource().get('v.value').Id);
       component.set("v.currentEmailId",event.getSource().get('v.value').Account_Email__c); 
    },
    resendPaymentEmail : function(component, event, helper) {
        
        var emailField = component.find('NewEmail');
        var sendEmail=false;
        var emailFieldValue = emailField.get("v.value");
        // Store Regular Expression
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;           
        
        if(!$A.util.isEmpty(emailFieldValue) && !(emailFieldValue.match(regExpEmailformat))){
            $A.util.addClass(emailField, 'slds-has-error');
            emailField.set("v.errors", [{message: "Please Enter a Valid Email Address"}]);               
            
        } 
        else if($A.util.isEmpty(emailFieldValue)){
            $A.util.addClass(emailField, 'slds-has-error');
            emailField.set("v.errors", [{message: "Email Address cannot be blank"}]);
        }
            else{
                let recordId = component.get("v.currentQuoteID");
                let action = component.get('c.resendPaymentEmailMethod');
                action.setParams({
                    recordId : recordId,
                    quoteEmail : emailFieldValue
                });
                action.setCallback(this,result=>{
                    if (result.getState() === "SUCCESS") {
                    helper.showToastMessage(component,event,'Success','Payment Email Sent Successfully.','pester','success');
                    component.set('v.showEmail',false);	
                    helper.construct(component, event, helper);
                    $A.get('e.force:refreshView').fire();
                }else{
                                   let errors = result.getError(); 
                helper.showToastMessage(component,event,'Error',errors[0].message,'sticky','error');
                helper.construct(component, event, helper);
                $A.get('e.force:refreshView').fire();
            }
    });
    $A.enqueueAction(action);   
}
 
 },
 closeEmailModal : function(component, event, helper) {
    component.set('v.showEmail',false);
}
})