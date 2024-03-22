/**
 * Created by jameshladek on 4/8/20.
 */

global class CS_PostToChatterHandler extends CS_StepHandlerBase {
    private Map<String, List<Id>> userIdsByGroupMemberMap;

    global CS_PostToChatterHandler() {
        this.action = 'Post to Chatter';
    }

    global override CSPOFA__Orchestration_Step__c doWork(Object params) {
        Map<String, Object> paramsType = (Map<String, Object>) params;
        CSPOFA__Orchestration_Step__c step = (CSPOFA__Orchestration_Step__c) paramsType.get('step');
system.debug(context);
        String validationReason ;
        if(context!=null)
         validationReason = (String) context.getVariable(step.CSPOFA__Orchestration_Process__c, CS_StepHandlerBase.ValidationReasonVariable, Type.String.class);
        
        if(String.isBlank(validationReason) || validationReason == step.Name) {
            CSPOFA__Orchestration_Process__c process = queryProcess((String) step.Merge_Field__c, (String) step.Add_mentions__c, (String) step.CSPOFA__Orchestration_Process__c);
            createChatterPost(step, process);
        }

        return setStepProgress(step, 'Post to chatter completed.');
    }

    private CSPOFA__Orchestration_Process__c queryProcess(String mergeFields, String atMention, Id processId) {
        String query = 'SELECT Id';
        if (String.isNotBlank(mergeFields)) {
            query += ', ' + mergeFields;
        }
        String atMentionFields = getAtMentionFields(atMention);
        if(String.isNotBlank(atMentionFields)) {
            query += ', ' + atMentionFields;
        }

        query += ' FROM CSPOFA__Orchestration_Process__c WHERE Id = :processId';
        return Database.query(query);
    }

    private void createChatterPost(CSPOFA__Orchestration_Step__c step, CSPOFA__Orchestration_Process__c process) {
        String feedElementId;

        for (Id targetId : getTargetIds((String) step.Chatter_Target__c, process)) {
            feedElementId = targetId;
            ConnectApi.FeedType targetFeedType = ConnectApi.FeedType.Record;
            if (targetId != null && targetId.getSObjectType().getDescribe().getName().toLowerCase().startsWith('user')) {
                targetFeedType = ConnectApi.FeedType.UserProfile;
            }
            ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
            ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
            ConnectApi.TextSegmentInput textSegment;
            ConnectApi.MentionSegmentInput mentionSegment;

            messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();

            List<String> values = new List<String>();
            for (String s : getMergeFields((String) step.Merge_Field__c)) {
                String fieldValue = CS_utl_SObject.getFieldValue((SObject) process, s);
                values.add(fieldValue == 'null' ? '' : fieldValue);
            }
            String finalMessage;
            if (!values.isEmpty()) {
                finalMessage = String.format((String) step.Chatter_Post_Message__c, values) + ' ';
            }
            else {
                finalMessage = (String) step.Chatter_Post_Message__c + ' ';
            }

            textSegment = new ConnectApi.TextSegmentInput();
            textSegment.text = finalMessage;
            messageInput.messageSegments.add(textSegment);

            for (Id mentionId : getAtMentions((String) step.Add_mentions__c, process)) {
                mentionSegment = new ConnectApi.MentionSegmentInput();
                mentionSegment.id = mentionId;
                messageInput.messageSegments.add(mentionSegment);
            }
            input.body = messageInput;
            system.debug(input);
            system.debug(targetFeedType);
            system.debug(targetId);
            ConnectApi.ChatterFeeds.postFeedItem(null, targetFeedType, targetId, input, null);
        }
    }

    private List<String> getMergeFields(String mergeField) {
        if (String.isNotBlank(mergeField)) {
            return mergeField.split(',');
        }
        return new List<String>();
    }

    private List<Id> getTargetIds(String targets, CSPOFA__Orchestration_Process__c process) {
        List<Id> targetIds = new List<Id>();
        system.debug(targets);
        system.debug(process);
        if (String.isNotBlank(targets)) {
            List<String> fieldNames = targets.split(',');
            for (String field : fieldNames) {
                system.debug('in for');
                targetIds.add(CS_utl_SObject.getFieldValue(process, field));
               
            }
        } else {
            
            targetIds.add(CS_utl_SObject.getFieldValue(process, 'Sales_Order__c'));
        }
         system.debug(targetIds);
        //system.debug(targetIds);
        return targetIds;
    }

    private String getAtMentionFields(String addMention) {
        List<String> fieldNames = new List<String>();
        if (String.isNotBlank(addMention)) {
            List<String> parts = addMention.split(',');
            for (String part : parts) {
                if (!part.containsIgnoreCase('group')) {
                    fieldNames.add(part);
                }
            }
        }

        return CS_utl_Array.join(fieldNames, ',');
    }

    private Set<Id> getAtMentions(String addMention, CSPOFA__Orchestration_Process__c process) {
        Set<Id> mentionIds = new Set<Id>();
        if (String.isNotBlank(addMention)) {
            List<String> parts = addMention.split(',');
            for (String part : parts) {
                if (part.containsIgnoreCase('group')) {
                    mentionIds.addAll(groupMention(part));
                } else {
                    mentionIds.add(CS_utl_SObject.getFieldValue(process, part));
                }
            }
        }
        else {
            mentionIds.add((Id) process.Sales_Order__c);
        }
        return mentionIds;
    }

    private List<Id> groupMention(String mergefield) {
        List<Id> ids = new List<Id>();
        String modifiedValue = mergefield.removeStartIgnoreCase('(Group)').trim();
        for (Id userId : getUserIdMap().get(modifiedValue)) {
            ids.add(userId);
        }
        return ids;
    }

    private Map<String, List<Id>> getUserIdMap() {
        if (userIdsByGroupMemberMap == null) {
            userIdsByGroupMemberMap = new Map<String, List<Id>>();
            for (GroupMember gm : [SELECT Id, Group.Name, UserOrGroupId FROM GroupMember]) {
                if (String.valueOf(gm.UserOrGroupId).startsWith('005')) {
                    List<Id> ids = userIdsByGroupMemberMap.get(gm.Group.Name);
                    if (ids == null) {
                        ids = new List<Id>();
                    }
                    ids.add(gm.UserOrGroupId);
                    userIdsByGroupMemberMap.put(gm.Group.Name, ids);
                }
            }
        }
        return userIdsByGroupMemberMap;
    }
}