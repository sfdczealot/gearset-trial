global class IncorrectCSS_Alert_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    global Database.QueryLocator start(Database.BatchableContext BC)  {
        //Get all active agents
        String query = label.PG_LABEL_IncorrectCSS_Batch_q;
        if(query == 'null'){
            query = 'SELECT id,Current_Subscription_Spending_Amount__c,AgentKey__c, Pro_Rate_Amount__c from Account where RecordType.Name = \'Agent\' and Status__c !=\'Pending\' and Status__c != \'Cancelled\' AND Status__c != \'Suspended\' AND Status__c != \'Expired\'';
        }
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, list<Account> AccList) {
        Set<Id> setOfAccountIds = new Set<Id>();
        for(Account eachAccount : AccList) {
            setOfAccountIds.add(eachAccount.Id);
        }
        Map<String, String> mapOfLatestOppty = AmountRollUpHandler.fetchLatestOppty(setOfAccountIds,false);

        List<OpportunityLineItem> listAllLineItem = [
            SELECT id,Discount_Reason__c,Amount_Despite_VIP__c, Amount__c, Opportunity.AccountId
            FROM OpportunityLineItem
            WHERE OpportunityId In: mapOfLatestOppty.values()
            AND Product_Category__c = 'Subscription'
            AND Complimentary__c = false
            AND Push_to_NetSuite__c = true
        ];
        Map<String, Decimal> mapOfCSS = new Map<String, Decimal>();
        for(OpportunityLineItem eachLineItem : listAllLineItem) {
            if(
                eachLineItem.Discount_Reason__c == 'VIP (Relationship)' ||
                eachLineItem.Discount_Reason__c == 'VIP (Spending)' ||
                eachLineItem.Discount_Reason__c == 'VIP (migration)'
            ) {
                mapOfCSS.put(eachLineItem.Opportunity.AccountId, eachLineItem.Amount_Despite_VIP__c);
            } else {
                mapOfCSS.put(eachLineItem.Opportunity.AccountId, eachLineItem.Amount__c);
            }
        }

        Map<String, Decimal> mapOfProRate = new Map<String, Decimal>();
        List<Opportunity> listOfOppData = [
            SELECT Id, Pro_rate__c, Opportunity_Type__c, AccountId FROM Opportunity WHERE Id IN: mapOfLatestOppty.values()
        ];
        for(Opportunity eachOpp: listOfOppData) {
            if(
                eachOpp.Opportunity_Type__c != null &&
                eachOpp.Opportunity_Type__c.equals('B2C - Upgrade') &&
                eachOpp.Pro_rate__c != null
            ) {
                mapOfProRate.put(eachOpp.AccountId, eachOpp.Pro_rate__c);
            } else {
                mapOfProRate.put(eachOpp.AccountId, 0);
            }
        }

        Map<String, Account> mapAccountToUpdate = new Map<String, Account>();
        for(Account eachAccount : AccList) {
            Account objAcc = new Account();
            objAcc.Id = eachAccount.Id;
            Boolean isUpdateRequired = false;
            if(
                mapOfCSS.containsKey(eachAccount.Id) &&
                eachAccount.Current_Subscription_Spending_Amount__c != mapOfCSS.get(eachAccount.Id)
            ) {
                objAcc.Current_Subscription_Spending_Amount__c = mapOfCSS.get(eachAccount.Id);
                isUpdateRequired = true;
            }

            if(
                mapOfProRate.containsKey(eachAccount.Id) &&
                eachAccount.Pro_Rate_Amount__c != mapOfProRate.get(eachAccount.Id)
            ) {
                objAcc.Pro_Rate_Amount__c  = mapOfProRate.get(eachAccount.Id);
                isUpdateRequired = true;
            }
            if(isUpdateRequired) {
                mapAccountToUpdate.put(objAcc.Id, objAcc);
            }
        }

        if(!mapAccountToUpdate.isEmpty()) {
            List<Error_Log__c> listOfErrors = new List<Error_Log__c>();
            Database.SaveResult[] saveResults = Database.update(mapAccountToUpdate.values(), false);
            for (Database.SaveResult eachResult : saveResults) {
                if (!eachResult.isSuccess()) {
                    String strErrorMsg = '';
                    for(Database.Error err : eachResult.getErrors()) {
                        strErrorMsg += err.getStatusCode() + ': ' + err.getMessage();
                    }
                    if(mapAccountToUpdate.containsKey(eachResult.getId())) {
                        Account errorAccount = mapAccountToUpdate.get(eachResult.getId());
                        Error_Log__c newError = AmountRollUpHandler.createErrorLog(eachResult.getId(), JSON.serialize(errorAccount), strErrorMsg);
                        listOfErrors.add(newError);
                    }
                }
            }
            if(!listOfErrors.isEmpty()) {
                insert listOfErrors;
            }
        }
    }

    global void finish(Database.BatchableContext BC) {

    }
}