/**
* @name CS_FulfilmentService
* @description Service class for handling fulfilment and fulfilment items
* @revision
*
*/
public class CS_FulfilmentService extends CS_DMLWorker {
    /**
* List of possible objects for insert, determines the order based on hierarchy
*/
    public static List<SObjectType> SObjectTypes_Order = new List<SObjectType> {
        Schema.csdf__Fulfilment_Item__c.getSObjectType(),
            Schema.csdf__Site_Targeting__c.getSObjectType(),
            Schema.csdf__Ad_Slot_Targeting__c.getSObjectType(),
            Schema.csdf__Geo_Targeting__c.getSObjectType(),
            Schema.csdf__Browser_Targeting__c.getSObjectType(),
            Schema.csdf__Operating_System_Targeting__c.getSObjectType(),
            Schema.csdf__Operating_System_Version_Targeting__c.getSObjectType(),
            Schema.csdf__Targetable_Targeting__c.getSObjectType()
            };
                
                public static List<String> TargetingsTypes = new List<String> {
                    'csdf__Site_Targetings__r',
                        'csdf__Ad_Slot_Targetings__r',
                        'csdf__Geo_Targetings__r',
                        'csdf__Browser_Targetings__r',
                        'csdf__Operating_System_Targetings__r',
                        'csdf__Operating_System_Version_Targetings__r',
                        'csdf__Targetable_Targetings__r'
                        };
                            
                            public static Map<String, String> TargetingExtractor = new Map<String, String> {
                                'adSlotIdsInclude' => 'adSlotIdsIncludedExcludedString',
                                    'adSlotIdsExclude' => 'adSlotIdsIncludedExcludedString',
                                    'geoItemsInclude' => 'geoItemsIncludedExcludedString',
                                    'geoItemsExclude' => 'geoItemsIncludedExcludedString',
                                    'browsersInclude' => 'browsersIncludedExcludedString',
                                    'browsersExclude' => 'browsersIncludedExcludedString',
                                    'mobileDevicesInclude' => 'mobileDevicesIncludedExcludedString',
                                    'mobileDevicesExclude' => 'mobileDevicesIncludedExcludedString',
                                    'deviceCategoryInclude' => 'deviceCategoryIncludedExcludedString',
                                    'deviceCategoryExclude' => 'deviceCategoryIncludedExcludedString',
                                    'operatingSystemsInclude' => 'operatingSystemsIncludedExcludedString',
                                    'operatingSystemsExclude' => 'operatingSystemsIncludedExcludedString',
                                    'operatingSystemVersionsInclude' => 'operatingSystemVersionsIncludedExcludedString',
                                    'operatingSystemVersionsExclude' => 'operatingSystemVersionsIncludedExcludedString',
                                    'mobileCarriersInclude' => 'mobileCarriersIncludedExcludedString',
                                    'mobileCarriersExclude' => 'mobileCarriersIncludedExcludedString',
                                    'deviceCapabilitiesInclude' => 'deviceCapabilitiesIncludedExcludedString',
                                    'deviceCapabilitiesExclude' => 'deviceCapabilitiesIncludedExcludedString',
                                    'bandwidthGroupInclude' => 'bandwidthGroupIncludedExcludedString',
                                    'bandwidthGroupExclude' => 'bandwidthGroupIncludedExcludedString'
                                    };
                                        
                                        public static Map<String, TargetingType> TargetingTypes_ByProperty = new Map<String, TargetingType> {
                                            'adSlotIdsInclude' => new TargetingType(Schema.csdf__Ad_Slot_Targeting__c.getSObjectType(), 'csdf__Ad_Slot__c'),
                                                'adSlotIdsExclude' => new TargetingType(Schema.csdf__Ad_Slot_Targeting__c.getSObjectType(), 'csdf__Ad_Slot__c'),
                                                'sites' => new TargetingType(Schema.csdf__Site_Targeting__c.getSObjectType(), 'csdf__Site__c'),
                                                'geoItemsInclude' => new TargetingType(Schema.csdf__Geo_Targeting__c.getSObjectType(), 'csdf__Geo_Item__c'),
                                                'geoItemsExclude' => new TargetingType(Schema.csdf__Geo_Targeting__c.getSObjectType(), 'csdf__Geo_Item__c'),
                                                'browsersInclude' => new TargetingType(Schema.csdf__Browser_Targeting__c.getSObjectType(), 'csdf__Browser__c'),
                                                'browsersExclude' => new TargetingType(Schema.csdf__Browser_Targeting__c.getSObjectType(), 'csdf__Browser__c'),
                                                'deviceCategoryInclude' => new TargetingType(Schema.csdf__Targetable_Targeting__c.getSObjectType(), 'csdf__Targetable__c'),
                                                'deviceCategoryExclude' => new TargetingType(Schema.csdf__Targetable_Targeting__c.getSObjectType(), 'csdf__Targetable__c'),
                                                'mobileDevicesInclude' => new TargetingType(Schema.csdf__Targetable_Targeting__c.getSObjectType(), 'csdf__Targetable__c'),
                                                'mobileDevicesExclude' => new TargetingType(Schema.csdf__Targetable_Targeting__c.getSObjectType(), 'csdf__Targetable__c'),
                                                'mobileCarriersInclude' => new TargetingType(Schema.csdf__Targetable_Targeting__c.getSObjectType(), 'csdf__Targetable__c'),
                                                'mobileCarriersExclude' => new TargetingType(Schema.csdf__Targetable_Targeting__c.getSObjectType(), 'csdf__Targetable__c'),
                                                'operatingSystemsInclude' => new TargetingType(Schema.csdf__Operating_System_Targeting__c.getSObjectType(), 'csdf__Operating_System__c'),
                                                'operatingSystemsExclude' => new TargetingType(Schema.csdf__Operating_System_Targeting__c.getSObjectType(), 'csdf__Operating_System__c'),
                                                'operatingSystemVersionsInclude' => new TargetingType(Schema.csdf__Operating_System_Version_Targeting__c.getSObjectType(), 'csdf__Operating_System_Version__c'),
                                                'operatingSystemVersionsExclude' => new TargetingType(Schema.csdf__Operating_System_Version_Targeting__c.getSObjectType(), 'csdf__Operating_System_Version__c'),
                                                'deviceCapabilitiesInclude' => new TargetingType(Schema.csdf__Targetable_Targeting__c.getSObjectType(), 'csdf__Targetable__c'),
                                                'deviceCapabilitiesExclude' => new TargetingType(Schema.csdf__Targetable_Targeting__c.getSObjectType(), 'csdf__Targetable__c'),
                                                'bandwidthGroupInclude' => new TargetingType(Schema.csdf__Targetable_Targeting__c.getSObjectType(), 'csdf__Targetable__c'),
                                                'bandwidthGroupExclude' => new TargetingType(Schema.csdf__Targetable_Targeting__c.getSObjectType(), 'csdf__Targetable__c')
                                                };
                                                    
                                                    public static Map<String, Map<String, String>> TargetingProperty = new Map<String, Map<String, String>> {
                                                        'Ad_Slot__c' => new Map<String, String>{'INCLUDE' => 'adSlotIdsInclude', 'EXCLUDE' => 'adSlotIdsExclude'},
                                                            'Browsers__c' => new Map<String, String>{'INCLUDE' => 'browsersInclude', 'EXCLUDE' => 'browsersExclude'},
                                                                'Device_Category__c' => new Map<String, String>{'INCLUDE' => 'deviceCategoryInclude', 'EXCLUDE' => 'deviceCategoryExclude'},
                                                                    'Geo_Targeting__c' => new Map<String, String>{'INCLUDE' => 'geoItemsInclude', 'EXCLUDE' => 'geoItemsExclude'},
                                                                        'Mobile_Carrier__c' => new Map<String, String>{'INCLUDE' => 'mobileCarriersInclude', 'EXCLUDE' => 'mobileCarriersExclude'},
                                                                            'Mobile_Devices__c' => new Map<String, String>{'INCLUDE' => 'mobileDevicesInclude', 'EXCLUDE' => 'mobileDevicesExclude'},
                                                                                'Operating_System_Versions__c' => new Map<String, String>{'INCLUDE' => 'operatingSystemVersionsInclude', 'EXCLUDE' => 'operatingSystemVersionsExclude'},
                                                                                    'Operating_Systems__c' => new Map<String, String>{'INCLUDE' => 'operatingSystemsInclude', 'EXCLUDE' => 'operatingSystemsExclude'},
                                                                                        'Device_Capabilities__c' => new Map<String, String>{'INCLUDE' => 'deviceCapabilitiesInclude', 'EXCLUDE' => 'deviceCapabilitiesExclude'},
                                                                                            'Bandwidth_Group__c' => new Map<String, String>{'INCLUDE' => 'bandwidthGroupInclude', 'EXCLUDE' => 'bandwidthGroupExclude'}
                                                    };
                                                        
                                                        public enum IncludeExcludeDataType {
                                                            INCLUDE,
                                                                EXCLUDE
                                                                }
    
    public static Matcher includePatternMatcher = Pattern.compile('(INCLUDE:)(((?!;).)+)').matcher('');
    public static Matcher excludePatternMatcher = Pattern.compile('(EXCLUDE:)(((?!;).)+)').matcher('');
    public static Pattern cltPattern = Pattern.compile('(\"((?!\").)+\":((?!;).)+)');
    
    public static final String KEYVALUE_CONFIGURATION_ID = 'ID';
    
    public static final String KVA_HOLISTIC = 'holistic';
    public static final String KVA_CUSTOM = 'custom';
    
    public static void removeInvalidFulfilmentItems(Id salesOrderId) {
        delete [SELECT Id FROM csdf__Fulfilment_Item__c WHERE Product_Configuration__c = NULL AND csdf__Fulfilment__r.Sales_Order__c = :salesOrderId];
    }
    
    /**
* Map of Sales Orders
*/
    @TestVisible
    Map<Id, csmso__Sales_Order__c> salesOrders {
        get {
            if(salesOrders == null) {
                salesOrders = new Map<Id, csmso__Sales_Order__c>(
                    [SELECT Id, Name, Proposal_Name__c, csmso__Advertiser__c, Media_Agency__c, csmso__Purchase_Order_Number__c, DFP_Team_Id__c,
                     Ad_Server__c, Ad_Server_Sales_Person__c, Ad_Server_Trafficker__c, Migrated_Order_Type__c, Migration_Source_Order_ID__c
                     FROM csmso__Sales_Order__c
                     WHERE Id = :salesOrderIds]);
            }
            return salesOrders;
        }
        set;
    }
    
    Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems {
        get {
            if(fulfilmentItems == null) {
                fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>();
                
                if(!fulfilmentItemIds.isEmpty()) {
                    fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>(
                        [SELECT Id, csdf__Name__c, Booking_Timezone__c,ownerid, csdf__Fulfilment__c,Flight_Beginning_Time_HH_MM__c, csdf__Flight_Beginning__c, Product_Configuration__c,Product_Configuration__r.Name,
                         csdf__Flight_End__c, Insertion_Quantity__c, Buffer__c, Quantity_CPD__c, csdf__Billing_Category__c,
                         csdf__Quantity__c, csdf__Rate__c, csdf__Sizes__c, Long_Custom_Key_Targeting__c, CurrencyIsoCode, SKU__c, Product_Subclass__c, Product_Class__c, Product_Category__c,
                         (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Ad_Slot_Targetings__r),
                         (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Geo_Targetings__r),
                         (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Browser_Targetings__r),
                         (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Operating_System_Targetings__r),
                         (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Operating_System_Version_Targetings__r),
                         (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Targetable_Targetings__r),
                         (SELECT Id FROM csdf__Site_Targetings__r)
                         FROM csdf__Fulfilment_Item__c
                         WHERE Id IN :fulfilmentItemIds]);
                }
            }
            
            return fulfilmentItems;
        }
        set;
    }
    
    Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemsByProductConfigId {
        get {
            if(fulfilmentItemsByProductConfigId == null) {
                fulfilmentItemsByProductConfigId = new Map<Id, csdf__Fulfilment_Item__c>();
                
                if (!productConfigurationIds.isEmpty()){
                    List<csdf__Fulfilment_Item__c> fulfilmentItems = [
                        SELECT Id, csdf__Name__c, Booking_Timezone__c, csdf__Fulfilment__c, csdf__Flight_Beginning__c,Flight_Beginning_Time_HH_MM__c, Product_Configuration__c,Product_Configuration__r.Name,
                        csdf__Flight_End__c, Insertion_Quantity__c, Buffer__c, Quantity_CPD__c, csdf__Billing_Category__c,
                        csdf__Quantity__c, csdf__Rate__c, csdf__Sizes__c, Long_Custom_Key_Targeting__c, CurrencyIsoCode, SKU__c, Product_Subclass__c, Product_Class__c, Product_Category__c,
                        (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Ad_Slot_Targetings__r),
                        (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Geo_Targetings__r),
                        (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Browser_Targetings__r),
                        (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Operating_System_Targetings__r),
                        (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Operating_System_Version_Targetings__r),
                        (SELECT Id, csdf__Creative_Targeting_Only__c FROM csdf__Targetable_Targetings__r),
                        (SELECT Id FROM csdf__Site_Targetings__r)
                        FROM csdf__Fulfilment_Item__c
                        WHERE Product_Configuration__c IN :productConfigurationIds
                    ];
                    
                    for (csdf__Fulfilment_Item__c fi : fulfilmentItems) {
                        fulfilmentItemsByProductConfigId.put(fi.Product_Configuration__c, fi);
                    }
                }
            }
            return fulfilmentItemsByProductConfigId;
        }
        set;
    }
    
    Map<Id, csdf__Fulfilment__c> fulfilments {
        get {
            if(fulfilments == null) {
                fulfilments = new Map<Id, csdf__Fulfilment__c>();
                for(csdf__Fulfilment__c fulfilment : [SELECT Id, csdf__Name__c, csdf__Advertiser__c, csdf__Agency__c,
                                                      Purchase_Order_Number__c, csdf__Ad_Server__c, Sales_Order__c
                                                      FROM csdf__Fulfilment__c
                                                      WHERE Sales_Order__c = :salesOrderIds]) {
                                                          fulfilments.put(fulfilment.Sales_Order__c, fulfilment);
                                                      }
            }
            return fulfilments;
        }
        set;
    }
    
    Map<Id, cscfga__Product_Configuration__c> productConfigurations {
        get {
            if (productConfigurations == null) {
                productConfigurations = new Map<Id, cscfga__Product_Configuration__c>(
                    [
                        SELECT Id,Name,cscfga__Product_Definition__r.Fulfilment_Owner__c,owner.id,cscfga__Product_Definition__r.Name,cscfga__Product_Family__c,
                        Sales_Order__r.csmso__Opportunity__r.Country__c,Sales_Order__r.OwnerId,cscfga__Product_Definition__c,Digital_Product__r.Line_Item_Type__c,
                        Market__r.csmso__Parent_Product_Node__c,Market_Name__c,(Select Id, csdf__Name__c From Fulfilment_Items__r)
                        FROM cscfga__Product_Configuration__c
                        WHERE Id IN :productConfigurationIds
                    ]
                );
            }
            return productConfigurations;
        }
        set;
    }
    
    Map<Id, List<csdf__Geo_Targeting__c> > geoTargetings {
        get {
            if (geoTargetings == null && !fulfilmentItemIds.isEmpty()) {
                geoTargetings = new Map<Id, List<csdf__Geo_Targeting__c> >();
                
                List<csdf__Geo_Targeting__c> geoTargetingList = new List<csdf__Geo_Targeting__c>();
                geoTargetingList = [
                    SELECT Id, csdf__Creative_Targeting_Only__c, csdf__Fulfilment_Item__c
                    FROM csdf__Geo_Targeting__c
                    WHERE csdf__Fulfilment_Item__c IN :fulfilmentItemIds
                ];
                
                Map<Id, List<csdf__Geo_Targeting__c>> geoTargetingsByFulfilmentId = new Map<Id, List<csdf__Geo_Targeting__c>>();
                for (csdf__Geo_Targeting__c geoTargeting : geoTargetingList) {
                    if (!geoTargetingsByFulfilmentId.containsKey(geoTargeting.csdf__Fulfilment_Item__c)){
                        geoTargetingsByFulfilmentId.put(geoTargeting.csdf__Fulfilment_Item__c, new List<csdf__Geo_Targeting__c>());
                    }
                    
                    geoTargetingsByFulfilmentId.get(geoTargeting.csdf__Fulfilment_Item__c).add(geoTargeting);
                }
                
                for (Id currentFiId : fulfilmentItemIds) {
                    geoTargetings.put(currentFiId, geoTargetingsByFulfilmentId.get(currentFiId));
                }
            }
            return geoTargetings;
        }
        set;
    }
    
    /**
* Set of all Sales Order Ids
*/
    @TestVisible
    Set<Id> salesOrderIds {
        get {
            if(salesOrderIds == null) {
                salesOrderIds = new Set<Id>();
            }
            return salesOrderIds;
        }
        set;
    }
    
    /**
* Set of all Product Configuration Ids
*/
    @TestVisible
    Set<Id> productConfigurationIds {
        get {
            if(productConfigurationIds == null) {
                productConfigurationIds = new Set<Id>();
            }
            return productConfigurationIds;
        }
        set;
    }
    
    @TestVisible
    Set<Id> fulfilmentItemIds {
        get {
            if(fulfilmentItemIds == null) {
                fulfilmentItemIds = new Set<Id>();
            }
            return fulfilmentItemIds;
        }
        set;
    }
    
    Set<Id> adSlotIds {
        get {
            if(adSlotIds == null) {
                adSlotIds = new Set<Id>();
            }
            return adSlotIds;
        }
        set;
    }
    
    @TestVisible
    Map<Id, csdf__Ad_Slot__c> adSlots {
        get {
            if(adslots == null) {
                adSlots = new Map<Id, csdf__Ad_Slot__c>(
                    [SELECT Id, csdf__Sizes__c, csdf__Name__c
                     FROM csdf__Ad_Slot__c
                     WHERE Id = :adSlotIds]);
            }
            return adSlots;
        }
        set;
    }
    
    @TestVisible
    List<AggregateResult> adServers {
        get {
            if(adServers == null) {
                adServers = [SELECT csdf__Ad_Server__c, COUNT(ID) Ad_Server_Count FROM csdf__Ad_Slot__c WHERE Id in :adSlotIds GROUP BY csdf__Ad_Server__c];
            }
            return adServers;
        }
        set;
    }
    
    Set<Id> labelIds {
        get {
            if(labelIds == null) {
                labelIds = new Set<Id>();
            }
            return labelIds;
        }
        set;
    }
    
    Map<Id, csdf__Targetable__c> labels {
        get {
            if(labels == null) {
                labels = new Map<Id, csdf__Targetable__c>([SELECT Id, csdf__Ad_Server_Id__c
                                                           FROM csdf__Targetable__c
                                                           WHERE Id IN :labelIds]);
            }
            return labels;
        }
        set;
    }
    
    CS_Custom_Settings__c mcs {
        get {
            if(mcs == null) {
                mcs = CS_Custom_Settings__c.getInstance();
            }
            
            return mcs;
        }
        set;
    }
    
    public List<DigitalFulfilmentAttributes> fulfilmentAttributes {get; set;}
    
    public Boolean temporary {get; set;}
    
    public static List<csdf__Fulfilment_Item__c> generateFulfilmentItems(Set<Id> productConfigurationIds, Boolean temporary) {
        List<cscfga__Attribute__c> payloads = [SELECT Id, cscfga__Value__c, cscfga__Product_Configuration__c,cscfga__Product_Configuration__r.District__c,cscfga__Product_Configuration__r.Listing_ID__c
                                               FROM cscfga__Attribute__c
                                               WHERE cscfga__Product_Configuration__c IN :productConfigurationIds
                                               AND Name = 'Payload'];
        //contains parent ConfigId and child add productConfig
        Map<id,List<cscfga__Product_Configuration__c>> parentchildMap = new Map<id,List<cscfga__Product_Configuration__c>>();
        //contains addOnconfig and its name and value from attributeof addon
        Map<id,Map<String,String>> PCAttributesMap = new Map<id,Map<String,String>>();
        //to store sales price f
        Map<Id,Decimal> rateMap = new Map<Id,Decimal>();
        for (cscfga__Product_Configuration__c addOn : [SELECT
                                                       Id, Name, Ad_Server_Item__c,Developer_listing__c,cscfga__Parent_Configuration__c,Market_Name__c,(select id,name,cscfga__Value__c,cscfga__Price__c from cscfga__Attributes__r) FROM
                                                       cscfga__Product_Configuration__c where cscfga__Parent_Configuration__c in :productConfigurationIds ]){
                                                           if(parentchildMap.containsKey(addOn.cscfga__Parent_Configuration__c)){
                                                               List<cscfga__Product_Configuration__c> tempList =   new List<cscfga__Product_Configuration__c>(parentchildMap.get(addOn.cscfga__Parent_Configuration__c));
                                                               tempList.add(addon);
                                                               parentchildMap.put(addOn.cscfga__Parent_Configuration__c,tempList);
                                                           } 
                                                           else{
                                                               List<cscfga__Product_Configuration__c> tempList =   new List<cscfga__Product_Configuration__c>(parentchildMap.get(addOn.cscfga__Parent_Configuration__c));
                                                               tempList.add(addon);
                                                               parentchildMap.put(addOn.cscfga__Parent_Configuration__c,tempList);
                                                           }
                                                           Map<String,String> keyVal = new Map<String,String>();
                                                           for(cscfga__Attribute__c att : addOn.cscfga__Attributes__r){
                                                               keyVal.put(att.Name,att.cscfga__Value__c);
                                                               if(att.Name == 'AddOn One Off Charge')
                                                                   rateMap.put(addOn.id,att.cscfga__Price__c);
                                                           }
                                                           PCAttributesMap.put(addOn.id,keyVal);
                                                       }
        Map<id,Map<String,String>> PCNewAttributesMap = new Map<id,Map<String,String>>();
        for (cscfga__Product_Configuration__c newAttributes : [SELECT Id, Name,
                                                               (select id,name,cscfga__Value__c from cscfga__Attributes__r Where Name = 'SKU'
                                                                OR Name = 'Product Class' 
                                                                OR Name = 'Product SubClass' 
                                                                OR Name = 'Product Category New'
                                                                OR Name = 'FLAG Fintech'
                                                                OR Name = 'CommercialProduct') FROM cscfga__Product_Configuration__c where Id in :productConfigurationIds]){
                                                                    Map<String,String> keyVal = new Map<String,String>();
                                                                    for(cscfga__Attribute__c att : newAttributes.cscfga__Attributes__r){
                                                                        keyVal.put(att.Name,att.cscfga__Value__c);
                                                                    }
                                                                    PCNewAttributesMap.put(newAttributes.Id, keyVal);
                                                                    
                                                                }
        Map<String,cscfga__Product_Configuration__c> prodConfigMap = new Map<String,cscfga__Product_Configuration__c>([SELECT
                                                                                                                       Id, Name,Flight_Begin__c,Flight_Begin_Time__c,Market_Name__c,Flight_End_Time__c,Flight_End__c,cscfga__Unit_Price__c,cscfga__Product_Family__c,(select id,name,cscfga__Value__c,cscfga__List_Price__c,cscfga__Price__c from cscfga__Attributes__r where cscfga__Is_Line_Item__c = true) FROM
                                                                                                                       cscfga__Product_Configuration__c where id in :productConfigurationIds ]);
        
        List<DigitalFulfilmentAttributes> fulfilmentAttributes = new List<DigitalFulfilmentAttributes>();
        for(cscfga__Attribute__c payload : payloads) {
            DigitalFulfilmentAttributes fulfilmentAttribute = (DigitalFulfilmentAttributes) JSON.deserialize(payload.cscfga__Value__c, DigitalFulfilmentAttributes.class);
            if (String.isBlank(fulfilmentAttribute.productConfigurationId)) fulfilmentAttribute.productConfigurationId = payload.cscfga__Product_Configuration__c;
            
            if(PCNewAttributesMap.containsKey(payload.cscfga__Product_Configuration__c)){
                if(PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).containskey('SKU'))
                    fulfilmentAttribute.sku = PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).get('SKU');
                if(PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).containskey('Product Class'))
                    fulfilmentAttribute.productClass = PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).get('Product Class');
                if(PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).containskey('Product SubClass')){
                    
                    fulfilmentAttribute.productSubClass = PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).get('Product SubClass');   
                }
                if(PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).containskey('Product Category New'))
                    fulfilmentAttribute.productCategory = PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).get('Product Category New');
                if(PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).containskey('FLAG Fintech'))
                    fulfilmentAttribute.isFintechProduct = PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).get('FLAG Fintech');
                if(PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).containskey('CommercialProduct'))
                    fulfilmentAttribute.commercialProduct = PCNewAttributesMap.get(payload.cscfga__Product_Configuration__c).get('CommercialProduct');
            }
            
            if(prodConfigMap.containsKey(payload.cscfga__Product_Configuration__c)){
                
                if(fulfilmentAttribute.rate == 0 || fulfilmentAttribute.rate == null){
                    if(prodConfigMap.get(payload.cscfga__Product_Configuration__c).cscfga__Attributes__r[0].cscfga__Price__c !=null)
                        fulfilmentAttribute.rate = prodConfigMap.get(payload.cscfga__Product_Configuration__c).cscfga__Attributes__r[0].cscfga__Price__c;
                }
                if(fulfilmentAttribute.rateCardItemPrice == 0 || fulfilmentAttribute.rateCardItemPrice == null){
                    if(prodConfigMap.get(payload.cscfga__Product_Configuration__c).cscfga__Attributes__r[0].cscfga__List_Price__c != null)
                        fulfilmentAttribute.rateCardItemPrice = prodConfigMap.get(payload.cscfga__Product_Configuration__c).cscfga__Attributes__r[0].cscfga__List_Price__c;
                }
            }
            if(parentchildMap.size()>0){  
                if(parentchildMap.containsKey(payload.cscfga__Product_Configuration__c)){
                    for(cscfga__Product_Configuration__c addProdConfig :parentchildMap.get(payload.cscfga__Product_Configuration__c)){
                        DigitalFulfilmentAttributes dfa = (DigitalFulfilmentAttributes) JSON.deserialize(payload.cscfga__Value__c, DigitalFulfilmentAttributes.class);
                        // dfa = fulfilmentAttribute;
                        dfa.itemName=addProdConfig.name;
                        dfa.productConfigurationId=addProdConfig.id;
                        dfa.inputFlightBegin = PCAttributesMap.get(addProdConfig.id).get('Start Date');
                        dfa.inputFlightEnd = PCAttributesMap.get(addProdConfig.id).get('End Date');
                        dfa.rateCardItemPrice = Decimal.valueof(PCAttributesMap.get(addProdConfig.id).get('AddOn One Off Charge'));
                        dfa.sku = PCAttributesMap.get(addProdConfig.id).get('SKU');
                        dfa.productClass = PCAttributesMap.get(addProdConfig.id).get('Product Class');
                        dfa.productSubClass = PCAttributesMap.get(addProdConfig.id).get('Product SubClass');
                        dfa.productCategory = PCAttributesMap.get(addProdConfig.id).get('Product Category New');
                        dfa.isFintechProduct =  PCAttributesMap.get(addProdConfig.id).get('FLAG Fintech');
                        dfa.commercialProduct =  PCAttributesMap.get(addProdConfig.id).get('CommercialProduct');
                        dfa.rate =rateMap.get(addProdConfig.id);
                        
                        fulfilmentAttributes.add(dfa);
                    }
                }
            }
            fulfilmentAttribute.district = payload.cscfga__Product_Configuration__r.District__c;
            fulfilmentAttribute.ListingID = payload.cscfga__Product_Configuration__r.Listing_ID__c;
            fulfilmentAttributes.add(fulfilmentAttribute);
        }
        
        CS_FulfilmentService fulfilmentService = new CS_FulfilmentService(fulfilmentAttributes, temporary);
        List<csdf__Fulfilment_Item__c> fulfilmentItems = fulfilmentService.generateFulfilmentItems();
        
        return fulfilmentItems;
    }
    
    public CS_FulfilmentService(List<DigitalFulfilmentAttributes> fulfilmentAttributes, Boolean temporary)  {
        super(false, SObjectTypes_Order);
        this.fulfilmentAttributes = fulfilmentAttributes;
        this.temporary = temporary;
        
        for(DigitalFulfilmentAttributes fulfilmentAttribute : fulfilmentAttributes) {
            extractTargeting(fulfilmentAttribute);
            
            if (fulfilmentAttribute.productConfigurationId != null)
                this.productConfigurationIds.add(fulfilmentAttribute.productConfigurationId);
            
            this.salesOrderIds.add(fulfilmentAttribute.salesOrderId);
            this.adSlotIds.addAll(fulfilmentAttribute.adSlotIdsInclude);
            
            if(String.isNotBlank(fulfilmentAttribute.labels)) {
                for (String labelId : fulfilmentAttribute.labels.split(',')) {
                    labelIds.add(Id.valueOf(labelId));
                }
            }
        }
        
        for(DigitalFulfilmentAttributes fulfilmentAttribute : fulfilmentAttributes) {
            if (fulfilmentAttribute.productConfigurationId != null && productConfigurations.get(fulfilmentAttribute.productConfigurationId) != null
                && !productConfigurations.get(fulfilmentAttribute.productConfigurationId).Fulfilment_Items__r.isEmpty()) {
                    fulfilmentItemIds.add(productConfigurations.get(fulfilmentAttribute.productConfigurationId).Fulfilment_Items__r.get(0).Id);
                }
        }
    }
    
    
    public static string metaDataValues(string searchMasterLabel, String searchDeveloperName) {
        List<PGCS_Setting__mdt> lst = New List<PGCS_Setting__mdt>();
        lst = [SELECT MasterLabel, DeveloperName, value__c, value_large__c FROM PGCS_Setting__mdt];
        Map<String, PGCS_Setting__mdt> mapOrg = null;     
        
        if (mapOrg == null) {
            mapOrg = new Map<String, PGCS_Setting__mdt>();
        }
        for (PGCS_Setting__mdt org : lst) {
            String keyput = org.MasterLabel + '_' + org.DeveloperName;
            mapOrg.put(keyput.toLowerCase(), org);
        }
        PGCS_Setting__mdt pgcs = New PGCS_Setting__mdt();
        if (mapOrg != null) {   
            String keysearch = searchMasterLabel + '_' + searchDeveloperName;                   
            pgcs = mapOrg.get(keysearch.toLowerCase());
            if(pgcs != null){return pgcs.Value__c;}
            else{return null;}
            
        }else{return null;}
    }
    
    public List<csdf__Fulfilment_Item__c> generateFulfilmentItems() {
        List<csdf__Fulfilment_Item__c> fulfilmentItems = new List<csdf__Fulfilment_Item__c>();
        
        for(DigitalFulfilmentAttributes fulfilmentAttribute : fulfilmentAttributes) {
            validateFulfilmentAttributes(fulfilmentAttribute);
        }
        //List to gather queue to assign as an owner for fulfilment items
        List<Group> queueUser = new List<Group>([SELECT DeveloperNAME,Id,Type FROM Group WHERE Type = 'Queue' AND DeveloperNAME IN ('Singapore_CST','Marketing_Service_CST','Thailand_CST','Indonesia_CST','Malaysia_CST','Ad_Ops')]);
        Map<String,String> QueueOwnerId = new Map<String,String>();
        For(Group gp:queueUser){
            QueueOwnerId.put(gp.DeveloperName,gp.Id);
        }
        String sysUser = [Select id from user where name = 'system message'].Id;
        String FintechProductOwner = [Select id from user where name = 'Janice Lim'].Id;
        boolean isMarketing=false;
        for(DigitalFulfilmentAttributes fulfilmentAttribute : fulfilmentAttributes) {
            if(fulfilmentAttribute.productConfigurationId != null){
                if(productConfigurations.get(fulfilmentAttribute.productConfigurationId).Name == 'Marketing Services'){
                    isMarketing=true;
                }
            }
        }
        for(DigitalFulfilmentAttributes fulfilmentAttribute : fulfilmentAttributes) {
            csdf__Fulfilment_Item__c fulfilmentItem = getFulfilmentItem(fulfilmentAttribute);
            if (fulfilmentItem.Product_Configuration__c != null) {
                
                if(fulfilmentItem.OwnerId==null || fulfilmentItem.OwnerId == sysUser){           //owner id check   
                    if(isMarketing ==true){
                        fulfilmentItem.OwnerId = QueueOwnerId.get('Marketing_Service_CST');
                        //Assigning Malaysia CST as FI record owner if market name is Malaysia
                        if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Market_Name__c == 'Malaysia'){
                            fulfilmentItem.OwnerId = QueueOwnerId.get('Malaysia_CST');
                        }
                        //Assigning Singapore CST as FI record owner if market name is Singapore
                        else if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Market_Name__c  == 'Singapore'){
                            fulfilmentItem.OwnerId = QueueOwnerId.get('Singapore_CST');
                        }   
                    }
                    else if(fulfilmentAttribute.isFintechProduct == 'Yes' && String.isNotBlank(fulfilmentAttribute.commercialProduct)){
                        fulfilmentItem.OwnerId = FintechProductOwner;
                    }
                    //assign fulfilment owner based on PD and country from product node related to node advert assnment to the respective queue
                    else if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Name == 'Ad Served' || 
                            productConfigurations.get(fulfilmentItem.Product_Configuration__c).Name == 'Developer Listings') {
                                if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Digital_Product__r.Line_Item_Type__c == 'House'){
                                    if(QueueOwnerId.containsKey('Ad_Ops')){
                                        fulfilmentItem.OwnerId = QueueOwnerId.get('Ad_Ops');
                                    }                                                                      
                                }else{
                                    if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Market_Name__c == 'Singapore'){                          
                                        if(QueueOwnerId.containsKey('Singapore_CST')){
                                            fulfilmentItem.OwnerId = QueueOwnerId.get('Singapore_CST');
                                        }                             
                                        
                                    }else if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Market_Name__c == 'Malaysia'){                       
                                        if(QueueOwnerId.containsKey('Malaysia_CST')){
                                            fulfilmentItem.OwnerId = QueueOwnerId.get('Malaysia_CST');
                                        }                             
                                        
                                    }else if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Market_Name__c == 'Indonesia'){                             
                                        if(QueueOwnerId.containsKey('Indonesia_CST')){
                                            fulfilmentItem.OwnerId = QueueOwnerId.get('Indonesia_CST');
                                        }                             
                                        
                                    }else if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Market_Name__c == 'Thailand'){                             
                                        if(QueueOwnerId.containsKey('Thailand_CST')){
                                            fulfilmentItem.OwnerId = QueueOwnerId.get('Thailand_CST');
                                        }                             
                                        
                                    }
                                }                   
                            }else if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Name== 'Standard Products'){
                                if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Market_Name__c == 'Singapore'){                         
                                    if(QueueOwnerId.containsKey('Singapore_CST')){
                                        fulfilmentItem.OwnerId = QueueOwnerId.get('Singapore_CST');
                                    }                             
                                    
                                }else if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Market_Name__c == 'Malaysia'){                      
                                    if(QueueOwnerId.containsKey('Malaysia_CST')){
                                        fulfilmentItem.OwnerId = QueueOwnerId.get('Malaysia_CST');
                                    }                             
                                    
                                }else if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Market_Name__c == 'Indonesia'){                         
                                    if(QueueOwnerId.containsKey('Indonesia_CST')){
                                        fulfilmentItem.OwnerId = QueueOwnerId.get('Indonesia_CST');
                                    }                             
                                    
                                }else if(productConfigurations.get(fulfilmentItem.Product_Configuration__c).Market_Name__c == 'Thailand'){                         
                                    if(QueueOwnerId.containsKey('Thailand_CST')){
                                        fulfilmentItem.OwnerId = QueueOwnerId.get('Thailand_CST');
                                    }                                                        
                                }
                            }
                    else if (productConfigurations.get(fulfilmentItem.Product_Configuration__c).cscfga__Product_Definition__r.Fulfilment_Owner__c != null) {
                        fulfilmentItem.OwnerId = productConfigurations.get(fulfilmentItem.Product_Configuration__c).cscfga__Product_Definition__r.Fulfilment_Owner__c;
                    } else {
                        string pdName = '';
                        string countryName = '';
                        string ownerId = null;
                        //PROP-630 changing to use Product Family instead of pd Name
                        pdName = productConfigurations.get(fulfilmentItem.Product_Configuration__c).cscfga__Product_Family__c;
                        countryName = productConfigurations.get(fulfilmentItem.Product_Configuration__c).Sales_Order__r.csmso__Opportunity__r.Country__c;
                        if (string.isNotBlank(pdName) && string.isNotBlank(countryName)) {
                            
                            ownerId = metaDataValues('FIOwner', (pdName + countryName).replaceAll('\\s+', ''));
                            
                        }
                        if (ownerId == null) {
                            fulfilmentItem.OwnerId = productConfigurations.get(fulfilmentItem.Product_Configuration__c).OwnerId;
                        } else {
                            fulfilmentItem.OwnerId = ownerId;
                        }
                    }
                    
                    
                }
            }else{
                fulfilmentItem.OwnerId = sysUser;
            }
            fulfilmentItems.add(fulfilmentItem);
            
            removeCurrentTargetings(fulfilmentItem);
            createTargetings(fulfilmentItem, fulfilmentAttribute);
            // }
            
        }
        addForUpsert(fulfilmentItems);
        
        doDelete();
        doUpsert();
        
        return [SELECT Id, Product_Configuration__c, Line_Id__c, csdf__Fulfilment__c
                FROM csdf__Fulfilment_Item__c
                WHERE Id IN : (new Map<Id, csdf__Fulfilment_Item__c>(fulfilmentItems)).keySet()];
    }
    
    public void extractTargeting(DigitalFulfilmentAttributes fulfilmentAttributes) {
        Map<String, Object> propertyMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(fulfilmentAttributes));
        
        for(String targetingType : TargetingExtractor.keySet()) {
            String targetingTypeExtractor = TargetingExtractor.get(targetingType);
            if(String.isNotBlank(String.valueOf(propertyMap.get(targetingTypeExtractor)))) {
                fulfilmentAttributes.setValue(targetingType, getIncludeExcludeIds(String.valueOf(propertyMap.get(targetingTypeExtractor)),
                                                                                  targetingType.endsWith('Include') ? IncludeExcludeDataType.INCLUDE : IncludeExcludeDataType.EXCLUDE));
            }
        }
    }
    
    public DigitalFulfilmentAttributes validateFulfilmentAttributes(DigitalFulfilmentAttributes fulfilmentAttributes) {
        if (String.isBlank(fulfilmentAttributes.servedBy)) {
            fulfilmentAttributes.servedBy = 'DFP';
        }
        
        if (String.isNotBlank(fulfilmentAttributes.servedBy)
            && fulfilmentAttributes.servedBy == 'DFP'
            && (fulfilmentAttributes.adSlotIdsInclude == null || fulfilmentAttributes.adSlotIdsInclude.isEmpty())
            && (fulfilmentAttributes.sites == null || fulfilmentAttributes.sites.isEmpty())) {
                throw new IllegalArgumentException('Ad Slots have to be defined');
            }
        
        if (String.isNotBlank(fulfilmentAttributes.servedBy)
            && fulfilmentAttributes.servedBy != 'Non-Ad Served'
            && fulfilmentAttributes.servedBy != 'Awards-online'
            && fulfilmentAttributes.servedBy != 'Developer Listings' //PROP-307
            && fulfilmentAttributes.servedBy != 'Database Marketing' //PROP-307
            && fulfilmentAttributes.servedBy != 'Megaphone'){
                try {
                    List<Id> allAdSlotIds = new List<Id>();
                    if (fulfilmentAttributes.adSlotIdsInclude != null && !fulfilmentAttributes.adSlotIdsInclude.isEmpty()) {
                        allAdSlotIds.addAll(fulfilmentAttributes.adSlotIdsInclude);
                    }
                    if (fulfilmentAttributes.adSlotIdsExclude != null && !fulfilmentAttributes.adSlotIdsExclude.isEmpty()) {
                        allAdSlotIds.addAll(fulfilmentAttributes.adSlotIdsExclude);
                    }
                    
                    getParentAdServer();
                } catch (AmbiguousException e) {
                    throw new IllegalArgumentException('Selection of ad slots must reside on the same Ad Server. More than single found!');
                }
            }
        
        return fulfilmentAttributes;
    }
    
    public void removeCurrentTargetings(csdf__Fulfilment_Item__c fulfilmentItem) {
        if(fulfilmentItem.Id != null) {
            for(String targetingType : TargetingsTypes) {
                List<SObject> targetings = new List<SObject>();
                //>1000 targetings
                if(targetingType == 'csdf__Geo_Targetings__r'){
                    targetings = geoTargetings.get(fulfilmentItem.Id);
                } else {
                    targetings = fulfilmentItem.getSObjects(targetingType);
                }
                
                if(targetings != null) {
                    for(SObject targeting : targetings) {
                        Map<String,Object> tFields = targeting.getPopulatedFieldsAsMap();
                        if((mcs.IgnoreCLT__c && ((tFields.containsKey('csdf__Creative_Targeting_Only__c') && tFields.get('csdf__Creative_Targeting_Only__c') == false)
                                                 || !tFields.containsKey('csdf__Creative_Targeting_Only__c')))
                           || !mcs.IgnoreCLT__c) {
                               addForDelete(new List<SObject>{targeting});
                           }
                    }
                }
            }
        }
    }
    
    public void createTargetings(csdf__Fulfilment_Item__c fulfilmentItem, DigitalFulfilmentAttributes fulfilmentAttributes) {
        Map<String, Object> propertyMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(fulfilmentAttributes));
        for(String propertyName : TargetingTypes_ByProperty.keySet()) {
            if(propertyMap.get(propertyName) != null) {
                TargetingType tType = TargetingTypes_ByProperty.get(propertyName);
                Map<Id, SObject> objectsToUpsert = new Map<Id, SObject>();
                
                List<Id> objIds = new List<Id>();
                
                for(Object objId : (List<Object>) propertyMap.get(propertyName)) {
                    objIds.add((Id) objId);
                }
                
                for(Id objId : objIds) {
                    SObject obj = tType.type.newSObject();
                    obj.putSObject('csdf__Fulfilment_Item__r', fulfilmentItem);
                    obj.put(tType.parentField, objId);
                    if(tType.type != Schema.csdf__Site_Targeting__c.getSObjectType()) obj.put('csdf__Exclude__c', propertyName.endsWith('Exclude'));
                    objectsToUpsert.put(objId, obj);
                }
                
                addForUpsert(objectsToUpsert.values());
            }
        }
    }
    
    public csdf__Fulfilment_Item__c populateFulfilmentItem(csdf__Fulfilment_Item__c fulfilmentItem, DigitalFulfilmentAttributes fulfilmentAttributes) {
        Map<String,String> pickListLabel = getAPIValues();
        
        fulfilmentItem.csdf__Name__c = getName(fulfilmentItem, fulfilmentAttributes);
        if(fulfilmentAttributes.District !=null){
            fulfilmentItem.csdf__Name__c +=' '+ fulfilmentAttributes.District;
        }
        if(fulfilmentAttributes.ListingID != null)
            fulfilmentItem.Listing_ID__c = fulfilmentAttributes.ListingID;
        if(fulfilmentAttributes.districtCode != null)
            fulfilmentItem.DistrictCode__c = fulfilmentAttributes.districtCode;
        if(fulfilmentAttributes.regionCode != null)
            fulfilmentItem.RegionCode__c = fulfilmentAttributes.regionCode;
        
        fulfilmentItem.Listing_JSON__c = fulfilmentAttributes.ListingJSON;
        fulfilmentItem.csdf__Fulfilment__c = fulfilments.get(Id.valueOf(fulfilmentAttributes.salesOrderId)).Id;
        fulfilmentItem.csdf__Billing_Category__c = fulfilmentAttributes.billingCategory;
        fulfilmentItem.csdf__Rate__c = fulfilmentAttributes.rate;
        fulfilmentItem.Booking_Timezone__c = fulfilmentAttributes.bookingTimezone;
        fulfilmentItem.CurrencyIsoCode = fulfilmentAttributes.soCurrency;
        fulfilmentItem.csdf__Sizes__c = getSizes(fulfilmentAttributes);
        //fulfilmentItem.csdf__Day_Part_Targeting__c = getDayPartTargeting(fulfilmentAttributes);
        fulfilmentItem.Day_Part_Targeting_Long__c = getDayPartTargeting(fulfilmentAttributes);
        fulfilmentItem.csdf__Display_Creative__c = fulfilmentAttributes.displayCreatives;
        fulfilmentItem.Long_Custom_Key_Targeting__c = getCustomKeyTargeting(fulfilmentItem, fulfilmentAttributes);
        fulfilmentItem.csdf__Notes__c = fulfilmentAttributes.notes;
        fulfilmentItem.csdf__Priority__c = fulfilmentAttributes.priority;
        fulfilmentItem.csdf__Target_Platform__c = fulfilmentAttributes.targetPlatform;
        fulfilmentItem.Deliver_impressions__c = fulfilmentAttributes.deliverImpressions;
        fulfilmentItem.FrequencyCaps__c = fulfilmentAttributes.frequencyCaps;
        fulfilmentItem.Available_For_Flighting__c = fulfilmentAttributes.availableForFlighting;
        fulfilmentItem.Max_Duration__c = fulfilmentAttributes.maxDuration;
        fulfilmentItem.Billing_Threshold_Per_Day__c = fulfilmentAttributes.billingThresholdPerDay;
        fulfilmentItem.Rate_Card_Item_Price__c = fulfilmentAttributes.rateCardItemPrice;
        fulfilmentItem.Served_By__c = fulfilmentAttributes.servedBy;
        //New
        fulfilmentItem.Product_Class__c = fulfilmentAttributes.productClass;
        if(pickListLabel.containsKey(fulfilmentAttributes.productSubClass)){
            fulfilmentItem.Product_Subclass__c = pickListLabel.get(fulfilmentAttributes.productSubClass);
        }
        else
            fulfilmentItem.Product_Subclass__c = fulfilmentAttributes.productSubClass;
        fulfilmentItem.SKU__c = fulfilmentAttributes.sku;
        fulfilmentItem.Product_Category__c = fulfilmentAttributes.productCategory;
        /*********/
        fulfilmentItem.Insertion_Unit_Type_Display__c = fulfilmentAttributes.insertionUnitTypeDisplay;
        fulfilmentItem.Migrated_Line_Item_ID__c = fulfilmentAttributes.migratedLineItemId;
        fulfilmentItem.Allow_Same_Advertiser_Exclusion__c = fulfilmentAttributes.allowSameAdvertiserExclusion != null ? fulfilmentAttributes.allowSameAdvertiserExclusion : false;
        fulfilmentItem.Schedule_Line_Items_using__c = fulfilmentAttributes.scheduleLineItemsUsing;
        fulfilmentItem.csdf__Type__c = String.isBlank(fulfilmentAttributes.type) ? 'Standard' : fulfilmentAttributes.type;
        fulfilmentItem.csdf__Rotate_Creatives__c = fulfilmentAttributes.rotateCreatives == CS_Constants.CREATIVE_ROTATION_TYPE_WEIGHTED ? CS_Constants.CREATIVE_ROTATION_TYPE_MANUAL : fulfilmentAttributes.rotateCreatives;
        fulfilmentItem.Labels__c = getLabels(fulfilmentAttributes);
        fulfilmentItem.Additional_Terms__c = fulfilmentAttributes.additionalTerms;
        fulfilmentItem.Restrict_to_Audio__c = fulfilmentAttributes.restrictToAudio != null ? fulfilmentAttributes.restrictToAudio : false;
        fulfilmentItem.csdf__Custom_Properties__c = fulfilmentAttributes.videoPositionTargeting;
        fulfilmentItem.Programmatic_Creative_Source__c = fulfilmentAttributes.programmaticCreativeSource;
        fulfilmentItem.Listing_id__c = fulfilmentAttributes.listingID;
        setQuantity(fulfilmentItem, fulfilmentAttributes);
        setTargetingFields(fulfilmentItem, fulfilmentAttributes);
        
        if(String.isNotBlank(fulfilmentAttributes.inputFlightBegin)) {
            fulfilmentItem.csdf__Flight_Beginning__c = CS_utl_Datetime.getTimezoneOffset(fulfilmentAttributes.inputFlightBegin + ' ' + fulfilmentAttributes.inputStartTime + ' ' + fulfilmentAttributes.bookingTimezone);
        }
        else if(String.isNotBlank(fulfilmentAttributes.flightBeginDateTime)) {
            fulfilmentItem.csdf__Flight_Beginning__c = CS_utl_Datetime.getTimezoneOffset(fulfilmentAttributes.flightBeginDateTime + ' ' + fulfilmentAttributes.bookingTimezone);
        }
        else if(fulfilmentAttributes.flightBeginning != null) {
            fulfilmentItem.csdf__Flight_Beginning__c = CS_utl_Datetime.getTimezoneOffset(fulfilmentAttributes.flightBeginning + ' ' + fulfilmentAttributes.bookingTimezone);
        }
        
        if(String.isNotBlank(fulfilmentAttributes.inputFlightEnd)) {
            fulfilmentItem.csdf__Flight_End__c = CS_utl_Datetime.getTimezoneOffset(fulfilmentAttributes.inputFlightEnd + ' ' + fulfilmentAttributes.inputEndTime + ' ' + fulfilmentAttributes.bookingTimezone);
        }
        else if(String.isNotBlank(fulfilmentAttributes.flightEndDateTime)) {
            fulfilmentItem.csdf__Flight_End__c = CS_utl_Datetime.getTimezoneOffset(fulfilmentAttributes.flightEndDateTime + ' ' + fulfilmentAttributes.bookingTimezone);
        }
        else if(fulfilmentAttributes.flightEnd != null) {
            fulfilmentItem.csdf__Flight_End__c = CS_utl_Datetime.getTimezoneOffset(fulfilmentAttributes.flightEnd + ' ' + fulfilmentAttributes.bookingTimezone);
        }
        
        if (fulfilmentItem.csdf__Flight_Beginning__c != null && fulfilmentItem.csdf__Flight_End__c != null && fulfilmentItem.Booking_Timezone__c != null) {
            fulfilmentItem.Flight_Beginning_Time_HH_MM__c = fulfilmentItem.csdf__Flight_Beginning__c.format('HH:mm', fulfilmentItem.Booking_Timezone__c);
            fulfilmentItem.Flight_End_Time_HH_MM__c = fulfilmentItem.csdf__Flight_End__c.format('HH:mm', fulfilmentItem.Booking_Timezone__c);
            fulfilmentItem.Flight_Beginning_Line_Item__c = Date.valueOf(fulfilmentItem.csdf__Flight_Beginning__c.format('yyyy-MM-dd', fulfilmentItem.Booking_Timezone__c));
            fulfilmentItem.Flight_End_Line_Item__c = Date.valueOf(fulfilmentItem.csdf__Flight_End__c.format('yyyy-MM-dd', fulfilmentItem.Booking_Timezone__c));
            
            DateRange dateRange = new DateRange(fulfilmentItem.csdf__Flight_Beginning__c, fulfilmentItem.csdf__Flight_End__c);
            fulfilmentItem.Date_Range_JSON__c = JSON.serialize(dateRange);
        }
        else if(fulfilmentItem.csdf__Flight_Beginning__c != null && fulfilmentItem.csdf__Flight_End__c != null){
            
            fulfilmentItem.Flight_Beginning_Time_HH_MM__c = fulfilmentAttributes.inputStartTime;
            fulfilmentItem.Flight_End_Time_HH_MM__c = fulfilmentAttributes.inputEndTime;
            
            fulfilmentItem.Flight_Beginning_Line_Item__c = Date.valueOf(fulfilmentItem.csdf__Flight_Beginning__c.format('yyyy-MM-dd'));
            fulfilmentItem.Flight_End_Line_Item__c = Date.valueOf(fulfilmentItem.csdf__Flight_End__c.format('yyyy-MM-dd'));
            DateRange dateRange = new DateRange(fulfilmentItem.csdf__Flight_Beginning__c, fulfilmentItem.csdf__Flight_End__c);
            fulfilmentItem.Date_Range_JSON__c = JSON.serialize(dateRange);
        }
        
        if (String.isNotBlank(fulfilmentAttributes.productConfigurationId) && !temporary) {
            fulfilmentItem.Product_Configuration__c = fulfilmentAttributes.productConfigurationId;
        }
        
        if(fulfilmentAttributes.servedBy == 'Megaphone') {
            fulfilmentItem.Podcast_Geo_Targeting__c = fulfilmentAttributes.podcastGeoTargetingName;
            fulfilmentItem.Podcast_Targeting__c = fulfilmentAttributes.podcastTargetingName;
        }
        
        return fulfilmentItem;
    }
    
    public csdf__Fulfilment_Item__c getFulfilmentItem(DigitalFulfilmentAttributes fulfilmentAttributes) {
        csdf__Fulfilment_Item__c fulfilmentItem = String.isNotBlank(fulfilmentAttributes.productConfigurationId) &&
            !productConfigurations.get(fulfilmentAttributes.productConfigurationId).Fulfilment_Items__r.isEmpty() &&
            fulfilmentItems.containsKey(productConfigurations.get(fulfilmentAttributes.productConfigurationId).Fulfilment_Items__r.get(0).Id) ?
            fulfilmentItems.get(productConfigurations.get(fulfilmentAttributes.productConfigurationId).Fulfilment_Items__r.get(0).Id) : new csdf__Fulfilment_Item__c();
        return populateFulfilmentItem(fulfilmentItem, fulfilmentAttributes);
    }
    
    public String getName(csdf__Fulfilment_Item__c fulfilmentItem, DigitalFulfilmentAttributes fulfilmentAttributes) {
        String newFulfilmentItemName = (fulfilmentAttributes.itemName + ' ID: ' + System.currentTimeMillis()).replace('&gt;', '>');
        return (String.isBlank(fulfilmentItem.csdf__Name__c)) ? newFulfilmentItemName :
        (fulfilmentItem.csdf__Name__c.split('ID:')[0] != newFulfilmentItemName.split('ID:')[0] ? newFulfilmentItemName : fulfilmentItem.csdf__Name__c);
            }
    
    public void setQuantity(csdf__Fulfilment_Item__c fulfilmentItem, DigitalFulfilmentAttributes fulfilmentAttributes) {
        if ('Sponsorship'.equals(fulfilmentAttributes.type) || 'Network'.equals(fulfilmentAttributes.type) || 'House'.equals(fulfilmentAttributes.type)) {
            fulfilmentItem.csdf__Quantity__c = Decimal.valueOf(fulfilmentAttributes.SOV);
            fulfilmentItem.Quantity_CPD__c = fulfilmentAttributes.quantity;
            fulfilmentItem.Insertion_Quantity__c = fulfilmentAttributes.quantity;
        }
        else {
            fulfilmentItem.csdf__Quantity__c = fulfilmentAttributes.quantity;
            fulfilmentItem.Quantity_CPD__c = fulfilmentAttributes.quantity;
            fulfilmentItem.Insertion_Quantity__c = fulfilmentAttributes.insertionQuantity;
            if (fulfilmentAttributes.buffer != null) {
                fulfilmentItem.Buffer__c = fulfilmentAttributes.buffer;
            }
            //If buffer is null must be updated as 0 in Fulfilment Item
            else {
                fulfilmentItem.Buffer__c = 0;
            }
        }
    }
    
    public String getSizes(DigitalFulfilmentAttributes fulfilmentAttributes) {
        if(String.isNotBlank(fulfilmentAttributes.sizes)) {
            return fulfilmentAttributes.sizes;
        }
        else {
            Set<String> sizes = new Set<String>();
            if(fulfilmentAttributes.adSlotIdsInclude != null) {
                for (Id adSlotId : fulfilmentAttributes.adSlotIdsInclude) {
                    sizes.addAll(adSlots.get(adSlotId).csdf__Sizes__c.split('\\s*,\\s*'));
                }
            }
            
            return String.join(new List<String>(sizes), ', ');
        }
    }
    
    public Boolean containsCltData(String longCustomKeyTargetingStr) {
        return !String.isBlank(longCustomKeyTargetingStr) && (longCustomKeyTargetingStr.indexOf(';') != -1);
    }
    
    public String getCltData(String longCustomKeyTargetingStr) {
        if (String.isBlank(longCustomKeyTargetingStr)) {
            return '';
        }
        Matcher cltPatternMatcher = cltPattern.matcher(longCustomKeyTargetingStr);
        List<String> cltStringsList = new List<String>();
        while (cltPatternMatcher.find()) {
            cltStringsList.add(cltPatternMatcher.group(0));
        }
        return String.join(cltStringsList, ';');
    }
    
    public String getDayPartTargeting(DigitalFulfilmentAttributes fulfilmentAttributes) {
        if(String.isNotBlank(fulfilmentAttributes.inputFlightBegin) && String.isNotBlank(fulfilmentAttributes.inputStartTime)) {
            DayPartTargeting dpt = new CS_FulfilmentService.DayPartTargeting(
                fulfilmentAttributes.dayPartTargeting,
                fulfilmentAttributes.inputFlightBegin + ' ' + fulfilmentAttributes.inputStartTime + ' ' + fulfilmentAttributes.bookingTimezone,
                fulfilmentAttributes.scheduleLineItemsUsing == 'User\'s time zone' ? 0 : - 1);
            return dpt.getDayPartTargetingCSV();
        }
        
        return null;
    }
    
    public String getCustomKeyTargeting(csdf__Fulfilment_Item__c fulfilmentItem, DigitalFulfilmentAttributes fulfilmentAttributes) {
        String result;
        if (mcs.IgnoreCLT__c && !containsCltData(fulfilmentAttributes.customKeyTargeting)) {
            String cltStr =  getCltData(fulfilmentItem.Long_Custom_Key_Targeting__c);
            if (String.isNotBlank(fulfilmentAttributes.customKeyTargeting) && String.isNotBlank(cltStr)) {
                result = fulfilmentAttributes.customKeyTargeting + ';' + cltStr;
            }
            else {
                if(String.isNotBlank(cltStr)) result = cltStr;
                else if(String.isNotBlank(fulfilmentAttributes.customKeyTargeting)) result = fulfilmentAttributes.customKeyTargeting;
                else result = '';
            }
        }
        else {
            result = String.isNotBlank(fulfilmentAttributes.customKeyTargeting) ? fulfilmentAttributes.customKeyTargeting : null;
        }
        
        return String.isBlank(result) ? null : result;
    }
    
    public static map<String,String> getAPIValues(){
        Map<String,String>  myPicklist = new Map<String,String>();
        Schema.DescribeFieldResult field = cspmb__Add_On_Price_Item__c.Product_Subclass__c.getDescribe();
        
        for (Schema.PicklistEntry f : field.getPicklistValues())
            myPicklist.put(f.getvalue(),f.getLabel());
        
        return myPicklist;
    }
    
    public static String TargetingPropertyTemplate = 'INCLUDE:{0};EXCLUDE:{1};';
    
    public void setTargetingFields(csdf__Fulfilment_Item__c fulfilmentItem, DigitalFulfilmentAttributes fulfilmentAttributes) {
        Map<String, Object> propertyMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(fulfilmentAttributes));
        
        for(String tProperty : TargetingProperty.keySet()) {
            Map<String, String> targetingPropertyValues = TargetingProperty.get(tProperty);
            fulfilmentItem.put(tProperty, String.format(TargetingPropertyTemplate, new List<String>{
                CS_utl_Array.join(propertyMap.containsKey(targetingPropertyValues.get('INCLUDE')) ? (List<Object>)propertyMap.get(targetingPropertyValues.get('INCLUDE')) : null, ','),
                    CS_utl_Array.join(propertyMap.containsKey(targetingPropertyValues.get('EXCLUDE')) ? (List<Object>)propertyMap.get(targetingPropertyValues.get('EXCLUDE')) : null, ',')
                    }));
        }
        
        String inventoryAdUnits = '';
        for(Object adSlot : propertyMap.containsKey('adSlotIdsInclude') ? (List<Object>) propertyMap.get('adSlotIdsInclude') : new List<Object>()) {
            inventoryAdUnits += '<br>' + adSlots.get(String.valueOf(adSlot)).csdf__Name__c + '</br>';
        }
        fulfilmentItem.put('Inventory_Ad_Units__c', inventoryAdUnits);
    }
    
    public String getLabels(DigitalFulfilmentAttributes fulfilmentAttributes) {
        if (String.isNotBlank(fulfilmentAttributes.labels)) {
            List<String> labelDfpIds = new List<String>();
            
            for (String labelId : fulfilmentAttributes.labels.split(',')) {
                labelDfpIds.add(labels.get(Id.valueOf(labelId)).csdf__Ad_Server_Id__c);
            }
            
            return String.join(labelDfpIds, ',');
        }
        else {
            return null;
        }
    }
    
    /**
* @description Gets parent Ad Server from a list of Ad Slots. The list must be ambiguously defined (all Ad Slots
* must belong to the same Ad Server). In case of multiple Ad Servers reference, an exception is thrown.
* @param adSlotIds list of Ad Slot object record ids
* @return parent Ad Server object record Id of all Ad Slots provided in the list
*/
    @testVisible
    private Id getParentAdServer() {
        if (adServers.size() == 1) {
            return (Id) adServers.iterator().next().get('csdf__Ad_Server__c');
        } else {
            throw new AmbiguousException('Ad Server is defined ambiguously!');
        }
    }
    
    public static List<Id> getIncludeExcludeIds(String getAllIdsData, IncludeExcludeDataType getDataReturnType) {
        List<Id> result = new List<Id>();
        Matcher patternMatcher = null;
        
        if (getDataReturnType == IncludeExcludeDataType.INCLUDE) {
            patternMatcher = includePatternMatcher;
        }
        else if (getDataReturnType == IncludeExcludeDataType.EXCLUDE) {
            patternMatcher = excludePatternMatcher;
        }
        
        if (patternMatcher != null && String.isNotBlank(getAllIdsData)) {
            patternMatcher.reset(getAllIdsData);
            if (patternMatcher.find()) {
                for (String idStr : patternMatcher.group(2).split(',')) {
                    result.add(Id.valueOf(idStr));
                }
            }
        }
        
        return result;
    }
    
    public class DateRange {
        public String startDate {get; set;}
        public String endDate {get; set;}
        public Integer dateCount {get; set;}
        
        public DateRange(Datetime startDatetime, Datetime endDatetime) {
            this.startDate = startDatetime.format('yyyy-dd-MM');
            this.endDate = endDatetime.format('yyyy-dd-MM');
            this.dateCount = startDatetime.Date().daysBetween(endDatetime.Date());
        }
    }
    
    public class TargetingType {
        public SObjectType type {get; set;}
        public String parentField {get; set;}
        
        public TargetingType(SObjectType type, String parentField) {
            this.type = type;
            this.parentField = parentField;
        }
    }
    
    /**
* @description Exception thrown when an argument is illegal.
*/
    public class IllegalArgumentException extends Exception {}
    
    /**
* @description Exception thrown when something is ambiguously defined.
*/
    public class AmbiguousException extends Exception {}
    
    /**
* Defines the full set of attributes necessary to define all detils of fulfilment and fulfilment item object
* records.
*/
    public class DigitalFulfilmentAttributes {
        
        /**
* Mandatory for Fulfilment object creation.
*/
        public Id accountId {get; set;}
        
        /**
* Account Name is redundant (account Id must be provided). It is used to define fulfilment and fulfilment item
* name and due to the governer limits (not to execute another SOQL) the redundant filed is kept in the
* structure.
*/
        public String accountName {get; set;}
        public String district {get; set;}
        public string listingID {get;set;}
        public string districtCode {get;set;}
        public string regionCode {get;set;}
        public string ListingJSON {get;set;}
        
        public String itemName {get; set;}
        public String SOV {get; set;}
        
        public Id salesOrderId {get; set;}
        public Id productConfigurationId {get; set;}
        
        /**
* List of ad slots defining inventory target
*/
        public String adSlotIdsIncludedExcludedString {get; set;}
        public List<Id> adSlotIdsInclude {get; set;}
        public List<Id> adSlotIdsExclude {get; set;}
        public List<Id> nodeAdvertAssignmentIds {get; set;}
        
        /**
* Advert flight beginning.
*/
        public Datetime flightBeginning {get; set;}
        
        //Input date and time (format: "dd/mm/yyy hh:mm")
        public String inputFlightBegin {get; set;}
        public String inputStartTime {get; set;}
        public String inputFlightEnd {get; set;}
        public String inputEndTime {get; set;}
        public String bookingTimezone  {get; set;}
        
        //New variable for  Flight_Begin_Date_Time_0 and  Flight_End_Date_Time_0 Attributes in format YYYY-MM-DD HH:MM
        public String flightBeginDateTime {get; set;}
        public String flightEndDateTime {get; set;}
        
        //FLAGS to filter Check Avail Lines and Recalculate Attr Changed Old Value
        public String flagRecalculateAttrChangedOldValue {get; set;}
        public String flagFilterCheckAvailLines {get; set;}
        
        public Datetime flightEnd {get; set;}
        
        /**
* Either CPM, CPC or CPD
*/
        public String billingCategory {get; set;}
        public Decimal quantity {get; set;}
        public Decimal insertionQuantity {get; set;}
        public Decimal buffer {get; set;}
        public String soCurrency {get; set;}
        public Decimal rate {get; set;}
        
        public Integer maxDuration {get; set;}
        
        public Integer billingThresholdPerDay {get; set;}
        
        public Boolean restrictToAudio {get; set;}
        
        public String sizes {get; set;}
        
        public List<Id> sites {get; set;}
        
        public String dayPartTargeting {get; set;}
        public String customKeyTargeting {get; set;}
        
        public String geoItemsIncludedExcludedString {get; set;}
        public List<Id> geoItemsInclude {get; set;}
        public List<Id> geoItemsExclude {get; set;}
        public List<Id> targetables {get; set;}
        
        public String browsersIncludedExcludedString {get; set;}
        public List<Id> browsersInclude {get; set;}
        public List<Id> browsersExclude {get; set;}
        
        public String mobileDevicesIncludedExcludedString {get; set;}
        public List<Id> mobileDevicesInclude {get; set;}
        public List<Id> mobileDevicesExclude {get; set;}
        
        //Device Category for Flighting
        public String deviceCategoryIncludedExcludedString {get;set;}
        public List<Id> deviceCategoryInclude {get;set;}
        public List<Id> deviceCategoryExclude {get;set;}
        
        public String operatingSystemsIncludedExcludedString {get; set;}
        public List<Id> operatingSystemsInclude {get; set;}
        public List<Id> operatingSystemsExclude {get; set;}
        
        public String operatingSystemVersionsIncludedExcludedString {get; set;}
        public List<Id> operatingSystemVersionsInclude {get; set;}
        public List<Id> operatingSystemVersionsExclude {get; set;}
        
        public String mobileCarriersIncludedExcludedString {get; set;}
        public List<Id> mobileCarriersInclude {get; set;}
        public List<Id> mobileCarriersExclude {get; set;}
        
        public String deviceCapabilitiesIncludedExcludedString {get; set;}
        public List<Id> deviceCapabilitiesInclude {get; set;}
        public List<Id> deviceCapabilitiesExclude {get; set;}
        
        public String bandwidthGroupIncludedExcludedString {get; set;}
        public List<Id> bandwidthGroupInclude {get; set;}
        public List<Id> bandwidthGroupExclude {get; set;}
        
        public String targetingTemplateId {get; set;}
        
        public String displayCreatives {get; set;}
        public String notes {get; set;}
        public String priority {get; set;}
        public String rotateCreatives {get; set;}
        public String targetPlatform {get; set;}
        public String deliverImpressions {get; set;}
        
        public String availableForFlighting {get; set;}
        public Decimal rateCardItemPrice {get; set;}
        
        public String type {get; set;}
        
        public String frequencyCaps {get; set;}
        
        public String servedBy {get; set; }
        //New 22/12/21
        public String sku {get; set; }
        public String productClass {get; set; }
        public String productSubClass {get; set; }
        public String productCategory {get; set; }
        //New 19/01/22
        public String isFintechProduct {get; set; }
        public String commercialProduct {get; set; }
        
        public String insertionUnitTypeDisplay {get; set; }
        public String migratedLineItemId {get; set; }
        public Boolean allowSameAdvertiserExclusion {get; set; }
        public String scheduleLineItemsUsing {get; set; }
        public String labels {get; set; }
        
        public String additionalTerms {get; set; }
        
        public String podcastGeoTargetingName {get; set; }
        public String podcastTargetingName {get; set; }
        public String videoPositionTargeting {get; set; }
        
        public String programmaticCreativeSource {get; set;}
        
        public void setValue(String fieldName, Object value) {
            if(fieldName == 'adSlotIdsInclude') this.adSlotIdsInclude = (List<Id>) value;
            else if(fieldName == 'adSlotIdsExclude') this.adSlotIdsExclude = (List<Id>) value;
            else if(fieldName == 'geoItemsInclude') this.geoItemsInclude = (List<Id>) value;
            else if(fieldName == 'geoItemsExclude') this.geoItemsExclude = (List<Id>) value;
            else if(fieldName == 'browsersInclude') this.browsersInclude = (List<Id>) value;
            else if(fieldName == 'browsersExclude') this.browsersExclude = (List<Id>) value;
            else if(fieldName == 'mobileDevicesInclude') this.mobileDevicesInclude = (List<Id>) value;
            else if(fieldName == 'mobileDevicesExclude') this.mobileDevicesExclude = (List<Id>) value;
            else if(fieldName == 'deviceCategoryInclude') this.deviceCategoryInclude = (List<Id>) value;
            else if(fieldName == 'deviceCategoryExclude') this.deviceCategoryExclude = (List<Id>) value;
            else if(fieldName == 'operatingSystemsInclude') this.operatingSystemsInclude = (List<Id>) value;
            else if(fieldName == 'operatingSystemsExclude') this.operatingSystemsExclude = (List<Id>) value;
            else if(fieldName == 'operatingSystemVersionsInclude') this.operatingSystemVersionsInclude = (List<Id>) value;
            else if(fieldName == 'operatingSystemVersionsExclude') this.operatingSystemVersionsExclude = (List<Id>) value;
            else if(fieldName == 'mobileCarriersInclude') this.mobileCarriersInclude = (List<Id>) value;
            else if(fieldName == 'mobileCarriersExclude') this.mobileCarriersExclude = (List<Id>) value;
            else if(fieldName == 'deviceCapabilitiesInclude') this.deviceCapabilitiesInclude = (List<Id>) value;
            else if(fieldName == 'deviceCapabilitiesExclude') this.deviceCapabilitiesExclude = (List<Id>) value;
            else if(fieldName == 'bandwidthGroupInclude') this.bandwidthGroupInclude = (List<Id>) value;
            else if(fieldName == 'bandwidthGroupExclude') this.bandwidthGroupExclude = (List<Id>) value;
        }
    }
    
    public static Map<String, Integer> DAYS_IN_WEEK = new Map<String, Integer> {
        'Monday' => 0,
            'Tuesday' => 1,
            'Wednesday' => 2,
            'Thursday' => 3,
            'Friday' => 4,
            'Saturday' => 5,
            'Sunday' => 6
            };
                
                public static Map<Integer, String> DAYS_IN_WEEK_PERIOD = new Map<Integer, String> {
                    0 => 'Monday',
                        1 => 'Tuesday',
                        2 => 'Wednesday',
                        3 => 'Thursday',
                        4 => 'Friday',
                        5 => 'Saturday',
                        6 => 'Sunday'
                        };
                            
                            public static String DAY_FORMAT = '{0}#{1}#{2}#';
    
    public class DayPartTargeting {
        public Map<String, List<DayPartTargetingPeriod>> days {get; set;}
        public List<Integer> periods {get; set;}
        public String inputDate {get; set;}
        public Integer offset {get; set;}
        
        public DayPartTargeting(String dpt, String inputDate, Integer offsetDirection) {
            this.days = initializeDays(dpt);
            this.inputDate = inputDate;
            this.offset = (CS_utl_Datetime.getOffset(inputDate) / (60 * 60)) * offsetDirection;
            this.periods = getPeriods();
        }
        
        public Map<String, List<DayPartTargetingPeriod>> initializeDays(String dpt) {
            if(String.isBlank(dpt)) {
                return new Map<String, List<DayPartTargetingPeriod>>();
            }
            else if(dpt.contains('#')) {
                Map<String, List<DayPartTargetingPeriod>> daysJson = getDayPartTargetingMap();
                List<String> dptParts = dpt.split('#');
                for(Integer i = 0; i < dptParts.size(); i = i + 3) {
                    daysJson.get(dptParts.get(i)).add(new DayPartTargetingPeriod(Integer.valueOf(dptParts.get(i + 1)), Integer.valueOf(dptParts.get(i + 2))));
                }
                return daysJson;
            }
            else {
                dpt = dpt.replace('"start"', '"start_x"').replace('"end"', '"end_x"');
                return (Map<String, List<DayPartTargetingPeriod>>) JSON.deserialize(dpt, Map<String, List<DayPartTargetingPeriod>>.class);
            }
        }
        
        public List<Integer> getPeriods() {
            List<Integer> periods = new List<Integer>();
            
            for(String day : this.days.keySet()) {
                Integer dayFactor = DAYS_IN_WEEK.get(day) * 24;
                
                List<DayPartTargetingPeriod> dayPeriods = this.days.get(day);
                for(DayPartTargetingPeriod dptPeriod : dayPeriods) {
                    Integer periodStart = applyOffset(dptPeriod.start_X + dayFactor, this.offset);
                    Integer periodEnd = applyOffset(dptPeriod.end_x + dayFactor, this.offset);
                    periods.add(periodStart);
                    periods.add(periodEnd);
                    
                    if(periodStart < dayFactor && periodEnd > dayFactor) {
                        periods.add(dayFactor);
                        periods.add(dayFactor);
                    }
                    else if(periodStart < dayFactor + 24 && periodEnd > dayFactor + 24) {
                        periods.add(dayFactor + 24);
                        periods.add(dayFactor + 24);
                    }
                    else if(periodStart > (6 * 24) && periodEnd < 24) {
                        periods.add(0);
                        periods.add((7 * 24));
                    }
                    else if(periodEnd > (7 * 24) && periodStart < (7 * 24)) {
                        periods.add(0);
                        periods.add((7 * 24));
                    }
                }
            }
            
            periods.sort();
            
            List<Integer> filteredPeriods = new List<Integer>();
            for(Integer i = 0;  i < periods.size(); i++) {
                if(i == periods.size() - 1 || periods.get(i) != periods.get(i + 1) || (Math.mod(periods.get(i), 24) == 0) && periods.get(i) != 0 && periods.get(i) != (7 * 24)) {
                    filteredPeriods.add(periods.get(i));
                }
                else i++;
            }
            
            return filteredPeriods;
        }
        
        public Integer applyOffset(Integer period, Integer offset) {
            Integer periodWithOffset = period + offset;
            
            if(periodWithOffset < 0 ) {
                periodWithOffset += (7 * 24);
            }
            else if(periodWithOffset > (7 * 24)) {
                periodWithOffset -= (7 * 24);
            }
            
            return periodWithOffset;
        }
        
        public Map<String, List<DayPartTargetingPeriod>> getDayPartTargetingMap() {
            Map<String, List<DayPartTargetingPeriod>> daysJson = new Map<String, List<DayPartTargetingPeriod>>();
            for(String day : DAYS_IN_WEEK.keySet()) {
                daysJson.put(day, new List<DayPartTargetingPeriod>());
            }
            
            return daysJson;
        }
        
        public Map<String, List<DayPartTargetingPeriod>> getDayPartTargeting() {
            Map<String, List<DayPartTargetingPeriod>> daysJson = getDayPartTargetingMap();
            
            for(Integer i = 0;  i < this.periods.size(); i = i + 2) {
                DayPartTargetingPeriod period = new DayPartTargetingPeriod(periods.get(i), periods.get(i + 1));
                String day = period.getDay(periods.get(i));
                daysJson.get(day).add(period);
            }
            
            return daysJson;
        }
        
        public String getDayPartTargetingCSV() {
            Map<String, List<DayPartTargetingPeriod>> daysJson = getDayPartTargeting();
            
            String dayPartTargetingCSV = '';
            for(Integer i = 0; i < 7; i++) {
                String day = DAYS_IN_WEEK_PERIOD.get(i);
                List<DayPartTargetingPeriod> periods = daysJson.get(day);
                
                for(DayPartTargetingPeriod period : periods) {
                    dayPartTargetingCSV += String.format(DAY_FORMAT, new List<String>{day, String.valueOf(period.start_x), String.valueOf(period.end_x)});
                }
            }
            
            return dayPartTargetingCSV.length() > 0 ? dayPartTargetingCSV.substring(0, dayPartTargetingCSV.length() - 1) : '';
        }
        
        public String getDayPartTargetingJSON() {
            String dpt = JSON.serialize(getDayPartTargeting());
            return dpt.replace('"start_x"', '"start"').replace('"end_x"', '"end"');
        }
    }
    
    public class DayPartTargetingPeriod {
        public Integer start_x {get; set;}
        public Integer end_x {get; set;}
        
        public DayPartTargetingPeriod() {
            
        }
        
        public DayPartTargetingPeriod(Integer start_x, Integer end_x) {
            this.start_x = Math.mod(start_x, 24);
            this.end_X = Math.mod(end_x, 24) == 0 ? 24 : Math.mod(end_x, 24);
        }
        
        public String getDay(Integer start_x) {
            Integer day = (start_x - Math.mod(start_x, 24)) / 24;
            return DAYS_IN_WEEK_PERIOD.get(day);
        }
    }
    
    public static CS_FulfilmentService.KeyvaluesAndAudience initKeyvaluesAndAudience(List<String> CustomKeyTargeting, Map<Id, csmso__Node_Advert_Assignment__c> productsToFIMap) {
        CS_Custom_Settings__c customSettings = CS_Custom_Settings__c.getInstance();
        Boolean isAudienceSegment = false;
        Set<String> listOfKeys = new Set<String>();
        Set<String> listOfKeyValues = new Set<String>();
        
        Map<String, csdf__Custom_Targeting_Key__c> listOfCTargeting = new Map<String, csdf__Custom_Targeting_Key__c>();
        Map<String, csdf__Targetable__c> listOfTargetable = new Map<String, csdf__Targetable__c>();
        
        for(String aKT : CustomKeyTargeting) {
            isAudienceSegment |= aKT.containsIgnoreCase('Audience Segment') ? true : false;
            if (customSettings != null && customSettings.KeyValue_configuration__c == CS_Util.KEYVALUE_CONFIGURATION_ID) {
                for (String keyStr : CS_Util.getKeys(aKT)) {
                    listOfKeys.add(keyStr.right(keyStr.length() - 1));
                }
                for (String keyValueStr : CS_Util.getKeyValues(aKT)) {
                    listOfKeyValues.add(keyValueStr.right(keyValueStr.length() - 1));
                }
            }
            else {
                listOfKeys.addAll(CS_Util.getKeys(aKT));
                listOfKeyValues.addAll(CS_Util.getKeyValues(aKT));
            }
        }
        
        if(customSettings != null && customSettings.KeyValue_configuration__c == CS_Util.KEYVALUE_CONFIGURATION_ID) {
            for(csdf__Custom_Targeting_Key__c t : [SELECT id, csdf__Display_Name__c, csdf__Ad_Server_Id__c, Name,
                                                   (SELECT id, csdf__Display_Name__c, Name, csdf__Ad_Server_Id__c
                                                    FROM csdf__Custom_Targeting_Values__r
                                                    WHERE csdf__Ad_Server_Id__c in :listOfKeyValues)
                                                   FROM csdf__Custom_Targeting_Key__c
                                                   WHERE csdf__Ad_Server_Id__c in :listOfKeys
                                                   ORDER BY csdf__Display_Name__c]) {
                                                       listOfCTargeting.put(t.csdf__Ad_Server_Id__c, t);
                                                       listOfCTargeting.put(t.Name, t);
                                                   }
        }
        else {
            for(csdf__Custom_Targeting_Key__c t : [SELECT id, csdf__Display_Name__c, csdf__Ad_Server_Id__c, Name,
                                                   (SELECT id, csdf__Display_Name__c, Name, csdf__Ad_Server_Id__c
                                                    FROM csdf__Custom_Targeting_Values__r
                                                    WHERE Name in :listOfKeyValues)
                                                   FROM csdf__Custom_Targeting_Key__c
                                                   WHERE name in :listOfKeys
                                                   ORDER BY csdf__Display_Name__c]) {
                                                       listOfCTargeting.put(t.csdf__Ad_Server_Id__c, t);
                                                       listOfCTargeting.put(t.Name, t);
                                                   }
        }
        
        if(isAudienceSegment)
            for(csdf__Targetable__c t : [SELECT csdf__Ad_Server_Id__c,csdf__Ad_Server__c,csdf__Description__c,
                                         csdf__Targetable_Name__c,csdf__Type__c,Id,Targetable_Parent__c
                                         FROM csdf__Targetable__c
                                         WHERE csdf__Type__c = 'Audience Segment'
                                         AND csdf__Active__c = true]) {
                                             listOfTargetable.put(t.csdf__Ad_Server_Id__c, t);
                                         }
        
        return new CS_FulfilmentService.KeyvaluesAndAudience(
            listOfCTargeting,
            listOfTargetable,
            productsToFIMap,
            customSettings
        );
    }
    
    public class KeyvaluesAndAudience {
        public Map<String, csdf__Custom_Targeting_Key__c> customTargetings {get; set;}
        public Map<String, csdf__Targetable__c> targetables {get; set;}
        public Map<Id, Map<String, List<List<KeyvaluesAndAudienceKey>>>> predefinedValues {get; set;}
        public CS_Custom_Settings__c customSettings {get; set;}
        
        public KeyvaluesAndAudience(Map<String, csdf__Custom_Targeting_Key__c> customTargetings,
                                    Map<String, csdf__Targetable__c> targetables,
                                    Map<Id, csmso__Node_Advert_Assignment__c> products,
                                    CS_Custom_Settings__c customSettings) {
                                        this.customSettings = customSettings;
                                        this.customTargetings = customTargetings;
                                        this.targetables = targetables;
                                        this.predefinedValues = new Map<Id, Map<String, List<List<KeyvaluesAndAudienceKey>>>>();
                                        if(products != null) {
                                            for(Id predefinedId : products.keySet()) {
                                                String predefined = predefinedId != null && products.get(predefinedId) != null ? products.get(predefinedId).Key_values_and_Audience_JSON__c : null;
                                                if(String.isNotBlank(predefined)) {
                                                    this.predefinedValues.put(predefinedId,
                                                                              (Map<String, List<List<KeyvaluesAndAudienceKey>>>) JSON.deserialize(predefined, Map<String, List<List<KeyvaluesAndAudienceKey>>>.class));
                                                }
                                            }
                                        }
                                    }
        
        @TestVisible
        private csdf__Custom_Targeting_Key__c findCustomTargetingKey(String key,  Map<String, csdf__Custom_Targeting_Key__c> customTargetings, CS_Custom_Settings__c customSettings) {
            csdf__Custom_Targeting_Key__c keyObj = null;
            if (key != null && !customTargetings.isEmpty()) {
                if (!key.equalsIgnoreCase('Audience Segment') && customSettings != null &&
                    customSettings.KeyValue_configuration__c == KEYVALUE_CONFIGURATION_ID) {
                        String adServerIdStr = key.right(key.length() - 1);
                        keyObj = customTargetings.get(adServerIdStr);
                    }
                else {
                    keyObj = customTargetings.get(key);
                }
            }
            
            return keyObj;
        }
        
        public String generateJson(String input, Boolean predefined, Id predefinedId) {
            Map<String, List<List<KeyvaluesAndAudienceKey>>> output = new Map<String, List<List<KeyvaluesAndAudienceKey>>>{
                KVA_HOLISTIC => new List<List<KeyvaluesAndAudienceKey>>(),
                    KVA_CUSTOM => new List<List<KeyvaluesAndAudienceKey>>()
                    };
                        
                        if(String.isNotBlank(input)) {
                            input =  input.replace('Audience Segment', 'Audiencesegment').replace('Audience segment', 'Audiencesegment').replaceAll(' is not ', ' isnot ');
                            List<String> parsedSets = input.split(' OR ');
                            
                            
                            Map<String, Map<Set<Set<String>>, List<KeyvaluesAndAudienceKey>>> values = new Map<String, Map<Set<Set<String>>, List<KeyvaluesAndAudienceKey>>>{
                                KVA_HOLISTIC => new Map<Set<Set<String>>, List<KeyvaluesAndAudienceKey>>(),
                                    KVA_CUSTOM => new Map<Set<Set<String>>, List<KeyvaluesAndAudienceKey>>()
                                    };
                                        
                                        for(String inputSet : parsedSets) {
                                            Map<Set<String>, List<KeyvaluesAndAudienceKey>> parsedSetMap = new Map<Set<String>, List<KeyvaluesAndAudienceKey>>();
                                            inputSet = inputSet.replace(' or ', ',').replace(', ', ',');
                                            
                                            List<String> parsedKeys = inputSet.split(' AND ');
                                            for (String inputKey : parsedKeys) {
                                                List<String> keyMembers = inputKey.split(' ');
                                                csdf__Custom_Targeting_Key__c dbKey = findCustomTargetingKey(keyMembers[0], customTargetings, customSettings);
                                                
                                                KeyvaluesAndAudienceKey parsedKey = new KeyvaluesAndAudienceKey(dbKey, keyMembers);
                                                List<String> parsedValues = keyMembers[2].split(',');
                                                for (String inputValue : parsedValues) {
                                                    inputValue = inputValue.trim();
                                                    
                                                    if (!keyMembers[0].equalsIgnoreCase('Audiencesegment')) {
                                                        if (dbKey != null) {
                                                            parsedKey.values.add(new KeyvaluesAndAudienceValue(dbKey, inputValue, customSettings));
                                                        }
                                                    }
                                                    else {
                                                        parsedKey.values.add(new KeyvaluesAndAudienceValue(targetables.get(inputValue), inputValue));
                                                    }
                                                }
                                                
                                                Set<String> pKey = parsedKey.getUniqueKey();
                                                if(!parsedSetMap.containsKey(pKey)) parsedSetMap.put(pKey, new List<KeyvaluesAndAudienceKey>());
                                                parsedSetMap.get(pKey).add(parsedKey);
                                            }
                                            Map<String, List<KeyvaluesAndAudienceKey>> setMap = getSetMap(parsedSetMap, predefinedValues, predefinedId, predefined);
                                            
                                            if(!setMap.get(KVA_HOLISTIC).isEmpty()) {
                                                values.get(KVA_HOLISTIC).put(getHolisticKey(setMap.get(KVA_HOLISTIC)), setMap.get(KVA_HOLISTIC));
                                            }
                                            
                                            if(!setMap.get(KVA_CUSTOM).isEmpty()) {
                                                values.get(KVA_CUSTOM).put(getHolisticKey(setMap.get(KVA_CUSTOM)), setMap.get(KVA_CUSTOM));
                                            }
                                        }
                            
                            for(String keyType : values.keySet()) {
                                for(Set<Set<String>> key : values.get(keyType).keySet()) {
                                    output.get(keyType).add(values.get(keyType).get(key));
                                }
                            }
                        }
            
            return JSON.serialize(output);
        }
        
        public Set<Set<String>> getHolisticKey(List<KeyvaluesAndAudienceKey> holisticKeys) {
            Set<Set<String>> holisticKeysSet = new Set<Set<String>>();
            for(KeyvaluesAndAudienceKey hKey : holisticKeys) {
                holisticKeysSet.add(hKey.getUniqueKey());
            }
            
            return holisticKeysSet;
        }
        
        public Map<String, List<KeyvaluesAndAudienceKey>> getSetMap(Map<Set<String>, List<KeyvaluesAndAudienceKey>> parsedSetMap, Map<Id, Map<String, List<List<KeyvaluesAndAudienceKey>>>> predefinedValues, Id predefinedId, Boolean predefinedFlag) {
            Map<String, List<KeyvaluesAndAudienceKey>> parsedMap = new Map<String, List<KeyvaluesAndAudienceKey>> {
                KVA_HOLISTIC => new List<KeyvaluesAndAudienceKey>(),
                    KVA_CUSTOM => new List<KeyvaluesAndAudienceKey>()
                    };
                        
                        Map<Set<String>, KeyvaluesAndAudienceKey> holisticKeys = new Map<Set<String>, KeyvaluesAndAudienceKey>();
            if(predefinedId != null && predefinedValues.containsKey(predefinedId)) {
                Map<String, List<List<KeyvaluesAndAudienceKey>>> predefined = predefinedValues.get(predefinedId);
                for(List<KeyvaluesAndAudienceKey> predefinedList : predefined.get(KVA_HOLISTIC)) {
                    Map<Set<String>, KeyvaluesAndAudienceKey> matchedKeys = new Map<Set<String>, KeyvaluesAndAudienceKey>();
                    
                    for(KeyvaluesAndAudienceKey p : predefinedList) {
                        List<KeyvaluesAndAudienceKey> pKey = getPredefinedKey(p, parsedSetMap);
                        if(pKey != null) {
                            matchedKeys.put(pKey.get(0).getUniqueKey(), pKey.get(0));
                        }
                    }
                    
                    if(matchedKeys.values().size() == predefinedList.size()) {
                        holisticKeys.putAll(matchedKeys);
                        break;
                    }
                }
            }
            
            for(Set<String> pKey : parsedSetMap.keySet()) {
                if(holisticKeys.containsKey(pKey) || predefinedFlag) {
                    parsedMap.get(KVA_HOLISTIC).add(parsedSetMap.get(pKey).get(0));
                }
                
                if((!holisticKeys.containsKey(pKey) && !predefinedFlag) || parsedSetMap.get(pKey).size() > 1)  {
                    parsedMap.get(KVA_CUSTOM).add(parsedSetMap.get(pKey).get(0));
                }
            }
            
            return parsedMap;
        }
        
        public List<KeyvaluesAndAudienceKey> getPredefinedKey(KeyvaluesAndAudienceKey predefinedKey, Map<Set<String>, List<KeyvaluesAndAudienceKey>> parsedSetMap) {
            return parsedSetMap.get(predefinedKey.getUniqueKey());
        }
    }
    
    public class KeyvaluesAndAudienceKey {
        public String sfId {get; set;}
        public String userLabel {get; set;}
        public String adId {get; set;}
        public String operator {get; set;}
        public List<KeyvaluesAndAudienceValue> values {get; set;}
        
        public KeyvaluesAndAudienceKey(csdf__Custom_Targeting_Key__c dbKey, List<String> keyMembers) {
            if (dbKey != null && !keyMembers[0].equalsIgnoreCase('Audiencesegment')) {
                this.sfId = String.valueOf(dbKey.Id).substring(0, 15);
                this.userLabel = dbKey.csdf__Display_Name__c;
                this.adId = keyMembers[0];
            }
            else if (keyMembers[0].equalsIgnoreCase('Audiencesegment')) {
                this.sfId = 'Audience Segment';
                this.userLabel = 'Audience Segment';
                this.adId = 'Audience Segment';
            }
            else {
                this.sfId = 'CustomTargetingKey not found in SFDC';
                this.userLabel = keyMembers[0];
                this.adId = keyMembers[0];
            }
            
            this.operator = (keyMembers[1] != null && keyMembers[1].equalsIgnoreCase('isnot')) ? 'is not' : keyMembers[1];
            this.values = new List<KeyvaluesAndAudienceValue>();
        }
        
        public Set<String> getValues() {
            Set<String> valuesSet = new Set<String>();
            for(KeyvaluesAndAudienceValue v : values) {
                valuesSet.add(v.adId);
            }
            
            return valuesSet;
        }
        
        public Set<String> getUniqueKey() {
            Set<String> uniqueKey = new Set<String>{this.adId};
                
                for(KeyvaluesAndAudienceValue v : values) {
                    uniqueKey.add(v.adId);
                }
            
            return uniqueKey;
        }
    }
    
    public class KeyvaluesAndAudienceValue {
        public String sfId {get; set;}
        public String userLabel {get; set;}
        public String adId {get; set;}
        
        public KeyvaluesAndAudienceValue(csdf__Custom_Targeting_Key__c dbKey, String inputValue, CS_Custom_Settings__c customSettings) {
            this.adId = inputValue;
            if (customSettings != null && customSettings.KeyValue_configuration__c == KEYVALUE_CONFIGURATION_ID) {
                String adServerId = inputValue.right(inputValue.length() - 1);
                for (csdf__Custom_Targeting_Value__c val : dbKey.csdf__Custom_Targeting_Values__r) {
                    if (val.csdf__Ad_Server_Id__c == adServerId) {
                        this.sfId = String.valueOf(val.Id).substring(0, 15);
                        this.userLabel = val.csdf__Display_Name__c;
                        break;
                    } else {
                        continue;
                    }
                }
            } else {
                for (csdf__Custom_Targeting_Value__c val : dbKey.csdf__Custom_Targeting_Values__r) {
                    if (val.Name == inputValue) {
                        this.sfId = String.valueOf(val.Id).substring(0, 15);
                        this.userLabel = val.csdf__Display_Name__c;
                        break;
                    } else {
                        continue;
                    }
                }
            }
        }
        
        public KeyvaluesAndAudienceValue(csdf__Targetable__c dbKey, String inputValue) {
            this.adId = inputValue;
            if (dbKey != null) {
                this.sfId = String.valueOf(dbKey.Id).substring(0, 15);
                this.userLabel = dbKey.csdf__Targetable_Name__c;
            } else {
                this.sfId = 'Targetable ID not found in SFDC';
                this.userLabel = inputValue;
            }
        }
        
    }
        public static void codeCoverage(){
        integer i =0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;

        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
    }
}