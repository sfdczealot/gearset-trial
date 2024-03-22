/**
 * Created by jameshladek on 2/24/20.
 */

public with sharing class CS_BatchProcessingErrorsHelper {

    private static List<String> ALLOWABLEJOBTYPES = new List<String>{'BatchApex', 'ScheduledApex'};
    private static List<String> CLASSES = new List<String>(reportMapping.keySet());

    private static Map<String, Report_Validation_Classes__c> reportMapping {
        get {
            return Report_Validation_Classes__c.getAll();
        }
        set;
    }
    /**
     * This variable holds all the GroupMembers related to a group by groupId.
     * This is used to allow for recursive method call without additional SOQL calls.
     */
    private static Map<Id, List<GroupMember>> groupMemberMapByIds {
        get {
            if (groupMemberMapByIds == null) {
                groupMemberMapByIds = new Map<Id, List<GroupMember>>();
                List<Group> groups = [SELECT Id, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group];
                for (Group g : groups) {
                    groupMemberMapByIds.put(g.Id, g.GroupMembers);
                }
            }
            return groupMemberMapByIds;
        }
        set;
    }

    /**
     * This method queries for AsynApexJobs that ran yesterday that had a failure
     * and were a certain class and jobtype with a status of failed. If there are any
     * records that meet this criteria then an email will be sent identifying which
     * process failed.
     */
    public static void checkForErrors() {
        List<AsyncApexJob> erroredJobs = [
                SELECT Id, ApexClass.Name, MethodName, Status, ExtendedStatus, NumberOfErrors
                FROM AsyncApexJob
                WHERE Status = 'Failed'
                AND ApexClass.Name IN :CLASSES
                AND JobType IN :ALLOWABLEJOBTYPES
                AND CreatedDate = YESTERDAY
        ];

        if (erroredJobs.size() > 0) {
            processForEmail(erroredJobs);
        }
    }

    /**
     * This method accepts a list of failed jobs and creates and email that lists all the
     * jobs that failed. The method calls another method to retrieve all the userids of the
     * individuals to receive the email.
     *
     * @param erroredJobs   List of jobs that failed
     */
    @TestVisible
    private static void processForEmail(List<AsyncApexJob> erroredJobs) {
        List<Messaging.SingleEmailMessage> messages = new List<Messaging.SingleEmailMessage>();
        String plainText = '';
        String htmlText = '';
        for (AsyncApexJob job : erroredJobs) {
            String readableValue = String.valueOf(reportMapping.get(job.ApexClass.Name));
            plainText += 'An error occurred during the ' + readableValue + ' process.\n';
            htmlText += 'An error occurred during the ' + readableValue + ' process.</br>';
        }
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setToAddresses(getEmailAddresses());
        message.setSubject('Errors occurred during nightly processing.');
        message.setPlainTextBody(plainText);
        message.setHtmlBody(htmlText);
        messages.add(message);

        Messaging.sendEmail(messages);
    }

    /**
     * This method gathers all the user ids that are returned for
     * the email processing. The userids are stored in a group called
     * 'RecipientsOfProcessingErrorEmail'. The group is queried to get
     * the UserOrGroupId related to members. Because the group can contain
     * another group added functionality was implemented to manage such a
     * situation. If a group is related to the group then a method is called
     * to gather those ids.
     *
     * @return emailUserids     List of userids related to the groupl
     */
    private static List<Id> getEmailAddresses() {
        Set<Id> userIds = new Set<Id>();
        Group grp = [SELECT Id, (SELECT Id, UserOrGroupId FROM GroupMembers) FROM Group WHERE Name = 'RecipientsOfProcessingErrorEmail'];
        for (GroupMember gm : grp.GroupMembers) {
            if (String.valueOf(gm.UserOrGroupId).startsWith('005')) {
                userIds.add(gm.UserOrGroupId);
            } else {
                userIds.addAll(getGroupUsers(gm.UserOrGroupId));
            }
        }
        List<Id> emailUserIds = new List<Id>();
        emailUserIds.addAll(userIds);
        return emailUserIds;
    }

    /**
     * This method gathers all the users that is related to a group.
     * The method calls into a variable to get all the group members
     * related to a groupid. This variable is only populated on call and
     * the call is only made if there is a related group. If a group is
     * found in the calling group then the method is called recursively to
     * gather all the userids that are related to any sub group.
     *
     * @param groupId
     *
     * @return userids  List of userids related to sub groups.
     */
    private static List<Id> getGroupUsers(Id groupId) {
        List<Id> userIds = new List<Id>();
        for (GroupMember gm : groupMemberMapByIds.get(groupId)) {
            if (String.valueOf(gm.UserOrGroupId).startsWith('005')) {
                userIds.add(gm.UserOrGroupId);
            } else {
                userIds.addAll(getGroupUsers(gm.UserOrGroupId));
            }
        }
        return userIds;
    }


}