global with sharing class TargetingControllerRefactored  implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate  {
    //AVAILABLE: AIRPORT, BOROUGH, CITY, COUNTRY, COUNTY, DMA_REGION, NEIGHBORHOOD, POSTAL_CODE, STATE, PROVINCE, CANTON, DEPARTMENT, GOVERNORATE, PREFECTURE, REGION, TERRITORY, TV_REGION, UNION_TERRITORY
    private static final Set<string> availableGeoCats = new  Set<string>{'CITY', 'COUNTRY', 'COUNTY', 'DMA_REGION', 'STATE', 'AIRPORT', 'BOROUGH', 'NEIGHBORHOOD', 'PROVINCE', 'CANTON', 'DEPARTMENT', 'GOVERNORATE', 'PREFECTURE', 'REGION', 'TERRITORY', 'TV_REGION', 'UNION_TERRITORY'};
    private static Set<string> availableGeoCatsRoot =  new  Set<string>{'CITY', 'COUNTRY', 'COUNTY', 'DMA_REGION', 'STATE', 'AIRPORT', 'BOROUGH', 'NEIGHBORHOOD', 'PROVINCE', 'CANTON', 'DEPARTMENT', 'GOVERNORATE', 'PREFECTURE', 'REGION', 'TERRITORY', 'TV_REGION', 'UNION_TERRITORY'};

    private static final Map<string, String> availableCatsToUserText  = new  Map<string,string>{
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
    private static final string audienceSegmentCategory = 'Audience segment';
    private static final Set<string> DeviceManCats = new Set<string>{'Mobile Device','Device Manufacturer'};

    public static final string SELECTED_NO = 'No';
    public static final string SELECTED_YES_INCLUDE = 'Yes-Include';
    public static final string SELECTED_YES_EXCLUDE = 'Yes-Exclude';
    public static final string KEYVALUE_CONFIGURATION_ID = 'ID';


    global string performAction(String parameters) {
        
        System.debug('parameters '+parameters);

        CS_Custom_Settings__c customSettings = CS_Custom_Settings__c.getInstance();
        
        TargetSearch currentSearch = (TargetSearch) JSON.deserialize(parameters, TargetSearch.class);
        TargetInfo retTargetInfo = new TargetInfo();
        retTargetInfo.searchText = currentSearch.searchText;
        retTargetInfo.selectedId = currentSearch.selectedId;
        retTargetInfo.targetType = currentSearch.targetType;
        Set<Id> selIds = new Set<Id>();
        Set<Id> selInclIds = new Set<Id>();
        Set<Id> selExclIds = new Set<Id>();
        if(!string.isEmpty(currentSearch.includedItems)){
            selInclIds.addAll((List<Id>)currentSearch.includedItems.split(','));
            selIds.addAll(selInclIds);
        }
        if(!string.isEmpty(currentSearch.excludedItems)){
            selExclIds.addAll((List<Id>)currentSearch.excludedItems.split(','));
            selIds.addAll(selExclIds);
        }

        if(currentSearch.targetType == 'Channels'){
            retTargetInfo.results = loadChannels(currentSearch.selectedId, currentSearch.adServer, currentSearch.searchText, selIds, selInclIds, false);
        }
        if(currentSearch.targetType == 'Device Category'){
            retTargetInfo.results = loadDeviceCategories(currentSearch.selectedId, currentSearch.adServer, currentSearch.searchText, selIds, selInclIds, false);
        }
        if(currentSearch.targetType == 'Inventory'){
            retTargetInfo.results = loadInventory(currentSearch.naa_Ids, currentSearch.adServer, currentSearch.searchText, selIds, selInclIds, false);
        }
        if(currentSearch.targetType == 'Ad Unit & Placements'){
            retTargetInfo.results = loadInventoryHierarchy(currentSearch.selectedId, currentSearch.adServer, currentSearch.searchText, selIds, selInclIds, false);
        }
        else if(currentSearch.targetType == 'Geography'){
            retTargetInfo.results = loadGeos(currentSearch.selectedId, currentSearch.adServer, currentSearch.searchText, selIds, selInclIds, false);
        }
        else if(currentSearch.targetType == 'Operating System'){
            retTargetInfo.results = loadOs(currentSearch.selectedId, currentSearch.adServer, currentSearch.searchText, selIds, selInclIds, false);
        }
        else if(currentSearch.targetType == 'Browser'){
            retTargetInfo.results = loadBrowsers(currentSearch.selectedId, currentSearch.adServer, currentSearch.searchText, selIds, selInclIds, false);
        }
        else if(currentSearch.targetType == 'Manufacturer/device'){
            retTargetInfo.results = loadDeviceMan(currentSearch.selectedId, currentSearch.adServer, currentSearch.searchText, selIds, selInclIds, false);
        }
        else if(currentSearch.targetType == 'Mobile Carrier'){
            retTargetInfo.results = loadMobileCarriers(currentSearch.selectedId, currentSearch.adServer, currentSearch.searchText, selIds, selInclIds, false);
        }
        else if(currentSearch.targetType == 'ZipSearch'){
            retTargetInfo.results = searchZips(currentSearch.searchText, currentSearch.adServer);
            //selects all items so we can return
            return JSON.serialize(retTargetInfo);
        }
        else if(currentSearch.targetType == 'Key-value and Audience'){
            retTargetInfo.results = loadKeys(currentSearch.adServer, customSettings);
            retTargetInfo.results.addAll(loadValues(currentSearch.searchText, currentSearch.adServer, customSettings));
        }

        if(retTargetInfo.results == null)
            retTargetInfo.results = new List<TargetItem>();

        List<TargetItem> loadSel = loadSelected(selIds, selInclIds, currentSearch.adServer);
        retTargetInfo.results.addAll(loadSel);

        System.debug('leaving '+retTargetInfo.results);
        return JSON.serialize(retTargetInfo);
    }


    public static List<Object> loadItems(Id currId, string adServer, string searchText, Set<Id> selIds, boolean onlySelected, string searchType){
        System.debug('Attributes are '+currId+ ' '+adServer+' '+searchText+' '+ selIds+' '+onlySelected+' '+searchType);
        
        List<TargetingQueryStrings__c> csQueriesList = [Select Name,Current_Id_Null__c,Base__c,Custom__c,Not_Selected__c,Object__c,Search_Text__c,Selected__c,CurrId__c from TargetingQueryStrings__c where Name =: searchType limit 1];
        if (csQueriesList.size() != 1){
            return null;
        }
        TargetingQueryStrings__c CSQuery = csQueriesList[0];
        Set<Id> selectedIds = new Set<Id>();
        selectedIds = onlySelectedForType(selIds, Schema.getGlobalDescribe().get(CSQuery.Object__c));
        if(onlySelected
           && selectedIds.isEmpty()){
            return null;
        }
        
        string searchTextSoql = '%' + searchText + '%';

         String queryString = 'SELECT ' + CS_Util.getFieldListAsCSV(CSQuery.Object__c) +' '+ CSQuery.Base__c;
        if(onlySelected){
            if(CSQuery.Selected__c != null)
            queryString += ' '+ CSQuery.Selected__c;
        }else{
            if(selectedIds != null) {
                if(CSQuery.Not_Selected__c != null)
                queryString += ' '+ CSQuery.Not_Selected__c;
            }
            if(!string.isEmpty(searchText)){
                if(CSQuery.Search_Text__c != null)
                queryString += ' '+CSQuery.Search_Text__c;
            }
            if(currId!=null){
                if(CSQuery.CurrId__c != null){
                    queryString += ' '+ CSQuery.CurrId__c;
                }
            }else{
                if(CSQuery.Current_Id_Null__c != null){
                    queryString += ' '+ CSQuery.Current_Id_Null__c;
                }   
            }

        }

        if(CSQuery.Custom__c != null){
            queryString = CSQuery.Custom__c;
        }
        
        if(!String.isEmpty(searchText)) {
            queryString = queryString.replace('AND csdf__Category__c in :availableGeoCatsRoot', ' ');
            queryString = queryString.replace('AND Targetable_Parent__c = null', ' ');
            if (queryString.contains('csdf__Operating_System_Version__c')){
                queryString = queryString.replace('AND id = null', ' ');
            }
        }
        
        System.debug('Geo cats '+ availableGeoCatsRoot);
        System.debug('STRING IS '+queryString);
       
        List<Object> queryRecords = database.query(queryString);
        System.debug('Records are'+ queryRecords);
       
        return queryRecords;  

    }



    public static List<TargetItem> loadSelected(Set<Id> selIds, Set<Id> selInclIds, Id adServer)
    {
        List<TargetItem> tmpTIs, retList = new List<TargetItem>();
        //load channels
        tmpTIs = loadChannels(null, adServer, '', selIds, selInclIds, true);
        if(tmpTIs != null)
            retList.addAll(tmpTIs);
        //load Device category
        tmpTIs = loadDeviceCategories(null, adServer, '', selIds, selInclIds, true);
        if(tmpTIs != null)
            retList.addAll(tmpTIs);
        //load inventory
        tmpTIs = loadInventory(null, adServer, '', selIds, selInclIds, true);
        if(tmpTIs != null)
            retList.addAll(tmpTIs);     
        //load inventory hierarchy   
        tmpTIs = loadInventoryHierarchy(null, adServer, '', selIds, selInclIds, true);
        if(tmpTIs != null)
            retList.addAll(tmpTIs);
        //load geos
        tmpTIs = loadGeos(null, adServer, '', selIds, selInclIds, true);
        if(tmpTIs != null)
            retList.addAll(tmpTIs);
        //load OS & OS Versions
        tmpTIs = loadOs(null, adServer, '', selIds, selInclIds, true);
        if(tmpTIs != null)
            retList.addAll(tmpTIs);
        //load browser
        tmpTIs = loadDeviceMan(null, adServer, '', selIds, selInclIds, true);
        if(tmpTIs != null)
            retList.addAll(tmpTIs);
        //load Browsers
        tmpTIs = loadBrowsers(null, adServer, '', selIds, selInclIds, true);
        if(tmpTIs != null)
            retList.addAll(tmpTIs);
        //load Mobile Carriers
        tmpTIs = loadMobileCarriers(null, adServer, '', selIds, selInclIds, true);
        if(tmpTIs != null)
            retList.addAll(tmpTIs);

        return retList;
    }


    public static List<TargetItem> loadChannels(Id currId, string adServer, string searchText, Set<Id> selIds, Set<Id> selInclIds, boolean onlySelected){
        List<csmso__Node_Advert_Assignment__c> channelRecords = (List<csmso__Node_Advert_Assignment__c>) loadItems(currId,adServer,searchText,selIds,onlySelected,'ChannelsNAA');
        System.debug('In load channels 1'+channelRecords);
        Set<Id> setOfChannelIds = new Set<Id>();
        if(channelRecords == null){
            return null;
        }
        for(csmso__Node_Advert_Assignment__c chan : channelRecords){
            System.debug('In load channels 22'+chan);
            setOfChannelIds.add(chan.id);
        }
        System.debug('In load channels 2');
        List<csmso__Rate_Card_Item_Price__c> rateCardRecords = (List<csmso__Rate_Card_Item_Price__c> ) loadItems(currId,adServer,searchText,setOfChannelIds,onlySelected,'ChannelsRateCard');
        System.debug('In load channels 3');
        List<TargetItem> returnTIs = new List<TargetItem>();
        TargetItem tmpTI;
        for(csmso__Node_Advert_Assignment__c chan : channelRecords)
        {
            tmpTI = new TargetItem(chan.Id, chan.Name, false);
            tmpTI.itemData.put('Type', 'Channels');
            tmpTI.itemData.put('UserType', 'Channel');
            Decimal priceOfRateCard = 0;
            System.debug(' 353 '+rateCardRecords);
            if(rateCardRecords != null){
                for(csmso__Rate_Card_Item_Price__c rcard : rateCardRecords){
                    if(rcard.csmso__Advert_Assignment__c == chan.id){
                        if(rcard.csmso__Price_Per_Unit__c!=null){
                            priceOfRateCard += rcard.csmso__Price_Per_Unit__c;
                        }
                    }
                }
            }
            //Price can be max 7
            tmpTI.itemData.put('Price',priceOfRateCard);
            tmpTI.itemData.put('ChannelName',chan.Name);
            tmpTI.itemData.put('Ad_Type',chan.Placement__c);
            tmpTI.selected = onlySelected ? ( selInclIds.contains(chan.Id) ? SELECTED_YES_INCLUDE : SELECTED_YES_EXCLUDE ) : SELECTED_NO;
            tmpTI.rootPath = chan.Root_Path__c;
            returnTIs.add(tmpTI);
        }
        System.debug('67'+returnTIs);
        returnTIs.sort();
        return returnTIs;

    }   

    public static List<TargetItem> loadDeviceCategories(Id currId, string adServer, string searchText, Set<Id> selIds, Set<Id> selInclIds, boolean onlySelected){
        return loadTargetables(currId, adServer, searchText, selIds, selInclIds, onlySelected, 'DeviceCategories');
    }
    
    public static List<TargetItem> loadDeviceMan(Id currId, string adServer, string searchText, Set<Id> selIds, Set<Id> selInclIds, boolean onlySelected){
        return  loadTargetables(currId, adServer, searchText, selIds, selInclIds, onlySelected, 'DeviceManufacturer');
    }
    
    public static List<TargetItem> loadMobileCarriers(Id currId, string adServer, string searchText, Set<Id> selIds, Set<Id> selInclIds, boolean onlySelected){
        return  loadTargetables(currId, adServer, searchText, selIds, selInclIds, onlySelected, 'MobileCarrier');
    }

    private static List<TargetItem> loadTargetables(Id currId, string adServer, string searchText, Set<Id> selIds, Set<Id> selInclIds, boolean onlySelected, string searchType){
        List<csdf__Targetable__c> targetList = (List<csdf__Targetable__c>)loadItems(currId,adServer,searchText,selIds,onlySelected,searchType);
        if(targetList == null){
            return null;
        }
        string tmpName;
        List<TargetItem> returnTIs = new List<TargetItem>();
        TargetItem tmpTI;
        for(csdf__Targetable__c target : targetList)
        {
            tmpName = target.csdf__Targetable_Name__c;
            tmpTI = new TargetItem(target.Id, tmpName, target.Targetables__r.size() > 0);
            tmpTI.itemData.put('csdf__Ad_Server_Id__c', target.csdf__Ad_Server_Id__c);
            tmpTI.itemData.put('Type', target.csdf__Type__c);
            tmpTI.selected = onlySelected ? ( selInclIds.contains(target.Id) ? SELECTED_YES_INCLUDE : SELECTED_YES_EXCLUDE ) : SELECTED_NO;
            tmpTI.rootPath = target.Root_Path__c;
            returnTIs.add(tmpTI);
        }
        returnTIs.sort();
        return returnTIs;
    }

    public static List<TargetItem> loadInventory(string naas, string adServer, string searchText, Set<Id> selIds, Set<Id> selInclIds, boolean onlySelected)
    {
        List<string> naasList = naas != null ? naas.split(',') : new List<string>();
        Set<Id> naaIds = new Set<Id>();
        for(string naa : naasList){
            if(!string.isEmpty(naa))
                naaIds.add(naa);
        }

        List<csmso__Node_Advert_Assignment__c> naaRecords = (List<csmso__Node_Advert_Assignment__c>) loadItems(null,adServer,searchText,naaIds,false,'InventoryNAA');
        if(naaRecords == null){
            return null;
        }
        
        Set<Id> adSlotIds = new Set<Id>();
        for(csmso__Node_Advert_Assignment__c naaItem : naaRecords){
            if(!string.isEmpty(naaItem.Ad_Slot__c)){
                /*adSlotIds.addAll(DigitalFulfilmentAdapterUtil.getIncludeExcludeIds(naaItem.Ad_Slot__c, 
                                                                                   DigitalFulfilmentAdapterUtil.IncludeExcludeDataType.INCLUDE));
                adSlotIds.addAll(DigitalFulfilmentAdapterUtil.getIncludeExcludeIds(naaItem.Ad_Slot__c, 
                                                                                   DigitalFulfilmentAdapterUtil.IncludeExcludeDataType.EXCLUDE));*/
            }
        }

        List<csdf__Ad_Slot__c> asList;
        if(onlySelected){
             asList= (List<csdf__Ad_Slot__c>) loadItems(null,adServer,searchText,selIds,onlySelected,'InventoryAdSlots');
        }else{
            adSlotIds.removeAll(selIds);
            asList = (List<csdf__Ad_Slot__c>) loadItems(null,adServer,searchText,adSlotIds,onlySelected,'InventoryAdSlots');
        }
        if(asList == null){
            return null;
        }
       
        List<TargetItem> returnTIs = new List<TargetItem>();
        for(csdf__Ad_Slot__c aSlot : asList)
        {
            TargetItem tmpTI = new TargetItem(aSlot.Id, aSlot.csdf__Name__c, false);
            tmpTI.itemData.put('csdf__Sizes__c', aSlot.csdf__Ad_Server_Id__c);
            tmpTI.itemData.put('Type', 'Inventory');
            tmpTI.itemData.put('UserType', aSlot.csdf__Type__c);
            tmpTI.selected = onlySelected ? ( selInclIds.contains(aSlot.Id) ? SELECTED_YES_INCLUDE : SELECTED_YES_EXCLUDE ) : SELECTED_NO;
            tmpTI.rootPath = aSlot.Root_Path__c;
            returnTIs.add(tmpTI);
        }
        returnTIs.sort();
        return returnTIs;
    }
    
    private static String replaceIdsWithNames(String idCsv, Map<Id, csdf__Ad_Slot__c> adSlots) {
        List<String> namesList = new List<String>();
        for(String adSlotIdStr : idCsv.split('\\,')) {
            Id adSlotId = Id.valueOf(adSlotIdStr.left(15));
            if(adSlots.containsKey(adSlotId)) {
                namesList.add(adSlots.get(adSlotId).csdf__Name__c);
            }
            else {
                System.debug('No ad slot found - will be omitted from the display name root path string: ' + adSlotIdStr);
            }
        }
        return String.join(namesList, ' > ');
    }

    public static List<TargetItem> loadInventoryHierarchy(id currId, string adServer, string searchText, Set<Id> selIds, Set<Id> selInclIds, boolean onlySelected)
    {
        List<csdf__Ad_Slot__c> adSlotList = (List<csdf__Ad_Slot__c>)loadItems(currId, adServer, searchText, selIds, onlySelected, 'InventoryHierarchy');
        if(adSlotList == null){
            return null;
        }

        // get list of all root path IDs
        Set<String> rootAdSlotsIdsStrsSet = new Set<String>();
        for(csdf__Ad_Slot__c slot : adSlotList) {
            if (String.isNotBlank(slot.Root_Path__c)) {
                rootAdSlotsIdsStrsSet.addAll(slot.Root_Path__c.split('\\,'));
            }
            rootAdSlotsIdsStrsSet.add(String.valueOf(slot.Id));
        }
        Map<Id, csdf__Ad_Slot__c> pathMap = new Map<Id, csdf__Ad_Slot__c>([SELECT Id, csdf__Name__c, csdf__Ad_Server_Id__c 
                                                                           FROM csdf__Ad_Slot__c 
                                                                           WHERE Id IN :rootAdSlotsIdsStrsSet]);

        List<TargetItem> returnTIs = new List<TargetItem>();
        TargetItem tmpTI;
        for(csdf__Ad_Slot__c aSlot : adSlotList)
        {   
            tmpTI = new TargetItem(aSlot.Id, aSlot.csdf__Name__c, aSlot.csdf__Ad_Slot_Parent_Assignments__r.size()>0 && aSlot.csdf__Type__c !='Placement' );
            tmpTI.itemData.put('csdf__Sizes__c', aSlot.csdf__Ad_Server_Id__c);
            tmpTI.itemData.put('Type', 'Ad Unit & Placements');
            tmpTI.itemData.put('UserType', aSlot.csdf__Type__c);
            tmpTI.selected = onlySelected ? ( selInclIds.contains(aSlot.Id) ? SELECTED_YES_INCLUDE : SELECTED_YES_EXCLUDE ) : SELECTED_NO;
            tmpTI.rootPath = aSlot.Root_Path__c;
            if(String.isNotBlank(aSlot.Root_Path__c)) {
                tmpTI.itemData.put('FullPath', replaceIdsWithNames(aSlot.Root_Path__c + ',' + aSlot.Id, pathMap));
            }
            else {
                tmpTI.itemData.put('FullPath', replaceIdsWithNames(aSlot.Id, pathMap));
            }
            returnTIs.add(tmpTI);
        }
        returnTIs.sort();

        return returnTIs;
    }

    public static List<TargetItem> loadGeos(Id currId, string adServer, string searchText, Set<Id> selIds, Set<Id> selInclIds, boolean onlySelected)
    {   
        if(currId == null){
            availableGeoCatsRoot = new  Set<string>{'COUNTRY'};

        }else{
            availableGeoCatsRoot = new  Set<string>{'CITY', 'COUNTRY', 'COUNTY', 'DMA_REGION', 'STATE', 'AIRPORT', 'BOROUGH', 'NEIGHBORHOOD','PROVINCE', 'CANTON', 'DEPARTMENT', 'GOVERNORATE', 'PREFECTURE', 'REGION', 'TERRITORY', 'TV_REGION', 'UNION_TERRITORY'};

        }

        List<csdf__Geo_Item__c> giList = (List<csdf__Geo_Item__c>)loadItems(currId,adServer,searchText,selIds,onlySelected,'Geography');
        if(giList == null){
            return null;
        }
        List<TargetItem> returnTIs = new List<TargetItem>();
        TargetItem tmpTI;

        string userType;
        for(csdf__Geo_Item__c gi : giList)
        {
            userType = '';
            tmpTI = new TargetItem(gi.Id, gi.Name, gi.csdf__Geo_Item_Parent_Assignments__r.size() > 0);
            tmpTI.itemData.put('csdf__Ad_Server_Id__c', gi.csdf__Ad_Server_Id__c);
            tmpTI.itemData.put('csdf__Code__c', gi.csdf__Code__c);
            tmpTI.itemData.put('Type', 'Geography');
            tmpTI.itemData.put('csdf__Category__c', gi.csdf__Category__c);
            if(gi.csdf__Geo_Item_Child_Assignments__r.size() > 0)
                userType = gi.csdf__Geo_Item_Child_Assignments__r[0].Geo_Parent_Name__c + ', ';
            userType += availableCatsToUserText.get(gi.csdf__Category__c);
            tmpTI.itemData.put('UserType', userType);
            tmpTI.selected = onlySelected ? ( selInclIds.contains(gi.Id) ? SELECTED_YES_INCLUDE : SELECTED_YES_EXCLUDE ) : SELECTED_NO;
            tmpTI.rootPath = gi.Root_Path__c;
            returnTIs.add(tmpTI);
        }
        returnTIs.sort();
        return returnTIs;
    }

    // load OS & OS versions
    public static List<TargetItem> loadOs(Id currId, Id adServer, string searchText, Set<Id> selIds, Set<Id> selInclIds, boolean onlySelected)
    {   
        List<csdf__Operating_System__c> osRecords = (List<csdf__Operating_System__c>)loadItems(currId,adServer,searchText,selIds,onlySelected,'OperatingSystems');
        List<csdf__Operating_System_Version__c> osVersionRecords = (List<csdf__Operating_System_Version__c>)loadItems(currId,adServer,searchText,selIds,onlySelected,'OperatingSystemsVersions');
        List<TargetItem> returnTIs = new List<TargetItem>();
        List<TargetItem> tmpItems;
        TargetItem tmpTI;
        if(osRecords != null)
        {
            tmpItems = new List<TargetItem>();
            for(csdf__Operating_System__c os : osRecords) {
                tmpTI = new TargetItem(os.Id, os.Name, os.csdf__Operating_System_Versions__r.size() > 0);
                tmpTI.itemData.put('csdf__Ad_Server_Id__c',os.csdf__Ad_Server_Id__c);
                tmpTI.itemData.put('Type','Operating System');
                tmpTI.selected = onlySelected ? ( selInclIds.contains(os.Id) ? SELECTED_YES_INCLUDE : SELECTED_YES_EXCLUDE ) : SELECTED_NO;
                tmpTI.rootPath = os.Root_Path__c;
                tmpItems.add(tmpTI);
            }
            returnTIs.addAll(tmpItems);
        }
        if(osVersionRecords != null)
        {
            string tmpName;
            tmpItems = new List<TargetItem>();
            for(csdf__Operating_System_Version__c osv : osVersionRecords) {
                tmpName = osv.csdf__Operating_System__r.Name + ' ' + 
                (osv.csdf__Major_Version__c != '-1' ? osv.csdf__Major_Version__c : 'x' ) + '.' +
                (osv.csdf__Minor_Version__c != '-1' ? osv.csdf__Minor_Version__c : 'x' ) + '.' +
                (osv.csdf__Micro_Version__c != '-1' ? osv.csdf__Micro_Version__c : 'x' );

                tmpTI = new TargetItem(osv.Id, tmpName, false);
                tmpTI.itemData.put('csdf__Ad_Server_Id__c',osv.csdf__Ad_Server_Id__c);
                tmpTI.itemData.put('Type','Operating System Version');
                tmpTI.selected = onlySelected ? ( selInclIds.contains(osv.Id) ? SELECTED_YES_INCLUDE : SELECTED_YES_EXCLUDE ) : SELECTED_NO;
                tmpTI.rootPath = osv.Root_Path__c;
                tmpItems.add(tmpTI);
            }
            returnTIs.addAll(tmpItems);
        }
        return returnTIs;
    }

    public static List<TargetItem> loadBrowsers(Id currId, string adServer, string searchText, Set<Id> selIds, Set<Id> selInclIds, boolean onlySelected) {   

        List<csdf__Browser__c> browserList = (List<csdf__Browser__c>)loadItems(currId,adServer,searchText,selIds,onlySelected,'Browsers');
        if(browserList == null){
            return null;
        }
        string tmpName;
        List<TargetItem> returnTIs = new List<TargetItem>();
        TargetItem tmpTI;
        for(csdf__Browser__c browser : browserList)
        {
            tmpName = browser.csdf__Browser_Name__c + ' (' +
                (browser.csdf__Major_Version__c == 'Any' ? 'x' : (browser.csdf__Major_Version__c == 'Other' ? 'Unknown' : browser.csdf__Major_Version__c)) +
                (browser.csdf__Minor_Version__c == 'Any' ? 'x' : (browser.csdf__Minor_Version__c == 'Other' ? 'Unknown' : browser.csdf__Minor_Version__c)) + ')';
            tmpTI = new TargetItem(browser.Id, tmpName, false);
            tmpTI.itemData.put('csdf__Ad_Server_Id__c', browser.csdf__Ad_Server_Id__c);
            tmpTI.itemData.put('csdf__Major_Version__c', browser.csdf__Major_Version__c);
            tmpTI.itemData.put('csdf__Minor_Version__c', browser.csdf__Minor_Version__c);
            tmpTI.itemData.put('Type', 'Browser');
            tmpTI.selected = onlySelected ? ( selInclIds.contains(browser.Id) ? SELECTED_YES_INCLUDE : SELECTED_YES_EXCLUDE ) : SELECTED_NO;
            tmpTI.rootPath = browser.Root_Path__c;
            returnTIs.add(tmpTI);
        }
        returnTIs.sort();
        return returnTIs;
    }
    
    public static List<TargetItem> searchZips(string searchText, Id adServerId){
        Set<string> countryCodes = new Set<string>();
        Set<string> zipCodes = new Set<string>();
        List<TargetItem> retItems = new List<TargetItem>();
        Set<string> enteredItems = new Set<string>();
        //split inputs to post codes
        List<string> zipInputs = searchText.split(',');
        string tmpZip;
        List<string> tmpZipArray;
        boolean us_ca_added = false;
        //get all postcodes with from all countries and then sort it out to have single soql
        for(string zi : zipInputs){
            tmpZip = zi.trim().toUpperCase();
            enteredItems.add(tmpZip);
            tmpZipArray = tmpZip.split('/');
            //US & CA allow zip only
            if(tmpZipArray.size() > 1){
                countryCodes.add(tmpZipArray[0]);
                zipCodes.add(tmpZipArray[1]);
            }
            else if(!tmpZipArray.isEmpty()){
                if(!us_ca_added){
                    countryCodes.add('CA');
                    countryCodes.add('US');
                    us_ca_added = true;
                }
                zipCodes.add(tmpZipArray[0]);
            }
        }
        //query database, most restrictive possible, but only 1 query
        string zipGeoQuery = 'select ' + CS_Util.getFieldListAsCSV('csdf__Geo_Item__c');
        zipGeoQuery += ' from csdf__Geo_Item__c where csdf__Category__c = \'POSTAL_CODE\' and Name in :zipCodes and csdf__Code__c in :countryCodes';
        List<csdf__Geo_Item__c> geoList = database.query(zipGeoQuery);
        TargetItem tmpTI;
        string tmpKey;

        for(csdf__Geo_Item__c geo : geoList){
            tmpKey = geo.csdf__Code__c.trim() + '/' + geo.Name.trim();
            if(!enteredItems.contains(tmpKey)){
                //if US or CA try w/o country
                if(geo.csdf__Code__c == 'US' || geo.csdf__Code__c == 'CA'){
                    tmpKey = geo.Name.trim();
                    if(!enteredItems.contains(tmpKey)){//not found
                        continue;
                    }
                }
                else {//not found
                    continue;
                }
            }
            //item is found, create selected target item
            tmpTI = new TargetItem(geo.Id, geo.Name, false);
            tmpTI.itemData.put('csdf__Ad_Server_Id__c', geo.csdf__Ad_Server_Id__c);
            tmpTI.itemData.put('csdf__Code__c', geo.csdf__Code__c);
            tmpTI.itemData.put('Type', 'Geography');
            tmpTI.itemData.put('csdf__Category__c', geo.csdf__Category__c);
            tmpTI.itemData.put('UserType', availableCatsToUserText.get(geo.csdf__Category__c));
            tmpTI.selected = SELECTED_YES_INCLUDE;
            tmpTI.rootPath = geo.Root_Path__c;
            retItems.add(tmpTI);
            //remove item that is found
            enteredItems.remove(tmpKey);
        }
        //add not found items as target ites 
        if(!enteredItems.isEmpty()){
            for(string item : enteredItems){
                tmpTI = new TargetItem(null, item, false);
                tmpTI.selected = SELECTED_NO;
                retItems.add(tmpTI);
            }
        }
        return retItems;
    }


    public static List<TargetItem> loadKeys(Id adServerId, CS_Custom_Settings__c customSettings){
        string keySoql = 'select ' + CS_Util.getFieldListAsCSV('csdf__Custom_Targeting_Key__c') + ' from csdf__Custom_Targeting_Key__c' +
        ' where csdf__Ad_Server__c = :adServerId';
        List<csdf__Custom_Targeting_Key__c> keyList = database.query(keySoql);
        List<TargetItem> returnTIs = new List<TargetItem>();
        TargetItem tmpTI;
        for(csdf__Custom_Targeting_Key__c ctk : keyList){
            tmpTI = new TargetItem(ctk.Id, ctk.csdf__Display_Name__c, false);
            if (customSettings != null 
                && customSettings.KeyValue_configuration__c == KEYVALUE_CONFIGURATION_ID) {

                tmpTI.itemData.put('csdf__Ad_Server_Id__c', '#' + ctk.csdf__Ad_Server_Id__c);
            }
            else {
                tmpTI.itemData.put('csdf__Ad_Server_Id__c', ctk.Name);
            }
            tmpTI.itemData.put('Type', ctk.csdf__Type__c);
            tmpTI.itemData.put('UIType','key');
            returnTIs.add(tmpTI);
        }
        tmpTI = new TargetItem(null,audienceSegmentCategory,false);
        tmpTI.itemData.put('csdf__Ad_Server_Id__c', audienceSegmentCategory);
        tmpTI.itemData.put('Type', audienceSegmentCategory);
        tmpTI.itemData.put('UIType','key');
        returnTIs.add(tmpTI);


        returnTIs.sort();
        return returnTIs;
    }

    public static List<TargetItem> loadValues(string inputValue, Id adServerId, CS_Custom_Settings__c customSettings){
        List<string> inputValues = inputValue.split(',');
        List<TargetItem> returnTIs = new List<TargetItem>();
        TargetItem tmpTI;
        Set<Id> keyIds = new Set<Id>();
        for(string inVal :  inputValues)
            if(inVal instanceof Id)
                keyIds.add(inVal);

        //if ID, it's key, else audience 
        if(!keyIds.isEmpty()){
            string valueSoql = 'select ' + CS_Util.getFieldListAsCSV('csdf__Custom_Targeting_Value__c') + ' from csdf__Custom_Targeting_Value__c' +
                ' where csdf__Custom_Targeting_Key__c in :keyIds LIMIT 10000';
            List<csdf__Custom_Targeting_Value__c> valueList = database.query(valueSoql);
            for(csdf__Custom_Targeting_Value__c ctv : valueList){
                tmpTI = new TargetItem(ctv.Id, ctv.csdf__Display_Name__c, false);
                if (customSettings != null 
                    && customSettings.KeyValue_configuration__c == KEYVALUE_CONFIGURATION_ID) {

                    tmpTI.itemData.put('csdf__Ad_Server_Id__c', '#' + ctv.csdf__Ad_Server_Id__c);
                }
                else {
                    tmpTI.itemData.put('csdf__Ad_Server_Id__c', ctv.Name);
                }
                tmpTI.itemData.put('UIType','value');
                tmpTI.itemData.put('key',ctv.csdf__Custom_Targeting_Key__c);
                returnTIs.add(tmpTI);
            }
            returnTIs.sort();
        }
        if(keyIds.size() != inputValues.size()) { //audience segment is always string input, not Id (add if for new use case )
            string audienceKeySoql = 'select ' + CS_Util.getFieldListAsCSV('csdf__Targetable__c') + ' from csdf__Targetable__c' +
                ' where csdf__Ad_Server__c = :adServerId and csdf__Type__c in :inputValues';
            List<csdf__Targetable__c> valueList = database.query(audienceKeySoql);
            for(csdf__Targetable__c tar : valueList){
                tmpTI = new TargetItem(tar.Id, tar.csdf__Targetable_Name__c, false);
                tmpTI.itemData.put('csdf__Ad_Server_Id__c', tar.csdf__Ad_Server_Id__c);
                tmpTI.itemData.put('UIType','value');
                tmpTI.itemData.put('key',audienceSegmentCategory);
                returnTIs.add(tmpTI);
            }
        }
        return returnTIs;
    }


    public static Set<Id> onlySelectedForType(Set<Id> selectedId, sObjectType currType)
    {
        string keyPrefix = CS_Util.findKeyPrefix(currType);
        Set<Id> returnIds = new Set<Id>(); 
        for(Id key : selectedId){
            if(string.valueOf(key).startsWith(keyPrefix)){
                returnIds.add(key);
            }
        }
        return returnIds;

    }


    public class TargetSearch
    {
        public string targetType { get; set; }
        public string searchText { get; set; }
        public Id selectedId { get; set; }
        public string adServer { get; set; }
        public string naa_Ids { get; set; }
        public string includedItems { get; set; }
        public string excludedItems { get; set; }
    }

    public class TargetInfo
    {
        public string targetType { get; set; }
        public List<BreadCrumb> breadCrumbList { get; set; }
        public string searchText { get; set; }
        public Id selectedId { get; set; }
        public List<TargetItem> results { get; set; }
    }

    public class BreadCrumb implements Comparable
    {
        public integer sortIndex { get;  set; }
        public Id targetId { get; set; }
        public string targetText { get; set; }

        public integer compareTo(object otherObj)
        {
            BreadCrumb otherBC = (BreadCrumb) otherObj;
            return sortIndex - otherBC.sortIndex;
        }
    }

    public class TargetItem implements Comparable
    {
        public Map<string, object> itemData { get; set; }
        public Id itemId { get; set; }
        public string name { get; set; }
        public String selected { get; set; }
        public boolean hasChilds { get; set; }
        public String rootPath { get; set; }

        public TargetItem(Id itmId, string nam, boolean hasChil) {
            itemId = itmId;
            name = nam;
            hasChilds = hasChil;
            itemData = new Map<string, object>();
            rootPath = '';
            selected = SELECTED_NO;
        }

        public TargetItem() {
            selected = SELECTED_NO;
            itemData = new Map<string, object>();
            rootPath = '';
        }

        public integer compareTo(object otherObj) {
            TargetItem otherTI = (TargetItem) otherObj;
            return name.compareTo(otherTI.name);
        }
    }
}