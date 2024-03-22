global without sharing class SyncOpportunity extends CS_ButtonBase {
    global override void init() {
        this.calloutType = 'SyncOpportunity';
        this.lastButtonClicked = 'Sync';
        this.className = SyncOpportunity.class.getName();
        this.isDfpAction = false; // to turn off loading screen later
        this.skipFulfilmentItemUpdate = true;
    }

    global override Boolean doAdditionalValidation() {
        if(checkDates())
    return false;
        if (!areAllConfigurationStatusesValid()
                || !isPrimarySo()
                || isStartDateOfAnyLineInThePast() ){//|| !checkDates()) {
            return false;
        }
        return true;
    }
    global final String AWARDS = 'Awards';
    global final String FASTKEY = 'FastKey';
    global final String EVENTS = 'Events';
    global final String CNS = 'China Solutions';
    global final String MAAS = 'Marketing Services';
    global final String DBSM = 'Database Marketing';
    global final String STANDARD = 'Standard Products';
    global final String DEV_LISTINGS = 'Developer Listings';
    global final String MPD_SUBS = 'MPD Subscriptions';
    global final String MPD_SOLS = 'MPD Custom Solutions';
    global final String MPD_Per= 'MPD Pay per use';
    global final String MPD_Offline = 'MPD Third-party Solution (Offline)';
    global final String AD_SERVED_UNIT_PRICE_ATTR = 'Net Rate';

    global override void doAction() {
        Map<String, cscfga__Product_Configuration__c> pcDescriptionToPcMap = new Map<String, cscfga__Product_Configuration__c>();
        Map<String, cscfga__Product_Configuration__c> attrDescriptionToPcMap = new Map<String, cscfga__Product_Configuration__c>();
        Set<String> createProduct = new Set<String>();
        Set<String> createStdPriceEntry = new Set<String>();
        Set<String> createPriceEntry = new Set<String>();
        Set<Id> pcId = new Set<Id>();
        Map<Id, String> pcNameId = new Map<Id, String>();
        Map<String, PricebookEntry> priceMap = new Map<String, PricebookEntry>();
        Map<String, PricebookEntry> stdPriceMap = new Map<String, PricebookEntry>();
        Map<String, Product2> prodMap = new Map<String, Product2>();
        Map<String, Product2> prodMapFastKey = new Map<String, Product2>();
        Map<String, cscfga__Attribute__c> lineItemPrice = new Map<String, cscfga__Attribute__c>();
        String pricebookName = '';
        Map<Id, Integer> snoMap = new Map<Id, Integer>();
        Set<Id> commIds = new Set<Id>();
        Set<Id> rateIds = new Set<Id>();
        Set<Id> addOnPriceItemIds = new Set<Id>();
        Map<Id, cspmb__Price_Item__c> commProdGstId = new Map<Id, cspmb__Price_Item__c>();
        Map<Id, cspmb__Add_On_Price_Item__c> idToAddOnPriceItemMap = new Map<Id, cspmb__Add_On_Price_Item__c>();
        Map<String, csmso__Rate_Card_Item_Price__c> rateGstId = new Map<String,csmso__Rate_Card_Item_Price__c>();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeAdServedMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityAdServed = new List<String>{'Insertion Quantity', 'Insertion Unit Type Display', 'Multiplier to Minimum Contract Quantity Days'};
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeDatabaseMarketingMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeStandardProductsMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityDatabaseMarketing = new List<String>{'Insertion Quantity'};
        List<String> attributeNamesQuantityStandardProducts = new List<String>{'Insertion Quantity'};
        Map<Id, Id> pcIdToTaxCodeOverrideIdMap = new Map<Id, Id>();
        Map<Id, Id> pcAddOnIdToTaxCodeOverrideIdMap = new Map<Id, Id>();
        Map<String,String> pickListLabel = getAPIValues();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeMPDOnlineMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityMPDOnline = new List<String>{'Insertion Quantity', 'Insertion Unit Type Display', 'Multiplier to Minimum Contract Quantity Days'};
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeAwardsWebsiteMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityAwardsWebsite = new List<String>{'Insertion Quantity', 'Insertion Unit Type Display', 'Multiplier to Minimum Contract Quantity Days'};
    
    //PROP-738
        List<String> attributeNamesQuantityDeveloperListing = new List<String>{'Insertion Quantity'};
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeDeveloperListMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        Map<Id,Map<String,cscfga__Attribute_Field__c>> FastKeyDateAttFieldMap = new Map<Id, Map<String,cscfga__Attribute_Field__c>>();
        System.debug('this.salesOrder.Id===' + this.salesOrder.Id);
        cscfga__Product_Basket__c basket = [
                SELECT Id, csmso__Sales_Order__c, (SELECT Id, Name,Aggregated_Status__c,Flight_Begin_Logged_User_Timezone__c, cscfga__Description__c, cscfga__Product_Family__c FROM cscfga__Product_Configurations__r)
                FROM cscfga__Product_Basket__c
                WHERE csmso__Sales_Order__c = :this.salesOrder.Id
        ];

        for (cscfga__Product_Configuration__c pc : basket.cscfga__Product_Configurations__r) {
            if(pc.cscfga__Product_Family__c != 'FastKey') {
                pcDescriptionToPcMap.put(pc.cscfga__Description__c, pc);
            }
            if(pc.Aggregated_Status__c!=null){   
            if (pc.Aggregated_Status__c.contains('Paused Inventory Released')) {
                continue;
            }
            }
            
            pcId.add(pc.Id);
        }
        System.debug('pcDescriptionToPcMap===' + pcDescriptionToPcMap.keySet());
        csmso__Sales_Order__c so = [
                SELECT Id, Primary_Sales_Order__c,csmso__Opportunity__c,
                        Synchronized_with_Opportunity__c
                FROM csmso__Sales_Order__c
                WHERE
                        Id = :this.salesOrder.Id
        ];

        Opportunity opp = [
                SELECT Id, Pricebook2Id, Pricebook2.Name, CurrencyIsoCode, (SELECT Id FROM OpportunityLineItems)
                FROM Opportunity
                WHERE Id = :so.csmso__Opportunity__c
        ];

        if (opp.OpportunityLineItems.size() > 0) {
            delete opp.OpportunityLineItems;
        }
        System.debug('opp===' + opp);

        List<cscfga__Product_Configuration__c> pcAttrList = [
                SELECT Id, Name, cscfga__Quantity__c, Start_Date__c,Insertion_Quantity__c,
                        End_Date__c,cscfga__Product_Family__c,Flight_Begin__c,Flight_End__c,
                        cscfga__Parent_Configuration__c, cscfga__originating_offer__c,cscfga__originating_offer__r.Name, cscfga__Description__c, (
                        SELECT Id, Name, cscfga__Price__c, cscfga__List_Price__c,
                                cscfga__Value__c, cscfga__Is_Line_Item__c, cscfga__Line_Item_Description__c
                        FROM
                                cscfga__Attributes__r
                )
                FROM cscfga__Product_Configuration__c
                WHERE
                Id IN:pcId AND cscfga__Parent_Configuration__c = NULL
        ];



        System.debug('pcAttrList>==' + pcAttrList);
        System.debug('pcAttrList===' + pcAttrList.size());

        List<cscfga__Product_Configuration__c> AddonPc = [
                SELECT Id, Name, cscfga__Quantity__c, Start_Date__c,Insertion_Quantity__c,
                        End_Date__c, cscfga__Product_Family__c,Flight_Begin__c,Flight_End__c,
                        cscfga__Parent_Configuration__c,
                        cscfga__Parent_Configuration__r.Name,cscfga__originating_offer__c,cscfga__originating_offer__r.Name, cscfga__Description__c, (
                        SELECT Id, Name, cscfga__Price__c, cscfga__List_Price__c,
                                cscfga__Value__c, cscfga__Is_Line_Item__c, cscfga__Line_Item_Description__c
                        FROM
                                cscfga__Attributes__r
                )
                FROM cscfga__Product_Configuration__c
                WHERE
                Id IN:pcId AND cscfga__Parent_Configuration__c != NULL
        ];
        System.debug('AddonPc===' + AddonPc.size());

        //helper maps for easier attribute retreiveal
        Map<Id,Map<String,cscfga__Attribute__c>> pcIdToAttributesByNameMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        Map<Id,Map<String,cscfga__Attribute__c>> addonPCIdToAttributesByNameMap = new Map<Id, Map<String, cscfga__Attribute__c>>();

        for (cscfga__Product_Configuration__c pc : pcAttrList) {

            if (pc.cscfga__Product_Family__c == 'Ad Served'
            || pc.cscfga__Product_Family__c == 'MPD Third-party Solution (Online)'
            || pc.cscfga__Product_Family__c == 'Awards (website)'
                    || pc.cscfga__Product_Family__c == 'Database Marketing'
                    || pc.cscfga__Product_Family__c == 'Developer Listings') {
                //AAJSON
                pcIdToAttributesByNameMap.put(pc.Id, new Map<String,cscfga__Attribute__c>());
                Attachment att = [SELECT Id,Body FROM Attachment WHERE ParentId =:pc.Id AND Name = 'Attributes as JSON' ORDER BY CreatedDate desc limit 1];
                aajson pcAajson = (aajson) JSON.deserialize(att.Body.toString(),aajson.class);
                att = null; //performance
                for (cscfga__Attribute__c attr : pcAajson.attributesByAttrDefId.values()){
                    pcIdToAttributesByNameMap.get(pc.Id).put(attr.Name,attr);
                }
                pcAajson = null; //performance
            }

            for (cscfga__Attribute__c att : pc.cscfga__Attributes__r) {

                //ad served unit price
                if ((pc.cscfga__Product_Family__c == 'Ad Served'
                || pc.cscfga__Product_Family__c == 'MPD Third-party Solution (Online)'
                || pc.cscfga__Product_Family__c == 'Awards (website)'
                        || pc.cscfga__Product_Family__c == 'Database Marketing'
                        || pc.cscfga__Product_Family__c == 'Developer Listings') && att.Name == AD_SERVED_UNIT_PRICE_ATTR) {
                    pcIdToAttributesByNameMap.get(pc.Id).put(att.Name,att);
                }

                if (att.Name == 'CommercialProduct') {
                    commIds.add(att.cscfga__Value__c);
                }

                if (att.cscfga__Is_Line_Item__c) {
                    lineItemPrice.put(pc.cscfga__Description__c, att);
                }

                System.debug('****** att.Name ');
                System.debug(att.Name);

                System.debug('****** att.cscfga__Value__c ');
                System.debug(att.cscfga__Value__c);

                if (att.Name == 'Tax Code Override'
                        && att.cscfga__Value__c != null) {
                    pcIdToTaxCodeOverrideIdMap.put(pc.Id, att.cscfga__Value__c);
                }

                if (pc.cscfga__Product_Family__c == 'Ad Served'
                        && attributeNamesQuantityAdServed.contains(att.Name)) {
                    if(pcIdToAttributeAdServedMap.get(pc.Id) == null) {
                        pcIdToAttributeAdServedMap.put(pc.Id, new Map<String, cscfga__Attribute__c>());
                    }
                    pcIdToAttributeAdServedMap.get(pc.Id).put(att.Name, att);
                }
                else if (pc.cscfga__Product_Family__c == 'MPD Third-party Solution (Online)'
                        && attributeNamesQuantityMPDOnline.contains(att.Name)) {
                    if(pcIdToAttributeMPDOnlineMap.get(pc.Id) == null) {
                        pcIdToAttributeMPDOnlineMap.put(pc.Id, new Map<String, cscfga__Attribute__c>());
                    }
                    pcIdToAttributeMPDOnlineMap.get(pc.Id).put(att.Name, att);
                }
                else if (pc.cscfga__Product_Family__c == 'Awards (website)'
                        && attributeNamesQuantityAwardsWebsite.contains(att.Name)) {
                    if(pcIdToAttributeAwardsWebsiteMap.get(pc.Id) == null) {
                        pcIdToAttributeAwardsWebsiteMap.put(pc.Id, new Map<String, cscfga__Attribute__c>());
                    }
                    pcIdToAttributeAwardsWebsiteMap.get(pc.Id).put(att.Name, att);
                }
                
                else if (pc.cscfga__Product_Family__c == DBSM
                        && attributeNamesQuantityDatabaseMarketing.contains(att.Name)) {
                    if(pcIdToAttributeDatabaseMarketingMap.get(pc.Id) == null) {
                        pcIdToAttributeDatabaseMarketingMap.put(pc.Id, new Map<String, cscfga__Attribute__c>());
                    }
                    pcIdToAttributeDatabaseMarketingMap.get(pc.Id).put(att.Name, att);
                }
                else if (pc.cscfga__Product_Family__c == DEV_LISTINGS 
                        && attributeNamesQuantityDeveloperListing.contains(att.Name)) {
                    if(pcIdToAttributeDeveloperListMap.get(pc.Id) == null) {
                        pcIdToAttributeDeveloperListMap.put(pc.Id, new Map<String, cscfga__Attribute__c>());
                    }
                    pcIdToAttributeDeveloperListMap.get(pc.Id).put(att.Name, att);
                }
                else if ((pc.cscfga__Product_Family__c == STANDARD || pc.cscfga__Product_Family__c == MAAS || pc.cscfga__Product_Family__c == FASTKEY || pc.cscfga__Product_Family__c == EVENTS || pc.cscfga__Product_Family__c == MPD_Offline || pc.cscfga__Product_Family__c == AWARDS ||  pc.cscfga__Product_Family__c == CNS ||pc.cscfga__Product_Family__c == MPD_SUBS ||pc.cscfga__Product_Family__c == MPD_SOLS )
                        && attributeNamesQuantityStandardProducts.contains(att.Name)) {
                    if(pcIdToAttributeStandardProductsMap.get(pc.Id) == null) {
                        pcIdToAttributeStandardProductsMap.put(pc.Id, new Map<String, cscfga__Attribute__c>());
                    }
                    pcIdToAttributeStandardProductsMap.get(pc.Id).put(att.Name, att);
                }
                else if (pc.cscfga__Product_Family__c == 'FastKey'
                        && att.cscfga__Is_Line_Item__c) {
FastKeyDateAttFieldMap.put(att.Id,new Map<String,cscfga__Attribute_Field__c>());
                    attrDescriptionToPcMap.put(att.cscfga__Line_Item_Description__c, pc);
                    lineItemPrice.put(att.cscfga__Line_Item_Description__c, att);

                    //Custom API DEvelopment is not a commercial product but need to add all the others
                    if (att.cscfga__Value__c != 'Yes') {
                        commIds.add(att.cscfga__Value__c);
                    }
                }
            }
        }
        if (!FastKeyDateAttFieldMap.isEmpty()) {
            for (cscfga__Attribute_Field__c attField : [
                    SELECT
                            Id,Name,cscfga__Value__c,cscfga__Attribute__c
                    FROM
                            cscfga__Attribute_Field__c
                    WHERE
                            cscfga__Attribute__c IN :FastKeyDateAttFieldMap.keySet()
                    AND
                            Name LIKE '%Date'])
            {
                FastKeyDateAttFieldMap.get(attField.cscfga__Attribute__c).put(attField.Name,attField);
            }
        }
        System.debug('pcIdToAttributesByNameMap===' + pcIdToAttributesByNameMap.values());
        //Ad Served and Rate Card Item Prices
        List<Id> naaIDs = new List<Id>();
        for (Id configId: pcIdToAttributesByNameMap.keySet()) {
            rateIds.add(pcIdToAttributesByNameMap.get(configId).get('Rate Card').cscfga__Value__c);
            naaIDs.add(pcIdToAttributesByNameMap.get(configId).get('Node Advert Assignments').cscfga__Value__c);
        }

        for (cscfga__Product_Configuration__c pc : AddonPc) {

            //AAJSON
            addonPCIdToAttributesByNameMap.put(pc.Id, new Map<String,cscfga__Attribute__c>());
            Attachment attachment = [SELECT Id,Body FROM Attachment WHERE ParentId =:pc.Id AND Name = 'Attributes as JSON'];
            aajson pcAajson = (aajson) JSON.deserialize(attachment.Body.toString(),aajson.class);
            attachment = null; //performance
            for (cscfga__Attribute__c attr : pcAajson.attributesByAttrDefId.values()){
                addonPCIdToAttributesByNameMap.get(pc.Id).put(attr.Name,attr);
            }
            pcAajson = null; //performance

            for (cscfga__Attribute__c att : pc.cscfga__Attributes__r) {

                if (att.Name == 'CommercialProduct') {
                    commIds.add(att.cscfga__Value__c);
                }
                System.debug('here===');
                if (att.cscfga__Is_Line_Item__c) {
                    System.debug('true==');
                    lineItemPrice.put(pc.cscfga__Description__c, att);
                }

                if(att.Name == 'AddOnCalculation') {
                    addOnPriceItemIds.add(att.cscfga__Value__c);
                }

                if (att.Name == 'Tax Code Override'
                        && att.cscfga__Value__c != null) {
                    pcAddOnIdToTaxCodeOverrideIdMap.put(pc.Id, att.cscfga__Value__c);
                }

                addonPCIdToAttributesByNameMap.get(pc.Id).put(att.Name,att);
            }
        }
        System.debug('commIds===' + commIds);
        System.debug('rateIds===' + rateIds);

        for (cspmb__Price_Item__c commProdList : [
                SELECT Id, Tax_Code__c, Tax_Code__r.Tax_Rate__c, Income_Account__c,Product_class__c,Product_Subclass__c, SKU__c, 
                        Product_Category__c,cspmb__Price_Item_Description__c, Line_Description__c
                FROM cspmb__Price_Item__c
                WHERE Id IN:commIds
        ]) {
            commProdGstId.put(commProdList.Id, commProdList);
        }

        for (cspmb__Add_On_Price_Item__c addOnPriceItem : [
                SELECT Id, Tax_Code__c, Tax_Code__r.Tax_Rate__c, Income_Account__c, Product_Category__c,Product_class__c,Product_Subclass__c, SKU__c 
                FROM cspmb__Add_On_Price_Item__c
                WHERE Id IN :addOnPriceItemIds
        ]) {
            idToAddOnPriceItemMap.put(addOnPriceItem.Id, addOnPriceItem);
        }

        for (csmso__Rate_Card_Item_Price__c ratePrice : [
                SELECT Id, Tax_Code__c, Tax_Code__r.Tax_Rate__c,
                        Income_Account__c, csmso__Rate_Card__c, Product_Category__c,Product_class__c,Product_Subclass__c,
                        csmso__Advert_Assignment__c,csmso__Advert_Assignment__r.Product_Info__c, SKU__c
                FROM csmso__Rate_Card_Item_Price__c
                WHERE
                csmso__Rate_Card__c IN:rateIds
                AND
                csmso__Advert_Assignment__c IN:naaIDs
        ]) {
            //RCIPs are a combination of ratecard and NAAA , ergo using joint key
            rateGstId.put( String.valueOf(ratePrice.csmso__Rate_Card__c) + String.valueOf(ratePrice.csmso__Advert_Assignment__c) , ratePrice);
        }



        if (opp.CurrencyIsoCode == 'SGD' ) {
            pricebookName = 'PG SG';
        } else if (opp.CurrencyIsoCode == 'IDR') {
            pricebookName = 'PG ID';
        } else if (opp.CurrencyIsoCode == 'MYR') {
            pricebookName = 'PG MY';
        } else if (opp.CurrencyIsoCode == 'THB') {
            pricebookName = 'PGI TH';
        }

        Pricebook2 priceBook = [SELECT Id, Name FROM Pricebook2 WHERE Id =: Opp.Pricebook2Id LIMIT 1];
        Pricebook2 stdPriceBook = [SELECT Id, Name FROM Pricebook2 WHERE Name = 'Standard Price Book' LIMIT 1];
        for (Product2 prod : [SELECT Id, Name FROM Product2 WHERE Name IN:pcDescriptionToPcMap.keySet() AND CurrencyIsoCode = :opp.CurrencyIsoCode and Segment__c != 'B2C Only']) {
            prodMap.put(prod.Name, prod);
        }

        // FastKey
        for (Product2 prodAttr : [SELECT Id, Name FROM Product2 WHERE Name IN:attrDescriptionToPcMap.keySet() AND CurrencyIsoCode = :opp.CurrencyIsoCode and Segment__c != 'B2C Only']) {
            prodMapFastKey.put(prodAttr.Name, prodAttr);
        }

        for (String str : pcDescriptionToPcMap.keySet()) {
            //creating only Product2s which were not found already
            if (!prodMap.containsKey(str)) {
                createProduct.add(str);
            }
        }

        // FastKey
        for (String str : attrDescriptionToPcMap.keySet()) {
            //creating only Product2s which were not found already
            if (!prodMapFastKey.containsKey(str)) {
                createProduct.add(str);
            }
        }

        System.debug('prodMap===' + prodMap);
        System.debug('createProduct===' + createProduct);
        List<Product2> prodList = new List<Product2>();
        for (String str : createProduct) {
            Product2 prod = new Product2(Name = str, CurrencyIsoCode = opp.CurrencyIsoCode);
            prodList.add(prod);
        }
        System.debug('b prodList====' + prodList);
        if (prodList.size() > 0) {
            insert prodList;
        }
        System.debug('a prodList====' + prodList);
        //query to get all products after insert of new products if any.
        if (!prodList.isEmpty() && prodList.size() > 0) {
            prodMap = new Map<String, Product2>();
            for (Product2 prod : [SELECT Id, Name FROM Product2 WHERE Name IN:pcDescriptionToPcMap.keySet() AND CurrencyIsoCode = :opp.CurrencyIsoCode and Segment__c != 'B2C Only']) {
                prodMap.put(prod.Name, prod);
            }

            // FastKey
            prodMapFastKey = new Map<String, Product2>();
            for (Product2 prod : [SELECT Id, Name FROM Product2 WHERE Name IN:attrDescriptionToPcMap.keySet() AND CurrencyIsoCode = :opp.CurrencyIsoCode and Segment__c != 'B2C Only']) {
                prodMapFastKey.put(prod.Name, prod);
            }
        }
        System.debug('final prodMap====' + prodMap);
        for (PricebookEntry priceEntry : [
                SELECT Id, Name, Product2.Name, CurrencyIsoCode, Pricebook2.Name
                FROM PricebookEntry
                WHERE
                Product2.Segment__c != 'B2C Only' and
                Product2.Name IN:pcDescriptionToPcMap.keySet() AND Pricebook2Id = :stdPriceBook.Id AND CurrencyIsoCode = :opp.CurrencyIsoCode
        ]) {
            stdPriceMap.put(priceEntry.Product2.Name, priceEntry);
        }

        // FastKey
        for (PricebookEntry priceEntry : [
                SELECT Id, Name, Product2.Name, CurrencyIsoCode, Pricebook2.Name
                FROM PricebookEntry
                WHERE
                Product2.Segment__c != 'B2C Only' and
                Product2.Name IN:attrDescriptionToPcMap.keySet() AND Pricebook2Id = :stdPriceBook.Id AND CurrencyIsoCode = :opp.CurrencyIsoCode
        ]) {
            stdPriceMap.put(priceEntry.Product2.Name, priceEntry);
        }

        for (PricebookEntry priceEntry : [
                SELECT Id, Name, Product2.Name, CurrencyIsoCode, Pricebook2.Name
                FROM PricebookEntry
                WHERE
                Product2.Segment__c != 'B2C Only' and
                Product2.Name IN:pcDescriptionToPcMap.keySet() AND Pricebook2Id = :priceBook.Id AND CurrencyIsoCode = :opp.CurrencyIsoCode
        ]) {
            priceMap.put(priceEntry.Product2.Name, priceEntry);
        }

        // FastKey
        for (PricebookEntry priceEntry : [
                SELECT Id, Name, Product2.Name, CurrencyIsoCode, Pricebook2.Name
                FROM PricebookEntry
                WHERE
                Product2.Segment__c != 'B2C Only' and
                Product2.Name IN:attrDescriptionToPcMap.keySet() AND Pricebook2Id = :priceBook.Id AND CurrencyIsoCode = :opp.CurrencyIsoCode
        ]) {
            priceMap.put(priceEntry.Product2.Name, priceEntry);
        }

        System.debug('stdPriceMap====' + stdPriceMap.keySet());
        System.debug('priceMap====' + priceMap.keySet());

        for (String str : pcDescriptionToPcMap.keySet()) {
            //create standard pricebook entry if no product exists
            if (!stdPriceMap.containsKey(str)) {
                createStdPriceEntry.add(str);
            }
        }

        // FastKey
        for (String str : attrDescriptionToPcMap.keySet()) {
            //create standard pricebook entry if no product exists
            if (!stdPriceMap.containsKey(str)) {
                createStdPriceEntry.add(str);
            }
        }

        System.debug('createStdPriceEntry===' + createStdPriceEntry);
        List<PricebookEntry> priceEntryList = new List<PricebookEntry>();
        //add price book entry to standard price book first.
        for (String str : createStdPriceEntry) {
            cscfga__Product_Configuration__c pc;
            if(pcDescriptionToPcMap.containsKey(str)) {
                pc = pcDescriptionToPcMap.get(str);
            }
            else if (attrDescriptionToPcMap.containsKey(str)) {
                pc = attrDescriptionToPcMap.get(str);
            }
            if (pc != null && pc.cscfga__Product_Family__c != 'FastKey' && lineItemPrice != null && lineItemPrice.containsKey(pc.cscfga__Description__c)) {
                cscfga__Attribute__c attribute = lineItemPrice.get(pc.cscfga__Description__c);
                PricebookEntry pe = new PricebookEntry();
                pe.IsActive = true;
                pe.CurrencyIsoCode = opp.CurrencyIsoCode;
                pe.UnitPrice = attribute.cscfga__List_Price__c != null ? attribute.cscfga__List_Price__c : 0;

                pe.Pricebook2Id = stdPriceBook.Id;
                pe.Product2Id = prodMap.get(str).Id;
                priceEntryList.add(pe);
            }
            else if (pc != null && pc.cscfga__Product_Family__c == 'FastKey' && lineItemPrice != null && lineItemPrice.containsKey(str)) {
                cscfga__Attribute__c attribute = lineItemPrice.get(str);
                PricebookEntry pe = new PricebookEntry();
                pe.IsActive = true;
                pe.CurrencyIsoCode = opp.CurrencyIsoCode;
                pe.UnitPrice = attribute.cscfga__List_Price__c != null ? attribute.cscfga__List_Price__c : 0;

                pe.Pricebook2Id = stdPriceBook.Id;
                pe.Product2Id = prodMapFastKey.get(str).Id;
                priceEntryList.add(pe);
            }
        }
        System.debug('priceEntryList===' + priceEntryList);
        System.debug('priceEntryList size===' + priceEntryList.size());
        if (!priceEntryList.isEmpty()) {
            insert priceEntryList;
        }


        for (String str : pcDescriptionToPcMap.keySet()) {
            //create custom pricebook entry if no product exists
            if ( !priceMap.containsKey(str) ) {
                createPriceEntry.add(str);
            }
        }

        // FastKey
        for (String str : attrDescriptionToPcMap.keySet()) {
            //create custom pricebook entry if no product exists
            if ( !priceMap.containsKey(str) ) {
                createPriceEntry.add(str);
            }
        }

        System.debug('createPriceEntry===' + createPriceEntry);
        //Add the pricebookentry to respective price book.
        priceEntryList = new List<PricebookEntry>();
        for (String str : createPriceEntry) {
            cscfga__Product_Configuration__c pc;
            if(pcDescriptionToPcMap.containsKey(str)) {
                pc = pcDescriptionToPcMap.get(str);
            }
            else if (attrDescriptionToPcMap.containsKey(str)) {
                pc = attrDescriptionToPcMap.get(str);
            }
            if (pc != null && pc.cscfga__Product_Family__c != 'FastKey' && lineItemPrice != null && lineItemPrice.containsKey(pc.cscfga__Description__c)) {
                cscfga__Attribute__c attribute = lineItemPrice.get(pc.cscfga__Description__c);
                PricebookEntry pe = new PricebookEntry();
                pe.IsActive = true;
                pe.CurrencyIsoCode = opp.CurrencyIsoCode;
                pe.UnitPrice = attribute.cscfga__List_Price__c != null ? attribute.cscfga__List_Price__c : 0;

                pe.Pricebook2Id = priceBook.Id;
                pe.Product2Id = prodMap.get(str).Id;
                priceEntryList.add(pe);
            }
            else if (pc != null && pc.cscfga__Product_Family__c == 'FastKey' && lineItemPrice != null && lineItemPrice.containsKey(str)) {
                cscfga__Attribute__c attribute = lineItemPrice.get(str);
                PricebookEntry pe = new PricebookEntry();
                pe.IsActive = true;
                pe.CurrencyIsoCode = opp.CurrencyIsoCode;
                pe.UnitPrice = attribute.cscfga__List_Price__c != null ? attribute.cscfga__Price__c : 0;

                pe.Pricebook2Id = priceBook.Id;
                pe.Product2Id = prodMapFastKey.get(str).Id;
                priceEntryList.add(pe);
            }
        }
        if (!priceEntryList.isEmpty()) {
            insert priceEntryList;
        }

        //query to get all price book entry after insert of new price book entry if any.
        if (!priceEntryList.isEmpty() && priceEntryList.size() > 0) {
            priceMap = new Map<String, PricebookEntry>();
            for (PricebookEntry priceEntry : [
                    SELECT Id, Name, Product2.Name, CurrencyIsoCode, Pricebook2.Name
                    FROM PricebookEntry
                    WHERE
                    Product2.Segment__c != 'B2C Only' and
                    Product2.Name IN:pcDescriptionToPcMap.keySet() AND Pricebook2Id = :priceBook.Id AND CurrencyIsoCode = :opp.CurrencyIsoCode
            ]) {
                priceMap.put(priceEntry.Product2.Name, priceEntry);
            }

            // FastKey
            for (PricebookEntry priceEntry : [
                    SELECT Id, Name, Product2.Name, CurrencyIsoCode, Pricebook2.Name
                    FROM PricebookEntry
                    WHERE
                    Product2.Segment__c != 'B2C Only' and
                    Product2.Name IN:attrDescriptionToPcMap.keySet() AND Pricebook2Id = :priceBook.Id AND CurrencyIsoCode = :opp.CurrencyIsoCode
            ]) {
                priceMap.put(priceEntry.Product2.Name, priceEntry);
            }
        }

        Map<Id, Tax_Code__c> taxCodeOverridesMap = new Map<Id, Tax_Code__c>([
                SELECT  Id,
                        Tax_Rate__c
                FROM Tax_Code__c
                WHERE Id IN :pcIdToTaxCodeOverrideIdMap.values()
        ]);

        Map<Id, Tax_Code__c> taxCodeOverridesAddOnMap = new Map<Id, Tax_Code__c>([
                SELECT  Id,
                        Tax_Rate__c
                FROM Tax_Code__c
                WHERE Id IN :pcAddOnIdToTaxCodeOverrideIdMap.values()
        ]);

        System.debug('ad served list ---> : ' + pcIdToAttributeAdServedMap);
        System.debug('prodMap===' + prodMap);
        System.debug('priceMap===' + priceMap);
        List<OpportunityLineItem> allOLI = new List<OpportunityLineItem>();
        Integer sno = 1;

        Set<String> commProductFamilies = new Set<String>{ EVENTS, AWARDS, CNS, MAAS, STANDARD, MPD_SUBS, MPD_SOLS,MPD_Offline,MPD_Per};

        for (cscfga__Product_Configuration__c pc : pcAttrList) {

            for (cscfga__Attribute__c attr : pc.cscfga__Attributes__r) {
                if (attr.cscfga__Is_Line_Item__c) {
                    System.debug('pc.cscfga__Description__c===' + pc.cscfga__Description__c);
                    //PricebookEntry pe = priceMap.get(pc.cscfga__Description__c);
                    System.debug('opp id=== ' + opp.CurrencyIsoCode);
                    System.debug('opp price book=== ' + opp.Pricebook2.Name);
                    //System.debug('pe=== ' + pe.CurrencyIsoCode);
                    //System.debug('pe pricebook=== ' + pe.Pricebook2.Name);
                    OpportunityLineItem oli = new OpportunityLineItem();
                    if(pc.cscfga__Product_Family__c == 'FastKey') {
                        oli.Product2Id = prodMapFastKey.get(attr.cscfga__Line_Item_Description__c).Id;
                        oli.PricebookEntryId = priceMap.get(attr.cscfga__Line_Item_Description__c).Id;
                    }
                    else {
                        oli.Product2Id = prodMap.get(pc.cscfga__Description__c).Id;
                        oli.PricebookEntryId = priceMap.get(pc.cscfga__Description__c).Id;
                    }
                    oli.OpportunityId = opp.Id;
                    if(pc.cscfga__Product_Family__c == 'Ad Served' && pcIdToAttributeAdServedMap.get(pc.Id) != null) {

                        oli.Quantity = Decimal.valueOf(pcIdToAttributeAdServedMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c);

                        if(pcIdToAttributeAdServedMap.get(pc.Id).get('Insertion Unit Type Display').cscfga__Value__c == 'CPM') {
                            oli.Quantity = oli.Quantity * Decimal.valueOf(pcIdToAttributeAdServedMap.get(pc.Id).get('Multiplier to Minimum Contract Quantity Days').cscfga__Value__c)/1000;
                        }

                    }
                        else if(pc.cscfga__Product_Family__c == 'MPD Third-party Solution (Online)' && pcIdToAttributeMPDOnlineMap.get(pc.Id) != null) {

                        oli.Quantity = Decimal.valueOf(pcIdToAttributeMPDOnlineMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c);

                        if(pcIdToAttributeMPDOnlineMap.get(pc.Id).get('Insertion Unit Type Display').cscfga__Value__c == 'CPM') {
                            oli.Quantity = oli.Quantity * Decimal.valueOf(pcIdToAttributeMPDOnlineMap.get(pc.Id).get('Multiplier to Minimum Contract Quantity Days').cscfga__Value__c)/1000;
                        }

                    }
                    else if(pc.cscfga__Product_Family__c == 'Awards (website)' && pcIdToAttributeAwardsWebsiteMap.get(pc.Id) != null) {

                        oli.Quantity = Decimal.valueOf(pcIdToAttributeAwardsWebsiteMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c);

                        if(pcIdToAttributeAwardsWebsiteMap.get(pc.Id).get('Insertion Unit Type Display').cscfga__Value__c == 'CPM') {
                            oli.Quantity = oli.Quantity * Decimal.valueOf(pcIdToAttributeAwardsWebsiteMap.get(pc.Id).get('Multiplier to Minimum Contract Quantity Days').cscfga__Value__c)/1000;
                        }

                    }
                
                    else if(pc.cscfga__Product_Family__c == DBSM && pcIdToAttributeDatabaseMarketingMap.get(pc.Id) != null) {
                        oli.Quantity = Decimal.valueOf(pcIdToAttributeDatabaseMarketingMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c);
                    }
                    else if((pc.cscfga__Product_Family__c == STANDARD || pc.cscfga__Product_Family__c == MAAS  || pc.cscfga__Product_Family__c == EVENTS || pc.cscfga__Product_Family__c == MPD_Offline || pc.cscfga__Product_Family__c == FASTKEY || pc.cscfga__Product_Family__c == AWARDS || pc.cscfga__Product_Family__c == CNS || pc.cscfga__Product_Family__c == MPD_SUBS || pc.cscfga__Product_Family__c == MPD_SOLS) && pcIdToAttributeStandardProductsMap.get(pc.Id) != null) {
                        oli.Quantity = Decimal.valueOf(pcIdToAttributeStandardProductsMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c);
                    }
                    else if(pc.cscfga__Product_Family__c == DEV_LISTINGS && pcIdToAttributeDeveloperListMap.get(pc.Id) != null) {
                                    oli.Quantity = Decimal.valueOf(pcIdToAttributeDeveloperListMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c);
                    } else if(pc.cscfga__Product_Family__c == 'MPD Pay per use') {
                        oli.Quantity = pc.Insertion_Quantity__c;
                    }
                    else {
                        oli.Quantity = pc.cscfga__Quantity__c;
                    }
                    oli.Originating_Offer__c = pc.cscfga__originating_offer__c;
                    oli.Originating_Offer_Name__c = pc.cscfga__originating_offer__r.Name;
                    if (pc.cscfga__Product_Family__c != 'Ad Served' && pc.cscfga__Product_Family__c != 'Awards (website)' && pc.cscfga__Product_Family__c != 'MPD Third-party Solution (Online)') {
                        if((pc.cscfga__Product_Family__c=='Events' || pc.cscfga__Product_Family__c == 'MPD Subscriptions') && attr.cscfga__List_Price__c == 0){
                                        oli.unitPrice= attr.cscfga__Price__c;

                                    }else{
                        oli.UnitPrice = attr.cscfga__List_Price__c;
                        if(attr.cscfga__List_Price__c!=null){
                        if (attr.cscfga__Price__c != attr.cscfga__List_Price__c && attr.cscfga__Price__c >= 0) {
                            oli.Discount_Amount__c = (attr.cscfga__List_Price__c - attr.cscfga__Price__c) * oli.Quantity;
                        }
                        }
                                    }
                    } else {
                        //discount is set as negative in Ad Served
                        // - Updated to reference list price rather than discounted price - oli.UnitPrice = Decimal.valueOf(pcIdToAttributesByNameMap.get(pc.Id).get('Net Unit Price').cscfga__Value__c);
                        //PROP-653
                        oli.UnitPrice = Decimal.valueOf(pcIdToAttributesByNameMap.get(pc.Id).get( AD_SERVED_UNIT_PRICE_ATTR ).cscfga__Value__c);
                        //oli.UnitPrice = Decimal.valueOf(pcIdToAttributesByNameMap.get(pc.Id).get('Net Unit Price').cscfga__Value__c);


                        Decimal adServedDiscount = Decimal.valueOf(pcIdToAttributesByNameMap.get(pc.Id).get('Net Rate Adjustment Flat').cscfga__Value__c);
                        if (adServedDiscount < 0) {
                            oli.Discount_Amount__c = adServedDiscount * -1;
                            oli.Discount_Amount__c = oli.Discount_Amount__c * oli.Quantity;
                        }
                    }

                    oli.Start_Date__c = pc.Flight_Begin__c;
                    oli.End_Date__c = pc.Flight_End__c;


                    // Fastkey has multiple line item products
                    if (pc.cscfga__Product_Family__c == 'FastKey' && attr.cscfga__Value__c!='Yes') {
                        oli.Commercial_Product__c = attr.cscfga__Value__c;
                        if (FastKeyDateAttFieldMap.containsKey(attr.Id) && !FastKeyDateAttFieldMap.get(attr.Id).isEmpty()) {

                            oli.Start_Date__c   = Date.valueOf(FastKeyDateAttFieldMap.get(attr.Id).get('Start Date').cscfga__Value__c);
                            oli.End_Date__c     = Date.valueOf(FastKeyDateAttFieldMap.get(attr.Id).get('End Date').cscfga__Value__c);
                    }
                    }



                    if (attr.Name == 'CommercialProduct') {
                        //other non-GAM line items
                        if ( commProductFamilies.contains(pc.cscfga__Product_Family__c) ) {
                            oli.Commercial_Product__c = attr.cscfga__Value__c;
                        }
                    }

                    String NULL_DESCRIPTION = 'No Product Info available for ';

                    if (oli.Commercial_Product__c != null && commProdGstId.containsKey(oli.Commercial_Product__c)) {
                        cspmb__Price_Item__c price = commProdGstId.get(oli.Commercial_Product__c);
                        oli.GST_VAT_Code__c = price.Tax_Code__c;
                        oli.Income_Account_Name__c = price.Income_Account__c;
                        oli.GST_VAT_Rate__c = price.Tax_Code__r.Tax_Rate__c;
                        oli.Product_Category__c = price.Product_Category__c;
                        oli.Product_class__c = price.Product_Class__c;
                        oli.SKU__c = price.SKU__c;
                        if(pickListLabel.containsKey(price.Product_Subclass__c)){
                        oli.product_subCLass__c = pickListLabel.get(price.Product_Subclass__c);
                        }
                        else
                            oli.product_subCLass__c = price.Product_Subclass__c;

                        if (price.Line_Description__c != null) {
                            oli.Line_Description2__c = String.valueOf(price.Line_Description__c).abbreviate(4000);
                        } else  {

                            oli.Line_Description2__c = NULL_DESCRIPTION  + oli.Commercial_Product__c;
                        }
                    }

                    if (pc.cscfga__Product_Family__c == 'Ad Served'
                    || pc.cscfga__Product_Family__c == 'MPD Third-party Solution (Online)'
                    || pc.cscfga__Product_Family__c == 'Awards (website)'
                            || pc.cscfga__Product_Family__c == 'Database Marketing'
                            || pc.cscfga__Product_Family__c == 'Developer Listings') {
                        cscfga__Attribute__c rateAttr = pcIdToAttributesByNameMap.get(pc.Id).get('Rate Card');
                        cscfga__Attribute__c naaAttr = pcIdToAttributesByNameMap.get(pc.Id).get('Node Advert Assignments');
                        String RC_NAA = rateAttr.cscfga__Value__c+naaAttr.cscfga__Value__c;
                        System.debug('RC_NAA =>'+ RC_NAA);
                        if (rateGstId.containsKey(RC_NAA)) {

                            csmso__Rate_Card_Item_Price__c ratePrice = rateGstId.get(RC_NAA);

                            oli.GST_VAT_Code__c = ratePrice.Tax_Code__c;
                            oli.Income_Account_Name__c = ratePrice.Income_Account__c;
                            oli.GST_VAT_Rate__c = ratePrice.Tax_Code__r.Tax_Rate__c;
                            oli.Product_Category__c = ratePrice.Product_Category__c;
                            oli.Rate_Card__c = ratePrice.Id;
                            oli.Product_class__c = ratePrice.Product_Class__c;
                            oli.SKU__c = ratePrice.SKU__c;
                            if(pickListLabel.containsKey(ratePrice.Product_Subclass__c)){
                        oli.product_subCLass__c = pickListLabel.get(ratePrice.Product_Subclass__c);
                        }
                        else
                            oli.product_subCLass__c =ratePrice.Product_Subclass__c;
                            if (ratePrice.csmso__Advert_Assignment__r.Product_Info__c != null) {
                                oli.Line_Description2__c = String.valueOf(ratePrice.csmso__Advert_Assignment__r.Product_Info__c).abbreviate(4000);
                            } else {
                                oli.Line_Description2__c = NULL_DESCRIPTION + ratePrice.csmso__Advert_Assignment__c;
                            }
                        }

                    }

                    System.debug('****** pcIdToTaxCodeOverrideIdMap');
                    System.debug(pcIdToTaxCodeOverrideIdMap);

                    if(pcIdToTaxCodeOverrideIdMap.containsKey(pc.Id)) {
                        oli.GST_VAT_Code__c = pcIdToTaxCodeOverrideIdMap.get(pc.Id);
                        oli.GST_VAT_Rate__c = taxCodeOverridesMap.get(pcIdToTaxCodeOverrideIdMap.get(pc.Id)).Tax_Rate__c;
                    }
                    oli.Product_Configuration__c = pc.Id;
                    oli.Record_Type__c = 'B2B';
                    oli.SNo__c = sno;

                    snoMap.put(pc.Id, sno);
                    sno = sno + 1;

                    allOLI.add(oli);
                }
            }
        }

        Integer num = 0;
        System.debug('priceMap===' + priceMap);
        for (cscfga__Product_Configuration__c pc : AddonPc) {
            num = num + 1;
            for (cscfga__Attribute__c attr : pc.cscfga__Attributes__r) {
                if (attr.cscfga__Is_Line_Item__c) {
                    System.debug('addon pc name===' + pc.cscfga__Description__c);
                    OpportunityLineItem oli = new OpportunityLineItem();
                    if(pc.cscfga__Product_Family__c == 'FastKey') {
                        oli.Product2Id = prodMapFastKey.get(attr.cscfga__Line_Item_Description__c).Id;
                        oli.PricebookEntryId = priceMap.get(attr.cscfga__Line_Item_Description__c).Id;
                    }
                    else {
                        oli.Product2Id = prodMap.get(pc.cscfga__Description__c).Id;
                        oli.PricebookEntryId = priceMap.get(pc.cscfga__Description__c).Id;
                    }
                    oli.OpportunityId = opp.Id;
                    oli.Quantity = pc.cscfga__Quantity__c;
                    oli.Originating_Offer__c = pc.cscfga__originating_offer__c;
                    oli.Originating_Offer_Name__c = pc.cscfga__originating_offer__r.Name;
                    if(attr.cscfga__List_Price__c==0){
                    oli.UnitPrice =attr.cscfga__Price__c;

                    }
                    else
                                        oli.UnitPrice = attr.cscfga__List_Price__c;
                                     
                        if(attr.cscfga__List_Price__c!=null && attr.cscfga__List_Price__c!=0){
                    if (attr.cscfga__Price__c != attr.cscfga__List_Price__c) {
                        oli.Discount_Amount__c = attr.cscfga__List_Price__c - attr.cscfga__Price__c;
                    }
                        }
                    oli.Start_Date__c = pc.Flight_Begin__c;
                    oli.End_Date__c = pc.Flight_End__c;
                    if (pc.cscfga__Product_Family__c == 'AddOn Product Definition') {
                        oli.Add_on__c = addonPCIdToAttributesByNameMap.get(pc.Id).get('AddOn').cscfga__Value__c;
                        oli.Commercial_Product__c = addonPCIdToAttributesByNameMap.get(pc.Id).get('CommercialProduct').cscfga__Value__c;

                        cspmb__Add_On_Price_Item__c addOnPriceItem = idToAddOnPriceItemMap.get(addonPCIdToAttributesByNameMap.get(pc.Id).get('AddOnCalculation').cscfga__Value__c);
                        oli.GST_VAT_Code__c = addOnPriceItem.Tax_Code__c;
                        oli.Income_Account_Name__c = addOnPriceItem.Income_Account__c;
                        oli.GST_VAT_Rate__c = addOnPriceItem.Tax_Code__r.Tax_Rate__c;
                        oli.Product_Category__c = addOnPriceItem.Product_Category__c;
                        oli.Product_class__c = addOnPriceItem.Product_Class__c;
                        oli.SKU__c = addOnPriceItem.SKU__c;
                        if(pickListLabel.containsKey(addOnPriceItem.Product_Subclass__c)){
                        oli.product_subCLass__c = pickListLabel.get(addOnPriceItem.Product_Subclass__c);
                        }
                        else
                        oli.product_subCLass__c = addOnPriceItem.Product_Subclass__c;
                        if(pcAddOnIdToTaxCodeOverrideIdMap.containsKey(pc.Id)) {
                            oli.GST_VAT_Code__c = pcAddOnIdToTaxCodeOverrideIdMap.get(pc.Id);
                            oli.GST_VAT_Rate__c = taxCodeOverridesAddOnMap.get(pcAddOnIdToTaxCodeOverrideIdMap.get(pc.Id)).Tax_Rate__c;
                        }
                    }

                    oli.Product_Configuration__c = pc.Id;
                    oli.Record_Type__c = 'B2B';
                    if (snoMap.containsKey(pc.cscfga__Parent_Configuration__c)) {
                        oli.SNo__c = Decimal.valueOf(snoMap.get(pc.cscfga__Parent_Configuration__c) + '.' + num);
                    }
                    allOLI.add(oli);
                }
            }
        }
        if (allOLI.size() > 0) {
            system.debug('******************');
            
            for(OpportunitylineItem oli : allOLI){
                system.debug(oli.Name   +' '+oli.Discount_Amount__c);
            }
            try{
            insert allOLI;
            }catch(exception e){
                  system.debug('ERROR: '+e.getStackTraceString());
            }
        }
        this.salesOrder.Synchronized_with_Opportunity__c = true;
    }
    global static map<String,String> getAPIValues(){
        

    Map<String,String>  myPicklist = new Map<String,String>();
    Schema.DescribeFieldResult field = cspmb__Add_On_Price_Item__c.Product_Subclass__c.getDescribe();

    for (Schema.PicklistEntry f : field.getPicklistValues())
        myPicklist.put(f.getvalue(),f.getLabel());

    return myPicklist;

    }
    global class aajson  {
        global aajson() {}
        global String productConfigurationId {get; set;}
        global Map<String,cscfga__Attribute__c> attributesByAttrDefId {get; set;}
        global Map<String, cscfga__Attribute_Field__c> attrFieldsByAttrDefId {get; set;}
    }
}