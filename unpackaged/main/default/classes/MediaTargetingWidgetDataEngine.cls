global with sharing class MediaTargetingWidgetDataEngine {

    public static final Map<String, String> CATEGORIES_TO_TEXT_MAP  = new  Map<String, String>{ // Mapping for geo items hierarchy
            'CITY' => 'City',
            'CITY' => 'City',
            'COUNTRY' => 'Country',
            'COUNTY' => 'County',
            'DMA_REGION' => 'DMA region',
            'STATE' => 'State',
            'AIRPORT' => 'Airport',
            'BOROUGH' => 'Borough',
            'NEIGHBORHOOD'=> 'Neighborhood',
            'PROVINCE' => 'Province',
            'CANTON' => 'Canton',
            'DEPARTMENT' => 'Department',
            'GOVERNORATE' => 'Governorate',
            'PREFECTURE' => 'Prefecture',
            'REGION' => 'Region',
            'TERRITORY' => 'Territory',
            'TV_REGION' => 'TV Region',
            'UNION_TERRITORY' => 'Union Territory',
            'POSTAL_CODE' => 'Postal code'
    };

    // both AdUnits & Placements use Ad Slots object
    public static List<TargetItem> getAdSlotTargetItems(List<csdf__Ad_Slot__c> adSlots) {
        List<TargetItem> res = new List<TargetItem>();
        TargetItem ti;
        if(adSlots != null) {
            // get map of id->name. Used when creating drilldown label from Root Path field
            Map<String, String> adSlotName = new Map<String, String>();
            for(csdf__Ad_Slot__c adSlot: adSlots) {
                adSlotName.put(((String) adSlot.Id).substring(0,15), adSlot.csdf__Name__c);
            }

            for(csdf__Ad_Slot__c adSlot: adSlots) {
                Map<String,Object> parents = new Map<String,Object>();
                if(adSlot.csdf__Ad_Slot_Child_Assignments__r.size() > 0) { // it is child record
                    Set<String> parentIds = new Set<String>();
                    for(csdf__Ad_Slot_Assignment__c assignment: adSlot.csdf__Ad_Slot_Child_Assignments__r) {
                        parentIds.add(((String) assignment.csdf__Ad_Slot_Parent__c).substring(0,15));
                        if(String.isNotBlank(assignment.csdf__Ad_Slot_Parent__r.csdf__Name__c)) {
                            String parentName = assignment.csdf__Ad_Slot_Parent__r.csdf__Name__c;
                            if(String.isNotBlank(assignment.csdf__Ad_Slot_Parent__r.csdf__Type__c)) {
                                parentName += ' [' + assignment.csdf__Ad_Slot_Parent__r.csdf__Type__c + ']';
                            }
                            parents.put(((String) assignment.csdf__Ad_Slot_Parent__c).substring(0,15), parentName);
                        }
                    }
                    ti = new TargetItem(adSlot.Id, adSlot.csdf__Name__c, 'AdSlots', adSlot.csdf__Ad_Slot_Parent_Assignments__r.size() > 0, parentIds);
                } else { // it is root record
                    ti = new TargetItem(adSlot.Id, adSlot.csdf__Name__c, 'AdSlots', adSlot.csdf__Ad_Slot_Parent_Assignments__r.size() > 0, null);
                }
                // ti.data.put('csdf__Sizes__c', adSlot.csdf__Sizes__c);
                ti.data.put('Type', adSlot.csdf__Type__c);
                ti.data.put('ParentName', parents);
                ti.data.put('Root_Path__c', adSlot.Root_Path__c);
                ti.data.put('Premium_Tag__c', adSlot.Premium_Tag__c);

                if(String.isNotBlank(adSlot.Root_Path__c)) {
                    List<String> drillDownName = new List<String>();
                    for(String asId: adSlot.Root_Path__c.split(',')) {
                        if(asId instanceOf Id && String.isNotBlank(adSlotName.get(asId.substring(0,15)))) {
                            drillDownName.add(adSlotName.get(asId.substring(0,15)));
                        }
                    }
                    drillDownName.add(adSlot.csdf__Name__c);

                    ti.data.put('DrillDownName', String.join(drillDownName, ' > '));
                } else {
                    ti.data.put('DrillDownName', adSlot.csdf__Name__c);
                }

                res.add(ti);
            }
        }
        res.sort();
        return res;
    }

    public static List<TargetItem> getAdSlotTargetItemsWithParents(List<csdf__Ad_Slot__c> adSlots, Boolean getDrillDownLabels) {
        List<TargetItem> res = new List<TargetItem>();
        TargetItem ti;
        if(adSlots != null) {
            Map<String, String> rootPathNames;
            if(getDrillDownLabels) {
                rootPathNames = MediaTargetingWidgetDataLoaderHelper.getAdSlotRootPathNames(adSlots);
            }

            for(csdf__Ad_Slot__c adSlot: adSlots) {
                Map<String,Object> parents = new Map<String,Object>();
                if(adSlot.csdf__Ad_Slot_Child_Assignments__r.size() > 0) { // it is child record
                    Set<String> parentIds = new Set<String>();
                    for(csdf__Ad_Slot_Assignment__c assignment: adSlot.csdf__Ad_Slot_Child_Assignments__r) {
                        parentIds.add(((String) assignment.csdf__Ad_Slot_Parent__c).substring(0,15));
                        if(String.isNotBlank(assignment.csdf__Ad_Slot_Parent__r.csdf__Name__c)) {
                            String parentName = assignment.csdf__Ad_Slot_Parent__r.csdf__Name__c;
                            if(String.isNotBlank(assignment.csdf__Ad_Slot_Parent__r.csdf__Type__c)) {
                                parentName += ' [' + assignment.csdf__Ad_Slot_Parent__r.csdf__Type__c + ']';
                            }
                            parents.put(((String) assignment.csdf__Ad_Slot_Parent__c).substring(0,15), parentName);
                        }
                    }
                    ti = new TargetItem(adSlot.Id, adSlot.csdf__Name__c, 'AdSlots', adSlot.csdf__Ad_Slot_Parent_Assignments__r.size() > 0, parentIds);
                } else { // it is root record
                    ti = new TargetItem(adSlot.Id, adSlot.csdf__Name__c, 'AdSlots', adSlot.csdf__Ad_Slot_Parent_Assignments__r.size() > 0, null); 
                }
                // ti.data.put('csdf__Sizes__c', adSlot.csdf__Sizes__c);
                ti.data.put('Type', adSlot.csdf__Type__c);
                ti.data.put('ParentName', parents);
                ti.data.put('Premium_Tag__c', adSlot.Premium_Tag__c);

                if(getDrillDownLabels) {
                    try {
                        if(String.isNotBlank(adSlot.Root_Path__c)) {
                            List<String> drillDownName = new List<String>();
                            for(String asId: adSlot.Root_Path__c.split(',')) {
                                if(asId instanceOf Id && rootPathNames != null) {
                                    String name = rootPathNames.get(((String)asId).substring(0,15));
                                    drillDownName.add(String.isBlank(name) ? '/' : name);
                                }
                            }
                            drillDownName.add(adSlot.csdf__Name__c);
                            ti.data.put('DrillDownName', String.join(drillDownName, ' > '));
                        } else {
                            ti.data.put('DrillDownName', adSlot.csdf__Name__c);
                        }   
                    } catch(Exception e) {
                        System.debug('##### Error while trying to parse drilldown name for AdSlot: ' + adSlot.Id);
                        ti.data.put('DrillDownName', adSlot.csdf__Name__c);
                    }
                }

                res.add(ti);
            }
        }
        res.sort();
        return res;
    }

    public static List<TargetItem> getGeoTargetItems(List<csdf__Geo_Item__c> geoItems) {
        List<TargetItem> res = new List<TargetItem>();
        TargetItem ti;

        if(geoItems != null) {
            for(csdf__Geo_Item__c gi: geoItems) {
                if(gi.csdf__Geo_Item_Child_Assignments__r.size() > 0) {
                    Set<String> parentIds = new Set<String>();
                    for(csdf__Geo_Item_Assignment__c assignment: gi.csdf__Geo_Item_Child_Assignments__r) {
                        parentIds.add(((String) assignment.csdf__Geo_Item_Parent__c).substring(0,15));
                    }
                    ti = new TargetItem(gi.Id, gi.Name, 'Geography', gi.csdf__Geo_Item_Parent_Assignments__r.size() > 0, parentIds);
                } else {
                    ti = new TargetItem(gi.Id, gi.Name, 'Geography', gi.csdf__Geo_Item_Parent_Assignments__r.size() > 0, null);
                }
                ti.data.put('csdf__Ad_Server_Id__c', gi.csdf__Ad_Server_Id__c);
                ti.data.put('csdf__Code__c', gi.csdf__Code__c);
                ti.data.put('Type', 'Geography');
                ti.data.put('csdf__Category__c', gi.csdf__Category__c);
                ti.data.put('Root_Path__c', gi.Root_Path__c);
                ti.data.put('Premium_Tag__c', gi.Premium_Tag__c);
                Map<String,Object> parents = new Map<String,Object>();

                if(gi.csdf__Geo_Item_Child_Assignments__r.size() > 0) {
                    for(csdf__Geo_Item_Assignment__c gia: gi.csdf__Geo_Item_Child_Assignments__r) {
                        parents.put(((String)gia.csdf__Geo_Item_Parent__c).substring(0,15), gia.Geo_Parent_Name__c);
                    }
                }
                ti.data.put('ParentName', parents);
                res.add(ti);
            }
        }
        res.sort();
        return res;
    }

    public static List<TargetItem> getBrowserTargetItems(List<csdf__Browser__c> browsers) {
        List<TargetItem> res = new List<TargetItem>();
        TargetItem ti;
        String browserName;

        if(browsers != null) {
            for(csdf__Browser__c browser: browsers) {
                browserName = browser.csdf__Browser_Name__c + ' ('
                        + (browser.csdf__Major_Version__c == 'Any' ? 'x': (browser.csdf__Major_Version__c == 'Other' ? 'Unknown' : browser.csdf__Major_Version__c))
                        + '.'
                        + (browser.csdf__Minor_Version__c == 'Any' ? 'x': (browser.csdf__Minor_Version__c == 'Other' ? 'Unknown' : browser.csdf__Minor_Version__c))
                        + ')';
                ti = new TargetItem(browser.Id, browserName, 'Browsers', false, null);
                ti.data.put('csdf__Ad_Server_Id__c', browser.csdf__Ad_Server_Id__c);
                // ti.data.put('csdf__Major_Version__c', browser.csdf__Major_Version__c);
                // ti.data.put('csdf__Minor_Version__c', browser.csdf__Minor_Version__c);
                ti.data.put('Premium_Tag__c', browser.Premium_Tag__c);
                res.add(ti);
            }
        }

        res.sort();
        return res;
    }

    /*
     * Method that handles all the targetable custom objects (DeviceCategories, DeviceManufacturer, MobileCarrier...)
     */
    public static List<TargetItem> getTargetableTargetItems(List<csdf__Targetable__c> targetables, String type) {
        List<TargetItem> res = new List<TargetItem>();
        TargetItem ti;

        if(targetables != null) {
            for(csdf__Targetable__c targetable: targetables) {
                if(targetable.Targetable_Parent__c == null) {
                    ti = new TargetItem(targetable.Id, targetable.csdf__Targetable_Name__c, type, targetable.Targetables__r.size() > 0, null);
                } else {
                    ti = new TargetItem(targetable.Id, targetable.csdf__Targetable_Name__c, type, targetable.Targetables__r.size() > 0, new Set<String>{((String) targetable.Targetable_Parent__c).substring(0,15)});
                }
                ti.data.put('csdf__Ad_Server_Id__c', targetable.csdf__Ad_Server_Id__c);
                ti.data.put('Type', targetable.csdf__Type__c);
                ti.data.put('Premium_Tag__c', targetable.Premium_Tag__c);
                res.add(ti);
            }
        }

        res.sort();
        return res;
    }

    public static List<TargetItem> getOperatingSystemTargetItems(List<csdf__Operating_System__c> operatingSystems) {
        List<TargetItem> res = new List<TargetItem>();
        TargetItem ti;

        if(operatingSystems != null) {
            for(csdf__Operating_System__c os : operatingSystems) {
                ti = new TargetItem(os.Id, os.Name, 'OperatingSystems', os.csdf__Operating_System_Versions__r.size() > 0, null);
                ti.data.put('csdf__Ad_Server_Id__c', os.csdf__Ad_Server_Id__c);
                ti.data.put('Type','Operating System');
                ti.data.put('Premium_Tag__c', os.Premium_Tag__c);
                res.add(ti);
            }
        }

        res.sort();
        return res;
    }

    public static List<TargetItem> getOperatingSystemVersionTargetItems(List<csdf__Operating_System_Version__c> operatingSystemVersions) {
        List<TargetItem> res = new List<TargetItem>();
        TargetItem ti;
        String osvName;

        if(operatingSystemVersions != null) {
            for(csdf__Operating_System_Version__c osv: operatingSystemVersions) {
                osvName = osv.csdf__Operating_System__r.Name + ' ' +
                        (osv.csdf__Major_Version__c != '-1' ? osv.csdf__Major_Version__c : 'x' ) + '.' +
                        (osv.csdf__Minor_Version__c != '-1' ? osv.csdf__Minor_Version__c : 'x' ) + '.' +
                        (osv.csdf__Micro_Version__c != '-1' ? osv.csdf__Micro_Version__c : 'x' );
                ti = new TargetItem(osv.Id, osvName, 'OperatingSystems', false, new Set<String>{((String) osv.csdf__Operating_System__c).substring(0,15)});
                ti.data.put('csdf__Ad_Server_Id__c',osv.csdf__Ad_Server_Id__c);
                ti.data.put('Type','Operating System Version');
                ti.data.put('Premium_Tag__c', osv.Premium_Tag__c);
                res.add(ti);
            }
        }

        res.sort();
        return res;
    }

    public static List<TargetItem> getKvaKeysTargetItems(List<csdf__Custom_Targeting_Key__c> kvaKeys) {
        List<TargetItem> res = new List<TargetItem>();
        TargetItem ti;
        if(kvaKeys != null) {
            for(csdf__Custom_Targeting_Key__c key: kvaKeys) {
                ti = new TargetItem(key.Id, key.csdf__Display_Name__c, 'KVA', true, null);
                ti.data.put('csdf__Ad_Server_Id__c', '#' + key.csdf__Ad_Server_Id__c);
                ti.data.put('Type', key.csdf__Type__c);
                ti.data.put('Visibility_Tag__c', key.Visibility_Tag__c);
                ti.data.put('Premium_Tag__c', key.Premium_Tag__c);
                // ti.data.put('UIType', 'key');
                res.add(ti);
            }
        }

        Media_Targeting_Widget_Settings__c settings = Media_Targeting_Widget_Settings__c.getOrgDefaults();
        if(settings != null && settings.Show_Audience_Segment__c == true) {
            ti = new TargetItem(
                    MediaTargetingWidget.AUDIENCE_SEGMENT_KEY,
                    settings.Audience_Segment_Label__c,
                    'KVA',
                    true,
                    null
            );
            ti.data.put('csdf__Ad_Server_Id__c', MediaTargetingWidget.AUDIENCE_SEGMENT_KEY);
            ti.data.put('Type', MediaTargetingWidget.AUDIENCE_SEGMENT_KEY);
            // ti.data.put('UIType', 'key');
            res.add(ti);
        }
        res.sort();
        return res;
    }

    // when KVA parent is Audience Segment
    public static List<TargetItem> getKvaAudienceValueTargetItems(List<csdf__Targetable__c> audienceValues) {
        List<TargetItem> res = new List<TargetItem>();
        TargetItem ti;

        if(audienceValues != null) {
            for(csdf__Targetable__c audience: audienceValues) {
                ti = new TargetItem(audience.Id, audience.csdf__Targetable_Name__c, 'KVA', false, new Set<String>{MediaTargetingWidget.AUDIENCE_SEGMENT_KEY});
                ti.data.put('csdf__Ad_Server_Id__c', audience.csdf__Ad_Server_Id__c);
                // ti.data.put('UIType', 'value');
                ti.data.put('Premium_Tag__c', audience.Premium_Tag__c);
                res.add(ti);
            }
        }
        res.sort();
        return res;
    }

    // when KVA parent is NOT Audience Segment
    public static List<TargetItem> getKvaValueTargetItems(List<csdf__Custom_Targeting_Value__c> kvaValues) {
        List<TargetItem> res = new List<TargetItem>();
        TargetItem ti;

        if(kvaValues != null) {
            for(csdf__Custom_Targeting_Value__c val: kvaValues) {
                ti = new TargetItem(val.Id, val.csdf__Display_Name__c, 'KVA', false, new Set<String>{((String) val.csdf__Custom_Targeting_Key__c).substring(0,15)});
                ti.data.put('csdf__Ad_Server_Id__c', '#' + val.csdf__Ad_Server_Id__c);
                // ti.data.put('UIType', 'value');
                ti.data.put('Premium_Tag__c', val.Premium_Tag__c);
                res.add(ti);
            }
        }
        res.sort();
        return res;
    }

    public static TargetItem getZipTargetItem(csdf__Geo_Item__c zipItem) {
        TargetItem ti = new TargetItem(zipItem.Id, zipItem.Name, 'Geography');
        ti.data.put('csdf__Ad_Server_Id__c', zipItem.csdf__Ad_Server_Id__c);
        ti.data.put('csdf__Code__c', zipItem.csdf__Code__c);
        ti.data.put('Type', 'Geography');
        ti.data.put('csdf__Category__c', zipItem.csdf__Category__c);
        ti.data.put('Root_Path__c', zipItem.Root_Path__c);
        ti.data.put('Premium_Tag__c', zipItem.Premium_Tag__c);
        // ti.data.put('UserType', CATEGORIES_TO_TEXT_MAP.get(zipItem.csdf__Category__c));

        return ti;
    }

    global class TargetItem implements Comparable {
        public String id;
        public String name;
        public String type;
        public Boolean hasChildren;
        public String parent;
        public Map<String, Object> data;

        public TargetItem(String id, String name, String type) {
            if(id.equals(MediaTargetingWidget.AUDIENCE_SEGMENT_KEY)) {
                this.id = id;
            } else {
                this.id = id.substring(0,15);
            }
            this.name = name;
            this.type = type;
            this.hasChildren = false;
            this.parent = null;
            this.data = new Map<String, Object>();
            // this.data.put('readOnlyInclude', false); // not read-only by default
            // this.data.put('readOnlyExclude', false); // not read-only by default
            // this.data.put('hiddenInclude', true); // not hidden by default
            // this.data.put('hiddenExclude', true); // not hidden by default
        }

        public TargetItem(String id, String name, String type, Boolean hasChildren, Set<String> parent) {
            if(id.equals(MediaTargetingWidget.AUDIENCE_SEGMENT_KEY)) {
                this.id = id;
            } else {
                this.id = id.substring(0,15);
            }
            this.name = name;
            this.type = type;
            this.hasChildren = hasChildren;
            if(parent != null) {
                this.parent = String.join(new List<String>(parent), ',');
            } else {
                this.parent = null;
            }
            this.data = new Map<String, Object>();
            // this.data.put('readOnlyInclude', false); // not read-only by default
            // this.data.put('readOnlyExclude', false); // not read-only by default
            // this.data.put('hiddenInclude', true); // not hidden by default
            // this.data.put('hiddenExclude', true); // not hidden by default
        }

        public Integer compareTo(Object obj) {
            TargetItem otherTi = (TargetItem) obj;
            return name.toLowerCase().compareTo(otherTi.name.toLowerCase());
        }
    }
}