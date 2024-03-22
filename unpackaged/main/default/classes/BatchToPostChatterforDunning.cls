global class BatchToPostChatterforDunning implements Database.Batchable<sObject>,System.Schedulable {
    
    
    global Void execute(System.SchedulableContext context) {
        Database.executeBatch(new BatchToPostChatterforDunning(), 3);
    }
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        
        return Database.getQueryLocator('Select Id, OwnerID,AccountId, Suspended_chatter_Date__c,Primary_Sales_Order__c '+
                                        'from opportunity where Suspended_chatter_Date__c= today '+
                                        'and Primary_Sales_Order__r.Fulfilment_Allowed__c = false and '+
                                        'stagename=\'Closed Won\'');
        
    }   
    global void execute(Database.BatchableContext BC,list<Opportunity> scope) {
        
      List<String> soIds = new List<String>();
        List<Opportunity> updateOppList = new List<Opportunity>();
        Map<String,Opportunity> soIDVSOpp = new  Map<String,Opportunity>();
        List<String> accountIDList = new List<String>();
        List<String> SuspendedAccIdList = new List<String>();
        for(Opportunity opp : scope){
            accountIDList.add(opp.AccountId);
        }
        for(Billing_Entity__c  nsDetail : [Select id,Account__c from Billing_Entity__c  
                                           where Account__c in :accountIDList
                                           and Subsidiary_Code__c = 'iPP' 
                                           and Customer_Status__c = 'Suspended']){
                                               SuspendedAccIdList.add(nsDetail.Account__c);            
                                           }
        
        for(Opportunity opp : scope){
            if(SuspendedAccIdList.contains(opp.AccountId)){
                // accountIDList.add(opp.AccountId);
                soIds.add(opp.Primary_Sales_Order__c);
                soIDVSOpp.put(opp.Primary_Sales_Order__c,opp);
            }
        }
        List<csdf__Fulfilment_Item__c> fiList = [select id,csdf__Fulfilment__r.Sales_Order__c 
                                                 from csdf__Fulfilment_Item__c 
                                                 where csdf__Fulfilment__r.Sales_Order__c in: soIds and
                                                 (Status_Manual_Tracking__c ='Delivering' or
                                                  csdf__Status__c = 'Delivering')];
        
        for(csdf__Fulfilment_Item__c fi : fiList){
            if(soIDVSOpp.containsKey(fi.csdf__Fulfilment__r.Sales_Order__c)){
                soIDVSOpp.remove(fi.csdf__Fulfilment__r.Sales_Order__c);
            }
        }
        List<ConnectApi.BatchInput> batchInputs = new List<ConnectApi.BatchInput>();
        
        for(Opportunity opp : soIDVSOpp.values()){
            Opp.Suspended_chatter_Date__c = System.Today().addDays(14);
            updateOppList.add(opp);
            batchInputs.add( postChatter(opp));
        }
        if(updateOppList.size() > 0){
            update updateOppList;
        }
        if(!test.isRunningTest() && batchInputs.size() > 0){
            ConnectApi.ChatterFeeds.postFeedElementBatch(Network.getNetworkId(), batchInputs);
        }
    }
    global void finish(Database.BatchableContext BC) {
    }
    public static ConnectApi.BatchInput postChatter(Opportunity opp){
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegmentInput.text = 'Fulfilment cannot proceed for this Opportunity because Customer has overdue payments.'+
            ' Please liaise with Customer to pay.';
        messageBodyInput.messageSegments.add(textSegmentInput);
        mentionSegmentInput.id = Opp.OwnerId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = Opp.Id;
        ConnectApi.BatchInput batchInput = new ConnectApi.BatchInput(feedItemInput);
        return batchInput;
    }
}