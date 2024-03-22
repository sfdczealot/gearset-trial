public class OppChatterSuspendedStatus {
    @invocableMethod
    public static void sendChatter(List<String> oppID){
        opportunity opp = [select id,ownerid from opportunity where id =: oppID[0]];
        FeedItem post = new FeedItem();
post.ParentId = opp.id; 
post.createdById = [select id from user where name ='system message'].id;
        post.Body = 'hello there {@'+opp.OwnerId+'}';
insert post;
       // MentionsUtility.mentionedUser(trigger.new[0]);

        //post Chatter
      /*  ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
        ConnectApi.MentionSegmentInput mentionSegmentInput = new ConnectApi.MentionSegmentInput();
        ConnectApi.MessageBodyInput messageBodyInput = new ConnectApi.MessageBodyInput();
        ConnectApi.TextSegmentInput textSegmentInput = new ConnectApi.TextSegmentInput();
        messageBodyInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
        textSegmentInput.text = 'Hey';
        messageBodyInput.messageSegments.add(textSegmentInput);
        mentionSegmentInput.id = Opp.OwnerId;
        messageBodyInput.messageSegments.add(mentionSegmentInput);
        textSegmentInput = new ConnectApi.TextSegmentInput();
        textSegmentInput.text = 'test Customer has overdue payments. Please liaise with Customer to pay, so that fulfilment can proceed for this Opportunity.';
        messageBodyInput.messageSegments.add(textSegmentInput);
        feedItemInput.body = messageBodyInput;
        feedItemInput.feedElementType = ConnectApi.FeedElementType.FeedItem;
        feedItemInput.subjectId = Opp.Id;
        if(!test.isRunningTest())
            ConnectApi.ChatterFeeds.postFeedElement(Network.getNetworkId(), feedItemInput);*/
        
    }
}