global with sharing class MediaTargetingWidget {

    public static final String AUDIENCE_SEGMENT_KEY = 'Audience Segment'; // Audience segment is Targetable object with csdf__Type__c of 'Audience Segment'

    @RemoteAction
    global static String performAction(String parameters) {
        TargetRequest req;
        try {
            req = (TargetRequest) JSON.deserialize(parameters, TargetRequest.class);
        } catch(Exception e) {
            System.debug('##### Error while deserializing request: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
            return null;
        }

        /*
            Possible Target Types:
                1) InitialData --> Returns sections along with initial data and templates (if asked for)
                2) Sections --> Returns all MTW sections declared in Custom Settings: 'Media Targeting Widget Sections'
                3) LoadData --> Loads all the requested data. Returns Data Response Model
                4) TemplateList --> Loads list of available templates
                5) TemplateLoad --> Loads templates
                6) TemplateSave --> Saves template
                7) LoadMultiple --> Loads multiple item types
                8) AdSlots --> loads all Ad Slots (Ad Units & Placements)
                9) KVA --> key-values and audience
                10) Geography --> Geo items
                11) Browsers --> Browsers with their versions
                12) DeviceCategories
                13) DeviceManufacturer
                14) OperatingSystems
                15) MobileCarrier
                16) ZipCodes
                17) BandwidthGroup
                18) DeviceCapability

            Possible keys for Data Request Mode when using LoadData keyword:
                1) AdSlots --> csdf__Ad_Slot__c
                2) Browsers --> csdf__Browser__c
                3) DeviceCategories --> csdf__Targetable__c
                4) DeviceManufacturer --> csdf__Targetable__c
                5) MobileCarrier --> csdf__Targetable__c
                6) Geography --> csdf__Geo_Item__c
                7) OperatingSystems --> csdf__Operating_System__c
                8) OperatingSystemVersions --> csdf__Operating_System_Version__c
                9) KvaKeys --> csdf__Custom_Targeting_Key__c
                10) KvaValues --> csdf__Custom_Targeting_Value__c
                11) KvaAudienceValues --> csdf__Targetable__c
                12) BandwidthGroup --> csdf__Targetable__c
                13) DeviceCapability --> csdf__Targetable__c

            Data Request Model:
            {
                'Key_1': [Id_1, Id_2, ...],
                'Key_2': [...],
                ...
            }

            Data Response Model:
            {
                'Key_1': [Id_1, Id_2, ...],
                'Key_2': [...],
                ...
                data: {
                    TargetItem1.Id: TargetItem1,
                    TargetItem2.Id: TargetItem2,
                    ...
                }
            }

            Response Example: (Request is the same, but without data map)
            {
                AdSlots: [1234, 5678],
                Browsers: [abcd, efgh],
                ...
                data: {
                    1234: TargetItem1234,
                    5678: TargetItem5678,
                    abcd: TargetItemabcd,
                    efgh: TargetItemefgh
                }
            }
        */

        switch on req.targetType {
            when 'InitialData' {
                // Loads initial data, along with the requested templates
                // if adServer is not provided, use the one from custom settings
                /*
                    Request example:
                    {
                        targetType: 'InitialData',
                        parent: null,
                        adServer: null,
                        getAllSubItemsAtOnce: null,
                        data: {
                            targetingTemplates: []
                        }
                    }

                    Response Example:
                    {
                        showKvaIds: true,
                        defaultAdServerId: 'dwja...213edc',
                        templateData: {
                            // See TemplateLoad response example
                        }
                    }
                */
                Media_Targeting_Widget_Settings__c settings = Media_Targeting_Widget_Settings__c.getOrgDefaults();
                Map<String, Object> res = new Map<String, Object>();
                if(settings != null) {
                    res.put('showKvaIds', settings.Show_KeyValue_Ids_Instead_Of_Names__c);
                    res.put('defaultAdServerId', settings.Default_Ad_Server_Id__c);
                    res.put('midRollCount', settings.Video_Settings_Available_Mid_Roll_AdPods__c);
                    res.put('positionsWithinPod', settings.Video_Settings_Ad_Pod_Position__c);
                }

                return JSON.serialize(
                        new InitialData(
                                getSectionsList(),
                                res,
                                MediaTargetingWidgetDataLoader.loadTemplate(req.data)
                        )
                );
            }
            when 'Sections' {
                return JSON.serialize(getSectionsList());
            }
            when 'LoadData' {
                // Loads all the requested data
                // Input: Data Request Model
                // Output: Data Response Model
                /*
                    Request example:
                    {
                        targetType: 'LoadData',
                        parent: null,
                        adServer: null,
                        getAllSubItemsAtOnce: null,
                        data: {
                            payload: JSON.stringify(<Data Request Model>) // [String] Has to be JSON.stringify-ed
                            marker: 'any marker' // [string] optional marker to be added to TargetItem.data (if provided)
                        }
                    }
                */
                return MediaTargetingWidgetDataLoader.getData(req.data);
            }
            when 'TemplateList' {
                // used for loading list of targeting templates
                // Input: Template Name (what user started typing)
                // Output: List of templates
                /*
                    Request example:
                    {
                        targetType: 'TemplateList',
                        parent: <Template Name>,
                        adServer: <Ad Server Id>,
                        getAllSubItemsAtOnce: null,
                        data: {
                            templateType: 'Ad Slot' // Possible values: csdf__Type__c picklist values
                        }
                    }
                */
                if(req.data == null || req.data.get('templateType') == null) {
                    System.debug('##### TemplateList data is invalid. Expected data.templateType property...');
                    return JSON.serialize(new List<Object>()); // empty list
                } else {
                    return JSON.serialize(MediaTargetingWidgetQueries.getTargetingTemplatesList(req.parent, req.adServer, (String) req.data.get('templateType')));
                }
            }
            when 'TemplateLoad' {
                // Loads AdSlot & Targeting templates
                // Input: list of ids for required targetingTemplates
                // Output: See Response example
                /*
                    Request example:
                    {
                        targetType: 'TemplateLoad',
                        parent: null,
                        adServer: 'd3iu2f...dwa',
                        getAllSubItemsAtOnce: null,
                        data: {
                            targetingTemplates: ['dwa..2dwa']
                        }
                    }
                    Response example:
                    {
                        targetingTemplates: ['dwa..2dwa'],
                        template: {
                            dwa..2dwa: {
                                'AdSlots': {
                                    include: [1234..ab],
                                    exclude: [dwavc2..ab]
                                },
                                'Browsers': {
                                    include: [],
                                    exclude: []
                                }
                            }
                        }
                    }
                */
                return JSON.serialize(MediaTargetingWidgetDataLoader.loadTemplate(req.data));
            }
            when 'TemplateSave' {
                // used for saving Template attachment
                // Input: Template Name
                // Output: Template Id (success) / null (failure)
                /*
                    Request example:
                    {
                        targetType: 'TemplateSave',
                        parent: <Template Name>,
                        adServer: <Ad Server Id>,
                        getAllSubItemsAtOnce: null,
                        data: {
                            templateType: 'Ad Slot' // Possible values: csdf__Type__c picklist values
                            templateData: <data> [String], // Has to be JSON.stringify-ed { JSON.stringify(data) }
                        }
                    }

                    Template Data Example:
                        Available keys:
                            KVA,
                            AdSlots,
                            Geography,
                            Browsers,
                            OperatingSystems,
                            OperatingSystemVersions,
                            Targetables (DeviceCategories, DeviceManufacturer, MobileCarrier, BandwidthGroup, DeviceCapability)
                        {
                            KVA: {
                                JSON: '<JSON.stringifyed KVA JSON>',
                                query: '...query string...'
                            },
                            AdSlots: {
                                include: ['dawk2e23...r4'],
                                exclude: []
                            },
                            Geography: {
                                include: ['dawk2ed223...r4'],
                                exclude: []
                            },
                            Targetables: {
                                include: ['23dec...r4'],
                                exclude: ['23dec...r3']
                            }
                        }
                */
                return MediaTargetingWidgetDataLoader.saveTemplate(req.parent, req.adServer, req.data);
            }
            when 'LoadMultiple' {
                /*
                    Input Example:
                    {
                        targetType: 'LoadMultiple'
	                    parent: null,
	                    adServer: null,
                        getAllSubItemsAtOnce: null,
                        data: {
                            items: JSON.stringify([ // [String] has to be JSON.stringifyed
                                {
                                    targetType: 'AdSlots'
                                    parent: null,
                                    adServer: <Ad Server Id>,
                                    getAllSubItemsAtOnce: true,
                                    data: {}
                                },
                                {
                                    targetType: 'Browsers'
                                    parent: null,
                                    adServer: <Ad Server Id>,
                                    getAllSubItemsAtOnce: false,
                                    data: {}
                                }
                            ])
                        }
                    }

                    Output: Map with list of target items per each category
                    {
                        'AdSlots': [TargetItem1, TargetItem2, ...],
                        'Browsers': [TargetItem3, ...],
                        ...
                    }
                */
                try {
                    if(req.data.get('items') == null) {
                        return JSON.serialize(new Map<String, Object>());
                    }

                    Map<String, List<MediaTargetingWidgetDataEngine.TargetItem>> res = new Map<String, List<MediaTargetingWidgetDataEngine.TargetItem>>();
                    List<TargetRequest> requests = (List<TargetRequest>) JSON.deserialize(req.data.get('items'), List<TargetRequest>.class);
                    for(TargetRequest tr: requests) {
                        switch on tr.targetType {
                            when 'AdSlots' {
                                res.put('AdUnits', getAdSlots(tr));
                            }
                            when 'Geography' {
                                res.put('Geography', getGeography(tr));
                            }
                            when 'Browsers' {
                                res.put('Browsers', getBrowsers(tr));
                            }
                            when 'DeviceCategories' {
                                res.put('DeviceCategories', getDeviceCategories(tr));
                            }
                            when 'DeviceManufacturer' {
                                res.put('DeviceManufacturer', getDeviceManufacturer(tr));
                            }
                            when 'MobileCarrier' {
                                res.put('MobileCarrier', getMobileCarrier(tr));
                            }
                            when 'OperatingSystems' {
                                res.put('OperatingSystems', getOperatingSystems(tr));
                            }
                            when 'KVA' {
                                res.put('KVA', getKVA(tr));
                            }
                            when 'ZipCodes' {
                                res.put('ZipCodes', getZipCodes(tr));
                            }
                            when 'BandwidthGroup' {
                                res.put('BandwidthGroup', getBandwidthGroup(tr));
                            }
                            when 'DeviceCapability' {
                                res.put('DeviceCapability', getDeviceCapability(tr));
                            }
                            when else {
                                // pass
                            }
                        }
                    }
                    return JSON.serialize(res);
                } catch(Exception e) {
                    System.debug('##### Error while deserializing LoadMultiple request: ' + e.getMessage() + ' [' + e.getLineNumber() + ']');
                    return null;
                }
            }
            /*
                Request example:
                {
                    targetType: 'AdSlots' / 'Geography' / 'Browsers' / ...
                    parent: null,
                    adServer: <Ad Server Id>,
                    getAllSubItemsAtOnce: null,
                    data: null
                }
            */
            when 'AdSlots' {
                return JSON.serialize(getAdSlots(req));
            }
            when 'Geography' {
                return JSON.serialize(getGeography(req));
            }
            when 'Browsers' {
                return JSON.serialize(getBrowsers(req));
            }
            when 'DeviceCategories' {
                return JSON.serialize(getDeviceCategories(req));
            }
            when 'DeviceManufacturer' {
                return JSON.serialize(getDeviceManufacturer(req));
            }
            when 'MobileCarrier' {
                return JSON.serialize(getMobileCarrier(req));
            }
            when 'OperatingSystems' {
                return JSON.serialize(getOperatingSystems(req));
            }
            when 'KVA' {
                return JSON.serialize(getKVA(req));
            }
            when 'ZipCodes' {
                return JSON.serialize(getZipCodes(req));
            }
            when 'BandwidthGroup' {
                return JSON.serialize(getBandwidthGroup(req));
            }
            when 'DeviceCapability' {
                return JSON.serialize(getDeviceCapability(req));
            }
            when else {
                System.debug('##### Request targetType [' + req.targetType + '] not found.');
                return JSON.serialize(new List<Object>());
            }
        }
    }




    // Data gathering methods



    public static List<MediaTargetingWidgetDataEngine.TargetItem> getAdSlots(TargetRequest req) {
        // Handles AdUnits & Placements
        // distinction is csdf__Type__c = {AdUnits/Placements (Roots), AdUnit/Placement (Items)}

        // req.data.loadType='missingParents' used for lazy loading the AdSlots with 'missing parents' feature
        if(req.data != null && (String) req.data.get('loadType') == 'missingParents') {
            // Advance
            List<csdf__Ad_Slot__c> adSlots = MediaTargetingWidgetQueries.getAdSlotsWithParents(req.adServer, req.parent, null);

            if(req.parent != null && adSlots != null) {
                // fetch missing parents
                Set<String> missingParents = new Set<String>();
                for(csdf__Ad_Slot__c adSlot: adSlots) {
                    if(adSlot.csdf__Ad_Slot_Child_Assignments__r.size() > 0) { 
                        for(csdf__Ad_Slot_Assignment__c assignment: adSlot.csdf__Ad_Slot_Child_Assignments__r) {
                            missingParents.add(assignment.csdf__Ad_Slot_Parent__c);
                        }
                    }
                }
                List<csdf__Ad_Slot__c> adSlotMissingParents = MediaTargetingWidgetQueries.getAdSlotsWithParents(null, null, missingParents);
                if(adSlotMissingParents != null) {
                    adSlots.addAll(adSlotMissingParents);
                }
            }

            return MediaTargetingWidgetDataEngine.getAdSlotTargetItemsWithParents(adSlots, false);
        } else {
            // Spotify
            List<csdf__Ad_Slot__c> adSlots;
            if(req.getAllSubItemsAtOnce == true) {
                adSlots = MediaTargetingWidgetQueries.getAdSlots(req.adServer, req.parent, null, true);
            } else {
                adSlots = MediaTargetingWidgetQueries.getAdSlots(req.adServer, req.parent, null, false);
            }
            return MediaTargetingWidgetDataEngine.getAdSlotTargetItems(adSlots);
        }
    }

    public static List<MediaTargetingWidgetDataEngine.TargetItem> getGeography(TargetRequest req) {
        Set<String> availableGeoCatsRoot;
        List<csdf__Geo_Item__c> geoItems;

        if(req.data != null && String.isNotBlank(req.data.get('query'))) {
            // apexSearch method
            geoItems = MediaTargetingWidgetQueries.searchGeography(req.adServer, req.data.get('query'));

            // get all parents hierarchy
            Set<String> parentsToFetch = new Set<String>();
            Integer circularSecurity = 5; // security if we have circular dependency among geo items
            for(csdf__Geo_Item__c gi: geoItems) {
                if(gi.csdf__Geo_Item_Child_Assignments__r.size() > 0) {
                    for(csdf__Geo_Item_Assignment__c assignment: gi.csdf__Geo_Item_Child_Assignments__r) {
                        parentsToFetch.add(assignment.csdf__Geo_Item_Parent__c);
                    }
                }
            }

            while(parentsToFetch.size() > 0 && circularSecurity-- > 0) {
                List<csdf__Geo_Item__c> geoParents = MediaTargetingWidgetQueries.getGeography(null, null, null, parentsToFetch);
                if(geoParents != null && geoParents.size() > 0) {
                    geoItems.addAll(geoParents);

                    parentsToFetch = new Set<String>();
                    for(csdf__Geo_Item__c gi: geoParents) {
                        if(gi.csdf__Geo_Item_Child_Assignments__r.size() > 0) {
                            for(csdf__Geo_Item_Assignment__c assignment: gi.csdf__Geo_Item_Child_Assignments__r) {
                                parentsToFetch.add(assignment.csdf__Geo_Item_Parent__c);
                            }
                        }
                    }
                } else {
                    break;
                }
            }
        } else if(req.parent == null) {
            // user is in root geography level. Load All countries
            availableGeoCatsRoot = new Set<String>{'COUNTRY'};
            // Loading Countries
            geoItems = MediaTargetingWidgetQueries.getGeography(req.adServer, null, availableGeoCatsRoot, null);
        } else {
            // ignore getAllSubitemsAtOnce flag
            // return only children of current parent
            availableGeoCatsRoot = MediaTargetingWidgetQueries.ALL_GEO_CATS;
            geoItems = MediaTargetingWidgetQueries.getGeography(req.adServer, req.parent, availableGeoCatsRoot, null);
        }
        return MediaTargetingWidgetDataEngine.getGeoTargetItems(geoItems);
    }

    // Method that's not being used due to the big ammount of geo data
    public static List<csdf__Geo_Item__c> getGeographySubitems(String adServer, String parent) {
        Set<String> availableGeoCatsRoot = MediaTargetingWidgetQueries.ALL_GEO_CATS;
        // get first level of children
        List<csdf__Geo_Item__c> geoSubItems = MediaTargetingWidgetQueries.getGeography(adServer, parent, availableGeoCatsRoot, null);
        Set<String> itemsToFetch = new Set<String>();

        if(geoSubItems != null) {
            // prepare list of requested next level children
            for(csdf__Geo_Item__c childItem: geoSubItems) {
                for(csdf__Geo_Item_Assignment__c gia: childItem.csdf__Geo_Item_Parent_Assignments__r) {
                    itemsToFetch.add(gia.csdf__Geo_Item_Child__c);
                }
            }

            // fetch every next sub-item level
            while(itemsToFetch.size() > 0) {
                List<csdf__Geo_Item__c> currentItems = MediaTargetingWidgetQueries.getGeography(adServer, null, null, itemsToFetch);
                itemsToFetch = new Set<String>(); // reset items to fetch

                if(currentItems != null) {
                    geoSubItems.addAll(currentItems); // add all items to global list of items
                    for(csdf__Geo_Item__c childItem: currentItems) { // fill list of next-level child items
                        for(csdf__Geo_Item_Assignment__c gia: childItem.csdf__Geo_Item_Parent_Assignments__r) {
                            itemsToFetch.add(gia.csdf__Geo_Item_Child__c);
                        }
                    }
                } else {
                    break;
                }
            }
            return geoSubItems;
        } else {
            return new List<csdf__Geo_Item__c>();
        }
    }

    public static List<MediaTargetingWidgetDataEngine.TargetItem> getBrowsers(TargetRequest req) {
        // Browsers don't have children elements -> ignore req.getAllSubItemsAtOnce
        List<csdf__Browser__c> browsers = MediaTargetingWidgetQueries.getBrowsers(req.adServer, null);
        return MediaTargetingWidgetDataEngine.getBrowserTargetItems(browsers);
    }

    public static List<MediaTargetingWidgetDataEngine.TargetItem> getDeviceCategories(TargetRequest req) {
        List<csdf__Targetable__c> deviceCategories;
        if(req.getAllSubItemsAtOnce == true) {
            deviceCategories = MediaTargetingWidgetQueries.getDeviceCategories(req.adServer, req.parent, null, true);
        } else {
            deviceCategories = MediaTargetingWidgetQueries.getDeviceCategories(req.adServer, req.parent, null, false);
        }
        return MediaTargetingWidgetDataEngine.getTargetableTargetItems(deviceCategories, 'DeviceCategories');
    }

    public static List<MediaTargetingWidgetDataEngine.TargetItem> getDeviceManufacturer(TargetRequest req) {
        List<csdf__Targetable__c> deviceMan;
        if(req.getAllSubItemsAtOnce == true) {
            deviceMan = MediaTargetingWidgetQueries.getDeviceManufacturers(req.adServer, req.parent, null, true);
        } else {
            deviceMan = MediaTargetingWidgetQueries.getDeviceManufacturers(req.adServer, req.parent, null, false);
        }

        return MediaTargetingWidgetDataEngine.getTargetableTargetItems(deviceMan, 'DeviceManufacturer');
    }

    public static List<MediaTargetingWidgetDataEngine.TargetItem> getMobileCarrier(TargetRequest req) {
        List<csdf__Targetable__c> mobileCarriers;
        if(req.getAllSubItemsAtOnce == true) {
            mobileCarriers = MediaTargetingWidgetQueries.getMobileCarriers(req.adServer, req.parent, null, true);
        } else {
            mobileCarriers = MediaTargetingWidgetQueries.getMobileCarriers(req.adServer, req.parent, null, false);
        }
        return MediaTargetingWidgetDataEngine.getTargetableTargetItems(mobileCarriers, 'MobileCarrier');
    }

    public static List<MediaTargetingWidgetDataEngine.TargetItem> getOperatingSystems(TargetRequest req) {
        // two levels of hierarchy: Operating Systems -> Operating System Versions
        if(req.getAllSubItemsAtOnce == true) {
            // get all items
            List<MediaTargetingWidgetDataEngine.TargetItem> items = new List<MediaTargetingWidgetDataEngine.TargetItem>();

            // getting the operating systems
            List<csdf__Operating_System__c> operatingSystems = MediaTargetingWidgetQueries.getOperatingSystems(req.adServer, null);
            items.addAll(MediaTargetingWidgetDataEngine.getOperatingSystemTargetItems(operatingSystems));

            // getting the operating system versions
            List<csdf__Operating_System_Version__c> operatingSystemVersions = MediaTargetingWidgetQueries.getOperatingSystemVersions(req.adServer, req.parent, null, true);
            items.addAll(MediaTargetingWidgetDataEngine.getOperatingSystemVersionTargetItems(operatingSystemVersions));

            return items;
        } else {
            // get only requested items
            if(String.isBlank(req.parent)) {
                // get operating systems
                List<csdf__Operating_System__c> operatingSystems = MediaTargetingWidgetQueries.getOperatingSystems(req.adServer, null);
                return MediaTargetingWidgetDataEngine.getOperatingSystemTargetItems(operatingSystems);
            } else {
                // get operating system versions for selected operating system
                List<csdf__Operating_System_Version__c> operatingSystemVersions = MediaTargetingWidgetQueries.getOperatingSystemVersions(req.adServer, req.parent, null, false);
                return MediaTargetingWidgetDataEngine.getOperatingSystemVersionTargetItems(operatingSystemVersions);
            }
        }
    }

    public static List<MediaTargetingWidgetDataEngine.TargetItem> getKVA(TargetRequest req) {
        if(String.isEmpty(req.parent)) {
            // load available keys (and Audience Segment if defined in custom settings)
            List<csdf__Custom_Targeting_Key__c> kvaKeys = MediaTargetingWidgetQueries.getKvaKeys(req.adServer, null);
            return MediaTargetingWidgetDataEngine.getKvaKeysTargetItems(kvaKeys);
        } else {
            // load values for given parent
            if(req.parent.equals(AUDIENCE_SEGMENT_KEY)) {
                // load audience segment values, Audience segment is Targetable object with csdf__Type__c of 'Audience Segment'
                List<csdf__Targetable__c> audienceValues = MediaTargetingWidgetQueries.getKvaAudienceValues(req.adServer, AUDIENCE_SEGMENT_KEY, null);
                return MediaTargetingWidgetDataEngine.getKvaAudienceValueTargetItems(audienceValues);
            } else {
                // load values for parent which is not audience segment
                List<csdf__Custom_Targeting_Value__c> kvaValues = MediaTargetingWidgetQueries.getKvaValues(req.parent, null);
                return MediaTargetingWidgetDataEngine.getKvaValueTargetItems(kvaValues);
            }
        }
    }

    public static List<MediaTargetingWidgetDataEngine.TargetItem> getZipCodes(TargetRequest req) {
        List<MediaTargetingWidgetDataEngine.TargetItem> res = new List<MediaTargetingWidgetDataEngine.TargetItem>();
        MediaTargetingWidgetDataEngine.TargetItem ti;

        Set<String> ZIP_CODE_CATEGORIES = new Set<String> {'POSTAL_CODE'};
        String CODE_US = 'US';
        String CODE_CANADA = 'CA';

        if(req.data.get('searchText') != null) {
            Set<String> countryCodes = new Set<String>();
            Set<String> zipCodes = new Set<string>();

            Set<String> enteredItems = new Set<string>();
            // split multiple inputs (example: IN/9011, GB/SW15) CountryCode/ZipCode
            // IN/9011 --> IN is country code(csdf__Code__c), 9011 is zip code(Name)
            List<String> inputs = ((String) req.data.get('searchText')).split(',');
            String tmpZip;
            List<String> tmpZipArray;
            Boolean usCaAdded = false; // US and CA can have inputs like: 8542, CA154

            //get all postcodes with from all countries and then sort it out to have single soql
            for(string zi : inputs){
                tmpZip = zi.trim().toUpperCase();
                enteredItems.add(tmpZip);
                tmpZipArray = tmpZip.split('/');
                //US & CA allow zip only (normal zip example: IN/9011. US/CA zip example: CA123)
                if(tmpZipArray.size() > 1){
                    countryCodes.add(tmpZipArray[0]);
                    zipCodes.add(tmpZipArray[1]);
                }
                else if(!tmpZipArray.isEmpty()){
                    if(!usCaAdded){
                        countryCodes.add(CODE_US);
                        countryCodes.add(CODE_CANADA);
                        usCaAdded = true;
                    }
                    zipCodes.add(tmpZipArray[0]);
                }
            }

            List<csdf__Geo_Item__c> zipItems = MediaTargetingWidgetQueries.getZipItems(req.adServer, ZIP_CODE_CATEGORIES, zipCodes, countryCodes);
            if(zipItems != null) {
                String tmpKey;
                for(csdf__Geo_Item__c geo : zipItems) {
                    tmpKey = geo.csdf__Code__c.trim() + '/' + geo.Name.trim();
                    if(!enteredItems.contains(tmpKey)){
                        //if US or CA try w/o country
                        if(geo.csdf__Code__c == CODE_US || geo.csdf__Code__c == CODE_CANADA){
                            tmpKey = geo.Name.trim();
                            if(!enteredItems.contains(tmpKey)){//not found
                                continue;
                            }
                        }
                        else {//not found
                            continue;
                        }
                    }
                    res.add(MediaTargetingWidgetDataEngine.getZipTargetItem(geo));
                }
            }
        }

        res.sort();
        return res;
    }

    public static List<MediaTargetingWidgetDataEngine.TargetItem> getBandwidthGroup(TargetRequest req) {
        List<csdf__Targetable__c> bandwidthGroups;
        if(req.getAllSubItemsAtOnce == true) {
            bandwidthGroups = MediaTargetingWidgetQueries.getBandwidthGroup(req.adServer, req.parent, null, true);
        } else {
            bandwidthGroups = MediaTargetingWidgetQueries.getBandwidthGroup(req.adServer, req.parent, null, false);
        }
        return MediaTargetingWidgetDataEngine.getTargetableTargetItems(bandwidthGroups, 'BandwidthGroup');
    }

    public static List<MediaTargetingWidgetDataEngine.TargetItem> getDeviceCapability(TargetRequest req) {
        List<csdf__Targetable__c> deviceCapabilities;
        if(req.getAllSubItemsAtOnce == true) {
            deviceCapabilities = MediaTargetingWidgetQueries.getDeviceCapability(req.adServer, req.parent, null, true);
        } else {
            deviceCapabilities = MediaTargetingWidgetQueries.getDeviceCapability(req.adServer, req.parent, null, false);
        }
        return MediaTargetingWidgetDataEngine.getTargetableTargetItems(deviceCapabilities, 'DeviceCapability');
    }

    public static List<TargetSection> getSectionsList() {
        List<TargetSection> response = new List<TargetSection>();
        List<Media_Targeting_Widget_Sections__c> sections = [
                SELECT Name,
                        Label__c,
                        Attribute_Name__c,
                        Auto_Update_Configuration__c,
                        Order__c,
                        Include_Exclude_Logic_Type__c,
                        Parent_Section__c,
                        Tabs_List__c
                FROM Media_Targeting_Widget_Sections__c
                ORDER BY Parent_Section__c, Order__c ASC
        ];
        if(sections != null) {
            for(Media_Targeting_Widget_Sections__c sec: sections) {
                response.add(new TargetSection(sec));
            }
        }
        return response;
    }

    global class TargetRequest{
        public String targetType; // sections/ preload / any section type
        public String parent; // if null, roots. If not null, parent is selected
        public String adServer; // ad server id
        public Boolean getAllSubItemsAtOnce; // true / false
        public Map<String, String> data; // additional data
    }

    global class InitialData {
        public List<TargetSection> sections;
        public Map<String, Object> data;
        public Map<String, Object> templateData;

        public InitialData(List<TargetSection> sections, Map<String, Object> data, Map<String, Object> templateData) {
            this.sections = sections;
            this.data = data;
            this.templateData = templateData;
        }
    }

    global class TargetSection {
        public String name;
        public String label;
        public String attribute;
        public Boolean autoUpdateConfig;
        public Decimal order;
        public Decimal includeExcludeType;
        public String parentSection;
        public List<String> tabsList;

        public TargetSection(Media_Targeting_Widget_Sections__c mtws) {
            this.name = mtws.Name;
            this.label = mtws.Label__c;
            this.attribute = mtws.Attribute_Name__c;
            this.autoUpdateConfig = mtws.Auto_Update_Configuration__c;
            this.order = mtws.Order__c;
            this.includeExcludeType = mtws.Include_Exclude_Logic_Type__c == null ? 0 : mtws.Include_Exclude_Logic_Type__c; // optional field
            this.parentSection = mtws.Parent_Section__c == null ? null : mtws.Parent_Section__c; // optional field
            this.tabsList = mtws.Tabs_List__c == null ? new List<String>() : mtws.Tabs_List__c.split(',');
        }
    }
}