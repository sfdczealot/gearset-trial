global with sharing class CS_GetPlaylistKeyvalues implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    global String performAction(String params) {
        PlaylistAttributes playlistAttributes = (PlaylistAttributes) JSON.deserialize(params, PlaylistAttributes.class);
        
        List<String> dfpPlaylistFolder = CS_Custom_Settings__c.getInstance().DFP_Playlist_Folder__c.split(',');
        
        List<csdf__Custom_Targeting_Value__c> customTargeting = [SELECT Id, csdf__Display_Name__c, csdf__Ad_Server_Id__c, Name, csdf__Custom_Targeting_Key__c,
                                                                        csdf__Custom_Targeting_Key__r.csdf__Display_Name__c, csdf__Custom_Targeting_Key__r.Name,
                                                                        csdf__Custom_Targeting_Key__r.csdf__Ad_Server_Id__c
                                                                 FROM csdf__Custom_Targeting_Value__c
                                                                 WHERE csdf__Custom_Targeting_Key__r.Name = :dfpPlaylistFolder AND
                                                                        (Name = :playlistAttributes.playlistURI OR csdf__Display_Name__c = :playlistAttributes.playlistURI) AND
                                                                        csdf__Custom_Targeting_Key__r.csdf__Ad_Server__c = :playlistAttributes.adServerId];
                                                                        
        return JSON.serialize(customTargeting);
    }
    
    public class PlaylistAttributes {
        public String playlistURI {get; set;}
        public String adServerId {get; set;}
    }
}