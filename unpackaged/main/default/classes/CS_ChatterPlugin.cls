/**
 * Created by jameshladek on 3/27/20.
 */

global with sharing class CS_ChatterPlugin implements CSPOFA.ChatterApiProvider_V1, CSPOFA.PluginFactory {

    /**
       * @description Post feed item to chatter feed.
       * ConnectApi.RateLimitException is not handled, the client code MUST wrap the call in a try-catch block and handle this exception!
       *
       * @param feedItemInput: a properly prepared ConnectAPI.FeedItemInput class instance
       * @param subjectID: string representation of the ID of target object to whose stream the post will be made.
       *
       *
       */
    public void post(String subjectId, ConnectApi.FeedItemInput feedItemInput) {
        Id subject = normalizeId(subjectId);
        ConnectApi.FeedType targetFeedType = ConnectApi.FeedType.Record;
        if (subject != null && subject.getSObjectType().getDescribe().getName().toLowerCase().startsWith('user')) {
            targetFeedType = ConnectApi.FeedType.UserProfile;
        }
        //can throw RateLimitException
        ConnectApi.ChatterFeeds.postFeedItem(null, targetFeedType, subjectID, feedItemInput, null);
    }
    private Id normalizeId(String idText) {
        try {
            return Id.valueOf(idText);
        } catch (Exception e) {
            return null;
        }
    }

    global Object create() {
        System.debug('Create');
        return new CS_ChatterPlugin();
    }
}

/**   global void post(String subject, ConnectApi.FeedItemInput feedItem) {
       ConnectApi.FeedType feedType = feedType(subject);
       Id subjectId = normalizeId(subject);
       System.debug(subjectId + 'subjectId');
       System.debug(subject + 'subject');
       ConnectApi.ChatterFeeds.postFeedITem(null, feedType, subject, feedItem, null);
   }

   private ConnectApi.FeedType feedType(String subject){
       if (isUserFeed(subject)){
           return ConnectApi.FeedType.UserProfile;
       }
       else {
           return ConnectApi.FeedType.Record;
       }
   }

   private Boolean isUserFeed(String subject){
       Id subjectId = normalizeId(subject);
       if (subjectId == null){
           return false;
       }

       String subjectName = subjectId.getSObjectType().getDescribe().getName();
       return subjectName.toLowerCase().startsWith('user');
   }

   private Id normalizeId(String idText){
       try{
           return Id.valueOf(idText);
       }
       catch (Exception e){
           return null;
       }
   }
*/