/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Utility class to manipulate users
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_utl_User
{
	public static Boolean isDeactivatedForDataMigration = false;
	public static Boolean isTriggerDeactivatedForOffers = false;

    public static String userProfile {
        get {
            if(userProfile == null) {
                userProfile = [SELECT Id, Name FROM Profile WHERE Id = :UserInfo.getProfileId()].Name;
            }

            return userProfile;
        }
        set;
    }

    /*
     * Gets or Sets the master switch for trigger deactivations for the current transaction.
     */
    public static boolean isTriggerDeactivationEnabledForAllTriggers { 
        get {
            if(isTriggerDeactivationEnabledForAllTriggers == null) {
                isTriggerDeactivationEnabledForAllTriggers = false;
            }
            return isTriggerDeactivationEnabledForAllTriggers;
        }
        set;
    }

    /**
     * Checks if the trigger should run for the user
     * @return Boolean
     */
    public static Boolean isTriggerActiveForMe() {
        No_Triggers__c noTriggers = No_Triggers__c.getInstance(UserInfo.getUserId());

        return !isTriggerDeactivationEnabledForAllTriggers && (noTriggers == null || !noTriggers.Flag__c);
    }

    /**
     * Checks if the process is active for the current user
     * @param  process CS_ProcessDefinition
     * @return         Boolean
     */
    public static Boolean isProcessActiveForMe(CS_ProcessDefinition process) {
        Process_Deactivation__c processDeactivation = Process_Deactivation__c.getInstance();

        if(processDeactivation == null || !processDeactivation.Active__c) {
            return true;
        }

        return !(processDeactivation.Active__c && 
                 (processDeactivation.Processes__c.contains(process.name()) ||
                  processDeactivation.Processes__c.equals(CS_ProcessDefinition.ALL.name())));
    }

    /**
     * Disables triggers for the given user
     * @param userId Id
     */
    public static void disableAllTriggers(Id userId) {
        No_Triggers__c noTriggers = No_Triggers__c.getInstance(userId);
        PGTestDataFactory_v2.CreateTriggerExecuteCS('Trigger_OpportunitySplit',true);

        if(noTriggers == null) {
            noTriggers = new No_Triggers__c();
            noTriggers.SetupOwnerId = userId;
            noTriggers.Flag__c = true;
        }
        else {
            noTriggers.Flag__c = true;
        }

        upsert noTriggers;
    }

    /**
     * Enables triggers for the given user
     * @param userId Id
     */
    public static void enableAllTriggers(Id userId) {
        No_Triggers__c noTriggers = No_Triggers__c.getInstance(userId);

        if(noTriggers != null) {
            noTriggers.Flag__c = false;
            upsert noTriggers;
        }     
    }
}