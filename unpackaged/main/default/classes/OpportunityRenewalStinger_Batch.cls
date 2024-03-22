//TEST CLASS :OpportunityRenwalStingerBatch_Test
Global class OpportunityRenewalStinger_Batch implements Database.Batchable<sObject>, Database.Stateful,Database.AllowsCallouts{
    
    public class Payload {
        String text;
    }
    
    String query;
    Map<String, list<Opportunity>> ruleCodeMap  = new Map<String, list<Opportunity>>();
    Map<String, list<Opportunity>> ruleCodeMapMY  = new Map<String, list<Opportunity>>();    
    Map<Id,String> accIdWithError = new Map<Id,String>();
    List<Payment_Term__c> rowPaymentTerms = new List<Payment_Term__c>();
    public Map<String,Integer> countryVsNoOfAgents = new Map<String,Integer>{'Thailand' => 0 , 'Singapore'=> 0 , 'Malaysia'=> 0 };
    public Map<String,Integer> countryVsNoOfRenewalOpps = new Map<String,Integer>{'Thailand' => 0 , 'Singapore'=> 0 , 'Malaysia'=> 0 };
    public Set<String> countrySet = new Set<String>{'Thailand', 'Singapore', 'Malaysia'};
        
        Global Database.QueryLocator start(Database.BatchableContext BC)  {
            // Remove EligibilityHandler Dependency 
            //string identifier = 'AC_OpportunityRenewal_Batch';
            //Set<string> setCountry = new Set<String>(EligibilityHandler.getCountryEligibility(identifier));
            Set<string> setCountry = new Set<String>{'Malaysia', 'Singapore', 'Thailand'};
                Datetime nextMonth = system.today().addMonths(1);
            Integer nxtmonth=nextMonth.month();
            Integer nxtyear=nextMonth.year();
            
            query= system.label.Query_OpportunityRenewalStinger_Batch;
            
            rowPaymentTerms = new list<Payment_Term__c>([SELECT Id FROM Payment_Term__c WHERE name = 'Immediate' LIMIT 1]);
            
            return Database.getQueryLocator(query);       
        }
    
    Global void execute(Database.BatchableContext BC, List<Account> batch) {
        // Created for PGAUTO-5241
        Set<ID> setOfAccId = new Set<ID>(); 
        Set<Id> oppId = new Set<Id>();
        List<Opportunity> toUpdateOpps = new List<Opportunity>();
        List<Quote> toUpdateQuotes = new List<Quote>();
        
        if(batch.size() > 0){
            Map<Integer, String> mapMonth = new Map<Integer, String>{1=>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May', 6=>'June', 7=>'July', 8=>'August', 9=>'September', 10=>'October', 11=>'November', 12=>'December'};
            List<Id> listCheckAgentHasRenewalOpp = new List<Id>();
            List<Id> listAgentId = new List<Id>();
            List<Opportunity> listExistingOpp = new List<Opportunity>();  
            Map<string, string> mapAccRT = new Map<string, string>();
            Map<string, string> mapCountryOwner = new Map<string, string>{'Singapore' => id.valueOf(label.PG_LABEL_SG_Renewal_Team_Lead), 'Thailand' => id.valueOf(label.PG_LABEL_TH_Renewal_Team_Lead), 'Malaysia' => id.valueOf(label.PG_LABEL_MY_Renewal_Team_Lead), 'Indonesia' => id.valueOf(label.PG_LABEL_ID_Renewal_Team_Lead)};
                
                for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType='Opportunity' and Name='B2C']){
                    MapAccRT.put(rt.Name, rt.Id);
                }
            
            List<Opportunity> newOpportunityRenewal = new List<Opportunity>();
            Set<Id> roleId = new Set<Id>();
            Set<Id> parentRoleId = new Set<id>();
            Map<Id,Id> roleVsAccount = new Map<Id,Id>();
            Map<Id,Id> parentRoleVsAccount = new Map<Id,Id>();
            Map<Id,Id> AccountVsOwnerid = new Map<Id,Id>();
            
            for(Account row : batch){
                
                listAgentId.add(row.Id);
                //Added to update the owner of renewal oppty (PGAUTO-6908)
                if(row.Renewal_Opportunity_User__c!=null) {
                    if(row.Renewal_Opportunity_User__r.isactive) {
                        AccountVsOwnerid.put(row.id,row.Renewal_Opportunity_User__c);
                    } else {
                        roleId.add(row.Renewal_Opportunity_User__r.UserRoleId);   
                        roleVsAccount.put(row.Renewal_Opportunity_User__r.UserRoleId,row.id);
                    }
                    
                } else {
                    AccountVsOwnerid.put(row.id,mapCountryOwner.get(row.Country__c));   
                }
            }
           
            if(roleId!=null){
                for(UserRole ur :[Select id,parentroleid from userRole where ID IN : roleId]){
                    parentRoleId.add(ur.parentroleid);  
                    parentRoleVsAccount.put(ur.parentroleid,roleVsAccount.get(ur.id));
                }
                for(User us : [Select id, UserRoleId from user where UserRoleId IN : parentRoleId]){
                    AccountVsOwnerid.put(parentRoleVsAccount.get(us.UserRoleId),us.id);
                }
                
            }
      
            Datetime currentMonth = system.today();
            //Added Upgrade Opp condition to restrict Renewal Opp Creation (PGAUTO-5241)
            for (Opportunity row: [SELECT Id, AccountId FROM Opportunity WHERE 
                                   RecordType.Name='B2C' AND 
                                   ((Opportunity_Type__c='B2C - Renewal' AND 
                                     calendar_month(CreatedDate)=:currentMonth.month() AND 
                                     calendar_year(CreatedDate)=:currentMonth.year()) OR 
                                    (Opportunity_Type__c='B2C - Upgrade' AND 
                                     Account.Country__c = 'Singapore' AND 
                                     (StageName = 'Pending OMC Approval' OR 
                                      (StageName = 'Pending Online Payment' AND 
                                       SyncedQuote.Agent_Accepted_Time__c != null)))) AND 
                                   AccountId in :listAgentId]) {
                                       listCheckAgentHasRenewalOpp.add(row.AccountId);
                                   }
            
            Opportunity temp;
            system.debug('@@@@listCheckAgentHasRenewalOpp'+listCheckAgentHasRenewalOpp);
            
            for (Account row: batch) {
                if (!listCheckAgentHasRenewalOpp.contains(row.Id)) {
                    
                    if(row.Country__c!=null){
                        if(!countrySet.contains(row.Country__c))
                            countrySet.add(row.Country__c);
                        
                        if(!countryVsNoOfAgents.containsKey(row.Country__c))
                            countryVsNoOfAgents.put(row.Country__c,0);
                        
                        Integer countryCount = countryVsNoOfAgents.get(row.Country__c);
                        countryCount = countryCount+1;
                        countryVsNoOfAgents.put(row.Country__c,countryCount);
                    } 
                    
                    Date dateField = row.Subscription_End_Date__c; 
                    if(row.Country__c !='Singapore'){
                        dateField = dateField.addMonths(1);   
                    }
                    else{
                        setOfAccId.add(row.Id); //Added for PGAUTO-5241
                    }
                    
                    Integer numberOfDays = Date.daysInMonth(dateField.year(), dateField.month()); 
                    Date lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
                    temp = new Opportunity(
                        CloseDate = lastDayOfMonth,
                        Name = (mapMonth.get(row.Subscription_End_Date__c.month()) + ' ' + row.Subscription_End_Date__c.year() + ' Renew Agent ' + row.Name),
                        StageName = 'New',
                        AccountId = row.Id,
                        Subsidiary__c = row.Subsidiary__c,
                        CurrencyIsoCode = row.CurrencyIsoCode,
                        OwnerId = AccountVsOwnerid.get(row.id),
                        RecordTypeId = MapAccRT.get('B2C'),
                        Subscription_End_Date__c = row.Subscription_End_Date__c.addYears(1),
                        Opportunity_Type__c = 'B2C - Renewal',
                        IsClone__c = 'NO',
                        Renewal_State__c = 'Early Bird',
                        Payment_Term__c = rowPaymentTerms[0].Id
                    );
                    
                    newOpportunityRenewal.add(temp);
                }
            }
            
            // Added Upgrade Opp condition to update Opp Stage to Closed Lost (PGAUTO-5241)
            if(!setOfAccId.isEmpty()){
                for (Opportunity opp: [SELECT Id,StageName FROM Opportunity
                                       WHERE AccountId In :setOfAccId
                                       AND RecordType.Name='B2C'
                                       AND Opportunity_Type__c='B2C - Upgrade' 
                                       AND (StageName = 'Proposal' 
                                            OR(StageName = 'Pending Online Payment' 
                                               AND SyncedQuote.Agent_Accepted_Time__c = null))])
                {
                    opp.StageName = 'Closed Lost';
                    opp.Loss_Reason__c = 'Expired Offer';
                    oppId.add(opp.Id);
                    toUpdateOpps.add(opp);
                }
            }
            
            // Added to update Quote Status to Invalid (PGAUTO-5241)
            if(!oppId.isEmpty()){
                
                for(Quote quo : [Select Id from Quote where OpportunityId In: oppId]){
                    quo.Loss_Reason__c = 'Expired Offer';
                    quo.Status = 'Invalid';
                    toUpdateQuotes.add(quo);
                }
            }
            
            if(newOpportunityRenewal.size() > 0){
                list<Id> listOppId = new list<Id>();
                list<Opportunity> listOpp = new list<Opportunity>();
                list<Id> listAccId = new list<Id>();
                list<Account> listAcc = new list<Account>();
                list<Id> successAccId = new list<Id>();
                Map<Integer,Database.Error> errorMap = new Map<Integer,Database.Error>();
                Integer count = 0;
                Integer errorCount = 0;
             
                // DML statement
                Database.SaveResult[] srList = Database.insert(newOpportunityRenewal, false);

                // Iterate through each returned result
                for(Database.SaveResult srObj: srList){
                    if(srObj.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        listOppId.add(srObj.getId()); 
                    }
                }
                
                for(Opportunity opp:[SELECT Id,AccountId FROM Opportunity WHERE ID IN:listOppId]){
                    successAccId.add(opp.AccountId);
                }
                
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        system.debug('succeed sr.getId():'+sr.getId()); 
                    } else {  
                        // Operation failed, so get all errors              
                        for(Database.Error err : sr.getErrors()) {
                            errorMap.put(errorCount,err);
                            errorCount++;
                        }
                        
                        for(Opportunity oppObj:newOpportunityRenewal){
                            if(!successAccId.contains(oppObj.AccountId) && Count<errorMap.values().size() && !accIdWithError.containskey(oppObj.AccountId)){
                                accIdWithError.put(oppObj.AccountId,errorMap.get(count).getStatusCode() + ':' +errorMap.get(count).getMessage());
                                count++;
                            }
                        }
                    }
                }
                
                list<Task> tskList = new list<task>();
                List<OpportunityTeamMember> createOpportunityTeamMember = new List<OpportunityTeamMember>();
                if(!listOppId.IsEmpty() && listOppId.size()>0)
                    for(Opportunity op : [select Id,AccountId,CloseDate,Account.VIP__c,Account.Commando_Sales_Rep__r.IsActive,Account.Commando_Sales_Rep__c,Account.Account_Rule_Code__c,Account.Commando_Sales_Rep__r.Team_Lead__c,account.Country__c,Account.PersonContactId from Opportunity where Id In : listOppId order by account.Account_Rule_Code__c,account.of_active_listings__c desc]){
                        
                        if(op.account.Country__c=='Thailand'){
                            if(!ruleCodeMap.containsKey(op.Account.Account_Rule_Code__c.tolowercase())) {
                                ruleCodeMap.put(op.Account.Account_Rule_Code__c.tolowercase(),new List<Opportunity>{op});
                            } else 
                            {
                                ruleCodeMap.get(op.Account.Account_Rule_Code__c.tolowercase()).add(op);
                            }   
                        }  else if(op.Account.Country__c == 'Malaysia'){
                            if(!ruleCodeMapMY.containsKey(op.Account.Account_Rule_Code__c.tolowercase())) {
                                ruleCodeMapMY.put(op.Account.Account_Rule_Code__c.tolowercase(),new List<Opportunity>{op});
                            } else 
                            {
                                ruleCodeMapMY.get(op.Account.Account_Rule_Code__c.tolowercase()).add(op);
                            }   
                        }  
                        if(String.isNotBlank(op.Account.Commando_Sales_Rep__c) && op.Account.VIP__c == true){
                            
                            //create task for Commando Sales Rep/Team Lead
                            Task tsk = new Task();
                            tsk.Subject = 'Followup VIP Package';
                            tsk.Status = 'Open';
                            tsk.Priority = 'Normal';
                            tsk.WhatId = op.Id;
                            tsk.ActivityDate = op.CloseDate;
                            tsk.WhoId = op.Account.PersonContactId;
                            
                            //Create Opportunity Team Member
                            OpportunityTeamMember otm = new OpportunityTeamMember();
                            otm.OpportunityId = op.Id;
                            otm.OpportunityAccessLevel = 'Read';
                            if(op.Account.Commando_Sales_Rep__r.IsActive){
                                otm.UserId = op.Account.Commando_Sales_Rep__c;
                                tsk.OwnerId = op.Account.Commando_Sales_Rep__c;
                            }
                            
                            else if(op.Account.Commando_Sales_Rep__r.Team_Lead__c != null){
                                otm.UserId = op.Account.Commando_Sales_Rep__r.Team_Lead__c;
                                tsk.OwnerId = op.Account.Commando_Sales_Rep__c;
                            }
                            
                            
                            otm.TeamMemberRole = 'Sales Rep';
                            
                            if(otm.UserId != null)
                                createOpportunityTeamMember.add(otm);
                            
                            if(tsk.OwnerId != null)
                                tskList.add(tsk);
                        }
                    }
                if(!createOpportunityTeamMember.isEmpty())
                    insert createOpportunityTeamMember;
                
                if(!tskList.isEmpty())
                    insert tskList;
                
                // Added for PGAUTO-5241
                if(toUpdateQuotes.size()>0)
                    update toUpdateQuotes;
                
                // Added for PGAUTO-5241
                if(toUpdateOpps.size()>0)
                    update toUpdateOpps;
                
                //added by vikas
                //if(!listOppId.IsEmpty())
                //QuoteSyncHandler.syncQuoteToOpp(listOppId);
                
                if (listOppId.size() > 0) {
                    for (Opportunity row: [select Id, Name,Account.Country__c, AccountId from Opportunity where Id in :listOppId]) {
                        listAccId.add(row.AccountId);
                        if(row.Account.Country__c!=null){
                            if(!countrySet.contains(row.Account.Country__c))
                                countrySet.add(row.Account.Country__c);
                            
                            if(!countryVsNoOfRenewalOpps.containsKey(row.Account.Country__c))
                                countryVsNoOfRenewalOpps.put(row.Account.Country__c,0);
                            
                            Integer countryCount = countryVsNoOfRenewalOpps.get(row.Account.Country__c);
                            countryCount = countryCount+1;
                            countryVsNoOfRenewalOpps.put(row.Account.Country__c,countryCount);
                        }
                        
                    }
                    system.debug('@@@@countryVsNoOfRenewalOpps'+countryVsNoOfRenewalOpps);
                    
                    listAcc = [select Id, Opportunity_Created_Date__c, Updated_From_API__c from Account where Id in :listAccId];
                    for (Account row: listAcc) {
                        row.Opportunity_Created_Date__c = system.today();
                        row.Updated_From_API__c = !row.Updated_From_API__c;
                    }
                    update listAcc;
                    system.debug('update succeed.');
                }
                
            }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        //to send report in alert-pgautomation
        renewalOppsSlackAlert(countrySet,countryVsNoOfAgents,countryVsNoOfRenewalOpps);
        slackAlertOnRenewalOppError(accIdWithError);
        if(countryVsNoOfRenewalOpps.get('Singapore') != 0){
            Renewal_Self_Serve_Oppty_update_insert__e oInsert = new Renewal_Self_Serve_Oppty_update_insert__e(
                event__c  = 'batch' );
            EventBus.publish(oInsert);
        }
        if(ruleCodeMap.size()>0)
            AssignTHOppty.assignOppty(ruleCodeMap);
        
        if(ruleCodeMapMy.size()>0)
            AssignMY_SGRenewalOpp.assignMYRenewalOppty(ruleCodeMapMy);
    }
    
    public void renewalOppsSlackAlert(Set<String> countrySet ,Map<String,Integer> countryVsNoOfAgents , Map<String,Integer> countryVsNoOfRenewalOpps){
        if(!runningInASandbox() || Test.isRunningTest()){
            
            Payload PayloadData = new Payload();
            String slack_User = label.ALERT_RENEWAL_OPP_INSERT;
            String title = slack_User+' '+'Please find renewal Opportunity report on the basis of country\n';
            String text = '', payload = '';
            title += '```"Country", "NoOfMatchingCriteriaAgents", "NoOfRenewalOppCreated"\n';
            
            for(String country: countrySet) {
                String noOfAgents;
                String noOfRenewalOpps;
                if(countryVsNoOfAgents.containsKey(country) && countryVsNoOfAgents.get(country)!=null) {
                    noOfAgents = String.valueOf(countryVsNoOfAgents.get(country));
                } else {
                    noOfAgents = '0';
                }
                if(countryVsNoOfRenewalOpps.containsKey(country) && countryVsNoOfRenewalOpps.get(country)!=null) {
                    noOfRenewalOpps = String.valueOf(countryVsNoOfRenewalOpps.get(country));
                } else {
                    noOfRenewalOpps = '0';
                }
                text += '"'+country+'", "'+noOfAgents+'", "'+noOfRenewalOpps+'"\n';
            }
            
            if(String.isNotBlank(text)){
                text += '```';
                payload += title + text; 
            }
            
            if(payload <> ''){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(label.PG_LABEL_PGAutomationAlert);
                req.setMethod('POST');
                req.setHeader('Cache-Control', 'no-cache');
                req.setHeader('Content-Type', 'application/json');
                PayloadData.text = payload;
                string request = system.JSON.serialize(PayloadData);
                req.setBody(request);
                if(!Test.isRunningTest()){
                    HttpResponse res = h.send(req);
                    if (res.getStatusCode() <> 200) {
                        String errorResponse = res.getBody();
                        system.debug(errorResponse);
                    }
                }
            }
        }
    }
    
    public void slackAlertOnRenewalOppError(Map<Id,String> accIdWithError){
        if(!runningInASandbox() || Test.isRunningTest()){
            Map<Id,Account> idVsAgentRecord = new map<Id,Account>([SELECT Id,Name,Subscription_End_Date__c,AgentNet_ID__c,Account_Long_ID__c,
                                                                   Renewal_Opportunity_User__c,Renewal_Opportunity_User__r.Name FROM Account 
                                                                   WHERE Id IN:accIdWithError.keyset()]);
            Payload PayloadData = new Payload();
            String slack_User = label.ALERT_RENEWAL_OPP_INSERT;
            String title = slack_User+' '+'Please find report of error on Renewal Opportunity Creation\n';
            String text = '', payload = '';
            title += '```"Account LongId", "AgentNet Id","Subscription End Date" , "Renewal Opportunity User" , "Error"\n';
            
            for(Id accIds:accIdWithError.keySet()){
                String subEndDate = String.ValueOf(idVsAgentRecord.get(accIds).Subscription_End_Date__c).SubStringBefore('00:00:00');
                text += '"'+idVsAgentRecord.get(accIds).Account_Long_ID__c+'", "'+idVsAgentRecord.get(accIds).AgentNet_ID__c+'", "'+subEndDate+'", "'+idVsAgentRecord.get(accIds).Renewal_Opportunity_User__r.Name+'", "'+accIdWithError.get(accIds)+'"\n';
            }
            
            if(String.isNotBlank(text)){
                text += '```';
                payload += title + text; 
            }
            
            system.debug('@@@@payload'+payload);
            if(payload <> ''){
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setEndpoint(label.PG_LABEL_PGAutomationAlert);
                req.setMethod('POST');
                req.setHeader('Cache-Control', 'no-cache');
                req.setHeader('Content-Type', 'application/json');
                PayloadData.text = payload;
                string request = system.JSON.serialize(PayloadData);
                req.setBody(request);
                if(!Test.isRunningTest()){
                    HttpResponse res = h.send(req);
                    if (res.getStatusCode() <> 200) {
                        String errorResponse = res.getBody();
                        system.debug(errorResponse);
                    }
                }
            }
        }
    }
    public static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
}