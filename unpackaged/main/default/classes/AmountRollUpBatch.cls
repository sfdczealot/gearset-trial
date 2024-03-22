/**
@name			AmountRollUpBatch
@Description	Schedulable batch class to update the roll up fields (like CSS amount and pro rate)
@Version 		1.0
@reference 		PGAUTO-6559
**/
global class AmountRollUpBatch implements Database.Batchable<sObject>, System.Schedulable {
    
    global final static string B2C_OPP_RECORDTYPEiD = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C');
    global final static string B2C_SS_OPP_RECORDTYPEiD = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C Self-Serve');
    
    global Database.QueryLocator start(Database.BatchableContext jobId) {
        String activeOppQuery = label.PG_LABEL_OppExclude_q;
        if(activeOppQuery.equals('null')) {
            activeOppQuery = 'SELECT Id FROM Account WHERE (Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\' ';
            activeOppQuery += 'AND Status__c != \'Pending\') and Customer_Type__c = \'Agent\'';
        }
        return Database.getQueryLocator(activeOppQuery);
    }
    
    global void execute(Database.BatchableContext BC, List<Account> activeAgents) {
        Set<Id> accIds = new Set<Id>();
        for(Account acc : activeAgents) {
            accIds.add(acc.Id); 
        }

        Map<Id,Opportunity> accIdsVsB2cOpp = new Map<Id,Opportunity>();
        Map<Id,Opportunity> accIdsVsB2cSSOpp = new Map<Id,Opportunity>();
        
        if(!accIds.isEmpty()) {
            for(Opportunity opp:[SELECT Id, AccountId, OMC_Approved_Date__c,
                                 (SELECT Id, Push_to_NetSuite__c 
                                  FROM OpportunityLineItems 
                                  WHERE Product2.Product_Category__c ='Subscription' 
                                  AND Complimentary__c = false
                                  AND Push_to_NetSuite__c = true
                                 ) FROM Opportunity
                                 WHERE AccountId IN: accIds
                                 AND IsWon = true
                                 AND RecordTypeId =: B2C_OPP_RECORDTYPEiD
                                 ORDER BY OMC_Approved_Date__c DESC
                                ]
               ) { 
                   if(!opp.OpportunityLineItems.isEmpty() && !accIdsVsB2cOpp.containsKey(opp.AccountId)) {
                       accIdsVsB2cOpp.put(opp.AccountId,opp);
                   }
               }
            
            for(Opportunity opp:[SELECT Id, AccountId, CloseDate,
                                 (SELECT Id, Push_to_NetSuite__c 
                                  FROM OpportunityLineItems 
                                  WHERE Product2.Product_Category__c ='Subscription' 
                                  AND Complimentary__c = false
                                  AND Push_to_NetSuite__c = true
                                 ) FROM Opportunity
                                 WHERE AccountId IN: accIds
                                 AND StageName = 'Converted'
                                 AND RecordTypeId =: B2C_SS_OPP_RECORDTYPEiD
                                 ORDER BY CloseDate DESC
                                ]
               ) { 
                   if(!opp.OpportunityLineItems.isEmpty() && !accIdsVsB2cSSOpp.containsKey(opp.AccountId)) {
                       accIdsVsB2cSSOpp.put(opp.AccountId,opp);
                   }
               }
            
        }
        for(Account eachAcc : activeAgents) {
            if(!accIdsVsB2cOpp.isEmpty() && 
               accIdsVsB2cOpp.containsKey(eachAcc.Id) &&
               !accIdsVsB2cSSOpp.isEmpty() && 
               accIdsVsB2cSSOpp.containsKey(eachAcc.Id)
              ) {
                  if(accIdsVsB2cOpp.get(eachAcc.Id).OMC_Approved_Date__c > accIdsVsB2cSSOpp.get(eachAcc.Id).CloseDate) {
                      AmountRollUpHandler.populateClosedWonFields(eachAcc.Id,accIdsVsB2cOpp.get(eachAcc.Id).Id);
                  } else if(accIdsVsB2cOpp.get(eachAcc.Id).OMC_Approved_Date__c < accIdsVsB2cSSOpp.get(eachAcc.Id).CloseDate) {
                      AmountRollUpHandler.populateConvertedSSFields(accIdsVsB2cSSOpp.get(eachAcc.Id).Id);
                  }
              } else if(!accIdsVsB2cOpp.isEmpty() && accIdsVsB2cOpp.containsKey(eachAcc.Id) ) {
                  AmountRollUpHandler.populateClosedWonFields(eachAcc.Id,accIdsVsB2cOpp.get(eachAcc.Id).Id);      
              } else if(!accIdsVsB2cSSOpp.isEmpty() && accIdsVsB2cSSOpp.containsKey(eachAcc.Id)) {
                  AmountRollUpHandler.populateConvertedSSFields(accIdsVsB2cSSOpp.get(eachAcc.Id).Id); 
              }
        }
    }
    
    global void finish(Database.BatchableContext BC) {
          
    }
    
    global Void execute(System.SchedulableContext context) {
        Database.executeBatch(new AmountRollUpBatch(), 1);
    }
}