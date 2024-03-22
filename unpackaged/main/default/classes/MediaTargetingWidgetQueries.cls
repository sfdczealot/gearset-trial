global with sharing class MediaTargetingWidgetQueries {

    public static final Set<String> DEVICE_MANUFACTURER_TYPES = new Set<string>{'Mobile Device','Device Manufacturer'};
    public static final Set<String> ALL_GEO_CATS = new Set<String>{'MUNICIPALITY', 'AUTONOMOUS_COMMUNITY', 'CITY', 'COUNTRY', 'COUNTY', 'DMA_REGION', 'STATE', 'AIRPORT', 'BOROUGH', 'NEIGHBORHOOD','PROVINCE', 'CANTON', 'DEPARTMENT', 'GOVERNORATE', 'PREFECTURE', 'REGION', 'TERRITORY', 'TV_REGION', 'UNION_TERRITORY'};

    // both Ad Units and Placements use csdf__Ad_Slot__c object
    global static List<csdf__Ad_Slot__c> getAdSlots(String adServer, String parentId, Set<String> preloadSet, Boolean getAll) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Ad_Slot__c')
                + ', (SELECT Id, csdf__Ad_Slot_Child__c FROM csdf__Ad_Slot_Parent_Assignments__r)'
                + ', (SELECT Id, csdf__Ad_Slot_Parent__c, csdf__Ad_Slot_Parent__r.csdf__Name__c, csdf__Ad_Slot_Parent__r.csdf__Type__c FROM csdf__Ad_Slot_Child_Assignments__r)'
                + ' FROM csdf__Ad_Slot__c';

        if(preloadSet == null) {
            query += ' WHERE csdf__Ad_Server__c = :adServer';
            query += ' AND csdf__Active__c = true';
            if(getAll == false) {
                if(parentId != null) {
                    // get child records
                    query += ' AND Id IN (SELECT csdf__Ad_Slot_Child__c FROM csdf__Ad_Slot_Assignment__c WHERE csdf__Ad_Slot_Parent__c = :parentId)';
                } else {
                    // get parent records (records that are not child record for any ad slot)
                    query += ' AND Id NOT IN (SELECT csdf__Ad_Slot_Child__c FROM csdf__Ad_Slot_Assignment__c)';
                }
            }
        } else {
            query += ' WHERE Id IN :preloadSet';
        }
        System.debug('##### Ad Slots query: ' + query);

        try {
            List<csdf__Ad_Slot__c> adSlots = Database.query(query);
            System.debug('##### Found ' + adSlots.size() + ' items.');
            return adSlots;
        } catch(Exception e) {
            System.debug('##### Error while fetching ad slots: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Ad_Slot__c> getAdSlotsWithParents(String adServer, String parentId, Set<String> preloadSet) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Ad_Slot__c')
            + ', (SELECT Id, csdf__Ad_Slot_Child__c FROM csdf__Ad_Slot_Parent_Assignments__r)'
            + ', (SELECT Id, csdf__Ad_Slot_Parent__c, csdf__Ad_Slot_Parent__r.csdf__Name__c, csdf__Ad_Slot_Parent__r.csdf__Type__c FROM csdf__Ad_Slot_Child_Assignments__r)'
            + ' FROM csdf__Ad_Slot__c';
        
        if(preloadSet == null) {
            query += ' WHERE csdf__Ad_Server__c = :adServer';
            query += ' AND csdf__Active__c = true';
            if(parentId != null) {
                // get child records
                query += ' AND Id IN (SELECT csdf__Ad_Slot_Child__c FROM csdf__Ad_Slot_Assignment__c WHERE csdf__Ad_Slot_Parent__c = :parentId)';
            } else {
                // get parent records (records that are not child record for any ad slot)
                query += ' AND Id NOT IN (SELECT csdf__Ad_Slot_Child__c FROM csdf__Ad_Slot_Assignment__c)';
            }
        } else {
            query += ' WHERE Id IN :preloadSet';
        }
        System.debug('##### Ad Slots query: ' + query);

        try {
            List<csdf__Ad_Slot__c> adSlots = Database.query(query);
            System.debug('##### Found ' + adSlots.size() + ' items.');
            return adSlots;
        } catch(Exception e) {
            System.debug('##### Error while fetching ad slots: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Browser__c> getBrowsers(String adServer, Set<String> preloadSet) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Browser__c')
                + ' FROM csdf__Browser__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet';
        } else {
            query += ' WHERE csdf__Ad_Server__c = :adServer and csdf__Active__c = true';
        }
        System.debug('##### Browsers query: ' + query);

        try {
            List<csdf__Browser__c> browsers = Database.query(query);
            System.debug('##### Found ' + browsers.size() + ' items.');
            return browsers;
        } catch(Exception e) {
            System.debug('##### Error while fetching browsers: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Targetable__c> getDeviceCategories(String adServer, String parentId, Set<String> preloadSet, Boolean getAll) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Targetable__c') + ', (SELECT Id from Targetables__r)'
                + ' FROM csdf__Targetable__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet';
        } else {
            query += ' WHERE csdf__Ad_Server__c =: adServer AND csdf__Type__c = \'Device Category\' AND csdf__Active__c = true';
            if(getAll == false) {
                query += ' AND Targetable_Parent__c= :parentId';
            }
        }
        System.debug('##### Device Categories query: ' + query);

        try {
            List<csdf__Targetable__c> deviceCategories = Database.query(query);
            System.debug('##### Found ' + deviceCategories.size() + ' items.');
            return deviceCategories;
        } catch(Exception e) {
            System.debug('##### Error while fetching device categories: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Targetable__c> getDeviceManufacturers(String adServer, String parentId, Set<String> preloadSet, Boolean getAll) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Targetable__c') + ', (SELECT Id from Targetables__r)'
                + ' FROM csdf__Targetable__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet';
        } else {
            query += ' WHERE csdf__Ad_Server__c =: adServer AND csdf__Type__c IN :DEVICE_MANUFACTURER_TYPES AND csdf__Active__c = true';
            if(getAll == false) {
                query += ' AND Targetable_Parent__c= :parentId';
            }
        }

        System.debug('##### Device Manufacturer query: ' + query);

        try {
            List<csdf__Targetable__c> deviceManufacturer = Database.query(query);
            System.debug('##### Found ' + deviceManufacturer.size() + ' items.');
            return deviceManufacturer;
        } catch(Exception e) {
            System.debug('##### Error while fetching device manufacturer: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Targetable__c> getBandwidthGroup(String adServer, String parentId, Set<String> preloadSet, Boolean getAll) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Targetable__c') + ', (SELECT Id from Targetables__r)'
                + ' FROM csdf__Targetable__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet';
        } else {
            query += ' WHERE csdf__Ad_Server__c =: adServer AND csdf__Type__c = \'Bandwidth Group\' AND csdf__Active__c = true AND (NOT csdf__Targetable_Name__c LIKE \'%(app only)%\')';
            if(getAll == false) {
                query += ' AND Targetable_Parent__c= :parentId';
            }
        }

        System.debug('##### Bandwidth Group query: ' + query);

        try {
            List<csdf__Targetable__c> bandwidthGroup = Database.query(query);
            System.debug('##### Found ' + bandwidthGroup.size() + ' items.');
            return bandwidthGroup;
        } catch(Exception e) {
            System.debug('##### Error while fetching bandwidth group: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Targetable__c> getDeviceCapability(String adServer, String parentId, Set<String> preloadSet, Boolean getAll) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Targetable__c') + ', (SELECT Id from Targetables__r)'
                + ' FROM csdf__Targetable__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet';
        } else {
            query += ' WHERE csdf__Ad_Server__c =: adServer AND csdf__Type__c = \'Device Capability\' AND csdf__Active__c = true';
            if(getAll == false) {
                query += ' AND Targetable_Parent__c= :parentId';
            }
        }

        System.debug('##### Device capability query: ' + query);

        try {
            List<csdf__Targetable__c> deviceCapability = Database.query(query);
            System.debug('##### Found ' + deviceCapability.size() + ' items.');
            return deviceCapability;
        } catch(Exception e) {
            System.debug('##### Error while fetching device capabilities: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Geo_Item__c> getGeography(String adServer, String parentId, Set<String> categories, Set<String> preloadSet) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Geo_Item__c')
                + ', (SELECT Id, csdf__Geo_Item_Child__c FROM csdf__Geo_Item_Parent_Assignments__r WHERE csdf__Geo_Item_Child__r.csdf__Category__c IN :ALL_GEO_CATS)'
                + ', (SELECT Id, Geo_Parent_Name__c, csdf__Geo_Item_Parent__c FROM csdf__Geo_Item_Child_Assignments__r)'
                + ' FROM csdf__Geo_Item__c';
        if(preloadSet == null) {
            query += ' WHERE csdf__Category__c IN :categories AND csdf__Ad_Server__c = :adServer';
            query += ' AND csdf__Active__c = true';
            if(parentId != null) {
                // get child records
                query += ' AND Id IN (SELECT csdf__Geo_Item_Child__c FROM csdf__Geo_Item_Assignment__c WHERE csdf__Geo_Item_Parent__c = :parentId)';
            }
        } else {
            query += ' WHERE Id IN :preloadSet';
        }
        System.debug('##### Geography query: ' + query);

        try {
            List<csdf__Geo_Item__c> geoItems = Database.query(query);
            System.debug('##### Found ' + geoItems.size() + ' items.');
            return geoItems;
        } catch(Exception e) {
            System.debug('##### Error while fetching geo items: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    //TODO: delete later
    global static List<csdf__Geo_Item__c> getGeographySubItems(String adServer, Set<String> preloadSet) {
        return null;
    }


    global static List<csdf__Geo_Item__c> searchGeography(String adServer, String query) {
        query = '%' + query + '%';
        String searchQuery = 'SELECT ' + getFieldListAsCSV('csdf__Geo_Item__c')
                + ', (SELECT Id, csdf__Geo_Item_Child__c FROM csdf__Geo_Item_Parent_Assignments__r WHERE csdf__Geo_Item_Child__r.csdf__Category__c IN :ALL_GEO_CATS)'
                + ', (SELECT Id, Geo_Parent_Name__c, csdf__Geo_Item_Parent__c FROM csdf__Geo_Item_Child_Assignments__r)'
                + ' FROM csdf__Geo_Item__c'
                + ' WHERE Name LIKE :query'
                + ' AND csdf__Ad_Server__c = :adServer'
                + ' AND csdf__Active__c = true';

        System.debug('##### Geography search query: ' + searchQuery);

        try {
            List<csdf__Geo_Item__c> geoItems = Database.query(searchQuery);
            System.debug('##### Found ' + geoItems.size() + ' items.');
            return geoItems;
        } catch(Exception e) {
            System.debug('##### Error while searching geo items: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Targetable__c> getMobileCarriers(String adServer, String parentId, Set<String> preloadSet, Boolean getAll) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Targetable__c') + ', (SELECT Id from Targetables__r)'
                + ' FROM csdf__Targetable__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet';
        } else {
            query += ' WHERE csdf__Ad_Server__c =: adServer AND csdf__Type__c= \'Mobile Carrier\' AND csdf__Active__c = true';
            if(getAll == false) {
                query += ' AND Targetable_Parent__c= :parentId';
            }
        }
        System.debug('##### Mobile Carriers query: ' + query);

        try {
            List<csdf__Targetable__c> mobileCarriers = Database.query(query);
            System.debug('##### Found ' + mobileCarriers.size() + ' items.');
            return mobileCarriers;
        } catch(Exception e) {
            System.debug('##### Error while fetching mobile carriers: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Operating_System__c> getOperatingSystems(String adServer, Set<String> preloadSet) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Operating_System__c') + ', (select Id from csdf__Operating_System_Versions__r)'
                + ' FROM csdf__Operating_System__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet';
        } else {
            query += ' WHERE csdf__Ad_Server__c = :adServer and csdf__Active__c = true';
        }
        System.debug('##### Operating systems query: ' + query);

        try {
            List<csdf__Operating_System__c> operatingSystems = Database.query(query);
            System.debug('##### Found ' + operatingSystems.size() + ' items.');
            return operatingSystems;
        } catch(Exception e) {
            System.debug('##### Error while fetching operating systems: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Operating_System_Version__c> getOperatingSystemVersions(String adServer, String parentId, Set<String> preloadSet, Boolean getAll) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Operating_System_Version__c') + ', csdf__Operating_System__r.Name'
                + ' FROM csdf__Operating_System_Version__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet';
        } else {
            query += ' WHERE csdf__Operating_System__r.csdf__Ad_Server__c = :adServer AND csdf__Active__c = true';
            if(getAll == false) {
                query += ' AND csdf__Operating_System__c= :parentId';
            }
        }
        System.debug('##### Operating system versions query: ' + query);

        try {
            List<csdf__Operating_System_Version__c> operatingSystemVersions = Database.query(query);
            System.debug('##### Found ' + operatingSystemVersions.size() + ' items.');
            return operatingSystemVersions;
        } catch(Exception e) {
            System.debug('##### Error while fetching operating system versions: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Custom_Targeting_Key__c> getKvaKeys(String adServer, Set<String> preloadSet) {
        System.debug('### adServer => ' + adServer);
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Custom_Targeting_Key__c')
                + ' FROM csdf__Custom_Targeting_Key__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet';
        } else {
            query += ' WHERE csdf__Ad_Server__c = :adServer';
            // ' AND csdf__Active__c = true';
        }
        System.debug('##### Keys query: ' + query);

        try {
            List<csdf__Custom_Targeting_Key__c> kvaKeys = Database.query(query);
            System.debug('##### Found ' + kvaKeys.size() + ' items.');
            return kvaKeys;
        } catch(Exception e) {
            System.debug('##### Error while fetching KeyValue and Audience keys: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Custom_Targeting_Value__c> getKvaValues(String parentId, Set<String> preloadSet) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Custom_Targeting_Value__c')
                + ' FROM csdf__Custom_Targeting_Value__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet' ;
        } else {
            query += ' WHERE csdf__Custom_Targeting_Key__c = :parentId';
            // ' AND csdf__Active__c = true';
        }
        System.debug('##### Key values query: ' + query);

        try {
            List<csdf__Custom_Targeting_Value__c> kvaValues = Database.query(query);
            System.debug('##### Found ' + kvaValues.size() + ' items.');
            return kvaValues;
        } catch(Exception e) {
            System.debug('##### Error while fetching KeyValue and Audience values: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Targetable__c> getKvaAudienceValues(String adServer, String audienceType, Set<String> preloadSet) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Targetable__c')
                + ' FROM csdf__Targetable__c';
        if(preloadSet != null) {
            query += ' WHERE Id IN :preloadSet' ;
        } else {
            query += ' WHERE csdf__Ad_Server__c =: adServer AND csdf__Type__c= :audienceType AND csdf__Active__c = true';
        }
        System.debug('##### Audience Values query: ' + query);

        try {
            List<csdf__Targetable__c> audienceValues = Database.query(query);
            System.debug('##### Found ' + audienceValues.size() + ' items.');
            return audienceValues;
        } catch(Exception e) {
            System.debug('##### Error while fetching audience values: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Geo_Item__c> getZipItems(String adServer, Set<String> categories, Set<String> zipCodes, Set<String> countryCodes) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Geo_Item__c')
                + ' FROM csdf__Geo_Item__c'
                + ' WHERE csdf__Category__c IN :categories AND Name IN :zipCodes AND csdf__Code__c IN :countryCodes'
                + ' AND csdf__Active__c = true AND csdf__Ad_Server__c = :adServer';
        System.debug('##### Zip Items query: ' + query);

        try {
            List<csdf__Geo_Item__c> zipValues = Database.query(query);
            System.debug('##### Found ' + zipValues.size() + ' items.');
            return zipValues;
        } catch(Exception e) {
            System.debug('##### Error while zip values: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Targetable__c> preloadTargetables(Set<String> preloadSet) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Targetable__c')
                + ' FROM csdf__Targetable__c'
                + ' WHERE Id IN :preloadSet' ;
        System.debug('##### Preload targetables query: ' + query);

        try {
            List<csdf__Targetable__c> targetables = Database.query(query);
            System.debug('##### Found ' + targetables.size() + ' items.');
            return targetables;
        } catch(Exception e) {
            System.debug('##### Error while fetching preload targetable values: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Targeting_Template__c> getTargetingTemplatesList(String presetName, String adServerId, String type) {
        String query = 'SELECT ' + getFieldListAsCSV('csdf__Targeting_Template__c')
                + ' FROM csdf__Targeting_Template__c'
                + ' WHERE csdf__Ad_Server__c =: adServerId';

        if(String.isNotBlank(presetName)) {
            query += ' AND Name LIKE \'%'+ presetName + '%\'';
        }
        if(String.isNotBlank(type)) {
            query += ' AND csdf__Type__c =: type';
        }
        query += ' ORDER BY Name';

        System.debug('##### Load Targeting Templates query: ' + query);

        try {
            List<csdf__Targeting_Template__c> targetingTemplates = Database.query(query);
            System.debug('##### Found ' + targetingTemplates.size() + ' items.');
            return targetingTemplates;
        } catch(Exception e) {
            System.debug('##### Error while fetching Targeting Templates: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    global static List<csdf__Targeting_Template__c> getTargetingTemplates(List<String> targetingTemplateIds) {
        try {
            List<csdf__Targeting_Template__c> targetingTemplates = [
                    SELECT Id,
                           csdf__Ad_Server__c,
                           Key_values_and_Audience__c,
                           Key_values_and_Audience_JSON__c,
                           csdf__Type__c
                    FROM csdf__Targeting_Template__c
                    WHERE Id IN: targetingTemplateIds
            ];

            System.debug('##### Found ' + targetingTemplates.size() + ' items.');
            return targetingTemplates;
        } catch(Exception e) {
            System.debug('##### Error while fetching Targeting Templates: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    public static Map<Id, List<Ad_Slot_Targeting_Template__c>> getAdSlotTargetingTemplates(List<String> targetingTemplateIds) {
        List<Ad_Slot_Targeting_Template__c> adSlotTargetingTemplates = [
                SELECT Id,
                        Ad_Slot__c,
                        Exclude__c,
                        Ad_Slot__r.csdf__Type__c,
                        Targeting_Template__c
                FROM Ad_Slot_Targeting_Template__c
                WHERE Targeting_Template__c IN :targetingTemplateIds
                AND Ad_Slot__r.csdf__Active__c = TRUE
        ];

        Map<Id, List<Ad_Slot_Targeting_Template__c>> adSlotTTsByTTId = new Map<Id, List<Ad_Slot_Targeting_Template__c>>();
        for (Ad_Slot_Targeting_Template__c adSlotTT : adSlotTargetingTemplates) {
            if (!adSlotTTsByTTId.containsKey(adSlotTT.Targeting_Template__c)) {
                adSlotTTsByTTId.put(adSlotTT.Targeting_Template__c, new List<Ad_Slot_Targeting_Template__c>());
            }
            adSlotTTsByTTId.get(adSlotTT.Targeting_Template__c).add(adSlotTT);
        }

        System.debug('##### Found ' + adSlotTargetingTemplates.size() + ' adSlotTargetingTemplates items.');
        return adSlotTTsByTTId;
    }

    public static Map<Id, List<csdf__Geo_Item_Targeting_Template__c>> getGeoItemTargetingTemplates(List<String> targetingTemplateIds) {
        List<csdf__Geo_Item_Targeting_Template__c> geoItemTargetingTemplates = [
                SELECT Id,
                        csdf__Geo_Item__c,
                        csdf__Exclude__c,
                        csdf__Creative_Targeting_Only__c,
                        csdf__Targeting_Template__c
                FROM csdf__Geo_Item_Targeting_Template__c
                WHERE csdf__Targeting_Template__c IN :targetingTemplateIds
                AND csdf__Geo_Item__r.csdf__Active__c = TRUE
        ];

        Map<Id, List<csdf__Geo_Item_Targeting_Template__c>> geoItemTTsbyTTId = new Map<Id, List<csdf__Geo_Item_Targeting_Template__c>>();
        for (csdf__Geo_Item_Targeting_Template__c geoItemTT : geoItemTargetingTemplates) {
            if (!geoItemTTsbyTTId.containsKey(geoItemTT.csdf__Targeting_Template__c)) {
                geoItemTTsbyTTId.put(geoItemTT.csdf__Targeting_Template__c, new List<csdf__Geo_Item_Targeting_Template__c>());
            }
            geoItemTTsbyTTId.get(geoItemTT.csdf__Targeting_Template__c).add(geoItemTT);
        }

        System.debug('##### Found ' + geoItemTargetingTemplates.size() + ' geoItemTargetingTemplates items.');
        return geoItemTTsbyTTId;
    }

    public static Map<Id, List<csdf__Browser_Targeting_Template__c>> getBrowserTargetingTemplates(List<String> targetingTemplateIds) {
        List<csdf__Browser_Targeting_Template__c> browserTargetingTemplates = [
                SELECT Id,
                        csdf__Browser__c,
                        csdf__Exclude__c,
                        csdf__Creative_Targeting_Only__c,
                        csdf__Targeting_Template__c
                FROM csdf__Browser_Targeting_Template__c
                WHERE csdf__Targeting_Template__c IN :targetingTemplateIds
                AND csdf__Browser__r.csdf__Active__c = TRUE
        ];

        Map<Id, List<csdf__Browser_Targeting_Template__c>> browserTTsbyTTId = new Map<Id, List<csdf__Browser_Targeting_Template__c>>();
        for (csdf__Browser_Targeting_Template__c browserTT : browserTargetingTemplates) {
            if (!browserTTsbyTTId.containsKey(browserTT.csdf__Targeting_Template__c)) {
                browserTTsbyTTId.put(browserTT.csdf__Targeting_Template__c, new List<csdf__Browser_Targeting_Template__c>());
            }
            browserTTsbyTTId.get(browserTT.csdf__Targeting_Template__c).add(browserTT);
        }

        System.debug('##### Found ' + browserTargetingTemplates.size() + ' browserTargetingTemplates items.');
        return browserTTsbyTTId;
    }

    public static Map<Id, List<csdf__Operating_System_Targeting_Template__c>> getOperatingSystemTargetingTemplates(List<String> targetingTemplateIds) {
        List<csdf__Operating_System_Targeting_Template__c> operatingSystemTargetingTemplates = [
                SELECT Id,
                        csdf__Operating_System__c,
                        csdf__Exclude__c,
                        csdf__Creative_Targeting_Only__c,
                        csdf__Targeting_Template__c
                FROM csdf__Operating_System_Targeting_Template__c
                WHERE csdf__Targeting_Template__c IN :targetingTemplateIds
                AND csdf__Operating_System__r.csdf__Active__c = TRUE
        ];

        Map<Id, List<csdf__Operating_System_Targeting_Template__c>> operatingSystemTTsbyTTId = new Map<Id, List<csdf__Operating_System_Targeting_Template__c>>();
        for (csdf__Operating_System_Targeting_Template__c operatingSystemTT : operatingSystemTargetingTemplates) {
            if (!operatingSystemTTsbyTTId.containsKey(operatingSystemTT.csdf__Targeting_Template__c)) {
                operatingSystemTTsbyTTId.put(operatingSystemTT.csdf__Targeting_Template__c, new List<csdf__Operating_System_Targeting_Template__c>());
            }
            operatingSystemTTsbyTTId.get(operatingSystemTT.csdf__Targeting_Template__c).add(operatingSystemTT);
        }

        System.debug('##### Found ' + operatingSystemTargetingTemplates.size() + ' operatingSystemTargetingTemplates items.');
        return operatingSystemTTsbyTTId;
    }

    public static Map<Id, List<csdf__Operating_System_Version_Target_Template__c>> getOperatingSystemVerTargetingTemplates(List<String> targetingTemplateIds) {
        List<csdf__Operating_System_Version_Target_Template__c> operatingSystemVerTargetingTemplates = [
                SELECT Id,
                        csdf__Operating_System_Version__c,
                        csdf__Exclude__c,
                        csdf__Creative_Targeting_Only__c,
                        csdf__Targeting_Template__c
                FROM csdf__Operating_System_Version_Target_Template__c
                WHERE csdf__Targeting_Template__c IN :targetingTemplateIds
                AND csdf__Operating_System_Version__r.csdf__Active__c = TRUE
        ];

        Map<Id, List<csdf__Operating_System_Version_Target_Template__c>> operatingSystemVerTTsbyTTId = new Map<Id, List<csdf__Operating_System_Version_Target_Template__c>>();
        for (csdf__Operating_System_Version_Target_Template__c operatingSystemVerTT : operatingSystemVerTargetingTemplates) {
            if (!operatingSystemVerTTsbyTTId.containsKey(operatingSystemVerTT.csdf__Targeting_Template__c)) {
                operatingSystemVerTTsbyTTId.put(operatingSystemVerTT.csdf__Targeting_Template__c, new List<csdf__Operating_System_Version_Target_Template__c>());
            }
            operatingSystemVerTTsbyTTId.get(operatingSystemVerTT.csdf__Targeting_Template__c).add(operatingSystemVerTT);
        }

        System.debug('##### Found ' + operatingSystemVerTargetingTemplates.size() + ' operatingSystemVerTargetingTemplates items.');
        return operatingSystemVerTTsbyTTId;
    }

    public static Map<Id, List<csdf__Targetable_Targeting_Template__c>> getTargetableTargetingTemplates(List<String> targetingTemplateIds) {
        List<csdf__Targetable_Targeting_Template__c> geoItemTargetingTemplates = [
                SELECT Id,
                       csdf__Targetable__c,
                       csdf__Targetable__r.csdf__Type__c,
                       csdf__Exclude__c,
                       csdf__Creative_Targeting_Only__c,
                       csdf__Targeting_Template__c
                FROM csdf__Targetable_Targeting_Template__c
                WHERE csdf__Targeting_Template__c IN :targetingTemplateIds
                AND csdf__Targetable__r.csdf__Active__c = TRUE
        ];

        Map<Id, List<csdf__Targetable_Targeting_Template__c>> geoItemTTsbyTTId = new Map<Id, List<csdf__Targetable_Targeting_Template__c>>();
        for (csdf__Targetable_Targeting_Template__c geoItemTT : geoItemTargetingTemplates) {
            if (!geoItemTTsbyTTId.containsKey(geoItemTT.csdf__Targeting_Template__c)) {
                geoItemTTsbyTTId.put(geoItemTT.csdf__Targeting_Template__c, new List<csdf__Targetable_Targeting_Template__c>());
            }
            geoItemTTsbyTTId.get(geoItemTT.csdf__Targeting_Template__c).add(geoItemTT);
        }

        System.debug('##### Found ' + geoItemTargetingTemplates.size() + ' geoItemTargetingTemplates items.');
        return geoItemTTsbyTTId;
    }

    global static String getFieldListAsCSV(String objectName) {
        switch on objectName {
            when 'csdf__Ad_Slot__c' {
                return 'Id,Name,csdf__Active__c,csdf__Ad_Server__c,csdf__Ad_Server_Id__c,csdf__Code__c,csdf__Name__c,csdf__Type__c,Root_Path__c,Premium_Tag__c';
            }
            when 'csdf__Browser__c' {
                return 'Id,Name,csdf__Active__c,csdf__Ad_Server__c,csdf__Ad_Server_Id__c,csdf__Browser_Name__c,csdf__Major_Version__c,csdf__Minor_Version__c,Premium_Tag__c';
            }
            when 'csdf__Targetable__c' {
                return 'Id,Name,csdf__Active__c,csdf__Ad_Server__c,csdf__Ad_Server_Id__c,Parent_Node_Id__c,csdf__Targetable_Name__c,Targetable_Parent__c,csdf__Type__c,Premium_Tag__c';
            }
            when 'csdf__Geo_Item__c' {
                return 'Id,Name,csdf__Active__c,csdf__Ad_Server__c,csdf__Ad_Server_Id__c,csdf__Category__c,csdf__Code__c,Root_Path__c,Premium_Tag__c';
            }
            when 'csdf__Operating_System__c' {
                return 'Id,Name,csdf__Active__c,csdf__Ad_Server__c,csdf__Ad_Server_Id__c,Premium_Tag__c';
            }
            when 'csdf__Operating_System_Version__c' {
                return 'Id,Name,csdf__Active__c,csdf__Ad_Server_Id__c,Display_Name__c,csdf__Major_Version__c,csdf__Micro_Version__c,csdf__Minor_Version__c,csdf__Operating_System__c,Parent_Node_Id__c,Premium_Tag__c';
            }
            when 'csdf__Custom_Targeting_Key__c' {
                return 'Id,Name,csdf__Ad_Server__c,csdf__Ad_Server_Id__c,csdf__Display_Name__c,csdf__Type__c,Visibility_Tag__c,Premium_Tag__c';
            }
            when 'csdf__Custom_Targeting_Value__c' {
                return 'Id,Name,csdf__Ad_Server_Id__c,csdf__Custom_Targeting_Key__c,csdf__Display_Name__c,Premium_Tag__c';
            }
            when 'Ad_Slot_Template__c' {
                return 'Id,Name';
            }
            when 'csdf__Targeting_Template__c' {
                return 'Id,Name,csdf__Ad_Server__c,csdf__Type__c';
            }
            when else {
                return '';
            }
        }
        // Uncomment this to get all the fields as CSV
        // List<Schema.DescribeSobjectResult> results = Schema.describeSObjects(new List<string>{objectName});
        // if(!results.isEmpty()) {
        //     Map<String, Schema.SObjectField> field_map = results[0].fields.getMap();
        //     return String.join(new List<String>(field_map.keySet()), ',');
        // }
        // return '';
    }
}