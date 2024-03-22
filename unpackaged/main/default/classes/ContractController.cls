/*
 * Test class: TestContractController
 * 
 */
public without sharing class ContractController {
    Public Opportunity selectedOpportunity{get;set;}
    Public List<cscfga__Product_Configuration__c> productConfigItemList{get;set;}
    public List<wrapOLI> allOLI{get;set;}
    public List<wrapOLI> OliList{get;set;}
    public String paymentClause {get;set;}
    public Map<Id,Decimal> MapQliIdAggrAmount{get;set;}
    public String SoType {get;set;}
    public String oppID {get;set;}
    public Date orderDate {get;set;}
    public Decimal oppTotal{get;set;}
    public String AgreementClause{get;set;}
    public Decimal TotalDiscount {get;set;}
    public Decimal TotalAmount {get;set;}
    public Decimal totalGSTValue {get;set;}
    public String companyAddress {get;set;}
    
    public list<String> countryManagerList {get;set;}
    public String isDraft {get;set;}
    public Decimal colSpanRemark {get;set;}
    public Decimal colSpanTotal {get;set;}
    public Decimal colSpanValTotal {get;set;}
    public Boolean isDetailed {get;set;}
    public OpportunityContactRole primaryBillingOCR{get;set;}
    public List<wrapSign> wrapSignList {get;set;} 
    Boolean isEvent = false;
    public string accountName {get;set;} 
    public string eventClause {get;set;} 
    public List<OpportunityContactRole> BillingOCRList{get;set;}
    public List<OpportunityContactRole> clientSignOCRList{get;set;}
    public string billingScheduleValue {get;set;} 
    public ContractController(String oppID,String SoType){
        this.SoType = SoType;
        this.oppID = oppID;
        getContract(); 
    }
    public ContractController() {
        
        if(ApexPages.currentPage() != null){
            oppid = ApexPages.currentPage().getParameters().get('Id');
            SoType = ApexPages.currentPage().getParameters().get('SoType');
        }
        
        if (SoType == 'SimpleDraft' || SoType == 'DetailedDraft') {
            isDraft = 'watermark';
        }
        if (SoType == 'DetailedFinal' || SoType == 'DetailedDraft') {
            isDetailed = true;
            colSpanRemark = 4;
            colSpanTotal = 4;
            colSpanValTotal=4;
        } else {
            isDetailed = false;
            //  colSpanRemark = 2;
            colSpanTotal = 3.5;
            colSpanValTotal=3.5;
        }
        String region = ApexPages.currentPage().getParameters().get('region');
        system.debug('regrion:' + region);
        getContract();
    }
    public void getContract(){
        countryManagerList = new List < String > ();
        selectedOpportunity = [select id, name,Billing_Entity_Suffix__c ,Subsidiary__r.Events_Claus__c, Opportunity_Number__c,Primary_Sales_Order__r.Customer_Approval__c,Order_Date__c, Subsidiary__r.Include_B2B_country_manager__c, Subsidiary__r.Name, Subsidiary__r.Logo_url__c, Subsidiary__r.Agreement_Clause__c, Subsidiary__r.Payment_Clause__c, Subsidiary__r.Company_Address__c,Subsidiary__r.Subsidiary_Code__c, Payment_Term__r.Name, Customer_PO__c, Owner.name, Re_print_Contract__c, Pricebook2Id, amount, Total_Discounted_Amount__c, Total_Tax_Amount__c, Total_Gross_Amount__c, b2b_Billing_Contact__c, b2b_Billing_Contact__r.Phone, Addressee__c,
                               accountid,b2b_Billing_Contact__r.Title,b2b_Billing_Contact__r.Account.BillingCountry,b2b_Billing_Contact__r.Name,Billing_Entity__r.BillingStreet,Billing_Entity__r.name, account.name, account.billingStreet, account.billingCity, account.billingState, account.billingCountry, subsidiary__r.Tax_label__c, b2b_Billing_Contact__r.Email, b2b_Billing_Contact__r.Fax,
                               account.billingpostalcode, account.Tax_Reg_Number__c, account.Branch_ID__c, account.shippingStreet, account.shippingCity, account.shippingState, Weighted_Revenue__c, Total_Gross_Amount_Display__c, Total_Discounted_Amount_display__c, Total_Tax_Amount_display__c,
                               Billing_Address__r.billing_Street__c,Billing_Address__r.Billing_City__c,Billing_Address__r.BillingCountry__c,Billing_Address__r.Billing_Postal_Code__c,Billing_Address__r.Billing_State__c,account.ShippingPostalCode, account.shippingCountry, country__c, currencyISOCode, Total_Complimentary_Value__c, Total_Complimentary_Value_display__c, Total_Amount_Before_Discount__c, Total_Amount_Before_Discount_display__c,
                               Billing_Street_new__c,Primary_Sales_Order__r.Owner.Email,Primary_Sales_Order__r.Owner.Name, Billing_City_new__c, Billing_Country_new__c, Billing_Zip_Postal_Code_new__c, Billing_State_Province_new__c,
                               Primary_Sales_Order__c,Primary_Sales_Order__r.NetSuite_Payment_Term__r.Name, Primary_Sales_Order__r.CreatedDate, Primary_Sales_Order__r.Total_Price_Calculated__c, Primary_Sales_Order__r.SO_Lines_Total_Discount__c,
                               Primary_Sales_Order__r.SO_Remarks__c, Primary_Sales_Order__r.Billing_schedule__c , CreatedDate, Primary_Sales_Order__r.SO_Gross_Amount__c, Primary_Sales_Order__r.SO_Start_Date_Manual__c,
                               (select id, role, Remarks__c, Attention__c, Contact.Email, Contact.Name, contact.title, contact.Account.name,
                                Contact.Account.BillingStreet, Contact.Account.BillingCity, Contact.Account.BillingState,
                                Contact.Account.BillingPostalCode, Contact.Account.BillingCountry, isPrimary from OpportunityContactRoles where role in ('Billing Contact', 'Client Signatory'))
                               from Opportunity where
                               id =: oppid
                              ];
        //companyAddress = 'khj'+selectedOpportunity.Subsidiary__r.Company_Address__c;
        if( selectedOpportunity.Primary_Sales_Order__r.Billing_schedule__c != null ){
            String billingType = selectedOpportunity.Primary_Sales_Order__r.Billing_schedule__c;
            switch on billingType {
                when 'Full bill upon signing'{
                    billingScheduleValue = 'Total amount will be billed upon signing this SOA';
                }
                when 'Full bill upon delivery'{
                    billingScheduleValue = 'Total amount will be billed at the start of delivery of this SOA';
                }
                when 'Bill by item'{
                    billingScheduleValue = 'Item amount will be billed at the start of delivery of each item in this SOA';
                }
                when '3 months'{
                    billingScheduleValue = 'Total amount will be split and billed for 3 consecutive months at the start of delivery of this SOA';
                }
                when '6 months'{
                    billingScheduleValue = 'Total amount will be split and billed for 6 consecutive months at the start of delivery of this SOA';
                    
                }
                when '12 months'{
                    billingScheduleValue = 'Total amount will be split and billed for 12 consecutive months at the start of delivery of this SOA';
                }
                
            }
        }
        // oppTotal = selectedOpportunity.Primary_Sales_Order__r.Total_Price_Calculated__c;
        if (selectedOpportunity.Subsidiary__r.Include_B2B_country_manager__c == true) {
            String roleName;
            
            if (selectedOpportunity.Country__c == 'Indonesia') {
                
                roleName = 'ID - Country Manager';
            } else if (selectedOpportunity.Country__c == 'Malaysia') {
                roleName = 'MY - Country Manager';
                
            } else if (selectedOpportunity.Country__c == 'Singapore') {
                roleName = 'SG - Country Manager';
                
            } else if (selectedOpportunity.Country__c == 'Thailand') {
                roleName = 'TH - Country Manager';
                
            }
            system.debug('********' + roleName);
            for (User u: [select id, name from user where userRole.name =: roleName]) {
                countryManagerList.add(u.name);
            }
            
        }
        countryManagerList.add(selectedOpportunity.owner.Name);
        
        AgreementClause = selectedOpportunity.Subsidiary__r.agreement_clause__c;
        
        productConfigItemList = [Select Id, name, cscfga__Quantity__c, Start_Date__c, End_Date__c, cscfga__Description__c,
                                 (Select Id, name, cscfga__Price__c,
                                  cscfga__List_Price__c,
                                  cscfga__Value__c, cscfga__Is_Line_Item__c from cscfga__Attributes__r where cscfga__Is_Line_Item__c = true or name = 'CommercialProduct')
                                 from cscfga__Product_Configuration__c where Sales_Order__c =: selectedOpportunity.Primary_Sales_Order__c
                                ];
    }
    public void updateOppRePrintFalse() {
        selectedOpportunity.Re_print_Contract__c = False;
        accountName = selectedOpportunity.Account.Name;
        if(selectedOpportunity.order_date__c == null){
            selectedOpportunity.Order_Date__c = selectedOpportunity.Primary_Sales_Order__r.SO_Start_Date_Manual__c;
            orderDate=selectedOpportunity.Primary_Sales_Order__r.SO_Start_Date_Manual__c;
        }
        else if(selectedOpportunity.Primary_Sales_Order__r.Customer_Approval__c == 'Approved'){
            orderDate =  selectedOpportunity.Order_Date__c;
        } 
        else {
            orderDate=selectedOpportunity.Primary_Sales_Order__r.SO_Start_Date_Manual__c;
            selectedOpportunity.Order_Date__c = selectedOpportunity.Primary_Sales_Order__r.SO_Start_Date_Manual__c;
        }
        //   orderDate=selectedOpportunity.Primary_Sales_Order__r.SO_Start_Date_Manual__c;
        system.debug('orderdate' + selectedOpportunity.Order_Date__c);
        update selectedOpportunity;
    } 
    
    
    
    public void generateContractPDF() {
        updateOppRePrintFalse();
        allOLI = new List < wrapOLI > ();
        //List<wrapOLI>
        oliList = new List < wrapOLI > ();
        //  QLiSortedList = new List<QuoteLineItem>();
        //   unprocessedqliList = new List<QuoteLineItem>();
        MapQliIdAggrAmount = new Map < Id, Decimal > ();
        //  BundledList = new List<QuoteLineItem>();
        primaryBillingOCR = new OpportunityContactRole();
        clientSignOCRList = new list < OpportunityContactRole > ();
        wrapSignList = new List < wrapSign > ();
        BillingOCRList = new list < OpportunityContactRole > ();
        
        String AWARDS = 'Awards';
        String FASTKEY = 'FastKey';
        String EVENTS = 'Events';
        String CNS = 'China Solutions';
        String MAAS = 'Marketing Services';
        String DBSM = 'Database Marketing';
        String DEV_LISTINGS = 'Developer Listings';
        String STANDARD = 'Standard Products';
        String AD_SERVED_UNIT_PRICE_ATTR = 'Net Rate';
        String MPD_SUBS = 'MPD Subscriptions';
        String MPD_SOLS = 'MPD Custom Solutions';
        String MPD_Per= 'MPD Pay per use';
        String MPD_Offline = 'MPD Third-party Solution (Offline)';
        
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
        Set<String> commIds = new Set<String>();
        Set<String> rateIds = new Set<String>();
        Set<Id> addOnPriceItemIds = new Set<Id>();
        Set<Id> lineItemId = new Set<Id>();
        Map<Id, cspmb__Price_Item__c> commProdGstId = new Map<Id, cspmb__Price_Item__c>();
        Map<Id, cspmb__Add_On_Price_Item__c> idToAddOnPriceItemMap = new Map<Id, cspmb__Add_On_Price_Item__c>();
        Map<String, csmso__Rate_Card_Item_Price__c> rateGstId = new Map<String,csmso__Rate_Card_Item_Price__c>();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeAdServedMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityAdServed = new List<String>{'Insertion Quantity', 'Insertion Unit Type Display', 'Multiplier to Minimum Contract Quantity Days'};
            Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeDatabaseMarketingMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeDeveloperListMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeStandardProductsMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityDatabaseMarketing = new List<String>{'Insertion Quantity'};
            List<String> attributeNamesQuantityDeveloperListing = new List<String>{'Insertion Quantity'};
                List<String> attributeNamesQuantityStandardProducts = new List<String>{'Insertion Quantity'};
                    Map<Id, Id> pcIdToTaxCodeOverrideIdMap = new Map<Id, Id>();
        Map<Id, Id> pcAddOnIdToTaxCodeOverrideIdMap = new Map<Id, Id>();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeMPDOnlineMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityMPDOnline = new List<String>{'Insertion Quantity', 'Insertion Unit Type Display', 'Multiplier to Minimum Contract Quantity Days'};
            Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeAwardsWebsiteMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityAwardsWebsite = new List<String>{'Insertion Quantity', 'Insertion Unit Type Display', 'Multiplier to Minimum Contract Quantity Days'};
            companyAddress = selectedOpportunity.Subsidiary__r.Company_Address__c;//.replaceAll('\\<.*?\\>', '');
            cscfga__Product_Basket__c basket = [
                SELECT Id, csmso__Sales_Order__c, (SELECT Id, Name,Aggregated_Status__c, cscfga__Description__c, cscfga__Product_Family__c FROM cscfga__Product_Configurations__r)
                FROM cscfga__Product_Basket__c
                WHERE csmso__Sales_Order__c =: selectedOpportunity.Primary_Sales_Order__c
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
        
        List<cscfga__Product_Configuration__c> pcAttrList = [
            SELECT Id, Name, cscfga__Quantity__c, Start_Date__c, Additional_Comments__c,District__c ,Insertion_Quantity__c,
            End_Date__c, cscfga__Product_Family__c, Flight_Begin__c, Flight_End__c,cscfga__package_guid__c,
            cscfga__Parent_Configuration__c, cscfga__originating_offer__c, cscfga__originating_offer__r.Disallow_Detailed_S_O_Print_Out__c, cscfga__originating_offer__r.cscfga__Description__c,  cscfga__originating_offer__r.name, cscfga__Description__c, (
                SELECT Id, Name, cscfga__Price__c, cscfga__List_Price__c,
                cscfga__Value__c, cscfga__Is_Line_Item__c, cscfga__Line_Item_Description__c
                FROM
                cscfga__Attributes__r
            )
            FROM cscfga__Product_Configuration__c
            WHERE
            Id IN:pcId AND cscfga__Parent_Configuration__c = NULL
        ];
        System.debug('pcAttrList size===' + pcAttrList.size());
        System.debug('pcAttrList===' + pcAttrList);
        
        List<cscfga__Product_Configuration__c> AddonPc = [
            SELECT Id, Name, cscfga__Quantity__c, Start_Date__c, Additional_Comments__c,Insertion_Quantity__c,
            End_Date__c, cscfga__Product_Family__c, Flight_Begin__c, Flight_End__c,cscfga__package_guid__c,
            cscfga__Parent_Configuration__c,
            cscfga__Parent_Configuration__r.Name, cscfga__originating_offer__c, cscfga__originating_offer__r.Disallow_Detailed_S_O_Print_Out__c,
            cscfga__originating_offer__r.name, cscfga__Description__c, (
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
        Map<Id,Map<String,cscfga__Attribute__c>> AddonPCIdToAttributesByNameMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        
        for (cscfga__Product_Configuration__c pc : pcAttrList) {
            
            if(pc.cscfga__Product_Family__c == EVENTS)
                isEvent = true;            
            if (pc.cscfga__Product_Family__c == 'Ad Served'
                || pc.cscfga__Product_Family__c == 'Database Marketing'
                || pc.cscfga__Product_Family__c == 'MPD Third-party Solution (Online)'
                || pc.cscfga__Product_Family__c == 'Awards (website)'
                || pc.cscfga__Product_Family__c == 'Developer Listings') {
                    //AAJSON
                    pcIdToAttributesByNameMap.put(pc.Id, new Map<String,cscfga__Attribute__c>());
                    Attachment att = [SELECT ID,Body FROM Attachment WHERE ParentId =:pc.Id AND NAME = 'Attributes as JSON' ORDER BY CreatedDate desc limit 1];
                    System.debug('att.Body.toString()'+att.Body);
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
                    if (att.cscfga__Value__c Instanceof ID) {
                        lineItemId.add(att.cscfga__Value__c);
                    }
                    lineItemPrice.put(pc.cscfga__Description__c, att);
                }
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
                
                else if (pc.cscfga__Product_Family__c == DBSM &&
                         attributeNamesQuantityDatabaseMarketing.contains(att.Name)) {
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
                             attrDescriptionToPcMap.put(att.cscfga__Line_Item_Description__c, pc);
                             lineItemPrice.put(att.cscfga__Line_Item_Description__c, att);
                             
                             //Custom API DEvelopment is not a commercial product but need to add all the others
                             if (att.cscfga__Value__c != 'Yes') {
                                 commIds.add(att.cscfga__Value__c);
                             }
                         }
            }
        }
        //Ad Served and Rate Card Item Prices
        List<Id> naaIDs = new List<Id>();
        for (Id configId: pcIdToAttributesByNameMap.keySet()) {
            if (pcIdToAttributesByNameMap.containsKey(configId) && pcIdToAttributesByNameMap.get(configId).get('Rate Card') != null)
                rateIds.add(pcIdToAttributesByNameMap.get(configId).get('Rate Card').cscfga__Value__c);
            if (pcIdToAttributesByNameMap.containsKey(configId) && pcIdToAttributesByNameMap.get(configId).get('Node Advert Assignments') != null)
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
                    if (att.cscfga__Value__c Instanceof ID) {
                        lineItemId.add(att.cscfga__Value__c);
                    }
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
            SELECT Id, Tax_Code__c, Tax_Code__r.Tax_Rate__c, Income_Account__c,
            Product_Category__c, cspmb__Price_Item_Description__c, Line_Description__c
            FROM cspmb__Price_Item__c
            WHERE Id IN: commIds
        ]) {
            commProdGstId.put(commProdList.Id, commProdList);
        }
        for (cspmb__Add_On_Price_Item__c addOnPriceItem : [
            SELECT Id, Tax_Code__c, Tax_Code__r.Tax_Rate__c,cspmb__Add_On_Price_Item_Description__c, Income_Account__c, Product_Category__c
            FROM cspmb__Add_On_Price_Item__c
            WHERE Id IN :addOnPriceItemIds
        ]) {
            idToAddOnPriceItemMap.put(addOnPriceItem.Id, addOnPriceItem);
        }
        for (csmso__Rate_Card_Item_Price__c ratePrice : [
            SELECT Id, Tax_Code__c, Tax_Code__r.Tax_Rate__c,
            Income_Account__c, csmso__Rate_Card__c, Product_Category__c,
            csmso__Advert_Assignment__c, csmso__Advert_Assignment__r.Product_Info__c
            FROM csmso__Rate_Card_Item_Price__c
            WHERE
            csmso__Rate_Card__c IN:rateIds
            AND
            csmso__Advert_Assignment__c IN:naaIDs
        ]) {
            //RCIPs are a combination of ratecard and NAAA , ergo using joint key
            rateGstId.put(String.valueOf(ratePrice.csmso__Rate_Card__c) + String.valueOf(ratePrice.csmso__Advert_Assignment__c), ratePrice);
        }
        Map<Id, Tax_Code__c> taxCodeOverridesMap = new Map<Id, Tax_Code__c> ([
            SELECT Id,
            Tax_Rate__c
            FROM Tax_Code__c
            WHERE Id IN: pcIdToTaxCodeOverrideIdMap.values()
        ]);
        Map<Id, Tax_Code__c> taxCodeOverridesAddOnMap = new Map<Id, Tax_Code__c>([
            SELECT  Id,
            Tax_Rate__c
            FROM Tax_Code__c
            WHERE Id IN :pcAddOnIdToTaxCodeOverrideIdMap.values()
        ]);
        Set<String> commProductFamilies = new Set<String> {
            EVENTS,
                AWARDS,
                CNS,
                MAAS,
                STANDARD,
                MPD_SUBS,
                MPD_SOLS,
                MPD_Offline,
                MPD_Per 
                };
                    
                    for (cscfga__Product_Configuration__c pc: pcAttrList) {
                        for (cscfga__Attribute__c attr: pc.cscfga__Attributes__r) {
                            if (attr.cscfga__Is_Line_Item__c) {
                                wrapOLI oli = new wrapOLI();
                                if (attr.name == 'Description') {
                                    oli.LineDescription2 = attr.cscfga__Value__c;
                                } 
                                if(pc.cscfga__Product_Family__c == 'Developer Listings'){
                                    oli.Name = pc.cscfga__Description__c;
                                    if(pc.District__c != null){
                                        oli.Name +=' '+ pc.District__c; 
                                    }
                                }
                                else if (pc.cscfga__Product_Family__c == 'FastKey') {
                                    oli.Name = attr.cscfga__Line_Item_Description__c;
                                } else {
                                    oli.Name = pc.cscfga__Description__c;
                                }
                                oli.additionalNote = pc.Additional_Comments__c;
                                if (pc.cscfga__Product_Family__c == 'Ad Served' && pcIdToAttributeAdServedMap.get(pc.Id) != null) {
                                    if (pcIdToAttributeAdServedMap.get(pc.Id).get('Insertion Quantity') != null && pcIdToAttributeAdServedMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c != null)
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
                                else if((pc.cscfga__Product_Family__c == STANDARD || pc.cscfga__Product_Family__c == MAAS  || pc.cscfga__Product_Family__c == EVENTS || pc.cscfga__Product_Family__c == MPD_Offline|| pc.cscfga__Product_Family__c == FASTKEY || pc.cscfga__Product_Family__c == AWARDS || pc.cscfga__Product_Family__c == CNS || pc.cscfga__Product_Family__c == MPD_SUBS || pc.cscfga__Product_Family__c == MPD_SOLS) && pcIdToAttributeStandardProductsMap.get(pc.Id) != null) {
                                    oli.Quantity = Decimal.valueOf(pcIdToAttributeStandardProductsMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c);
                                }
                                else if(pc.cscfga__Product_Family__c == DEV_LISTINGS && pcIdToAttributeDeveloperListMap.get(pc.Id) != null) {
                                    oli.Quantity = Decimal.valueOf(pcIdToAttributeDeveloperListMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c);
                                }  else if(pc.cscfga__Product_Family__c == 'MPD Pay per use') {
                                    oli.Quantity = pc.Insertion_Quantity__c;
                                }
                                else {
                                    oli.Quantity = pc.cscfga__Quantity__c;
                                }
                                oli.Offer = pc.cscfga__originating_offer__c + pc.cscfga__package_guid__c;
                                if (oli.Offer != null)
                                    oli.offerName = pc.cscfga__originating_offer__r.Name;
                                if (pc.cscfga__Product_Family__c != 'Ad Served'  && pc.cscfga__Product_Family__c != 'Awards (website)'  && pc.cscfga__Product_Family__c != 'MPD Third-party Solution (Online)') {
                                    if((pc.cscfga__Product_Family__c == 'Events' || pc.cscfga__Product_Family__c == 'MPD Subscriptions') && attr.cscfga__List_Price__c == 0){
                                        oli.unitPrice= attr.cscfga__Price__c;
                                        
                                    }else{
                                        oli.UnitPrice = attr.cscfga__List_Price__c;
                                        if (attr.cscfga__Price__c != attr.cscfga__List_Price__c) {
                                            if(attr.cscfga__List_Price__c!=null &&  attr.cscfga__Price__c!=null)
                                                oli.DiscountAmount = (attr.cscfga__List_Price__c - attr.cscfga__Price__c) * oli.Quantity;
                                        }
                                    }
                                } else {
                                    if (pcIdToAttributesByNameMap != null && pcIdToAttributesByNameMap.containsKey(pc.id)) {
                                        //discount is set as negativ in Ad Served
                                        if (pcIdToAttributesByNameMap.get(pc.Id).get(AD_SERVED_UNIT_PRICE_ATTR ) != null) {
                                            oli.UnitPrice = Decimal.valueOf(pcIdToAttributesByNameMap.get(pc.Id).get(AD_SERVED_UNIT_PRICE_ATTR ).cscfga__Value__c);
                                            if (pcIdToAttributesByNameMap.get(pc.Id).get('Net Rate Adjustment Flat') != null) {
                                                Decimal adServedDiscount = Decimal.valueOf(pcIdToAttributesByNameMap.get(pc.Id).get('Net Rate Adjustment Flat').cscfga__Value__c);
                                                if (adServedDiscount<0) {
                                                    oli.DiscountAmount = adServedDiscount * -1;
                                                    oli.DiscountAmount = oli.DiscountAmount * oli.Quantity;
                                                }
                                            }
                                        }
                                    }
                                }
                                system.debug('unitprice==>' +oli.unitprice);
                                if(oli.UnitPrice == null){
                                    oli.UnitPrice = 0;
                                }
                                
                                oli.StartDate = pc.Flight_Begin__c;
                                oli.EndDate = pc.Flight_End__c;
                                
                                
                                // Fastkey has multiple line item products
                                if (pc.cscfga__Product_Family__c == 'FastKey' && attr.cscfga__Value__c != 'Yes') {
                                    oli.CommProd = attr.cscfga__Value__c;
                                }
                                
                                
                                
                                if (attr.Name == 'CommercialProduct') {
                                    //other non-GAM line items
                                    if (commProductFamilies.contains(pc.cscfga__Product_Family__c)) {
                                        oli.CommProd = attr.cscfga__Value__c;
                                        
                                    }
                                }
                                
                                if (oli.CommProd != null && commProdGstId.containsKey(oli.CommProd)) {
                                    cspmb__Price_Item__c price = commProdGstId.get(oli.CommProd);
                                    if (price.Tax_Code__r.Tax_Rate__c != null)
                                        oli.GSTVATRate = price.Tax_Code__r.Tax_Rate__c;
                                    if (price.Line_Description__c != null) {
                                        oli.LineDescription2 = String.valueOf(price.Line_Description__c).abbreviate(4000);
                                    }
                                }
                                
                                
                                if (pc.cscfga__Product_Family__c == 'Ad Served'
                                    || pc.cscfga__Product_Family__c == 'MPD Third-party Solution (Online)'
                                    || pc.cscfga__Product_Family__c == 'Awards (website)'
                                    || pc.cscfga__Product_Family__c == 'Database Marketing'
                                    || pc.cscfga__Product_Family__c == 'Developer Listings') {
                                        cscfga__Attribute__c rateAttr = pcIdToAttributesByNameMap.get(pc.Id).get('Rate Card');
                                        cscfga__Attribute__c naaAttr = pcIdToAttributesByNameMap.get(pc.Id).get('Node Advert Assignments');
                                        String RC_NAA = '';
                                        if (rateAttr != null) {
                                            RC_NAA = rateAttr.cscfga__Value__c;
                                        }
                                        
                                        if (naaAttr != null) {
                                            RC_NAA = RC_NAA + naaAttr.cscfga__Value__c;
                                        }
                                        
                                        System.debug('RC_NAA =>' + RC_NAA);
                                        if (RC_NAA != null && RC_NAA != '') {
                                            if (rateGstId.containsKey(RC_NAA)) {
                                                
                                                csmso__Rate_Card_Item_Price__c ratePrice = rateGstId.get(RC_NAA);
                                                if (ratePrice.Tax_Code__r.Tax_Rate__c != null)
                                                    oli.GSTVATRate = ratePrice.Tax_Code__r.Tax_Rate__c;
                                                
                                                if (ratePrice.csmso__Advert_Assignment__r.Product_Info__c != null) {
                                                    oli.LineDescription2 = String.valueOf(ratePrice.csmso__Advert_Assignment__r.Product_Info__c).abbreviate(4000);
                                                }
                                            }
                                        }
                                    }
                                
                                if(pcIdToTaxCodeOverrideIdMap.containsKey(pc.Id)) {
                                    if (taxCodeOverridesMap.get(pcIdToTaxCodeOverrideIdMap.get(pc.Id)).Tax_Rate__c != null)
                                        oli.GSTVATRate = taxCodeOverridesMap.get(pcIdToTaxCodeOverrideIdMap.get(pc.Id)).Tax_Rate__c;
                                }
                                oli.offerDescription2 = pc.cscfga__originating_offer__r.cscfga__Description__c;
                                oliList.add(oli);
                            }
                        }
                    }
        for (cscfga__Product_Configuration__c pc: AddonPc) {
            for (cscfga__Attribute__c attr: pc.cscfga__Attributes__r) {
                if (attr.cscfga__Is_Line_Item__c) {
                    wrapOLI oli = new wrapOLI();
                    if (pc.cscfga__Product_Family__c == 'FastKey') {
                        oli.Name = attr.cscfga__Line_Item_Description__c;
                    }
                    else {
                        oli.Name = pc.cscfga__Description__c;
                    }
                    oli.Quantity = pc.cscfga__Quantity__c;
                    oli.offer = pc.cscfga__originating_offer__c + pc.cscfga__package_guid__c;
                    if (oli.Offer != null)
                        oli.offerName = pc.cscfga__originating_offer__r.Name;
                    oli.additionalNote = pc.Additional_Comments__c;
                    if(attr.cscfga__List_Price__c==0){
                        oli.UnitPrice =attr.cscfga__Price__c    ;
                        
                    }
                    else{
                        oli.UnitPrice = attr.cscfga__List_Price__c;
                    }
                    //  oli.UnitPrice = attr.cscfga__List_Price__c;
                    if (attr.cscfga__Price__c != attr.cscfga__List_Price__c ) {
                        if(attr.cscfga__List_Price__c!=null &&  attr.cscfga__Price__c!=null && attr.cscfga__List_Price__c!=0)
                            oli.DiscountAmount = attr.cscfga__List_Price__c - attr.cscfga__Price__c;
                    }
                    oli.StartDate = pc.Flight_Begin__c;
                    oli.EndDate = pc.Flight_End__c;
                    if (pc.cscfga__Product_Family__c == 'AddOn Product Definition') {
                        oli.CommProd = addonPCIdToAttributesByNameMap.get(pc.Id).get('CommercialProduct').cscfga__Value__c;
                        cspmb__Add_On_Price_Item__c addOnPriceItem = idToAddOnPriceItemMap.get(addonPCIdToAttributesByNameMap.get(pc.Id).get('AddOnCalculation').cscfga__Value__c);
                        if (addOnPriceItem.cspmb__Add_On_Price_Item_Description__c != null) {
                            oli.LineDescription2 = String.valueOf(addOnPriceItem.cspmb__Add_On_Price_Item_Description__c).abbreviate(4000);
                        }
                        oli.GSTVATRate = addOnPriceItem.Tax_Code__r.Tax_Rate__c;
                        if(pcAddOnIdToTaxCodeOverrideIdMap.containsKey(pc.Id)) {
                            oli.GSTVATRate = taxCodeOverridesAddOnMap.get(pcAddOnIdToTaxCodeOverrideIdMap.get(pc.Id)).Tax_Rate__c;
                        }
                    }
                    oliList.add(oli);
                }
            }
        }
        
        
        
        if(selectedOpportunity.Subsidiary__r.Subsidiary_Code__c  == 'iPP' && isEvent == true){
            eventClause = selectedOpportunity.Subsidiary__r.Events_Claus__c ;
        }
         paymentClause = selectedOpportunity.Subsidiary__r.Payment_Clause__c.replace('$$OwnerName$$',selectedOpportunity.Primary_Sales_Order__r.Owner.Name);
        paymentClause = paymentClause.replace('$$OwnerEmail$$',selectedOpportunity.Primary_Sales_Order__r.Owner.Email) ; 
        
        Decimal discount = 0;
        Decimal total = 0;
        Decimal totalGST = 0;
        map < String, List < wrapOli >> offerMap = new Map < String, List < wrapOli >> ();
        map < String, Decimal> offerList = new Map < String,Decimal> ();
        for (wrapOli wo: oliList) {
            if(wo.unitPrice != null){
                wo.unitPrice =  wo.unitPrice.setScale(2,System.RoundingMode.HALF_UP);
            }          
            Decimal tPrice = 0;
            if (wo.UnitPrice == 0) {
                wo.additionalNote = 'Complimentary';
            }
            if (wo.Quantity != null  && wo.UnitPrice != null ) {
                tPrice = wo.Quantity * wo.UnitPrice;
                //tPrice = tPrice.setScale(2,System.RoundingMode.HALF_UP);
                
                wo.TotalPrice = tPrice;
                if(wo.totalPrice !=  null)
                    wo.TotalPrice=wo.TotalPrice.setScale(2,System.RoundingMode.HALF_UP);
                total += tPrice;
            }
            if (wo.DiscountAmount != null && wo.DiscountAmount != 0) {
                tPrice -= wo.DiscountAmount;
                wo.DiscountAmount=wo.DiscountAmount.setScale(2,System.RoundingMode.HALF_UP);
                
                
                discount += wo.DiscountAmount;
                Decimal salesPrice = wo.UnitPrice -wo.DiscountAmount;
                if( tPrice == 0){
                    wo.additionalNote = 'Complimentary';
                }
                tPrice = tPrice.setScale(2,System.RoundingMode.HALF_UP);
            }
            if (tPrice != 0 && wo.GSTVATRate != null && wo.GSTVATRate != 0) {
                system.debug('GST '+wo.GSTVATRate * tPrice / 100);
                decimal gst =(wo.GSTVATRate * tPrice / 100);
                totalGST = totalGST + gst.setScale(2,System.RoundingMode.HALF_UP);
            }
            if (wo.Offer == null) {
                allOLI.add(wo);
            } else {
                wrapOli bundleOli = new wrapOli();
                bundleOli.name = wo.offerName;
                bundleOli.offerId = wo.offer;
                bundleOli.Linedescription2 = wo.offerDescription2;
                if (!offerMap.containsKey(wo.offer)) {
                    decimal price =wo.unitprice ;
                    /*if( wo.DiscountAmount != null){
price -=  wo.DiscountAmount;
}*/
                    offerList.put(wo.offer,price);
                    list < wrapOli > wrapOliList = new list < wrapOli > ();
                    wrapOliList.add(bundleOli);
                    wrapOlilist.add(wo);
                    offerMap.put(wo.offer, wrapOlilist);
                } else {
                    list < wrapOli > wrapOliList = offerMap.get(wo.offer);
                    //wrapOliList.add(bundleOli);
                    wrapOlilist.add(wo);                    
                    decimal price = offerList.get(wo.offer);
                    /*   if( wo.DiscountAmount != null){
price += wo.TotalPrice -  wo.DiscountAmount  ;
}*/
                    offerList.put(wo.offer, price + wo.unitprice);
                    offerMap.put(wo.offer, wrapOlilist);
                }
            }
            system.debug('offermap'+ offerMap);
            system.debug('name' + wo.name);
            system.debug('gst rate' + wo.GSTVATRate);
            tPrice = tPrice.setScale(2,System.RoundingMode.HALF_UP);
            system.debug('tPrice' + tprice);
            
        }
        
        for (String s: offerMap.keySet()) {
            for (wrapOli wo: offerMap.get(s)) {
                if(offerList.containsKey(wo.offerId) && wo.name != null ){
                    wo.Name = wo.Name + ' - '+ selectedOpportunity.currencyisocode +' '+offerList.get(wo.OfferId).setScale(2).format();
                }
                system.debug('************'+wo);
                allOLI.add(wo);
            } 
        }
        TotalDiscount = discount;
        TotalAmount = total;
        totalGSTValue = totalGST;
        OppTotal = TotalAmount + totalGSTValue;
        if(totalDiscount!=null)
            OppTotal -=totalDiscount ;
        system.debug('TotalDiscount'+TotalDiscount);
        system.debug('TotalAmount'+TotalAmount);
        system.debug('totalGSTValue'+totalGSTValue);
        system.debug('OppTotal'+OppTotal);
        for (OpportunityContactRole ocr: selectedOpportunity.OpportunityContactRoles) {
            if (ocr.Role == 'Billing Contact') {
                if (ocr.isPrimary) {
                    primaryBillingOCR = ocr;
                }
                BillingOCRList.add(ocr);
                
            } else if (ocr.Role == 'Client Signatory') {
                clientSignOCRList.add(ocr);
            }
            
        }
        integer ownerCount = 0;
        wrapSignList = new List < wrapSign > ();
        list < wrapSign > tempList = new List < wrapSign > ();
        system.debug('clientSignOCRList ' + clientSignOCRList);
        for (OpportunityCOntactRole ocr: clientSignOCRList) {
            wrapSign ws = new wrapSign();
            ws.signOCR = ocr;
            tempList.add(ws);
            wrapSignList.add(ws);
        }
        system.debug('before spname ' + wrapSignList);
        system.debug('country ' + countryManagerList);
        for (String s: countryManagerList) {
            wrapSign ws = new wrapSign();
            if (ownerCount < tempList.size()) {
                
                
                ws = tempList[ownerCount];
                system.debug('sign ocr ' + ws.signOcr);
                ws.spName = s;
                //wrapSignList.remove(ownerCount);
            } else {
                
                ws.spName = s;
                system.debug('ws.spName ' + ws);
                wrapSignList.add(ws);
            }
            system.debug(wrapsignList);
            system.debug('ownerCount++; ' + ownerCount);
            ownerCount++;
        }
        //system.debug(clientSignOCRList);
        //system.debug(countryManagerList);
        system.debug('wrapSignList ' + wrapSignList);
        
    }
 /*   public void generateContract(String oppID) {
        updateOppRePrintFalse();
        allOLI = new List < wrapOLI > ();
        //List<wrapOLI>
        oliList = new List < wrapOLI > ();
        //  QLiSortedList = new List<QuoteLineItem>();
        //   unprocessedqliList = new List<QuoteLineItem>();
        MapQliIdAggrAmount = new Map < Id, Decimal > ();
        //  BundledList = new List<QuoteLineItem>();
        primaryBillingOCR = new OpportunityContactRole();
        clientSignOCRList = new list < OpportunityContactRole > ();
        wrapSignList = new List < wrapSign > ();
        BillingOCRList = new list < OpportunityContactRole > ();
        
        String AWARDS = 'Awards';
        String FASTKEY = 'FastKey';
        String EVENTS = 'Events';
        String CNS = 'China Solutions';
        String MAAS = 'Marketing Services';
        String DBSM = 'Database Marketing';
        String DEV_LISTINGS = 'Developer Listings';
        String STANDARD = 'Standard Products';
        String AD_SERVED_UNIT_PRICE_ATTR = 'Net Rate';
        String MPD_SUBS = 'MPD Subscriptions';
        String MPD_SOLS = 'MPD Custom Solutions';
        String MPD_Per= 'MPD Pay per use';
        String MPD_Offline = 'MPD Third-party Solution (Offline)';
        
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
        Set<String> commIds = new Set<String>();
        Set<String> rateIds = new Set<String>();
        Set<Id> addOnPriceItemIds = new Set<Id>();
        Set<Id> lineItemId = new Set<Id>();
        Map<Id, cspmb__Price_Item__c> commProdGstId = new Map<Id, cspmb__Price_Item__c>();
        Map<Id, cspmb__Add_On_Price_Item__c> idToAddOnPriceItemMap = new Map<Id, cspmb__Add_On_Price_Item__c>();
        Map<String, csmso__Rate_Card_Item_Price__c> rateGstId = new Map<String,csmso__Rate_Card_Item_Price__c>();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeAdServedMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityAdServed = new List<String>{'Insertion Quantity', 'Insertion Unit Type Display', 'Multiplier to Minimum Contract Quantity Days'};
            Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeDatabaseMarketingMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeDeveloperListMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeStandardProductsMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityDatabaseMarketing = new List<String>{'Insertion Quantity'};
            List<String> attributeNamesQuantityDeveloperListing = new List<String>{'Insertion Quantity'};
                List<String> attributeNamesQuantityStandardProducts = new List<String>{'Insertion Quantity'};
                    Map<Id, Id> pcIdToTaxCodeOverrideIdMap = new Map<Id, Id>();
        Map<Id, Id> pcAddOnIdToTaxCodeOverrideIdMap = new Map<Id, Id>();
        Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeMPDOnlineMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityMPDOnline = new List<String>{'Insertion Quantity', 'Insertion Unit Type Display', 'Multiplier to Minimum Contract Quantity Days'};
            Map<Id, Map<String, cscfga__Attribute__c>> pcIdToAttributeAwardsWebsiteMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        List<String> attributeNamesQuantityAwardsWebsite = new List<String>{'Insertion Quantity', 'Insertion Unit Type Display', 'Multiplier to Minimum Contract Quantity Days'};
            
            cscfga__Product_Basket__c basket = [
                SELECT Id, csmso__Sales_Order__c, (SELECT Id, Name,Aggregated_Status__c, cscfga__Description__c, cscfga__Product_Family__c FROM cscfga__Product_Configurations__r)
                FROM cscfga__Product_Basket__c
                WHERE csmso__Sales_Order__c =: selectedOpportunity.Primary_Sales_Order__c
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
        
        List<cscfga__Product_Configuration__c> pcAttrList = [
            SELECT Id, Name, cscfga__Quantity__c, Start_Date__c, Additional_Comments__c,District__c ,Insertion_Quantity__c,
            End_Date__c, cscfga__Product_Family__c, Flight_Begin__c, Flight_End__c,cscfga__package_guid__c,
            cscfga__Parent_Configuration__c, cscfga__originating_offer__c, cscfga__originating_offer__r.Disallow_Detailed_S_O_Print_Out__c, cscfga__originating_offer__r.cscfga__Description__c,  cscfga__originating_offer__r.name, cscfga__Description__c, (
                SELECT Id, Name, cscfga__Price__c, cscfga__List_Price__c,
                cscfga__Value__c, cscfga__Is_Line_Item__c, cscfga__Line_Item_Description__c
                FROM
                cscfga__Attributes__r
            )
            FROM cscfga__Product_Configuration__c
            WHERE
            Id IN:pcId AND cscfga__Parent_Configuration__c = NULL
        ];
        System.debug('pcAttrList size===' + pcAttrList.size());
        System.debug('pcAttrList===' + pcAttrList);
        
        List<cscfga__Product_Configuration__c> AddonPc = [
            SELECT Id, Name, cscfga__Quantity__c, Start_Date__c, Additional_Comments__c,Insertion_Quantity__c,
            End_Date__c, cscfga__Product_Family__c, Flight_Begin__c, Flight_End__c,cscfga__package_guid__c,
            cscfga__Parent_Configuration__c,
            cscfga__Parent_Configuration__r.Name, cscfga__originating_offer__c, cscfga__originating_offer__r.Disallow_Detailed_S_O_Print_Out__c,
            cscfga__originating_offer__r.name, cscfga__Description__c, (
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
        Map<Id,Map<String,cscfga__Attribute__c>> AddonPCIdToAttributesByNameMap = new Map<Id, Map<String, cscfga__Attribute__c>>();
        
        for (cscfga__Product_Configuration__c pc : pcAttrList) {
            
            
            if (pc.cscfga__Product_Family__c == 'Ad Served'
                || pc.cscfga__Product_Family__c == 'Database Marketing'
                || pc.cscfga__Product_Family__c == 'MPD Third-party Solution (Online)'
                || pc.cscfga__Product_Family__c == 'Awards (website)'
                || pc.cscfga__Product_Family__c == 'Developer Listings') {
                    //AAJSON
                    pcIdToAttributesByNameMap.put(pc.Id, new Map<String,cscfga__Attribute__c>());
                    Attachment att = [SELECT ID,Body FROM Attachment WHERE ParentId =:pc.Id AND NAME = 'Attributes as JSON' ORDER BY CreatedDate desc limit 1];
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
                    if (att.cscfga__Value__c Instanceof ID) {
                        lineItemId.add(att.cscfga__Value__c);
                    }
                    lineItemPrice.put(pc.cscfga__Description__c, att);
                }
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
                
                else if (pc.cscfga__Product_Family__c == DBSM &&
                         attributeNamesQuantityDatabaseMarketing.contains(att.Name)) {
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
                             attrDescriptionToPcMap.put(att.cscfga__Line_Item_Description__c, pc);
                             lineItemPrice.put(att.cscfga__Line_Item_Description__c, att);
                             
                             //Custom API DEvelopment is not a commercial product but need to add all the others
                             if (att.cscfga__Value__c != 'Yes') {
                                 commIds.add(att.cscfga__Value__c);
                             }
                         }
            }
        }
        //Ad Served and Rate Card Item Prices
        List<Id> naaIDs = new List<Id>();
        for (Id configId: pcIdToAttributesByNameMap.keySet()) {
            if (pcIdToAttributesByNameMap.containsKey(configId) && pcIdToAttributesByNameMap.get(configId).get('Rate Card') != null)
                rateIds.add(pcIdToAttributesByNameMap.get(configId).get('Rate Card').cscfga__Value__c);
            if (pcIdToAttributesByNameMap.containsKey(configId) && pcIdToAttributesByNameMap.get(configId).get('Node Advert Assignments') != null)
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
                    if (att.cscfga__Value__c Instanceof ID) {
                        lineItemId.add(att.cscfga__Value__c);
                    }
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
            SELECT Id, Tax_Code__c, Tax_Code__r.Tax_Rate__c, Income_Account__c,
            Product_Category__c, cspmb__Price_Item_Description__c, Line_Description__c
            FROM cspmb__Price_Item__c
            WHERE Id IN: commIds
        ]) {
            commProdGstId.put(commProdList.Id, commProdList);
        }
        for (cspmb__Add_On_Price_Item__c addOnPriceItem : [
            SELECT Id, Tax_Code__c, Tax_Code__r.Tax_Rate__c,cspmb__Add_On_Price_Item_Description__c, Income_Account__c, Product_Category__c
            FROM cspmb__Add_On_Price_Item__c
            WHERE Id IN :addOnPriceItemIds
        ]) {
            idToAddOnPriceItemMap.put(addOnPriceItem.Id, addOnPriceItem);
        }
        for (csmso__Rate_Card_Item_Price__c ratePrice : [
            SELECT Id, Tax_Code__c, Tax_Code__r.Tax_Rate__c,
            Income_Account__c, csmso__Rate_Card__c, Product_Category__c,
            csmso__Advert_Assignment__c, csmso__Advert_Assignment__r.Product_Info__c
            FROM csmso__Rate_Card_Item_Price__c
            WHERE
            csmso__Rate_Card__c IN:rateIds
            AND
            csmso__Advert_Assignment__c IN:naaIDs
        ]) {
            //RCIPs are a combination of ratecard and NAAA , ergo using joint key
            rateGstId.put(String.valueOf(ratePrice.csmso__Rate_Card__c) + String.valueOf(ratePrice.csmso__Advert_Assignment__c), ratePrice);
        }
        Map<Id, Tax_Code__c> taxCodeOverridesMap = new Map<Id, Tax_Code__c> ([
            SELECT Id,
            Tax_Rate__c
            FROM Tax_Code__c
            WHERE Id IN: pcIdToTaxCodeOverrideIdMap.values()
        ]);
        Map<Id, Tax_Code__c> taxCodeOverridesAddOnMap = new Map<Id, Tax_Code__c>([
            SELECT  Id,
            Tax_Rate__c
            FROM Tax_Code__c
            WHERE Id IN :pcAddOnIdToTaxCodeOverrideIdMap.values()
        ]);
        Set<String> commProductFamilies = new Set<String> {
            EVENTS,
                AWARDS,
                CNS,
                MAAS,
                STANDARD,
                MPD_SUBS,
                MPD_SOLS,
                MPD_Offline,
                MPD_Per 
                };
                    
                    for (cscfga__Product_Configuration__c pc: pcAttrList) {
                        
                        for (cscfga__Attribute__c attr: pc.cscfga__Attributes__r) {
                            if (attr.cscfga__Is_Line_Item__c) {
                                wrapOLI oli = new wrapOLI();
                                if (attr.name == 'Description') {
                                    oli.LineDescription2 = attr.cscfga__Value__c;
                                } 
                                if(pc.cscfga__Product_Family__c == 'Developer Listings'){
                                    oli.Name = pc.cscfga__Description__c;
                                    if(pc.District__c != null){
                                        oli.Name +=' '+ pc.District__c; 
                                    }
                                }
                                else if (pc.cscfga__Product_Family__c == 'FastKey') {
                                    oli.Name = attr.cscfga__Line_Item_Description__c;
                                } else {
                                    oli.Name = pc.cscfga__Description__c;
                                }
                                oli.additionalNote = pc.Additional_Comments__c;
                                if (pc.cscfga__Product_Family__c == 'Ad Served' && pcIdToAttributeAdServedMap.get(pc.Id) != null) {
                                    if (pcIdToAttributeAdServedMap.get(pc.Id).get('Insertion Quantity') != null && pcIdToAttributeAdServedMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c != null)
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
                                else if((pc.cscfga__Product_Family__c == STANDARD || pc.cscfga__Product_Family__c == MAAS  || pc.cscfga__Product_Family__c == EVENTS || pc.cscfga__Product_Family__c == MPD_Offline|| pc.cscfga__Product_Family__c == FASTKEY || pc.cscfga__Product_Family__c == AWARDS || pc.cscfga__Product_Family__c == CNS || pc.cscfga__Product_Family__c == MPD_SUBS || pc.cscfga__Product_Family__c == MPD_SOLS) && pcIdToAttributeStandardProductsMap.get(pc.Id) != null) {
                                    oli.Quantity = Decimal.valueOf(pcIdToAttributeStandardProductsMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c);
                                }
                                else if(pc.cscfga__Product_Family__c == DEV_LISTINGS && pcIdToAttributeDeveloperListMap.get(pc.Id) != null) {
                                    oli.Quantity = Decimal.valueOf(pcIdToAttributeDeveloperListMap.get(pc.Id).get('Insertion Quantity').cscfga__Value__c);
                                }  else if(pc.cscfga__Product_Family__c == 'MPD Pay per use') {
                                    oli.Quantity = pc.Insertion_Quantity__c;
                                }
                                else {
                                    oli.Quantity = pc.cscfga__Quantity__c;
                                }
                                oli.Offer = pc.cscfga__originating_offer__c + pc.cscfga__package_guid__c;
                                if (oli.Offer != null)
                                    oli.offerName = pc.cscfga__originating_offer__r.Name;
                                if (pc.cscfga__Product_Family__c != 'Ad Served'  && pc.cscfga__Product_Family__c != 'Awards (website)'  && pc.cscfga__Product_Family__c != 'MPD Third-party Solution (Online)') {
                                    if((pc.cscfga__Product_Family__c == 'Events' || pc.cscfga__Product_Family__c == 'MPD Subscriptions') && attr.cscfga__List_Price__c == 0){
                                        oli.unitPrice= attr.cscfga__Price__c;
                                        
                                    }else{
                                        oli.UnitPrice = attr.cscfga__List_Price__c;
                                        if (attr.cscfga__Price__c != attr.cscfga__List_Price__c) {
                                            if(attr.cscfga__List_Price__c!=null &&  attr.cscfga__Price__c!=null)
                                                oli.DiscountAmount = (attr.cscfga__List_Price__c - attr.cscfga__Price__c) * oli.Quantity;
                                        }
                                    }
                                } else {
                                    if (pcIdToAttributesByNameMap != null && pcIdToAttributesByNameMap.containsKey(pc.id)) {
                                        //discount is set as negativ in Ad Served
                                        if (pcIdToAttributesByNameMap.get(pc.Id).get(AD_SERVED_UNIT_PRICE_ATTR ) != null) {
                                            oli.UnitPrice = Decimal.valueOf(pcIdToAttributesByNameMap.get(pc.Id).get(AD_SERVED_UNIT_PRICE_ATTR ).cscfga__Value__c);
                                            if (pcIdToAttributesByNameMap.get(pc.Id).get('Net Rate Adjustment Flat') != null) {
                                                Decimal adServedDiscount = Decimal.valueOf(pcIdToAttributesByNameMap.get(pc.Id).get('Net Rate Adjustment Flat').cscfga__Value__c);
                                                if (adServedDiscount<0) {
                                                    oli.DiscountAmount = adServedDiscount * -1;
                                                    oli.DiscountAmount = oli.DiscountAmount * oli.Quantity;
                                                }
                                            }
                                        }
                                    }
                                }
                                system.debug('unitprice==>' +oli.unitprice);
                                if(oli.UnitPrice == null){
                                    oli.UnitPrice = 0;
                                }
                                
                                oli.StartDate = pc.Flight_Begin__c;
                                oli.EndDate = pc.Flight_End__c;
                                
                                
                                // Fastkey has multiple line item products
                                if (pc.cscfga__Product_Family__c == 'FastKey' && attr.cscfga__Value__c != 'Yes') {
                                    oli.CommProd = attr.cscfga__Value__c;
                                }
                                
                                
                                
                                if (attr.Name == 'CommercialProduct') {
                                    //other non-GAM line items
                                    if (commProductFamilies.contains(pc.cscfga__Product_Family__c)) {
                                        oli.CommProd = attr.cscfga__Value__c;
                                        
                                    }
                                }
                                
                                if (oli.CommProd != null && commProdGstId.containsKey(oli.CommProd)) {
                                    cspmb__Price_Item__c price = commProdGstId.get(oli.CommProd);
                                    if (price.Tax_Code__r.Tax_Rate__c != null)
                                        oli.GSTVATRate = price.Tax_Code__r.Tax_Rate__c;
                                    if (price.Line_Description__c != null) {
                                        oli.LineDescription2 = String.valueOf(price.Line_Description__c).abbreviate(4000);
                                    }
                                }
                                
                                
                                if (pc.cscfga__Product_Family__c == 'Ad Served'
                                    || pc.cscfga__Product_Family__c == 'MPD Third-party Solution (Online)'
                                    || pc.cscfga__Product_Family__c == 'Awards (website)'
                                    || pc.cscfga__Product_Family__c == 'Database Marketing'
                                    || pc.cscfga__Product_Family__c == 'Developer Listings') {
                                        cscfga__Attribute__c rateAttr = pcIdToAttributesByNameMap.get(pc.Id).get('Rate Card');
                                        cscfga__Attribute__c naaAttr = pcIdToAttributesByNameMap.get(pc.Id).get('Node Advert Assignments');
                                        String RC_NAA = '';
                                        if (rateAttr != null) {
                                            RC_NAA = rateAttr.cscfga__Value__c;
                                        }
                                        
                                        if (naaAttr != null) {
                                            RC_NAA = RC_NAA + naaAttr.cscfga__Value__c;
                                        }
                                        
                                        System.debug('RC_NAA =>' + RC_NAA);
                                        if (RC_NAA != null && RC_NAA != '') {
                                            if (rateGstId.containsKey(RC_NAA)) {
                                                
                                                csmso__Rate_Card_Item_Price__c ratePrice = rateGstId.get(RC_NAA);
                                                if (ratePrice.Tax_Code__r.Tax_Rate__c != null)
                                                    oli.GSTVATRate = ratePrice.Tax_Code__r.Tax_Rate__c;
                                                
                                                if (ratePrice.csmso__Advert_Assignment__r.Product_Info__c != null) {
                                                    oli.LineDescription2 = String.valueOf(ratePrice.csmso__Advert_Assignment__r.Product_Info__c).abbreviate(4000);
                                                }
                                            }
                                        }
                                    }
                                
                                if(pcIdToTaxCodeOverrideIdMap.containsKey(pc.Id)) {
                                    if (taxCodeOverridesMap.get(pcIdToTaxCodeOverrideIdMap.get(pc.Id)).Tax_Rate__c != null)
                                        oli.GSTVATRate = taxCodeOverridesMap.get(pcIdToTaxCodeOverrideIdMap.get(pc.Id)).Tax_Rate__c;
                                }
                                oli.offerDescription2 = pc.cscfga__originating_offer__r.cscfga__Description__c;
                                oliList.add(oli);
                            }
                        }
                    }
        for (cscfga__Product_Configuration__c pc: AddonPc) {
            for (cscfga__Attribute__c attr: pc.cscfga__Attributes__r) {
                if (attr.cscfga__Is_Line_Item__c) {
                    wrapOLI oli = new wrapOLI();
                    if (pc.cscfga__Product_Family__c == 'FastKey') {
                        oli.Name = attr.cscfga__Line_Item_Description__c;
                    }
                    else {
                        oli.Name = pc.cscfga__Description__c;
                    }
                    oli.Quantity = pc.cscfga__Quantity__c;
                    oli.offer = pc.cscfga__originating_offer__c + pc.cscfga__package_guid__c;
                    if (oli.Offer != null)
                        oli.offerName = pc.cscfga__originating_offer__r.Name;
                    oli.additionalNote = pc.Additional_Comments__c;
                    if(attr.cscfga__List_Price__c==0){
                        oli.UnitPrice =attr.cscfga__Price__c    ;
                        
                    }
                    else{
                        oli.UnitPrice = attr.cscfga__List_Price__c;
                    }
                    //  oli.UnitPrice = attr.cscfga__List_Price__c;
                    if (attr.cscfga__Price__c != attr.cscfga__List_Price__c ) {
                        if(attr.cscfga__List_Price__c!=null &&  attr.cscfga__Price__c!=null && attr.cscfga__List_Price__c!=0)
                            oli.DiscountAmount = attr.cscfga__List_Price__c - attr.cscfga__Price__c;
                    }
                    oli.StartDate = pc.Flight_Begin__c;
                    oli.EndDate = pc.Flight_End__c;
                    if (pc.cscfga__Product_Family__c == 'AddOn Product Definition') {
                        oli.CommProd = addonPCIdToAttributesByNameMap.get(pc.Id).get('CommercialProduct').cscfga__Value__c;
                        cspmb__Add_On_Price_Item__c addOnPriceItem = idToAddOnPriceItemMap.get(addonPCIdToAttributesByNameMap.get(pc.Id).get('AddOnCalculation').cscfga__Value__c);
                        if (addOnPriceItem.cspmb__Add_On_Price_Item_Description__c != null) {
                            oli.LineDescription2 = String.valueOf(addOnPriceItem.cspmb__Add_On_Price_Item_Description__c).abbreviate(4000);
                        }
                        oli.GSTVATRate = addOnPriceItem.Tax_Code__r.Tax_Rate__c;
                        if(pcAddOnIdToTaxCodeOverrideIdMap.containsKey(pc.Id)) {
                            oli.GSTVATRate = taxCodeOverridesAddOnMap.get(pcAddOnIdToTaxCodeOverrideIdMap.get(pc.Id)).Tax_Rate__c;
                        }
                    }
                    oliList.add(oli);
                }
            }
        }
        
        
        
        
        
        Decimal discount = 0;
        Decimal total = 0;
        Decimal totalGST = 0;
        map < String, List < wrapOli >> offerMap = new Map < String, List < wrapOli >> ();
        map < String, Decimal> offerList = new Map < String,Decimal> ();
        for (wrapOli wo: oliList) {
            if(wo.unitPrice != null){
                wo.unitPrice =  wo.unitPrice.setScale(2,System.RoundingMode.HALF_UP);
            }          
            Decimal tPrice = 0;
            if (wo.UnitPrice == 0) {
                wo.additionalNote = 'Complimentary';
            }
            if (wo.Quantity != null  && wo.UnitPrice != null ) {
                tPrice = wo.Quantity * wo.UnitPrice;
                //tPrice = tPrice.setScale(2,System.RoundingMode.HALF_UP);
                
                wo.TotalPrice = tPrice;
                if(wo.totalPrice !=  null)
                    wo.TotalPrice=wo.TotalPrice.setScale(2,System.RoundingMode.HALF_UP);
                total += tPrice;
            }
            if (wo.DiscountAmount != null && wo.DiscountAmount != 0) {
                tPrice -= wo.DiscountAmount;
                wo.DiscountAmount=wo.DiscountAmount.setScale(2,System.RoundingMode.HALF_UP);
                
                
                discount += wo.DiscountAmount;
                Decimal salesPrice = wo.UnitPrice -wo.DiscountAmount;
                if( tPrice == 0){
                    wo.additionalNote = 'Complimentary';
                }
                tPrice = tPrice.setScale(2,System.RoundingMode.HALF_UP);
            }
            if (tPrice != 0 && wo.GSTVATRate != null && wo.GSTVATRate != 0) {
                system.debug('GST '+wo.GSTVATRate * tPrice / 100);
                decimal gst =(wo.GSTVATRate * tPrice / 100);
                totalGST = totalGST + gst.setScale(2,System.RoundingMode.HALF_UP);
            }
            if (wo.Offer == null) {
                allOLI.add(wo);
            } else {
                wrapOli bundleOli = new wrapOli();
                bundleOli.name = wo.offerName;
                bundleOli.offerId = wo.offer;
                bundleOli.Linedescription2 = wo.offerDescription2;
                if (!offerMap.containsKey(wo.offer)) {
                    decimal price =wo.unitprice ;

                    offerList.put(wo.offer,price);
                    list < wrapOli > wrapOliList = new list < wrapOli > ();
                    wrapOliList.add(bundleOli);
                    wrapOlilist.add(wo);
                    offerMap.put(wo.offer, wrapOlilist);
                } else {
                    list < wrapOli > wrapOliList = offerMap.get(wo.offer);
                    //wrapOliList.add(bundleOli);
                    wrapOlilist.add(wo);                    
                    decimal price = offerList.get(wo.offer);
                  
                    offerList.put(wo.offer, price + wo.unitprice);
                    offerMap.put(wo.offer, wrapOlilist);
                }
            }
            system.debug('offermap'+ offerMap);
            system.debug('name' + wo.name);
            system.debug('gst rate' + wo.GSTVATRate);
            tPrice = tPrice.setScale(2,System.RoundingMode.HALF_UP);
            system.debug('tPrice' + tprice);
            
        }
        
        for (String s: offerMap.keySet()) {
            for (wrapOli wo: offerMap.get(s)) {
                if(offerList.containsKey(wo.offerId) && wo.name != null ){
                    wo.Name = wo.Name + ' - '+ selectedOpportunity.currencyisocode +' '+offerList.get(wo.OfferId).setScale(2).format();
                }
                system.debug('************'+wo);
                allOLI.add(wo);
            } 
        }
        TotalDiscount = discount;
        TotalAmount = total;
        totalGSTValue = totalGST;
        OppTotal = TotalAmount + totalGSTValue;
        if(totalDiscount!=null)
            OppTotal -=totalDiscount ;
        system.debug('TotalDiscount'+TotalDiscount);
        system.debug('TotalAmount'+TotalAmount);
        system.debug('totalGSTValue'+totalGSTValue);
        system.debug('OppTotal'+OppTotal);
        for (OpportunityContactRole ocr: selectedOpportunity.OpportunityContactRoles) {
            if (ocr.Role == 'Billing Contact') {
                if (ocr.isPrimary) {
                    primaryBillingOCR = ocr;
                }
                BillingOCRList.add(ocr);
                
            } else if (ocr.Role == 'Client Signatory') {
                clientSignOCRList.add(ocr);
            }
            
        }
        integer ownerCount = 0;
        wrapSignList = new List < wrapSign > ();
        list < wrapSign > tempList = new List < wrapSign > ();
        system.debug('clientSignOCRList ' + clientSignOCRList);
        for (OpportunityCOntactRole ocr: clientSignOCRList) {
            wrapSign ws = new wrapSign();
            ws.signOCR = ocr;
            tempList.add(ws);
            wrapSignList.add(ws);
        }
        system.debug('before spname ' + wrapSignList);
        system.debug('country ' + countryManagerList);
        for (String s: countryManagerList) {
            wrapSign ws = new wrapSign();
            if (ownerCount < tempList.size()) {
                
                
                ws = tempList[ownerCount];
                system.debug('sign ocr ' + ws.signOcr);
                ws.spName = s;
                //wrapSignList.remove(ownerCount);
            } else {
                
                ws.spName = s;
                system.debug('ws.spName ' + ws);
                wrapSignList.add(ws);
            }
            system.debug(wrapsignList);
            system.debug('ownerCount++; ' + ownerCount);
            ownerCount++;
        }
        
        system.debug('wrapSignList ' + wrapSignList);
        
    }*/
    public class wrapOLI {
        public String Name {get; set;}
        public String LineDescription2 {get; set;}
        public String offerDescription2 {get; set;}
        public String offer {get; set;}
        public String offerName {get; set;}
        public String additionalNote {get; set;}
        public Date StartDate {get; set;}
        public Date EndDate {get; set;} 
        public Boolean IsBundle {get; set;}
        public Decimal Quantity {get; set;}
        public Decimal TotalPrice {get; set;}
        public Decimal GSTVATRate {get; set;}
        public String Commprod {get; set;}
        public Decimal DiscountAmount {get; set;}
        public Decimal UnitPrice {get; set;}
        public string offerId{get; set;}
    } 
    public class wrapSign {
        public OpportunityContactRole signOCR{get; set;}
        public String spname {get; set;}
    }
    public class aajson  {
        public aajson() {}
        public String productConfigurationId {get; set;}
        public Map<String,cscfga__Attribute__c> attributesByAttrDefId {get; set;}
        public Map<String, cscfga__Attribute_Field__c> attrFieldsByAttrDefId {get; set;}
    }
}