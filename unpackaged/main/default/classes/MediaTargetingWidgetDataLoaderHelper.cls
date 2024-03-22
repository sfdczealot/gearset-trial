global with sharing class MediaTargetingWidgetDataLoaderHelper {

    public static final String INCLUDE_KEYWORD = 'include';
    public static final String EXCLUDE_KEYWORD = 'exclude';
    public static final String JSON_KEYWORD = 'JSON';
    public static final String QUERY_KEYWORD = 'query';

    public static Map<String, Object> loadTargetingTemplate(List<String> templateIds) {
        Map<String, Object> res = new Map<String, Object>();

        List<csdf__Targeting_Template__c> targetingTemplates = MediaTargetingWidgetQueries.getTargetingTemplates(templateIds);
        Map<Id, List<Ad_Slot_Targeting_Template__c>> adSlotTargetingTemplatesByTargetingTemplateId =  MediaTargetingWidgetQueries.getAdSlotTargetingTemplates(templateIds);
        Map<Id, List<csdf__Geo_Item_Targeting_Template__c>> geoItemTargetingTemplatesByTargetingTemplateId=  MediaTargetingWidgetQueries.getGeoItemTargetingTemplates(templateIds);
        Map<Id, List<csdf__Browser_Targeting_Template__c>> browserTargetingTemplatesByTargetingTemplateId =  MediaTargetingWidgetQueries.getBrowserTargetingTemplates(templateIds);
        Map<Id, List<csdf__Operating_System_Targeting_Template__c>> operatingSystemTargetingTemplatesByTargetingTemplateId =  MediaTargetingWidgetQueries.getOperatingSystemTargetingTemplates(templateIds);
        Map<Id, List<csdf__Operating_System_Version_Target_Template__c>> operatingSystemVersionTargetTemplatesByTargetingTemplateId =  MediaTargetingWidgetQueries.getOperatingSystemVerTargetingTemplates(templateIds);
        Map<Id, List<csdf__Targetable_Targeting_Template__c>> targetableTargetingTemplatesByTargetingTemplateId =  MediaTargetingWidgetQueries.getTargetableTargetingTemplates(templateIds);

        if(targetingTemplates != null) {
            for(csdf__Targeting_Template__c targetingTemplate: targetingTemplates) {
                // Ad Slots
                Set<String> adSlotsIncl = new Set<String>();
                Set<String> adSlotsExcl = new Set<String>();
                List<Ad_Slot_Targeting_Template__c> adSlotTargetingTemplates = adSlotTargetingTemplatesByTargetingTemplateId.get(targetingTemplate.Id);
                if (adSlotTargetingTemplates != null && !adSlotTargetingTemplates.isEmpty()) {
                    for(Ad_Slot_Targeting_Template__c adSlotJunctionObject: adSlotTargetingTemplates) {
                        if(String.isNotBlank(adSlotJunctionObject.Ad_Slot__r.csdf__Type__c)) {
                            if(adSlotJunctionObject.Exclude__c) {
                                adSlotsExcl.add(((String) adSlotJunctionObject.Ad_Slot__c).substring(0,15));
                            } else {
                                // include
                                adSlotsIncl.add(((String) adSlotJunctionObject.Ad_Slot__c).substring(0,15));
                            }
                        }
                    }
                }

                // geo item targetings
                Set<String> geoItemIncludes = new Set<String>();
                Set<String> geoItemExcludes = new Set<String>();
                List<csdf__Geo_Item_Targeting_Template__c> geoItemTargetingTemplates = geoItemTargetingTemplatesByTargetingTemplateId.get(targetingTemplate.Id);
                if (geoItemTargetingTemplates != null && !geoItemTargetingTemplates.isEmpty()) {
                    for (csdf__Geo_Item_Targeting_Template__c geoItemJunctionObject : geoItemTargetingTemplates) {
                        if (geoItemJunctionObject.csdf__Exclude__c) {
                            geoItemExcludes.add(((String) geoItemJunctionObject.csdf__Geo_Item__c).substring(0, 15));
                        }
                        else {
                            geoItemIncludes.add(((String) geoItemJunctionObject.csdf__Geo_Item__c).substring(0, 15));
                        }
                    }
                }

                // browser targetings
                Set<String> browserIncludes = new Set<String>();
                Set<String> browserExcludes = new Set<String>();
                List<csdf__Browser_Targeting_Template__c> browserTargetingTemplates = browserTargetingTemplatesByTargetingTemplateId.get(targetingTemplate.Id);
                if (browserTargetingTemplates != null && !browserTargetingTemplates.isEmpty()) {
                    for(csdf__Browser_Targeting_Template__c browserJunctionObject: browserTargetingTemplates) {
                        if(browserJunctionObject.csdf__Exclude__c) {
                            browserExcludes.add(((String) browserJunctionObject.csdf__Browser__c).substring(0,15));
                        } else {
                            browserIncludes.add(((String) browserJunctionObject.csdf__Browser__c).substring(0,15));
                        }
                    }
                }

                // operating system targetings
                Set<String> osIncludes = new Set<String>();
                Set<String> osExcludes = new Set<String>();
                List<csdf__Operating_System_Targeting_Template__c> operatingSystemTargetingTemplates = operatingSystemTargetingTemplatesByTargetingTemplateId.get(targetingTemplate.Id);
                if (operatingSystemTargetingTemplates != null && !operatingSystemTargetingTemplates.isEmpty()) {
                    for(csdf__Operating_System_Targeting_Template__c osJunctionObject: operatingSystemTargetingTemplates) {
                        if(osJunctionObject.csdf__Exclude__c) {
                            osExcludes.add(((String) osJunctionObject.csdf__Operating_System__c).substring(0,15));
                        } else {
                            osIncludes.add(((String) osJunctionObject.csdf__Operating_System__c).substring(0,15));
                        }
                    }
                }

                // operating system version targetings
                Set<String> osvIncludes = new Set<String>();
                Set<String> osvExcludes = new Set<String>();
                List<csdf__Operating_System_Version_Target_Template__c> operatingSystemVersionTargetTemplates = operatingSystemVersionTargetTemplatesByTargetingTemplateId.get(targetingTemplate.Id);
                if (operatingSystemVersionTargetTemplates != null && !operatingSystemVersionTargetTemplates.isEmpty()) {
                    for(csdf__Operating_System_Version_Target_Template__c osvJunctionObject: operatingSystemVersionTargetTemplates) {
                        if(osvJunctionObject.csdf__Exclude__c) {
                            osvExcludes.add(((String) osvJunctionObject.csdf__Operating_System_Version__c).substring(0,15));
                        } else {
                            osvIncludes.add(((String) osvJunctionObject.csdf__Operating_System_Version__c).substring(0,15));
                        }
                    }
                }

                // targetable targetings
                // DeviceCategories, DeviceManufacturer, MobileCarrier
                Set<String> devCatIncludes = new Set<String>();
                Set<String> devCatExcludes = new Set<String>();
                Set<String> devManIncludes = new Set<String>();
                Set<String> devManExcludes = new Set<String>();
                Set<String> mobCarIncludes = new Set<String>();
                Set<String> mobCarExcludes = new Set<String>();
                Set<String> bwGroupIncludes = new Set<String>();
                Set<String> bwGroupExcludes = new Set<String>();
                Set<String> devCapIncludes = new Set<String>();
                Set<String> devCapExcludes = new Set<String>();
                List<csdf__Targetable_Targeting_Template__c> targetableTargetingTemplates = targetableTargetingTemplatesByTargetingTemplateId.get(targetingTemplate.Id);
                if (targetableTargetingTemplates != null && !targetableTargetingTemplates.isEmpty()) {
                    for(csdf__Targetable_Targeting_Template__c targetableJunctionObject: targetableTargetingTemplates) {
                        switch on targetableJunctionObject.csdf__Targetable__r.csdf__Type__c {
                            when 'Device Category' {
                                if(targetableJunctionObject.csdf__Exclude__c) {
                                    devCatExcludes.add(((String) targetableJunctionObject.csdf__Targetable__c).substring(0,15));
                                } else {
                                    devCatIncludes.add(((String) targetableJunctionObject.csdf__Targetable__c).substring(0,15));
                                }
                            }
                            when 'Mobile Device', 'Device Manufacturer' { // DeviceManufacturer
                                if(targetableJunctionObject.csdf__Exclude__c) {
                                    devManExcludes.add(((String) targetableJunctionObject.csdf__Targetable__c).substring(0,15));
                                } else {
                                    devManIncludes.add(((String) targetableJunctionObject.csdf__Targetable__c).substring(0,15));
                                }
                            }
                            when 'Mobile Carrier' {
                                if(targetableJunctionObject.csdf__Exclude__c) {
                                    mobCarExcludes.add(((String) targetableJunctionObject.csdf__Targetable__c).substring(0,15));
                                } else {
                                    mobCarIncludes.add(((String) targetableJunctionObject.csdf__Targetable__c).substring(0,15));
                                }
                            }
                            when 'Bandwidth Group' {
                                if(targetableJunctionObject.csdf__Exclude__c) {
                                    bwGroupExcludes.add(((String) targetableJunctionObject.csdf__Targetable__c).substring(0,15));
                                } else {
                                    bwGroupIncludes.add(((String) targetableJunctionObject.csdf__Targetable__c).substring(0,15));
                                }
                            }
                            when 'Device Capability' {
                                if(targetableJunctionObject.csdf__Exclude__c) {
                                    devCapExcludes.add(((String) targetableJunctionObject.csdf__Targetable__c).substring(0,15));
                                } else {
                                    devCapIncludes.add(((String) targetableJunctionObject.csdf__Targetable__c).substring(0,15));
                                }
                            }
                            when else {
                                // pass
                            }
                        }
                    }
                }

                res.put(((String)targetingTemplate.Id).substring(0,15), new Map<String, Object>{
                        'AdSlots' => new Map<String, Object>{
                                INCLUDE_KEYWORD => adSlotsIncl,
                                EXCLUDE_KEYWORD => adSlotsExcl
                        },
                        'KVA' => new Map<String, Object> {
                                JSON_KEYWORD => String.isBlank(targetingTemplate.Key_values_and_Audience_JSON__c) ? null : targetingTemplate.Key_values_and_Audience_JSON__c,
                                QUERY_KEYWORD => String.isBlank(targetingTemplate.Key_values_and_Audience__c) ? null : targetingTemplate.Key_values_and_Audience__c
                        },
                        'Geography' => new Map<String, Object> {
                                INCLUDE_KEYWORD => geoItemIncludes,
                                EXCLUDE_KEYWORD => geoItemExcludes
                        },
                        'Browsers' => new Map<String, Object> {
                                INCLUDE_KEYWORD => browserIncludes,
                                EXCLUDE_KEYWORD => browserExcludes
                        },
                        'OperatingSystems' => new Map<String, Object> {
                                INCLUDE_KEYWORD => osIncludes,
                                EXCLUDE_KEYWORD => osExcludes
                        },
                        'OperatingSystemVersions' => new Map<String, Object> {
                                INCLUDE_KEYWORD => osvIncludes,
                                EXCLUDE_KEYWORD => osvExcludes
                        },
                        'DeviceCategories' => new Map<String, Object> {
                                INCLUDE_KEYWORD => devCatIncludes,
                                EXCLUDE_KEYWORD => devCatExcludes
                        },
                        'DeviceManufacturer' => new Map<String, Object> {
                                INCLUDE_KEYWORD => devManIncludes,
                                EXCLUDE_KEYWORD => devManExcludes
                        },
                        'MobileCarrier' => new Map<String, Object> {
                                INCLUDE_KEYWORD => mobCarIncludes,
                                EXCLUDE_KEYWORD => mobCarExcludes
                        },
                        'BandwidthGroup' => new Map<String, Object> {
                                INCLUDE_KEYWORD => bwGroupIncludes,
                                EXCLUDE_KEYWORD => bwGroupExcludes
                        },
                        'DeviceCapability' => new Map<String, Object> {
                                INCLUDE_KEYWORD => devCapIncludes,
                                EXCLUDE_KEYWORD => devCapExcludes
                        }
                });
            }
        }

        return res;
    }

    public static String saveTargetingTemplate(String name, String adServerId, Map<String, String> data) {
        if(data.get('templateData') == null || data.get('templateType') == null) {
            return null;
        }
        Savepoint sp = Database.setSavepoint();

        String templateType = (String) data.get('templateType');
        csdf__Targeting_Template__c targetingTemplate;

        List<csdf__Targeting_Template__c> targetingTemplates = [
                SELECT Id, Name, csdf__Type__c
                FROM csdf__Targeting_Template__c
                WHERE Name =: name
                    AND csdf__Type__c =: templateType
        ];

        if(targetingTemplates != null && targetingTemplates.size() > 0) {
            targetingTemplate = targetingTemplates[0];
            System.debug('##### Found the existing Targeting template. Id=' + targetingTemplate.Id + '. Cleaning it up...');

            // ad slots
            List<Ad_Slot_Targeting_Template__c> adSlotJunctions = [SELECT Id FROM Ad_Slot_Targeting_Template__c WHERE Targeting_Template__c =: targetingTemplate.Id];
            if(adSlotJunctions != null && adSlotJunctions.size() > 0) { delete adSlotJunctions; }

            // geo items
            List<csdf__Geo_Item_Targeting_Template__c> geoItemJunctions = [SELECT Id FROM csdf__Geo_Item_Targeting_Template__c WHERE csdf__Targeting_Template__c =: targetingTemplate.Id];
            if(geoItemJunctions != null && geoItemJunctions.size() > 0) { delete geoItemJunctions; }

            // browsers
            List<csdf__Browser_Targeting_Template__c> browserJunctions = [SELECT Id FROM csdf__Browser_Targeting_Template__c WHERE csdf__Targeting_Template__c =: targetingTemplate.Id];
            if(browserJunctions != null && browserJunctions.size() > 0) { delete browserJunctions; }

            // os items
            List<csdf__Operating_System_Targeting_Template__c> osJunctions = [SELECT Id FROM csdf__Operating_System_Targeting_Template__c WHERE csdf__Targeting_Template__c =: targetingTemplate.Id];
            if(osJunctions != null && osJunctions.size() > 0) { delete osJunctions; }

            // osv items
            List<csdf__Operating_System_Version_Target_Template__c> osvJunctions = [SELECT Id FROM csdf__Operating_System_Version_Target_Template__c WHERE csdf__Targeting_Template__c =: targetingTemplate.Id];
            if(osvJunctions != null && osvJunctions.size() > 0) { delete osvJunctions; }

            // targetable items
            List<csdf__Targetable_Targeting_Template__c> targetableJunctions = [SELECT Id FROM csdf__Targetable_Targeting_Template__c WHERE csdf__Targeting_Template__c =: targetingTemplate.Id];
            if(targetableJunctions != null && targetableJunctions.size() > 0) { delete targetableJunctions; }

            targetingTemplate.Key_values_and_Audience_JSON__c = null;
            targetingTemplate.Key_values_and_Audience__c = null;

            System.debug('##### Targeting template successfully cleaned...');
        } else {
            targetingTemplate = new csdf__Targeting_Template__c();
            targetingTemplate.Name = name;
            targetingTemplate.csdf__Ad_Server__c = adServerId;
            targetingTemplate.csdf__Type__c = templateType;
            System.debug('##### Targeting template root successfully inserted.');
        }

        Map<String, Object> templateData;

        try {
            templateData = (Map<String, Object>) JSON.deserializeUntyped((String) data.get('templateData'));

            if(templateData.get('KVA') != null) {
                System.debug('##### Parsing KVA data.');
                Map<String, Object> kvaTargeting = (Map<String, Object>) templateData.get('KVA');

                if(kvaTargeting.get(JSON_KEYWORD) != null) {
                    targetingTemplate.Key_values_and_Audience_JSON__c = (String) kvaTargeting.get(JSON_KEYWORD);
                }

                if(kvaTargeting.get(QUERY_KEYWORD) != null) {
                    targetingTemplate.Key_values_and_Audience__c = ((String) kvaTargeting.get(QUERY_KEYWORD));
                }
                System.debug('##### KVA data parsed successfully.');
            } else {
                targetingTemplate.Key_values_and_Audience_JSON__c = null;
                targetingTemplate.Key_values_and_Audience__c = null;
            }

            upsert targetingTemplate;
            System.debug('##### Targeting template root successfully inserted.');
        } catch (Exception e) {
            System.debug('##### Error while trying to insert targeting template root: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }

        try {
            /*
                AD SLOTS
            */
            if(templateData.get('AdSlots') != null) {
                System.debug('##### Parsing AdSlots data.');
                Map<String, Object> adSlotsTargeting = (Map<String, Object>) templateData.get('AdSlots');
                List<Ad_Slot_Targeting_Template__c> adSlotJunctionObjects = new List<Ad_Slot_Targeting_Template__c>();
                if(adSlotsTargeting.get(INCLUDE_KEYWORD) != null) {
                    for(Object adSlotItemInclude: (List<Object>) adSlotsTargeting.get(INCLUDE_KEYWORD)) {
                        if(adSlotItemInclude instanceOf Id) {
                            adSlotJunctionObjects.add(
                                    new Ad_Slot_Targeting_Template__c(
                                            Ad_Slot__c = (Id) adSlotItemInclude,
                                            Targeting_Template__c = targetingTemplate.Id,
                                            Exclude__c = false
                                    )
                            );
                        }
                    }
                }
                if(adSlotsTargeting.get(EXCLUDE_KEYWORD) != null) {
                    for(Object adSlotItemExclude: (List<Object>) adSlotsTargeting.get(EXCLUDE_KEYWORD)) {
                        if(adSlotItemExclude instanceOf Id) {
                            adSlotJunctionObjects.add(
                                    new Ad_Slot_Targeting_Template__c(
                                            Ad_Slot__c = (Id) adSlotItemExclude,
                                            Targeting_Template__c = targetingTemplate.Id,
                                            Exclude__c = true
                                    )
                            );
                        }
                    }
                }
                System.debug('##### Inserting AdSlot junction objects. adSlotJunctionObjects => ' + adSlotJunctionObjects);
                insert adSlotJunctionObjects;
                System.debug('##### AdSlots junction records insert successful...');
            }

            /*
                GEO ITEMS
            */
            if(templateData.get('Geography') != null) {
                System.debug('##### Parsing Geography data.');
                Map<String, Object> geographyTargeting = (Map<String, Object>) templateData.get('Geography');
                List<csdf__Geo_Item_Targeting_Template__c> geoJunctionObjects = new List<csdf__Geo_Item_Targeting_Template__c>();
                if(geographyTargeting.get(INCLUDE_KEYWORD) != null) {
                    for(Object geoItemInclude: (List<Object>) geographyTargeting.get(INCLUDE_KEYWORD)) {
                        if(geoItemInclude instanceOf Id) {
                            geoJunctionObjects.add(
                                    new csdf__Geo_Item_Targeting_Template__c(
                                            csdf__Targeting_Template__c = targetingTemplate.Id,
                                            csdf__Geo_Item__c = (Id) geoItemInclude,
                                            csdf__Exclude__c = false,
                                            csdf__Creative_Targeting_Only__c = true
                                    )
                            );
                        }
                    }
                }

                if(geographyTargeting.get(EXCLUDE_KEYWORD) != null) {
                    for(Object geoItemExclude: (List<Object>) geographyTargeting.get(EXCLUDE_KEYWORD)) {
                        if(geoItemExclude instanceOf Id) {
                            geoJunctionObjects.add(
                                    new csdf__Geo_Item_Targeting_Template__c(
                                            csdf__Targeting_Template__c = targetingTemplate.Id,
                                            csdf__Geo_Item__c = (Id) geoItemExclude,
                                            csdf__Exclude__c = true,
                                            csdf__Creative_Targeting_Only__c = true
                                    )
                            );
                        }
                    }
                }
                System.debug('##### Inserting Geography junction objects. geoJunctionObjects => ' + geoJunctionObjects);
                insert geoJunctionObjects;
                System.debug('##### Successfully inserted Geography junction objects.');
            }

            /*
                BROWSER ITEMS
            */
            if(templateData.get('Browsers') != null) {
                System.debug('##### Parsing Browsers data.');
                Map<String, Object> browserTargeting = (Map<String, Object>) templateData.get('Browsers');
                List<csdf__Browser_Targeting_Template__c> browserJunctionObjects = new List<csdf__Browser_Targeting_Template__c>();
                if(browserTargeting.get(INCLUDE_KEYWORD) != null) {
                    for(Object browserInclude: (List<Object>) browserTargeting.get(INCLUDE_KEYWORD)) {
                        if(browserInclude instanceOf Id) {
                            browserJunctionObjects.add(
                                    new csdf__Browser_Targeting_Template__c(
                                            csdf__Targeting_Template__c = targetingTemplate.Id,
                                            csdf__Browser__c = (Id) browserInclude,
                                            csdf__Exclude__c = false,
                                            csdf__Creative_Targeting_Only__c = true
                                    )
                            );
                        }
                    }
                }

                if(browserTargeting.get(EXCLUDE_KEYWORD) != null) {
                    for(Object browserExclude: (List<Object>) browserTargeting.get(EXCLUDE_KEYWORD)) {
                        if(browserExclude instanceOf Id) {
                            browserJunctionObjects.add(
                                    new csdf__Browser_Targeting_Template__c(
                                            csdf__Targeting_Template__c = targetingTemplate.Id,
                                            csdf__Browser__c = (Id) browserExclude,
                                            csdf__Exclude__c = true,
                                            csdf__Creative_Targeting_Only__c = true
                                    )
                            );
                        }
                    }
                }
                System.debug('##### Inserting Browsers junction objects.');
                insert browserJunctionObjects;
                System.debug('##### Successfully inserted Browsers junction objects.');
            }

            /*
                Operating System ITEMS
            */
            if(templateData.get('OperatingSystems') != null) {
                System.debug('##### Parsing OperatingSystems data.');
                Map<String, Object> osTargeting = (Map<String, Object>) templateData.get('OperatingSystems');
                List<csdf__Operating_System_Targeting_Template__c> osJunctionObjects = new List<csdf__Operating_System_Targeting_Template__c>();
                if(osTargeting.get(INCLUDE_KEYWORD) != null) {
                    for(Object osInclude: (List<Object>) osTargeting.get(INCLUDE_KEYWORD)) {
                        if(osInclude instanceOf Id) {
                            osJunctionObjects.add(
                                    new csdf__Operating_System_Targeting_Template__c(
                                            csdf__Targeting_Template__c = targetingTemplate.Id,
                                            csdf__Operating_System__c = (Id) osInclude,
                                            csdf__Exclude__c = false,
                                            csdf__Creative_Targeting_Only__c = true
                                    )
                            );
                        }
                    }
                }

                if(osTargeting.get(EXCLUDE_KEYWORD) != null) {
                    for(Object osExclude: (List<Object>) osTargeting.get(EXCLUDE_KEYWORD)) {
                        if(osExclude instanceOf Id) {
                            osJunctionObjects.add(
                                    new csdf__Operating_System_Targeting_Template__c(
                                            csdf__Targeting_Template__c = targetingTemplate.Id,
                                            csdf__Operating_System__c = (Id) osExclude,
                                            csdf__Exclude__c = true,
                                            csdf__Creative_Targeting_Only__c = true
                                    )
                            );
                        }
                    }
                }
                System.debug('##### Inserting OperatingSystems junction objects.');
                insert osJunctionObjects;
                System.debug('##### Successfully inserted OperatingSystems junction objects.');
            }

            /*
                Operating System Version ITEMS
            */
            if(templateData.get('OperatingSystemVersions') != null) {
                System.debug('##### Parsing OperatingSystemVersions data.');
                Map<String, Object> osvTargeting = (Map<String, Object>) templateData.get('OperatingSystemVersions');
                List<csdf__Operating_System_Version_Target_Template__c> osvJunctionObjects = new List<csdf__Operating_System_Version_Target_Template__c>();
                if(osvTargeting.get(INCLUDE_KEYWORD) != null) {
                    for(Object osvInclude: (List<Object>) osvTargeting.get(INCLUDE_KEYWORD)) {
                        if(osvInclude instanceOf Id) {
                            osvJunctionObjects.add(
                                    new csdf__Operating_System_Version_Target_Template__c(
                                            csdf__Targeting_Template__c = targetingTemplate.Id,
                                            csdf__Operating_System_Version__c = (Id) osvInclude,
                                            csdf__Exclude__c = false,
                                            csdf__Creative_Targeting_Only__c = true
                                    )
                            );
                        }
                    }
                }

                if(osvTargeting.get(EXCLUDE_KEYWORD) != null) {
                    for(Object osvExclude: (List<Object>) osvTargeting.get(EXCLUDE_KEYWORD)) {
                        if(osvExclude instanceOf Id) {
                            osvJunctionObjects.add(
                                    new csdf__Operating_System_Version_Target_Template__c(
                                            csdf__Targeting_Template__c = targetingTemplate.Id,
                                            csdf__Operating_System_Version__c = (Id) osvExclude,
                                            csdf__Exclude__c = true,
                                            csdf__Creative_Targeting_Only__c = true
                                    )
                            );
                        }
                    }
                }
                System.debug('##### Inserting OperatingSystemVersions junction objects.');
                insert osvJunctionObjects;
                System.debug('##### Successfully inserted OperatingSystemVersions junction objects.');
            }

            /*
                Targetable ITEMS
            */
            if(templateData.get('Targetables') != null) {
                System.debug('##### Parsing Targetables data.');
                Map<String, Object> targetableTargeting = (Map<String, Object>) templateData.get('Targetables');
                List<csdf__Targetable_Targeting_Template__c> targetableJunctionObjects = new List<csdf__Targetable_Targeting_Template__c>();
                if(targetableTargeting.get(INCLUDE_KEYWORD) != null) {
                    for(Object targetableInclude: (List<Object>) targetableTargeting.get(INCLUDE_KEYWORD)) {
                        if(targetableInclude instanceOf Id) {
                            targetableJunctionObjects.add(
                                    new csdf__Targetable_Targeting_Template__c(
                                            csdf__Targeting_Template__c = targetingTemplate.Id,
                                            csdf__Targetable__c = (Id) targetableInclude,
                                            csdf__Exclude__c = false,
                                            csdf__Creative_Targeting_Only__c = true
                                    )
                            );
                        }
                    }
                }

                if(targetableTargeting.get(EXCLUDE_KEYWORD) != null) {
                    for(Object targetableExclude: (List<Object>) targetableTargeting.get(EXCLUDE_KEYWORD)) {
                        if(targetableExclude instanceOf Id) {
                            targetableJunctionObjects.add(
                                    new csdf__Targetable_Targeting_Template__c(
                                            csdf__Targeting_Template__c = targetingTemplate.Id,
                                            csdf__Targetable__c = (Id) targetableExclude,
                                            csdf__Exclude__c = true,
                                            csdf__Creative_Targeting_Only__c = true
                                    )
                            );
                        }
                    }
                }
                System.debug('##### Inserting Targetables junction objects.');
                insert targetableJunctionObjects;
                System.debug('##### Successfully inserted Targetables junction objects.');
            }

            System.debug('##### Targeting template successfully created.');
            return targetingTemplate.Id;
        } catch(Exception e) {
            Database.Rollback(sp);
            System.debug('##### Error while trying to save template: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    public static Map<String, Object> parseDataModel(Map<String, String> data) {
        if(data.get('payload') == null) {
            return null;
        }

        Map<String, Object> res = new Map<String, Object>();
        try {
            Map<String, Object> dataModel = (Map<String, Object>) JSON.deserializeUntyped((String) data.get('payload'));
            for(String key: dataModel.keySet()) {
                if(dataModel.get(key) != null) {
                    Set<String> parsedIds = new Set<String>();
                    List<Object> ids = (List<Object>) dataModel.get(key);

                    for(Object itemId: ids) {
                        if(itemId instanceOf Id) {
                            parsedIds.add(((String)itemId).substring(0, 15));
                        }
                    }
                    res.put(key, parsedIds);
                }
            }
            return res;
        } catch(Exception e) {
            System.debug('##### Error while parsing data model: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }
    }

    // Fetches 
    public static Map<String, String> getAdSlotRootPathNames(List<csdf__Ad_Slot__c> adSlots) {
        Map<String, String> asNames = new Map<String, String>();

        // get Drill Down label by fetching Root_Path__c ids and parsing it to a name
        if(adSlots != null && adSlots.size() > 0) {
            Set<String> adSlotIds = new Set<String>();
            for(csdf__Ad_Slot__c adSlot: adSlots) {
                try {
                    if(String.isNotBlank(adSlot.Root_Path__c)) {
                        for(String asId: adSlot.Root_Path__c.split(',')) {
                            if(asId instanceOf Id) {
                                adSlotIds.add(asId);
                            }
                        }
                    }       
                } catch(Exception e) {
                    System.debug('##### Error while trying to get drilldown name for AdSlot: ' + adSlot.Id);
                }
            }

            // fetch the data required for adSlots drilldown and map their names
            List<csdf__Ad_Slot__c> drillDownAdSlots = MediaTargetingWidgetQueries.getAdSlotsWithParents(null, null, adSlotIds);
            if(drillDownAdSlots != null && drillDownAdSlots.size() > 0) {
                for(csdf__Ad_Slot__c ddas: drillDownAdSlots) {
                    asNames.put(((String)ddas.Id).substring(0,15), ddas.csdf__Name__c);
                }
            }
        }
        return asNames;
    }
}