// Created for Reward calculator component
public class AgentRewardCalculatorController {
    
    @AuraEnabled(cacheable = true)
    public static LightningResponse prePopulateFields(String accId) {
        try {
            WrapResponse objResponse = calculateInputFields(accId);
            return new LightningResponse(true, 'Success', JSON.serialize(objResponse));            
        } catch (Exception ex) {
            return new LightningResponse(false, ex.getMessage(), '');
        }
    }
    
    @AuraEnabled
    public static LightningResponse calculateTotalSpending (String accId, String country,
                                                            Date LSD, Date CED,
                                                            Decimal xFact ,Decimal yFact,
                                                            Decimal pgPoints,Decimal pgfPoints,String CurrencyIsoCode) {
                                                                
                                                                List<Account> accList = new List<Account>();
                                                                Account acc = new Account();
                                                                acc.Id = accId;
                                                                acc.Country__c = country;
                                                                acc.Loyalty_Start_Date__c = LSD;
                                                                acc.PGF_Reward_Points__c = pgfPoints;
                                                                acc.PG_Reward_Points__c = pgPoints;
                                                                acc.CurrencyIsoCode = CurrencyIsoCode;
                                                                accList.add(acc);
                                                                try {
                                                                    BatchToComputeTotalSpending batchObj = new BatchToComputeTotalSpending(country,false);
                                                                    String wrapResponse = batchObj.computeTotalSpending(accList,CED,xFact,yFact,false,country);
                                                                    return new LightningResponse(true, 'Success', wrapResponse);
                                                                    
                                                               } catch (Exception ex) {
                                                                    return new LightningResponse(false, ex.getMessage(), '');
                                                                }
                                                            }
    
    @AuraEnabled
    public static LightningResponse runRewardCalculation(String totalSpending) {
        Savepoint sp = Database.setSavepoint();
        try {
            runARCreation(totalSpending);
            return new LightningResponse(true, 'Success','');
            
        } catch (Exception ex) {
            Database.rollback(sp);
            return new LightningResponse(false, ex.getMessage(), '');
        } 
    }
    
    private static void runARCreation(String totalSpending) {
        List<String> csvRowValuesAgentSuccess = new List<String>(); // Stores the account Updated successsfuly
        List<String> csvRowValuesAgentFailure = new List<String>(); // Stores the accountdetails with error
        List<RewardCalculation__e> rewardCalculationSuccess = new List<RewardCalculation__e>();
        Map<Id,Account> PGFRewardPoints = new Map<Id,Account>();
        Map<id,String> agentVsTier = new Map<id,String>();
        
        list<agent_reward__c> ARlist = new list<agent_reward__c>();
        BatchToComputeTotalSpending.WrapTotalSpending wrapObj = (BatchToComputeTotalSpending.WrapTotalSpending) JSON.deserializeStrict(totalSpending, BatchToComputeTotalSpending.WrapTotalSpending.Class);
        pgfRewardPoints.put(wrapObj.accId,wrapObj.accRecord);
        
        Agent_Reward__c agtReward = new Agent_Reward__c();
        agtReward.Account__c = wrapObj.accId;
        agtReward.Subscription_Spending__c = wrapObj.subsSpending;
        agtReward.Discretionary_Spending__c = wrapObj.discSpending;
        agtReward.Reward_Points__c = wrapObj.rewardPoints;
        agtReward.Reward_Tier__c = wrapObj.rewardTier;
        agtReward.Calculated_from__c = 'Reward Calculator';
        agtReward.PG_Reward_Points__c = wrapObj.PGRewardPoint;
        agtReward.PGF_Loan_Reward_Points__c = wrapObj.PGFRewardPoint;
        agtReward.CurrencyIsoCode = wrapObj.CurrencyIsoCode;
        Insert agtReward;
        ARlist.add(agtReward);
        
        publishRewardsToAgents.publishPoints(ARlist,PGFRewardPoints,wrapObj.country,false);
        
        Account acc = [SELECT Id,Reward_Points__c,reward_tier__c,AgentNet_ID__c FROM Account WHERE Id =: wrapObj.accId];
        acc.isRewardTierUpdated__c = true; 
        
        List<Account> toUpdate = new List<Account>();
        toUpdate.add(acc);
        
        Database.SaveResult[] updateResults = Database.update(toUpdate,false);
        publishRewardsToAgents.CSVWrapper CSVResults = new publishRewardsToAgents.CSVWrapper();
        
        CSVResults = publishRewardsToAgents.notifyUpdateStatus(updateResults,toUpdate,wrapObj.country,agentVsTier,true);
        
        csvRowValuesAgentSuccess.addall(CSVResults.successCSV);
        csvRowValuesAgentFailure.addall(CSVResults.errorCSV);
        System.debug('csvRowValuesAgentSuccess-->>'+csvRowValuesAgentSuccess);
        String csvColumnHeader; 
        Folder f = [SELECT Id, Name FROM Folder WHERE Name = 'BatchToComputeTotalSpending_Results'];
        
        if(!csvRowValuesAgentSuccess.isEmpty()){
            
            String documentName = 'BatchToComputeTotalSpending_SuccessResults-'+ Datetime.now().format('MMM') + Datetime.now().year();
            csvColumnHeader = 'Date, AccountId ,Reward Points, Reward Tiers ,AgentNet ID,Update Status\n';
            String csvFile = csvColumnHeader + String.join(csvRowValuesAgentSuccess,'\n');
            
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = f.Id, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;     
            
            rewardCalculationSuccess.add(new RewardCalculation__e(Document_Id__c = doc.id, Message__c = wrapObj.country+': Update'));
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
        
    }
    
    private static WrapResponse calculateInputFields (String accId){
        Account acc = [SELECT Id,Loyalty_Start_Date__c,Country__c,PGF_Reward_Points__c	,PG_Reward_Points__c,CurrencyIsoCode FROM Account WHERE Id =: accId];
        BatchToComputeTotalSpending batchObj = new BatchToComputeTotalSpending(acc.Country__c,false);
        Map<String,Rewards_Calculator__c> XYFactorMap = batchObj.returnRewardFactors();
        
        WrapResponse wrapRes = new WrapResponse();
        wrapRes.loyaltyStartDate = acc.Loyalty_Start_Date__c;
        wrapRes.calculateEndDate = batchObj.calculateCED(false,acc.Country__c);
        wrapRes.PGFRewardPoints = acc.PGF_Reward_Points__c;
        wrapRes.pgRewardPoints = acc.PG_Reward_Points__c;
        wrapRes.agtCountry = acc.Country__c;
        wrapRes.CurrencyIsoCode = acc.CurrencyIsoCode;
        
        if(XYFactorMap.containsKey(acc.Country__c)){
            wrapRes.XFactor = XYFactorMap.get(acc.Country__c).X_factor__c;
            wrapRes.YFactor = XYFactorMap.get(acc.Country__c).Y_factor__c;
        }
        return wrapRes;
    }
    
    public class WrapResponse {
        public date loyaltyStartDate;
        public date calculateEndDate;
        public String agtCountry;
        public String CurrencyIsoCode;
        public decimal pgfRewardPoints;
        public decimal pgRewardPoints;
        public decimal XFactor;
        public decimal YFactor;
    }
}