@isTest
public class MediaTargetingWidgetTest {

    public static csdf__Ad_Server__c adServer;
    public static csdf__Ad_Slot__c adUnit;
    public static csdf__Ad_Slot__c placement;
    public static csdf__Geo_Item__c geoItemParent;
    public static csdf__Geo_Item__c geoItemChild;
    public static csdf__Geo_Item__c geoItemSubChild;
    public static csdf__Geo_Item__c zipCode1;
    public static csdf__Geo_Item__c zipCode2;
    public static csdf__Browser__c browser;
    public static csdf__Targetable__c targDeviceCategory;
    public static csdf__Targetable__c targetableDeviceManufacturer;
    public static csdf__Targetable__c targMobileCarrier;
    public static csdf__Targetable__c targBandwidthGroup;
    public static csdf__Targetable__c targDeviceCapability;
    public static csdf__Operating_System__c opSystem;
    public static csdf__Operating_System_Version__c opSystemVersion;
    public static csdf__Custom_Targeting_Key__c kvaKey;
    public static csdf__Custom_Targeting_Value__c kvaValue;
    public static csdf__Targetable__c kvaAudienceValue;
    // public static Ad_Slot_Template__c adSlotTemplate1;
    // public static Ad_Slot_Template__c adSlotTemplate2;
    public static csdf__Targeting_Template__c targetingTemplate1;
    public static csdf__Targeting_Template__c targetingTemplate2;
    public static csdf__Targeting_Template__c targetingTemplateCLT1;
    public static csdf__Targeting_Template__c targetingTemplateCLT2;

    public static void createTestData() {
        // AdServer
        adServer = new csdf__Ad_Server__c();
        adServer.Name = 'Newsday DFP Production';
        adServer.csdf__Network_Code__c = '5819';
        adServer.csdf__Username__c = 'userTest';
        adServer.csdf__Password__c = 'userPass';
        insert adServer;

        // Custom settings
        setupMTWSections();
        setupMTWSettings(adServer.Id);

        // AdUnit
        adUnit = new csdf__Ad_Slot__c();
        adUnit.csdf__Name__c = 'NewsDay Traffic';
        adUnit.csdf__Active__c = true;
        adUnit.csdf__Ad_Server__c = adServer.Id;
        adUnit.csdf__Ad_Server_Id__c = adServer.Id;
        adUnit.csdf__Code__c = 'cblvsn.nwsd.traffic';
        adUnit.csdf__Type__c = 'Ad Unit';
        adUnit.csdf__Sizes__c = '100x100,150x100';
        insert adUnit;

        // AdSlot
        placement = new csdf__Ad_Slot__c();
        placement.csdf__Name__c = 'NewsDay Traffic';
        placement.csdf__Active__c = true;
        placement.csdf__Ad_Server__c = adServer.Id;
        placement.csdf__Ad_Server_Id__c = adServer.Id;
        placement.csdf__Code__c = 'cblvsn.nwsd.traffic';
        placement.csdf__Type__c = 'Placement';
        placement.csdf__Sizes__c = '100x100,150x100';
        insert placement;

        // Geography parent
        geoItemParent = new csdf__Geo_Item__c();
        geoItemParent.name = 'Portugal';
        geoItemParent.csdf__Ad_Server__c = adServer.Id;
        geoItemParent.csdf__Ad_Server_Id__c = '21149';
        geoItemParent.csdf__Category__c = 'COUNTRY';
        geoItemParent.csdf__Active__c = true;
        geoItemParent.csdf__Code__c = 'US';

        // Geography child
        geoItemChild = new csdf__Geo_Item__c();
        geoItemChild.name = 'Vila Real District';
        geoItemChild.csdf__Ad_Server__c = adServer.Id;
        geoItemChild.csdf__Ad_Server_Id__c = '21150';
        geoItemChild.csdf__Category__c = 'REGION';
        geoItemChild.csdf__Active__c = true;
        geoItemChild.csdf__Code__c = 'US';

        geoItemSubChild = new csdf__Geo_Item__c();
        geoItemSubChild.name = 'Vila Real House';
        geoItemSubChild.csdf__Ad_Server__c = adServer.Id;
        geoItemSubChild.csdf__Ad_Server_Id__c = '21150';
        geoItemSubChild.csdf__Category__c = 'CITY';
        geoItemSubChild.csdf__Active__c = true;
        geoItemSubChild.csdf__Code__c = 'US';

        // Zip Codes
        zipCode1 = new csdf__Geo_Item__c();
        zipCode1.name = '1234';
        zipCode1.csdf__Ad_Server__c = adServer.Id;
        zipCode1.csdf__Ad_Server_Id__c = '21149';
        zipCode1.csdf__Category__c = 'POSTAL_CODE';
        zipCode1.csdf__Active__c = true;
        zipCode1.csdf__Code__c = 'AB';

        zipCode2 = new csdf__Geo_Item__c();
        zipCode2.name = '1234';
        zipCode2.csdf__Ad_Server__c = adServer.Id;
        zipCode2.csdf__Ad_Server_Id__c = '21149';
        zipCode2.csdf__Category__c = 'POSTAL_CODE';
        zipCode2.csdf__Active__c = true;
        zipCode2.csdf__Code__c = 'US';

        insert new List<csdf__Geo_Item__c> {geoItemParent, geoItemChild, geoItemSubChild, zipCode1, zipCode2};

        // Geo item assignment
        csdf__Geo_Item_Assignment__c geoItemAssignment1 = new csdf__Geo_Item_Assignment__c();
        geoItemAssignment1.csdf__Geo_Item_Child__c = geoItemChild.Id;
        geoItemAssignment1.csdf__Geo_Item_Parent__c = geoItemParent.Id;

        // Geo item assignment
        csdf__Geo_Item_Assignment__c geoItemAssignment2 = new csdf__Geo_Item_Assignment__c();
        geoItemAssignment2.csdf__Geo_Item_Child__c = geoItemSubChild.Id;
        geoItemAssignment2.csdf__Geo_Item_Parent__c = geoItemChild.Id;

        insert new List<csdf__Geo_Item_Assignment__c> {geoItemAssignment1, geoItemAssignment2};

        // Browsers
        browser = new csdf__Browser__c();
        browser.csdf__Ad_Server__c = adServer.Id;
        browser.csdf__Ad_Server_Id__c = '500011';
        browser.csdf__Browser_Name__c = 'FireFox';
        insert browser;

        // DeviceCategories
        targDeviceCategory = new csdf__Targetable__c();
        targDeviceCategory.csdf__Targetable_Name__c = 'Zen';
        targDeviceCategory.csdf__Active__c = true;
        targDeviceCategory.csdf__Ad_Server_Id__c = '40343';
        targDeviceCategory.csdf__Ad_Server__c = adServer.Id;
        targDeviceCategory.csdf__Type__c = 'Device Category';
        insert targDeviceCategory;

        // DeviceManufacturer
        targetableDeviceManufacturer = new csdf__Targetable__c();
        targetableDeviceManufacturer.csdf__Targetable_Name__c = 'Zen';
        targetableDeviceManufacturer.csdf__Active__c = true;
        targetableDeviceManufacturer.csdf__Ad_Server_Id__c = '40343';
        targetableDeviceManufacturer.csdf__Ad_Server__c = adServer.Id;
        targetableDeviceManufacturer.csdf__Type__c = 'Device Manufacturer';
        insert targetableDeviceManufacturer;

        // MobileCarrier
        targMobileCarrier = new csdf__Targetable__c();
        targMobileCarrier.csdf__Targetable_Name__c = 'E-Plus Germany';
        targMobileCarrier.csdf__Active__c = true;
        targMobileCarrier.csdf__Ad_Server_Id__c = '40343';
        targMobileCarrier.csdf__Ad_Server__c = adServer.Id;
        targMobileCarrier.csdf__Type__c = 'Mobile Carrier';
        insert targMobileCarrier;

        // BandwidthGroup
        targBandwidthGroup = new csdf__Targetable__c();
        targBandwidthGroup.csdf__Targetable_Name__c = 'BW-Test';
        targBandwidthGroup.csdf__Active__c = true;
        targBandwidthGroup.csdf__Ad_Server_Id__c = '403243';
        targBandwidthGroup.csdf__Ad_Server__c = adServer.Id;
        targBandwidthGroup.csdf__Type__c = 'Bandwidth Group';
        insert targBandwidthGroup;

        // DeviceCapability
        targDeviceCapability = new csdf__Targetable__c();
        targDeviceCapability.csdf__Targetable_Name__c = 'DCapp-Test';
        targDeviceCapability.csdf__Active__c = true;
        targDeviceCapability.csdf__Ad_Server_Id__c = '403243';
        targDeviceCapability.csdf__Ad_Server__c = adServer.Id;
        targDeviceCapability.csdf__Type__c = 'Device Capability';
        insert targDeviceCapability;

        // OperatingSystems
        opSystem = new csdf__Operating_System__c();
        opSystem.Name = 'PlayStation3';
        opSystem.csdf__Ad_Server__c = adServer.Id;
        opSystem.csdf__Active__c = true;
        opSystem.csdf__Ad_Server_Id__c = '501015';
        insert opSystem;

        // OperatingSystems Versions
        opSystemVersion = new csdf__Operating_System_Version__c();
        opSystemVersion.csdf__Operating_System__c = opSystem.Id;
        opSystemVersion.csdf__Active__c = true;
        opSystemVersion.csdf__Ad_Server_Id__c = '630239';
        insert opSystemVersion;

        // KVA key
        kvaKey = new csdf__Custom_Targeting_Key__c();
        kvaKey.Name = 'test key';
        kvaKey.csdf__Ad_Server__c = adServer.Id;
        kvaKey.csdf__Ad_Server_Id__c = '501015';
        kvaKey.csdf__Display_Name__c = 'test key';
        kvaKey.csdf__Type__c = 'Predefined';
        insert kvaKey;

        // KVA value
        kvaValue = new csdf__Custom_Targeting_Value__c();
        kvaValue.Name = 'test value';
        kvaValue.csdf__Ad_Server_Id__c = adServer.Id;
        kvaValue.csdf__Custom_Targeting_Key__c = kvaKey.Id;
        kvaValue.csdf__Display_Name__c = 'test value';
        kvaValue.csdf__Match_Type__c = 'Exact';
        insert kvaValue;

        // Kva Audience Value
        kvaAudienceValue = new csdf__Targetable__c();
        kvaAudienceValue.csdf__Targetable_Name__c = 'test audience value';
        kvaAudienceValue.csdf__Active__c = true;
        kvaAudienceValue.csdf__Ad_Server_Id__c = '2134';
        kvaAudienceValue.csdf__Ad_Server__c = adServer.Id;
        kvaAudienceValue.csdf__Type__c = 'Audience Segment';
        insert kvaAudienceValue;




        // // ad slots template 1
        // adSlotTemplate1 = new Ad_Slot_Template__c();
        // adSlotTemplate1.Name = 'ad slot templ include';
        // adSlotTemplate1.Sizes__c = '100x100';
        // adSlotTemplate1.Ad_Server__c = adServer.Id;
        // insert adSlotTemplate1;

        // Ad_Slot_Targeting_Template__c astt11 = new Ad_Slot_Targeting_Template__c();
        // astt11.Ad_Slot__c = adUnit.Id;
        // astt11.Ad_Slot_Template__c = adSlotTemplate1.Id;
        // astt11.Exclude__c = false;

        // Ad_Slot_Targeting_Template__c astt12 = new Ad_Slot_Targeting_Template__c();
        // astt12.Ad_Slot__c = placement.Id;
        // astt12.Ad_Slot_Template__c = adSlotTemplate1.Id;
        // astt12.Exclude__c = false;

        // // ad slots template 2
        // adSlotTemplate2 = new Ad_Slot_Template__c();
        // adSlotTemplate2.Name = 'ad slot templ 2 exclude';
        // adSlotTemplate2.Sizes__c = '100x100';
        // adSlotTemplate2.Ad_Server__c = adServer.Id;
        // insert adSlotTemplate2;

        // Ad_Slot_Targeting_Template__c astt21 = new Ad_Slot_Targeting_Template__c();
        // astt21.Ad_Slot__c = adUnit.Id;
        // astt21.Ad_Slot_Template__c = adSlotTemplate2.Id;
        // astt21.Exclude__c = true;

        // Ad_Slot_Targeting_Template__c astt22 = new Ad_Slot_Targeting_Template__c();
        // astt22.Ad_Slot__c = placement.Id;
        // astt22.Ad_Slot_Template__c = adSlotTemplate2.Id;
        // astt22.Exclude__c = true;



        // targeting template 1
        targetingTemplate1 = new csdf__Targeting_Template__c();
        targetingTemplate1.Name = 'targ templ 1 incl';
        targetingTemplate1.csdf__Ad_Server__c = adServer.Id;
        targetingTemplate1.csdf__Custom_Key_Targeting__c = '#11823193 is #448034020020 AND #11889798 is #448094763862';
        targetingTemplate1.Long_Custom_Key_Targeting__c = '{"custom":[[{"id":"' + kvaKey.Id + '","item":null,"label":"ZagrebKey","operator":"is","values":[{"type":"KVA","parent":"' + kvaKey.Id + '","name":"London","id":"' + kvaValue.Id +'","hasChildren":false,"data":{"csdf__Ad_Server_Id__c":"#55994910178"}}],"csdf__Ad_Server_Id__c":"#198058"}]],"holistic":[]}';
        targetingTemplate1.csdf__Type__c = 'Standard'; // CLT
        insert targetingTemplate1;

        csdf__Geo_Item_Targeting_Template__c gitt1 = new csdf__Geo_Item_Targeting_Template__c();
        gitt1.csdf__Creative_Targeting_Only__c = false;
        gitt1.csdf__Exclude__c = false;
        gitt1.csdf__Geo_Item__c = geoItemParent.Id;
        gitt1.csdf__Targeting_Template__c = targetingTemplate1.Id;
        gitt1.csdf__Target_Name__c = null;

        csdf__Targetable_Targeting_Template__c ttt1 = new csdf__Targetable_Targeting_Template__c();
        ttt1.csdf__Creative_Targeting_Only__c = false;
        ttt1.csdf__Exclude__c = false;
        ttt1.csdf__Targetable__c = targDeviceCategory.Id;
        ttt1.csdf__Targeting_Template__c = targetingTemplate1.Id;
        ttt1.csdf__Target_Name__c = null;

        csdf__Targetable_Targeting_Template__c ttt2 = new csdf__Targetable_Targeting_Template__c();
        ttt2.csdf__Creative_Targeting_Only__c = false;
        ttt2.csdf__Exclude__c = false;
        ttt2.csdf__Targetable__c = targetableDeviceManufacturer.Id;
        ttt2.csdf__Targeting_Template__c = targetingTemplate1.Id;
        ttt2.csdf__Target_Name__c = null;

        csdf__Targetable_Targeting_Template__c ttt3 = new csdf__Targetable_Targeting_Template__c();
        ttt3.csdf__Creative_Targeting_Only__c = false;
        ttt3.csdf__Exclude__c = false;
        ttt3.csdf__Targetable__c = targMobileCarrier.Id;
        ttt3.csdf__Targeting_Template__c = targetingTemplate1.Id;
        ttt3.csdf__Target_Name__c = null;

        csdf__Targetable_Targeting_Template__c ttt13 = new csdf__Targetable_Targeting_Template__c();
        ttt13.csdf__Creative_Targeting_Only__c = false;
        ttt13.csdf__Exclude__c = false;
        ttt13.csdf__Targetable__c = targBandwidthGroup.Id;
        ttt13.csdf__Targeting_Template__c = targetingTemplate1.Id;
        ttt13.csdf__Target_Name__c = null;

        csdf__Targetable_Targeting_Template__c ttt17 = new csdf__Targetable_Targeting_Template__c();
        ttt17.csdf__Creative_Targeting_Only__c = false;
        ttt17.csdf__Exclude__c = false;
        ttt17.csdf__Targetable__c = targDeviceCapability.Id;
        ttt17.csdf__Targeting_Template__c = targetingTemplate1.Id;
        ttt17.csdf__Target_Name__c = null;

        csdf__Browser_Targeting_Template__c btt1 = new csdf__Browser_Targeting_Template__c();
        btt1.csdf__Browser__c = browser.Id;
        btt1.csdf__Creative_Targeting_Only__c = false;
        btt1.csdf__Exclude__c = false;
        btt1.csdf__Targeting_Template__c = targetingTemplate1.Id;
        btt1.csdf__Target_Name__c = null;

        csdf__Operating_System_Targeting_Template__c ostt1 = new csdf__Operating_System_Targeting_Template__c();
        ostt1.csdf__Creative_Targeting_Only__c = false;
        ostt1.csdf__Exclude__c = false;
        ostt1.csdf__Operating_System__c = opSystem.Id;
        ostt1.csdf__Targeting_Template__c = targetingTemplate1.Id;
        ostt1.csdf__Target_Name__c = null;

        csdf__Operating_System_Version_Target_Template__c osvtt1 = new csdf__Operating_System_Version_Target_Template__c();
        osvtt1.csdf__Creative_Targeting_Only__c = false;
        osvtt1.csdf__Exclude__c =  false;
        osvtt1.csdf__Operating_System_Version__c = opSystemVersion.Id;
        osvtt1.csdf__Targeting_Template__c = targetingTemplate1.Id;
        osvtt1.csdf__Target_Name__c = null;


        // targeting template 2
        targetingTemplate2 = new csdf__Targeting_Template__c();
        targetingTemplate2.Name = 'targ templ 2 excl';
        targetingTemplate2.csdf__Ad_Server__c = adServer.Id;
        targetingTemplate2.csdf__Custom_Key_Targeting__c = '#11823193 is #448034020020 AND #11889798 is #448094763862';
        targetingTemplate2.Long_Custom_Key_Targeting__c = '{"custom":[[{"id":"' + kvaKey.Id + '","item":null,"label":"ZagrebKey","operator":"is","values":[{"type":"KVA","parent":"' + kvaKey.Id + '","name":"London","id":"' + kvaValue.Id +'","hasChildren":false,"data":{"csdf__Ad_Server_Id__c":"#55994910178"}}],"csdf__Ad_Server_Id__c":"#198058"}]],"holistic":[]}';
        targetingTemplate2.csdf__Type__c = 'Standard'; // CLT
        insert targetingTemplate2;

        csdf__Geo_Item_Targeting_Template__c gitt2 = new csdf__Geo_Item_Targeting_Template__c();
        gitt2.csdf__Creative_Targeting_Only__c = false;
        gitt2.csdf__Exclude__c = true;
        gitt2.csdf__Geo_Item__c = geoItemParent.Id;
        gitt2.csdf__Targeting_Template__c = targetingTemplate2.Id;
        gitt2.csdf__Target_Name__c = null;

        csdf__Targetable_Targeting_Template__c ttt4 = new csdf__Targetable_Targeting_Template__c();
        ttt4.csdf__Creative_Targeting_Only__c = false;
        ttt4.csdf__Exclude__c = true;
        ttt4.csdf__Targetable__c = targDeviceCategory.Id;
        ttt4.csdf__Targeting_Template__c = targetingTemplate2.Id;
        ttt4.csdf__Target_Name__c = null;

        csdf__Targetable_Targeting_Template__c ttt5 = new csdf__Targetable_Targeting_Template__c();
        ttt5.csdf__Creative_Targeting_Only__c = false;
        ttt5.csdf__Exclude__c = true;
        ttt5.csdf__Targetable__c = targetableDeviceManufacturer.Id;
        ttt5.csdf__Targeting_Template__c = targetingTemplate2.Id;
        ttt5.csdf__Target_Name__c = null;

        csdf__Targetable_Targeting_Template__c ttt6 = new csdf__Targetable_Targeting_Template__c();
        ttt6.csdf__Creative_Targeting_Only__c = false;
        ttt6.csdf__Exclude__c = true;
        ttt6.csdf__Targetable__c = targMobileCarrier.Id;
        ttt6.csdf__Targeting_Template__c = targetingTemplate2.Id;
        ttt6.csdf__Target_Name__c = null;

        csdf__Targetable_Targeting_Template__c ttt14 = new csdf__Targetable_Targeting_Template__c();
        ttt14.csdf__Creative_Targeting_Only__c = false;
        ttt14.csdf__Exclude__c = true;
        ttt14.csdf__Targetable__c = targBandwidthGroup.Id;
        ttt14.csdf__Targeting_Template__c = targetingTemplate2.Id;
        ttt14.csdf__Target_Name__c = null;

        csdf__Targetable_Targeting_Template__c ttt18 = new csdf__Targetable_Targeting_Template__c();
        ttt18.csdf__Creative_Targeting_Only__c = false;
        ttt18.csdf__Exclude__c = true;
        ttt18.csdf__Targetable__c = targDeviceCapability.Id;
        ttt18.csdf__Targeting_Template__c = targetingTemplate2.Id;
        ttt18.csdf__Target_Name__c = null;

        csdf__Browser_Targeting_Template__c btt2 = new csdf__Browser_Targeting_Template__c();
        btt2.csdf__Browser__c = browser.Id;
        btt2.csdf__Creative_Targeting_Only__c = false;
        btt2.csdf__Exclude__c = true;
        btt2.csdf__Targeting_Template__c = targetingTemplate2.Id;
        btt2.csdf__Target_Name__c = null;

        csdf__Operating_System_Targeting_Template__c ostt2 = new csdf__Operating_System_Targeting_Template__c();
        ostt2.csdf__Creative_Targeting_Only__c = false;
        ostt2.csdf__Exclude__c = true;
        ostt2.csdf__Operating_System__c = opSystem.Id;
        ostt2.csdf__Targeting_Template__c = targetingTemplate2.Id;
        ostt2.csdf__Target_Name__c = null;

        csdf__Operating_System_Version_Target_Template__c osvtt2 = new csdf__Operating_System_Version_Target_Template__c();
        osvtt2.csdf__Creative_Targeting_Only__c = false;
        osvtt2.csdf__Exclude__c =  true;
        osvtt2.csdf__Operating_System_Version__c = opSystemVersion.Id;
        osvtt2.csdf__Targeting_Template__c = targetingTemplate2.Id;
        osvtt2.csdf__Target_Name__c = null;


        // targeting template CLT 1
        targetingTemplateCLT1 = new csdf__Targeting_Template__c();
        targetingTemplateCLT1.Name = 'targ templ CLT incl';
        targetingTemplateCLT1.csdf__Ad_Server__c = adServer.Id;
        targetingTemplateCLT1.csdf__Type__c = 'CLT';
        insert targetingTemplateCLT1;

        csdf__Geo_Item_Targeting_Template__c gitt3 = new csdf__Geo_Item_Targeting_Template__c();
        gitt3.csdf__Creative_Targeting_Only__c = true;
        gitt3.csdf__Exclude__c = false;
        gitt3.csdf__Geo_Item__c = geoItemParent.Id;
        gitt3.csdf__Targeting_Template__c = targetingTemplateCLT1.Id;
        gitt3.csdf__Target_Name__c = 'targ templ CLT incl';

        csdf__Targetable_Targeting_Template__c ttt7 = new csdf__Targetable_Targeting_Template__c();
        ttt7.csdf__Creative_Targeting_Only__c = true;
        ttt7.csdf__Exclude__c = false;
        ttt7.csdf__Targetable__c = targDeviceCategory.Id;
        ttt7.csdf__Targeting_Template__c = targetingTemplateCLT1.Id;
        ttt7.csdf__Target_Name__c = 'targ templ CLT incl';

        csdf__Targetable_Targeting_Template__c ttt8 = new csdf__Targetable_Targeting_Template__c();
        ttt8.csdf__Creative_Targeting_Only__c = true;
        ttt8.csdf__Exclude__c = false;
        ttt8.csdf__Targetable__c = targetableDeviceManufacturer.Id;
        ttt8.csdf__Targeting_Template__c = targetingTemplateCLT1.Id;
        ttt8.csdf__Target_Name__c = 'targ templ CLT incl';

        csdf__Targetable_Targeting_Template__c ttt9 = new csdf__Targetable_Targeting_Template__c();
        ttt9.csdf__Creative_Targeting_Only__c = true;
        ttt9.csdf__Exclude__c = false;
        ttt9.csdf__Targetable__c = targMobileCarrier.Id;
        ttt9.csdf__Targeting_Template__c = targetingTemplateCLT1.Id;
        ttt9.csdf__Target_Name__c = 'targ templ CLT incl';

        csdf__Targetable_Targeting_Template__c ttt15 = new csdf__Targetable_Targeting_Template__c();
        ttt15.csdf__Creative_Targeting_Only__c = true;
        ttt15.csdf__Exclude__c = false;
        ttt15.csdf__Targetable__c = targBandwidthGroup.Id;
        ttt15.csdf__Targeting_Template__c = targetingTemplateCLT1.Id;
        ttt15.csdf__Target_Name__c = 'targ templ CLT incl';

        csdf__Targetable_Targeting_Template__c ttt19 = new csdf__Targetable_Targeting_Template__c();
        ttt19.csdf__Creative_Targeting_Only__c = true;
        ttt19.csdf__Exclude__c = false;
        ttt19.csdf__Targetable__c = targDeviceCapability.Id;
        ttt19.csdf__Targeting_Template__c = targetingTemplateCLT1.Id;
        ttt19.csdf__Target_Name__c = 'targ templ CLT incl';

        csdf__Browser_Targeting_Template__c btt3 = new csdf__Browser_Targeting_Template__c();
        btt3.csdf__Browser__c = browser.Id;
        btt3.csdf__Creative_Targeting_Only__c = true;
        btt3.csdf__Exclude__c = false;
        btt3.csdf__Targeting_Template__c = targetingTemplateCLT1.Id;
        btt3.csdf__Target_Name__c = 'targ templ CLT incl';

        csdf__Operating_System_Targeting_Template__c ostt3 = new csdf__Operating_System_Targeting_Template__c();
        ostt3.csdf__Creative_Targeting_Only__c = true;
        ostt3.csdf__Exclude__c = false;
        ostt3.csdf__Operating_System__c = opSystem.Id;
        ostt3.csdf__Targeting_Template__c = targetingTemplateCLT1.Id;
        ostt3.csdf__Target_Name__c = 'targ templ CLT incl';

        csdf__Operating_System_Version_Target_Template__c osvtt3 = new csdf__Operating_System_Version_Target_Template__c();
        osvtt3.csdf__Creative_Targeting_Only__c = true;
        osvtt3.csdf__Exclude__c =  false;
        osvtt3.csdf__Operating_System_Version__c = opSystemVersion.Id;
        osvtt3.csdf__Targeting_Template__c = targetingTemplateCLT1.Id;
        osvtt3.csdf__Target_Name__c = 'targ templ CLT incl';


        // targeting template CLT 2
        targetingTemplateCLT2 = new csdf__Targeting_Template__c();
        targetingTemplateCLT2.Name = 'targ templ CLT excl';
        targetingTemplateCLT2.csdf__Ad_Server__c = adServer.Id;
        targetingTemplateCLT2.csdf__Type__c = 'CLT';
        insert targetingTemplateCLT2;

        csdf__Geo_Item_Targeting_Template__c gitt4 = new csdf__Geo_Item_Targeting_Template__c();
        gitt4.csdf__Creative_Targeting_Only__c = true;
        gitt4.csdf__Exclude__c = true;
        gitt4.csdf__Geo_Item__c = geoItemParent.Id;
        gitt4.csdf__Targeting_Template__c = targetingTemplateCLT2.Id;
        gitt4.csdf__Target_Name__c = 'targ templ CLT excl';

        csdf__Targetable_Targeting_Template__c ttt10 = new csdf__Targetable_Targeting_Template__c();
        ttt10.csdf__Creative_Targeting_Only__c = true;
        ttt10.csdf__Exclude__c = true;
        ttt10.csdf__Targetable__c = targDeviceCategory.Id;
        ttt10.csdf__Targeting_Template__c = targetingTemplateCLT2.Id;
        ttt10.csdf__Target_Name__c = 'targ templ CLT excl';

        csdf__Targetable_Targeting_Template__c ttt11 = new csdf__Targetable_Targeting_Template__c();
        ttt11.csdf__Creative_Targeting_Only__c = true;
        ttt11.csdf__Exclude__c = true;
        ttt11.csdf__Targetable__c = targetableDeviceManufacturer.Id;
        ttt11.csdf__Targeting_Template__c = targetingTemplateCLT2.Id;
        ttt11.csdf__Target_Name__c = 'targ templ CLT excl';

        csdf__Targetable_Targeting_Template__c ttt12 = new csdf__Targetable_Targeting_Template__c();
        ttt12.csdf__Creative_Targeting_Only__c = true;
        ttt12.csdf__Exclude__c = true;
        ttt12.csdf__Targetable__c = targMobileCarrier.Id;
        ttt12.csdf__Targeting_Template__c = targetingTemplateCLT2.Id;
        ttt12.csdf__Target_Name__c = 'targ templ CLT excl';

        csdf__Targetable_Targeting_Template__c ttt16 = new csdf__Targetable_Targeting_Template__c();
        ttt16.csdf__Creative_Targeting_Only__c = true;
        ttt16.csdf__Exclude__c = true;
        ttt16.csdf__Targetable__c = targBandwidthGroup.Id;
        ttt16.csdf__Targeting_Template__c = targetingTemplateCLT2.Id;
        ttt16.csdf__Target_Name__c = 'targ templ CLT excl';

        csdf__Targetable_Targeting_Template__c ttt20 = new csdf__Targetable_Targeting_Template__c();
        ttt20.csdf__Creative_Targeting_Only__c = true;
        ttt20.csdf__Exclude__c = true;
        ttt20.csdf__Targetable__c = targDeviceCapability.Id;
        ttt20.csdf__Targeting_Template__c = targetingTemplateCLT2.Id;
        ttt20.csdf__Target_Name__c = 'targ templ CLT excl';

        csdf__Browser_Targeting_Template__c btt4 = new csdf__Browser_Targeting_Template__c();
        btt4.csdf__Browser__c = browser.Id;
        btt4.csdf__Creative_Targeting_Only__c = true;
        btt4.csdf__Exclude__c = true;
        btt4.csdf__Targeting_Template__c = targetingTemplateCLT2.Id;
        btt4.csdf__Target_Name__c = 'targ templ CLT excl';

        csdf__Operating_System_Targeting_Template__c ostt4 = new csdf__Operating_System_Targeting_Template__c();
        ostt4.csdf__Creative_Targeting_Only__c = true;
        ostt4.csdf__Exclude__c = true;
        ostt4.csdf__Operating_System__c = opSystem.Id;
        ostt4.csdf__Targeting_Template__c = targetingTemplateCLT2.Id;
        ostt4.csdf__Target_Name__c = 'targ templ CLT excl';

        csdf__Operating_System_Version_Target_Template__c osvtt4 = new csdf__Operating_System_Version_Target_Template__c();
        osvtt4.csdf__Creative_Targeting_Only__c = true;
        osvtt4.csdf__Exclude__c =  true;
        osvtt4.csdf__Operating_System_Version__c = opSystemVersion.Id;
        osvtt4.csdf__Targeting_Template__c = targetingTemplateCLT2.Id;
        osvtt4.csdf__Target_Name__c = 'targ templ CLT excl';

        // insert new List<Ad_Slot_Targeting_Template__c> {astt11, astt12, astt21, astt22};
        insert new List<csdf__Geo_Item_Targeting_Template__c>{gitt1, gitt2, gitt3, gitt4};
        insert new List<csdf__Targetable_Targeting_Template__c>{ttt1, ttt2, ttt3, ttt4, ttt5, ttt6, ttt7, ttt8, ttt9, ttt10, ttt11, ttt12, ttt13, ttt14, ttt15, ttt16, ttt17, ttt18, ttt19, ttt20};
        insert new List<csdf__Browser_Targeting_Template__c>{btt1, btt2, btt3, btt4};
        insert new List<csdf__Operating_System_Targeting_Template__c>{ostt1, ostt2, ostt3, ostt4};
        insert new List<csdf__Operating_System_Version_Target_Template__c>{osvtt1, osvtt2, osvtt3, osvtt4};
    }

    @isTest
    private static void testMTW() {
        createTestData();

        // Error
        Map<String, Object> req = new Map<String, Object>{
                'targetType' => new List<String> {'123', '456'},
                'boo' => 'haa'
        };
        System.assertEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // InitialData
        req = new Map<String, Object>{
                'targetType' => 'InitialData',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => false,
                'data' => new Map<String, Object> {
                        'adSlotTemplates' => JSON.serialize(new List<String>()),
                        'targetingTemplates' => JSON.serialize(new List<String>())
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // Sections
        req = new Map<String, Object>{
                'targetType' => 'Sections',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => false,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // LoadData
        req = new Map<String, Object>{
                'targetType' => 'LoadData',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => false,
                'data' => new Map<String, Object> {
                        'payload' => JSON.serialize(new Map<String, Object> {
                                'AdSlots' => new List<String>{adUnit.Id, '123'},
                                'Browsers' => new List<String>{browser.Id, '123'},
                                'DeviceCategories' => new List<String>{targDeviceCategory.Id, '123'},
                                'DeviceManufacturer' => new List<String>{targetableDeviceManufacturer.Id, '123'},
                                'Geography' => new List<String>{geoItemChild.Id, geoItemParent.Id, '123'},
                                'KvaAudienceValues' => new List<String>{},
                                'KvaKeys' => new List<String>{},
                                'KvaValues' => new List<String>{},
                                'MobileCarrier' => new List<String>{targMobileCarrier.Id, '123'},
                                'OperatingSystemVersions' => new List<String>{opSystem.Id, '123'},
                                'OperatingSystems' => new List<String>{opSystemVersion.Id, '123'},
                                'BandwidthGroup' => new List<String>{targBandwidthGroup.Id, '123'},
                                'DeviceCapability' => new List<String>{targDeviceCapability.Id, '123'}
                        }),
                        'marker' => 'test'
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // TemplateList
        req = new Map<String, Object>{
                'targetType' => 'TemplateList',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateList',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'type' => 'non-existing'
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateList',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'type' => 'adSlots'
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateList',
                'parent' => 'ad slot te',
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'type' => 'adSlots'
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateList',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'type' => 'targeting'
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateList',
                'parent' => 'targ tem',
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'type' => 'targeting'
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateList',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'type' => 'targeting',
                        'targetingTemplateType' => 'CLT'
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateList',
                'parent' => 'targ te',
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'type' => 'targeting',
                        'targetingTemplateType' => 'CLT'
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // TemplateLoad
        // req = new Map<String, Object>{
        //         'targetType' => 'TemplateLoad',
        //         'parent' => null,
        //         'adServer' => adServer.Id,
        //         'getAllSubItemsAtOnce' => null,
        //         'data' => new Map<String, Object> {
        //                 'adSlotTemplates' => JSON.serialize(new List<String>{adSlotTemplate1.Id, adSlotTemplate2.Id}),
        //                 'targetingTemplates' => JSON.serialize(new List<String>{targetingTemplate1.Id, targetingTemplate2.Id, targetingTemplateCLT1.Id, targetingTemplateCLT2.Id})
        //         }
        // };
        // System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // TemplateSave
        req = new Map<String, Object>{
                'targetType' => 'TemplateSave',
                'parent' => 'test new adsl templ 1',
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'templateType' => 'adSlots',
                        'templateData' => JSON.serialize(new Map<String, Object>{
                                'AdSlots' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{adUnit.Id, placement.Id}
                                }
                        })
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateSave',
                'parent' => 'test new adsl templ 2',
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'templateType' => 'adSlots',
                        'templateData' => JSON.serialize(new Map<String, Object>{
                                'AdSlots' => new Map<String, Object> {
                                        'include' => new List<String>{adUnit.Id, placement.Id},
                                        'exclude' => new List<String>{}
                                }
                        })
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateSave',
                'parent' => 'test new targ templ 1',
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'templateType' => 'targeting',
                        'templateData' => JSON.serialize(new Map<String, Object>{
                                'KVA' => new Map<String, Object> {
                                        'JSON' => '{"custom":[[{"id":"' + kvaKey.Id + '","item":null,"label":"ZagrebKey","operator":"is","values":[{"type":"KVA","parent":"' + kvaKey.Id + '","name":"London","id":"' + kvaValue.Id +'","hasChildren":false,"data":{"csdf__Ad_Server_Id__c":"#55994910178"}}],"csdf__Ad_Server_Id__c":"#198058"}]],"holistic":[]}',
                                        'query' => '#11823193 is #448034020020 AND #11889798 is #448094763862'
                                },
                                'Geography' => new Map<String, Object> {
                                        'include' => new List<String>{geoItemParent.Id},
                                        'exclude' => new List<String>{}
                                },
                                'Browsers' => new Map<String, Object> {
                                        'include' => new List<String>{browser.Id},
                                        'exclude' => new List<String>{}
                                },
                                'OperatingSystems' => new Map<String, Object> {
                                        'include' => new List<String>{opSystem.Id},
                                        'exclude' => new List<String>{}
                                },
                                'OperatingSystemVersions' => new Map<String, Object> {
                                        'include' => new List<String>{opSystemVersion.Id},
                                        'exclude' => new List<String>{}
                                },
                                'Targetables' => new Map<String, Object> {
                                        'include' => new List<String>{targDeviceCategory.Id, targetableDeviceManufacturer.Id, targMobileCarrier.Id, targBandwidthGroup.Id, targDeviceCapability.Id},
                                        'exclude' => new List<String>{}
                                }
                        })
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateSave',
                'parent' => 'test new targ templ 2',
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'templateType' => 'targeting',
                        'templateData' => JSON.serialize(new Map<String, Object>{
                                'KVA' => new Map<String, Object> {
                                        'JSON' => '{"custom":[[{"id":"' + kvaKey.Id + '","item":null,"label":"ZagrebKey","operator":"is","values":[{"type":"KVA","parent":"' + kvaKey.Id + '","name":"London","id":"' + kvaValue.Id +'","hasChildren":false,"data":{"csdf__Ad_Server_Id__c":"#55994910178"}}],"csdf__Ad_Server_Id__c":"#198058"}]],"holistic":[]}',
                                        'query' => '#11823193 is #448034020020 AND #11889798 is #448094763862'
                                },
                                'Geography' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{geoItemParent.Id}
                                },
                                'Browsers' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{browser.Id}
                                },
                                'OperatingSystems' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{opSystem.Id}
                                },
                                'OperatingSystemVersions' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{opSystemVersion.Id}
                                },
                                'Targetables' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{targDeviceCategory.Id, targetableDeviceManufacturer.Id, targMobileCarrier.Id, targBandwidthGroup.Id, targDeviceCapability.Id}
                                }
                        })
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateSave',
                'parent' => 'test new targ templ CLT 1',
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'templateType' => 'targeting',
                        'targetingTemplateType' => 'CLT',
                        'templateData' => JSON.serialize(new Map<String, Object>{
                                'Geography' => new Map<String, Object> {
                                        'include' => new List<String>{geoItemParent.Id},
                                        'exclude' => new List<String>{}
                                },
                                'Browsers' => new Map<String, Object> {
                                        'include' => new List<String>{browser.Id},
                                        'exclude' => new List<String>{}
                                },
                                'OperatingSystems' => new Map<String, Object> {
                                        'include' => new List<String>{opSystem.Id},
                                        'exclude' => new List<String>{}
                                },
                                'OperatingSystemVersions' => new Map<String, Object> {
                                        'include' => new List<String>{opSystemVersion.Id},
                                        'exclude' => new List<String>{}
                                },
                                'Targetables' => new Map<String, Object> {
                                        'include' => new List<String>{targDeviceCategory.Id, targetableDeviceManufacturer.Id, targMobileCarrier.Id, targBandwidthGroup.Id, targDeviceCapability.Id},
                                        'exclude' => new List<String>{}
                                }
                        })
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'TemplateSave',
                'parent' => 'test new targ templ CLT 2',
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'templateType' => 'targeting',
                        'targetingTemplateType' => 'CLT',
                        'templateData' => JSON.serialize(new Map<String, Object>{
                                'Geography' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{geoItemParent.Id}
                                },
                                'Browsers' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{browser.Id}
                                },
                                'OperatingSystems' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{opSystem.Id}
                                },
                                'OperatingSystemVersions' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{opSystemVersion.Id}
                                },
                                'Targetables' => new Map<String, Object> {
                                        'include' => new List<String>{},
                                        'exclude' => new List<String>{targDeviceCategory.Id, targetableDeviceManufacturer.Id, targMobileCarrier.Id, targBandwidthGroup.Id, targDeviceCapability.Id}
                                }
                        })
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // LoadMultiple
        req = new Map<String, Object>{
                'targetType' => 'LoadMultiple',
                'parent' => null,
                'adServer' => null,
                'getAllSubItemsAtOnce' => false,
                'data' => new Map<String, Object> {
                        'items' => null
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'LoadMultiple',
                'parent' => null,
                'adServer' => null,
                'getAllSubItemsAtOnce' => false,
                'data' => new Map<String, Object> {
                        'items' => 'not guuud items'
                }
        };
        System.assertEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'LoadMultiple',
                'parent' => null,
                'adServer' => null,
                'getAllSubItemsAtOnce' => false,
                'data' => new Map<String, Object> {
                        'items' => JSON.serialize(new List<Map<String, Object>>{
                                new Map<String, Object>{
                                        'targetType' => 'AdSlots',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                },
                                new Map<String, Object>{
                                        'targetType' => 'Geography',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                },
                                new Map<String, Object>{
                                        'targetType' => 'Geography',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{
                                                'query' => 'bla'
                                        }
                                },
                                new Map<String, Object>{
                                        'targetType' => 'Browsers',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                },
                                new Map<String, Object>{
                                        'targetType' => 'DeviceCategories',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                },
                                new Map<String, Object>{
                                        'targetType' => 'DeviceManufacturer',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                },
                                new Map<String, Object>{
                                        'targetType' => 'MobileCarrier',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                },
                                new Map<String, Object>{
                                        'targetType' => 'OperatingSystems',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                },
                                new Map<String, Object>{
                                        'targetType' => 'KVA',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                },
                                new Map<String, Object>{
                                        'targetType' => 'ZipCodes',
                                        'parent' => '1234',
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                },
                                new Map<String, Object>{
                                        'targetType' => 'BandwidthGroup',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                },
                                new Map<String, Object>{
                                        'targetType' => 'DeviceCapability',
                                        'parent' => null,
                                        'adServer' => adServer.Id,
                                        'getAllSubItemsAtOnce' => true,
                                        'data' => new Map<String, Object>{}
                                }
                        })
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // AdSlots
        req = new Map<String, Object>{
                'targetType' => 'AdSlots',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // Geography
        req = new Map<String, Object>{
                'targetType' => 'Geography',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // Geography
        req = new Map<String, Object>{
                'targetType' => 'Geography',
                'parent' => geoItemParent.Id,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => true,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'Geography',
                'parent' => geoItemParent.Id,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => false,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // Browsers
        req = new Map<String, Object>{
                'targetType' => 'Browsers',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // DeviceCategories
        req = new Map<String, Object>{
                'targetType' => 'DeviceCategories',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => true,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'DeviceCategories',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => false,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // DeviceManufacturer
        req = new Map<String, Object>{
                'targetType' => 'DeviceManufacturer',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => true,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'DeviceManufacturer',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => false,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // BandwidthGroup
        req = new Map<String, Object>{
                'targetType' => 'BandwidthGroup',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => true,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'BandwidthGroup',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => false,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // DeviceCapability
        req = new Map<String, Object>{
                'targetType' => 'DeviceCapability',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => true,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'DeviceCapability',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => false,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // MobileCarrier
        req = new Map<String, Object>{
                'targetType' => 'MobileCarrier',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => true,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'MobileCarrier',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => false,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // OperatingSystems
        req = new Map<String, Object>{
                'targetType' => 'OperatingSystems',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // OperatingSystemVersions
        req = new Map<String, Object>{
                'targetType' => 'OperatingSystems',
                'parent' => opSystem.Id,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // KVA key
        req = new Map<String, Object>{
                'targetType' => 'KVA',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // KVA value
        req = new Map<String, Object>{
                'targetType' => 'KVA',
                'parent' => kvaKey.Id,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // KVA audience value
        req = new Map<String, Object>{
                'targetType' => 'KVA',
                'parent' => 'Audience Segment',
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        // ZipCodes
        req = new Map<String, Object>{
                'targetType' => 'ZipCodes',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'searchText' => '1234'
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'ZipCodes',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => new Map<String, Object> {
                        'searchText' => 'AB/1234'
                }
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        req = new Map<String, Object>{
                'targetType' => 'Blaaah',
                'parent' => null,
                'adServer' => adServer.Id,
                'getAllSubItemsAtOnce' => null,
                'data' => null
        };
        System.assertNotEquals(null, MediaTargetingWidget.performAction(JSON.serialize(req)));

        System.assertEquals('', MediaTargetingWidgetQueries.getFieldListAsCSV('tstttt'));
        System.assertNotEquals(null, MediaTargetingWidgetDataLoader.loadTemplate(null));
        System.assertNotEquals(null, MediaTargetingWidgetDataLoader.getData(new Map<String, String>{
                'payload' => null
        }));
    }

    private static void setupMTWSections() {
        List<Media_Targeting_Widget_Sections__c> mtwSections = new List<Media_Targeting_Widget_Sections__c>{
                new Media_Targeting_Widget_Sections__c(
                        Name = 'AdSlots',
                        Attribute_Name__c = 'Ad_Slot_0',
                        Auto_Update_Configuration__c = true,
                        Include_Exclude_Logic_Type__c = 2,
                        Label__c = 'Inventory',
                        Order__c = 1,
                        Parent_Section__c = null,
                        Tabs_List__c = 'search'
                ),
                new Media_Targeting_Widget_Sections__c(
                        Name = 'Browsers',
                        Attribute_Name__c = 'Browsers_0',
                        Auto_Update_Configuration__c = true,
                        Include_Exclude_Logic_Type__c = 1,
                        Label__c = 'Browsers',
                        Order__c = 1,
                        Parent_Section__c = 'Devices',
                        Tabs_List__c = 'search'
                ),
                new Media_Targeting_Widget_Sections__c(
                        Name = 'Devices',
                        Attribute_Name__c = 'Devices_0',
                        Auto_Update_Configuration__c = true,
                        Include_Exclude_Logic_Type__c = null,
                        Label__c = 'Devices',
                        Order__c = 2,
                        Parent_Section__c = null,
                        Tabs_List__c = null
                )
        };
        insert mtwSections;
    }

    private static void setupMTWSettings(String adServerId) {
        Media_Targeting_Widget_Settings__c mtwSettings = new Media_Targeting_Widget_Settings__c();
        mtwSettings.Audience_Segment_Label__c = 'Audience Test Label';
        mtwSettings.Default_Ad_Server_Id__c = adServerId;
        mtwSettings.Show_Audience_Segment__c = true;
        mtwSettings.Show_KeyValue_Ids_Instead_Of_Names__c = true;
        insert mtwSettings;
    }
}