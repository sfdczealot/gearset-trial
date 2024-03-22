// Daily Batch to fetch consumed AC by an agent and calculate quantity for CarryOver AC qli for PGAUTO-6542
global class DailyBatchToCalculateCarryOverAC implements DataBase.Batchable<Sobject>, Schedulable, DataBase.AllowsCallouts{
    
    global void execute(SchedulableContext ctx) {
        Database.executeBatch(this, 1);
    }
    public final static string skuCodeOfACProd = System.Label.PRODUCT_SKUCODE_AD_CREDIT;
    
    global DataBase.QueryLocator start(DataBase.BatchableContext Bc) {
        return Database.getQueryLocator('SELECT id,Opportunity.StageName,AccountId,Account.AgentNet_ID__c, '+
                                        '(SELECT Id,CurrPackageAdCredit__c FROM QuoteLineItems '+
                                        'WHERE Product2.SKU_Code__c =: skuCodeOfACProd AND IsDiscretionaryAC__c = true '+
                                        'ORDER BY End_Date__c DESC LIMIT 1), Account.Country__c FROM Quote '+
                                        'WHERE (Opportunity.RecordType.Name = \'B2C\' OR Opportunity.RecordType.Name = \'B2C Self-Serve\') AND Opportunity.Opportunity_Type__c!= null '+
                                        'AND (Opportunity.StageName = \'Proposal\' OR Opportunity.StageName = \'Pending Online Payment\' '+
                                        'OR Opportunity.StageName = \'Pending OMC Approval\') AND Opportunity.IsClosed = false '+
                                        'AND Opportunity.Opportunity_Type__c = \'B2C - Upgrade\' '+
                                        'AND AccountId!= null AND Account.Status__c = \'Active\' '+
                                        'AND Account.Country__c = \'Singapore\'');
    }
    
    global void execute(DataBase.BatchableContext Bc,List<Quote> quoteList) {
        try {
            List<QuoteLineItem> toUpdateQliList = new List<QuoteLineItem>();
            List<QuoteLineItem> toDeleteQliList = new List<QuoteLineItem>();
            Map<String,String> countryVsAccessToken = new Map<String,String>();
            Map<String,String> mapOfOppIdVsInternalId = new Map<String,String>();
            Set<Id> accIdSet = new Set<Id>();
            String internalID;
            Map<String,String> mapOfAccIdVsLatestOppId = new Map<String,String>();
            for(Billing_API__mdt metadata : [SELECT Country__c,Access_Token__c 
                                             FROM Billing_API__mdt
                                             WHERE Country__c = 'Singapore']
               ){
                   countryVsAccessToken.put(metadata.Country__c,metadata.Access_Token__c);
               }
            
            for(Quote quo: quoteList) {
                if(quo.AccountId!=null) {
                    accIdSet.add(quo.AccountId);
                    system.debug('accIdSet@@'+accIdSet);
                }
            }
            if(!accIdSet.isEmpty()) {
                system.debug('accIdSet==>'+accIdSet);
                mapOfAccIdVsLatestOppId = AmountRollUpHandler.fetchLatestOppty(accIdSet,false);
                system.debug('mapOfAccIdVsLatestOppId@@'+mapOfAccIdVsLatestOppId);
            }
            
            if(!mapOfAccIdVsLatestOppId.isEmpty()) {
                for(QuoteLineItem qli : [SELECT Id,Quote.OpportunityId,
                                         SNo__c,Quote.Opp_Quote_Ref_num__c
                                         FROM QuoteLineItem 
                                         Where Quote.OpportunityId In:mapOfAccIdVsLatestOppId.values()
                                         AND Product2.SKU_Code__c =:skuCodeOfACProd
                                         AND Quote.isSyncing =true 
                                         AND SNo__c != null]
                   ) {
                       String comma,Sno;
                       SNo = string.valueof(qli.SNo__c); //1.08
                       if(Sno.length()>3) {
                           comma = Sno.substring(Sno.length()-2, Sno.length());
                       }
                       if( comma != '00') {
                           Sno = string.valueof(qli.SNo__c);
                           if(comma.substring(0,1) == '0') {
                               internalID = qli.Quote.Opp_Quote_Ref_num__c + '_' + Sno.substring(0,1) + '_' + comma.substring(1,comma.length()) ; 
                               if(!mapOfOppIdVsInternalId.containsKey(qli.Quote.OpportunityId)) {
                                   mapOfOppIdVsInternalId.put(qli.Quote.OpportunityId,internalID);
                               }
                           }else {
                               internalID = qli.Quote.Opp_Quote_Ref_num__c + '_' + String.valueOf(qli.SNo__c).replace('.', '_');
                               if(!mapOfOppIdVsInternalId.containsKey(qli.Quote.OpportunityId)) {
                                   mapOfOppIdVsInternalId.put(qli.Quote.OpportunityId,internalID);
                               }
                           }
                       }
                   }
            }
            String adCreditProductCode = System.Label.AD_CREDIT_PRODUCTCODE;
            for(Quote quo: quoteList) {
                if(quo.quoteLineItems.size()>0) {
                    Decimal carryOverAC = 0;
                    String consumedAC = '';
                    Account acc = new Account();
                    acc.Id = quo.AccountId;
                    acc.AgentNet_ID__c = quo.Account.AgentNet_ID__c;
                    acc.Country__c = quo.Account.Country__c;
                    
                    if(!countryVsAccessToken.isEmpty() && 
                       !mapOfAccIdVsLatestOppId.isEmpty() && 
                       !mapOfOppIdVsInternalId.isEmpty() && 
                       countryVsAccessToken.containsKey(acc.Country__c) &&
                       mapOfAccIdVsLatestOppId.containsKey(acc.Id)) {
                           LightningResponse result = OpportunityProductRegistrationStinger_cc.getConsumedAdCredit(JSON.serialize(acc),countryVsAccessToken.get(acc.Country__c),
                                                                                                                   mapOfAccIdVsLatestOppId.get(acc.Id),
                                                                                                                   mapOfOppIdVsInternalId,adCreditProductCode);
                           if(result.isSuccess == true) {
                               consumedAC = result.response;
                               if(quo.quoteLineItems[0].CurrPackageAdCredit__c == null) {
                                   quo.quoteLineItems[0].CurrPackageAdCredit__c = 0;
                               }
                               carryOverAC = Math.round(quo.quoteLineItems[0].CurrPackageAdCredit__c - Decimal.valueOf(consumedAC));
                               QuoteLineItem qli= new QuoteLineItem();
                               qli.Id = quo.quoteLineItems[0].Id;
                               qli.Quantity = carryOverAC;
                               qli.Consumed_Ad_Credit__c = Math.round(Decimal.valueOf(consumedAC));
                               if(qli.Quantity!= 0) {
                                   toUpdateQliList.add(qli);
                               } else {
                                   toDeleteQliList.add(qli);
                               }
                           }
                       }
                }
            }
            
            if(!toUpdateQliList.isEmpty()) {
                update toUpdateQliList;
            }
            if(!toDeleteQliList.isEmpty()) {
                delete toDeleteQliList;
            }
        } catch (Exception ex) {
            Error_Log__c newError = AmountRollUpHandler.createErrorLog(quoteList[0].Id, JSON.serialize(quoteList[0]) , ex.getMessage());
            insert newError;
        }
    }
    
    global void finish(DataBase.BatchableContext Bc) {
        
    }
}