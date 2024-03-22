public class OpportunityOwnerTransfer_Batch implements Database.Batchable<sObject>, Database.Stateful {
    public User objUser;
    public string opportunityHeader = 'Id,Opportunity Number ,Opportunity Name,Opportunity Type,Expected Close Date,Response \n';
    public string finalOppStr = opportunityHeader ;
    public string finalAccStr;
    
    public OpportunityOwnerTransfer_Batch(User objUser,String finalAccStr){
        this.objUser=objUser;
        this.finalAccStr=finalAccStr;
    }
    Public Database.querylocator start(Database.BatchableContext BC) {
        String query='select id ,CloseDate,Name,Opportunity_Type__c,Opportunity_Number__c, ownerId ,AccountId, stageName from Opportunity Where OwnerId=\''+objUser.Id+'\''+' and stageName NOT IN(\'Closed Won\',\'Closed Lost\',\'Converted\')';
        return Database.getQueryLocator(query);
    }
    Public void execute(Database.BatchableContext BC, List<Opportunity> opportunityList) {
        for(Opportunity opp: opportunityList){
            opp.ownerId=objUser.ManagerId;
        }
        Database.SaveResult[] srOppList=Database.update(opportunityList, false);
        for(Integer i=0; i < srOppList.size(); i++){
            if(srOppList.size()>0){
                if (srOppList.get(i).isSuccess()){
                    Id recID=opportunityList.get(i).Id;
                    finalOppStr = finalOppStr+ recID+ ','+ opportunityList.get(i).Opportunity_Number__c+ ','+ opportunityList.get(i).Name+ ','+ opportunityList.get(i).Opportunity_Type__c+ ','+ opportunityList.get(i).CloseDate+ ','+ 'Success'+ '\n';
                }else{
                    String allerrors;
                    Id recID=opportunityList.get(i).Id;
                    for(Database.Error err : srOppList.get(i).getErrors()) {
                        allerrors=allerrors+';'+err.getMessage().replace(',', '_');
                    }
                    finalOppStr = finalOppStr+ recID+ ','+ opportunityList.get(i).Opportunity_Number__c+ ','+ opportunityList.get(i).Name+ ','+ opportunityList.get(i).Opportunity_Type__c+ ','+ opportunityList.get(i).CloseDate+ ','+ allerrors+ '\n';
                }
            }
        }
        
    }
    Public void finish(Database.BatchableContext BC){
        system.debug('--inside finish--');
        List<String> ccaddress =System.Label.Transfer_Account_Result_Email.split(','); 
        Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
        blob excel = blob.valueOf(finalAccStr);
        attach.setBody(excel);
        attach.setFileName('Accounts result.csv');
        Messaging.EmailFileAttachment attach1 = new Messaging.EmailFileAttachment();
        blob excel1 = blob.valueOf(finalOppStr);
        attach1.setBody(excel1);
        attach1.setFileName('Opportunities result.csv');
        
        Messaging.SingleEmailMessage reply_email = new Messaging.SingleEmailMessage ();
        reply_email.setToAddresses(new List<String>{objUser.Manager.Email});
        reply_email.setccAddresses(ccaddress);
        reply_email.setSubject(objUser.Name+' being inactivated in Salesforce');
        reply_email.setPlainTextBody('Please find attached the list  containing the accounts and open opportunities that are assigned to a different salesperson.');
        reply_email.setFileAttachments(new Messaging.EmailFileAttachment[]{attach,attach1});
        
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {reply_email});
    }
}