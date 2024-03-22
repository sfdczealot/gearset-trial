public class AgentRewardTriggerHandler implements PGTriggerInterface {
    List<Agent_Reward__c> listAR;
    List<Agent_Reward__c> oldListAR ;
    Map<Id,Agent_Reward__c> triggerOldMap;
    Map<Id,Agent_Reward__c> triggerNewMap;
    
    public AgentRewardTriggerHandler() {  
        listAR = new  List<Agent_Reward__c>();
        oldListAR = new List<Agent_Reward__c>();
        triggerOldMap = new Map<Id,Agent_Reward__c>();
        triggerNewMap = new Map<Id,Agent_Reward__c>();
    }
    
    //Use this variable to disable this trigger from transaction
    public static Boolean TriggerDisabled = false;
    
    //check if the trigger is disabled from transaction
    public Boolean isDisabled(){
        return TriggerDisabled;
    }
    public void beforeInsert(List<sObject> newList) { 
    }
    
    public void afterInsert(List<sObject> newList , Map<Id, sObject> newMap) {
        syncPGFtoPG((List<Agent_Reward__c>) newList,(Map<Id,Agent_Reward__c>) newMap, null,false);   
    }
    public void beforeUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        validateApprovalCap((List<Agent_Reward__c>) newList, (Map<Id,Agent_Reward__c>) oldMap);
        publishSolatireResult((List<Agent_Reward__c>) newList, (Map<Id,Agent_Reward__c>) oldMap);
    }
    
    public void afterUpdate(List<sObject> newList, Map<Id, sObject> newMap, List<sObject> oldList, Map<Id, sObject> oldMap) {
        sendMailToActualApprover((List<Agent_Reward__c>) newList, (Map<Id,Agent_Reward__c>) oldMap);
        syncPGFtoPG((List<Agent_Reward__c>) newList, (Map<Id,Agent_Reward__c>) newMap,(Map<Id,Agent_Reward__c>) oldMap,true);
    }
    public void beforeDelete(List<sObject> oldList , Map<Id, sObject> oldMap) { 
        
    }
    public void afterDelete(List<sObject> oldList , Map<Id, sObject> oldMap) {
        
    }
    
    public void afterUnDelete(List<sObject> newList, Map<Id, sObject> newMap) {         
    }
    
    /**
*  Method used to sync PGF Reward Points to PG
*  @name syncPGFtoPG
*  @param List<Agent_Reward__c>, Map<Id,Agent_Reward__c>, boolean
*  @return void
*/
    public static void syncPGFtoPG(List<Agent_Reward__c> listTriggerNew, Map<Id,Agent_Reward__c> newMap,Map<Id,Agent_Reward__c> oldMap,boolean isUpdate) {
        
        Set<Id> accountIds = new Set<Id>();
        list<account> accountToUpdate = new list<account>();
        Map<Id,Decimal> AccountVsPGPoints = new Map<Id,Decimal>();
        Map<Id,Decimal> AccountVsPGFPoints = new Map<Id,Decimal>();
        Map<Id,Account> PGFRewardPoints =new Map<Id,Account>();
        
        list<Reward_Calculation_Tier__mdt> countryVsTier = new list<Reward_Calculation_Tier__mdt>();
            
        for(Reward_Calculation_Tier__mdt rewardTier : [Select id,Country__c,Lower_Limit__c,Upper_Limit__c,Tier__c from Reward_Calculation_Tier__mdt]){
            countryVsTier.add(rewardTier);
           }
        for(Agent_Reward__c eachReward : listTriggerNew){  
            if((eachReward.PGF_LoanId__c!=null && !isUpdate) || 
               (isUpdate && eachReward.PGF_LoanId__c!=null && eachReward.PGF_Loan_Reward_Points__c!=oldMap.get(eachReward.id).PGF_Loan_Reward_Points__c)){
                   accountIds.add(eachReward.Account__c);   
               }
        }  
        if(!accountIds.isempty()){
            for(AggregateResult eachReward :[Select SUM(PGF_Loan_Reward_Points__c) totalPoints,Account__c from Agent_Reward__c where account__c IN : accountIds Group By Account__c]){
                AccountVsPGFPoints.put((id)eachReward.get('Account__c'),(Decimal)eachReward.get(('totalPoints')));
            } 
            for(Account acc :[Select id, PG_Reward_Points__c ,PGF_Reward_Points__c,Reward_Points__c,Reward_Tier__c,AgentNet_ID__c from account where Id IN : accountIds]){
               if(acc.PG_Reward_Points__c == null){
                    acc.PG_Reward_Points__c = 0;
                }
                AccountVsPGPoints.put(acc.id,(Decimal)acc.PG_Reward_Points__c);
                acc.PGF_Reward_Points__c = AccountVsPGFPoints.get(acc.id);
                acc.Reward_Points__c = AccountVsPGFPoints.get(acc.id) + acc.PG_Reward_Points__c;
                accountToUpdate.add(acc);
                PGFRewardPoints.put(acc.id,acc);
            }  
            list<Agent_Reward__c> agentRewardToUpdate = new list<Agent_Reward__c>();
            for(Agent_Reward__c eachReward : [Select Id,PG_Reward_Points__c, Reward_Points__c,Calculated_from__c,Status__c,Account__c,Account__r.country__c from Agent_Reward__c where ID IN : newMap.keyset()]){
                eachReward.PG_Reward_Points__c = AccountVsPGPoints.get(eachReward.Account__c);
                eachReward.Reward_Points__c = AccountVsPGPoints.get(eachReward.Account__c) + AccountVsPGFPoints.get(eachReward.Account__c);
                eachReward.Calculated_from__c = 'PGF Calculation';
                eachReward.Status__c = 'New Quarter';
                if(eachReward.Reward_Points__c < 0)
                    eachReward.Reward_Points__c = 0;
                
                for(Reward_Calculation_Tier__mdt rewardTier : countryVsTier){
                    if(rewardTier.country__c == eachReward.Account__r.country__c && 
                        eachReward.Reward_Points__c >= rewardTier.Lower_Limit__c && eachReward.Reward_Points__c <= rewardTier.Upper_Limit__c ){
                        eachReward.Reward_Tier__c = rewardTier.Tier__c;
                        break;
                    }     
                }
                agentRewardToUpdate.add(eachReward);
                
            } 
            
            update agentRewardToUpdate;  
            for(Account acc :accountToUpdate){
                Update_PGF_Reward_Points__e updatePGFPoints = new Update_PGF_Reward_Points__e(Account_Id__c=acc.id,PGF_Reward_Points__c=acc.PGF_Reward_Points__c,Reward_Points__c=acc.Reward_Points__c);
                EventBus.publish(updatePGFPoints);
            } 
        }  
    }    
    /**
*  Method used to vaidate the count on the Solitaire Limit on approval
*  @name validateApprovalCap
*  @param List<Agent_Reward__c>, Map<Id,Agent_Reward__c>
*  @return void
*/
   private static void validateApprovalCap(List<Agent_Reward__c> listTriggerNew, Map<Id,Agent_Reward__c> oldMap) {
       Map<String,Set<Id>> setOfApprovedIds = new Map<String,Set<Id>>();
         Map<String,Boolean> isLimitReached = new  Map<String,Boolean>();
        for(Agent_Reward__c eachReward : listTriggerNew) {
            if(
                eachReward.Approval_Status__c == 'Approved' && ((eachReward.Reward_Tier__c == 'Solitaire' && eachReward.Country__c != 'Thailand')
                                                               ||(eachReward.Reward_Tier__c == 'Black' && eachReward.Country__c == 'Thailand')) &&
                oldMap.get(eachReward.Id).Approval_Status__c != eachReward.Approval_Status__c  
            ) {
                if(setOfApprovedIds.containskey(eachReward.Country__c)){
                   setOfApprovedIds.get(eachReward.Country__c).add(eachReward.Id);
                }else{
                    Set<id> approvedId = new Set<Id>();
                    approvedId.add(eachReward.Id);
                    setOfApprovedIds.put(eachReward.Country__c,approvedId);
                }
            }
        }
        if(!setOfApprovedIds.values().isEmpty()) {
            Map<String,list<account>> countryVsSolitaireAcc = new Map<String,list<account>>();
            for(Account SolitaireAcc : [
                SELECT Id ,Country__c FROM Account WHERE 
                ((Reward_Tier__c = 'Solitaire' AND Account_Rule_Code__c IN ('Standard','Advanced','Advance','Premier','Business')) OR 
                 (Reward_Tier__c = 'Black'  AND Account_Rule_Code__c IN ('BEGINNER','PRO','SUPERSTAR'))) AND
                Country__c IN : setOfApprovedIds.keyset() AND
                RecordType.DeveloperName = 'Agent'  AND 
                Status__c IN ('Active','Suspended')
            ]){
                if(countryVsSolitaireAcc.containskey(SolitaireAcc.Country__c)){
                   countryVsSolitaireAcc.get(SolitaireAcc.Country__c).add(SolitaireAcc);
                }else{
                    list<account> listSolitaireAcc = new list<account>();
                    listSolitaireAcc.add(SolitaireAcc);
                    countryVsSolitaireAcc.put(SolitaireAcc.Country__c,listSolitaireAcc);
                }   
            }
            for(String country : setOfApprovedIds.keyset()){
           
            Integer maxSolitaireAgentsAllowed=0;
                Integer solitaireAcc = 0;
                if(countryVsSolitaireAcc.containskey(Country)){
                  solitaireAcc =   countryVsSolitaireAcc.get(country).size();
                }else{
                   solitaireAcc = 0; 
                }
            Integer totalSolitaireAgents = solitaireAcc + setOfApprovedIds.get(country).size();
                if(country=='Singapore'){
                  maxSolitaireAgentsAllowed = Integer.valueOf(label.SOLITAIRE_ACCOUNT_LIMIT);
                }else if(country=='Malaysia'){
                  maxSolitaireAgentsAllowed = Integer.valueOf(label.SOLITAIRE_ACCOUNT_LIMIT_FOR_MY);
                  
                }else if(country=='Thailand'){
                  maxSolitaireAgentsAllowed = Integer.valueOf(label.Black_ACCOUNT_LIMIT_FOR_TH);
                  
                }
            if(totalSolitaireAgents >= maxSolitaireAgentsAllowed) {
                isLimitReached.put(country,true);
              }   
            }
            
            for(Agent_Reward__c eachReward : listTriggerNew) {
                if(setOfApprovedIds.containskey(eachReward.country__c)&& setOfApprovedIds.get(eachReward.country__c).contains(eachReward.Id) &&
                   isLimitReached.containskey(eachReward.country__c)&& isLimitReached.get(eachReward.country__c)) {
                       if(eachReward.Country__c == 'Singapore' || eachReward.Country__c == 'Malaysia') {
                           eachReward.addError(label.SOLITAIRE_ERROR_MESSAGE);
                       } else if(eachReward.Country__c == 'Thailand') {
                           eachReward.addError(label.BLACK_ERROR_MESSAGE);
                       }
                   }
                }
        }
    }
 
    private static void sendMailToActualApprover(List<Agent_Reward__c> listTriggerNew, Map<Id,Agent_Reward__c> oldMap){
        Set<Id> setOfApprovedIds = new Set<Id>();
        Set<Id> setOfAccId = new Set<Id>();
        List<Messaging.SingleEmailMessage> lstMail = new List<Messaging.SingleEmailMessage>();
        Set<Id> groupMemberIds = new Set<Id>();
        for(Agent_Reward__c eachReward : listTriggerNew) {
            if((eachReward.Approval_Status__c == 'Approved' ||
                eachReward.Approval_Status__c == 'Rejected') &&
               oldMap.get(eachReward.Id).Approval_Status__c != eachReward.Approval_Status__c){
                   setOfApprovedIds.add(eachReward.Id);
                   setOfAccId.add(eachReward.Account__c);
               }
        }
        
        if(!setOfApprovedIds.isEmpty()) {
            Boolean sendDoubleMail = false;
            Id userRoleId = UserInfo.getUserRoleId();
            List<UserRole> currentUserRole =[select Id, DeveloperName from UserRole where Id =: userRoleId];
            List<EmailTemplate> emailTempList = [Select Id,DeveloperName,Body from EmailTemplate 
                                                 where DeveloperName = 'Solitaire_Approval_Response'];
            
            Map<Id,Account> mapOfIdVsAcc = new Map<Id,Account> ([SELECT PersonContactId FROM Account WHERE Id In: setOfAccId]);
            Id owdEmailId = [Select Id From OrgWideEmailAddress where Address= 'sales_enablement@propertyguru.com.sg'].Id;
            
            for(GroupMember member : [select id,UserOrGroupId 
                                      from groupmember 
                                      where group.DeveloperName = 'Solitaire_Approvers'  
                                      and group.type = 'Regular'] 
               ){
                   groupMemberIds.add(member.UserOrGroupId);                          
               }
            
            List<Group> listOfGrp = [SELECT Id, DeveloperName FROM Group WHERE Id In:groupMemberIds];
            if(currentUserRole.size()>0 && listOfGrp.size()>0) {
                for(Group grp: listOfGrp) {
                    if(grp.DeveloperName == currentUserRole[0].DeveloperName){
                        sendDoubleMail = true;
                        break;
                    }
                }
            }
            if(!sendDoubleMail){
                String emailAddress = UserInfo.getUserEmail();
                for(Agent_Reward__c eachReward: listTriggerNew) {
                    if(setOfApprovedIds.contains(eachReward.Id)) {
                        lstMail.add(sendMail(emailTempList[0].Id,
                                             emailAddress,
                                             mapOfIdVsAcc.get(eachReward.Account__c).PersonContactId,
                                             eachReward.Id,owdEmailId));
                    }
                }
            }
        }
        
        if(lstMail.size() > 0) {
            try{
                Messaging.SendEmailResult[] results = Messaging.sendEmail(lstMail);
            }catch(Exception e){
                System.debug(''+e.getMessage());
            }
        }
    }
    
    private static Messaging.SingleEmailMessage sendMail(Id templateId, String emailId , 
                                                         Id contId, Id agentRewardId,
                                                         Id orgWideEmailId) {
                                                             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                                                             
                                                             if(templateId != null) {
                                                                 mail.setTemplateID(templateId);
                                                                 mail.setToAddresses(new List<String> {emailId});
                                                                 if(orgWideEmailId != null) {
                                                                     mail.setOrgWideEmailAddressId(orgWideEmailId);
                                                                 }
                                                                 mail.setWhatId(agentRewardId);
                                                                 mail.setTreatTargetObjectAsRecipient(false);
                                                                 mail.setTargetObjectId(contId);
                                                                 mail.setSaveAsActivity(false);
                                                                 
                                                             }
                                                             return mail;
                                                         }
    /**
*  Method used to publish Solatire based on Approvals
*  @name publishSolatireResult
*  @param List<Agent_Reward__c>>
*  @return void
*/
    
    private static void publishSolatireResult(List<Agent_Reward__c> listTriggerNew, Map<Id,Agent_Reward__c> oldMap) {
        List<String> csvRowValuesAgentSuccess = new List<String>(); // Stores the account Updated successsfuly
        List<String> csvRowValuesAgentFailure = new List<String>(); // Stores the accountdetails with error
        List<String> csvRemoveAgents = new List<String>(); // Stores the accountdetails that have to be removed
        List<RewardCalculation__e> rewardCalculationSuccess = new List<RewardCalculation__e>();
        Map<id,String> agentVsTier = new Map<id,String>();
        Map<String,list<account>> countryVsAccount = new Map<String,list<account>>();
        Map<Id,account> accountMap = new map<id,account>();
        Map<String,String> countryVsHighestTier = new Map<String,String>();
        Map<String,String> countryVsSecondHighestTier = new Map<String,String>();
       
        Set<id> accIds = new Set<Id>();
        
        for(Reward_Calculation_Tier__mdt rewardTier : [Select id,Country__c,Lower_Limit__c,Upper_Limit__c,Tier__c from Reward_Calculation_Tier__mdt order by Upper_Limit__c desc]){
           if(!countryVsSecondHighestTier.containskey(rewardTier.Country__c) && countryVsHighestTier.containskey(rewardTier.Country__c)){
                countryVsSecondHighestTier.put(rewardTier.Country__c,rewardTier.Tier__c);
            }
            
            if(!countryVsHighestTier.containskey(rewardTier.Country__c)){
                countryVsHighestTier.put(rewardTier.Country__c,rewardTier.Tier__c);
            }
       }
        for(Agent_Reward__c eachReward : listTriggerNew) {
            if(eachReward.Approval_Status__c != oldMap.get(eachReward.Id).Approval_Status__c && eachReward.Approval_Status__c !='Approval Submitted') {
                accIds.add(eachReward.account__c);
                if(eachReward.Approval_Status__c == 'Approved') {
                    eachReward.Published_Date__c = System.now();
                    eachReward.Status__c = 'Published';
                }
            }
        }
        
        if(accIds.isEmpty()) {
            return;
        }
        for(Account acc :[Select id,country__c,reward_points__c,reward_tier__c,AgentNet_ID__c from account where ID IN : accIds]){
            accountMap.put(acc.id,acc); 
             if(acc.Reward_Tier__c!=null){
               agentVsTier.put(acc.id,acc.Reward_Tier__c);  
            }
        }
        for(Agent_Reward__c eachReward : listTriggerNew) {
            if(eachReward.Approval_Status__c != oldMap.get(eachReward.Id).Approval_Status__c) {
                system.debug(eachReward.Approval_Status__c);
                if(eachReward.Approval_Type__c =='Upgrade'){
                    if(eachReward.Approval_Status__c == 'Approved' && accountMap.containskey(eachReward.account__c)){
                        accountMap.get(eachReward.account__c).reward_tier__c = countryVsHighestTier.get(eachReward.Country__c);
                    }
                    if(eachReward.Approval_Status__c == 'Rejected' && accountMap.containskey(eachReward.account__c)){
                        accountMap.get(eachReward.account__c).Reward_Tier__c = countryVsSecondHighestTier.get(eachReward.Country__c);
                    }   
                } else {
                    if(eachReward.Approval_Status__c == 'Approved' && accountMap.containskey(eachReward.account__c)){
                        accountMap.get(eachReward.account__c).reward_tier__c = eachReward.reward_tier__c;
                    }
                    if(eachReward.Approval_Status__c == 'Rejected' && accountMap.containskey(eachReward.account__c)){
                        accountMap.get(eachReward.account__c).reward_tier__c = countryVsHighestTier.get(eachReward.Country__c);
                    }     
                }
            }
             if(!countryVsAccount.containskey(accountMap.get(eachReward.account__c).country__c)){
               list<account> temp = new list<Account>();  
               temp.add(accountMap.get(eachReward.account__c));
               countryVsAccount.put(accountMap.get(eachReward.account__c).country__c,temp); 
            }else{
               countryVsAccount.get(accountMap.get(eachReward.account__c).country__c).add(accountMap.get(eachReward.account__c));  
            }
        }
        Database.SaveResult[] updateResults = Database.update(accountMap.values(),false);
        publishRewardsToAgents.CSVWrapper CSVResults = new publishRewardsToAgents.CSVWrapper();
        
        for(String country : countryVsAccount.keyset()){

        CSVResults = publishRewardsToAgents.notifyUpdateStatus(updateResults,countryVsAccount.get(country),country,agentVsTier,true);
        
        csvRowValuesAgentSuccess.addall(CSVResults.successCSV);
        csvRowValuesAgentFailure.addall(CSVResults.errorCSV);
        csvRemoveAgents.addall(CSVResults.removeAgentIdsCSV);
        String csvColumnHeader; 
            
        Folder f = [SELECT Id, Name FROM Folder WHERE Name = 'BatchToComputeTotalSpending_Results'];
        
        if(!csvRowValuesAgentSuccess.isEmpty()){
            
            String documentName = 'BatchToComputeTotalSpending_SuccessResults-'+ Datetime.now().format('MMM') + Datetime.now().year();
            csvColumnHeader = 'Date, AccountId ,Reward Points, Reward Tiers ,AgentNet ID,Update Status\n';
            String csvFile = csvColumnHeader + String.join(csvRowValuesAgentSuccess,'\n');
            
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = f.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;     
            
            rewardCalculationSuccess.add(new RewardCalculation__e(Document_Id__c = doc.id, Message__c = country+': Update'));
            EventBus.publish(rewardCalculationSuccess);
        }
        
        
        if(!csvRowValuesAgentFailure.isEmpty()){
            String documentName = 'BatchToComputeTotalSpending_Results-'+ Datetime.now().format('MMM') + Datetime.now().year();
            csvColumnHeader = 'Date, AccountId ,Error Message\n';
            String csvFile = csvColumnHeader + String.join(csvRowValuesAgentFailure,'\n');
            
            // To send alert on PG Automation Channel
            
            String slack_user = label.PG_LABEL_BatchToComputeTotalSpending_SlackUser;
            String text = '', payload = '';
            String title = slack_user +' '+ 'Please find detailed Error information of BatchToComputeTotalSpending\n';
            title += '```"Id"';
            text += '"'+csvFile+'"\n';
            if(String.isNotBlank(text)){
                text += '```';
                payload += title + text; 
            }
            if(payload!= '') {
                SlackAlert.notifyPGAutoChannel(payload);
            }
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = f.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;
        }
         if(!csvRemoveAgents.isEmpty()){
            String documentName = 'BatchToComputeTotalSpending_Remove_From_AdminNet '+ Datetime.now().format('MMM') + Datetime.now().year();
            csvColumnHeader = 'Date, AccountId ,Reward Points, Reward Tiers ,AgentNet ID,Update Status\n';
            String csvFile = csvColumnHeader + String.join(csvRemoveAgents,'\n');
            
            Document doc=new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = f.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;     
            
            rewardCalculationSuccess.add(new RewardCalculation__e(Document_Id__c = doc.id, Message__c = country+': Remove'));
            EventBus.publish(rewardCalculationSuccess );
                   
        }
      }
    }
}