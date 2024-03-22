public with sharing class CS_CurrentTargetingsTransformer {

    public static Map<String, String> transformToTargetingList (Map<String, Object> currentTargetingsByKey) {
        System.debug('currentTargetingsByKey => ' + currentTargetingsByKey);
        Map<Id, MediaTargetingWidgetDataEngine.TargetItem> targetItemsByTargetingId = new Map<Id, MediaTargetingWidgetDataEngine.TargetItem>();

        Set<String> adSlotIds = new Set<String>();
        Set<String> geographyIds = new Set<String>();
        Set<String> browserIds = new Set<String>();
        Set<String> operatingSystemIds = new Set<String>();
        Set<String> operatingSystemVersionIds = new Set<String>();
        Set<String> targetableIds = new Set<String>();
        Map<Id,String> targetableTypesMap = new Map<Id,String>();

        Map<String, IncludeExclude> adSlotsIncludeExcludes = new Map<String, IncludeExclude>();
        Map<String, IncludeExclude> geoIncludeExclude = new Map<String, IncludeExclude>();
        Map<String, IncludeExclude> browsersIncludeExclude = new Map<String, IncludeExclude>();
        Map<String, IncludeExclude> operSysIncludeExclude = new Map<String, IncludeExclude>();
        Map<String, IncludeExclude> operSysVerIncludeExclude = new Map<String, IncludeExclude>();
        Map<String, IncludeExclude> deviceCategIncludeExclude = new Map<String, IncludeExclude>();
        Map<String, IncludeExclude> deviceCapIncludeExclude = new Map<String, IncludeExclude>();
        Map<String, IncludeExclude> deviceManIncludeExclude = new Map<String, IncludeExclude>();
        Map<String, IncludeExclude> mobileCarrIncludeExclude = new Map<String, IncludeExclude>();
        Map<String, IncludeExclude> bandwidthIncludeExclude = new Map<String, IncludeExclude>();
        Map<String, String> kvaByConfigGuid = new Map<String, String>();
        Map<String, String> transformedKvaByGuid = new Map<String, String>();
        Map<String, List<TargetedPosition>> targetedPositionsByKey = new Map<String, List<TargetedPosition>>();

        for (String guid : currentTargetingsByKey.keySet()) {
            Map<String, Object> templateData = (Map<String, Object>) JSON.deserializeUntyped((String) currentTargetingsByKey.get(guid));

            if (templateData.get('AdSlots') != null) {
                IncludeExclude adSlots = new IncludeExclude(templateData, 'AdSlots');
                adSlotsIncludeExcludes.put(guid, adSlots);
                adSlotIds.addAll(adSlots.include);
                adSlotIds.addAll(adSlots.exclude);
            }

            if (templateData.get('Geography') != null) {
                IncludeExclude geographies = new IncludeExclude(templateData, 'Geography');
                geoIncludeExclude.put(guid, geographies);
                geographyIds.addAll(geographies.include);
                geographyIds.addAll(geographies.exclude);
            }

            if (templateData.get('Browsers') != null) {
                IncludeExclude browsers = new IncludeExclude(templateData, 'Browsers');
                browsersIncludeExclude.put(guid, browsers);
                browserIds.addAll(browsers.include);
                browserIds.addAll(browsers.exclude);
            }

            if (templateData.get('OperatingSystems') != null) {
                IncludeExclude operatingSystems = new IncludeExclude(templateData, 'OperatingSystems');
                operSysIncludeExclude.put(guid, operatingSystems);
                operatingSystemIds.addAll(operatingSystems.include);
                operatingSystemIds.addAll(operatingSystems.exclude);
            }

            if (templateData.get('OperatingSystemVersions') != null) {
                IncludeExclude operatingSystemVersions = new IncludeExclude(templateData, 'OperatingSystemVersions');
                operSysVerIncludeExclude.put(guid, operatingSystemVersions);
                operatingSystemVersionIds.addAll(operatingSystemVersions.include);
                operatingSystemVersionIds.addAll(operatingSystemVersions.exclude);
            }

            if (templateData.get('DeviceCategories') != null) {
                IncludeExclude deviceCategories = new IncludeExclude(templateData, 'DeviceCategories');
                deviceCategIncludeExclude.put(guid, deviceCategories);
                targetableIds.addAll(deviceCategories.include);
                targetableIds.addAll(deviceCategories.exclude);
                for(String id: deviceCategories.include) {
                    targetableTypesMap.put(id.substring(0, 15), 'dc');
                }
                for(String id: deviceCategories.exclude) {
                    targetableTypesMap.put(id.substring(0, 15), 'dc');
                }
            }

            if (templateData.get('DeviceManufacturer') != null) {
                IncludeExclude deviceManufacturer = new IncludeExclude(templateData, 'DeviceManufacturer');
                deviceManIncludeExclude.put(guid, deviceManufacturer);
                targetableIds.addAll(deviceManufacturer.include);
                targetableIds.addAll(deviceManufacturer.exclude);
                for(String id: deviceManufacturer.include) {
                    targetableTypesMap.put(id.substring(0, 15), 'dm');
                }
                for(String id: deviceManufacturer.exclude) {
                    targetableTypesMap.put(id.substring(0, 15), 'dm');
                }
            }

            if (templateData.get('MobileCarrier') != null) {
                IncludeExclude mobileCarrier = new IncludeExclude(templateData, 'MobileCarrier');
                mobileCarrIncludeExclude.put(guid, mobileCarrier);
                targetableIds.addAll(mobileCarrier.include);
                targetableIds.addAll(mobileCarrier.exclude);
                for(String id: mobileCarrier.include) {
                    targetableTypesMap.put(id.substring(0, 15), 'mc');
                }
                for(String id: mobileCarrier.exclude) {
                    targetableTypesMap.put(id.substring(0, 15), 'mc');
                }
            }

            if (templateData.get('BandwidthGroup') != null) {
                IncludeExclude bandwidth = new IncludeExclude(templateData, 'BandwidthGroup');
                bandwidthIncludeExclude.put(guid, bandwidth);
                targetableIds.addAll(bandwidth.include);
                targetableIds.addAll(bandwidth.exclude);
                for(String id: bandwidth.include) {
                    targetableTypesMap.put(id.substring(0, 15), 'bw');
                }
                for(String id: bandwidth.exclude) {
                    targetableTypesMap.put(id.substring(0, 15), 'bw');
                }
            }

            if (templateData.get('DeviceCapability') != null) {
                IncludeExclude deviceCapability = new IncludeExclude(templateData, 'DeviceCapability');
                deviceCapIncludeExclude.put(guid, deviceCapability);
                targetableIds.addAll(deviceCapability.include);
                targetableIds.addAll(deviceCapability.exclude);
                for(String id: deviceCapability.include) {
                    targetableTypesMap.put(id.substring(0, 15), 'dc');
                }
                for(String id: deviceCapability.exclude) {
                    targetableTypesMap.put(id.substring(0, 15), 'dc');
                }
            }

            if (templateData.get('KVA') != null) {
                Map<String, Object> kvaMap = (Map<String, Object>) templateData.get('KVA');
                String kvaQuery = (String) kvaMap.get('query');
                if (!String.isEmpty(kvaQuery)) {
                    kvaByConfigGuid.put(guid, kvaQuery);
                }
            }

            if (templateData.get('VideoPosition') != null) {
                Map<String, Object> videoPosition = (Map<String, Object>) templateData.get('VideoPosition');
                List<Object> targeting = (List<Object>) videoPosition.get('targeting');
                Map<String, Object> videoPositionTargeting = (Map<String, Object>)targeting[0];
                Map<String, Object> targetedPositions = (Map<String, Object>)videoPositionTargeting.get('videoPositionTargeting');
                List<Object> targetedPositionsList = (List<Object>)targetedPositions.get('targetedPositions');

                List<TargetedPosition> targetedPositionsListCasted = new List<TargetedPosition>();
                for (Object targetedPosition : targetedPositionsList) {
                    TargetedPosition tp = new TargetedPosition();
                    Map<String, Object> tpMap = (Map<String, Object>)targetedPosition;
                    tp.midrollIndex = (Integer)tpMap.get('midrollIndex');
                    tp.positionType = (String)tpMap.get('positionType');
                    tp.videoPositionWithinPod = (Integer)tpMap.get('videoPositionWithinPod');
                    targetedPositionsListCasted.add(tp);
                }

                targetedPositionsByKey.put(guid, targetedPositionsListCasted);
            }
        }

        if (adSlotIds != null && !adSlotIds.isEmpty()) {
            List<csdf__Ad_Slot__c> adSlots = MediaTargetingWidgetQueries.getAdSlots(null, null, adSlotIds, false);
            List<MediaTargetingWidgetDataEngine.TargetItem> adSlotTargetItems = MediaTargetingWidgetDataEngine.getAdSlotTargetItems(adSlots);
            for (MediaTargetingWidgetDataEngine.TargetItem ti : adSlotTargetItems) {
                targetItemsByTargetingId.put(Id.valueOf(ti.id), ti);
            }
        }

        if(geographyIds != null && !geographyIds.isEmpty()) {
            List<csdf__Geo_Item__c> geography = MediaTargetingWidgetQueries.getGeography(null, null, MediaTargetingWidgetQueries.ALL_GEO_CATS, geographyIds);
            List<MediaTargetingWidgetDataEngine.TargetItem> geographyTargetItems = MediaTargetingWidgetDataEngine.getGeoTargetItems(geography);
            for(MediaTargetingWidgetDataEngine.TargetItem ti: geographyTargetItems) {
                targetItemsByTargetingId.put(Id.valueOf(ti.id), ti);
            }
        }

        if(browserIds != null && !browserIds.isEmpty()) {
            List<csdf__Browser__c> browsers = MediaTargetingWidgetQueries.getBrowsers(null, browserIds);
            List<MediaTargetingWidgetDataEngine.TargetItem> browserTargetItems = MediaTargetingWidgetDataEngine.getBrowserTargetItems(browsers);
            for(MediaTargetingWidgetDataEngine.TargetItem ti: browserTargetItems) {
                targetItemsByTargetingId.put(Id.valueOf(ti.id), ti);
            }
        }

        if(operatingSystemIds != null && !operatingSystemIds.isEmpty()) {
            List<csdf__Operating_System__c> operatingSystems = MediaTargetingWidgetQueries.getOperatingSystems(null, operatingSystemIds);
            List<MediaTargetingWidgetDataEngine.TargetItem> operatingSystemTargetItems = MediaTargetingWidgetDataEngine.getOperatingSystemTargetItems(operatingSystems);
            for(MediaTargetingWidgetDataEngine.TargetItem ti: operatingSystemTargetItems) {
                targetItemsByTargetingId.put(Id.valueOf(ti.id), ti);
            }
        }
        if(operatingSystemVersionIds != null && !operatingSystemVersionIds.isEmpty()) {
            List<csdf__Operating_System_Version__c> operatingSystemVersions = MediaTargetingWidgetQueries.getOperatingSystemVersions(null, null, operatingSystemVersionIds, false);
            List<MediaTargetingWidgetDataEngine.TargetItem> operatingSystemVersionTargetItems = MediaTargetingWidgetDataEngine.getOperatingSystemVersionTargetItems(operatingSystemVersions);
            for(MediaTargetingWidgetDataEngine.TargetItem ti: operatingSystemVersionTargetItems) {
                targetItemsByTargetingId.put(Id.valueOf(ti.id), ti);
            }
        }
        if(!targetableIds.isEmpty()) {
            List<csdf__Targetable__c> targetables = MediaTargetingWidgetQueries.preloadTargetables(targetableIds);
            List<csdf__Targetable__c> deviceCategories = new List<csdf__Targetable__c>();
            List<csdf__Targetable__c> deviceManufacturers = new List<csdf__Targetable__c>();
            List<csdf__Targetable__c> mobileCarriers = new List<csdf__Targetable__c>();
            List<csdf__Targetable__c> bandwidthGroups = new List<csdf__Targetable__c>();
            List<csdf__Targetable__c> deviceCapabilities = new List<csdf__Targetable__c>();
            for(csdf__Targetable__c item: targetables) {
                String type = targetableTypesMap.get(((String)item.Id).substring(0,15));
                switch on type {
                    when 'dc' {
                        deviceCategories.add(item);
                    }
                    when 'dm' {
                        deviceManufacturers.add(item);
                    }
                    when 'mc' {
                        mobileCarriers.add(item);
                    }
                    when 'bw' {
                        bandwidthGroups.add(item);
                    }
                    when 'dca' {
                        deviceCapabilities.add(item);
                    }
                }
            }

            List<MediaTargetingWidgetDataEngine.TargetItem> deviceCategoryTargetItems = MediaTargetingWidgetDataEngine.getTargetableTargetItems(deviceCategories, 'DeviceCategories');
            List<MediaTargetingWidgetDataEngine.TargetItem> deviceManufacturerTargetItems = MediaTargetingWidgetDataEngine.getTargetableTargetItems(deviceManufacturers, 'DeviceManufacturer');
            List<MediaTargetingWidgetDataEngine.TargetItem> mobileCarrierTargetItems = MediaTargetingWidgetDataEngine.getTargetableTargetItems(mobileCarriers, 'MobileCarrier');
            List<MediaTargetingWidgetDataEngine.TargetItem> bandwidthGroupTargetItems = MediaTargetingWidgetDataEngine.getTargetableTargetItems(bandwidthGroups, 'BandwidthGroup');
            List<MediaTargetingWidgetDataEngine.TargetItem> deviceCapabilityTargetItems = MediaTargetingWidgetDataEngine.getTargetableTargetItems(deviceCapabilities, 'DeviceCapability');

            for(MediaTargetingWidgetDataEngine.TargetItem ti: deviceCategoryTargetItems) {
                targetItemsByTargetingId.put(Id.valueOf(ti.id), ti);
            }
            for(MediaTargetingWidgetDataEngine.TargetItem ti: deviceManufacturerTargetItems) {
                targetItemsByTargetingId.put(Id.valueOf(ti.id), ti);
            }
            for(MediaTargetingWidgetDataEngine.TargetItem ti: mobileCarrierTargetItems) {
                targetItemsByTargetingId.put(Id.valueOf(ti.id), ti);
            }
            for(MediaTargetingWidgetDataEngine.TargetItem ti: bandwidthGroupTargetItems) {
                targetItemsByTargetingId.put(Id.valueOf(ti.id), ti);
            }
            for(MediaTargetingWidgetDataEngine.TargetItem ti: deviceCapabilityTargetItems) {
                targetItemsByTargetingId.put(Id.valueOf(ti.id), ti);
            }
        }
        if (!kvaByConfigGuid.isEmpty()) {
            KvaTransformer kvaParser = new KvaTransformer(kvaByConfigGuid);
            transformedKvaByGuid = kvaParser.transformKvaExpressionToTargetingList();
        }

        Map<String, String> targetingListByGuid = new Map<String, String>();
        List<String> targetingListElements = new List<String>();
        for (String guid : currentTargetingsByKey.keySet()) {
            IncludeExclude adSlotIE = adSlotsIncludeExcludes.get(guid);
            String targetingElement = getTargetingListElement('Ad Unit', adSlotIE, targetItemsByTargetingId);
            if (!String.isEmpty(targetingElement))
                targetingListElements.add(targetingElement);

            IncludeExclude geoIE = geoIncludeExclude.get(guid);
            targetingElement = getTargetingListElement('Geography', geoIE, targetItemsByTargetingId);
            if (!String.isEmpty(targetingElement))
                targetingListElements.add(targetingElement);

            IncludeExclude browserIE = browsersIncludeExclude.get(guid);
            targetingElement = getTargetingListElement('Browsers', browserIE, targetItemsByTargetingId);
            if (!String.isEmpty(targetingElement))
                targetingListElements.add(targetingElement);

            IncludeExclude operSysIE = operSysIncludeExclude.get(guid);
            targetingElement = getTargetingListElement('Operating System', operSysIE, targetItemsByTargetingId);
            if (!String.isEmpty(targetingElement))
                targetingListElements.add(targetingElement);

            IncludeExclude operSysVerIE = operSysVerIncludeExclude.get(guid);
            targetingElement = getTargetingListElement('Operating System Version', operSysVerIE, targetItemsByTargetingId);
            if (!String.isEmpty(targetingElement))
                targetingListElements.add(targetingElement);

            IncludeExclude deviceCatIE = deviceCategIncludeExclude.get(guid);
            targetingElement = getTargetingListElement('Device Category', deviceCatIE, targetItemsByTargetingId);
            if (!String.isEmpty(targetingElement))
                targetingListElements.add(targetingElement);

            IncludeExclude deviceManIE = deviceManIncludeExclude.get(guid);
            targetingElement = getTargetingListElement('Mobile Device', deviceManIE, targetItemsByTargetingId);
            if (!String.isEmpty(targetingElement))
                targetingListElements.add(targetingElement);

            IncludeExclude mobileCarIE = mobileCarrIncludeExclude.get(guid);
            targetingElement = getTargetingListElement('Mobile Carrier', mobileCarIE, targetItemsByTargetingId);
            if (!String.isEmpty(targetingElement))
                targetingListElements.add(targetingElement);

            IncludeExclude bandwidthIE = bandwidthIncludeExclude.get(guid);
            targetingElement = getTargetingListElement('Bandwidth', bandwidthIE, targetItemsByTargetingId);
            if (!String.isEmpty(targetingElement))
                targetingListElements.add(targetingElement);

            IncludeExclude deviceCapIE = deviceCapIncludeExclude.get(guid);
            targetingElement = getTargetingListElement('Device Capability', deviceCapIE, targetItemsByTargetingId);
            if (!String.isEmpty(targetingElement))
                targetingListElements.add(targetingElement);

            if (!transformedKvaByGuid.isEmpty() && transformedKvaByGuid.containsKey(guid)) {
                targetingElement = transformedKvaByGuid.get(guid);

                if (!String.isEmpty(targetingElement))
                    targetingListElements.add('Key-value and Audience: ' + targetingElement);
            }

            if (!targetedPositionsByKey.isEmpty() && targetedPositionsByKey.containsKey(guid)) {
                List<TargetedPosition> targetedPositions = targetedPositionsByKey.get(guid);

                if (!targetedPositions.isEmpty()){
                    targetingElement = getVideoPositionTargetingListElement(targetedPositions);
                    targetingListElements.add('Video Position: ' + targetingElement);
                }
            }

            targetingListByGuid.put(guid, String.join(targetingListElements, ' | '));
            targetingListElements = new List<String>();
        }

        return targetingListByGuid;
    }

    private static String  getTargetingListElement(String targetingCategory, IncludeExclude includeExclude, Map<Id, MediaTargetingWidgetDataEngine.TargetItem> targetItemsMap){
        String targetingListElement = '';

        if (includeExclude == null
                || (includeExclude.include.isEmpty() && includeExclude.exclude.isEmpty())) {
            return targetingListElement;
        }

        targetingListElement += targetingCategory;

        if (!includeExclude.include.isEmpty()) {
            targetingListElement += ' (include) ';

            List<String> targetingItemNames = new List<String>();
            for (String targetItemId : includeExclude.include) {
                MediaTargetingWidgetDataEngine.TargetItem targetItem = targetItemsMap.get(targetItemId);
                targetingItemNames.add(targetItem.name);
            }
            targetingListElement += String.join(targetingItemNames, ',');
        }

        if (!includeExclude.exclude.isEmpty()) {
            targetingListElement += ' (exclude) ';

            List<String> targetingItemNames = new List<String>();
            for (String targetItemId : includeExclude.exclude) {
                MediaTargetingWidgetDataEngine.TargetItem targetItem = targetItemsMap.get(targetItemId);
                targetingItemNames.add(targetItem.name);
            }
            targetingListElement += String.join(targetingItemNames, ',');
        }

        return targetingListElement;
    }

    public class IncludeExclude {
        public List<String> include { get; set; }
        public List<String> exclude { get; set; }

        public IncludeExclude() {
            include = new List<String>();
            exclude = new List<String>();
        }

        public IncludeExclude(Map<String, Object> templateData, String targetingSection)  {
            this();

            Map<String, Object> adslotsMap = (Map<String, Object>) templateData.get(targetingSection);
            List<Object> includeList = (List<Object>) adslotsMap.get('include');
            List<Object> excludeList = (List<Object>) adslotsMap.get('exclude');

            for(Object includeId: (List<Object>) includeList) {
                if (includeId instanceof Id) {
                    include.add(((String)includeId).substring(0,15));
                }
            }

            for(Object excludeId: (List<Object>) excludeList) {
                if (excludeId instanceof Id) {
                    exclude.add(((String)excludeId).substring(0,15));
                }
            }
        }
    }

    public class KvaTransformer {
        public List<String> kvaKeyIds { get; set; }
        public List<String> kvaValueIds { get; set; }
        public List<String> kvaAudienceValueIds { get; set; }
        Map<String, String> kvaExpressionByKeyMap {get; set;}

        public Map<String, csdf__Custom_Targeting_Key__c> customTargetingKeyByAdServerKey {
            get {
                if(customTargetingKeyByAdServerKey == null) {
                    customTargetingKeyByAdServerKey = new Map<String, csdf__Custom_Targeting_Key__c>();
                    for (csdf__Custom_Targeting_Key__c t : [
                            SELECT Id, csdf__Display_Name__c, csdf__Ad_Server_Id__c, Name, (
                                    SELECT Id, csdf__Display_Name__c, Name, csdf__Ad_Server_Id__c
                                    FROM csdf__Custom_Targeting_Values__r
                                    WHERE csdf__Ad_Server_Id__c IN :kvaValueIds
                            )
                            FROM csdf__Custom_Targeting_Key__c
                            WHERE csdf__Ad_Server_Id__c IN :kvaKeyIds
                            ORDER BY csdf__Display_Name__c
                    ]) {
                        customTargetingKeyByAdServerKey.put(t.csdf__Ad_Server_Id__c, t);
                    }
                }
                return customTargetingKeyByAdServerKey;
            }
            private set;
        }

        public Map<String, csdf__Targetable__c> audienceSegmentValueByAdServerKey {
            get {
                if (audienceSegmentValueByAdServerKey == null) {
                    audienceSegmentValueByAdServerKey = new Map<String, csdf__Targetable__c>();
                    if (!kvaAudienceValueIds.isEmpty()) {
                        for (csdf__Targetable__c t : [
                                SELECT csdf__Ad_Server_Id__c,csdf__Ad_Server__c,csdf__Description__c,
                                        csdf__Targetable_Name__c,csdf__Type__c,Id,Targetable_Parent__c
                                FROM csdf__Targetable__c
                                WHERE csdf__Type__c = 'Audience Segment'
                                AND csdf__Ad_Server_Id__c IN :kvaAudienceValueIds
                                AND csdf__Active__c = TRUE
                        ]) {
                            audienceSegmentValueByAdServerKey.put(t.csdf__Ad_Server_Id__c, t);
                        }
                    }
                }
                return audienceSegmentValueByAdServerKey;
            }
            private set;
        }

        public KvaTransformer() {
            kvaKeyIds = new List<String>();
            kvaValueIds = new List<String>();
            kvaAudienceValueIds = new List<String>();
        }

        public KvaTransformer(Map<String, String> kvaExpressionByKeyMap) {
            this();
            this.kvaExpressionByKeyMap = kvaExpressionByKeyMap;
            for (String kvaExpression : kvaExpressionByKeyMap.values()) {
                for (String keyStr : CS_Util.getKeys(kvaExpression)) {
                    kvaKeyIds.add(keyStr.right(keyStr.length() - 1));
                }
                for (String valueStr : CS_Util.getKeyValues(kvaExpression)) {
                    kvaValueIds.add(valueStr.right(valueStr.length() - 1));
                }
                for (String valueStr : CS_Util.getAudienceSegmentKeyValues(kvaExpression)) {
                    kvaAudienceValueIds.add(valueStr);
                }
            }
        }

        public Map<String, String> transformKvaExpressionToTargetingList() {
            Map<String, String> transformedKvaQueryByKeyMap = new Map<String, String>();
            for (String adServerIdKey : kvaExpressionByKeyMap.keySet()) {
                String kvaExpression = kvaExpressionByKeyMap.get(adServerIdKey);

                String replacedKvaExpression1 = kvaExpression.replace(' AND ', ' and ');
                String replacedKvaExpression2 = CS_Util.replaceAll(' is not ', ' isnot ', replacedKvaExpression1, true);

                String[] sets = replacedKvaExpression2.split(' OR ');

                for (String setString : sets) {
                    System.debug('setString: ' + setString);
                    String replacedSetString = setString.replace(' or ', ',');
                    String[] keyValuesElements = replacedSetString.split(' and ');

                    for (String keyValuesElement : keyValuesElements) {
                        System.debug('keyValuesElement: ' + keyValuesElement);
                        if (keyValuesElement.containsIgnoreCase('Audience Segment')) {
                            String[] keyValueElements = keyValuesElement.split(' ');
                            String[] values = keyValueElements[3].split(',');
                            System.debug('values: ' + values);
                            for (String value : values) {
                                System.debug('value:  ' + value);
                                csdf__Targetable__c targetable = audienceSegmentValueByAdServerKey.get(value);

                                if (targetable == null) {
                                    throw new NotFoundException('Cannot find csdf__Targetable__c record for Audience Segment which has Ad_Server_Id__c = ' + value);
                                }

                                kvaExpression = kvaExpression.replace(value, targetable.csdf__Targetable_Name__c);
                            }
                        }
                        else {
                            String[] keyValueElements = keyValuesElement.split(' ');

                            String key = keyValueElements[0];
                            csdf__Custom_Targeting_Key__c ctKey = customTargetingKeyByAdServerKey.get(key.right(key.length() - 1)); //removing #

                            if (ctKey == null) {
                                throw new NotFoundException('Cannot find csdf__Custom_Targeting_Key__c record which has Ad_Server_Id__c = ' + key);
                            }

                            kvaExpression = kvaExpression.replace(key, ctKey.csdf__Display_Name__c);

                            Map<String, csdf__Custom_Targeting_Value__c> customTargetingValueByKeyMap = new Map<String, csdf__Custom_Targeting_Value__c>();
                            for (csdf__Custom_Targeting_Value__c customTargetingValue : ctKey.csdf__Custom_Targeting_Values__r) {
                                customTargetingValueByKeyMap.put(customTargetingValue.csdf__Ad_Server_Id__c, customTargetingValue);
                            }

                            String[] values = keyValueElements[2].split(',');
                            System.debug('values: ' + values);
                            for (String value : values) {
                                csdf__Custom_Targeting_Value__c ctValue = customTargetingValueByKeyMap.get(value.right(value.length() - 1)); //removing #

                                if (ctValue == null) {
                                    throw new NotFoundException('Cannot find csdf__Custom_Targeting_Value__c record which has Ad_Server_Id__c = ' + value);
                                }

                                kvaExpression = kvaExpression.replace(value, ctValue.csdf__Display_Name__c);

                                System.debug('value:  ' + value);
                            }
                        }
                    }
                }

                transformedKvaQueryByKeyMap.put(adServerIdKey, kvaExpression);
            }

            return transformedKvaQueryByKeyMap;
        }
    }

    private static Map<String, String> VIDEO_POSITIONS_TO_LABELS = new Map<String, String> {
            'PREROLL' => 'Pre-roll',
            'MIDROLL' => 'Mid-roll',
            'POSTROLL' => 'Post-roll'
    };

    public static String getVideoPositionTargetingListElement(List<TargetedPosition> targetedPositions) {
        List<String> videoPositionTargetings = new List<String>();
        for (TargetedPosition targetedPosition : targetedPositions) {
            if (targetedPosition.videoPositionWithinPod == null) {
                if (targetedPosition.midrollIndex == null) {
                    videoPositionTargetings.add(VIDEO_POSITIONS_TO_LABELS.get(targetedPosition.positionType));
                }
                else {
                    videoPositionTargetings.add(VIDEO_POSITIONS_TO_LABELS.get(targetedPosition.positionType) + ' ' + targetedPosition.midrollIndex);
                }
            }
            else {
                videoPositionTargetings.add(getVideoLabel(VIDEO_POSITIONS_TO_LABELS.get(targetedPosition.positionType), targetedPosition.videoPositionWithinPod));
            }
        }

        return String.join(videoPositionTargetings, ', ');
    }

    private static String getVideoLabel (String name, Integer index) {
        String position;
        switch on index {
            when 1 {
                position = 'First position';
            }
            when 100 {
                position = 'Last position';
            }
            when else {
                position = 'Position ' + index;
            }
        }
        String labelName = name.toLowerCase() == 'mid-roll' ? 'any mid-roll' : name.toLowerCase();
        return position + ' in ' + labelName + ' pod';
    }

    public class TargetedPosition {
        public String positionType {get; set;}
        public Integer videoPositionWithinPod {get; set;}
        public Integer midrollIndex {get; set;}
    }

    public class NotFoundException extends Exception {}
}