global with sharing class MediaTargetingWidgetDataLoader {

    public static final String DATA_KEYWORD = 'data';
    public static final String MARKER_KEYWORD = 'marker';
    public static final String TEMPLATE_KEYWORD = 'template';
    public static final String TARGETING_TEMPLATES_KEYWORD = 'targetingTemplates';

    public static Map<String, Object> loadTemplate(Map<String, String> data) {
        if(data == null) {
            // return empty placeholders for consistency
            return new Map<String, Object>{
                TARGETING_TEMPLATES_KEYWORD => new List<String>(),
                TEMPLATE_KEYWORD => new Map<String, Object>()
            };
        }

        Map<String, Object> res = new Map<String, Object>();
        Map<String, Object> templateMap = new Map<String, Object>();
        List<String> targetingTemplateIds = new List<String>();

        // loading targeting templates map
        try {
            if(data.get(TARGETING_TEMPLATES_KEYWORD) != null) {
                for(String targetingTemplateId: (List<String>) JSON.deserialize((String) data.get(TARGETING_TEMPLATES_KEYWORD), List<String>.class)) {
                    if(targetingTemplateId instanceOf Id) {
                        targetingTemplateIds.add(targetingTemplateId.substring(0,15));
                    }
                }

                if(targetingTemplateIds.size() > 0) {
                    templateMap = MediaTargetingWidgetDataLoaderHelper.loadTargetingTemplate(targetingTemplateIds);
                }
            }
        } catch(Exception e) {
            System.debug('##### Error while fetching targeting templates data: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
        }

        res.put(TARGETING_TEMPLATES_KEYWORD, targetingTemplateIds);
        res.put(TEMPLATE_KEYWORD, templateMap);

        return res;
    }

    public static String saveTemplate(String name, String adServerId, Map<String, String> data) {
        if (data == null || data.get('templateData') == null || data.get('templateType') == null) {
            System.debug('##### Request invalid. data.templateData map or data.templateType not provided...');
            return null;
        }

        return MediaTargetingWidgetDataLoaderHelper.saveTargetingTemplate(name, adServerId, data);
    }

    public static String getData(Map<String, String> data) {
        Map<String, Object> parsedDataModel = MediaTargetingWidgetDataLoaderHelper.parseDataModel(data);
        System.debug('##### Parsed data model: ' + parsedDataModel);
        if(parsedDataModel == null) {
            System.debug('##### Received payload invalid.');
            Map<String, Object> empty = new Map<String, Object>{DATA_KEYWORD => new Map<String, Object>()};
            return JSON.serialize(empty);
        } else {
            System.debug('##### Received input model: ' + data.get('payload'));
            parsedDataModel.put(DATA_KEYWORD, loadData(parsedDataModel, data.get('marker'), data.get('loadType')));
            return JSON.serialize(parsedDataModel);
        }
    }

    private static Map<String, Object> loadData(Map<String, Object> inputModel, String marker, String loadType) {
        Map<String, Object> res = new Map<String, Object>();
        Map<String,String> targetableTypesMap = new Map<String,String>();

        Set<String> adSlotIds = (Set<String>) inputModel.get('AdSlots');
        Set<String> browserIds = (Set<String>) inputModel.get('Browsers');
        Set<String> deviceCategoryIds = (Set<String>) inputModel.get('DeviceCategories');
        Set<String> deviceManufacturerIds = (Set<String>) inputModel.get('DeviceManufacturer');
        Set<String> mobileCarrierIds = (Set<String>) inputModel.get('MobileCarrier');
        Set<String> geographyIds = (Set<String>) inputModel.get('Geography');
        Set<String> operatingSystemIds = (Set<String>) inputModel.get('OperatingSystems');
        Set<String> operatingSystemVersionIds = (Set<String>) inputModel.get('OperatingSystemVersions');
        Set<String> kvaKeyIds = (Set<String>) inputModel.get('KvaKeys');
        Set<String> kvaValueIds = (Set<String>) inputModel.get('KvaValues');
        Set<String> kvaAudienceValueIds = (Set<String>) inputModel.get('KvaAudienceValues');
        Set<String> bandwidthGroupIds = (Set<String>) inputModel.get('BandwidthGroup');
        Set<String> deviceCapabilityIds = (Set<String>) inputModel.get('DeviceCapability');

        Set<String> targetableIds = new Set<String>();
        if(deviceCategoryIds != null) {
            targetableIds.addAll(deviceCategoryIds);
            for(String id: deviceCategoryIds) {
                targetableTypesMap.put(id, 'dc');
            }
        }
        if(deviceManufacturerIds != null) {
            targetableIds.addAll(deviceManufacturerIds);
            for(String id: deviceManufacturerIds) {
                targetableTypesMap.put(id, 'dm');
            }
        }
        if(mobileCarrierIds != null) {
            targetableIds.addAll(mobileCarrierIds);
            for(String id: mobileCarrierIds) {
                targetableTypesMap.put(id, 'mc');
            }
        }
        if(kvaAudienceValueIds != null) {
            targetableIds.addAll(kvaAudienceValueIds);
            for(String id: kvaAudienceValueIds) {
                targetableTypesMap.put(id, 'kav');
            }
        }
        if(bandwidthGroupIds != null) {
            targetableIds.addAll(bandwidthGroupIds);
            for(String id: bandwidthGroupIds) {
                targetableTypesMap.put(id, 'bw');
            }
        }
        if(deviceCapabilityIds != null) {
            targetableIds.addAll(deviceCapabilityIds);
            for(String id: deviceCapabilityIds) {
                targetableTypesMap.put(id, 'dca');
            }
        }
        if(adSlotIds != null && !adSlotIds.isEmpty()) {
            List<csdf__Ad_Slot__c> adSlots = MediaTargetingWidgetQueries.getAdSlots(null, null, adSlotIds, false);
            List<MediaTargetingWidgetDataEngine.TargetItem> adSlotTargetItems;
            if(loadType != null && loadType == 'missingParents') {
                adSlotTargetItems = MediaTargetingWidgetDataEngine.getAdSlotTargetItemsWithParents(adSlots, true);
            } else {
                adSlotTargetItems = MediaTargetingWidgetDataEngine.getAdSlotTargetItems(adSlots);
            }
            for(MediaTargetingWidgetDataEngine.TargetItem ti: adSlotTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
        }
        if(browserIds != null && !browserIds.isEmpty()) {
            List<csdf__Browser__c> browsers = MediaTargetingWidgetQueries.getBrowsers(null, browserIds);
            List<MediaTargetingWidgetDataEngine.TargetItem> browserTargetItems = MediaTargetingWidgetDataEngine.getBrowserTargetItems(browsers);
            for(MediaTargetingWidgetDataEngine.TargetItem ti: browserTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
        }
        if(!targetableIds.isEmpty()) {
            List<csdf__Targetable__c> targetables = MediaTargetingWidgetQueries.preloadTargetables(targetableIds);
            List<csdf__Targetable__c> deviceCategories = new List<csdf__Targetable__c>();
            List<csdf__Targetable__c> deviceManufacturers = new List<csdf__Targetable__c>();
            List<csdf__Targetable__c> mobileCarriers = new List<csdf__Targetable__c>();
            List<csdf__Targetable__c> kvaAudienceValues = new List<csdf__Targetable__c>();
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
                    when 'kav' {
                        kvaAudienceValues.add(item);
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
            List<MediaTargetingWidgetDataEngine.TargetItem> kvaAudienceValueTargetItems = MediaTargetingWidgetDataEngine.getKvaAudienceValueTargetItems(kvaAudienceValues);
            List<MediaTargetingWidgetDataEngine.TargetItem> bandwidthGroupTargetItems = MediaTargetingWidgetDataEngine.getTargetableTargetItems(bandwidthGroups, 'BandwidthGroup');
            List<MediaTargetingWidgetDataEngine.TargetItem> deviceCapabilityTargetItems = MediaTargetingWidgetDataEngine.getTargetableTargetItems(deviceCapabilities, 'DeviceCapability');

            for(MediaTargetingWidgetDataEngine.TargetItem ti: deviceCategoryTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
            for(MediaTargetingWidgetDataEngine.TargetItem ti: deviceManufacturerTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
            for(MediaTargetingWidgetDataEngine.TargetItem ti: mobileCarrierTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
            for(MediaTargetingWidgetDataEngine.TargetItem ti: kvaAudienceValueTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
            for(MediaTargetingWidgetDataEngine.TargetItem ti: bandwidthGroupTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
            for(MediaTargetingWidgetDataEngine.TargetItem ti: deviceCapabilityTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
        }
        if(geographyIds != null && !geographyIds.isEmpty()) {
            List<csdf__Geo_Item__c> geography = MediaTargetingWidgetQueries.getGeography(null, null, MediaTargetingWidgetQueries.ALL_GEO_CATS, geographyIds);
            List<MediaTargetingWidgetDataEngine.TargetItem> geographyTargetItems = MediaTargetingWidgetDataEngine.getGeoTargetItems(geography);
            for(MediaTargetingWidgetDataEngine.TargetItem ti: geographyTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
        }
        if(operatingSystemIds != null && !operatingSystemIds.isEmpty()) {
            List<csdf__Operating_System__c> operatingSystems = MediaTargetingWidgetQueries.getOperatingSystems(null, operatingSystemIds);
            List<MediaTargetingWidgetDataEngine.TargetItem> operatingSystemTargetItems = MediaTargetingWidgetDataEngine.getOperatingSystemTargetItems(operatingSystems);
            for(MediaTargetingWidgetDataEngine.TargetItem ti: operatingSystemTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
        }
        if(operatingSystemVersionIds != null && !operatingSystemVersionIds.isEmpty()) {
            List<csdf__Operating_System_Version__c> operatingSystemVersions = MediaTargetingWidgetQueries.getOperatingSystemVersions(null, null, operatingSystemVersionIds, false);
            List<MediaTargetingWidgetDataEngine.TargetItem> operatingSystemVersionTargetItems = MediaTargetingWidgetDataEngine.getOperatingSystemVersionTargetItems(operatingSystemVersions);
            for(MediaTargetingWidgetDataEngine.TargetItem ti: operatingSystemVersionTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
        }
        if(kvaKeyIds != null) { // if we want Audience Segment only, send empty set
            List<csdf__Custom_Targeting_Key__c> kvaKeys = MediaTargetingWidgetQueries.getKvaKeys(null, kvaKeyIds);
            List<MediaTargetingWidgetDataEngine.TargetItem> kvaKeyTargetItems = MediaTargetingWidgetDataEngine.getKvaKeysTargetItems(kvaKeys);
            for(MediaTargetingWidgetDataEngine.TargetItem ti: kvaKeyTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
        }
        if(kvaValueIds != null && !kvaValueIds.isEmpty()) {
            List<csdf__Custom_Targeting_Value__c> kvaValues = MediaTargetingWidgetQueries.getKvaValues(null, kvaValueIds);
            List<MediaTargetingWidgetDataEngine.TargetItem> kvaValueTargetItems = MediaTargetingWidgetDataEngine.getKvaValueTargetItems(kvaValues);
            for(MediaTargetingWidgetDataEngine.TargetItem ti: kvaValueTargetItems) {
                if(marker != null) {
                    ti.data.put(MARKER_KEYWORD, marker);
                }
                res.put(ti.Id, ti);
            }
        }

        return res;
    }
}