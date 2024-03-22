public class CustomRetriggerSMSNotification_cc {
    
    @auraEnabled
    public static boolean sendSMSToAgent(String recordId,Boolean checkStageName){
        Opportunity opp = [Select id,stageName,Account.Status__c ,Opportunity_Type__c,ownerId 
                           from opportunity where id =: recordId];
        if(opp.Opportunity_Type__c  != 'B2C - Renewal' || opp.StageName == 'Closed Won' ||
           opp.StageName == 'Closed Lost' || (opp.Account.Status__c != 'Expired' && opp.Account.Status__c != 'Suspended')  ){
               throw new AuraHandledException('You are not allowed to send non-login link for this agent.');
           }
        //send SMS
        if(checkStageName == true){
            if(opp.StageName == 'Pending Online Payment' || opp.StageName == 'Pending OMC approval'){
                
                
                
                return false;
            }
        }
        Send_non_login_flow_SMS_notification__e  send = new Send_non_login_flow_SMS_notification__e (Opportunity_ID__c =recordid);
        EventBus.publish(send);
        
        
        //post Chatter
        ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegmentInput.text = 'Hey';
        messageBodyInput.messageSegments.add(textSegmentInput);
        mentionSegmentInput.id = Opp.OwnerId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = '\n Non-login flow SMS notification was sent to the Agent at specified mobile number.';
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = Opp.Id;
        if(!test.isRunningTest())
            ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);
            
        
       return true;
    }
}