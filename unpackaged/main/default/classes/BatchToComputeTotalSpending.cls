//PGAUTO - 5480
public class BatchToComputeTotalSpending implements Database.Batchable<sObject>,Schedulable,Database.Stateful,Database.AllowsCallouts{
    
    Boolean runOnly;
    Date calculationEndDate;
    String country;
    Map<String,Rewards_Calculator__c> XYFactor = new  Map<String,Rewards_Calculator__c>();
    List<String> csvRowValues = new List<String>(); // Stores the accountdetails with error
    List<String> csvRowValuesAgentSuccess = new List<String>(); // Stores the account Updated successsfuly
    List<String> csvRowValuesAgentFailure = new List<String>(); // Stores the accountdetails with error
    List<String> csvRemoveAgents = new List<String>(); //Stores the agent to be removed from AdminNet
    
    public BatchToComputeTotalSpending(String country, Boolean runOnly){
        this.runOnly = runOnly;
        this.country = country;
        XYFactor = returnRewardFactors();
        calculateCED(this.runOnly,this.country);   
    }   

    public void execute(SchedulableContext sc){  
        DataBase.executeBatch(new BatchToComputeTotalSpending('Singapore',false), 200);  
    }
    
    
    public Database.QueryLocator start(Database.BatchableContext bc){
        String query;
        if(country =='Singapore'){
            query = System.label.PG_LABEL_SG_Rewards_Criteria;    
        }
        if(country =='Malaysia'){
            system.debug(country);
            query = System.label.PG_LABEL_MY_Rewards_Criteria;    
        }
        system.debug(country);
        if(country =='Thailand'){
            query = System.label.PG_LABEL_TH_Rewards_Criteria;    
        }
        return Database.getQueryLocator(query); 
    } 
    
    
    public void execute(Database.BatchableContext BC, List<Account> scope){   
        
        computeTotalSpending(scope,calculationEndDate,XYFactor.get(country).X_factor__c,XYFactor.get(country).Y_factor__c,true,this.country);
        
    }
    /**
*  Method used to publish Agent Points and Tiers To Admin Net and report for any error
*  @name finish
*  @param 
*  @return void
*/    
    
    public void finish(Database.BatchableContext BC){     
        
        String csvColumnHeader; // Stores the header of CSV
        Map<String,Id> folderIds = new Map<String,Id>();
        List<RewardCalculation__e> rewardCalculationSuccess = new List<RewardCalculation__e>();
        
        for(Folder f : [SELECT Id, Name FROM Folder WHERE Name = 'BatchToComputeTotalSpending_Results' OR Name = 'BatchToComputeTotalSpending_BulkResult']){
            folderIds.put(f.Name,f.Id);
        }
        Id folderId;
        if(runOnly == true){
            folderId = folderIds.get('BatchToComputeTotalSpending_BulkResult');
        } else {
            folderId = folderIds.get('BatchToComputeTotalSpending_Results');
        }
        
        if(!csvRowValues.isEmpty()){
            String documentName = 'BatchToComputeTotalSpending_Errpr_Results-'+ Datetime.now().format('MMM') + Datetime.now().year();
            csvColumnHeader = 'Date,Country, AccountId, Subscription Amount,Discreption Amount, Total Spending, Reward Points, Reward Tiers,Message\n';
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
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folderId, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;            
        }
        
        if(!csvRowValuesAgentSuccess.isEmpty()){
            
            String documentName = 'BatchToComputeTotalSpending_SuccessResults-'+ Datetime.now().format('MMM') + Datetime.now().year();
            csvColumnHeader = 'Date, AccountId ,Reward Points, Reward Tiers ,AgentNet ID,Update Status\n';
            String csvFile = csvColumnHeader + String.join(csvRowValuesAgentSuccess,'\n');
            
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folderId, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;     
            
            rewardCalculationSuccess.add(new RewardCalculation__e(Document_Id__c = doc.id, Message__c = country+': Update'));
            EventBus.publish(rewardCalculationSuccess);
        } 
        if(!csvRemoveAgents.isEmpty()){
            String documentName = 'BatchToComputeTotalSpending_Remove_From_AdminNet '+ Datetime.now().format('MMM') + Datetime.now().year();
            csvColumnHeader = 'Date, AccountId ,Reward Points, Reward Tiers ,AgentNet ID,Update Status\n';
            String csvFile = csvColumnHeader + String.join(csvRemoveAgents,'\n');
            
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folderId, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;     
            
            rewardCalculationSuccess.add(new RewardCalculation__e(Document_Id__c = doc.id, Message__c = country+': Remove'));
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
            Document doc = new Document(Name = documentName, Body = Blob.valueOf(csvFile), FolderId = folderId, Type = 'csv', ContentType='application/vnd.ms-excel');
            insert doc;            
        }
        
    }
    
    /**
*  Method used to calculates the Total Spending of Agent and its reward points
*  @name computeTotalSpending
*  @param list<account>,Date,Decimal,Decimal,Boolean,String
*  @return String
*/
    public String computeTotalSpending(List<Account> scope,Date Calculation_end_date,Decimal xFactor, Decimal yFactor, Boolean calledFromBatch,String country){
        Set<Id> accMonthsDiff12 = new Set<Id>();
        Set<Id> accMonthsDiffLess12 = new Set<Id>();
        Set<Id> accList = new Set<Id>();
        Map<Id,Decimal> accSubInvoice = new Map<Id,Decimal>();
        Map<Id,Decimal> accDiscInvoice = new Map<Id,Decimal>();
        Map<String,Account>  accToUpdate = new Map<String,Account>();
        Map<Id,Decimal> accTotalSpending = new Map<Id,Decimal>();
        Date accLSD;
        
        for(Account acc : scope){           
            accToUpdate.put(acc.id,acc);
            if(acc.Loyalty_Start_Date__c!=null){
                accList.add(acc.id);
                
                if(calledFromBatch == false){
                    accLSD = acc.Loyalty_Start_Date__c;
                }
                if(acc.Loyalty_Start_Date__c.monthsBetween(Calculation_end_date)>12){
                    accMonthsDiff12.add(acc.id); // Accounts with differnce between CED and LSd >12
                }else{
                    accMonthsDiffLess12.add(acc.id);  // Accounts with differnce between CED and LSd <= 12
                }
            }
            
        }
        
        
        Set<Id> oppSub= new Set<Id>();
        Set<Id> oppDisc= new Set<Id>();
        set<Id> oppWithoutFinancial = new set<Id>();
        Set<Id> oppB2CSelfServe = new Set<Id>();
        DateTime CED_temp = Calculation_end_date;
        CED_temp= CED_temp.addHours(23);
        CED_temp= CED_temp.addMinutes(59);
        CED_temp= CED_temp.addSeconds(59);
        for(Opportunity opp : [Select id,account.Loyalty_Start_Date__c,Stagename,CloseDate,Total_Gross_Amount__c,recordtype.developername,OMC_Approved_Date__c,(Select id,name,Type__c from Financials__r where type__c = 'Invoice' OR type__c = 'Credit Memo') from opportunity where ((OMC_Approved_Date__c <= : CED_temp AND recordtype.developername = 'B2C')OR (CloseDate < : CED_temp.Date() AND recordtype.developername = 'B2C_Self_Serve'))  and
                               accountid IN : accList]){
                                   
                                   if(opp.Financials__r.isempty() && opp.Stagename=='Closed Won' && opp.Total_Gross_Amount__c >0 && opp.Recordtype.Developername == 'B2C'){
                                       oppWithoutFinancial.add(opp.Id); // Stores the Closed Won opportunities without Invoice                                       
                                   }
                                   if(opp.Financials__r.isempty() && opp.StageName== 'Converted' && opp.Total_Gross_Amount__c>0 && opp.RecordType.developername == 'B2C_Self_Serve'){
                                       oppB2CSelfServe.add(opp.Id); // stores converted b2c self-serve opps without invoice
                                   }
                                   if(accMonthsDiffLess12.contains(opp.AccountId)){                                       
                                       Date loyaltyStartDate;
                                       
                                       if(calledFromBatch == false){
                                           loyaltyStartDate = accLSD;
                                       }
                                       else{
                                           loyaltyStartDate = opp.account.Loyalty_Start_Date__c;
                                       }
                                       
                                       if(opp.recordtype.developername == 'B2C')
                                       {
                                           if(opp.OMC_Approved_Date__c >=loyaltyStartDate.toStartOfMonth()){
                                               oppDisc.add(opp.id);
                                           }    
                                           if(opp.OMC_Approved_Date__c >=loyaltyStartDate.addMonths(-1).toStartOfMonth()){
                                               oppSub.add(opp.Id);
                                           } 
                                       } else if(opp.recordtype.developername == 'B2C_Self_Serve')
                                       {
                                           if(opp.CloseDate >=loyaltyStartDate.toStartOfMonth()){
                                               oppDisc.add(opp.id);
                                           }    
                                           if(opp.CloseDate >=loyaltyStartDate.addMonths(-1).toStartOfMonth()){
                                               oppSub.add(opp.Id);
                                           } 
                                       }
                                   }
                                   
                                   if(accMonthsDiff12.contains(opp.accountid)){
                                       if(opp.recordtype.developername == 'B2C'){
                                           if(opp.OMC_Approved_Date__c >= Calculation_end_date.addMonths(-11).toStartOfMonth()){
                                               oppDisc.add(opp.Id);
                                           }    
                                           if(opp.OMC_Approved_Date__c >= Calculation_end_date.addMonths(-12).toStartOfMonth()){
                                               oppSub.add(opp.Id);
                                           }
                                       }else if(opp.recordtype.developername == 'B2C_Self_Serve'){
                                           if(opp.CloseDate >= Calculation_end_date.addMonths(-11).toStartOfMonth()){
                                               
                                               oppDisc.add(opp.Id);
                                           }    
                                           if(opp.CloseDate >= Calculation_end_date.addMonths(-12).toStartOfMonth()){
                                               
                                               oppSub.add(opp.Id);
                                           } 
                                       }
                                   }  
                               }
        
        
        Set<Id> oppSubAndDisc = new Set<Id>();
        oppSubAndDisc.addall(oppDisc);
        oppSubAndDisc.addall(oppSub);
        for(Financial__c fin :[SELECT Id,Type__c,Subscription_Total__c,Discretionary_Total__c,Opportunity__r.accountid FROM Financial__c WHERE Opportunity__c IN : oppSubAndDisc]){
            
            if(fin.type__c =='Invoice' ){
                if(oppSub.contains(fin.Opportunity__c) && fin.Subscription_Total__c!=null){
                    if(!accSubInvoice.containskey(fin.Opportunity__r.accountid)){
                        accSubInvoice.put(fin.Opportunity__r.accountid,fin.Subscription_Total__c);
                    } else {
                        accSubInvoice.put(fin.Opportunity__r.accountid,accSubInvoice.get(fin.Opportunity__r.accountid)+fin.Subscription_Total__c);                       
                    }  
                }
                
                if( oppDisc.contains(fin.Opportunity__c ) && fin.Discretionary_Total__c!=null){
                    if(!accDiscInvoice.containskey(fin.Opportunity__r.accountid)){
                        accDiscInvoice.put(fin.Opportunity__r.accountid,fin.Discretionary_Total__c);
                    } else {
                        accDiscInvoice.put(fin.Opportunity__r.accountid,accDiscInvoice.get(fin.Opportunity__r.accountid)+fin.Discretionary_Total__c);
                    }
                }                
            }
            
            if(fin.type__c =='Credit Memo'){                
                if(oppSub.contains(fin.Opportunity__c) && fin.Subscription_Total__c!=null){                    
                    if(!accSubInvoice.containskey(fin.Opportunity__r.accountid)){
                        accSubInvoice.put(fin.Opportunity__r.accountid,-(fin.Subscription_Total__c));
                    } else {
                        accSubInvoice.put(fin.Opportunity__r.accountid,accSubInvoice.get(fin.Opportunity__r.accountid)-fin.Subscription_Total__c);
                    }
                }                
                if(oppDisc.contains(fin.Opportunity__c) && fin.Discretionary_Total__c!=null){                    
                    if(!accDiscInvoice.containskey(fin.Opportunity__r.accountid)) {
                        accDiscInvoice.put(fin.Opportunity__r.accountid,-(fin.Discretionary_Total__c));
                    } else {
                        accDiscInvoice.put(fin.Opportunity__r.accountid,accDiscInvoice.get(fin.Opportunity__r.accountid)-fin.Discretionary_Total__c);
                    }                    
                }                
            }
        }
        
        //Refer to OLI of opportunities without Financial Record created yet
        for(OpportunityLineItem OLI :[SELECT Id,Product2.Product_Category__c,Gross_Amount__c ,opportunityid,Opportunity.accountid,SNo__c FROM opportunityLineItem WHERE opportunityid IN : oppWithoutFinancial AND SNo__c!= null]){
            Decimal SNo = OLI.SNo__c;
            
            if(SNo - SNo.round(System.RoundingMode.DOWN)==00){ // Sno should be a whole Number
                if(OLI.Product2.Product_Category__c=='Subscription'){
                    if(oppSub.contains(OLI.OpportunityId) && OLI.Gross_Amount__c!=null){
                        if(!accSubInvoice.containskey(OLI.Opportunity.accountid)){
                            accSubInvoice.put(OLI.Opportunity.accountid,OLI.Gross_Amount__c);
                        }else{
                            accSubInvoice.put(OLI.Opportunity.accountid,accSubInvoice.get(OLI.Opportunity.accountid)+OLI.Gross_Amount__c);
                        }
                    }
                }else{
                    if(oppDisc.contains(OLI.OpportunityId) && OLI.Gross_Amount__c!=null){
                        if(!accDiscInvoice.containskey(OLI.Opportunity.accountid)){
                            accDiscInvoice.put(OLI.Opportunity.accountid,OLI.Gross_Amount__c);
                        }else{
                            accDiscInvoice.put(OLI.Opportunity.accountid,accDiscInvoice.get(OLI.Opportunity.accountid)+OLI.Gross_Amount__c);
                        }  
                    }
                }   
            }            
        }
        
        //OLI of B2C Self-Serve Opportunities without Financial Record
        for(opportunityLineItem OLI :[Select id,Product2.Product_Category__c,Gross_Amount__c ,opportunityid,Opportunity.accountid,SNo__c from opportunityLineItem where opportunityid IN : oppB2CSelfServe and SNo__c!= null]){
            Decimal SNo = OLI.SNo__c;
            
            if(SNo - SNo.round(System.RoundingMode.DOWN)==00){ // Sno should be a whole Number
                if(OLI.Product2.Product_Category__c=='Subscription'){
                    if(oppSub.contains(OLI.OpportunityId) && OLI.Gross_Amount__c!=null){
                        if(!accSubInvoice.containskey(OLI.Opportunity.accountid)){
                            accSubInvoice.put(OLI.Opportunity.accountid,OLI.Gross_Amount__c);
                        } else{
                            accSubInvoice.put(OLI.Opportunity.accountid,accSubInvoice.get(OLI.Opportunity.accountid)+OLI.Gross_Amount__c);
                        }
                    }
                }else{
                    if(oppDisc.contains(OLI.OpportunityId) && OLI.Gross_Amount__c!=null){
                        if(!accDiscInvoice.containskey(OLI.Opportunity.accountid)){
                            accDiscInvoice.put(OLI.Opportunity.accountid,OLI.Gross_Amount__c);
                        }else{
                            accDiscInvoice.put(OLI.Opportunity.accountid,accDiscInvoice.get(OLI.Opportunity.accountid)+OLI.Gross_Amount__c);
                        }
                    }   
                }   
            }            
        }
        //Add the Subscription and Discretionary amount to get Total Spending       
        List<Agent_Reward__c> ARList = new list<Agent_Reward__c>();
        Map<Id,Account> pgfRewardPoints = new Map<Id,Account>();
        Map<Id,Decimal> accRewardPoint = new Map<id,Decimal>();
        Map<Id,String> accRewardTier = new Map<id,String>();
        list<Reward_Calculation_Tier__mdt> countryVsTier = new list<Reward_Calculation_Tier__mdt>();
        List<WrapTotalSpending> listWrapTotalSpending = new list<WrapTotalSpending>();
        
        for(Reward_Calculation_Tier__mdt rewardTier : [Select id,Country__c,Lower_Limit__c,Upper_Limit__c,Tier__c from Reward_Calculation_Tier__mdt where Country__c=:Country ]){
            countryVsTier.add(rewardTier);
        }
        
        for(account acc : scope){
            if(!pgfRewardPoints.containskey(acc.id)){
                pgfRewardPoints.put(acc.Id,acc);
            }
            if(!accDiscInvoice.containskey(acc.id)&&!accSubInvoice.containskey(acc.id)){
                accTotalSpending.put(acc.id,0);
                accDiscInvoice.put(acc.id,0);
                accSubInvoice.put(acc.id,0);
            }
            if(accDiscInvoice.containskey(acc.id)){
                if(!accTotalSpending.containskey(acc.id)){
                    accTotalSpending.put(acc.id,accDiscInvoice.get(acc.id));  
                }else{
                    accTotalSpending.put(acc.id,accTotalSpending.get(acc.id)+accDiscInvoice.get(acc.id));  
                }
            }  else{
                accDiscInvoice.put(acc.id,0);
            } 
            if(accSubInvoice.containskey(acc.id)){
                if(!accTotalSpending.containskey(acc.id)){
                    accTotalSpending.put(acc.id,accSubInvoice.get(acc.id));  
                }else{
                    accTotalSpending.put(acc.id,accTotalSpending.get(acc.id)+accSubInvoice.get(acc.id));  
                }
            }else{
                accSubInvoice.put(acc.id,0); 
            } 
            
            if(accTotalSpending.containskey(acc.id)){
                pgfRewardPoints.get(acc.Id).PG_Reward_Points__c = (accTotalSpending.get(acc.id) / (xFactor * yFactor)).round(System.RoundingMode.CEILING);
                if(pgfRewardPoints.get(acc.Id).PGF_Reward_Points__c == null){
                    pgfRewardPoints.get(acc.Id).PGF_Reward_Points__c = 0;
                }
                Decimal RC = pgfRewardPoints.get(acc.Id).PG_Reward_Points__c+pgfRewardPoints.get(acc.Id).PGF_Reward_Points__c;
               
                if(RC < 0)
                    RC = 0;
                
                accRewardPoint.put(acc.id,RC);
                for(Reward_Calculation_Tier__mdt rewardTier : countryVsTier){
                    if(RC >= rewardTier.Lower_Limit__c && RC <= rewardTier.Upper_Limit__c ){
                        accRewardTier.put(acc.id,rewardTier.Tier__c);
                        break;
                    }     
                }
                Agent_Reward__c AR = new Agent_Reward__c(Calculated_from__c = 'Quartely Batch',Account__c = acc.Id,CurrencyIsoCode = acc.CurrencyIsoCode,Status__c = 'New Quarter',Discretionary_Spending__c = accDiscInvoice.get(acc.Id),Subscription_Spending__c =accSubInvoice.get(acc.Id), Reward_Points__c = accRewardPoint.get(acc.id), Reward_Tier__c = accRewardTier.get(acc.id) ,PG_Reward_Points__c = pgfRewardPoints.get(acc.Id).PG_Reward_Points__c ,PGF_Loan_Reward_Points__c = pgfRewardPoints.get(acc.Id).PGF_Reward_Points__c);
                ARList.add(AR);
                
                if(runOnly==true){
                    String rowStr = Datetime.now().format('MMM') + ','+ country + ',' + acc.Id + ',' + accSubInvoice.get(acc.Id) + ',' + accDiscInvoice.get(acc.Id) + ','+accTotalSpending.get(acc.id)+','+ accRewardPoint.get(acc.id)+','+ accRewardTier.get(acc.id) + ','  + 'Successfully calculated';
                    csvRowValues.add(rowStr); 
                }
            }
            
            // For Agent Reward Caculator Component
            WrapTotalSpending wrapResponse = new WrapTotalSpending();
            wrapResponse.accId = acc.Id;
            wrapResponse.country = acc.Country__c;
            wrapResponse.CurrencyIsoCode = acc.CurrencyIsoCode;
            
            if(accSubInvoice.containsKey(acc.Id)){
                wrapResponse.subsSpending = accSubInvoice.get(acc.Id);
            }
            if(accDiscInvoice.containsKey(acc.Id)){
                wrapResponse.discSpending = accDiscInvoice.get(acc.Id);
            }
            if(accTotalSpending.containsKey(acc.Id)){
                wrapResponse.totalSpending = accTotalSpending.get(acc.Id);
            }
            if(accRewardPoint.containsKey(acc.Id)){
                wrapResponse.rewardPoints = accRewardPoint.get(acc.Id);
            }
            if(accRewardTier.containsKey(acc.Id)){
                wrapResponse.rewardTier = accRewardTier.get(acc.Id);
            }
            if(PGFRewardPoints.containskey(acc.Id)){
                wrapResponse.accRecord = PGFRewardPoints.get(acc.Id);
                wrapResponse.PGRewardPoint = PGFRewardPoints.get(acc.Id).PG_Reward_Points__c;
                wrapResponse.PGFRewardPoint = PGFRewardPoints.get(acc.Id).PGF_Reward_Points__c;
                
            }
            
            listWrapTotalSpending.add(wrapResponse);
        }
        
        String failedDML;
        String AccountId;
        
        if(runOnly == false && calledFromBatch == true){
            Database.SaveResult[] updateResults = Database.insert(ARList,false);
            for(Integer i=0;i< updateResults.size();i++){
                
                if (!updateResults.get(i).isSuccess()){
                    Database.Error error = updateResults.get(i).getErrors().get(0);
                    failedDML = error.getMessage();
                    AccountId = ARList.get(i).Account__c; //failed record from the list
                    String rowStr = Datetime.now().format('MMM') + ','+ country + ','+ AccountId + ',' + accSubInvoice.get(AccountId) + ',' + accDiscInvoice.get(AccountId) + ','+accTotalSpending.get(AccountId)+','+ accRewardPoint.get(AccountId)+','+ accRewardTier.get(AccountId) + ',' + failedDML;
                    csvRowValues.add(rowStr);
                } else{                    
                    // accToUpdate.put(ARList.get(i).Account__c,accToUpdate.get(ARList.get(i).Account__c));                   
                }
            }
            publishRewardsToAgents.CSVWrapper CSVResults = new publishRewardsToAgents.CSVWrapper();
            
            CSVResults = publishRewardsToAgents.publishPoints(ARList,pgfRewardPoints,this.country,true);
            csvRowValuesAgentSuccess.addall(CSVResults.successCSV);
            csvRowValuesAgentFailure.addall(CSVResults.errorCSV);
            csvRemoveAgents.addall(CSVResults.removeAgentIdsCSV);
            //update accToUpdate.values();
        }
        return JSON.serialize(listWrapTotalSpending);        
    }
    
    //Calculates CED as last day of the month of previous quarter
    public Date calculateCED(Boolean runOnlyTemp, String countryTemp){
        
        country = countryTemp;
        runOnly = runOnlyTemp;
        
        Integer month = Date.today().month();
        
        if(month/3 == 0){
            calculationEndDate = date.newInstance(Date.today().year()-1, 12, date.daysInMonth(Date.today().year()-1, 12));            
        }
        
        else if(month/3 <= 1){
            if(math.mod(month,3) ==0){
                calculationEndDate = date.newInstance(Date.today().year()-1, 12, date.daysInMonth(Date.today().year()-1, 12));
                
            }
            if(math.mod(month,3) ==1){
                calculationEndDate = date.newInstance(Date.today().year(), 3, date.daysInMonth(Date.today().year(), 3));
                
            }
            if(math.mod(month,3) ==2){
                calculationEndDate = date.newInstance(Date.today().year(), 3, date.daysInMonth(Date.today().year(), 3));
                
            }
        }
        
        else if(month/3 <= 2){
            if(math.mod(month,3) ==0){
                calculationEndDate = date.newInstance(Date.today().year(), 3, date.daysInMonth(Date.today().year(), 3));
                
            }
            if(math.mod(month,3) ==1){
                calculationEndDate = date.newInstance(Date.today().year(), 6, date.daysInMonth(Date.today().year(), 6));
                
            }
            if(math.mod(month,3) ==2){
                calculationEndDate = date.newInstance(Date.today().year(), 6, date.daysInMonth(Date.today().year(), 6));
                
            }
        }
        
        else  if(month/3 <= 3){
            if(math.mod(month,3) ==0){
                calculationEndDate = date.newInstance(Date.today().year(), 6, date.daysInMonth(Date.today().year(), 6));
            }
            if(math.mod(month,3) ==1){
                calculationEndDate = date.newInstance(Date.today().year(), 9, date.daysInMonth(Date.today().year(), 9));
                
            }
            if(math.mod(month,3) ==2){
                calculationEndDate = date.newInstance(Date.today().year(), 9, date.daysInMonth(Date.today().year(), 9));
            }
        }
        
        else {
            calculationEndDate = date.newInstance(Date.today().year(), 9, date.daysInMonth(Date.today().year(), 9));
        } 
        
        return calculationEndDate;
    }
    
    //Fetch the X and Y factors as per country
    public Map<String,Rewards_Calculator__c> returnRewardFactors(){
        Map<String,Rewards_Calculator__c> XYFactorMap = new  Map<String,Rewards_Calculator__c>();
        for(Rewards_Calculator__c rc : [select Country__c, X_factor__c,Y_factor__c from Rewards_Calculator__c]){
            if(!XYFactorMap.containskey(rc.Country__c))
                XYFactorMap.put(rc.Country__c,rc);
        }
        return XYFactorMap;
    }
    
    // Created For Agent Reward Caculator 
    public class WrapTotalSpending {
        public String accId;
        public Decimal subsSpending;
        public Decimal discSpending;
        public Decimal totalSpending;
        public Decimal rewardPoints;
        public String rewardTier;
        public Account accRecord;
        public decimal PGFRewardPoint;
        public decimal PGRewardPoint;
        public string CurrencyIsoCode;
        public string country;
    }
}