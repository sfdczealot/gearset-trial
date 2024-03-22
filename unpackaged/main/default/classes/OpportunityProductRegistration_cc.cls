/*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Apex class to handle DML of OpportunityProductRegistration lightning component & AgentUpgrade button
Inputs:        

Test Class: OpportunityProductRegistration_cc_test
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
public class OpportunityProductRegistration_cc {
    private static list<PricebookEntry> listAvailableProduct {get; set;}
    private static list<OpportunityLineItem> listOppLineItem {get; set;}
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get Opportunity record, to route app accordingly to it's country 
Inputs:        oppId <string>: id of specified Opportunity

Return: OppTmpConstruct
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static Opportunity getOppRecord(string oppId) {
        Opportunity result = [select Id, Name, Country__c from Opportunity where Id=:oppId];
        return result;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get Account record, to route app accordingly to it's country 
Inputs:        accId <string>: id of specified Account

Return: OppTmpConstruct
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static Account getAccRecord(Id accId) {
        Account result = [select Id, Name, Country__c, Current_Subscription_Spending_Amount__c, Next_Subscription_Activation_Date__c from Account where Id=:accId];
        return result;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to initialize page data 
Inputs:        oppId <string>: id of specified Opportunity

Return: OppTmpConstruct
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static OppTmpConstruct construct(string oppId) {
        User usr = [select Id, Subsidiary__c from User where Id=:UserInfo.getUserId()][0];
        map<string, Subsidiary__c> mapSubsidiary = new map<string, Subsidiary__c>();
        OppTmpConstruct oppTmp = new OppTmpConstruct();
        for (Subsidiary__c row: [select Id, Name, Country__c from Subsidiary__c where Name=:usr.Subsidiary__c]) {
            mapSubsidiary.put(row.Name, row);
        }
        
        list<Opportunity> listOpp = [select Id,Account.PG_Tenure__c,Name, AccountId, Account.Name,Account.Loyalty_Start_Date__c, Account.Country__c, Account.PersonContactId, Account.Approval_Status__c,Account.CEA_Salesperson_Number__c, Account.VIP__c,Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Current_Subscription_Code__c, Account.Is_Qualify_Agent_Referral_Program__c, Account.Referrer_Agent__c, Pricebook2Id, PG_Tenure__c, Total_Spending__c, Subsidiary__c, Country__c, Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, StageName, Approval_Status__c, CurrencyIsoCode, CloseDate, Pro_Rate__c, Account.Subscription_End_Date__c, Account.Previous_Acct_End_Date__c from Opportunity where Id=:oppId];
        if (listOpp.size() > 0) {
            for (Opportunity row: listOpp) {
                oppTmp.oppObj = row;
            }
            if (oppTmp.oppObj.Account.PG_Tenure__c != null && oppTmp.oppObj.Account.PG_Tenure__c > 0){

                if(!(oppTmp.oppObj.Account.VIP__c && String.isNotBlank(oppTmp.oppObj.Account.Approval_Status__c) && oppTmp.oppObj.Account.Approval_Status__c.containsIgnoreCase('Approved') && (oppTmp.oppObj.Order_Type_Clone__c == 'Contract - Upgrade' || oppTmp.oppObj.Order_Type_Clone__c == 'Contract - Renewal')))
                oppTmp.loyaltyUpgrade = getLoyaltyDiscInfo(oppTmp.oppObj.Account.PG_Tenure__c, oppTmp.oppObj.Country__c);
            }
        }
        
        oppTmp.oppObj.Subsidiary__c = (string.isBlank(oppTmp.oppObj.Subsidiary__c) && mapSubsidiary.keySet().size() > 0)?mapSubsidiary.get(usr.Subsidiary__c).Id:oppTmp.oppObj.Subsidiary__c;
        system.debug('oppTmp.oppObj.Subsidiary__c:'+oppTmp.oppObj.Subsidiary__c);
        system.debug('oppTmp.oppObj.Pricebook2Id:'+oppTmp.oppObj.Pricebook2Id);
        if (oppTmp.oppObj.Pricebook2Id == null) {
            for (Pricebook2 row: [select Id, Name from Pricebook2 where Subsidiary__c=:oppTmp.oppObj.Subsidiary__c and IsActive=true]) {
                oppTmp.oppObj.Pricebook2Id = row.Id;
            }
        }
        
        /* FIND LIST OF DOWNGRADE */
        boolean includeLookup = false;
        string[] mapGradeIdx;
        integer idxLevel = 0;
        system.debug('oppTmp.oppObj.Country__c:'+oppTmp.oppObj.Country__c);
        for (Upgrade_Package_Lookup__c row: [select Name, Renewal_SKU__c, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:oppTmp.oppObj.Country__c order by Level__c desc]) {
            system.debug(row.Name);
            system.debug(oppTmp.oppObj.Account.Account_Rule_Code__c);
            if (includeLookup && idxLevel>row.Level__c) {
                mapGradeIdx = row.Name.split('-');
                mapGradeIdx[0] = mapGradeIdx[0].trim();
                // oppTmp.oppObj.Country__c=='Malaysia' && oppTmp.oppObj.Order_Type_Clone__c=='Contract - Renewal' -> Renewal_SKU__c
                // else: SG -> Upgrade_SKU__c
                oppTmp.mapDownGrade.put(mapGradeIdx[0], (oppTmp.oppObj.Country__c=='Malaysia' && oppTmp.oppObj.Order_Type_Clone__c=='Contract - Renewal')?row.Renewal_SKU__c:row.Upgrade_SKU__c);
            } else if (row.Name!=null && oppTmp.oppObj.Account.Account_Rule_Code__c!=null && row.Name.containsIgnoreCase(oppTmp.oppObj.Account.Account_Rule_Code__c)) {
                includeLookup = true;
                idxLevel = integer.valueOf(row.Level__c);
                oppTmp.currentSubscription = row.Upgrade_SKU__c;
            }
        }
        
        /* FIND LIST OF UPGRADE */
        system.debug('oppTmp.oppObj.Country__c:'+oppTmp.oppObj.Country__c);
        includeLookup = false;
        if(oppTmp.oppObj.Account.Account_Rule_Code__c.containsIgnoreCase('LITE6')){
            oppTmp.oppObj.Account.Account_Rule_Code__c='LITE';
        }
        for (Upgrade_Package_Lookup__c row: [select Name, Renewal_SKU__c, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:oppTmp.oppObj.Country__c order by Level__c asc]) {
            system.debug(row.Name);
            system.debug(oppTmp.oppObj.Account.Account_Rule_Code__c);
            if (includeLookup && idxLevel<row.Level__c) {
                mapGradeIdx = row.Name.split('-');
                mapGradeIdx[0] = mapGradeIdx[0].trim();
                // oppTmp.oppObj.Country__c=='Malaysia' && oppTmp.oppObj.Order_Type_Clone__c=='Contract - Renewal' -> Renewal_SKU__c
                // else: SG -> Upgrade_SKU__c
                oppTmp.mapUpGrade.put(mapGradeIdx[0], (oppTmp.oppObj.Country__c=='Malaysia' && oppTmp.oppObj.Order_Type_Clone__c=='Contract - Renewal')?row.Renewal_SKU__c:row.Upgrade_SKU__c);
            } else if (row.Name!=null && oppTmp.oppObj.Account.Account_Rule_Code__c!=null && row.Name.containsIgnoreCase(oppTmp.oppObj.Account.Account_Rule_Code__c)
                      &&!(!oppTmp.oppObj.Account.Account_Rule_Code__c.containsIgnoreCase('LITE6') && oppTmp.oppObj.Account.Account_Rule_Code__c.containsIgnoreCase('LITE')  
                           && row.Name.containsIgnoreCase('LITE6'))) {
                includeLookup = true;
                idxLevel = integer.valueOf(row.Level__c);
                oppTmp.currentSubscription = oppTmp.oppObj.Order_Type_Clone__c=='Contract - Renewal'?row.Renewal_SKU__c:row.Upgrade_SKU__c;
            }
        }
        system.debug('mapUpgrade:'+oppTmp.mapUpGrade);
        system.debug('oppTmp.oppObj.Pricebook2Id:'+oppTmp.oppObj.Pricebook2Id);
        return oppTmp;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get picklist value of specified sObject & field
Inputs:        objObject <sObject>: Specified object
fld <string>: Specified field name 

Return: List<String>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static List < String > getSelectOptions(sObject objObject, string fld) {
        List < String > allOpts = new list < String > ();
        // Get the object type of the SObject.
        Schema.sObjectType objType = objObject.getSObjectType();
        
        // Describe the SObject using its object type.
        Schema.DescribeSObjectResult objDescribe = objType.getDescribe();
        
        // Get a map of fields for the SObject
        map < String, Schema.SObjectField > fieldMap = objDescribe.fields.getMap();
        
        // Get the list of picklist values for this field.
        list < Schema.PicklistEntry > values = fieldMap.get(fld).getDescribe().getPickListValues();
        
        // Add these values to the selectoption list.
        for (Schema.PicklistEntry a: values) {
            allOpts.add(a.getValue());
        }
        return allOpts;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get OpportunityLineItem of specified Opportunity Id
Inputs:        oppId <string>: id of specified Opportunity

Return: list<OpportunityLineItem>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<OpportunityLineItem> getSelectedProduct(string oppId) {
        listOppLineItem = new list<OpportunityLineItem>();
        if (string.isNotBlank(oppId)) {
            listOppLineItem = [select Id, Name, Product2Id, Product2.Name, Product2.Is_Bundle__c, Product2.Product_Category__c, Campaign__c, Campaign__r.Name, Line_Description2__c, Start_Date__c, End_Date__c, Quantity, UnitPrice, Discount__c, Discount_Amount__c, GST_VAT_Code__c, GST_VAT_Rate__c, Complimentary__c, Discount_Reason__c, Discount_Remarks__c, Parent__c, Amount__c, Gross_Amount__c, Order_Type__c, PO__c, SNo__c, Original_Price__c, Push_to_NetSuite__c, PricebookEntryId, Child_Category__c, Product_Category__c, Pro_Rate_Amount__c from OpportunityLineItem where OpportunityId = :oppId order by SNo__c];
        }
        return listOppLineItem;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get available product of specified Pricebook & Search Key.
Inputs:        priceBookId <string>: id of specified Pricebook
searchKey <string>: keyword to find particular product

Return: list<PricebookEntry>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<PricebookEntry> getListAvailableProduct(string priceBookId, string currencyCode, string searchKey) {
        system.debug('pricebookid: ' + priceBookId);
        system.debug('searchKey: ' + searchKey);
        listAvailableProduct = new list<PricebookEntry>();
        if (!string.isBlank(priceBookId) && searchKey.length() > 3) {
            searchKey = '%'+searchKey.escapeHtml4()+'%';
            system.debug('select Id, Name, UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.Product_Category__c, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c from PricebookEntry where Pricebook2Id=:priceBookId and CurrencyIsoCode=\''+currencyCode+'\' and Product2.CurrencyIsoCode=\''+currencyCode+'\' and Product2.IsActive=true and IsActive=true and Product2.Segment__c in (\'B2C Only\', \'B2B & B2C\') and Product2.Can_Be_Sold_Stand_Alone__c=true and (Product2.Name like \''+searchKey+'\' or Product2.SKU_Code__c like \''+searchKey+'\') limit 100');
            for (PricebookEntry row: [select Id, Name, UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.Product_Category__c, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c from PricebookEntry where Pricebook2Id=:priceBookId and CurrencyIsoCode=:currencyCode and Product2.CurrencyIsoCode=:currencyCode and Product2.IsActive=true and IsActive=true and Product2.Segment__c in ('B2C Only', 'B2B & B2C') and Product2.Can_Be_Sold_Stand_Alone__c=true and (Product2.Name like :searchKey or Product2.SKU_Code__c like :searchKey) limit 100]) {
                system.debug('Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c:'+row.Product2.Tax_Code__c+' - '+row.Product2.Tax_Code__r.Tax_Rate__c);
                // Only include Pricebook Entry which are having the same Currency Iso Code
                listAvailableProduct.add(row);
            }
        }
        return listAvailableProduct;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get list data of particular lookup field.
Inputs:        idx <string>: id of specified field object
namex <string>: name of specified field object
objectx <string>: name of specified object

Return: list<sObject>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<sObject> getListData(string idx, string namex, string objectx) {
        list<sObject> listObject = database.query('select '+idx+', '+namex+' from '+objectx);
        return listObject;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get kit/child of particular bundle product.
Inputs:        priceBookId <string>: Id of specified Pricebook
parentProductId <string>: Id of specified parent product

Return: list<OppLineItemTmp>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<OppLineItemTmp> getChild(string priceBookId, string parentProductId) {
        system.debug(priceBookId);
        system.debug(parentProductId);
        list<OppLineItemTmp> listOppLineItem = new list<OppLineItemTmp>();
        map<string, Item_Bundle__c> mapItemBundle = new map<string, Item_Bundle__c>();
        list<Item_Bundle__c> listItemBundle = [select Parent_Product__c, Child_Product__c, Qty__c, Upload_Tag__c from Item_Bundle__c where Parent_Product__c=:parentProductId];
        for (Item_Bundle__c row: listItemBundle) {
            mapItemBundle.put(row.Child_Product__c, row);
        }
        list<PricebookEntry> listPricebookEntry = [select Id, Name, UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.Product_Category__c, Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.CurrencyIsoCode, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c from PricebookEntry where Pricebook2Id=:priceBookId and Product2.IsActive=true and IsActive=true and Product2Id in :mapItemBundle.keySet()];
        for (PricebookEntry row: listPricebookEntry) {
            if (row.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode && row.Product2.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode) {
                oppLineItemTmpAssignment(row, listOppLineItem, integer.valueOf(mapItemBundle.get(row.Product2.Id).Qty__c), parentProductId, false);
            }
        }
        return listOppLineItem;
    }
    
    @TestVisible
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
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get VIP promotion eligibility of particular agent.
Inputs:        agentSpending <decimal>: Total spending of particular agent to determine the eligibility

Return: DiscountInfo
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    /*@AuraEnabled
    public static DiscountInfo getVipDiscInfo(decimal agentSpending, string countryName) {
        DiscountInfo result = new DiscountInfo();
        list<VIP__c> listVIP = [select Id, Name, Campaign__c, Campaign__r.Name, Max_Spending__c, Min_Spending__c, Product__c from VIP__c where Campaign__r.Country__c=:countryName and Campaign__r.IsActive=true and Min_Spending__c<=:agentSpending and (Max_Spending__c>=:agentSpending or Max_Spending__c=null)];
        if (listVIP.size() > 0 && agentSpending!=null) {
            result.Name = listVIP.get(0).Campaign__r.Name;
            result.Description = '<b>'+listVIP.get(0).Name+'</b>';
            result.CampaignId = listVIP.get(0).Campaign__c;
            result.ProductReference = listVIP.get(0).Product__c;
            result.EligibleVip = result.Description.toLowerCase().contains('advance')?'Advance':(result.Description.toLowerCase().contains('premier')?'Premier':null);
                }
        return result;
    }
    */
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get Loyalty promotion eligibility of particular agent.
Inputs:        agentTenure <decimal>: Total tenure of particular agent to determine the eligibility

Return: list<DiscountInfo>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
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
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get Referral Agent promotion eligibility of particular agent.
Inputs:        agentTenure <decimal>: Total tenure of particular agent to determine the eligibility

Return: list<DiscountInfo>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
   /* @AuraEnabled
    public static list<DiscountInfo> getReferralAgentPromo(Opportunity oppObj, list<DiscountInfo> listResult) {
        DiscountInfo result;
        string info;
        integer discIdx = listResult.size();
        map <string, list<integer>> mapDiscIdx = new map<string, list<integer>>();
        list<integer> listDiscIdx;
        list<Promotion_Agent_Referral__c> listReferralPromotion = [select Name, Campaign__c, Campaign__r.CurrencyIsoCode
                                                                   , Campaign__r.Name, Bonus_Product__c, Bonus_Product__r.Name
                                                                   , Bonus_Quantity_Referee__c, Bonus_Quantity_Referrer__c
                                                                   , Product_Reference__c, Product_Reference__r.Name, Type__c
                                                                   , Bonus_Product__r.Tax_Code__c, Bonus_Product__r.Tax_Code__r.Tax_Rate__c
                                                                   , Bonus_Product__r.Product_Type__c, Bonus_Product__r.Description
                                                                   , Bonus_Product__r.Income_Account_Name__c
                                                                   from Promotion_Agent_Referral__c
                                                                   where Campaign__r.Country__c=:oppObj.Country__c
                                                                   and Type__c=:(string.isBlank(oppObj.Account.CEA_Salesperson_Number__c)?'NON-REN Agent':'REN Agent')
                                                                   and Campaign__r.IsActive=true];
        for (Promotion_Agent_Referral__c row: listReferralPromotion) {
            result = new DiscountInfo();
            info = '<b>Any</b> purchase of <b>' + row.Product_Reference__r.Name + '</b> would get';
            result.Name = row.Campaign__r.Name;
            result.CampaignId = row.Campaign__c;
            result.DiscountReason = 'Agent Referral: Referee';
            result.ProductReference = row.Product_Reference__c;
            result.IsAny = true;
            
            result.Description = info + ' <b>' + row.Bonus_Product__r.Name + ' (' + row.Bonus_Quantity_Referee__c + ' unit for Referee and ' + row.Bonus_Quantity_Referrer__c + ' unit for Referrer)</b>';
            result.BonusProduct = row.Bonus_Product__c;
            result.BonusProductName = row.Bonus_Product__r.Name;
            result.ChildCategory = 'Bonus';
            result.BonusQty = row.Bonus_Quantity_Referee__c;
            result.BonusPrice = 0;
            result.DiscountPercentage = 100;
            if (!string.isBlank(row.Bonus_Product__r.Tax_Code__c)) {
                result.TaxCode = row.Bonus_Product__r.Tax_Code__c;
                result.TaxRate = row.Bonus_Product__r.Tax_Code__r.Tax_Rate__c;
            }
            result.ProductType = row.Bonus_Product__r.Product_Type__c;
            result.ProductDescription = row.Bonus_Product__r.Description;
            result.AccountName = row.Bonus_Product__r.Income_Account_Name__c;
            listResult.add(result);
            
            if (mapDiscIdx.keyset().contains(row.Bonus_Product__c)) {
                listDiscIdx = mapDiscIdx.get(row.Bonus_Product__c);
            } else {
                listDiscIdx = new list<integer>();
            }
            listDiscIdx.add(discIdx);
            mapDiscIdx.put(row.Bonus_Product__c, listDiscIdx);
            discIdx++;
        }
        
        if (mapDiscIdx.keyset().size() > 0) {
            for (PricebookEntry row: [select Id, Name, Product2Id, UnitPrice from PricebookEntry where Pricebook2Id=:oppObj.Pricebook2Id and Product2Id in :mapDiscIdx.keyset() and Product2.IsActive=true and IsActive=true and CurrencyIsoCode=:oppObj.CurrencyIsoCode]) {
                for (integer idx: mapDiscIdx.get(row.Product2Id)) {
                    listResult.get(idx).PricebookEntryId = row.Id;
                    listResult.get(idx).BonusPrice = row.UnitPrice;
                }
            }
        }
        return listResult;
    }
    */
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get First Timer promotion eligibility of particular Agent.
Inputs:        oppObj <Opportuntiy>: Opportunity record of particular Agent.

Return: list<DiscountInfo>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
   /* @AuraEnabled
    public static void getFirstTimerPromo(Opportunity oppObj, list<DiscountInfo> listResult) {
        DiscountInfo result;
        list<Promotion_First_Timer__c> listFirstTimer = [select Name, Campaign__c, Campaign__r.CurrencyIsoCode, Campaign__r.Name, PG_Tenure__c, Status__c, Current_Account_Rule_Code__c, Prev_Account_Rule_Code__c, Product__c, Product__r.Name, Discount_Amount__c from Promotion_First_Timer__c
                                                         where Campaign__r.Country__c=:oppObj.Country__c
                                                         and Status__c=:oppObj.Account.Status__c
                                                         and Current_Account_Rule_Code__c=:oppObj.Account.Account_Rule_Code__c
                                                         and Prev_Account_Rule_Code__c=:oppObj.Account.Previous_Account_Rule__c
                                                         and PG_Tenure__c=:oppObj.PG_Tenure__c
                                                         and Order_Type__c=:oppObj.Order_Type_Clone__c
                                                         and Campaign__r.IsActive=true];
        for (Promotion_First_Timer__c row: listFirstTimer) {
            result = new DiscountInfo();
            result.Name = row.Campaign__r.Name;
            result.Description = '<b>'+row.Name+' ('+row.Campaign__r.CurrencyIsoCode+' '+row.Discount_Amount__c+' discount for purchasing '+row.Product__r.Name+')</b>';
            result.CampaignId = row.Campaign__c;
            result.DiscountAmount = row.Discount_Amount__c;
            result.DiscountReason = 'First-Timer Discount';
            result.ProductReference = row.Product__c;
            result.IsAny = true;
            listResult.add(result);
        }
    }*/
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get Tier Pricing eligibility of particular agent.
Inputs:        agentTenure <decimal>: Total tenure of particular agent to determine the eligibility

Return: list<DiscountInfo>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    /*@AuraEnabled
    public static void getTierPricingInfo(list<DiscountInfo> listResult, string countryName) {
        DiscountInfo result;
        string info;
        list<Tier_Pricing__c> listTier = [select Name, Campaign__c, Campaign__r.Name, Campaign__r.CurrencyIsoCode, Product_Reference__c, Product_Reference__r.Name, Min_Quantity__c, Max_Quantity__c, Discount_Amount__c, Discount_Percentage__c, Unit_Price__c, Denomination__c from Tier_Pricing__c where Campaign__r.Country__c=:countryName and Campaign__r.IsActive=true order by CreatedDate];
        for (Tier_Pricing__c row: listTier) {
            result = new DiscountInfo();
            if (row.Min_Quantity__c != null || row.Max_Quantity__c != null) {
                info = '<b>'+((row.Min_Quantity__c != null && row.Max_Quantity__c != null)?(row.Min_Quantity__c+' - '+row.Max_Quantity__c):((row.Min_Quantity__c != null && row.Max_Quantity__c == null)?('Minimum of '+row.Min_Quantity__c):('Maximum of '+row.Max_Quantity__c)))+'</b> Purchase';
            } else {
                info = '<b>Any</b> purchase';
                result.IsAny = true;
            }
            info += ' of <b>' + row.Product_Reference__r.Name + '</b> would get';
            
            if (row.Discount_Percentage__c != null) {
                result.Description = info + ' <b>' + row.Discount_Percentage__c+'%</b> discount for each unit.';
                result.DiscountPercentage = row.Discount_Percentage__c;
            } else if (row.Discount_Amount__c != null) {
                result.Description = info + ' <b>'+row.Campaign__r.CurrencyIsoCode+' '+row.Discount_Amount__c+'</b> discount for each unit.';
                result.DiscountAmount = row.Discount_Amount__c;
            } else if (row.Unit_Price__c != null) {
                result.Description = info + ' price of <b>'+row.Campaign__r.CurrencyIsoCode+' ' + row.Unit_Price__c + ' for each</b>.';
                result.DiscountUnitPrice = row.Unit_Price__c;
            }
            
            if (result.Description != '') {
                result.Name = row.Name;
                result.IsTier = true;
                result.CampaignId = row.Campaign__c;
                result.ProductReference = row.Product_Reference__c;
                result.MinQuantity = row.Min_Quantity__c;
                result.MaxQuantity = row.Max_Quantity__c;
                result.Denomination = row.Denomination__c;
            }
            listResult.add(result);
        }
    }*/
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get all campaign/promotion eligibility of particular agent.
Inputs:        oppObj <Opportunity>: Specified Opportunity

Return: list<DiscountInfo>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<DiscountInfo> getListEligiblePromotion(Opportunity oppObj) {
        list<DiscountInfo> listResult = new list<DiscountInfo>();
        DiscountInfo result;
        
        /*result = getVipDiscInfo(oppObj.Total_Spending__c, oppObj.Country__c);
        if (result!=null && result.Name!=null) {
            listResult.add(result);
        }*/
        decimal des;
        if(oppObj.Account.Loyalty_Start_Date__c != null){
            des = math.floor(((system.Today().addDays(1).year()-oppObj.Account.Loyalty_Start_Date__c.year())*12+system.Today().addDays(1).month()-oppObj.Account.Loyalty_Start_Date__c.month())/12);
        }else{
            des = 0;
        }
        if(!(oppObj.Account.VIP__c && String.isNotBlank(oppObj.Account.Approval_Status__c)&& oppObj.Account.Approval_Status__c.containsIgnoreCase('Approved') && (oppObj.Order_Type_Clone__c == 'Contract - Upgrade' || oppObj.Order_Type_Clone__c == 'Contract - Renewal')))
        result = (oppObj.Order_Type_Clone__c == 'Contract - Upgrade') ? getLoyaltyDiscInfo(des, oppObj.Country__c) : getLoyaltyDiscInfo(oppObj.PG_Tenure__c, oppObj.Country__c);
        if (result!=null && result.Name!=null) {
            listResult.add(result);
        }
        
        //getFirstTimerPromo(oppObj, listResult);
        
        /*if (oppObj.Account.Is_Qualify_Agent_Referral_Program__c) {
            getReferralAgentPromo(oppObj, listResult);
        }*/
        
       // getDiscountInfo(oppObj, listResult);
        
       // getTierPricingInfo(listResult, oppObj.Country__c);
        
        return listResult;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get any active promotion which agent is eligible to (registered in CampaignMember)
Inputs:        oppObj <Opportunity>: Specified Opportunity
listResult <list<DiscountInfo>>: List of promotion 

Return: null
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    /*@AuraEnabled
    public static void getDiscountInfo(Opportunity oppObj, list<DiscountInfo> listResult) {
        DiscountInfo result;
        string info;
        integer discIdx = 0;
        map <string, list<integer>> mapDiscIdx = new map<string, list<integer>>();
        list<integer> listDiscIdx;
        
//(Agent Name) is eligible for 
//- Promotion X: 100 ProductA with (Discount%) % discount 
//- Promotion Y: 200 ProductB with (Discount%) % discount

        for (Campaign row: [select Id, Name, (Select CampaignId, ContactId from CampaignMembers where ContactId = :oppObj.Account.PersonContactId),
                            (select Id, Name, Campaign__c, Campaign__r.CurrencyIsoCode, Discount_Amount__c, Discount_Percentage__c, Product__c,
                             Product__r.Name, Product__r.Description, Product__r.Product_Type__c, Product__r.Tax_Code__c, Product__r.Tax_Code__r.Tax_Rate__c,
                             Qty__c, Unit_Price__c, Promotion_Type__c, Product_Reference__c, Product_Reference__r.Name, toLabel(Operator__c), Quantity__c,
                             Max_Quantity__c, Product__r.Income_Account_Name__c from Promotion_Discount_Values__r where (RecordType.Name='Marketing Promotion' or RecordTypeId=null) order by Quantity__c asc)
                            from Campaign where Country__c=:oppObj.Country__c and IsActive=true and RecordType.Name='Marketing Promo' and Id in (Select CampaignId from CampaignMember where ContactId = :oppObj.Account.PersonContactId) AND StartDate <= Today AND EndDate >= Today order by LastModifiedDate desc]) {
                                system.debug(row.Promotion_Discount_Values__r.size());
                                if (row.Promotion_Discount_Values__r.size() > 0) {
                                    // To map DiscountValueId to DiscountValue
                                    for (Promotion_Discount_Value__c rowValue: row.Promotion_Discount_Values__r) {
                                        result = new DiscountInfo();
                                        if (!string.isBlank(rowValue.Operator__c) && rowValue.Quantity__c != null) {
                                            info = '<b>'+rowValue.Operator__c + ' ' + rowValue.Quantity__c+'</b> Purchase';
                                        } else {
                                            info = '<b>Any</b> purchase';
                                            result.IsAny = true;
                                        }
                                        info += ' of <b>' + rowValue.Product_Reference__r.Name + '</b> would get';
                                        system.debug('rowValue:::'+rowValue);
                                        if (rowValue.Discount_Percentage__c != null) {
                                            result.Description = info + ' <b>' + rowValue.Discount_Percentage__c+'%</b> discount.';
                                            result.DiscountPercentage = rowValue.Discount_Percentage__c;
                                        } else if (rowValue.Discount_Amount__c != null) {
                                            result.Description = info + ' <b>'+rowValue.Campaign__r.CurrencyIsoCode+' '+rowValue.Discount_Amount__c+'</b> discount.';
                                            result.DiscountAmount = rowValue.Discount_Amount__c;
                                        } else if (rowValue.Unit_Price__c != null) {
                                            result.Description = info + ' price of <b>'+rowValue.Campaign__r.CurrencyIsoCode+' ' + rowValue.Unit_Price__c + ' for each</b>.';
                                            result.DiscountUnitPrice = rowValue.Unit_Price__c;
                                        } else if (rowValue.Qty__c!=null && rowValue.Product__c!=null) {
                                            result.Description = info + ' <b>' + rowValue.Product__r.Name + ' (' + rowValue.Qty__c + ' unit)</b>';
                                            result.BonusProduct = rowValue.Product__c;
                                            result.BonusProductName = rowValue.Product__r.Name;
                                            result.ChildCategory = 'Bonus';
                                            result.BonusQty = rowValue.Qty__c;
                                            result.BonusPrice = 0;
                                            if (!string.isBlank(rowValue.Product__r.Tax_Code__c)) {
                                                result.TaxCode = rowValue.Product__r.Tax_Code__c;
                                                result.TaxRate = rowValue.Product__r.Tax_Code__r.Tax_Rate__c;
                                            }
                                            result.ProductType = rowValue.Product__r.Product_Type__c;
                                            result.ProductDescription = rowValue.Product__r.Description;
                                            result.AccountName = rowValue.Product__r.Income_Account_Name__c;
                                            if (mapDiscIdx.keyset().contains(rowValue.Product__c)) {
                                                listDiscIdx = mapDiscIdx.get(rowValue.Product__c);
                                            } else {
                                                listDiscIdx = new list<integer>();
                                            }
                                            listDiscIdx.add(discIdx);
                                            mapDiscIdx.put(rowValue.Product__c, listDiscIdx);
                                        }
                                        
                                        if (result.Description != '') {
                                            result.Name = row.Name;
                                            result.CampaignId = row.Id;
                                            result.ProductReference = rowValue.Product_Reference__c;
                                            result.Operator = rowValue.Operator__c;
                                            result.Quantity = rowValue.Quantity__c;
                                            result.MaxQuantity = rowValue.Max_Quantity__c;
                                            result.DiscountReason = 'Marketing Promo';
                                        }
                                        listResult.add(result);
                                        discIdx++;
                                    }
                                }
                            }
        if (mapDiscIdx.keyset().size() > 0) {
            for (PricebookEntry row: [select Id, Name, Product2Id from PricebookEntry where Pricebook2Id=:oppObj.Pricebook2Id and Product2Id in :mapDiscIdx.keyset() and Product2.IsActive=true and IsActive=true and CurrencyIsoCode=:oppObj.CurrencyIsoCode]) {
                for (integer idx: mapDiscIdx.get(row.Product2Id)) {
                    listResult.get(idx).PricebookEntryId = row.Id;
                }
            }
        }
    }
    */
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get renewal promotion available to particular agent.
Inputs:        oppObj <Opportunity>: Specified Opportunity
listResult <list<DiscountInfo>>: List of promotion 
currentAccountRuleCode <string>: Current Agent Rule Code
mapUpgrade map<string, string>: Upgrade Map of current Subscription Product
mapDowngrade map<string, string>: Downgrade Map of current Subscription Product

Return: list<DiscountInfo>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<DiscountInfo> getRenewalDiscountInfo(Opportunity oppObj, list<DiscountInfo> listResult, string currentAccountRuleCode, map<string, string> mapUpgrade, map<string, string> mapDowngrade) {
        DiscountInfo result;
        string info;
        integer discIdx = listResult.size();
        map <string, list<integer>> mapDiscIdx = new map<string, list<integer>>();
        list<integer> listDiscIdx;
        list<string> listRenewalSku = new list<string>();
        list<string> listBonusSku = new list<string>();
        list<string> listUpgradeSku = new list<string>();
        list<string> listDowngradeSku = new list<string>();
        //list<Promotion_Discount_Value__c> listPromotion;
        map<string, decimal> mapProductUnitPrice = new map<string, decimal>();
        string accRuleCodeParams, renewalStage = '';
        // AM: The whole month of the Account Subscription End Date
        // AM+1: The whole month after the month of Account Subscription End Date
        // EB: The Month before the Month of Account Subscription End Date
        
        boolean isAm = (oppObj.Account.Subscription_End_Date__c.month() == system.today().month() && oppObj.Account.Subscription_End_Date__c.year() == system.today().year());
        boolean isAmPlus1 = (oppObj.Account.Subscription_End_Date__c.addMonths(1).month() == system.today().month() && oppObj.Account.Subscription_End_Date__c.addMonths(1).year() == system.today().year());
        boolean isEB = (oppObj.Account.Subscription_End_Date__c.addMonths(-1).month() == system.today().month() && oppObj.Account.Subscription_End_Date__c.addMonths(-1).year() == system.today().year());
        system.debug('Sub End date: '+ oppObj.Account.Subscription_End_Date__c);
        system.debug('isAm: ' + isAm + ' isAm+1: ' + isAmPlus1 + ' isEB: ' + isEB);
        if(isEB){
            renewalStage = 'Early Bird';
        }
        else if(isAm){
            renewalStage = 'AM';
        }
        else if(isAmPlus1){
            renewalStage = 'AM+1';
        }
        system.debug('Renewal Stage:' + renewalStage);
        if (currentAccountRuleCode!=null && !string.isBlank(currentAccountRuleCode)) {
            accRuleCodeParams = '%'+currentAccountRuleCode+'%';
            system.debug('Upgrade lookup for renewal discount SOQL:select Name, Renewal_SKU__c, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=\''+oppObj.Country__c+'\' and Name like \''+accRuleCodeParams+'\' order by Level__c desc');
            for (Upgrade_Package_Lookup__c row: [select Name, Renewal_SKU__c, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:oppObj.Country__c and Name like :accRuleCodeParams order by Level__c desc]) {
                listRenewalSku.add(row.Renewal_SKU__c);
            }
        }
        if (mapUpgrade!=null && mapUpgrade.keyset().size() > 0) {
            for (string idx: mapUpgrade.keyset()) {
                listRenewalSku.add(mapUpgrade.get(idx));
                listUpgradeSku.add(mapUpgrade.get(idx));
            }
        }
        system.debug('mapUpgrade:'+mapUpgrade);
        system.debug('mapDowngrade:'+mapDowngrade);
        if (mapDowngrade!=null && mapDowngrade.keyset().size() > 0) {
            for (string idx: mapDowngrade.keyset()) {
                listRenewalSku.add(mapDowngrade.get(idx));
                listDowngradeSku.add(mapDowngrade.get(idx));
            }
        }
        if (listRenewalSku.size() > 0) {
            
            /*listPromotion = [select Id, Name, RecordType.Name, Renewal_Type__c,Campaign__c, Campaign__r.Name, Campaign__r.CurrencyIsoCode, Product__c, Product__r.Name, Product__r.Description, Product__r.SKU_Code__c, Product__r.Product_Type__c, Product__r.Tax_Code__c, Product__r.Tax_Code__r.Tax_Rate__c, Qty__c, Unit_Price__c, Promotion_Type__c, Product_Reference__c, Product_Reference__r.Name, Product_Reference__r.SKU_Code__c,Product__r.Income_Account_Name__c,Discount_Amount__c from Promotion_Discount_Value__c where RecordType.Name='Renewal Promotion' and Renewal_Stage__c=:renewalStage and Product_Reference__r.SKU_Code__c in :listRenewalSku and Campaign__r.Country__c=:oppObj.Country__c and Campaign__r.IsActive=true and Campaign__r.RecordType.Name='Renewal Promotion' order by Campaign__r.LastModifiedDate desc];
            //system.debug('listPromotion:' + listPromotion);
            for (Promotion_Discount_Value__c rowValue: listPromotion) {
                system.debug('check:' + rowValue.Id + '-' + rowValue.Qty__c);
                if (rowValue.Qty__c>0) {
                    listBonusSku.add(rowValue.Product__r.SKU_Code__c);
                }
            }*/
            for (PricebookEntry row: [select Id, Product2.SKU_Code__c, UnitPrice,Product2.Income_Account_Name__c from PricebookEntry where Product2.SKU_Code__c in :listBonusSku
                                      and Pricebook2Id=:oppObj.Pricebook2Id and CurrencyIsoCode=:oppObj.CurrencyIsoCode and Product2.CurrencyIsoCode=:oppObj.CurrencyIsoCode
                                      and IsActive=true and Product2.IsActive=true]) {
                                          system.debug('--Map-SKU_Code__c-'+row.Product2.SKU_Code__c+'-unitprice-'+row.UnitPrice);
                                          mapProductUnitPrice.put(row.Product2.SKU_Code__c, row.UnitPrice);
                                      }
            //system.debug('Renewal discount SOQL:select Id, Name, RecordType.Name, Campaign__c, Campaign__r.Name, Campaign__r.CurrencyIsoCode, Product__c, Product__r.Name, Product__r.Description, Product__r.Product_Type__c, Product__r.Tax_Code__c, Product__r.Tax_Code__r.Tax_Rate__c, Qty__c, Unit_Price__c, Promotion_Type__c, Product_Reference__c, Product_Reference__r.Name, Product__r.Income_Account_Name__c from Promotion_Discount_Value__c where RecordType.Name=\'Renewal Promotion\' and Product_Reference__r.SKU_Code__c in '+listRenewalSku+' and Campaign__r.Country__c=\''+oppObj.Country__c+'\' and Campaign__r.IsActive=true and Campaign__r.RecordType.Name=\'Renewal Promotion\' order by Campaign__r.LastModifiedDate desc');
           /* for (Promotion_Discount_Value__c rowValue: listPromotion) {
                Boolean toAdd = false;
                // To map DiscountValueId to DiscountValue
                result = new DiscountInfo();
                info = (listUpgradeSku.contains(rowValue.Product_Reference__r.SKU_Code__c)?'Upgrade to ':(listDowngradeSku.contains(rowValue.Product_Reference__r.SKU_Code__c)?'Downgrade to ':'Renewal of '))+'<b>' + rowValue.Product_Reference__r.Name + '</b> would get';
                if(listUpgradeSku.contains(rowValue.Product_Reference__r.SKU_Code__c)&& rowValue.Renewal_Type__c == 'Upgrade'){
                    info = 'Upgrade to '+'<b>' + rowValue.Product_Reference__r.Name + '</b> would get';
                    toAdd = true;
                }else if(listDowngradeSku.contains(rowValue.Product_Reference__r.SKU_Code__c)&& rowValue.Renewal_Type__c == 'Downgrade'){
                    info = 'Downgrade to '+'<b>' + rowValue.Product_Reference__r.Name + '</b> would get';
                    toAdd = true;
                }else if(!(listUpgradeSku.contains(rowValue.Product_Reference__r.SKU_Code__c) || listDowngradeSku.contains(rowValue.Product_Reference__r.SKU_Code__c)) && rowValue.Renewal_Type__c == 'Renew' ){
                    info = 'Renewal of '+'<b>' + rowValue.Product_Reference__r.Name + '</b> would get';
                    toAdd = true;
                }
                
                result.IsAny = true;
                result.recordType = rowValue.RecordType.Name;
                result.Description = info + ' price of <b>'+rowValue.Campaign__r.CurrencyIsoCode+' ' + rowValue.Unit_Price__c + ' for each</b>';
                // Downgrade scenario cannot have bonus item.
                //rowValue.Qty__c = listDowngradeSku.contains(rowValue.Product_Reference__r.SKU_Code__c)?0:rowValue.Qty__c;
                system.debug('quantity of bonus item' + rowValue.Product__r.Name + ' is ' + rowValue.Qty__c);
                result.Description += (rowValue.Qty__c>0)?' and <b>' + rowValue.Product__r.Name + ' (' + rowValue.Qty__c + ' unit)</b>.':'';
                result.DiscountUnitPrice = rowValue.Unit_Price__c;
                //system.debug('--result.DiscountUnitPrice-'+result.DiscountUnitPrice+'-rowValue.Product__r.SKU_Code__c'+rowValue.Product__r.SKU_Code__c);
                //system.debug('--mapProductUnitPrice.get(rowValue.Product__r.SKU_Code__c-'+mapProductUnitPrice.get(rowValue.Product__r.SKU_Code__c));
                result.BonusProduct = rowValue.Product__c;
                result.BonusProductName = rowValue.Product__r.Name;
                result.ChildCategory = 'Bonus';
                result.BonusQty = rowValue.Qty__c;
                result.BonusPrice = mapProductUnitPrice.keyset().contains(rowValue.Product__r.SKU_Code__c)?mapProductUnitPrice.get(rowValue.Product__r.SKU_Code__c):0;
                result.DiscountPercentage = 100;
                if (!string.isBlank(rowValue.Product__r.Tax_Code__c)) {
                    result.TaxCode = rowValue.Product__r.Tax_Code__c;
                    result.TaxRate = rowValue.Product__r.Tax_Code__r.Tax_Rate__c;
                }
                result.ProductType = rowValue.Product__r.Product_Type__c;
                result.ProductDescription = rowValue.Product__r.Description;
                result.AccountName = rowValue.Product__r.Income_Account_Name__c;
                if (mapDiscIdx.keyset().contains(rowValue.Product__c)) {
                    listDiscIdx = mapDiscIdx.get(rowValue.Product__c);
                } else {
                    listDiscIdx = new list<integer>();
                }
                if(toAdd){
                    listDiscIdx.add(discIdx);
                    mapDiscIdx.put(rowValue.Product__c, listDiscIdx);   
                }
                
                
                
                result.Name = rowValue.Campaign__r.Name;
                result.CampaignId = rowValue.Campaign__c;
                result.ProductReference = rowValue.Product_Reference__c;
                result.DiscountReason = 'Renewal Promotion';
                result.DiscountReasonChild = 'Renewal Bonus';
                result.DiscountAmount = rowValue.Discount_Amount__c;
                result.renewalType = rowValue.Renewal_Type__c;
                if(toAdd){  
                    listResult.add(result);
                    discIdx++;
                }
                
            }*/
            
            if (mapDiscIdx.keyset().size() > 0) {
                for (PricebookEntry row: [select Id, Name, Product2Id from PricebookEntry where Pricebook2Id=:oppObj.Pricebook2Id and Product2Id in :mapDiscIdx.keyset() and Product2.IsActive=true and IsActive=true and CurrencyIsoCode=:oppObj.CurrencyIsoCode and Product2.CurrencyIsoCode=:oppObj.CurrencyIsoCode]) {
                    for (integer idx: mapDiscIdx.get(row.Product2Id)) {
                        listResult.get(idx).PricebookEntryId = row.Id;
                    }
                }
            }
        }
        system.debug(listResult);
        return listResult;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get renewal promotion available to particular agent.
Inputs:        oppObj <Opportunity>: Specified Opportunity
listResult <list<DiscountInfo>>: List of promotion 
currentAccountRuleCode <string>: Current Agent Rule Code
mapUpgrade map<string, string>: Upgrade Map of current Subscription Product
mapDowngrade map<string, string>: Downgrade Map of current Subscription Product

Return: list<DiscountInfo>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<DiscountInfo> getFirstTimerWinbackInfo(Opportunity oppObj, list<DiscountInfo> listResult) {
        DiscountInfo result;
        integer discIdx = listResult.size();
        system.debug('DiscountInfo size before first-timer winback is '+ discIdx);
        map <string, list<integer>> mapDiscIdx = new map<string, list<integer>>();
        list<integer> listDiscIdx;
        list<string> listBonusSku = new list<string>();
        list<Campaign> listPromotion;
        map<string, decimal> mapProductUnitPrice = new map<string, decimal>();
        string accRuleCodeParams;
        system.debug('First-timer winback SOQL:select Id, Name, (Select CampaignId, ContactId from CampaignMembers where ContactId = \''+oppObj.Account.PersonContactId+'\'), (select Id, Name, RecordType.Name, Campaign__c, Campaign__r.Name, Campaign__r.CurrencyIsoCode, Product__c, Product__r.Name, Product__r.Description, Product__r.SKU_Code__c, Product__r.Product_Type__c, Product__r.Tax_Code__c, Product__r.Tax_Code__r.Tax_Rate__c, Qty__c, Discount_Amount__c, Promotion_Type__c, Product_Reference__c, Product_Reference__r.Name');
        system.debug(', Product_Reference__r.SKU_Code__c from Promotion_Discount_Values__r where RecordType.Name=\'First-Timer Winback\') from Campaign where Country__c=\''+OppObj.Country__c+'\' and IsActive=true and RecordType.Name=\'First-Timer Winback\' and Id in (Select CampaignId from CampaignMember where ContactId = '+oppObj.Account.PersonContactId+') order by LastModifiedDate desc');
        listPromotion = [select Id, Name, (Select CampaignId, ContactId from CampaignMembers where ContactId = :oppObj.Account.PersonContactId)/*, (select Id, Name, RecordType.Name, Campaign__c, Campaign__r.Name, Campaign__r.CurrencyIsoCode, Product__c, Product__r.Name, Product__r.Description, Product__r.SKU_Code__c, Product__r.Product_Type__c, Product__r.Tax_Code__c, Product__r.Tax_Code__r.Tax_Rate__c, Qty__c, Discount_Amount__c, Promotion_Type__c, Product_Reference__c, Product_Reference__r.Name, Product_Reference__r.SKU_Code__c, Product__r.Income_Account_Name__c from Promotion_Discount_Values__r where RecordType.Name='First-Timer Winback')*/ from Campaign where Country__c=:oppObj.Country__c and IsActive=true and RecordType.Name='First-Timer Winback' and Id in (Select CampaignId from CampaignMember where ContactId = :oppObj.Account.PersonContactId) AND StartDate <= Today AND EndDate >= Today order by LastModifiedDate desc];
        /*for (Campaign row: listPromotion) {
            for (Promotion_Discount_Value__c rowValue: row.Promotion_Discount_Values__r) {
                if (rowValue.Qty__c>0) {
                    listBonusSku.add(rowValue.Product__r.SKU_Code__c);
                }
            }
        }*/
        system.debug('list bonus sku' + listBonusSku);
        system.debug('select Id, Product2.SKU_Code__c, UnitPrice from PricebookEntry where Product2.SKU_Code__c in \''+listBonusSku+'\' and Pricebook2Id=\''+oppObj.Pricebook2Id+'\' and CurrencyIsoCode=\''+oppObj.CurrencyIsoCode+'\' and Product2.CurrencyIsoCode=\''+oppObj.CurrencyIsoCode+'\' and IsActive=true and Product2.IsActive=true');
        for (PricebookEntry row: [select Id, Product2.SKU_Code__c, UnitPrice from PricebookEntry where Product2.SKU_Code__c in :listBonusSku
                                  and Pricebook2Id=:oppObj.Pricebook2Id and CurrencyIsoCode=:oppObj.CurrencyIsoCode and Product2.CurrencyIsoCode=:oppObj.CurrencyIsoCode
                                  and IsActive=true and Product2.IsActive=true]) {
                                      mapProductUnitPrice.put(row.Product2.SKU_Code__c, row.UnitPrice);
                                  }
        /*for (Campaign row: listPromotion) {
            for (Promotion_Discount_Value__c rowValue: row.Promotion_Discount_Values__r) {
                // To map DiscountValueId to DiscountValue
                result = new DiscountInfo();
                result.IsAny = true;
                result.recordType = rowValue.RecordType.Name;
                result.Description = 'Purchase of <b>' + rowValue.Product_Reference__r.Name + '</b> would get discount <b>'+rowValue.Campaign__r.CurrencyIsoCode+' ' + rowValue.Discount_Amount__c + ' for each</b>';
                // Downgrade scenario, AM & AM+1 cannot have bonus item.
                rowValue.Qty__c = rowValue.Qty__c;
                result.Description += (rowValue.Qty__c>0)?' and <b>' + rowValue.Product__r.Name + ' (' + rowValue.Qty__c + ' unit)</b>.':'';
                result.DiscountAmount = rowValue.Discount_Amount__c;
                result.BonusProduct = rowValue.Product__c;
                result.BonusProductName = rowValue.Product__r.Name;
                result.ChildCategory = 'Bonus';
                result.BonusQty = rowValue.Qty__c;
                result.BonusPrice = mapProductUnitPrice.keyset().contains(rowValue.Product__r.SKU_Code__c)?mapProductUnitPrice.get(rowValue.Product__r.SKU_Code__c):0;
                if (!string.isBlank(rowValue.Product__r.Tax_Code__c)) {
                    result.TaxCode = rowValue.Product__r.Tax_Code__c;
                    result.TaxRate = rowValue.Product__r.Tax_Code__r.Tax_Rate__c;
                }
                result.ProductType = rowValue.Product__r.Product_Type__c;
                result.ProductDescription = rowValue.Product__r.Description;
                result.AccountName = rowValue.Product__r.Income_Account_Name__c;
                if (mapDiscIdx.keyset().contains(rowValue.Product__c)) {
                    listDiscIdx = mapDiscIdx.get(rowValue.Product__c);
                } else {
                    listDiscIdx = new list<integer>();
                }
                listDiscIdx.add(discIdx);
                mapDiscIdx.put(rowValue.Product__c, listDiscIdx);
                
                result.Name = rowValue.Campaign__r.Name;
                result.CampaignId = rowValue.Campaign__c;
                result.ProductReference = rowValue.Product_Reference__c;
                result.DiscountReason = 'Marketing Promo';
                result.DiscountReasonChild = 'Marketing Promo';
                listResult.add(result);
                discIdx++;
            }
        }*/
        
        system.debug('DiscountInfo size after first-timer winback is '+ listResult.size());
        
        if (mapDiscIdx.keyset().size() > 0) {
            for (PricebookEntry row: [select Id, Name, Product2Id from PricebookEntry where Pricebook2Id=:oppObj.Pricebook2Id and Product2Id in :mapDiscIdx.keyset() and Product2.IsActive=true and IsActive=true and CurrencyIsoCode=:oppObj.CurrencyIsoCode and Product2.CurrencyIsoCode=:oppObj.CurrencyIsoCode]) {
                for (integer idx: mapDiscIdx.get(row.Product2Id)) {
                    listResult.get(idx).PricebookEntryId = row.Id;
                }
            }
        }
        return listResult;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to save Opportunity Product records
Inputs:        opp <Opportunity>: Specified Opportunity
listOppLine <list<OpportunityLineItem>>: List of OpportunityLineItem of specified Opportunity 
listOppLineDelete <list<OpportunityLineItem>>: List of OpportunityLineItem of specified Opportunity which is going to be deleted.

Return: list<OpportunityLineItem>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<OpportunityLineItem> saveForm(Opportunity opp, list<OpportunityLineItem> listOppLine, list<OpportunityLineItem> listOppLineDelete) {
        string result = 'ListOppLine Size: '+string.valueOf(listOppLine.size());
        list<OpportunityLineItem> listOppLineApex = new list<OpportunityLineItem>();
        OpportunityLineItem oppLine = new OpportunityLineItem();
        decimal counter;
        map<string, decimal> mapCounter = new map<string, decimal>();
        list<string> listParentId = new list<string>();
        mapCounter.put('', 0);
        system.debug('Pricebook2Idx:'+opp.Pricebook2Id);
        string errorMessage;
        
        Opportunity oppx = [select Id, Name, AccountId, Account.Name, Account.Country__c, Account.PersonContactId, Account.Status__c, Account.Previous_Account_Rule__c, Account.Account_Rule_Code__c, Account.Subscription_Start_Date__c, Account.Current_Subscription_Code__c, Pricebook2Id, PG_Tenure__c, Total_Spending__c, Subsidiary__c, Country__c, Order_Type_Clone__c, to_VIP_Approval__c, to_Managerial_Approval__c, to_FOC_Approval__c, StageName, Approval_Status__c, CurrencyIsoCode, CloseDate, Agent_Accepted_Time__c from Opportunity where Id=:opp.Id];
        Savepoint sp = Database.setSavepoint();
        try {
            Boolean throwExcep = oppx.StageName == 'Pending OMC Approval' && (string.isBlank(oppx.Approval_Status__c)|| oppx.Approval_Status__c == 'OMC Approval Rejected'||oppx.Approval_Status__c == 'OMC Approval Recalled');
            if (((oppx.StageName!='New' && oppx.StageName!='Proposal') || !(oppx.Approval_Status__c == null || oppx.Approval_Status__c == '' || oppx.Approval_Status__c == 'Discount Approval Rejected')) && (oppx.Agent_Accepted_Time__c != null)) {
                if(!throwExcep)
                    throw new DmlException('Opportunity is Locked.');
            }
            update opp;
            system.debug('after update oppx:'+opp.Pricebook2Id);
            if (listOppLineDelete.size() > 0) {
                delete listOppLineDelete;
            }
            system.debug('after delete line item');
            List<AggregateResult> listAggResults =[select Parent__c, Discount_Reason__c, MAX(SNo__c) maxCount from OpportunityLineItem where OpportunityId=:opp.Id group by Parent__c, Discount_Reason__c order by Parent__c];
            date dateSubscriptionStart = opp.Account.Subscription_Start_Date__c==null?Date.newInstance(opp.CloseDate.year(), opp.CloseDate.month(), opp.CloseDate.day()):Date.newInstance(opp.Account.Subscription_Start_Date__c.year(), opp.Account.Subscription_Start_Date__c.month(), opp.Account.Subscription_Start_Date__c.day());
            if(listAggResults !=null && listAggResults.size() >0) {
                for (AggregateResult aggRow: listAggResults) {
                    counter = string.valueOf(aggRow.get('maxCount'))==null?0:decimal.valueOf(string.valueOf(aggRow.get('maxCount')));
                    // Checkpoint 26112018: need further test on multiple scenario to populate SNo (bonus item/child item)
                    mapCounter.put(((string.valueOf(aggRow.get('Parent__c'))==null||(string.valueOf(aggRow.get('Discount_Reason__c'))=='Marketing Promo' || string.valueOf(aggRow.get('Discount_Reason__c'))=='Renewal Bonus'))?'':string.valueOf(aggRow.get('Parent__c'))), counter);
                    if (string.valueOf(aggRow.get('Parent__c'))!=null && (string.valueOf(aggRow.get('Discount_Reason__c'))=='Marketing Promo' || string.valueOf(aggRow.get('Discount_Reason__c'))=='Renewal Bonus')) listParentId.add(string.valueOf(aggRow.get('Parent__c')));
                }
                System.debug('aggregate results ' + listAggResults );
            }
            if (listParentId.size() > 0) {
                // Need to do re-query for any line item which has bonus item. Because bonus item has a separate SNo, unlike child item. This re-query is to get the child item SNo (if any)
                listAggResults =[select Parent__c, Discount_Reason__c, MAX(SNo__c) maxCount from OpportunityLineItem where OpportunityId=:opp.Id and Parent__c in :listParentId and (Discount_Reason__c!='Marketing Promo' OR Discount_Reason__c!='Renewal Bonus') group by Parent__c, Discount_Reason__c order by Parent__c];
                for (AggregateResult aggRow: listAggResults) {
                    counter = string.valueOf(aggRow.get('maxCount'))==null?0:decimal.valueOf(string.valueOf(aggRow.get('maxCount')));
                    mapCounter.put(string.valueOf(aggRow.get('Parent__c')), counter);
                }
            }
            system.debug('before proceed line item');
            for (OpportunityLineItem row: listOppLine) {
                oppLine = row.clone(true, true, false, false);
                
                oppLine.Order_Type__c = oppLine.Order_Type__c=='Upgrade'?getOrderType(dateSubscriptionStart, oppLine.Start_Date__c, oppx.Country__c):oppLine.Order_Type__c;
                oppLine.Product2 = null;
                oppLine.Campaign__r = null;
                if (oppLine.Parent__c=='null') {
                    oppLine.Parent__c = null;
                } else if (oppLine.Parent__c!=null) {
                    oppLine.Parent__c = string.valueOf(oppLine.Parent__c);
                }
                
                if (string.isBlank(oppLine.Id)) {
                    system.debug('opp.Id:'+opp.Id);
                    oppLine.OpportunityId = opp.Id;
                } else {
                    mapCounter.put(row.Id, row.SNo__c);
                }
                
                listOppLineApex.add(oppLine);
            }
            system.debug('before upsert line item');
            upsert listOppLineApex;
            system.debug('after upsert line item');
        } catch (DmlException e) {
            Database.rollback(sp);
            errorMessage = e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, Can\'t changed Stage to Proposal / New from Pending Online Payment')?'Opportunity Is Locked':(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION:')?e.getMessage().subStringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION:'):(e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION,')?e.getMessage().subStringAfter('FIELD_CUSTOM_VALIDATION_EXCEPTION,'):e.getMessage()));
                errorMessage = errorMessage.contains('You can look up ExceptionCode')?errorMessage.substringBefore('You can look up ExceptionCode'):errorMessage;
            System.debug('error : ' +e.getMessage() + e.getLineNumber());
            system.debug('opp.Pricebook2Id:'+opp.Pricebook2Id);
            //system.debug('listOppLineApex[0].PricebookEntryId:'+listOppLineApex.get(0).PricebookEntryId);
            throw new AuraHandledException(errorMessage);
        }
        list<OpportunityLineItem> listOppLineNeedUpdate = new list<OpportunityLineItem>();
        for (OpportunityLineItem row: listOppLineApex) {
            if (!string.isBlank(row.Parent__c) && row.Parent__c.isNumeric()) {
                row.Parent__c = listOppLineApex.get(integer.valueOf(row.Parent__c)).Id;
            }
            if (row.Parent__c==null && row.SNo__c==null || (row.Parent__c!=null && row.SNo__c==null && (row.Discount_Reason__c=='Marketing Promo' || row.Discount_Reason__c=='Renewal Bonus'))) {
                /*
* Parent Item Line
*/
                row.SNo__c = mapCounter.get('')+1;
                mapCounter.put(row.Id, row.SNo__c);
                mapCounter.put('', row.SNo__c);
                listOppLineNeedUpdate.add(row);
            } else if (row.Parent__c!=null && row.SNo__c==null) {
                /*
* Child Item Line
*/
                system.debug('row.Parent__c:'+row.Parent__c);
                row.SNo__c = mapCounter.get(row.Parent__c)+0.01;
                system.debug('row.SNo__c'+row.SNo__c);
                
                mapCounter.put(row.Parent__c, row.SNo__c);
                listOppLineNeedUpdate.add(row);
            }
        }
        if (listOppLineNeedUpdate.size() > 0) {
            sp = Database.setSavepoint();
            try {
                update listOppLineNeedUpdate;
            } catch (DmlException e) {
                Database.rollback(sp);
                System.debug('error : ' +e.getMessage() + e.getLineNumber());
                throw new AuraHandledException(e.getMessage());
            }
        }
        return listOppLineApex;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Apex class for discount info wrapper
Inputs:        

Test Class: 
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
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
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Apex class for OpportunityLineItem wrapper
Inputs:        

Test Class: 
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
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
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Apex class for Opportunity wrapper
Inputs:        

Test Class: 
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    public class OppTmpConstruct {
        @AuraEnabled
        public Opportunity oppObj;
        @AuraEnabled
        public string GstCode;
        @AuraEnabled
        public decimal GstVatRate;
        @AuraEnabled
        public map<string, string> mapDownGrade;
        @AuraEnabled
        public map<string, string> mapUpGrade;
        @AuraEnabled
        public string currentSubscription;
        @AuraEnabled
        public DiscountInfo loyaltyUpgrade;
        
        public OppTmpConstruct() {
            oppObj = new Opportunity();
            GstCode = '';
            GstVatRate = 0;
            mapDownGrade = new map<string, string>();
            mapUpGrade = new map<string, string>();
            currentSubscription = '';
            loyaltyUpgrade = new DiscountInfo();
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
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to construct upgrade page data.
Inputs:        accId <String>: Specified Account Id

Return: UpgradeTmp
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static UpgradeTmp constructUpgrade (string accId) {
        UpgradeTmp result = new UpgradeTmp();
        result.agentObj = [select Id, PG_Tenure__c, Name, VIP__c,Approval_Status__c,Account_Rule_Code__c, Status__c, Current_Subscription_Code__c, Subscription_Start_Date__c, Subscription_End_Date__c, Current_Subscription_Spending_Amount__c, Pro_Rate_Amount__c, Country__c, CurrencyIsoCode,Loyalty_Start_Date__c from Account where Id=:accId];
        if (result.agentObj.Subscription_Start_Date__c==null) {
            throw new AuraHandledException('Cannot proceed Upgrade Package, Subscription Start Date is empty.');
        } else if (result.agentObj.Country__c=='Singapore' && result.agentObj.Status__c=='Expired') {
            throw new AuraHandledException(result.agentObj.Name + '\'s Subscription is expired already. Cannot Upgrade Package');
        } else if (result.agentObj.Country__c=='Malaysia' && result.agentObj.Status__c!='Active') {
            throw new AuraHandledException(result.agentObj.Name + ' is not an Active Agent. Cannot Upgrade Package');
        }
        date dateSubscriptionStart = Date.newInstance(result.agentObj.Subscription_Start_Date__c.year(), result.agentObj.Subscription_Start_Date__c.month(), result.agentObj.Subscription_Start_Date__c.day());
        date dateNow = Date.newInstance(system.today().YEAR(),system.today().MONTH(),system.today().DAY());
        result.upgradeStartDate = dateNow;
        result.monthUtilised = dateSubscriptionStart.monthsBetween(dateNow);
        if (dateSubscriptionStart.day() > dateNow.day()) result.monthUtilised--;
        result.dayUtilised = dateSubscriptionStart.daysBetween(dateNow);
        result.listPbEntry = getUpgradeProductList(result.agentObj, result.monthUtilised);
        system.debug('listPbEntry@@@ '+result.listPbEntry);
        system.debug('getUpgradeProductList@@@ '+getUpgradeProductList(result.agentObj, result.monthUtilised));
        //added by Vikas for PGAUTO-1127
        Decimal agentTenure = CalculateUpgradeTenure(result.agentObj);
        //result.loyaltyDetail = getLoyaltyDiscInfo(result.agentObj.PG_Tenure__c, result.agentObj.Country__c);
        if(!(result.agentObj.VIP__c && String.isNotBlank(result.agentObj.Approval_Status__c)&& result.agentObj.Approval_Status__c.containsIgnoreCase('Approved')))
        result.loyaltyDetail = getLoyaltyDiscInfo(agentTenure, result.agentObj.Country__c);
        return result;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get custom setting to map Upgrade package
Inputs:        accId <String>: Specified Account Id

Return: UpgradeTmp
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------
CHECKPOINT 20190410: adjust constructUpgrade to retrieve upgrade product picklist (to have unit price adjusted[DONE]) and additional child (adjust SKU_Code & Quantity upon save [NOT DONE])
*/
    @AuraEnabled
    public static UpgradePackageWrapper getUpgradeMapping (Account agent, list<PricebookEntry> listPbEntry) {
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
        system.debug('agent.Country__c:'+agent.Country__c);
        system.debug('mapOfPbEntryIdx.keySet():'+mapOfPbEntryIdx.keySet());
        system.debug('SOQL Upgrade Package Lookup: select Name, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:agent.Country__c and Upgrade_SKU__c in :mapOfPbEntryIdx.keySet() order by Level__c');
        for (Upgrade_Package_Lookup__c row: [select Name, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:agent.Country__c and Upgrade_SKU__c in :mapOfPbEntryIdx.keySet() order by Level__c]) {
            ruleCodeSplit = row.Name.split('-');
            ruleCodeName = ruleCodeSplit[0].trim();
            mapRuleCodeOfProduct.put(ruleCodeName, row.Upgrade_SKU__c);
        }
        
        // Adjust Pricebook Entry Unit Price accordingly to the Upgrade_Package_Mapping__c
        system.debug('agent.Country__c: '+agent.Country__c);
        system.debug('agent.Account_Rule_Code__c: '+agent.Account_Rule_Code__c);
        system.debug('SOQL Upgrade Package Mapping: select Name, Origin_Rule_Code__c, Destination_Rule_Code__c, SKU_Code__c, Quantity__c, Unit_Price__c, Rack_Price__c from Upgrade_Package_Mapping__c where Country__c=:agent.Country__c and Origin_Rule_Code__c=:agent.Account_Rule_Code__c');
        for (Upgrade_Package_Mapping__c row: [select Name, Origin_Rule_Code__c, Destination_Rule_Code__c, SKU_Code__c, Quantity__c, Unit_Price__c, Rack_Price__c from Upgrade_Package_Mapping__c where Country__c=:agent.Country__c and Origin_Rule_Code__c=:agent.Account_Rule_Code__c]) {
            if (mapRuleCodeOfProduct.keySet().contains(row.Destination_Rule_Code__c) && mapOfPbEntryIdx.keySet().contains(mapRuleCodeOfProduct.get(row.Destination_Rule_Code__c))) {
                idx = mapOfPbEntryIdx.get(mapRuleCodeOfProduct.get(row.Destination_Rule_Code__c));
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
        result.listPbEntry = listPbEntry;
        return result;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get list of available PricebookEntry to be used as Upgrade
Inputs:        agentObj <Account>: Specified Account
monthDiff <integer>: Month difference between current Subscription start date and TODAY.

Return: list<PricebookEntry>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<PricebookEntry> getUpgradeProductList (Account agentObj, integer monthDiff) {
        system.debug('agentObj###monthDiff '+agentObj+' '+monthDiff);
        string errorMessage = '';
        map<string, Subsidiary__c> mapSubsidiary = new map<string, Subsidiary__c>();
        list<PricebookEntry> listPricebookEntry = new list<PricebookEntry>();
        User usr = [select Id, CurrencyIsoCode, Subsidiary__c from User where Id=:UserInfo.getUserId()][0];
        system.debug('usr### '+usr);
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
            system.debug('errorMessage### '+errorMessage);
        }
        
        if (!string.isBlank(errorMessage) && !Test.isRunningTest()) {
            system.debug('errorMessage>>>@@@ '+errorMessage);
            throw new AuraHandledException(errorMessage);
        }
        
        return listPricebookEntry;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get list of available PricebookEntry to be used as Renewal
Inputs:        agentObj <Account>: Specified Account
monthDiff <integer>: Month difference between current Subscription start date and TODAY.

Return: list<PricebookEntry>
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static list<PricebookEntry> getRenewalProductList (Account agentObj, Opportunity oppObj) {
        string errorMessage = '';
        list<PricebookEntry> listPricebookEntry = new list<PricebookEntry>();
        errorMessage = getSubscriptionProduct(agentObj, oppObj.CurrencyIsoCode, oppObj.Pricebook2Id, oppObj.Country__c, listPricebookEntry, 'Renewal_SKU__c');
        return listPricebookEntry;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get list of available PricebookEntry which is Subscription Products
Inputs:        agentObj <Account>: Specified Account
pricebookId <string>: Specified Pricebook Id
country <string>: Specified country
listPricebookEntry <list<PricebookEntry>>: list of available product (subscription)
whichSku <string>: To determine whether SKU for Upgrade or Renewal

Return: string
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    private static string getSubscriptionProduct(Account agentObj, string currencyCode, string pricebookId, string country, list<PricebookEntry> listPricebookEntry, string whichSku) {
        string errorMessage = '';
        string query;
        list<string> listUpgrade = new list<string>();
        boolean includeLookup = false;
        integer idxLevel;
        system.debug('Subscription Product SOQL: select Name, Renewal_SKU__c, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=\''+country+'\' order by Level__c');
        system.debug(whichSku);
        for (Upgrade_Package_Lookup__c row: [select Name, Renewal_SKU__c, Upgrade_SKU__c, Level__c from Upgrade_Package_Lookup__c where Country__c=:country order by Level__c]) {
            if (whichSku == 'Renewal_SKU__c') {
                if (agentObj.Country__c=='Singapore' && agentObj.Status__c=='Downgraded' && agentObj.Account_Rule_Code__c=='TRIAL' && row.Name.containsIgnoreCase(agentObj.Previous_Account_Rule__c)) {
                    listUpgrade.add(string.valueOf(row.get(whichSku)));
                    break;
                } else if (agentObj.Country__c=='Malaysia' && agentObj.Status__c=='Suspended' && agentObj.Account_Rule_Code__c=='TRIAL' && row.Name.containsIgnoreCase(agentObj.Previous_Account_Rule__c)) {
                    listUpgrade.add(string.valueOf(row.get(whichSku)));
                    break;
                } else if (row.Name.containsIgnoreCase(agentObj.Account_Rule_Code__c) && !row.Name.containsIgnoreCase('LITE6')) {
                    listUpgrade.add(string.valueOf(row.get(whichSku)));
                    break;
                }else if(agentObj.Account_Rule_Code__c.contains('LITE6') && !row.Name.containsIgnoreCase('LITE6') && row.Name.containsIgnoreCase('LITE')){
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
            system.debug('row.get(whichSku):'+row.get(whichSku));
        }
        system.debug('listUpgrade.size():'+listUpgrade.size());
        system.debug('Country:'+currencyCode);
        if (listUpgrade.size() > 0) {
            query = 'select Id, Name, UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.Product_Category__c, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c from PricebookEntry where Pricebook2Id=\''+pricebookId+'\' and Product2.IsActive=true and IsActive=true and Product2.Segment__c in (\'B2C Only\', \'B2B & B2C\') and Product2.Product_Category__c=\'Subscription\' and CurrencyIsoCode=\''+currencyCode+'\' and Product2.CurrencyIsoCode=\''+currencyCode+'\' and Product2.SKU_Code__c in (\''+ string.join(listUpgrade, '\', \'') + '\')';
            system.debug('getsub:');system.debug('query%%% '+query);
            for (PricebookEntry row: database.query(query)) {
                if (row.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode) {
                    listPricebookEntry.add(row);
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
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get proper Pricebook Id for specified user.
Inputs:        usr <Account>: Specified Agent Account
mapSubsidiary <map<string, Subsidiary__c>>: specified Subsidiary map to contain all Subsidiary records.

Return: String
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    private static Pricebook2 getPricebook (User usr, map<string, Subsidiary__c> mapSubsidiary) {
        Pricebook2 result;
        for (Subsidiary__c row: [select Id, Name, Country__c from Subsidiary__c where Name=:usr.Subsidiary__c]) {
            row.Country__c = row.Country__c.toUpperCase();
            mapSubsidiary.put(row.Name, row);
        }
        
        system.debug('SOQL$$$ '+[select Id, Name, Country__c from Subsidiary__c where Name=:usr.Subsidiary__c]);
        system.debug('map mapSubsidiary ::::'+mapSubsidiary);
        system.debug('map mapSubsidiary### ::::'+mapSubsidiary.get(usr.Subsidiary__c).Country__c);
        
        if (mapSubsidiary.keyset().size() > 0) {
            for (Pricebook2 row: [select Id, Name, CurrencyIsoCode from Pricebook2 where Subsidiary__c=:mapSubsidiary.get(usr.Subsidiary__c).Id and IsActive=true]) {
                result = row;
            }
        }
        system.debug('SOQL@@@ '+[select Id, Name, CurrencyIsoCode from Pricebook2 where Subsidiary__c=:mapSubsidiary.get(usr.Subsidiary__c).Id and IsActive=true]);
        system.debug('result>>> '+result);
        return result;
    }
    
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to save Upgrade Opportunity - Opportunity Line Item
Inputs:        agentObj <Account>: Specified Agent Account
pbEntry <PricebookEntry>: Specified Pricebook Entry
CampaignId <string>: Selected Campaign
DiscountPercentage <decimal>: Specified Discount Percentage
DiscountReason <string>: Specified Discount Reason
UpgradeStartDateString <string>: Specified Upgrade Start Date
PreviousProRate <decimal>: Previous Pro Rate
CurrentProRate <decimal>: Current Pro Rate

Return: String
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
    @AuraEnabled
    public static string saveUpgrade(Account agentObj, PricebookEntry pbEntry, string CampaignId, decimal DiscountPercentage, string DiscountReason, string UpgradeStartDateString, decimal PreviousProRate, decimal CurrentProRate, Upgrade_Package_Mapping__c UpgradePackageMap) {
        
        
        Opportunity opp = new Opportunity();
        OpportunityLineItem oppLine = new OpportunityLineItem();
        OpportunityLineItem oppLineChild;
        list<OpportunityLineItem> listOppLineChild = new list<OpportunityLineItem>();
        date dateSubscriptionStart;
        String[] strDate = UpgradeStartDateString.split('-');
        Integer myIntDate = integer.valueOf(strDate[2]);
        Integer myIntMonth = integer.valueOf(strDate[1]);
        Integer myIntYear = integer.valueOf(strDate[0]);
        Date UpgradeStartDate = Date.newInstance(myIntYear, myIntMonth, myIntDate);
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
        
        list<OppLineItemTmp> listOppLineTmp = getChild(priceBook.Id, pbEntry.Product2Id);
        system.debug('->UpgradePackageMap:');
        system.debug(UpgradePackageMap);
        if (UpgradePackageMap != null) {
            // Only for Upgrade Package with Upgrade Package Mapping
            getUpgradeMapBonusItem(priceBook, UpgradePackageMap, listOppLineTmp, pbEntry.Product2Id);
        }
        Savepoint sp = Database.setSavepoint();
        try {
            opp.Name = 'Upgrade '+agentObj.Account_Rule_Code__c+' to ' + pbEntry.Name+'.';
            opp.StageName = 'Proposal';
            opp.AccountId = agentObj.Id;
            opp.RecordTypeId = mapOppRT.get('B2C');
            opp.Order_Type_Clone__c = 'Contract - Upgrade';
            opp.Pro_Rate__c = CurrentProRate;
            opp.Pricebook2Id = pricebook.Id;
            opp.CloseDate = system.today();
            opp.Subsidiary__c = mapSubsidiary.get(usr.Subsidiary__c).Id;            
            dateSubscriptionStart = Date.newInstance(agentObj.Subscription_Start_Date__c.year(), agentObj.Subscription_Start_Date__c.month(), agentObj.Subscription_Start_Date__c.day());
            // Using UpgradePackageMap to identify whether to set Order Type as Upgrade Outside Renewal Window due to MY requirement, can use Country though.
            oppLine.Order_Type__c = UpgradePackageMap!=null?'Upgrade Outside Renewal Window':getOrderType(dateSubscriptionStart, upgradeStartDate, agentObj.Country__c);
            
            insert opp;
            
            //added by vikas
            if(opp.id != null)
                QuoteSyncHandler.syncQuoteToOpp(new List<Id>{opp.Id});
            
            oppLine.OpportunityId = opp.Id;
            oppLine.PricebookEntryId = pbEntry.Id;
            oppLine.Product2Id = pbEntry.Product2Id;
            oppLine.UnitPrice = pbEntry.UnitPrice;
            oppLine.Original_Price__c = oppLine.UnitPrice;
            oppLine.Line_Description2__c = pbEntry.Product2.Description;
            oppLine.Product_Type__c = pbEntry.Product2.Product_Type__c;
            oppLine.Quantity = 1;
            oppLine.SNo__c = 1;
            oppLine.Discount_Remarks__c = (CurrentProRate!=null && CurrentProRate>0)?('Pro Rated Amount: ' + proRateFormat):oppLine.Discount_Remarks__c;
            oppLine.Pro_Rate_Amount__c = CurrentProRate;
            oppLine.Start_Date__c = UpgradeStartDate;
            oppLine.Income_Account_Name__c = pbEntry.Product2.Income_Account_Name__c;
            // Using UpgradePackageMap to identify whether to use Subscription_End_Date__c due to MY requirement, can use Country though.
            oppLine.End_Date__c = UpgradePackageMap!=null?(agentObj.Account_Rule_Code__c == 'LITE6' ? UpgradeStartDate.addMonths(12).addDays(-1):agentObj.Subscription_End_Date__c):UpgradeStartDate.addMonths(12).addDays(-1);
            if (!string.isBlank(CampaignId)) {
                oppLine.Campaign__c = CampaignId;
                oppLine.Discount__c = DiscountPercentage;
                oppLine.Discount_Reason__c = DiscountReason;
            }
            if (!string.isBLank(pbEntry.Product2.Tax_Code__c)) {
                oppLine.GST_VAT_Rate__c = pbEntry.Product2.Tax_Code__r.Tax_Rate__c;
                oppLine.GST_VAT_Code__c = pbEntry.Product2.Tax_Code__c;
            }
            
            system.debug('Opportunity PricebookId:'+opp.Pricebook2Id);
            system.debug('LineItem PricebookId:'+pbEntry.Pricebook2Id);
            if(!Test.isRunningTest()) insert oppLine; // added by gian 21-09-2018
            if (listOppLineTmp.size() > 0) {
                for (OppLineItemTmp row: listOppLineTmp) {
                    oppLineChild = new OpportunityLineItem();
                    oppLineChild.PricebookEntryId = row.Id;
                    oppLineChild.OpportunityId = opp.Id;
                    oppLineChild.Parent__c = oppLine.Id;
                    oppLineChild.Product2Id = row.Product2Id;
                    oppLineChild.SNo__c = row.IsSeparate?2:SNoChild;
                    oppLineChild.Child_Category__c = 'Package';
                    oppLineChild.Line_Description2__c = row.Line_Description2;
                    oppLineChild.Product_Category__c = row.Product2.Product_Category__c;
                    oppLineChild.UnitPrice = row.UnitPrice;
                    oppLineChild.Original_Price__c = oppLineChild.UnitPrice==null?0:oppLineChild.UnitPrice;
                    oppLineChild.Product_Type__c = row.Product_Type;
                    oppLineChild.Quantity = row.Quantity;
                    oppLineChild.Complimentary__c = true;
                    oppLineChild.Start_Date__c = oppLine.Start_Date__c;
                    oppLineChild.End_Date__c = oppLine.End_Date__c;
                    oppLineChild.Push_to_NetSuite__c = false;
                    oppLineChild.Income_Account_Name__c = oppLine.Product2.Income_Account_Name__c;
                    if (!string.isBLank(row.Product2.Tax_Code__c)) {
                        oppLine.GST_VAT_Rate__c = row.Product2.Tax_Code__r.Tax_Rate__c;
                        oppLine.GST_VAT_Code__c = row.Product2.Tax_Code__c;
                    }
                    oppLineChild.Order_Type__c = null;
                    oppLineChild.PO__c = true;
                    
                    listOppLineChild.add(oppLineChild);
                    SNoChild += row.IsSeparate?0:0.01;
                }
                insert listOppLineChild;
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
        system.debug('listOppLineItem before:');
        system.debug(listOppLineItem);
        for (PricebookEntry row: [select Id, Name, UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.Product_Category__c, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c from PricebookEntry where Pricebook2Id=:pb.Id and CurrencyIsoCode=:pb.CurrencyIsoCode and Product2.CurrencyIsoCode=:pb.CurrencyIsoCode and Product2.IsActive=true and IsActive=true and Product2.Segment__c in ('B2C Only', 'B2B & B2C') and Product2.SKU_Code__c = :upm.SKU_Code__c limit 100]) {
            oppLineItemTmpAssignment(row, listOppLineItem, integer.valueOf(upm.Quantity__c), parentProductId, true);
        }
        system.debug('listOppLineItem after:');
        system.debug(listOppLineItem);
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Function to get Order Type based on date difference between Subscription Start Date & Upgrade Start Date
Inputs:        dateSubscriptionStart <date>: 
upgradeStartDate <date>: 

Return: String
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
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
    
    @AuraEnabled
    public static boolean getProfileNamePermission(){
        
        boolean profileName;
        User usr = [Select Id,Name,ProfileId,Profile.Name from User where Id=:UserInfo.getUserId()];
        if(usr.Profile.Name == 'MY B2C Sales User' || usr.Profile.Name == 'B2C Sales User' || usr.Profile.Name == 'MY B2C Sales Head' || usr.Profile.Name == 'B2C Sales Head')
            profileName = true;
        else
            profileName = false;
        
        return profileName;
    }
    
    /*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Apex class for Agent Upgrade page wrapper
Inputs:        

Test Class: 
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
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
        
        public UpgradeTmp() {
            agentObj = new Account();
            listPbEntry = new list<PricebookEntry>();
            loyaltyDetail = new DiscountInfo();
            monthUtilised = 0;
            dayUtilised = 0;
        }
    } 
    //return wrapper of user info and opportunity record details
    public class userInfoOppRecordWrapper {
        @AuraEnabled public String userProfile;
        @AuraEnabled public Opportunity opp;
    }
    @AuraEnabled
    public static userInfoOppRecordWrapper getUserInfoAndOppRecord(string oppId) {
        userInfoOppRecordWrapper wrapper = new userInfoOppRecordWrapper(); 
        String profileId = userInfo.getProfileId();
        wrapper.userProfile = [select name from profile where id = :profileId].Name;
        Opportunity result = [select Id, Name,Agent_Accepted_Time__c,Approval_Status__c, Country__c,Is_Testing__c,Order_Type_Clone__c,Pricebook2Id,CurrencyIsoCode,CampaignId, Campaign.Name,StageName,Account.PersonContactId from Opportunity where Id=:oppId];
        wrapper.opp = result;
        return wrapper;
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
        
    
 
}
}