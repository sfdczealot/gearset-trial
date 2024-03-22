global with sharing class MediaTargetingWidgetController {

    public String templateId {get;set;}

    global MediaTargetingWidgetController() {
        templateId = ApexPages.currentPage().getParameters().get('id');
    }

    @RemoteAction
    @AuraEnabled
    global static String performAction(String payload) {
        return MediaTargetingWidget.performAction(payload);
    }

    @ReadOnly
    @RemoteAction
    @AuraEnabled
    global static String performReadOnlyAction(String payload) {
        return MediaTargetingWidget.performAction(payload);
    }

    @ReadOnly
    @RemoteAction
    global static Map<String, Object> getInitialTemplateEditorData() {
        try {
            List<csmso__Product_Node__c> markets = [
                SELECT
                    Id,
                    Name,
                    csmso__Description__c,
                    Unique_Id__c,
                    (
                        SELECT Ad_Server__c,
                            Market__c,
                            Targeting_Template__c
                        FROM Market_Targeting_Templates__r
                        WHERE Type__c = 'Market Targeting'
                    )
                FROM csmso__Product_Node__c
            ];

            Set<String> targetingTemplateIds = new Set<String>();
            for(csmso__Product_Node__c market: markets) {
                if(market.Market_Targeting_Templates__r != null && market.Market_Targeting_Templates__r.size() > 0) {
                    for(Market_Targeting_Template__c mtt: market.Market_Targeting_Templates__r) {
                        targetingTemplateIds.add(mtt.Targeting_Template__c);
                    }
                }
            }

            return new  Map<String, Object>{
                'adServers' => [
                    SELECT Id, Name,csdf__Type__c, csdf__Network_Code__c
                    FROM csdf__Ad_Server__c
                ],
                'templateTypes' => [
                    SELECT  Type__c, Ad_Server__c, Profile_Restriction__c, Targeting_Sections__c, Market__c
                    FROM Targeting_Template_Type__mdt
                ],
                'markets' => markets,
                'presetsTargetingTemplates' => [
                    SELECT Id,
                        Ad_Server__c,
                        Market__c,
                        Targeting_Template__c
                    FROM Market_Targeting_Template__c
                    WHERE Type__c = 'Preset Targeting'
                ],
                'targetingTemplates' => [
                    SELECT Id,
                        (
                            SELECT Id,
                                csdf__Geo_Item__c
                            FROM csdf__Geo_Item_Targeting_Templates__r
                        )
                    FROM csdf__Targeting_Template__c
                    WHERE Id IN: targetingTemplateIds
                ],
                'profile' => [
                    SELECT Name
                    FROM profile
                    WHERE Id = :UserInfo.getProfileId()
                ][0].Name,
                'visibilityTags' => Targeting_Visibility_Tags__c.getInstance()
            };
        } catch(Exception e) {
            System.debug('##### Error while fetching initial Template editor data: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return new Map<String, Object>{
                'adServers' => new List<Object>(),
                'templateTypes' => new List<Object>(),
                'markets' => new List<Object>(),
                'marketTargetingTemplates' => new List<Object>(),
                'geoRoots' => new List<Object>(),
                'profile' => ''
            };
        }
    }

    @RemoteAction
    public static String handleMarketTemplateSave(
        String adServerId,
        String marketId,
        String newTemplateId,
        String oldTemplateId
    ) {
        try {
            List<Market_Targeting_Template__c> mtts = [
                SELECT Id, Targeting_Template__c
                FROM Market_Targeting_Template__c
                WHERE Ad_Server__c =: adServerId
                    AND Market__c =: marketId
                    AND Type__c =: 'Market Targeting'
            ];

            if(mtts != null && mtts.size() > 0) {
                System.debug('##### Found MTT record');
                if(mtts[0].Targeting_Template__c == null) {
                    System.debug('##### Targeting Template is not set. Setting and updating');
                    // template has been deleted in the past
                    mtts[0].Targeting_Template__c = newTemplateId;
                    update mtts[0];
                    return mtts[0].Id;
                } else {
                    System.debug('##### Targeting Template is set');
                    if(((String) mtts[0].Targeting_Template__c).substring(0,15).equals(newTemplateId.substring(0,15))) {
                        // existing template is updated
                        // no need to update the junction record
                        System.debug('##### Existing Template record has been updated. No changes needed');
                        return mtts[0].Id;
                    } else {
                        System.debug('##### New Template is created. Deleting previous Template...');
                        // new template has been created. Delete previous one since only one template per market is allowed
                        if(deleteTemplate(oldTemplateId)) {
                            System.debug('##### Delete successful. Inserting new Template');
                            // template and MTT record are deleted
                            // insert new one
                            Market_Targeting_Template__c mtt = new Market_Targeting_Template__c(
                                Ad_Server__c = adServerId,
                                Market__c = marketId,
                                Targeting_Template__c = newTemplateId,
                                Type__c = 'Market Targeting'
                            );
                            insert mtt;
                            System.debug('##### New Record successfully inserted.');
                            return mtt.Id;
                        } else {
                            System.debug('##### Error while deleting the old template...');
                            return null;
                        }
                    }
                }
            } else {
                System.debug('##### No MTT records found. Creating new Market_Targeting_Template__c record...');
                Market_Targeting_Template__c mtt = new Market_Targeting_Template__c(
                    Ad_Server__c = adServerId,
                    Market__c = marketId,
                    Targeting_Template__c = newTemplateId,
                    Type__c = 'Market Targeting'
                );
                insert mtt;
                return mtt.Id;
            }
        } catch(Exception e) {
            System.debug('##### Error while handling market template save: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    @RemoteAction
    public static String handlePresetTemplateSave(
        String adServerId,
        String marketId,
        String templateId
    ) {
        try {
            List<Market_Targeting_Template__c> mtts = [
                SELECT Id
                FROM Market_Targeting_Template__c
                WHERE Ad_Server__c =: adServerId
                    AND Market__c =: marketId
                    AND Targeting_Template__c =: templateId
                    AND Type__c = 'Preset Targeting'
            ];

            if(mtts != null && mtts.size() > 0) {
                // template has been updated
                System.debug('##### Found existing Market Targeting Template of Type "Preset Targeting"...');
                return mtts[0].Id;
            } else {
                System.debug('##### Market Targeting Template of Type "Preset Targeting" doesn\' exist. Creating new...');
                Market_Targeting_Template__c mtt = new Market_Targeting_Template__c(
                    Market__c = marketId,
                    Ad_Server__c = adServerId,
                    Targeting_Template__c = templateId,
                    Type__c = 'Preset Targeting'
                );
                insert mtt;
                return mtt.Id;
            }
        } catch (Exception e) {
            System.debug('##### Error while handling preset template save: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }
    
    webservice static Boolean deleteTemplate(String templateId) {
        System.debug('##### Trying to delete Targeting template with id: ' + templateId);

        Savepoint sp = Database.setSavepoint();
        try {
            // ad slots
            List<Ad_Slot_Targeting_Template__c> adSlotJunctions = [SELECT Id FROM Ad_Slot_Targeting_Template__c WHERE Targeting_Template__c =: templateId];
            if(adSlotJunctions != null && adSlotJunctions.size() > 0) { delete adSlotJunctions; }
            
            // geo items
            List<csdf__Geo_Item_Targeting_Template__c> geoItemJunctions = [SELECT Id FROM csdf__Geo_Item_Targeting_Template__c WHERE csdf__Targeting_Template__c =: templateId];
            if(geoItemJunctions != null && geoItemJunctions.size() > 0) { delete geoItemJunctions; }

            // browsers
            List<csdf__Browser_Targeting_Template__c> browserJunctions = [SELECT Id FROM csdf__Browser_Targeting_Template__c WHERE csdf__Targeting_Template__c =: templateId];
            if(browserJunctions != null && browserJunctions.size() > 0) { delete browserJunctions; }

            // os items
            List<csdf__Operating_System_Targeting_Template__c> osJunctions = [SELECT Id FROM csdf__Operating_System_Targeting_Template__c WHERE csdf__Targeting_Template__c =: templateId];
            if(osJunctions != null && osJunctions.size() > 0) { delete osJunctions; }

            // osv items
            List<csdf__Operating_System_Version_Target_Template__c> osvJunctions = [SELECT Id FROM csdf__Operating_System_Version_Target_Template__c WHERE csdf__Targeting_Template__c =: templateId];
            if(osvJunctions != null && osvJunctions.size() > 0) { delete osvJunctions; }

            // targetable items
            List<csdf__Targetable_Targeting_Template__c> targetableJunctions = [SELECT Id FROM csdf__Targetable_Targeting_Template__c WHERE csdf__Targeting_Template__c =: templateId];
            if(targetableJunctions != null && targetableJunctions.size() > 0) { delete targetableJunctions; }

            // market targeting templates
            List<Market_Targeting_Template__c> mttJunctions = [SELECT Id FROM Market_Targeting_Template__c WHERE Targeting_Template__c =: templateId];
            if(mttJunctions != null && mttJunctions.size() > 0) { delete mttJunctions; }

            // template parent
            delete new csdf__Targeting_Template__c(Id = templateId);

            return true;
        } catch(Exception e) {
            Database.rollback(sp);
            System.debug('##### Error while trying to delete Targeting Template: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return false;
        }
    }

    @ReadOnly
    @RemoteAction
    @AuraEnabled
    global static List<Market_Targeting_Template__c> getMarketTargetingTemplates() {
        return [
            SELECT Ad_Server__c,
                Market__c,
                Targeting_Template__c
            FROM Market_Targeting_Template__c
            WHERE Type__c = 'Preset Targeting'
        ];
    }
}