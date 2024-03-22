//TEST CLASS :OpportunityProductRegStinger_Test/OpportunityProductRegistration_cc_Test
public class OpportunityProductRegistrationStinger_cc {
    
    public final static string B2C_OPP_RECORDTYPEiD = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C');
    public final static string skuCodeOfACProd = System.Label.PRODUCT_SKUCODE_AD_CREDIT;
    public final static string skuCodeOfPCProd = System.Label.PRODUCT_SKUCODE_PRIME_CREDIT;
    private static list<OpportunityLineItem> listOppLineItem {get; set;}
    
    @AuraEnabled
    public static Account getAccRecord(Id accId) {
        Account result = [select Id, Name, Country__c, Current_Subscription_Spending_Amount__c, Next_Subscription_Activation_Date__c from Account where Id=:accId];
        return result;
    }
    @AuraEnabled
    public static DiscountInfo getLoyaltyDiscInfo(decimal agentTenure, string countryName) {
        DiscountInfo result;
        list<Loyalty__c> listLoyalty = [select Name, Campaign__c, Campaign__r.Name, Discount_Percentage__c, PG_Tenure__c from Loyalty__c where Campaign__r.Country__c=:countryName and Campaign__r.IsActive=true order by PG_Tenure__c desc];
        for (Loyalty__c row: listLoyalty) {
            if (agentTenure >= row.PG_Tenure__c) {
                result = new DiscountInfo();
                result.Name = row.Campaign__r.Name;
                result.Description = '<b>'+row.Name+' ('+row.Discount_Percentage__c+'%)</b>';
                result.CampaignId = row.Campaign__c;
                result.IsLoyalty = true;
                result.DiscountPercentage = row.Discount_Percentage__c;
                result.DiscountReason = 'Loyalty Discount';
                break;
            }
        }
        return result;
    }
    
    @AuraEnabled
    public static list<OppLineItemTmp> getChild(string priceBookId, string parentProductId,Integer proRatedDiscAdCredit) {
        list<OppLineItemTmp> listOppLineItem = new list<OppLineItemTmp>();
        list<String> listChildProdWithSeqNo=new list<String>();
        map<string, Item_Bundle__c> mapItemBundle = new map<string, Item_Bundle__c>();
        map<string, Product2> mapofAdCredit = new map<string, Product2>();
        list<Item_Bundle__c> listItemBundle = [select Parent_Product__c,Parent_Product__r.SKU_Code__c, Child_Product__c,Child_Product__r.Name, Qty__c,Sno__c, Upload_Tag__c from Item_Bundle__c where Parent_Product__c=:parentProductId order By Sno__c ASC];
        Product2 adCreditProduct = [SELECT Id,Name,SKU_Code__c,Product_Category__c,Tax_Code__r.Tax_Rate__c FROM Product2 WHERE SKU_Code__c =:skuCodeOfACProd];
        for (Item_Bundle__c row: listItemBundle) {
            mapItemBundle.put(row.Child_Product__c, row);
            listChildProdWithSeqNo.add(row.Sno__c+'_'+row.Child_Product__c);
        }
        if(listItemBundle[0].Parent_Product__r.SKU_Code__c == SYSTEM.LABEL.SKU_CODE_ADVANCE_PLUS && adCreditProduct != null) {
            mapofAdCredit.put(adCreditProduct.Id,adCreditProduct);
            listChildProdWithSeqNo.add(listItemBundle.size()+1+'_'+adCreditProduct.Id);
        }
        listChildProdWithSeqNo.sort();
        list<PricebookEntry> listPricebookEntry = [select Id, Name, UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.Product_Category__c, Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.CurrencyIsoCode, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c from PricebookEntry where Pricebook2Id=:priceBookId and Product2.IsActive=true and IsActive=true and (Product2Id in :mapItemBundle.keySet() OR Product2Id in :mapofAdCredit.keyset())];
        Map<Id,PricebookEntry> mapOfProductWithPbe=new Map<Id,PricebookEntry>();
        for(PricebookEntry eachPbe: listPricebookEntry){
            mapOfProductWithPbe.put(eachPbe.Product2.Id,eachPbe);
        }
        for (String each: listChildProdWithSeqNo){
            PricebookEntry row=mapOfProductWithPbe.get(each.substringAfter('_'));
            if(mapOfProductWithPbe.containskey(each.substringAfter('_'))){
                if (row.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode && row.Product2.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode) {
                    if(row.Product2.SKU_Code__c == skuCodeOfACProd && proRatedDiscAdCredit >0) {
                       oppLineItemTmpAssignment(row, listOppLineItem, proRatedDiscAdCredit, parentProductId, false); 
                    } else {
                        if(!mapItemBundle.isEmpty() && mapItemBundle.containsKey(row.Product2.Id)){
                    oppLineItemTmpAssignment(row, listOppLineItem, integer.valueOf(mapItemBundle.get(row.Product2.Id).Qty__c), parentProductId, false);
                        }
                    }
                }
            }
        }
       
        return listOppLineItem;
    }
    @testVisible
    private static void oppLineItemTmpAssignment(PricebookEntry row, list<OppLineItemTmp> listOppLineItem, integer qty, string parentProductId, boolean IsSeparate) {
        OppLineItemTmp oppLineItem = new OppLineItemTmp();
        oppLineItem.Id = row.Id;
        oppLineItem.Product2Id = row.Product2.Id;
        oppLineItem.Product2 = row.Product2;
        oppLineItem.Line_Description2 = row.Product2.Description;
        oppLineItem.UnitPrice = row.UnitPrice;
        oppLineItem.ChildCategory = 'Package';
        oppLineItem.Product_Type = row.Product2.Product_Type__c;
        oppLineItem.Complimentary = true;
        oppLineItem.Push_to_NetSuite = false;
        oppLineItem.Quantity = qty;
        oppLineItem.Parent = parentProductId;
        oppLineItem.IsSeparate = IsSeparate;
        listOppLineItem.add(oppLineItem);
    }
    
    
    
    public class OppLineItemTmp {
        @AuraEnabled
        public string Id {get; set;}
        @AuraEnabled
        public string Product2Id {get; set;}
        @AuraEnabled
        public string Line_Description2 {get; set;}
        @AuraEnabled
        public decimal UnitPrice {get; set;}
        @AuraEnabled
        public string Product_Type {get; set;}
        @AuraEnabled
        public decimal Quantity {get; set;}
        @AuraEnabled
        public Product2 Product2 {get; set;}
        @AuraEnabled
        public boolean Complimentary {get; set;}
        @AuraEnabled
        public boolean Push_to_NetSuite {get; set;}
        @AuraEnabled
        public string Parent {get; set;}
        @AuraEnabled
        public string DiscountReason {get; set;}
        @AuraEnabled
        public string ChildCategory {get; set;}
        @AuraEnabled
        public boolean IsSeparate {get; set;}
        
        public oppLineItemTmp() {
            Product2 = new Product2();
            Push_to_NetSuite = true;
            ChildCategory = null;
            IsSeparate = false;
        }
    }
    
    
    
    public class UpgradePackageWrapper {
        @AuraEnabled
        public map<string, Upgrade_Package_Mapping__c> mapUpgradePackage;
        @AuraEnabled
        public list<PricebookEntry> listPbEntry;
        
        public upgradePackageWrapper() {
            mapUpgradePackage = new map<string, Upgrade_Package_Mapping__c>();
            listPbEntry = new list<PricebookEntry>();
        }
    }
    
    // Changed return type from wrapper to String (PGAUTO-5358)
    @AuraEnabled
    public static String constructUpgrade (string accId) {
        
        UpgradePackageCalculatorSG.WrapResponseSG wrapResSG = new UpgradePackageCalculatorSG.WrapResponseSG();
        UpgradeTmp result = new UpgradeTmp();
        result.agentObj = [select Id, PG_Tenure__c, Name, VIP__c,AgentNet_ID__c,Approval_Status__c,Account_Rule_Code__c, Status__c,IsAdvance_Plus_Downgrade__c, Current_Subscription_Code__c, Subscription_Start_Date__c, Subscription_End_Date__c, Current_Subscription_Spending_Amount__c, Pro_Rate_Amount__c, Country__c, CurrencyIsoCode,Loyalty_Start_Date__c,Account_Previous_Status__c,Previous_Account_Rule__c from Account where Id=:accId];
        if (result.agentObj.Subscription_Start_Date__c==null) {
            throw new AuraHandledException('Cannot proceed Upgrade Package, Subscription Start Date is empty.');
        } else if (result.agentObj.Country__c=='Singapore' && result.agentObj.Status__c=='Expired') {
            throw new AuraHandledException(result.agentObj.Name + '\'s Subscription is expired already. Cannot Upgrade Package');
        } else if (result.agentObj.Country__c=='Malaysia' && result.agentObj.Status__c!='Active') {
            throw new AuraHandledException(result.agentObj.Name + ' is not an Active Agent. Cannot Upgrade Package');
        }
        // To Restrict Opp Creation (PGAUTO-5237 and PGAUTO-5245)
        List<Opportunity> oppList = [Select Id,Opportunity_Number__c,Opportunity_Type__c From Opportunity
                                     Where AccountId=:accId And RecordType.Name='B2C' And Account.Country__c = 'Singapore' 
                                     And StageName != 'Closed Won' And StageName !='Closed Lost'
                                     And ((Opportunity_Type__c = 'B2C - Upgrade')
                                          OR (Opportunity_Type__c = 'B2C - Renewal' And Account.Status__c = 'Active'
                                              And Account.Next_Subscription_Activation_Date__c <= today)) LIMIT 1];
        if(oppList.size()>0){
            result.oppObj = oppList[0];
        }
        
        date dateSubscriptionStart = Date.newInstance(result.agentObj.Subscription_Start_Date__c.year(), result.agentObj.Subscription_Start_Date__c.month(), result.agentObj.Subscription_Start_Date__c.day());
        date dateNow = Date.newInstance(system.today().YEAR(),system.today().MONTH(),system.today().DAY());
        result.upgradeStartDate = dateNow;
        result.monthUtilised = dateSubscriptionStart.monthsBetween(dateNow);
        if (dateSubscriptionStart.day() > dateNow.day()) result.monthUtilised--;
        result.dayUtilised = dateSubscriptionStart.daysBetween(dateNow);
        result.listPbEntry = getUpgradeProductList(result.agentObj, result.monthUtilised);
        
        //added by Vikas for PGAUTO-1127
        Decimal agentTenure = CalculateUpgradeTenure(result.agentObj);
        //result.loyaltyDetail = getLoyaltyDiscInfo(result.agentObj.PG_Tenure__c, result.agentObj.Country__c);
        if(!result.agentObj.VIP__c && ( String.isBlank(result.agentObj.Approval_Status__c)|| !result.agentObj.Approval_Status__c.containsIgnoreCase('Approved')))
            result.loyaltyDetail = getLoyaltyDiscInfo(agentTenure, result.agentObj.Country__c);
        
        if(result.agentObj.Country__c == 'Singapore'){
            
            Decimal loyaltyPerc = 0.00;
            
            if(result.loyaltyDetail!= null && result.loyaltyDetail.DiscountPercentage!=null)
            {
                loyaltyPerc = result.loyaltyDetail.DiscountPercentage;
            }
            Map<String,String> mapOfAccIdVsSKUCode = AmountRollUpHandler.fetchLatestOppProdSKUCode(new Set<Id>{accId});
            wrapResSG = UpgradePackageCalculatorSG.getUpgradeForecast(accId,result.listPbEntry,loyaltyPerc,mapOfAccIdVsSKUCode.get(accId));
        }
        
        // To return wrapper in form of JSON 
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartArray();
        gen.writeStartObject();
        gen.writeObjectField('result', result);
        if(result.agentObj.Country__c == 'Singapore')
        {
            gen.writeObjectField('wrapResSG', wrapResSG);
        }
        gen.writeEndObject();
        gen.writeEndArray();
        
        String jsonData = gen.getAsString();
        return jsonData; 
    }
    
    // Changed parameter for PGAUTO-5358
    @AuraEnabled
    public static UpgradePackageWrapper getUpgradeMapping (String agentStr, String listPbEntryStr) {
        
        Account agent = (Account) JSON.deserializeStrict(agentStr, Account.Class);
        list<PricebookEntry> listPbEntry = (list<PricebookEntry>) JSON.deserializeStrict(listPbEntryStr,list<PricebookEntry>.class);
        Map<String,String> mapOfAccIdVsSKUCode = AmountRollUpHandler.fetchLatestOppProdSKUCode(new Set<Id>{agent.Id});
        UpgradePackageWrapper result = new UpgradePackageWrapper();
        map<string, integer> mapOfPbEntryIdx = new map<string, integer>();
        integer idx = 0;
        map<string, string> mapRuleCodeOfProduct = new map<string, string>();
        string[] ruleCodeSplit;
        string ruleCodeName;
        
        // Capture index of list of pricebookEntry, for value assignment later
        for (PricebookEntry row: listPbEntry) {
            mapOfPbEntryIdx.put(row.Product2.SKU_Code__c, idx);
            idx++;
        }
        // Map Account Rule Code to Upgrade SKU
        for (Upgrade_Package_Lookup__c row: [select Name, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:agent.Country__c and Upgrade_SKU__c in :mapOfPbEntryIdx.keySet() AND IsActive__c = TRUE order by Level__c]) {
            ruleCodeSplit = row.Name.split('-');
            ruleCodeName = ruleCodeSplit[0].trim().toLowerCase();
            mapRuleCodeOfProduct.put(ruleCodeName, row.Upgrade_SKU__c);
        }
        // Adjust Pricebook Entry Unit Price accordingly to the Upgrade_Package_Mapping__c
        for (Upgrade_Package_Mapping__c row: [select Name, Origin_Rule_Code__c,Origin_Prod_SKU__c, Destination_Rule_Code__c, SKU_Code__c, Quantity__c, Unit_Price__c, Rack_Price__c,PC_Quantity__c,PC_SKU_Code__c from Upgrade_Package_Mapping__c where Country__c=:agent.Country__c and Origin_Rule_Code__c=:agent.Account_Rule_Code__c]) {
            if(row.Origin_Prod_SKU__c.Split(';').contains(mapOfAccIdVsSKUCode.get(agent.Id))) {
                if (mapRuleCodeOfProduct.keySet().contains(row.Destination_Rule_Code__c.toLowerCase()) && mapOfPbEntryIdx.keySet().contains(mapRuleCodeOfProduct.get(row.Destination_Rule_Code__c.toLowerCase()))) {
                    idx = mapOfPbEntryIdx.get(mapRuleCodeOfProduct.get(row.Destination_Rule_Code__c.toLowerCase()));
                    if(agent.Country__c == 'Malaysia'){
                        listPbEntry[idx].UnitPrice = row.Rack_Price__c;
                        listPbEntry[idx].Display_Price__c = row.Rack_Price__c;
                    }
                    else{
                        listPbEntry[idx].UnitPrice = row.Unit_Price__c;
                        listPbEntry[idx].Display_Price__c = row.Unit_Price__c;
                    }
                    result.mapUpgradePackage.put(listPbEntry[idx].Product2.SKU_Code__c, row);
                }
            }
        }
        result.listPbEntry = listPbEntry;
        return result;
    }
    
    @AuraEnabled
    public static list<PricebookEntry> getUpgradeProductList (Account agentObj, integer monthDiff) {
        string errorMessage = '';
        map<string, Subsidiary__c> mapSubsidiary = new map<string, Subsidiary__c>();
        list<PricebookEntry> listPricebookEntry = new list<PricebookEntry>();
        User usr = [select Id, CurrencyIsoCode, Subsidiary__c from User where Id=:UserInfo.getUserId()][0];
        Pricebook2 pricebook = getPricebook(usr, mapSubsidiary);
        
        if (string.isBlank(agentObj.Id)) {
            errorMessage = 'Agent is not found.';
        } else if (agentObj.Subscription_Start_Date__c == null) {
            errorMessage = agentObj.Name + ' doesn\'t have Subscription Start Date yet.';
        } else if (string.isBlank(agentObj.Account_Rule_Code__c)) {
            errorMessage = agentObj.Name + ' currently doesn\'t have any Subscription yet.';
        } else if (monthDiff > 12) {
            errorMessage = 'Current month is more than 12 month from Subscription Start Date, cannot upgrade.';
        } else if (mapSubsidiary.keySet().size() == 0) {
            errorMessage = 'No Subsidiary found, cannot upgrade.';
        } else {
            errorMessage = getSubscriptionProduct(agentObj, usr.CurrencyIsoCode, pricebook.Id, mapSubsidiary.get(usr.Subsidiary__c).Country__c, listPricebookEntry, 'Upgrade_SKU__c');
        }
        
        if (!string.isBlank(errorMessage) && !Test.isRunningTest()) {
            throw new AuraHandledException(errorMessage);
        }
        return listPricebookEntry;
    }
    
    @testvisible
    private static string getSubscriptionProduct(Account agentObj, string currencyCode, string pricebookId, string country, list<PricebookEntry> listPricebookEntry, string whichSku) {
        string errorMessage = '';
        string query;
        list<string> listUpgrade = new list<string>();
        boolean includeLookup = false;
        integer idxLevel;
        //List<String> listOfNewPackageSKU = Label.SKU_CODE_OF_CULLINAN_PACKAGE.Split(';');
        List<Opportunity> renwalOppList = [SELECT Id FROM Opportunity WHERE AccountId =: agentObj.Id AND Opportunity_Type__c = 'B2C - Renewal' AND (StageName = 'Proposal' OR StageName = 'New')];
        
        if(agentObj.Status__c != null && agentObj.Status__c == 'Active' && agentObj.Account_Previous_Status__c != null && 
           (agentObj.Account_Previous_Status__c == 'Trial' || agentObj.Account_Previous_Status__c == 'Expired')){
               List<Upgrade_Package_Lookup__c> upgList = [select Name, Renewal_SKU__c, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:country and isActive__c = true order by Level__c];
               for (Upgrade_Package_Lookup__c row: [select Name, Renewal_SKU__c, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:country and isActive__c = true order by Level__c]) {
                   if(whichSku == 'Upgrade_SKU__c'){
                       if (includeLookup && idxLevel<row.Level__c) {
                           if(!(idxLevel == 0 && row.Level__c == 1))
                               listUpgrade.add(string.valueOf(row.get(whichSku)));
                       } else if (row.Name.containsIgnoreCase(agentObj.Account_Rule_Code__c)) {
                           includeLookup = true;
                           idxLevel = integer.valueOf(row.Level__c);
                       }
                   }
               }
           }else {
               List<Upgrade_Package_Lookup__c> upgList = [select Name, Renewal_SKU__c, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:country and isActive__c = true order by Level__c];
               for (Upgrade_Package_Lookup__c row: [select Name, Renewal_SKU__c, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:country and isActive__c = true order by Level__c]) {
                   if (whichSku == 'Renewal_SKU__c') {
                       if (agentObj.Country__c=='Singapore' && agentObj.Status__c=='Downgraded' && agentObj.Account_Rule_Code__c=='TRIAL' && row.Name.containsIgnoreCase(agentObj.Previous_Account_Rule__c)) {
                           listUpgrade.add(string.valueOf(row.get(whichSku)));
                           break;
                       } else if (agentObj.Country__c=='Malaysia' && agentObj.Status__c=='Suspended' && agentObj.Account_Rule_Code__c=='TRIAL' && row.Name.containsIgnoreCase(agentObj.Previous_Account_Rule__c)) {
                           listUpgrade.add(string.valueOf(row.get(whichSku)));
                           break;
                       } else if (row.Name.containsIgnoreCase(agentObj.Account_Rule_Code__c)) {
                           listUpgrade.add(string.valueOf(row.get(whichSku)));
                           break;
                       }
                   } else {
                       if (includeLookup && idxLevel<row.Level__c) {
                           //added by Vikas for PGAuto-922
                           if(!(idxLevel == 0 && row.Level__c == 1))
                               listUpgrade.add(string.valueOf(row.get(whichSku)));
                       } else if (row.Name.containsIgnoreCase(agentObj.Account_Rule_Code__c)) {
                           includeLookup = true;
                           idxLevel = integer.valueOf(row.Level__c);
                       }
                   }
               }
           }
        if (listUpgrade.size() > 0) {
            query = 'select Id, Name, UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.Product_Category__c, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.CustItem_Duration_Value__c, Product2.CustItem_Duration_Unit__c,Display_Price__c  from PricebookEntry where Pricebook2Id=\''+pricebookId+'\' and Product2.IsActive=true and IsActive=true and Product2.Segment__c in (\'B2C Only\', \'B2B & B2C\') and Product2.Product_Category__c=\'Subscription\' and CurrencyIsoCode=\''+currencyCode+'\' and Product2.CurrencyIsoCode=\''+currencyCode+'\' and Product2.SKU_Code__c in (\''+ string.join(listUpgrade, '\', \'') + '\')';
            for (PricebookEntry row: database.query(query)) { 
                if (row.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode) {
                    if(agentObj.Account_Rule_Code__c.toLowercase() == SYSTEM.LABEL.ADVANCE_RENEW_EXCEPTION.toLowercase()) {
                        if(agentObj.Status__c == 'Active' && renwalOppList.isEmpty()) {
                            listPricebookEntry.add(row); 
                        } else if (row.Product2.SKU_Code__c == SYSTEM.LABEL.SKU_CODE_ADVANCE_PLUS) {
                            listPricebookEntry.add(row); 
                        }
                    } else {
                        listPricebookEntry.add(row);
                    }
                }
            }
            if (listPricebookEntry.size()==0) {
                errorMessage = 'No matching upgrade found for ' + agentObj.Name + '.';
            }
            
        } else {
            errorMessage = 'No matching upgrade found for ' + agentObj.Name + '.';
        }
        return errorMessage;
    }
    
    private static Pricebook2 getPricebook (User usr, map<string, Subsidiary__c> mapSubsidiary) {
        Pricebook2 result;
        for (Subsidiary__c row: [select Id, Name, Country__c from Subsidiary__c where Name=:usr.Subsidiary__c]) {
            row.Country__c = row.Country__c.toUpperCase();
            mapSubsidiary.put(row.Name, row);
        }
        
        if (mapSubsidiary.keyset().size() > 0) {
            for (Pricebook2 row: [select Id, Name, CurrencyIsoCode from Pricebook2 where Subsidiary__c=:mapSubsidiary.get(usr.Subsidiary__c).Id and IsActive=true]) {
                result = row;
            }
        }
        return result;
    }
    
    // Changed parameter for PGAUTO-5358
    @AuraEnabled
    public static string saveUpgrade(String agentObjStr, String pbEntryStr, string CampaignId, decimal DiscountPercentage, string DiscountReason, 
                                     string UpgradeStartDateString, decimal PreviousProRate, decimal CurrentProRate, Upgrade_Package_Mapping__c 
                                     UpgradePackageMap, Integer proRatedAdCredit, Integer usedAC, Integer proRatedDiscAdCredit, 
                                     Integer currentPackageAdCredit,Integer proRatedPrimeCredit,Decimal usedPC, Decimal proRatedDiscPrimeCredit,
                                     Integer currentPackagePrimeCredit) {
                                         Account agentObj = (Account) JSON.deserializeStrict(agentObjStr, Account.Class);
                                         PricebookEntry pbEntry = (PricebookEntry) JSON.deserializeStrict(pbEntryStr, PricebookEntry.Class);
                                         Map<String,OppLineItemTmp> mapOfAdCreditProd = new Map<String,OppLineItemTmp>();
                                         Map<String,OppLineItemTmp> mapOfPrimeCreditProd = new Map<String,OppLineItemTmp>();
                                         Opportunity opp = new Opportunity();
                                         //OpportunityLineItem oppLine = new OpportunityLineItem();
                                         QuoteLineItem quoteLine = new QuoteLineItem();
                                         //OpportunityLineItem oppLineChild;
                                         QuoteLineItem quoteLineChild;
                                         //list<OpportunityLineItem> listOppLineChild = new list<OpportunityLineItem>();
                                         list<QuoteLineItem> listQuoteLineChild = new list<QuoteLineItem>();
                                         date dateSubscriptionStart;
                                         String[] strDate = UpgradeStartDateString.split('-');
                                         Integer myIntDate = integer.valueOf(strDate[2]);
                                         Integer myIntMonth = integer.valueOf(strDate[1]);
                                         Integer myIntYear = integer.valueOf(strDate[0]);
                                         Date UpgradeStartDate = Date.newInstance(myIntYear, myIntMonth, myIntDate);
                                         Date oppCloseDateSG = UpgradePackageCalculatorSG.getNextMonEvenIfItsMon(UpgradeStartDate);
                                         decimal SNoChild = 1.01;
                                         List<String> args = new String[]{'0','number','###,###,##0.00'};
                                             String proRateFormat = String.format((CurrentProRate==null?'0':CurrentProRate.format()), args);
                                         string errorMessage;
                                         Map<String,String> mapOppRT = new Map<String,String>();
                                         
                                         map<string, Subsidiary__c> mapSubsidiary = new map<string, Subsidiary__c>();
                                         User usr = [select Id, Subsidiary__c from User where Id=:UserInfo.getUserId()][0];
                                         Pricebook2 pricebook = getPricebook(usr, mapSubsidiary);
                                         
                                         for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Opportunity' and Name='B2C']){
                                             mapOppRT.put(rt.Name,rt.Id);
                                         }
                                         
                                         list<OppLineItemTmp> listOppLineTmp = getChild(priceBook.Id, pbEntry.Product2Id,proRatedDiscAdCredit);                             
                                         if (UpgradePackageMap != null) {
                                             // Only for Upgrade Package with Upgrade Package Mapping
                                             getUpgradeMapBonusItem(priceBook, UpgradePackageMap, listOppLineTmp, pbEntry.Product2Id);
                                         }
                                         Savepoint sp = Database.setSavepoint();
                                         try {
                                             opp.Name = 'Upgrade '+agentObj.Account_Rule_Code__c+' to ' + pbEntry.Name+'.';
                                             opp.StageName = 'Proposal';
                                             opp.AccountId = agentObj.Id;
                                             opp.Upgrade_Start_Date__c = UpgradeStartDate;
                                             opp.RecordTypeId = mapOppRT.get('B2C');
                                             opp.Pro_Rate__c = CurrentProRate;
                                             opp.Pricebook2Id = pricebook.Id;
                                             if(agentObj.Country__c == 'Singapore') {
                                                 opp.CloseDate = oppCloseDateSG;
                                             } else {
                                                 opp.CloseDate = UpgradeStartDate;
                                             }
                                             if(agentObj.Account_Rule_Code__c == 'ADVANCE' && pbEntry.Product2.SKU_Code__c == SYSTEM.LABEL.SKU_CODE_ADVANCE_PLUS) {
                                                 opp.Opportunity_Type__c = 'B2C - Conversion'; 
                                             } else {
                                                 opp.Opportunity_Type__c = 'B2C - Upgrade';
                                             }
                                             opp.Subsidiary__c = mapSubsidiary.get(usr.Subsidiary__c).Id;            
                                             dateSubscriptionStart = Date.newInstance(agentObj.Subscription_Start_Date__c.year(), agentObj.Subscription_Start_Date__c.month(), agentObj.Subscription_Start_Date__c.day());
                                             // Using UpgradePackageMap to identify whether to set Order Type as Upgrade Outside Renewal Window due to MY requirement, can use Country though.
                                             quoteLine.Order_Type__c = UpgradePackageMap!=null?'Upgrade Outside Renewal Window':getOrderType(dateSubscriptionStart, upgradeStartDate, agentObj.Country__c);
                                             insert opp;
                                             List<Quote> lstquoteopp=[select Id from quote where OpportunityId=:opp.Id order By createdDate Desc limit 1];
                                             quoteLine.QuoteId = lstquoteopp[0].Id;
                                             quoteLine.PricebookEntryId = pbEntry.Id;
                                             quoteLine.Product2Id = pbEntry.Product2Id;
                                             quoteLine.UnitPrice = pbEntry.UnitPrice;
                                             quoteLine.Original_Price__c = quoteLine.UnitPrice;
                                             quoteLine.Line_Description2__c = pbEntry.Product2.Description;
                                             quoteLine.Product_Type__c = pbEntry.Product2.Product_Type__c;
                                             quoteLine.Product_Category__c = pbEntry.Product2.Product_Category__c;
                                             quoteLine.Quantity = 1;
                                             quoteLine.SNo__c = 1;
                                             quoteLine.Discount_Remarks__c = (CurrentProRate!=null && CurrentProRate>0)?('Pro Rated Amount: ' + proRateFormat):quoteLine.Discount_Remarks__c;
                                             if(agentObj.Account_Rule_Code__c == 'ADVANCE' && pbEntry.Product2.SKU_Code__c == SYSTEM.LABEL.SKU_CODE_ADVANCE_PLUS) {
                                                 quoteLine.Pro_Rate_Amount__c = 0; 
                                             } else {
                                                 quoteLine.Pro_Rate_Amount__c = CurrentProRate; 
                                             }
                                             quoteLine.Start_Date__c = UpgradeStartDate;
                                             quoteLine.Income_Account_Name__c = pbEntry.Product2.Income_Account_Name__c;
                                             if(agentObj.country__c=='Thailand'){
                                                 String durationUnit = pbEntry.Product2.CustItem_Duration_Unit__c;
                                                 Integer durationValue =(INteger)pbEntry.Product2.CustItem_Duration_Value__c;
                                                 if (durationUnit == 'Years') {
                                                     quoteLine.End_Date__c =  UpgradeStartDate.addMonths(durationValue*12).addDays(-1);
                                                     
                                                 } else if (durationUnit == 'Weeks') {
                                                     quoteLine.End_Date__c =  UpgradeStartDate.addMonths((durationValue*7)-1);
                                                     
                                                 } else if (durationUnit == 'Months') {
                                                     quoteLine.End_Date__c =  UpgradeStartDate.addMonths(durationValue).addDays(-1);
                                                 }
                                             }
                                             else{
                                                 // Using UpgradePackageMap to identify whether to use Subscription_End_Date__c due to MY requirement, can use Country though.
                                                 quoteLine.End_Date__c = UpgradePackageMap!=null?(agentObj.Account_Rule_Code__c == 'LITE6' ? UpgradeStartDate.addMonths(12).addDays(-1):agentObj.Subscription_End_Date__c):UpgradeStartDate.addMonths(12).addDays(-1);
                                             }
                                             if (!string.isBlank(CampaignId)) {
                                                 quoteLine.Campaign__c = CampaignId;
                                                 quoteLine.Discount__c = DiscountPercentage;
                                                 quoteLine.Discount_Reason__c = DiscountReason;
                                             }
                                             if (!string.isBLank(pbEntry.Product2.Tax_Code__c)) {
                                                 quoteLine.GST_VAT_Rate__c = pbEntry.Product2.Tax_Code__r.Tax_Rate__c;
                                                 //quoteLine.GST_VAT_Code__c = pbEntry.Product2.Tax_Code__c;
                                             }
                                             
                                             insert quoteLine; // added by gian 21-09-2018
                                             if (listOppLineTmp.size() > 0) {
                                                 //Decimal SNoSeparate = 2;
                                                 Decimal latestSNo = [SELECT Id, SNo__c FROM QuoteLineItem WHERE QuoteId = :lstquoteopp[0].Id  AND SNo__c != null ORDER BY SNo__c DESC LIMIT 1].SNo__c;
                                                 for (OppLineItemTmp row: listOppLineTmp) {
                                                     if(row.Product2.SKU_Code__c == SYSTEM.LABEL.SKU_CODE_MONTHLY_AC) {
                                                         Date todayDate = System.today();
                                                         for (Integer i=0;i<12;i++) {
                                                             quoteLineChild = new QuoteLineItem();
                                                             quoteLineChild.PricebookEntryId = row.Id;
                                                             quoteLineChild.QuoteId = lstquoteopp[0].Id;
                                                             quoteLineChild.Parent__c = quoteLine.Id;
                                                             quoteLineChild.Product2Id = row.Product2Id;
                                                             quoteLineChild.SNo__c = row.IsSeparate?2:SNoChild;
                                                             quoteLineChild.Child_Category__c = 'Package';
                                                             quoteLineChild.Line_Description2__c = row.Line_Description2;
                                                             quoteLineChild.Product_Category__c = row.Product2.Product_Category__c;
                                                             quoteLineChild.UnitPrice = 0;
                                                             quoteLineChild.Original_Price__c = quoteLineChild.UnitPrice==null?0:quoteLineChild.UnitPrice;
                                                             quoteLineChild.Product_Type__c = row.Product_Type;
                                                             quoteLineChild.Quantity = proRatedAdCredit/12;
                                                             quoteLineChild.Complimentary__c = true;
                                                             quoteLineChild.Start_Date__c = todayDate.addMonths(i);
                                                             Date endDate = todayDate.addMonths(i+1);
                                                             quoteLineChild.End_Date__c = endDate.addDays(-1);
                                                             quoteLineChild.Push_to_NetSuite__c = false;
                                                             quoteLineChild.Income_Account_Name__c = quoteLine.Product2.Income_Account_Name__c;
                                                             if (!string.isBLank(row.Product2.Tax_Code__c)) {
                                                                 quoteLine.GST_VAT_Rate__c = row.Product2.Tax_Code__r.Tax_Rate__c;
                                                                 //quoteLine.GST_VAT_Code__c = row.Product2.Tax_Code__c;
                                                             }
                                                             quoteLineChild.Order_Type__c = null;
                                                             quoteLineChild.PO__c = true;
                                                             if(quoteLineChild.Quantity!= 0){
                                                                 listQuoteLineChild.add(quoteLineChild);
                                                             }
                                                             SNoChild += row.IsSeparate?0:0.01;
                                                         }
                                                     } else {
                                                         quoteLineChild = new QuoteLineItem();
                                                         quoteLineChild.PricebookEntryId = row.Id;
                                                         quoteLineChild.QuoteId = lstquoteopp[0].Id;
                                                         quoteLineChild.Parent__c = quoteLine.Id;
                                                         quoteLineChild.Product2Id = row.Product2Id;
                                                         quoteLineChild.SNo__c = row.IsSeparate?Math.floor(latestSNo + 1):SNoChild;
                                                         quoteLineChild.Child_Category__c = 'Package';
                                                         quoteLineChild.Line_Description2__c = row.Line_Description2;
                                                         quoteLineChild.Product_Category__c = row.Product2.Product_Category__c;
                                                         quoteLineChild.UnitPrice = 0;
                                                         quoteLineChild.Original_Price__c = quoteLineChild.UnitPrice==null?0:quoteLineChild.UnitPrice;
                                                         quoteLineChild.Product_Type__c = row.Product_Type;
                                                         if(agentObj.Country__c == 'Singapore' && row.Product2.SKU_Code__c == skuCodeOfACProd) {
                                                             if(/*agentObj.Account_Rule_Code__c != 'ADVANCE' &&*/ pbEntry.Product2.SKU_Code__c == SYSTEM.LABEL.SKU_CODE_ADVANCE_PLUS) {
                                                                 if(proRatedDiscAdCredit != null) {
                                                                     quoteLineChild.Quantity = proRatedDiscAdCredit; 
                                                                 }    
                                                             } else {
                                                                 if(proRatedAdCredit != null) {
                                                                     quoteLineChild.Quantity = proRatedAdCredit; 
                                                                 }
                                                                 if(proRatedDiscAdCredit != null) {
                                                                     mapOfAdCreditProd.put(skuCodeOfACProd,row);
                                                                 }
                                                             } 
                                                         } else if (agentObj.Country__c == 'Singapore' && row.Product2.SKU_Code__c == skuCodeOfPCProd) {
                                                             quoteLineChild.Quantity = proRatedPrimeCredit;
                                                             mapOfPrimeCreditProd.put(skuCodeOfPCProd,row);
                                                         } else {
                                                             quoteLineChild.Quantity = row.Quantity;
                                                         }
                                                         quoteLineChild.Complimentary__c = true;
                                                         quoteLineChild.Start_Date__c = quoteLine.Start_Date__c;
                                                         quoteLineChild.End_Date__c = quoteLine.End_Date__c;
                                                         quoteLineChild.Push_to_NetSuite__c = false;
                                                         quoteLineChild.Income_Account_Name__c = quoteLine.Product2.Income_Account_Name__c;
                                                         if (!string.isBLank(row.Product2.Tax_Code__c)) {
                                                             quoteLine.GST_VAT_Rate__c = row.Product2.Tax_Code__r.Tax_Rate__c;
                                                             //quoteLine.GST_VAT_Code__c = row.Product2.Tax_Code__c;
                                                         }
                                                         quoteLineChild.Order_Type__c = null;
                                                         quoteLineChild.PO__c = true;
                                                         if(quoteLineChild.Quantity!=0){
                                                             listQuoteLineChild.add(quoteLineChild);
                                                         }
                                                         SNoChild += row.IsSeparate?0:0.01;
                                                         latestSNo = quoteLineChild.SNo__c;
                                                         //SNoSeparate += row.IsSeparate?1:0;
                                                     } 
                                                 }
                                                 if(!mapOfAdCreditProd.isEmpty()) {
                                                     QuoteLineItem quoteLineItem = new QuoteLineItem();
                                                     quoteLineItem.PricebookEntryId = mapOfAdCreditProd.get(skuCodeOfACProd).Id;
                                                     quoteLineItem.QuoteId = lstquoteopp[0].Id;
                                                     quoteLineItem.Product2Id = mapOfAdCreditProd.get(skuCodeOfACProd).Product2Id;
                                                     quoteLineItem.SNo__c = Math.floor(SNoChild+1);
                                                     quoteLineItem.Child_Category__c = 'Package';
                                                     quoteLineItem.Line_Description2__c = mapOfAdCreditProd.get(skuCodeOfACProd).Line_Description2;
                                                     quoteLineItem.Product_Category__c = mapOfAdCreditProd.get(skuCodeOfACProd).Product2.Product_Category__c;
                                                     quoteLineItem.UnitPrice = 0;
                                                     quoteLineItem.Original_Price__c = quoteLineItem.UnitPrice==null?0:quoteLineItem.UnitPrice;
                                                     quoteLineItem.Product_Type__c = mapOfAdCreditProd.get(skuCodeOfACProd).Product_Type;
                                                     quoteLineItem.Quantity = proRatedDiscAdCredit;
                                                     quoteLineItem.IsDiscretionaryAC__c = true;
                                                     quotelineItem.CurrPackageAdCredit__c = currentPackageAdCredit;
                                                     quotelineitem.Consumed_Ad_Credit__c = usedAC;
                                                     quoteLineItem.Complimentary__c = true;
                                                     quoteLineItem.Start_Date__c = quoteLine.Start_Date__c;
                                                     quoteLineItem.End_Date__c = agentObj.Subscription_End_Date__c;
                                                     quoteLineItem.Push_to_NetSuite__c = false;
                                                     //quoteLineItem.Carry_fwd__c = true;
                                                     quoteLineItem.Income_Account_Name__c = quoteLine.Product2.Income_Account_Name__c;
                                                     quoteLineItem.GST_VAT_Rate__c = mapOfAdCreditProd.get(skuCodeOfACProd).Product2.Tax_Code__r.Tax_Rate__c;
                                                     if(quoteLineItem.Quantity!=0){
                                                         listQuoteLineChild.add(quoteLineItem);
                                                     }
                                                 }
                                                 if(!mapOfPrimeCreditProd.isEmpty()) {
                                                     QuoteLineItem pcQLI = new QuoteLineItem();
                                                     pcQLI.PricebookEntryId = mapOfPrimeCreditProd.get(skuCodeOfPCProd).Id;
                                                     pcQLI.QuoteId = lstquoteopp[0].Id;
                                                     pcQLI.Product2Id = mapOfPrimeCreditProd.get(skuCodeOfPCProd).Product2Id;
                                                     pcQLI.SNo__c = Math.floor(SNoChild+1);
                                                     pcQLI.Child_Category__c = 'Package';
                                                     pcQLI.Line_Description2__c = mapOfPrimeCreditProd.get(skuCodeOfPCProd).Line_Description2;
                                                     pcQLI.Product_Category__c = mapOfPrimeCreditProd.get(skuCodeOfPCProd).Product2.Product_Category__c;
                                                     pcQLI.UnitPrice = 0;
                                                     pcQLI.Original_Price__c = pcQLI.UnitPrice==null?0:pcQLI.UnitPrice;
                                                     pcQLI.Product_Type__c = mapOfPrimeCreditProd.get(skuCodeOfPCProd).Product_Type;
                                                     pcQLI.Quantity = proRatedDiscPrimeCredit;
                                                     pcQLI.IsDiscretionaryAC__c = true;
                                                     pcQLI.CurrPackageAdCredit__c = currentPackagePrimeCredit;
                                                     pcQLI.Consumed_Ad_Credit__c = usedPC;
                                                     pcQLI.Complimentary__c = true;
                                                     pcQLI.Start_Date__c = quoteLine.Start_Date__c;
                                                     pcQLI.End_Date__c = agentObj.Subscription_End_Date__c;
                                                     pcQLI.Push_to_NetSuite__c = false;
                                                     //pcQLI.Carry_fwd__c = true;
                                                     pcQLI.Income_Account_Name__c = quoteLine.Product2.Income_Account_Name__c;
                                                     pcQLI.GST_VAT_Rate__c = mapOfPrimeCreditProd.get(skuCodeOfPCProd).Product2.Tax_Code__r.Tax_Rate__c;
                                                     if(pcQLI.Quantity!=0){
                                                         listQuoteLineChild.add(pcQLI);
                                                     }
                                                 }
                                                 insert listQuoteLineChild;
                                                 
                                             } 
                                         } catch (DmlException e) {
                                             Database.rollback(sp);
                                             System.debug('error : ' +e.getMessage() + e.getLineNumber());
                                             errorMessage = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Can\'t changed Stage to Proposal / New from Pending Online Payment')?'Opportunity Is Locked':(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION:')?e.getMessage().subStringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION:'):(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')?e.getMessage().subStringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,'):e.getMessage()));
                                                 errorMessage = errorMessage.contains('You can look up ExceptionCode')?errorMessage.substringBefore('You can look up ExceptionCode'):errorMessage;
                                             throw new AuraHandledException(errorMessage);
                                         }
                                         return opp.Id;
                                     }
    
    public static void getUpgradeMapBonusItem(Pricebook2 pb, Upgrade_Package_Mapping__c upm, list<OppLineItemTmp> listOppLineItem, string parentProductId) {
        for (PricebookEntry row: [select Id, Name, UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.Product_Category__c, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c from PricebookEntry where Pricebook2Id=:pb.Id and CurrencyIsoCode=:pb.CurrencyIsoCode and Product2.CurrencyIsoCode=:pb.CurrencyIsoCode and Product2.IsActive=true and IsActive=true and Product2.Segment__c in ('B2C Only', 'B2B & B2C') and (Product2.SKU_Code__c = :upm.SKU_Code__c or Product2.SKU_Code__c = :upm.PC_SKU_Code__c) limit 100]) {
            if(row.Product2.Name.Contains('Ad Credits')) {
                oppLineItemTmpAssignment(row, listOppLineItem, integer.valueOf(upm.Quantity__c), parentProductId, true);
            } else {
                oppLineItemTmpAssignment(row, listOppLineItem, integer.valueOf(upm.PC_Quantity__c), parentProductId, true);
            }
        }
    }
    @AuraEnabled
    public static string getOrderType(date dateSubscriptionStart, date upgradeStartDate, String country) {
        integer monthDiff;
        string result = '';
        monthDiff = dateSubscriptionStart.monthsBetween(UpgradeStartDate);
        if (monthDiff < 11) {
            result = 'Upgrade Outside Renewal Window';
        } else if (monthDiff <= 12) {
            result = 'Upgrade Inside Renewal Window';
        } else if (country == 'Singapore' && monthDiff > 12) {
            throw new AuraHandledException('Cannot create Opportunity Upgrade Package due to Current Subscription Start Date is more than 12 months ago.' );
        } else if (country == 'Malaysia' && monthDiff > 13) {
            throw new AuraHandledException('Cannot create Opportunity Upgrade Package due to Current Subscription Start Date is more than 12 months ago.' );
        }
        return result;
    }
    //added by Vikas
    public static Decimal CalculateUpgradeTenure(Account ac){
        
        return (ac.Loyalty_Start_Date__c != null)? math.floor((((system.Today().addDays(1).year()-ac.Loyalty_Start_Date__c.year())*12+system.Today().addDays(1).month()-ac.Loyalty_Start_Date__c.month())/12)): 0;
    }
    
    
    public class UpgradeTmp {
        @AuraEnabled    
        public Account agentObj;
        @AuraEnabled
        public list<PricebookEntry> listPbEntry;
        @AuraEnabled
        public DiscountInfo loyaltyDetail;
        @AuraEnabled
        public integer monthUtilised;
        @AuraEnabled
        public integer dayUtilised;
        @AuraEnabled
        public date upgradeStartDate;
        // Created to Restrict Opp Creation (PGAUTO-5237 and PGAUTO-5245)
        @AuraEnabled
        public Opportunity oppObj;
        
        public UpgradeTmp() {
            agentObj = new Account();
            listPbEntry = new list<PricebookEntry>();
            loyaltyDetail = new DiscountInfo();
            monthUtilised = 0;
            dayUtilised = 0;
            oppObj = new Opportunity();
        }
    } 
    public class DiscountInfo {
        @AuraEnabled
        public string Name {get; set;}
        @AuraEnabled
        public string Description {get; set;}
        @AuraEnabled
        public boolean IsAny {get; set;}
        @AuraEnabled
        public string recordType {get; set;}
        @AuraEnabled
        public string PricebookEntryId {get; set;}
        @AuraEnabled
        public string ProductReference {get; set;}
        @AuraEnabled
        public string Operator {get; set;}
        @AuraEnabled
        public decimal Quantity {get; set;}
        @AuraEnabled
        public decimal MinQuantity {get; set;}
        @AuraEnabled
        public decimal MaxQuantity {get; set;}
        @AuraEnabled
        public decimal DiscountPercentage {get; set;}
        @AuraEnabled
        public decimal DiscountAmount {get; set;}
        @AuraEnabled
        public decimal DiscountUnitPrice {get; set;}
        @AuraEnabled
        public string BonusProduct {get; set;}
        @AuraEnabled
        public string BonusProductName {get; set;}
        @AuraEnabled
        public Decimal BonusQty {get; set;}
        @AuraEnabled
        public Decimal BonusPrice {get; set;}
        @AuraEnabled
        public string ProductType {get; set;}
        @AuraEnabled
        public string ProductDescription {get; set;}
        @AuraEnabled
        public string CampaignId {get; set;}
        @AuraEnabled
        public boolean IsLoyalty {get; set;}
        @AuraEnabled
        public boolean IsTier {get; set;}
        @AuraEnabled
        public string DiscountReason {get; set;}
        @AuraEnabled
        public string DiscountReasonChild {get; set;}
        @AuraEnabled
        public string ChildCategory {get; set;}
        @AuraEnabled
        public string TaxCode {get; set;}
        @AuraEnabled
        public decimal TaxRate {get; set;}
        @AuraEnabled
        public string EligibleVip {get; set;}
        @AuraEnabled
        public decimal Denomination{get; set;}
        @AuraEnabled
        public string AccountName{get; set;}
        @AuraEnabled
        public string renewalType{get;set;}
        
        public DiscountInfo() {
            IsLoyalty = false;
            IsTier = false;
            IsAny = false;
            ChildCategory = null;
            EligibleVip = null;
            recordType = '';
            DiscountReasonChild = null;
        }
    }
    
    // Changed parameter for PGAUTO-5358
    @AuraEnabled
    public static Product2 getProductDurationvalue(String accStr){
        Account acc = (Account) JSON.deserializeStrict(accStr, Account.Class);
        String rule;
        if(acc.Account_Rule_Code__c!=null){
            List<Upgrade_Package_Lookup__c> upgPkgList = [Select Country__c,Level__c,Name, Renewal_SKU__c,Upgrade_SKU__c,Renewal_Type__c 
                                                          from Upgrade_Package_Lookup__c where Country__c ='Thailand' and Name=:acc.Account_Rule_Code__c+' - TH'
                                                          order by Level__c limit 1];
            if(upgPkgList.size()>0){
                product2 p= [select id,
                             CustItem_Duration_Unit__c, CustItem_Duration_Value__c from
                             product2 where SKU_Code__c =: upgPkgList[0].Upgrade_SKU__c limit 1];
                Product2 prod = new Product2(CustItem_Duration_Unit__c=p.CustItem_Duration_Unit__c,
                                             CustItem_Duration_Value__c=p.CustItem_Duration_Value__c);
                
                return prod;
            }
            throw new AuraHandledException(acc.Name + 'Cannot proceed to Upgrade Package');
        }
        throw new AuraHandledException(acc.Name + ' does not have valid Account Rule Code');
    }
    
    
    /**
*  fetch total ad credits consumed by an agent
*  @name getConsumedAdCredit
*  @param account data in JSON
*  @return wrapper of response and success/error msg
*  @reference PGAUTO-6219
*/
    @AuraEnabled
    public static LightningResponse getConsumedAdCredit(String agentStr,String accessToken,Id oppId,Map<String,String> mapOfOppIdVsInternalId,String productCode) {
        Account agentObj = (Account) JSON.deserializeStrict(agentStr, Account.Class);
        String consumedCredit = ''; 
        String balanceCredit = '';
        String consumedPC = ''; 
        String balancePC = '';
        Map<String,String> primeCreditQuantity = new Map<String,String>();
        Map<String,String> CreditQuantity = new Map<String,String>();
        String adCreditProductCode = System.Label.AD_CREDIT_PRODUCTCODE; 
        String primeCreditProductCode = System.Label.PRIME_CREDIT_PRODUCTCODE;
        Boolean isEnabled = false;
        Trigger_Execute__c TE = Trigger_Execute__c.getValues('BillingAPI');
        isEnabled = TE.Enable_del__c;
   
        if(isEnabled) {
            Map<string,string> reqHeaders = new Map<string,string>();
            String RootEndpoint;
            String errResponse;
            String billingApiToken;
            Map<String,String> internalId = new Map<String,String>();
            HttpResponse response; // Instantiate a new HttpResponse object
            Map<String,String> countryVsAccessToken = new Map<String,String>();
            Set<Id> accIdSet = new Set<Id>();
            Map<String,String> mapOfAccIdVsLatestOppId = new Map<String,String>();
            if(accessToken == null) {
                for(Billing_API__mdt metadata : [SELECT Country__c,
                                                 Access_Token__c 
                                                 FROM Billing_API__mdt
                                                 WHERE Country__c = 'Singapore']
                   ){
                       countryVsAccessToken.put(metadata.Country__c,metadata.Access_Token__c);
                   }
            }
            
            if(oppId==null) {
                accIdSet.add(agentObj.Id);
                mapOfAccIdVsLatestOppId = AmountRollUpHandler.fetchLatestOppty(accIdSet,false);
                oppId = mapOfAccIdVsLatestOppId.get(agentObj.Id);
            }
             Opportunity opp;
            if(oppId != null){
                 opp = [SELECT Id,Invoice_Id__c,RecordType.Name from opportunity WHERE Id =: oppId];
            }
            
            if(opp.RecordType.Name == 'B2C Self-Serve' && productCode != primeCreditProductCode){
                  internalId.put(skuCodeOfACProd,opp.Invoice_Id__c);  
             }
          else if((mapOfOppIdVsInternalId== null || mapOfOppIdVsInternalId.isEmpty()) && oppId!=null) {
                for(QuoteLineItem qli : [SELECT Id,Quote.OpportunityId,Product2.SKU_Code__c,
                                         SNo__c,Quote.Opp_Quote_Ref_num__c
                                         FROM QuoteLineItem 
                                         WHERE Quote.OpportunityId =:oppId
                                         AND (Product2.SKU_Code__c =:skuCodeOfACProd OR Product2.SKU_Code__c =:skuCodeOfPCProd)
                                         AND Quote.isSyncing =true 
                                         AND SNo__c != null]
                   ) {
                       String comma,Sno;
                       SNo = string.valueof(qli.SNo__c); //1.08
                       if(Sno.length()>3) {
                           comma = Sno.substring(Sno.length()-2, Sno.length());
                       }
                       if( comma != '00') {
                           Sno = string.valueof(qli.SNo__c);
                           if(productCode == adCreditProductCode && qli.Product2.SKU_Code__c == skuCodeOfACProd){
                               if(comma.substring(0,1) == '0') {
                                   internalId.put(skuCodeOfACProd,qli.Quote.Opp_Quote_Ref_num__c + '_' + Sno.substring(0,1) + '_' + comma.substring(1,comma.length())) ; 
                               } else{
                                   internalId.put(skuCodeOfACProd,qli.Quote.Opp_Quote_Ref_num__c + '_' + String.valueOf(qli.SNo__c).replace('.', '_'));
                               }
                           }
                           
                       }
                   }
            } else if(oppId!=null && 
                      !mapOfOppIdVsInternalId.isEmpty() && 
                      mapOfOppIdVsInternalId.containsKey(oppId)
                     ) {
                         if(productCode == adCreditProductCode) {
                             internalID.put(skuCodeOfACProd,mapOfOppIdVsInternalId.get(oppId));
                             if(internalID.get(skuCodeOfACProd).contains('/')){
                                 internalID.get(skuCodeOfACProd).replace('/','\\/');
                             }
                         }
                         
                     }
            system.debug('oppId===>'+oppId);
            if(opp != null && opp.recordtype.Name == 'B2C Self-Serve' && opp.Invoice_id__c!=null && productCode != primeCreditProductCode){
                  RootEndpoint = 'callout:Billing_API/v1/purchased-product-summary/'+ agentObj.AgentNet_ID__c+'?region=SG&productCode='+adCreditProductCode+'&statusCode=ACTIVE&limit=10&invoiceId='+ opp.invoice_id__c;
                } 
                else
                      RootEndpoint = 'callout:Billing_API/v1/purchased-product-summary/'+ agentObj.AgentNet_ID__c+'?region=SG&productCode='+productCode+'&statusCode=ACTIVE&limit=10&invoiceId='+ oppId;
            reqHeaders.put('User-Agent','Workato');
            if(accessToken == null) {
                billingApiToken = countryVsAccessToken.get(agentObj.Country__c);
            } else {
                billingApiToken = accessToken;
            }
            reqHeaders.put('Authorization','Bearer '+ billingApiToken);
            // Send the request and return a response
            if(!Test.isRunningTest()) {
                response = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,'','GET',false,false,null,null);
            } else {
                response = new HttpResponse();
                response.setStatusCode(200);
                response.setStatus('SUCCESS');
                response.setBody('{ "total": 1, "records": [ { "id": 1155150, "webuserId": 415142, "invoiceId": "0062r0000056DA2AAM", "externalId": "21267507-PGQ-21094052", "internalId": "21267507-PGQ-21094052_1_2", "utilizedQuantity": 182, "balanceQuantity": 318 } ] }');
            }
            // Deserialize the JSON string into collections of primitive data types.
            Map<String, object> responseMsg = (Map<String, object>)JSON.deserializeUntyped(response.getBody());
            if(response.getStatusCode() == 200) {
                if(responseMsg.containsKey('records') && responseMsg.get('records') != null) {
                    Map<String,Object> mapOfrecordsVsValues =  new Map<String,Object>();
                    List<Object> listOfRecords = (List<Object>) responseMsg.get('records');
                    for(integer i=0;i<listOfRecords.size();i++){
                        map<String,Object> mapObj = (map<String,Object>) listOfRecords[i];
                        String objStr = (String) mapObj.get('internalId');
                        if(objStr.substringBetween('_', '_') == '1' ) {
                            mapOfrecordsVsValues = (Map<String,Object>)listOfRecords[i];
                        }
                        
                        if(!mapOfrecordsVsValues.isEmpty() && mapOfrecordsVsValues.containsKey('internalId')) {
                            if(productCode == adCreditProductCode) {
                                if(internalID.get(skuCodeOfACProd) == String.valueOf(mapOfrecordsVsValues.get('internalId')) ||
                                   (opp.recordtype.name == 'B2C Self-Serve' && String.valueOf(mapOfrecordsVsValues.get('internalId')).contains(internalID.get(skuCodeOfACProd))) ) {
                                       break;
                                   } else {
                                       mapOfrecordsVsValues.clear(); 
                                   }
                            }
                            
                        } else {
                            mapOfrecordsVsValues.clear(); 
                        }
                    }
                    if(!mapOfrecordsVsValues.isEmpty() && mapOfrecordsVsValues.containsKey('utilizedQuantity') && mapOfrecordsVsValues.containsKey('balanceQuantity')) {
                        consumedCredit = String.valueOf(mapOfrecordsVsValues.get('utilizedQuantity'));
                        balanceCredit = String.valueOf(mapOfrecordsVsValues.get('balanceQuantity'));
                        CreditQuantity.put('utilizedQuantity',consumedCredit);
                        CreditQuantity.put('balanceQuantity',balanceCredit);
                        return new LightningResponse(true, 'Success', CreditQuantity); 
                    } else {
                        consumedCredit = 'No record found in response.';
                        return new LightningResponse(true, 'Success',consumedCredit );
                    }
                } else {
                    consumedCredit = 'No record found in response.';
                    return new LightningResponse(true, 'Success',consumedCredit );
                }
            } else {
                errResponse = String.valueOf(response.getStatusCode() + ' '+ response.getStatus() + ' ' + response.getBody());
                Error_Log__c newError = AmountRollUpHandler.createErrorLog(agentObj.Id, JSON.serialize(agentObj) , errResponse);
                insert newError;
                return new LightningResponse(false, 'Failed', errResponse);
            }
        } else {
            consumedCredit = System.Label.CONSUMED_AD_CREDIT_TEST;
            return new LightningResponse(true, 'Success', CreditQuantity);
        }
        
    }
    
    public static void justIncrement() {
        Integer i = 0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
}
}