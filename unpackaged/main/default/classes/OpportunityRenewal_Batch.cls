/*------------------------------------------------------------
Author:        Whisnu Satriya Wardhana
Company:       Viseo Asia PTE LTD
Description:   Batch class to create Renewal Opportunity
Inputs:        

Test Class:    
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
global class OpportunityRenewal_Batch implements Database.Batchable<sObject>{
    String query; 
    
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        string identifier = 'AC_OpportunityRenewal_Batch';
        list<string> listCountry = EligibilityHandler.getCountryEligibility(identifier);
        datetime nextMonth = system.today().addMonths(1);
        query = 'SELECT Id, Name, OwnerId, Country__c, CurrencyIsoCode, Subsidiary__c, Subscription_End_Date__c, Opportunity_Created_Date__c, Updated_From_API__c FROM Account WHERE Country__c in (\''+string.join(listCountry, '\',\'')+'\') and calendar_month(Subscription_End_Date__c) = '+nextMonth.month()+' and calendar_year(Subscription_End_Date__c) = '+nextMonth.year()+' AND ((Country__c=\'Singapore\' and Status__c!=\'Cancelled\') or (Country__c=\'Malaysia\' and Status__c=\'Active\')) AND Account_Rule_Code__c not in (\'Trial\', \'\',\'Developer\', null) AND (NOT Account_Rule_Code__c like \'%CORP%\') AND RecordType.Name = \'Agent\'';
        system.debug(query);
        return Database.getQueryLocator(query);       
    }
    global void execute(Database.BatchableContext BC, List<Account> batch) {        
        if(batch.size() > 0){
            map<integer, string> mapMonth = new map<integer, string>{1=>'January', 2=>'February', 3=>'March', 4=>'April', 5=>'May', 6=>'June', 7=>'July', 8=>'August', 9=>'September', 10=>'October', 11=>'November', 12=>'December'};
                list<Id> listCheckAgentHasRenewalOpp = new list<Id>();
            list<Id> listAgentId = new list<Id>();
            list<Opportunity> listExistingOpp = new list<Opportunity>();
            map<string, string> MapAccRT = new map<string, string>();
            map<string, string> mapCountryOwner = new map<string, string>{'Singapore' => id.valueOf(label.PG_LABEL_SG_Renewal_Team_Lead), 'Thailand' => id.valueOf(label.PG_LABEL_TH_Renewal_Team_Lead), 'Malaysia' => id.valueOf(label.PG_LABEL_MY_Renewal_Team_Lead), 'Indonesia' => id.valueOf(label.PG_LABEL_ID_Renewal_Team_Lead)};
                for (RecordType rt : [SELECT Id, Name FROM RecordType WHERE SObjectType='Opportunity' and Name='B2C']){
                    MapAccRT.put(rt.Name, rt.Id);
                }
            List<Opportunity> newOpportunityRenewal = new List<Opportunity>();
            for(Account row : batch){
                listAgentId.add(row.Id);
            }
            datetime currentMonth = system.today();
            for (Opportunity row: [select Id, AccountId from Opportunity where RecordType.Name='B2C' and Order_Type_Clone__c ='Contract - Renewal' and calendar_month(CreatedDate)=:currentMonth.month() and calendar_year(CreatedDate)=:currentMonth.year() and AccountId in :listAgentId]) {
                listCheckAgentHasRenewalOpp.add(row.AccountId);
            }
            Opportunity temp;
            
            for (Account row: batch) {
                if (!listCheckAgentHasRenewalOpp.contains(row.Id)) {
                    Date dateField = row.Subscription_End_Date__c;
                    dateField = dateField.addMonths(1);
                    Integer numberOfDays = Date.daysInMonth(dateField.year(), dateField.month());
                    Date lastDayOfMonth = Date.newInstance(dateField.year(), dateField.month(), numberOfDays);
                    temp = new Opportunity(
                        CloseDate = lastDayOfMonth,
                        Name = (mapMonth.get(row.Subscription_End_Date__c.month()) + ' ' + row.Subscription_End_Date__c.year() + ' Renew Agent ' + row.Name),
                        StageName = 'Proposal',
                        AccountId = row.Id,
                        Subsidiary__c = row.Subsidiary__c,
                        CurrencyIsoCode = row.CurrencyIsoCode,
                        OwnerId = mapCountryOwner.get(row.Country__c),
                        RecordTypeId = MapAccRT.get('B2C'),
                        Subscription_End_Date__c = row.Subscription_End_Date__c.addYears(1),
                        Order_Type_Clone__c  = 'Contract - Renewal',
                        IsClone__c = 'NO',
                        Renewal_State__c = 'Early Bird' 
                    );
                    newOpportunityRenewal.add(temp);
                }
            }
            if(newOpportunityRenewal.size() > 0){
                list<Id> listOppId = new list<Id>();
                list<Opportunity> listOpp = new list<Opportunity>();
                list<Id> listAccId = new list<Id>();
                list<Account> listAcc = new list<Account>();
                
                // DML statement
                Database.SaveResult[] srList = Database.insert(newOpportunityRenewal, false);
                
                // Iterate through each returned result
                for (Database.SaveResult sr : srList) {
                    if (sr.isSuccess()) {
                        // Operation was successful, so get the ID of the record that was processed
                        system.debug('succeed sr.getId():'+sr.getId());
                        listOppId.add(sr.getId());
                    } else {
                        // Operation failed, so get all errors                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred.');                    
                            System.debug(err.getStatusCode() + ': ' + err.getMessage());
                            System.debug('Account fields that affected this error: ' + err.getFields());
                        }
                    }
                }
                
                list<Task> tskList = new list<task>();
                List<OpportunityTeamMember> createOpportunityTeamMember = new List<OpportunityTeamMember>();
                if(!listOppId.IsEmpty() && listOppId.size()>0)
                    for(Opportunity op : [select Id,AccountId,CloseDate,Account.VIP__c,Account.Commando_Sales_Rep__r.IsActive,Account.Commando_Sales_Rep__c,Account.Commando_Sales_Rep__r.Team_Lead__c,Account.PersonContactId from Opportunity where Id In : listOppId]){
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
                
                //added by vikas
                if(!listOppId.IsEmpty())
                    QuoteSyncHandler.syncQuoteToOpp(listOppId);
                
                if (listOppId.size() > 0) {
                    for (Opportunity row: [select Id, Name, AccountId from Opportunity where Id in :listOppId]) {
                        listAccId.add(row.AccountId);
                    }
                    
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
        
    }
}