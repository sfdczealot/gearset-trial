public class publishRewardsToAgents {
/**
*  Method used to publish Agent Points and Tiers
*  @name publishPoints
*  @param List<Agent_Reward__c>
*  @return void
*/
    public static CSVWrapper publishPoints( List<Agent_Reward__c> arrList,Map<Id,Account> pgRewardPoints,String country,Boolean isbatch){
        Set<Id> accountIds = new Set<Id>();
        Map<Id,Account> accList = new Map<Id,Account>();
        Map<Id,Agent_Reward__c> newAR = new Map<Id,Agent_Reward__c>();
        Map<Id,Agent_Reward__c> previousAR = new Map<Id,Agent_Reward__c>();
        Map<Id,String> currentARTier = new Map<Id,String>();
        Map<Id,String> agentTier = new Map<Id,String>();
        List<Account> toUpdateAccount = new List<Account>();
        Map<id,String> agentVsTier = new Map<id,String>();
        Map<String,String> countryVsHighestTier = new Map<String,String>();
        
        for(Agent_Reward__c ar : arrList) {
            accountIds.add(ar.account__c);
            newAR.put(ar.account__c,ar);
        }
        
        for(Reward_Calculation_Tier__mdt rewardTier : [Select id,Country__c,Lower_Limit__c,Upper_Limit__c,Tier__c from Reward_Calculation_Tier__mdt order by Upper_Limit__c desc]){           
            if(!countryVsHighestTier.containskey(rewardTier.Country__c)){
                countryVsHighestTier.put(rewardTier.Country__c,rewardTier.Tier__c);
            }
        }
        for(Account acc : [SELECT Id,Reward_Points__c,PG_Reward_Points__c,Reward_Tier__c,AgentNet_ID__c,isRewardTierUpdated__c FROM account WHERE Id IN : accountIds]){
            accList.put(acc.Id,acc);
            if(acc.Reward_Tier__c!=null){
                agentVsTier.put(acc.id,acc.Reward_Tier__c);  
            }
        }
        for(Agent_Reward__c prevAR : [SELECT Id ,Approval_Status__c,Approval_Type__c,Calculated_from__c,Reward_Points__c,Reward_Tier__c,account__c,Published_Date__c,Status__c FROM Agent_Reward__c WHERE (account__c IN :accountIds  AND status__c = 'Published') ORDER BY CREATEDDATE DESC]){
            if(!previousAR.containskey(prevAR.account__c)) {
                previousAR.put(prevAR.account__c,prevAR);
            }
        }
        for(Id acc :accList.keyset()) {
            Decimal currentARPoints;
            if(accList.get(acc).Reward_Points__c == null && previousAR.containskey(acc)){
                currentARPoints = previousAR.get(acc).Reward_Points__c;
                currentARTier = calculateTier(previousAR.get(acc).Reward_Points__c,acc,country);
            }else {
                currentARPoints = accList.get(acc).Reward_Points__c;
            currentARTier = calculateTier(accList.get(acc).Reward_Points__c,acc,country);
            }
            if(!previousAR.containskey(acc)) {
                if(currentARPoints==null) {
                    if(newAR.get(acc).Reward_Tier__c != countryVsHighestTier.get(country)) {
                        if(accList.get(acc).Reward_Tier__c != null && accList.get(acc).Reward_Tier__c.equals(countryVsHighestTier.get(country))) {
                            newAR.get(acc).Approval_Status__c ='Approval Submitted';
                            newAR.get(acc).Approval_Type__c = 'Downgrade';
                        } else {
                            accList.get(acc).Reward_Tier__c = newAR.get(acc).Reward_Tier__c; 
                            newAR.get(acc).Status__c ='Published'; 
                            newAR.get(acc).Published_Date__c = System.now();
                        }
                    } else {
                        if(accList.get(acc).Reward_Tier__c != countryVsHighestTier.get(country)) {
                            newAR.get(acc).Approval_Status__c ='Approval Submitted';
                            newAR.get(acc).Approval_Type__c = 'Upgrade';
                        } else {
                            accList.get(acc).Reward_Tier__c = newAR.get(acc).Reward_Tier__c;
                            newAR.get(acc).Status__c ='Published';
                            newAR.get(acc).Published_Date__c = System.now();
                        }
                    }
                } else {
                    if(newAR.get(acc).Reward_Points__c >=currentARPoints) {
                        if(newAR.get(acc).Reward_Tier__c !=countryVsHighestTier.get(country)) {
                            if(accList.get(acc).Reward_Tier__c != null && accList.get(acc).Reward_Tier__c.equals(countryVsHighestTier.get(country))) {
                                newAR.get(acc).Approval_Status__c ='Approval Submitted';
                                newAR.get(acc).Approval_Type__c = 'Downgrade';
                            } else {
                                accList.get(acc).Reward_Tier__c = newAR.get(acc).Reward_Tier__c; 
                                newAR.get(acc).Status__c ='Published';
                                newAR.get(acc).Published_Date__c = System.now();
                            }
                        } else {
                            if(accList.get(acc).Reward_Tier__c != countryVsHighestTier.get(country)){
                                newAR.get(acc).Approval_Status__c ='Approval Submitted'; 
                                newAR.get(acc).Approval_Type__c = 'Upgrade';
                            }else{
                                accList.get(acc).Reward_Tier__c = newAR.get(acc).Reward_Tier__c;
                                newAR.get(acc).Status__c ='Published';
                                newAR.get(acc).Published_Date__c = System.now();
                            }
                        }
                    } 
                    else{
                        // Agent will remain same
                        newAR.get(acc).Status__c ='Not Published';
                    }
                }
            } else {
                if(previousAR.get(acc).Reward_Points__c >=currentARPoints) { // PQ- CQ DG or Same 
                    if(previousAR.get(acc).Reward_Tier__c == currentARTier.get(acc)) { // PQ- CQ Same Tier
                        if(newAR.get(acc).Reward_Tier__c == currentARTier.get(acc)) { // NQ-CQ Same Tier
                            if(newAR.get(acc).Reward_Tier__c !=countryVsHighestTier.get(country)) {
                                if(accList.get(acc).Reward_Tier__c != null && accList.get(acc).Reward_Tier__c.equals(countryVsHighestTier.get(country))) {
                                    newAR.get(acc).Approval_Status__c ='Approval Submitted';
                                    newAR.get(acc).Approval_Type__c = 'Downgrade';
                                } else { 
                                    accList.get(acc).Reward_Tier__c =newAR.get(acc).Reward_Tier__c;
                                    newAR.get(acc).Status__c ='Published';
                                    newAR.get(acc).Published_Date__c = System.now();
                                }
                            } else {
                                if(accList.get(acc).Reward_Tier__c != countryVsHighestTier.get(country)) {
                                    newAR.get(acc).Approval_Status__c ='Approval Submitted'; 
                                    newAR.get(acc).Approval_Type__c = 'Upgrade';
                                } else {
                                    accList.get(acc).Reward_Tier__c = newAR.get(acc).Reward_Tier__c;
                                    newAR.get(acc).Status__c ='Published';
                                    newAR.get(acc).Published_Date__c = System.now();
                                }
                            } 
                        } else if(newAR.get(acc).Reward_Points__c >currentARPoints) { //NQ-CQ Upgrade
                            if(newAR.get(acc).Reward_Tier__c !=countryVsHighestTier.get(country)){
                                if(accList.get(acc).Reward_Tier__c != null && accList.get(acc).Reward_Tier__c.equals(countryVsHighestTier.get(country))) {
                                    newAR.get(acc).Approval_Status__c ='Approval Submitted';
                                    newAR.get(acc).Approval_Type__c = 'Downgrade';
                                } else { 
                                    accList.get(acc).Reward_Tier__c =newAR.get(acc).Reward_Tier__c; 
                                    newAR.get(acc).Status__c ='Published';
                                    newAR.get(acc).Published_Date__c = System.now();
                                }
                            } else {
                                if(accList.get(acc).Reward_Tier__c != countryVsHighestTier.get(country)){
                                    newAR.get(acc).Approval_Status__c ='Approval Submitted'; 
                                    newAR.get(acc).Approval_Type__c = 'Upgrade';
                                }  else{
                                    accList.get(acc).Reward_Tier__c = newAR.get(acc).Reward_Tier__c;
                                    newAR.get(acc).Status__c ='Published';
                                    newAR.get(acc).Published_Date__c = System.now();
                                }
                            }
                        } else {  
                            if(accList.get(acc).Reward_Tier__c !=countryVsHighestTier.get(country)) { //NQ-CQ DG for 1st Time
                                accList.get(acc).Reward_Tier__c = currentARTier.get(acc);
                                newAR.get(acc).Status__c ='Not Published';
                            } else {
                                newAR.get(acc).Approval_Status__c ='Approval Submitted'; 
                                newAR.get(acc).Approval_Type__c = 'Downgrade';
                            }
                        }
                    } else {  
                        // PQ- CQ Downgrage
                        if(newAR.get(acc).Reward_Tier__c !=countryVsHighestTier.get(country) ) {
                            if(accList.get(acc).Reward_Tier__c != null && accList.get(acc).Reward_Tier__c.equals(countryVsHighestTier.get(country))) {
                                newAR.get(acc).Approval_Status__c ='Approval Submitted';
                                newAR.get(acc).Approval_Type__c = 'Downgrade';
                            } else {
                                accList.get(acc).Reward_Tier__c = newAR.get(acc).Reward_Tier__c;  
                                newAR.get(acc).Status__c ='Published';
                                newAR.get(acc).Published_Date__c = System.now();
                            }
                        } else {
                            newAR.get(acc).Approval_Status__c ='Approval Submitted'; 
                            newAR.get(acc).Approval_Type__c = 'Downgrade';
                        }
                    }
                } else if (previousAR.get(acc).Reward_Points__c < currentARPoints) {// PQ- CQ UG or Same 
                    if(previousAR.get(acc).Reward_Tier__c != currentARTier.get(acc)) { // PQ- CQ UG
                        system.debug('currentARTier'+currentARTier);
                        system.debug('newAR'+newAR);
                        if(newAR.get(acc).Reward_Tier__c == currentARTier.get(acc)) { // NQ-CQ Same Tier
                            if(newAR.get(acc).Reward_Tier__c !=countryVsHighestTier.get(country)){
                                if(accList.get(acc).Reward_Tier__c != null && accList.get(acc).Reward_Tier__c.equals(countryVsHighestTier.get(country))) {
                                    newAR.get(acc).Approval_Status__c ='Approval Submitted';
                                    newAR.get(acc).Approval_Type__c = 'Downgrade';
                                } else {
                                    accList.get(acc).Reward_Tier__c =newAR.get(acc).Reward_Tier__c; 
                                    newAR.get(acc).Status__c ='Published';
                                    newAR.get(acc).Published_Date__c = System.now();
                                }
                            } else {
                                if(accList.get(acc).Reward_Tier__c != countryVsHighestTier.get(country)){
                                    newAR.get(acc).Approval_Status__c ='Approval Submitted'; 
                                    newAR.get(acc).Approval_Type__c = 'Upgrade';
                                } else {
                                    accList.get(acc).Reward_Tier__c = newAR.get(acc).Reward_Tier__c;
                                    newAR.get(acc).Status__c ='Published';
                                    newAR.get(acc).Published_Date__c = System.now();
                                }
                            }
                            system.debug('newAR'+newAR.get(acc).Reward_Points__c);
                            system.debug('accList'+accList.get(acc).Reward_Points__c);
                        } else if(newAR.get(acc).Reward_Points__c >currentARPoints) { //NQ-CQ Upgrade
                            if(newAR.get(acc).Reward_Tier__c !=countryVsHighestTier.get(country)) {
                                if(accList.get(acc).Reward_Tier__c != null && accList.get(acc).Reward_Tier__c.equals(countryVsHighestTier.get(country))) {
                                    newAR.get(acc).Approval_Status__c ='Approval Submitted';
                                    newAR.get(acc).Approval_Type__c = 'Downgrade';
                                } else {
                                    accList.get(acc).Reward_Tier__c =newAR.get(acc).Reward_Tier__c; 
                                    newAR.get(acc).Status__c ='Published';
                                    newAR.get(acc).Published_Date__c = System.now();
                                }
                            }else{
                                if(accList.get(acc).Reward_Tier__c != countryVsHighestTier.get(country)){
                                    newAR.get(acc).Approval_Status__c ='Approval Submitted'; 
                                    newAR.get(acc).Approval_Type__c = 'Upgrade';
                                } 
                                else{
                                    accList.get(acc).Reward_Tier__c = newAR.get(acc).Reward_Tier__c;
                                    newAR.get(acc).Status__c ='Published';
                                    newAR.get(acc).Published_Date__c = System.now();
                                }
                            }
                        } else {
                            if(accList.get(acc).Reward_Tier__c !=countryVsHighestTier.get(country)) {         //NQ-CQ DG for 1st Time
                                accList.get(acc).Reward_Tier__c = currentARTier.get(acc);
                                newAR.get(acc).Status__c ='Not Published';
                            } else {
                                newAR.get(acc).Approval_Status__c ='Approval Submitted'; 
                                newAR.get(acc).Approval_Type__c = 'Downgrade';
                            }
                        } 
                    }else{
                        
                    }
                }  
            }
            if(!pgRewardPoints.isempty() && pgRewardPoints.containskey(acc) && pgRewardPoints.get(acc) != null){       
                accList.get(acc).PG_Reward_Points__c = pgRewardPoints.get(acc).PG_Reward_Points__c; 
            }
            accList.get(acc).Reward_Points__c = newAR.get(acc).Reward_Points__c;
            accList.get(acc).isRewardTierUpdated__c = true;
            toUpdateAccount.add(accList.get(acc));
        } 
        List<account> temp = toUpdateAccount;
        Database.SaveResult[] updateResults =  Database.update(accList.values(),false);
        Database.SaveResult[] updateResults1 =  Database.update(newAR.values(),false);
        
        CSVWrapper csvWrap = notifyUpdateStatus(updateResults,toUpdateAccount,country,agentVsTier,isbatch);
        return csvWrap;
    }
    
    
    public static Map<Id,String> calculateTier(Decimal Points,Id acc,String country) {
        Map<id,String> mapToUpdate = new Map<id,String>();
        for(Reward_Calculation_Tier__mdt rewardTier : [Select id,Country__c,Lower_Limit__c,Upper_Limit__c,Tier__c from Reward_Calculation_Tier__mdt where Country__c=:Country]){
          
            if(Points >= rewardTier.Lower_Limit__c && Points <= rewardTier.Upper_Limit__c ){
                System.debug(Points+rewardTier.Tier__c);
                mapToUpdate.put(acc,rewardTier.Tier__c);
                break;
            }     
        }  return mapToUpdate;         
    }
    
    public static CSVWrapper notifyUpdateStatus(Database.SaveResult[] updateResults,list<account> toUpdateAccount,String country,Map<id,string> agentVsTier,boolean isbatch){
        String failedDML;
        String AccountId;
        String csvColumnHeader; 
        List<String> csvRowValuesSuccess = new List<String>(); // Stores the account Updated successsfuly
        List<String> csvRowValues = new List<String>(); // Stores the accountdetails with error
        List<String> csvRemoveAgents = new List<String>(); //Stores the agent to be removed from AdminNet
        List<String> allowTierAdmitNet = new List<String>();
        
        for(Reward_Calculation_Tier__mdt reward :[SELECT tier__c,Upload_To_AdminNet__c, Country__c FROM Reward_Calculation_Tier__mdt WHERE Country__c =: country and Upload_To_AdminNet__c = true]){
            allowTierAdmitNet.add(reward.tier__c); 
        }
        Folder f = [SELECT Id, Name FROM Folder WHERE Name = 'BatchToComputeTotalSpending_Results'];
        
        for(Integer i=0;i< updateResults.size();i++){
            String rowStr;
            if(updateResults.get(i).isSuccess()) {
                Id accId = updateResults.get(i).getId();
                if(toUpdateAccount[i].reward_tier__c!=null){
                    if(allowTierAdmitNet.contains(toUpdateAccount[i].reward_tier__c)){
                        rowStr = Datetime.now().format('MMM') + ','+ accId +',' +toUpdateAccount[i].Reward_Points__c + ','+ toUpdateAccount[i].reward_tier__c+','+ toUpdateAccount[i].AgentNet_ID__c +',' + 'Successfully Updated';
                        csvRowValuesSuccess.add(rowStr);    
                    }else{
                        if(!agentVsTier.isempty() && agentVsTier.containskey(accId) && allowTierAdmitNet.contains(agentVsTier.get(accId))){
                            rowStr = Datetime.now().format('MMM') + ','+ accId +',' +toUpdateAccount[i].Reward_Points__c + ','+ toUpdateAccount[i].reward_tier__c+','+ toUpdateAccount[i].AgentNet_ID__c +',' + 'Remove the AgentId from AdminNet';
                            csvRemoveAgents.add(rowStr);
                        }
                    }
                    
                }    
                
            } else {
                Database.Error error = updateResults.get(i).getErrors().get(0);
                failedDML = error.getMessage();
                AccountId = toUpdateAccount[i].id; //failed record from the list
                rowStr = Datetime.now().format('MMM') + ','+ AccountId +','+failedDML;
                csvRowValues.add(rowStr);
            }
        }
        
        CSVWrapper csvWrapperObj = new CSVWrapper();
        csvWrapperObj.successCSV = csvRowValuesSuccess;
        csvWrapperObj.errorCSV = csvRowValues;
        csvWrapperObj.removeAgentIdsCSV = csvRemoveAgents;
        if(!isbatch){
            List<RewardCalculation__e> rewardCalculationSuccess = new List<RewardCalculation__e>();
            
            if(!csvRowValuesSuccess.isEmpty()){
                
                String documentName = 'BatchToComputeTotalSpending_SuccessResults-'+ Datetime.now().format('MMM') + Datetime.now().year();
                csvColumnHeader = 'Date, AccountId ,Reward Points, Reward Tiers ,AgentNet ID,Update Status\n';
                String csvFile = csvColumnHeader + String.join(csvRowValuesSuccess,'\n');
                
                Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = f.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
                insert doc;     
                
                rewardCalculationSuccess.add(new RewardCalculation__e(Document_Id__c = doc.id, Message__c = country+': Update'));
                EventBus.publish(rewardCalculationSuccess);
            }
            if(!csvRemoveAgents.isEmpty()){
                String documentName = 'BatchToComputeTotalSpending_Remove_From_AdminNet '+ Datetime.now().format('MMM') + Datetime.now().year();
                csvColumnHeader = 'Date, AccountId ,Reward Points, Reward Tiers ,AgentNet ID,Update Status\n';
                String csvFile = csvColumnHeader + String.join(csvRemoveAgents,'\n');
                
                Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = f.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
                insert doc;     
                
                rewardCalculationSuccess.add(new RewardCalculation__e(Document_Id__c = doc.id, Message__c = country+': Remove'));
                EventBus.publish(rewardCalculationSuccess);
                
            }
            
            if(!csvRowValues.isEmpty()){
                String documentName = 'BatchToComputeTotalSpending_Results-'+ Datetime.now().format('MMM') + Datetime.now().year();
                csvColumnHeader = 'Date, AccountId ,Error Message\n';
                String csvFile = csvColumnHeader + String.join(csvRowValues,'\n');
                
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
        }
        return csvWrapperObj;
    }
    
    public class CSVWrapper {
        public List<String> successCSV;
        public List<String> errorCSV;
        public List<String> removeAgentIdsCSV;
    }
}