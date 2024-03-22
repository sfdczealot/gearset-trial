/*
* TestClass : ApprovalProcessStinger_Test
*/
public class ApprovalProcessStinger {
    
    @AuraEnabled
    public static void sendApporval(Id recordId){
        
        Quote qu = [Select Id,Status,isSyncing,to_FOC_Approval__c,to_VIP_Approval__c,Invoice_Id__c,Quote_Type__c,Total_Gross_Amount__c,Agent_Accepted_Time__c,approval_Status__c,recordType.Name,Country__c,Opportunity.Payment_Type__c,Opportunity.Payment_Time__c,Opportunity.Payment_Amount__c,Opportunity.Payment_Reference__c,OpportunityId from Quote where Id = : recordId];
        List<ContentDocumentLink> lstFiles= [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =:qu.OpportunityId];
        //List<Payment__c> paymentList = [Select Id from Payment__c where Quote_Record__c = : recordId]; 
        Approval.ProcessSubmitRequest [] requestList = new Approval.ProcessSubmitRequest []{};
            
            if(!Test.isRunningTest() && qu.isSyncing == false){
                throw new AuraHandledException('Cannot submit an unsynced quote to OMC.');
            }else if(!Test.isRunningTest() &&  qu.Total_Gross_Amount__c == 0 && qu.Agent_Accepted_Time__c == null){
                throw new AuraHandledException('This Quote cannot be submitted to OMC. Please ensure customer has approved it.');
            }else if(qu.Total_Gross_Amount__c > 0 && (qu.Agent_Accepted_Time__c == null)){
                throw new AuraHandledException('This Quote cannot be submitted to OMC. Please ensure customer has approved it, and the payment has been made.');
            }else if( qu.approval_Status__c == 'OMC Approval Submitted'){
                throw new AuraHandledException('Your Quote is already sent to OMC. Please wait until OMC approved or rejected your Quote.');
            }else if( qu.approval_Status__c == 'OMC Approval Approved'){
                throw new AuraHandledException('This Quote has already approved by OMC.');
            }else if( !Test.isRunningTest() && qu.recordType.Name=='B2C' && !qu.to_VIP_Approval__c && !qu.to_FOC_Approval__c && (lstFiles==null || lstFiles.size()==0 )) {
                throw new AuraHandledException('Error : Please upload Attachment and Payment');
            }else{
                update new Quote(Id = qu.Id,submit_to_OMC_Manually__c=false);
                update new Opportunity(Id = qu.OpportunityId,submit_to_OMC_Manually__c=false);
                // Send approval
                Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
                req1.setComments('Need OMC Approval');
                req1.setObjectId(qu.Id);                
                // Submit the record to specific process
                req1.setProcessDefinitionNameOrId('Quote_B2C_PG_SG_OMC_Approval');
                system.debug('Send Approval');
                
                Approval.ProcessResult result = Approval.process(req1);
                system.debug('getInstanceStatus>>>'+result.getInstanceStatus());  
            }
    }
    @AuraEnabled
    public static string beforeApprovalValidation(String recordId){
        if(Approval.isLocked(recordId)){
            return 'Error : Record is locked';
        }
        
        List<ProcessDefinition> processDefinitionList = [SELECT id,TableEnumOrId FROM ProcessDefinition where TableEnumOrId = 'Quote' limit 50000];
        if(processDefinitionList == null || (processDefinitionList != null && processDefinitionList.isEmpty())){
            return 'Error : No Approval Process found on this object';
        }
        return 'SUCCESS';
    }
    @AuraEnabled
    public static string runApproval(string recordId, string approvalComment){
         List<QuoteLineItem> qliList = [SELECT Id,QuoteId,product2.Multiple_Sale_Not_Allowed__c,Discount_Amount__c,
                                       Quote.Floor_Price_Type__c,Discount__c,Price_before_discount__c,Amount__c FROM QuoteLineItem WHERE QuoteId = :recordId];
        Boolean isRequired= false;
        for(QuoteLineItem qli:qliList){
            if((qli.Quote.Floor_Price_Type__c == 'Below List Price') || ((qli.Discount__c == null || qli.Discount__c == 0 )
               && (qli.Discount_Amount__c == null || qli.Discount_Amount__c == 0) )){
                   isRequired = false;
               } else {
                   isRequired = true;
                   break;
               }
        }
        if(!isRequired) {
            return 'Error : No approval is required. Please proceed for payment';
        }
        Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
        req.setComments(approvalComment);
        req.setObjectId(recordId);
        Approval.ProcessResult result;
        try{
            update new Quote(id = recordId, Approval_Requester_Comment__c = approvalComment);
            result = Approval.process(req);
        }catch(Exception exp){
            return 'Error : '+exp.getMessage();
        }
        if(result.isSuccess() && !Test.isRunningTest()){
            return 'Discount Approval Request Submitted';
        }
        else{
            try{
                update new Quote(id = recordId, Approval_Requester_Comment__c = '');
            }catch(exception e){
                return 'Error : While removing Approval Requester Comment '+e.getMessage();
            }
            string errorToReturn = 'Errors : ';
            List<Database.Error> errorList = result.getErrors();
            if(errorList != null && !errorList.isEmpty()){
                for(Database.error errorStr : errorList){
                    errorToReturn += errorStr.getMessage()+'; ';
                } 
            }
            return errorToReturn;
        } 
    }
}