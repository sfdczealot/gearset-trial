/*
* TestClass : QuoteApprovalHistoryController_Test
*/
public class QuoteApprovalHistoryController {
    
    public class wrapperStepNameVSSteps{
        
        @AuraEnabled
        public String stepName;
        @AuraEnabled
        public Datetime createdDate; 
        @AuraEnabled
        public String stepStatus;
        @AuraEnabled
        public String originalActor; 
        @AuraEnabled
        public String actor;
        @AuraEnabled
        public String comments;
        @AuraEnabled
        public String actorId;
         @AuraEnabled
        public String SobjectType;
    }
    @AuraEnabled
    public static List<wrapperStepNameVSSteps> getApprovalHistory(String recordId){
        Id recId = (ID)recordId;
       String SobjectType= recId.getSObjectType().getDescribe().getName();
        List<wrapperStepNameVSSteps> lstWrapper = new List<wrapperStepNameVSSteps>();
        For(ProcessInstance eachProcessInst:[SELECT CreatedDate, (SELECT ID,ProcessNode.Name, StepStatus, Comments,TargetObjectId,Actor.Name,CreatedById,IsPending, OriginalActor.Name,OriginalActorId,ProcessInstanceId,CreatedDate FROM StepsAndWorkitems order by createdDate Desc , Id DESC ) FROM ProcessInstance where TargetObjectId=:recordId order by createdDate Desc ]){
            for(Integer i=0;i<eachProcessInst.StepsAndWorkitems.size();i++){
                wrapperStepNameVSSteps objwrapper=new wrapperStepNameVSSteps();
                objwrapper.stepName=eachProcessInst.StepsAndWorkitems[i].ProcessNode.Name==null?'Approval Request Submitted':eachProcessInst.StepsAndWorkitems[i].ProcessNode.Name;
                objwrapper.createdDate=eachProcessInst.StepsAndWorkitems[i].CreatedDate;
                objwrapper.stepStatus=eachProcessInst.StepsAndWorkitems[i].StepStatus;
                objwrapper.originalActor=eachProcessInst.StepsAndWorkitems[i].OriginalActor.Name;
                objwrapper.actor=eachProcessInst.StepsAndWorkitems[i].Actor.Name;
                objwrapper.comments=eachProcessInst.StepsAndWorkitems[i].Comments;
                if(eachProcessInst.StepsAndWorkitems[i].ProcessNode.Name != null){
                    objwrapper.actorId = eachProcessInst.StepsAndWorkitems[i].OriginalActorId;
                }
                objwrapper.SobjectType=SobjectType;
                system.debug('---'+objwrapper.CreatedDate);
                lstWrapper.add(objwrapper);
            }
        }
        
        return lstWrapper;
    }
    @AuraEnabled
    public static void recallApprovalProcess(String recordId,String rejectComment){
        Quote qu = [Select Id,Status,Quote_Type__c from Quote where Id = : recordId];
        If(qu.Quote_Type__c!=null){
            ProcessInstanceWorkitem[] workItems = [SELECT Id, ActorId
                                                   FROM ProcessInstanceWorkitem 
                                                   WHERE ProcessInstance.TargetObjectId = : recordId
                                                   AND ProcessInstance.Status = 'Pending']; 
            List<Approval.ProcessWorkitemRequest> workItemsList = new List<Approval.ProcessWorkitemRequest>();
            system.debug('--workItemsList--'+workItemsList);
            If(workItems.size() == 0){
                system.debug('--111workItemsList--'+workItemsList);
                throw new AuraHandledException('Invalid action. No Approval process found.');
            }
            for(ProcessInstanceWorkitem eachWordItem: workItems){
                
                Approval.ProcessWorkitemRequest pwr = new Approval.ProcessWorkitemRequest();  
                pwr.setAction('Removed');
                pwr.setWorkItemId(eachWordItem.Id);
                pwr.setComments(rejectComment);
                workItemsList.add(pwr);
                
            }
            List<Approval.ProcessResult> resultList = Approval.process(workItemsList,false);
            for (Approval.ProcessResult sr : resultList) {
                if (sr.isSuccess()) {
                    //Do nothing
                }
                else {
                    throw new AuraHandledException('Invalid action. Something went wrong please contact to system admin');
                }
            }
        }
        
    }
    @AuraEnabled
    public static void approveAndRejectApprovalProcess(String recordId,String actionMsg,String commentMsg){
        
        Boolean hasCustomPermission = FeatureManagement.checkPermission('System_Admin_Compliance_Access');
        String deligatedUser;
        Map<Id,User> userSetId = new Map<Id,User>([SELECT Id,Name FROM User where DelegatedApproverId = : userinfo.getUserId()]);
        for(Id delUserId : userSetId.keyset()){
            deligatedUser = delUserId;
        }
        Quote qu = [Select Id,Account.Agency__r.Expiry_Date_Time__c,Status,Quote_Type__c from Quote where Id = : recordId];
        If(qu.Quote_Type__c!=null){
            
            List<ProcessInstanceWorkitem> workItemList = [SELECT Id, ProcessInstanceId,ActorId,Actor.Name FROM ProcessInstanceWorkitem where ProcessInstance.TargetObjectId =:recordId ];//OR Actor.Name =: us.Name
            List<Approval.ProcessWorkitemRequest> workItemsList = new List<Approval.ProcessWorkitemRequest>();
            
            If(workItemList.size() == 0 && !Test.isRunningTest()){   
                throw new AuraHandledException('Invalid action. No Approval process found.');
            }
            
            if(qu.Account.Agency__r.Expiry_Date_Time__c != null){
                throw new AuraHandledException('Cannot proceed with approval of the Quote as the Agency linked to the Account has expired');  
            }
            
            for(ProcessInstanceWorkitem wr : workItemList){
                if(wr.ActorId == userinfo.getUserId() || wr.ActorId == deligatedUser || hasCustomPermission){
                    Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                    req.setComments(commentMsg);
                    req.setAction(actionMsg);
                    req.setWorkitemId(wr.Id);
                    workItemsList.add(req);
                    break;  
                }
            }
            List<Approval.ProcessResult> resultList = Approval.process(workItemsList,false);
            for (Approval.ProcessResult sr : resultList) {
                if (sr.isSuccess()) {
                    //Do nothing
                }
                else {
                    system.debug('@@error'+sr.getErrors());
                    throw new AuraHandledException('Invalid action. Something went wrong please contact to system admin');
                }
            }
        }
    }
    @AuraEnabled
    public static User getUserProfile(){
        
        user ur = [SELECT Id,Name,DelegatedApproverId, ProfileId,Profile.Name FROM User where Id = : userinfo.getUserId()];
        return ur;
    }
}