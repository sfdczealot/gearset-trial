({
    doInit : function(cmp, event, helper) {
        helper.getData(cmp);
        helper.getPaymentMethodRecord(cmp);
    },
    doSave : function(cmp,event,helper) {
        
        let paymentMethodId = cmp.find("paymentMethodId").get("v.value");
        let userProfile = cmp.get('v.userProfile');
        let paymentMethodList = cmp.get('v.paymentMethodList');
        let paymentMethodName = '';
        paymentMethodList.find(item=>{
            if(item.Id.includes(paymentMethodId))
            paymentMethodName = item.Name;
        })
        if(paymentMethodName.includes('Adyen') || paymentMethodName.includes('Braintree') || paymentMethodName.includes('Paypal') || paymentMethodName.includes('Installment_Online')){
            if(userProfile != 'System Administrator' && userProfile != 'Delegated System Administrator' && userProfile != 'API User Profile'){
                helper.showToast(cmp,'ERROR', 'Payment Creation not allowed! only system admin can create payment record with Adyen,BrainTree and Paypal.');
                return ;
            }
                
        }
        helper.createPaymentRec(cmp);
    },
    redirectToOpportunity : function(cmp){
        
        window.location = '/'+cmp.get('v.oppId');
    },
   showAppr : function(cmp){
        if(cmp.get("v.oppObj").Country__c=='Thailand'){
        var paymentRec = cmp.get('v.createPayment');
        paymentRec.Appr_Code__c=null;
         cmp.set('v.createPayment',paymentRec);
        let paymentMethodId = cmp.find("paymentMethodId").get("v.value");
        let paymentMethodList = cmp.get('v.paymentMethodList');
        for(var pm in paymentMethodList){
            if(paymentMethodId == paymentMethodList[pm].Id && paymentMethodList[pm].NS_Internal_ID__c == '32'){
                cmp.set('v.isApprCode',true);
                break;
            }
            else{
                cmp.set('v.isApprCode',false);
            }

        }
        }
    }
})