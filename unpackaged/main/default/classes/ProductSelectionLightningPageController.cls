// Test class : ProductSelectionController_Test  
public without sharing class ProductSelectionLightningPageController {
    //return wrapper of user info and opportunity record details
    public class userInfoOppRecordWrapper {
        @AuraEnabled public String userProfile;
        @AuraEnabled public Quote quo;
        @AuraEnabled public Opportunity opp;
        @AuraEnabled public Decimal paymentAmt;
    }
    @AuraEnabled
    public static userInfoOppRecordWrapper getUserInfoAndOppRecord(string oppId) {
        userInfoOppRecordWrapper wrapper = new userInfoOppRecordWrapper(); 
        String profileId = userInfo.getProfileId();
        wrapper.userProfile = [select name from profile where id = :profileId].Name;
        Quote result = [select Id, Name,Quote_Type__c,Approval_Status__c,Agent_Accepted_Time__c, Country__c,Status,Pricebook2Id,CurrencyIsoCode,OpportunityId,Account.Subscription_End_Date__c,Account.Previous_Acct_End_Date__c,Account.Account_Rule_Code__c,Account.Previous_Account_Rule__c,Account.IsAdvance_Plus_Downgrade__c  from Quote where Id=:oppId];
        Opportunity opp = [select Id, Name,Agent_Accepted_Time__c,CloseDate,Country__c,Approval_Status__c,CreatedDate,Is_Testing__c,Order_Type_Clone__c  ,Opportunity_Type__c,Pricebook2Id,CurrencyIsoCode,CampaignId, Campaign.Name, StageName, Account.PersonContactId, Account.Subscription_End_Date__c, Account.Tax_Reg_Number__c from Opportunity where Id=:result.OpportunityId];
        AggregateResult[] groupedResults =[select sum(Amount2__c) from payment__c where Opportunity_Record__c=: result.OpportunityId    ];
        wrapper.quo = result;
        wrapper.opp = opp;
        if(groupedResults.Size()==0){
            wrapper.paymentAmt = 0;
        }
        else
        {
            wrapper.paymentAmt =(Decimal)groupedResults[0].get('expr0');
        }   
        return wrapper;
    }
    public class ProductAndPromoListWrapper {
        @AuraEnabled public List<PricebookEntry> prodList;
        @AuraEnabled public Map<String, List<Promo_Mechanic__c>> prodIdVsPromoMap;
        @AuraEnabled public Map<Id,List<Id>> mapOfPromoIdVSSetOfProductIds;
        @AuraEnabled public map<id,PricebookEntry> prodIdVsPricebookEntry;
    }
    //get available product for opportunity and list of promo mechanic for opportunity 
    @AuraEnabled
    public static ProductAndPromoListWrapper getAvailableProductAndPromo(string priceBookId, string currencyCode, string searchKey, String oppId,String quoteID) {
        
        ProductAndPromoListWrapper wrapper = new ProductAndPromoListWrapper();
        String selectedOppRecordName = '';
        Map<Id,List<Id>> mapOfPromoIdVSSetOfProductSetIds = new Map<Id,List<Id>>();
        List<PricebookEntry> listAvailableProduct = new List<PricebookEntry>();
        List<String> productIdList = new List<String>();
        List<Promo_Mechanic__c> promoList = new List<Promo_Mechanic__c>();
        Map<String, List<Promo_Mechanic__c>> prodIdVsPromoRecMap = new Map<String, List<Promo_Mechanic__c>>();
        map<id,PricebookEntry> prodIdVsPricebookEntry = new map<id,PricebookEntry>();
        map<id,CampaignMember> campaignIdVsCM = new map<id,CampaignMember>();
        
        List<Opportunity> opportunityList = [select Id, RecordType.developerName,accountId,Order_Type_Clone__c  ,Opportunity_Type__c, account.IsPersonAccount, account.PersonContactId,account.VIP_Campaign__c,account.VIP__c,account.Approval_Status__c from opportunity where id = :oppId limit 1 ];
        if(opportunityList != null && opportunityList.size()>0){
            selectedOppRecordName = opportunityList[0].RecordType.developerName + ' Only';
            For(CampaignMember campMember : [select CampaignId,Status,Campaign.isActive from CampaignMember where Campaign.isActive = true AND ContactId = :opportunityList[0].account.PersonContactId]){
                //filling map here because for a contact there can be one Campaign Member on single campaign
                campaignIdVsCM.put(campMember.CampaignId,campMember);
            }
            
            if (!string.isBlank(priceBookId)) {
                searchKey = '%'+searchKey+'%';
                Set<Id> PBEIds = new Set<Id>();
                if(opportunityList[0].Opportunity_Type__c =='B2C - Renewal'){
                    Map<String,PriceBookEntry> PBE = new Map<String,PriceBookEntry>();
                    Map<decimal,Map<String,PriceBookEntry>> mapReturnPBE =  ProductSelectionLightningPageController.getRenewalOptions(quoteID);
                    for(decimal temp : mapReturnPBE.keySet()){
                     PBE.putall(mapReturnPBE.get(temp));
                    }
                    for(String temp : PBE.keyset()){
                      PBEIds.add(PBE.get(temp).Id);
                    }
               }
                for (PricebookEntry row: [select Id, Name, UnitPrice, Pricebook2Id, Product2Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.End_Date_Non_Editable__c,
                                          Product2.Is_Bundle__c, Product2.SKU_Code__c,Product2.Multiple_Sale_Not_Allowed__c,Product2.Start_Date_Non_Editable__c,Product2.Product_Category__c, CurrencyIsoCode, Pricebook2.CurrencyIsoCode,Product2.Revised_Product__c, Product2.Effective_till__c,
                                          Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c,Product2.CustItem_Validity_Value__c,Product2.CustItem_Validity_Unit__c from PricebookEntry where 
                                          Pricebook2Id=:priceBookId and CurrencyIsoCode=:currencyCode and Product2.CurrencyIsoCode=:currencyCode and 
                                          Product2.IsActive=true and IsActive=true and 
                                          //Product2.Segment__c = 'B2C Only' and 
                                          Product2.Segment__c in ('B2C Only', 'B2B & B2C') and
                                          Product2.Can_Be_Sold_Stand_Alone__c=true 
                                          and (Product2.Name like :searchKey or Product2.SKU_Code__c like :searchKey) limit 100]) {
                                              Date currentDate = date.newInstance(System.today().year(),System.today().month(),System.today().day());
                                              if(((row.Product2.Revised_Product__c==null|| row.Product2.Effective_till__c==null ) && opportunityList[0].Opportunity_Type__c !='B2C - Renewal')||
                                                (opportunityList[0].Opportunity_Type__c =='B2C - Renewal' && PBEIds.contains(row.Id)) ||(row.Product2.Product_Category__c !='Subscription')){
                                                     listAvailableProduct.add(row);
                                                     productIdList.add(row.Product2Id);
                                                     prodIdVsPricebookEntry.put(row.Product2Id,row); 
                                              }
                                          }      
                /* for(Promo_Mechanic__c promo : [select Id,Denomination__c ,Opportunity_Type__c, Name, Eligible_Product__c, Renewal_Type__c,Usage__c,CurrencyIsoCode,Discount_Reason__c, Campaign_Eligibility__c,Campaign_Eligibility__r.Name,
Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.Name,Campaign_Eligibility__r.Campaign__r.ParentId,Max_Qty__c,Min_Qty__c,
(select id, name,Discount__c, Discounted_amt__c,Entitlement_Product__c,Entitlement_Product__r.Name,Quantity__c, CurrencyIsoCode,
Promo_Mechanic__c from Entitlement_Product__r),(SELECT Id, Name, Promo_Mechanic__c,Exclusion_Product__c FROM Exclusion_Product__r) from Promo_Mechanic__c where Campaign_Eligibility__r.Campaign__r.ParentId  IN : campaignIdVsCM.keySet() OR Campaign_Eligibility__r.Campaign__c IN : campaignIdVsCM.keySet()]) {*/
                for(Promo_Mechanic__c promo : [select Id,Denomination__c ,Opportunity_Type__c, Name, Eligible_Product__c, Renewal_Type__c,Usage__c,CurrencyIsoCode,Discount_Reason__c, Campaign_Eligibility__c,Campaign_Eligibility__r.Name,
                                               Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.Name,Campaign_Eligibility__r.Campaign__r.ParentId,Max_Qty__c,Min_Qty__c,
                                               (select id, name,Discount__c, Discounted_amt__c,Discount_per_unit__c,Entitlement_Product__c,Entitlement_Product__r.Name,Quantity__c, CurrencyIsoCode,Duration__c,Duration_Term__c,Is_Promo_Start_Date_Editable__c,Entitlement_Product__r.CustItem_Validity_Value__c,Entitlement_Product__r.CustItem_Validity_Unit__c,
                                                Promo_Mechanic__c from Entitlement_Product__r), Override_Duration_Unit__c, Override_End_Date__c, Override_Duration_Value__c from Promo_Mechanic__c where (Campaign_Eligibility__r.Campaign__r.ParentId  IN : campaignIdVsCM.keySet() OR Campaign_Eligibility__r.Campaign__c IN : campaignIdVsCM.keySet()) AND Status__c = 'Active']) {
                                                    
                                                    /*  for(Excluded_Promotion__c ep : promo.Exclusion_Product__r){
if(mapOfPromoIdVSSetOfProductSetIds.containsKey(ep.Exclusion_Product__c)){
mapOfPromoIdVSSetOfProductSetIds.get(promo.Id).add(ep.Exclusion_Product__c);
}else
mapOfPromoIdVSSetOfProductSetIds.put(promo.Id,new List<Id>{ep.Exclusion_Product__c});
}*/                                               
                                                    if(prodIdVsPromoRecMap.containsKey(promo.Eligible_Product__c)) {
                                                        if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__r.ParentId)){
                                                            //if(opportunityList[0].Order_Type_Clone__c   == 'Contract - Renewal' && opportunityList[0].account.VIP__c == true && opportunityList[0].account.Approval_Status__c.containsIgnoreCase('Approved')){
                                                            String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__r.ParentId).Status;
                                                            if((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1){
                                                                promoList = prodIdVsPromoRecMap.get(promo.Eligible_Product__c);
                                                                promoList.add(promo);
                                                                prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                            }
                                                            
                                                            //}
                                                        }else if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__c)){
                                                            String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__c).Status;
                                                            if((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1){
                                                                promoList = prodIdVsPromoRecMap.get(promo.Eligible_Product__c);
                                                                promoList.add(promo);
                                                                prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                            }
                                                        }
                                                        
                                                        
                                                    }
                                                    else {
                                                        
                                                        if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__r.ParentId)){
                                                            //if(opportunityList[0].Order_Type_Clone__c   == 'Contract - Renewal' && opportunityList[0].account.VIP__c == true && opportunityList[0].account.Approval_Status__c.containsIgnoreCase('Approved')){
                                                            String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__r.ParentId).Status;
                                                            if((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1){
                                                                promoList = new list<Promo_Mechanic__c>();
                                                                promoList.add(promo);
                                                                prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                            }
                                                            //}
                                                        }else if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__c)){
                                                            String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__c).Status;
                                                            if(((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1) && cmStatus != 'Revoked'){
                                                                promoList = new list<Promo_Mechanic__c>();
                                                                promoList.add(promo);
                                                                prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                            }
                                                        }
                                                    }
                                                    
                                                }
            }
        }
        wrapper.prodList = listAvailableProduct; 
        wrapper.prodIdVsPromoMap = prodIdVsPromoRecMap;
        wrapper.mapOfPromoIdVSSetOfProductIds = mapOfPromoIdVSSetOfProductSetIds;
        wrapper.prodIdVsPricebookEntry = prodIdVsPricebookEntry;
        return wrapper;
    }
    public class oliAndDefaultPromoListWrapper {
        @AuraEnabled public List<OpportunityLineItem> oliList;
        @AuraEnabled public Map<String, List<Promo_Mechanic__c>> defaultProdIdVsPromoRecMap;
        @AuraEnabled public Map<String, List<Promo_Mechanic__c>> prodIdVsPromoRecMap;
        @AuraEnabled public Map<Id,List<Id>> mapOfPromoIdVSSetOfProductIds;
        @AuraEnabled public boolean isRenewal = false;
        @AuraEnabled public List<QuoteLineItem> qliList;
        @AuraEnabled public Map<Id,Date> endOfWeek = new Map<Id,Date>();
    }
    @AuraEnabled
    public static oliAndDefaultPromoListWrapper oliAndDefaultPromoList (String oppId, String quoteId) {
        Date endOfWeekForCarryOverAC;
        oliAndDefaultPromoListWrapper wrapper = new oliAndDefaultPromoListWrapper();
        Map<Id,List<Id>> mapOfPromoIdVSSetOfProductSetIds = new Map<Id,List<Id>>();
        Map<String, List<Promo_Mechanic__c>> prodIdVsPromoRecMap = new Map<String, List<Promo_Mechanic__c>>();
        map<id,CampaignMember> campaignIdVsCM = new map<id,CampaignMember>();
        List<Promo_Mechanic__c> promoList = new List<Promo_Mechanic__c>();
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        List<QuoteLineItem> qliList = new List<QuoteLineItem>();
        List<String> oliProdIdList = new List<String>();
        if(String.isBlank(quoteId) || quoteId.containsIgnoreCase('show')){
            For(OpportunityLineItem oli : [select Id,OpportunityId,Opportunity.Country__c,Discount_Reason__c,SNO__c,PO__c,Start_Date__c ,IsDiscretionaryAC__c,End_Date__c ,Opportunity.Order_Type_Clone__c  ,Opportunity.Opportunity_Type__c,Product2Id,Product2.Name,Promo_Mechanic_Id__c,Parent_Id__c,Product2.Product_Category__c, ListPrice,UnitPrice, Quantity, Discount__c, Discount_Amount__c,Amount__c, Campaign__r.Name,Parent__c,Product2.CustItem_Validity_Value__c,Product2.CustItem_Validity_Unit__c from 
                                           OpportunityLineItem where OpportunityId = :oppId order by SNO__c asc]) {
                                               oliList.add(oli);
                                               oliProdIdList.add(oli.Product2Id);   
                                           }
        }else if(String.isNotBlank(quoteId)){
            for(QuoteLineItem oli : [select Id,Quote.OpportunityId,Quote.Account.Account_Rule_Code__c,Product2.SKU_Code__c,Product2.Start_Date_Non_Editable__c,Product2.End_Date_Non_Editable__c,Discount_Reason__c,IsDiscretionaryAC__c,PO__c,Start_Date__c ,SNO__c,End_Date__c ,Quote.Opportunity.Order_Type_Clone__c  ,Product2Id,Product2.Name,Promo_Mechanic_Id__c,Parent_Id__c,Product2.Product_Category__c, ListPrice,UnitPrice, Quantity, Discount__c, Discount_Amount__c, Campaign__r.Name,Parent__c, GST_VAT_Rate__c, Amount__c, WHT_Rate__c,Pro_Rate_Amount__c,Gross_Amount__c,CampaignId__c,Product2.CustItem_Validity_Value__c,Product2.CustItem_Validity_Unit__c, Product2.Multiple_Sale_Not_Allowed__c from 
                                     QuoteLineItem where QuoteId = :quoteId order by SNO__c asc]
               ) {
                   qliList.add(oli);
                   oliProdIdList.add(oli.Product2Id);
                   Date endOfTheWeek = UpgradePackageCalculatorSG.calculateWeekEndDate(oli.Start_Date__c);
                   if(oli.Product2Id!=null && oli.Product2.Product_Category__c == 'Subscription') {
                       endOfWeekForCarryOverAC = endOfTheWeek;
                   }
                   if(oli.IsDiscretionaryAC__c == true) {
                       wrapper.endOfWeek.put(oli.id,endOfWeekForCarryOverAC); 
                   } else {
                       wrapper.endOfWeek.put(oli.id,endOfTheWeek); 
                   }
               }
        }
        
        List<Opportunity> opportunityList = [select Id, accountId,Order_Type_Clone__c  ,Opportunity_Type__c, account.IsPersonAccount, account.PersonContactId,account.VIP_Campaign__c,account.VIP__c,account.Approval_Status__c from opportunity where id = :oppId limit 1 ];
        if(opportunityList != null && opportunityList.size()>0){
            if(opportunityList[0].Order_Type_Clone__c   == 'Contract - Renewal' || opportunityList[0].Opportunity_Type__c == 'B2C - Renewal')
                wrapper.isRenewal = true;
            For(CampaignMember campMember : [select CampaignId,Campaign.isActive,Status from CampaignMember where Campaign.isActive = true AND ContactId = :opportunityList[0].account.PersonContactId])
                campaignIdVsCM.put(campMember.CampaignId,campMember);
            /* for(Promo_Mechanic__c promo : [select Id, Name,Denomination__c ,Opportunity_Type__c, Eligible_Product__c,Discount_Reason__c, Renewal_Type__c,CurrencyIsoCode,Campaign_Eligibility__c,Campaign_Eligibility__r.Name,Usage__c,
Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.ParentId,Campaign_Eligibility__r.Campaign__r.Name,Campaign_Eligibility__r.Campaign__r.Parent.Name,Max_Qty__c,Min_Qty__c,
(select id, name,Discount__c, Discounted_amt__c,Entitlement_Product__c,Entitlement_Product__r.Name,Quantity__c, CurrencyIsoCode,
Promo_Mechanic__c from Entitlement_Product__r),(SELECT Id, Name, Exclusion_Product__c FROM Exclusion_Product__r) from Promo_Mechanic__c where Campaign_Eligibility__r.Campaign__r.ParentId  IN : campaignIdVsCM.keySet() OR Campaign_Eligibility__r.Campaign__c IN : campaignIdVsCM.keySet()]) {*/
            for(Promo_Mechanic__c promo : [select Id, Name,Denomination__c ,Opportunity_Type__c, Eligible_Product__c,Discount_Reason__c, Renewal_Type__c,CurrencyIsoCode,Campaign_Eligibility__c,Campaign_Eligibility__r.Name,Usage__c,
                                           Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.ParentId,Campaign_Eligibility__r.Campaign__r.Name,Campaign_Eligibility__r.Campaign__r.Parent.Name,Max_Qty__c,Min_Qty__c,
                                           (select id, name,Discount__c, Discounted_amt__c,Discount_per_unit__c,Entitlement_Product__c,Entitlement_Product__r.Name,Quantity__c, CurrencyIsoCode,Duration__c,Duration_Term__c,Is_Promo_Start_Date_Editable__c,Entitlement_Product__r.CustItem_Validity_Value__c,Entitlement_Product__r.CustItem_Validity_Unit__c,
                                            Promo_Mechanic__c from Entitlement_Product__r), Override_Duration_Unit__c, Override_End_Date__c, Override_Duration_Value__c from Promo_Mechanic__c where (Campaign_Eligibility__r.Campaign__r.ParentId  IN : campaignIdVsCM.keySet() OR Campaign_Eligibility__r.Campaign__c IN : campaignIdVsCM.keySet()) AND Status__c = 'Active']) {
                                                /*for(Excluded_Promotion__c ep : promo.Exclusion_Product__r){
if(mapOfPromoIdVSSetOfProductSetIds.containsKey(ep.Exclusion_Product__c)){
mapOfPromoIdVSSetOfProductSetIds.get(promo.Id).add(ep.Exclusion_Product__c);
}else
mapOfPromoIdVSSetOfProductSetIds.put(promo.Id,new List<Id>{ep.Exclusion_Product__c});
}*/
                                                if(prodIdVsPromoRecMap.containsKey(promo.Eligible_Product__c)) {
                                                    if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__r.ParentId)){
                                                        //if(opportunityList[0].Order_Type_Clone__c   == 'Contract - Renewal' && opportunityList[0].account.VIP__c == true && opportunityList[0].account.Approval_Status__c.containsIgnoreCase('Approved')){
                                                        String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__r.ParentId).Status;
                                                        if((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1){
                                                            promoList = prodIdVsPromoRecMap.get(promo.Eligible_Product__c);
                                                            promoList.add(promo);
                                                            prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                        }
                                                        //}
                                                    }else if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__c)){
                                                        String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__c).Status;
                                                        if((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1){
                                                            promoList = prodIdVsPromoRecMap.get(promo.Eligible_Product__c);
                                                            promoList.add(promo);
                                                            prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                        }
                                                        
                                                    }
                                                    
                                                    
                                                }
                                                else {
                                                    
                                                    if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__r.ParentId)){
                                                        //if(opportunityList[0].Order_Type_Clone__c   == 'Contract - Renewal' && opportunityList[0].account.VIP__c == true && opportunityList[0].account.Approval_Status__c.containsIgnoreCase('Approved')){
                                                        String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__r.ParentId).Status;
                                                        if((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1){
                                                            promoList = new list<Promo_Mechanic__c>();
                                                            promoList.add(promo);
                                                            prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                        }
                                                        
                                                        
                                                        //}
                                                    }else if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__c)){
                                                        String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__c).Status;
                                                        if(((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1) && cmStatus != 'Revoked'){
                                                            promoList = new list<Promo_Mechanic__c>();
                                                            promoList.add(promo);
                                                            prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                        }
                                                    }
                                                }
                                                
                                            }
            wrapper.defaultProdIdVsPromoRecMap = prodIdVsPromoRecMap;
            prodIdVsPromoRecMap = new Map<String, List<Promo_Mechanic__c>>();
            /*for(Promo_Mechanic__c promo : [select Id, Name,Denomination__c ,Opportunity_Type__c, Eligible_Product__c,Discount_Reason__c, CurrencyIsoCode,Campaign_Eligibility__c,Campaign_Eligibility__r.Name,Usage__c,Renewal_Type__c,
Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.Name,Campaign_Eligibility__r.Campaign__r.ParentId,Max_Qty__c,Min_Qty__c,
(select id, name,Discount__c, Discounted_amt__c,Entitlement_Product__c,Entitlement_Product__r.Name,Quantity__c, CurrencyIsoCode,
Promo_Mechanic__c from Entitlement_Product__r),(SELECT Id, Name, Exclusion_Product__c FROM Exclusion_Product__r) from Promo_Mechanic__c where Eligible_Product__c IN :oliProdIdList AND (Campaign_Eligibility__r.Campaign__r.ParentId IN : campaignIdVsCM.keySet() OR Campaign_Eligibility__r.Campaign__c IN : campaignIdVsCM.keySet())]) {*/
            for(Promo_Mechanic__c promo : [select Id, Name,Denomination__c ,Opportunity_Type__c, Eligible_Product__c,Discount_Reason__c, CurrencyIsoCode,Campaign_Eligibility__c,Campaign_Eligibility__r.Name,Usage__c,Renewal_Type__c,
                                           Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.Name,Campaign_Eligibility__r.Campaign__r.ParentId,Max_Qty__c,Min_Qty__c,
                                           (select id, name,Discount__c, Discounted_amt__c,Discount_per_unit__c,Entitlement_Product__c,Entitlement_Product__r.Name,Quantity__c, CurrencyIsoCode,Duration__c,Duration_Term__c,Is_Promo_Start_Date_Editable__c,Entitlement_Product__r.CustItem_Validity_Value__c,Entitlement_Product__r.CustItem_Validity_Unit__c,
                                            Promo_Mechanic__c from Entitlement_Product__r), Override_Duration_Unit__c, Override_End_Date__c, Override_Duration_Value__c from Promo_Mechanic__c where Eligible_Product__c IN :oliProdIdList AND (Campaign_Eligibility__r.Campaign__r.ParentId IN : campaignIdVsCM.keySet() OR Campaign_Eligibility__r.Campaign__c IN : campaignIdVsCM.keySet()) AND Status__c = 'Active']) {
                                                /*for(Excluded_Promotion__c ep : promo.Exclusion_Product__r){
if(mapOfPromoIdVSSetOfProductSetIds.containsKey(ep.Exclusion_Product__c)){
mapOfPromoIdVSSetOfProductSetIds.get(promo.Id).add(ep.Exclusion_Product__c);
}else
mapOfPromoIdVSSetOfProductSetIds.put(promo.Id,new List<Id>{ep.Exclusion_Product__c});
}*/
                                                if(prodIdVsPromoRecMap.containsKey(promo.Eligible_Product__c)) {
                                                    
                                                    if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__r.ParentId)){
                                                        //if(opportunityList[0].Order_Type_Clone__c   == 'Contract - Renewal' && opportunityList[0].account.VIP__c == true && opportunityList[0].account.Approval_Status__c.containsIgnoreCase('Approved')){
                                                        String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__r.ParentId).Status;
                                                        if((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1){
                                                            
                                                            promoList = prodIdVsPromoRecMap.get(promo.Eligible_Product__c);
                                                            promoList.add(promo);
                                                            prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                        }
                                                        //}
                                                    }else if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__c)){
                                                        String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__c).Status;
                                                        if((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1){
                                                            promoList = prodIdVsPromoRecMap.get(promo.Eligible_Product__c);
                                                            promoList.add(promo);
                                                            prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                        }
                                                    }
                                                    
                                                    
                                                }
                                                else {
                                                    
                                                    if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__r.ParentId)){
                                                        //if(opportunityList[0].Order_Type_Clone__c   == 'Contract - Renewal' && opportunityList[0].account.VIP__c == true && opportunityList[0].account.Approval_Status__c.containsIgnoreCase('Approved')){
                                                        String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__r.ParentId).Status;
                                                        if((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1){
                                                            promoList = new list<Promo_Mechanic__c>();
                                                            promoList.add(promo);
                                                            prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                        }
                                                        //}
                                                    }else if(campaignIdVsCM.containsKey(promo.Campaign_Eligibility__r.Campaign__c)){
                                                        String cmStatus = campaignIdVsCM.get(promo.Campaign_Eligibility__r.Campaign__c).Status;
                                                        if((cmStatus == 'Approved' || cmStatus == 'Eligible' || cmStatus == 'Re-eligible')||promo.Usage__c == -1){
                                                            promoList = new list<Promo_Mechanic__c>();
                                                            promoList.add(promo);
                                                            prodIdVsPromoRecMap.put(promo.Eligible_Product__c, promoList);
                                                        }
                                                    }
                                                }
                                            }
            
        }
        wrapper.oliList = oliList;
        wrapper.qliList = qliList;
        wrapper.prodIdVsPromoRecMap = prodIdVsPromoRecMap;
        wrapper.mapOfPromoIdVSSetOfProductIds = mapOfPromoIdVSSetOfProductSetIds;
        return wrapper;
    }
    @AuraEnabled
    public static void saveOliData(String oppId, List<OpportunityLineItem> oliRec) {
        List<String> oliIdList = new List<String>();        
        List<OpportunityLineItem> insertOliList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> deleteOliList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> updateOliList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> childOliList = new List<OpportunityLineItem>();
        list<OpportunityLineItem> listOppLineApex = new List<OpportunityLineItem>();
        List<String> oliPromoIdList = new List<String>();
        List<OpportunityLineItem> insertChildOliList = new List<OpportunityLineItem>();
        Map<String, OpportunityLineItem> existingOliMap = new  Map<String, OpportunityLineItem>();
        decimal counter;
        map<string, decimal> mapCounter = new map<string, decimal>();
        list<string> listParentId = new list<string>();
        mapCounter.put('', 0);
        For(OpportunityLineItem oli : [select Id,OpportunityId,Product2Id,Product2.Name, ListPrice,Promo_Mechanic_Id__c, Quantity, Discount, Discount_Reason__c, Campaign__r.Name from 
                                       OpportunityLineItem where OpportunityId = :oppId ]) 
            existingOliMap.put(oli.Id, oli); 
        for(OpportunityLineItem oliVar : oliRec) {
            
            // -1927-
            oliVar.Campaign__r = null;
            
            if(oliVar.Discount_Amount__c == 0) oliVar.Discount_Amount__c = null;
            if(oliVar.Discount__c == 0) oliVar.Discount__c = null;
            if(oliVar.Discount_Amount__c == null && oliVar.Discount__c == null) oliVar.Discount_Amount__c = 0;
            
            listOppLineApex.add(oliVar);
            oliVar.Product2 = null;
            if (oliVar.Parent__c!=null) {
                oliVar.Parent__c = string.valueOf(oliVar.Parent__c);
            }
            if(String.isBlank(oliVar.Id)) {
                if(String.isBlank(oliVar.Parent_Id__c) ) {
                    OpportunityLineItem oli = new OpportunityLineItem();
                    oli = oliVar;
                    insertOliList.add(oli);
                }
                else{
                    childOliList.add(oliVar);   
                }
            }
            else if(String.isNotBlank(oliVar.Id)) {
                oliIdList.add(oliVar.Id);
                OpportunityLineItem oli = new OpportunityLineItem();
                oli.Id = oliVar.Id;
                oli = oliVar;
                
                if(oliVar.Campaign__c == null)
                    oli.Campaign__c = null;
                if(oliVar.Discount_Amount__c == null)
                    oli.Discount_Amount__c = null;
                if(oliVar.Discount__c == null)
                    oli.Discount__c = 0;
                if(oliVar.Parent_Id__c == null)
                    oli.Parent_Id__c = null;
                if(oliVar.Promo_Mechanic_Id__c == null)
                    oli.Promo_Mechanic_Id__c = null;
                if(oliVar.Discount_Reason__c == null)
                    oli.Discount_Reason__c = '';
                //oli.UnitPrice = oliVar.ListPrice;
                mapCounter.put(oliVar.Id, oliVar.SNo__c);
                updateOliList.add(oli); 
            } 
        }
        for(String key:existingOliMap.keySet()) {
            if(!oliIdList.contains(key))
                deleteOliList.add(existingOliMap.get(key));
        }
        if(!insertOliList.isEmpty())
            insert insertOliList;
        if(!updateOliList.isEmpty())
            update updateOliList;
        if(!deleteOliList.isEmpty())
            delete deleteOliList;
        for(OpportunityLineItem insertedOli : insertOliList){
            if(String.isNotBlank(insertedOli.id))
                oliPromoIdList.add(insertedOli.id);
        }
        
        
        for(OpportunityLineItem childOli : childOliList) {
            if(oliPromoIdList.contains(childOli.Parent_Id__c)) {
                Integer index = oliPromoIdList.indexOf(childOli.Parent_Id__c);
                childOli.Parent_Id__c = insertOliList.get(oliPromoIdList.indexOf(childOli.Parent_Id__c)).Id;
                OpportunityLineItem oli = new OpportunityLineItem();
                oli = childOli;
                insertChildOliList.add(childOli);
                insertOliList.remove(index);
            }
            else{
                insertChildOliList.add(childOli);
            }
        }
        if(!insertChildOliList.isEmpty())
            insert insertChildOliList;
        //SNO work starts from here
        
        List<AggregateResult> listAggResults =[select Parent__c, Discount_Reason__c, MAX(SNo__c) maxCount from OpportunityLineItem where OpportunityId=:oppId group by Parent__c, Discount_Reason__c order by Parent__c];
        if(listAggResults !=null && listAggResults.size() >0) {
            for (AggregateResult aggRow: listAggResults) {
                counter = string.valueOf(aggRow.get('maxCount'))==null?0:decimal.valueOf(string.valueOf(aggRow.get('maxCount')));
                // Checkpoint 26112018: need further test on multiple scenario to populate SNo (bonus item/child item)
                mapCounter.put(((string.valueOf(aggRow.get('Parent__c'))==null||(string.valueOf(aggRow.get('Discount_Reason__c'))=='Marketing Promo' || string.valueOf(aggRow.get('Discount_Reason__c'))=='Renewal Bonus'))?'':string.valueOf(aggRow.get('Parent__c'))), counter);
                if (string.valueOf(aggRow.get('Parent__c'))!=null && (string.valueOf(aggRow.get('Discount_Reason__c'))=='Marketing Promo' || string.valueOf(aggRow.get('Discount_Reason__c'))=='Renewal Bonus'))
                    listParentId.add(string.valueOf(aggRow.get('Parent__c')));
            }
        }
        if (listParentId.size() > 0) {
            // Need to do re-query for any line item which has bonus item. Because bonus item has a separate SNo, unlike child item. This re-query is to get the child item SNo (if any)
            listAggResults =[select Parent__c, Discount_Reason__c, MAX(SNo__c) maxCount from OpportunityLineItem where OpportunityId=:oppId and Parent__c in :listParentId and (Discount_Reason__c!='Marketing Promo' OR Discount_Reason__c!='Renewal Bonus') group by Parent__c, Discount_Reason__c order by Parent__c];
            for (AggregateResult aggRow: listAggResults) {
                counter = string.valueOf(aggRow.get('maxCount'))==null?0:decimal.valueOf(string.valueOf(aggRow.get('maxCount')));
                mapCounter.put(string.valueOf(aggRow.get('Parent__c')), counter);
            }
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
                row.SNo__c = mapCounter.get(row.Parent__c)+0.01;
                
                mapCounter.put(row.Parent__c, row.SNo__c);
                listOppLineNeedUpdate.add(row);
            }
        }
        if(!listOppLineNeedUpdate.isEmpty())
            Update listOppLineNeedUpdate;
    }
    @AuraEnabled
    public static List<String> getPickListValue(String objectName,String fieldName){
        
        List<String> optionsList = new List<String>();
        Map<String,Schema.SObjectType> getAllObj = Schema.getGlobalDescribe();
        Map<String,Schema.SObjectField> getObj = getAllObj.get(objectName).getDescribe().fields.getMap();
        List<Schema.PicklistEntry> pickList = getObj.get(fieldName).getDescribe().getPickListValues();
        for(Schema.PicklistEntry pk : pickList){
            optionsList.add(pk.getValue());
        }
        return optionsList;
    }
    @AuraEnabled
    public static list<sObject> getListData(string idx, string namex, string objectx) {
        list<sObject> listObject = database.query('select '+idx+', '+namex+' from '+objectx);
        return listObject;
    }
    @AuraEnabled
    public static list<DiscountInfo> getListEligiblePromotion(Opportunity oppObj) {
        list<DiscountInfo> listResult = new list<DiscountInfo>();
        //getDiscountInfo(oppObj, listResult);
        
        //getTierPricingInfo(listResult, oppObj.Country__c);
        
        return listResult;
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
    /*
@AuraEnabled
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
}*/
    /* @AuraEnabled
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
    @AuraEnabled
    public static list<OppLineItemTmp> getChild(string priceBookId, string parentProductId) {
        list<OppLineItemTmp> listOppLineItem = new list<OppLineItemTmp>();
        list<String> listChildProdWithSeqNo=new list<String>();
        map<string, Item_Bundle__c> mapItemBundle = new map<string, Item_Bundle__c>();
        list<Item_Bundle__c> listItemBundle = [select Parent_Product__c,Parent_Product__r.SKU_Code__c, Child_Product__c, Qty__c,Sno__c, Upload_Tag__c from Item_Bundle__c where Parent_Product__c=:parentProductId order By Sno__c ASC];
        for (Item_Bundle__c row: listItemBundle) {
            mapItemBundle.put(row.Child_Product__c, row);
            listChildProdWithSeqNo.add(row.Sno__c+'_'+row.Child_Product__c);
        }
        listChildProdWithSeqNo.sort();
        list<PricebookEntry> listPricebookEntry = [select Id, Name, UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.Product_Category__c, Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.CurrencyIsoCode, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c from PricebookEntry where Pricebook2Id=:priceBookId and Product2.IsActive=true and IsActive=true and Product2Id in :mapItemBundle.keySet()];
        Map<Id,PricebookEntry> mapOfProductWithPbe=new Map<Id,PricebookEntry>();
        for(PricebookEntry eachPbe: listPricebookEntry){
            mapOfProductWithPbe.put(eachPbe.Product2.Id,eachPbe);
        }
        for (String each: listChildProdWithSeqNo){
            PricebookEntry row=mapOfProductWithPbe.get(each.substringAfter('_'));
            if(mapOfProductWithPbe.containskey(each.substringAfter('_'))){
                if (row.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode && row.Product2.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode) {
                    oppLineItemTmpAssignment(row, listOppLineItem, integer.valueOf(mapItemBundle.get(row.Product2.Id).Qty__c), parentProductId, false);
                }
            }
        }
        return listOppLineItem;
    }
    private static void oppLineItemTmpAssignment(PricebookEntry row, list<OppLineItemTmp> listOppLineItem, integer qty, string parentProductId, boolean IsSeparate) {
        
        Product2 parentProduct = [SELECT Id,SKU_Code__c FROM Product2 WHERE Id =:parentProductId];
        String skuCodeOfAdvancePlus = System.Label.SKU_CODE_ADVANCE_PLUS;
        String skuCodeOfMonthlyAC = System.Label.SKU_CODE_MONTHLY_AC;
        if(row.Product2.SKU_Code__c == skuCodeOfMonthlyAC && parentProduct.SKU_Code__c == skuCodeOfAdvancePlus) {
            for(Integer i= 1;i<=12;i++){
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
                oppLineItem.Quantity = qty/12;
                oppLineItem.Parent = parentProductId;
                oppLineItem.IsSeparate = IsSeparate;
                listOppLineItem.add(oppLineItem);
            }
        } else {
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
        
    }
    
    @AuraEnabled
    public static void saveQliData(String quoteId, List<QuoteLineItem> qliRec,String priceBookId,String quoteCurrency) {
        
        List<String> prodId = new List<String>();
        for(QuoteLineItem q:qliRec ){
            prodId.add(q.product2id);
        }
        List<String> qliIdList = new List<String>();
        List<QuoteLineItem> insertQliList = new List<QuoteLineItem>();
        List<QuoteLineItem> deleteQliList = new List<QuoteLineItem>();
        List<QuoteLineItem> updateQliList = new List<QuoteLineItem>();
        List<QuoteLineItem> childQliList = new List<QuoteLineItem>();
        list<QuoteLineItem> listQuoteLineApex = new List<QuoteLineItem>();
        List<String> qliPromoIdList = new List<String>();
        List<QuoteLineItem> insertchildQliList = new List<QuoteLineItem>();
        Map<String, QuoteLineItem> existingQliMap = new  Map<String, QuoteLineItem>();
        decimal counter;
        Decimal latestSNo;
        map<string, decimal> mapCounter = new map<string, decimal>();
        list<string> listParentId = new list<string>();
        mapCounter.put('', 0);
        For(QuoteLineItem qli : [select Id,QuoteId,Product2Id,Product2.Name, ListPrice,Promo_Mechanic_Id__c, Quantity, Discount, Discount_Reason__c, Campaign__r.Name from 
                                 QuoteLineItem where QuoteId = :quoteId ]) 
            existingQliMap.put(qli.Id, qli); 
        for(QuoteLineItem qliVar : qliRec) {
            // -1927-
            qliVar.Campaign__r = null;
            
            if(qliVar.Discount_Amount__c == 0) qliVar.Discount_Amount__c = null;
            if(qliVar.Discount__c == 0) qliVar.Discount__c = null;
            if(qliVar.Discount_Amount__c == null && qliVar.Discount__c == null) qliVar.Discount_Amount__c = 0;
            
            listQuoteLineApex.add(qliVar);
            qliVar.Product2 = null;
            if (qliVar.Parent__c!=null) {
                qliVar.Parent__c = string.valueOf(qliVar.Parent__c);
            }
            if(String.isBlank(qliVar.Id)) {
                if(String.isBlank(qliVar.Parent_Id__c) ) {
                    QuoteLineItem qli = new QuoteLineItem();
                    qli = qliVar;
                    insertQliList.add(qli);
                }
                else{
                    childQliList.add(qliVar);   
                }
            }
            else if(String.isNotBlank(qliVar.Id)) {
                qliIdList.add(qliVar.Id);
                QuoteLineItem qli = new QuoteLineItem();
                qli.Id = qliVar.Id;
                qli = qliVar;
                
                if(qliVar.Campaign__c == null)
                    qli.Campaign__c = null;
                if(qliVar.Discount_Amount__c == null)
                    qli.Discount_Amount__c = null;
                if(qliVar.Discount__c == null)
                    qli.Discount__c = 0;
                if(qliVar.Parent_Id__c == null)
                    qli.Parent_Id__c = null;
                if(qliVar.Promo_Mechanic_Id__c == null)
                    qli.Promo_Mechanic_Id__c = null;
                if(qliVar.Discount_Reason__c == null)
                    qli.Discount_Reason__c = '';
                qli.Quantity = qlivar.Quantity;
                //qli.UnitPrice = qliVar.ListPrice;
                mapCounter.put(qliVar.Id, qliVar.SNo__c);
                updateQliList.add(qli); 
            } 
        }
        for(String key:existingqliMap.keySet()) {
            if(!qliIdList.contains(key))
                deleteQliList.add(existingqliMap.get(key));
        }
        if(!insertQliList.isEmpty())
            insert insertQliList;
        if(!updateQliList.isEmpty())
            update updateQliList;
        if(!deleteQliList.isEmpty())
            delete deleteQliList;
        for(QuoteLineItem insertedqli : insertQliList){
            if(String.isNotBlank(insertedqli.id))
                qliPromoIdList.add(insertedqli.id);
        }
        
        map<String,String> priceBookEntryProd = new  map<String,String>();
        for (PricebookEntry row: [select Id, Name, Product2Id from PricebookEntry 
                                  where Product2Id in :prodId and Product2.IsActive=true and pricebook2id=: priceBookid 
                                  and currencyIsoCode=:quoteCurrency]
            ) {
                priceBookEntryProd.put(row.product2id,row.id); 
            }
        for(QuoteLineItem childqli : childQliList) {
            if(qliPromoIdList.contains(childqli.Parent_Id__c)) {
                Integer index = qliPromoIdList.indexOf(childqli.Parent_Id__c);
                childqli.Parent_Id__c = insertQliList.get(qliPromoIdList.indexOf(childqli.Parent_Id__c)).Id;
                QuoteLineItem qli = new QuoteLineItem();
                //qli.PricebookEntryId = childqli.PricebookEntryId;
                qli = childqli;
                qli.PricebookEntryId=priceBookEntryProd.get(childqli.product2id);
                qli.product2id=childqli.product2ID;
                insertchildQliList.add(qli);
                insertQliList.remove(index);
            }
            else{
                QuoteLineItem qli = new QuoteLineItem();
                qli = childqli;
                qli.PricebookEntryId=priceBookEntryProd.get(childqli.product2id);
                qli.product2id=childqli.product2ID;
                insertchildQliList.add(qli);
            }
        }
        if(!insertchildQliList.isEmpty())
            insert insertchildQliList;
        //SNO work starts from here
        List<QuoteLineItem> qliRecordList = new List<QuoteLineItem>([SELECT Id,SNo__c FROM QuoteLineItem WHERE QuoteId = :quoteId AND SNo__c != null ORDER BY SNo__c DESC LIMIT 1]);
        //qliRecordList = [SELECT Id,SNo__c FROM QuoteLineItem WHERE QuoteId = :quoteId AND SNo__c != null ORDER BY SNo__c DESC LIMIT 1];
        if(qliRecordList.size() == 0) {
            System.Debug('Inside 1###');
            latestSNo = 0.0;
        }
        else if(qliRecordList.size() > 0 && qliRecordList[0].SNo__c == null){
            System.Debug('Inside 2###');
            latestSNo = 0.0;
        }
        else {
            System.Debug('Inside 3###');
            latestSNo = qliRecordList[0].SNo__c;
        }
        List<AggregateResult> listAggResults =[select Parent__c, Discount_Reason__c, MAX(SNo__c) maxCount from QuoteLineItem where QuoteId=:quoteId group by Parent__c, Discount_Reason__c order by Parent__c];
        if(listAggResults !=null && listAggResults.size() >0) {
            for (AggregateResult aggRow: listAggResults) {
                counter = string.valueOf(aggRow.get('maxCount'))==null?0:decimal.valueOf(string.valueOf(aggRow.get('maxCount')));
                // Checkpoint 26112018: need further test on multiple scenario to populate SNo (bonus item/child item)
                mapCounter.put(((string.valueOf(aggRow.get('Parent__c'))==null||(string.valueOf(aggRow.get('Discount_Reason__c'))=='Marketing Promo' || string.valueOf(aggRow.get('Discount_Reason__c'))=='Renewal Bonus'))?'':string.valueOf(aggRow.get('Parent__c'))), counter);
                if (string.valueOf(aggRow.get('Parent__c'))!=null && (string.valueOf(aggRow.get('Discount_Reason__c'))=='Marketing Promo' || string.valueOf(aggRow.get('Discount_Reason__c'))=='Renewal Bonus'))
                    listParentId.add(string.valueOf(aggRow.get('Parent__c')));
            }
        }
        if (listParentId.size() > 0) {
            // Need to do re-query for any line item which has bonus item. Because bonus item has a separate SNo, unlike child item. This re-query is to get the child item SNo (if any)
            listAggResults =[select Parent__c, Discount_Reason__c, MAX(SNo__c) maxCount from QuoteLineItem where QuoteId=:quoteId and Parent__c in :listParentId and (Discount_Reason__c!='Marketing Promo' OR Discount_Reason__c!='Renewal Bonus') group by Parent__c, Discount_Reason__c order by Parent__c];
            for (AggregateResult aggRow: listAggResults) {
                counter = string.valueOf(aggRow.get('maxCount'))==null?0:decimal.valueOf(string.valueOf(aggRow.get('maxCount')));
                mapCounter.put(string.valueOf(aggRow.get('Parent__c')), counter);
            }
        }
        list<QuoteLineItem> listQuoteLineNeedUpdate = new list<QuoteLineItem>();
        for (QuoteLineItem row: listQuoteLineApex) {
            if (!string.isBlank(row.Parent__c) && row.Parent__c.isNumeric()) {
                row.Parent__c = listQuoteLineApex.get(integer.valueOf(row.Parent__c)).Id;
            }
            if (row.Parent__c==null && row.SNo__c==null || (row.Parent__c!=null && row.SNo__c==null && (row.Discount_Reason__c=='Marketing Promo' || row.Discount_Reason__c=='Renewal Bonus'))) {
                /*
* Parent Item Line
*/
                row.SNo__c = Math.floor(latestSNo + 1);
                mapCounter.put(row.Id, row.SNo__c);
                mapCounter.put('', row.SNo__c);
                listQuoteLineNeedUpdate.add(row);
                latestSNo = row.SNo__c;
            } else if (row.Parent__c!=null && row.SNo__c==null) {
/*
* Child Item Line
*/
                row.SNo__c = mapCounter.get(row.Parent__c)+0.01;
                
                mapCounter.put(row.Parent__c, row.SNo__c);
                listQuoteLineNeedUpdate.add(row);
            }
        }
        if(!listQuoteLineNeedUpdate.isEmpty())
            Update listQuoteLineNeedUpdate;
    }
    @AuraEnabled
    public static Map<decimal,Map<String,PriceBookEntry>> getRenewalOptions(String quoteID){
        Map<String,Decimal> levelRuleMap = new Map<String,Decimal>();
        //  Map<String,String> UpgSkuMap = new Map<String,String>(); 
        Map<String,String> renSkuMap = new Map<String,String>(); 
        Map<String,String> revisedSkuMap = new Map<String,String>(); 
        Map<decimal,Map<String,PriceBookEntry>> mapReturnPBE = new   Map<decimal,Map<String,PriceBookEntry>>();
        Date renSameTierUpgradeDate = Date.valueOf(System.Label.RENEW_SAME_TIER_UPGRADE_DATE);
        
        Quote quoteObj = [select id,Account.Account_Rule_Code__c,Account.Subscription_End_Date__c,Account.Previous_Account_Rule__c,Account.Country__c,CurrencyIsoCode,Pricebook2id from Quote where id =: quoteID];
        
        List<Upgrade_Package_Lookup__c> upgPkgList = [Select Country__c,Level__c,Name, Renewal_SKU__c,Upgrade_SKU__c,Renewal_Type__c,IsActive__c 
                                                      from Upgrade_Package_Lookup__c where  Country__c =: quoteObj.Account.Country__c
                                                      order by Level__c];
        for(Upgrade_Package_Lookup__c upgPkg: upgPkgList){
            
            String name;
            if(quoteObj.Account.Country__c == 'Singapore'){
                name=upgPkg.Name.replace('- SG','').trim();
            }
            else if(quoteObj.Account.Country__c == 'Malaysia'){
                name=upgPkg.Name.replace('- MY','').trim();
            }
            else if(quoteObj.Account.Country__c == 'Thailand'){
                name=upgPkg.Name.replace('- TH','').trim();
            }
          levelRuleMap.put(name.toLowerCase(),upgPkg.level__c);
            if(upgPkg.IsActive__c){
                renSkuMap.put(upgPkg.Renewal_SKU__c,name.toLowerCase());
            }
        }
      
          for (PricebookEntry row:[select Id, Name, UnitPrice, Pricebook2Id, Product2Id, Product2.Name, Product2.Product_Type__c, Product2.Description,Product2.Revised_Product__r.SKU_Code__c, 
                                     Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.Product_Category__c, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, 
                                     Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c,Product2.CustItem_Validity_Value__c,Product2.CustItem_Validity_Unit__c from PricebookEntry where 
                                     Pricebook2Id=: quoteObj.Pricebook2id and CurrencyIsoCode=: quoteObj.CurrencyIsoCode and Product2.CurrencyIsoCode=:quoteObj.CurrencyIsoCode and 
                                     Product2.IsActive=true and IsActive=true and 
                                     //Product2.Segment__c = 'B2C Only' and 
                                     Product2.Segment__c in ('B2C Only', 'B2B & B2C') 
                                     and Product2.Can_Be_Sold_Stand_Alone__c=true 
                                     and (Product2.SKU_Code__c in: renSkuMap.keySet()) and Product2.Revised_Product__c!=null]){
                                         String name = row.Product2.Name.replace('PGSG Package : ','');
                                         name = name.replace('NEW','');
                                         name = name.replace(' (12 Mths)','');
                                         revisedSkuMap.put(row.Product2.Revised_Product__r.SKU_Code__c,name.toLowerCase());      
                                     }
        
        
        Decimal currentLevel;
        if(quoteObj.Account.Account_Rule_Code__c.toLowerCase() == 'trial' && quoteObj.Account.Country__c == 'Singapore'){
            currentLevel = levelRuleMap.get(quoteObj.Account.Previous_Account_Rule__c.toLowerCase());
        }
        else{
            currentLevel = levelRuleMap.get(quoteObj.Account.Account_Rule_Code__c.toLowerCase());
        }
        for (PricebookEntry row:[select Id, Name, UnitPrice, Pricebook2Id, Product2Id, Product2.Name, Product2.Product_Type__c, Product2.Description,Product2.Effective_till__c,Product2.Revised_Product__r.SKU_Code__c,
                                 Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.Product_Category__c, CurrencyIsoCode, Pricebook2.CurrencyIsoCode,Product2.Revised_Product__c,
                                 Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c,Product2.CustItem_Validity_Value__c,Product2.CustItem_Validity_Unit__c from PricebookEntry where 
                                 Pricebook2Id=: quoteObj.Pricebook2id and CurrencyIsoCode=: quoteObj.CurrencyIsoCode and Product2.CurrencyIsoCode=:quoteObj.CurrencyIsoCode and 
                                 Product2.IsActive=true and IsActive=true and 
                                 //Product2.Segment__c = 'B2C Only' and 
                                 Product2.Segment__c in ('B2C Only', 'B2B & B2C') 
                                 and Product2.Can_Be_Sold_Stand_Alone__c=true 
                                 and (Product2.SKU_Code__c in: renSkuMap.keySet() or Product2.SKU_Code__c in: revisedSkuMap.keySet())
                                 order by Product2.SKU_Code__c  limit 100]){
                                     Decimal rowLevel;
                                     Decimal rowlevelCurr;
                                     Map<String,PriceBookEntry> mapPBE = new Map<String,PriceBookEntry>(); 
                                     if(renSkuMap.containskey(row.Product2.SKU_Code__c)){            
                                         rowLevel=levelRuleMap.get(renSkuMap.get(row.Product2.SKU_Code__c));
                                         rowlevelCurr=levelRuleMap.get(renSkuMap.get(row.Product2.SKU_Code__c));
                                     }else{
                                         rowLevel=levelRuleMap.get(revisedSkuMap.get(row.Product2.SKU_Code__c));
                                         rowlevelCurr=levelRuleMap.get(revisedSkuMap.get(row.Product2.SKU_Code__c));
                                         
                                     }
                                   
                                     Date currentDate = date.newInstance(System.today().year(),System.today().month(),System.today().day());
                                    
                                     if(rowLevel < currentLevel){//downgrade
                                         if(row.Product2.Effective_till__c ==null || row.Product2.Revised_Product__c==null){  
                                             if(renSkuMap.containskey(row.Product2.SKU_Code__c)){    
                                                 if(quoteObj.Account.Account_Rule_Code__c == SYSTEM.LABEL.ADVANCEPLUS_RENEW_EXCEPTION && row.Product2.Name.containsIgnoreCase(SYSTEM.LABEL.ADVANCE_RENEW_EXCEPTION) == true){
                                                     
                                                 }else{
                                                     if(quoteObj.Account.Account_Rule_Code__c == SYSTEM.LABEL.ADVANCEPLUS_RENEW_EXCEPTION && row.Product2.Name.containsIgnoreCase(SYSTEM.LABEL.SG_STANDARD_PACKAGE) == true) {
                                                         //throw new AuraHandledException('If you are downgrading from Advance Plus Package ,you would not able to Upgrade to Advance Plus in future');
                                                     }
                                                     mapPBE.put('Downgrade to '+renSkuMap.get(row.Product2.SKU_Code__c).toUpperCase(),row);
                                                 }
                                             }else{   
                                                 mapPBE.put('Downgrade to '+revisedSkuMap.get(row.Product2.SKU_Code__c).toUpperCase(),row); 
                                             }
                                         } else if(row.Product2.Revised_Product__c!=null && currentDate < row.Product2.Effective_till__c && renSkuMap.containskey(row.Product2.SKU_Code__c)) {
                                             mapPBE.put('Downgrade to '+renSkuMap.get(row.Product2.SKU_Code__c).toUpperCase(),row);
                                         }
                                         if(!mapPBE.isEmpty() && !mapReturnPBE.containsKey(rowLevel)) {
                                             mapReturnPBE.put(rowLevel,mapPBE); 
                                         }
                                     }
                                     else if(rowlevelCurr == currentLevel){//same tier
                                         list<String> Penny_Alpha_Renew_Exceptions = System.Label.Penny_Alpha_Renew_Exceptions.split(';');
                                        if(row.Product2.Effective_till__c ==null || row.Product2.Revised_Product__c==null){
                                             if(renSkuMap.containskey(row.Product2.SKU_Code__c)){  
                                                 mapPBE.put('Renew '+renSkuMap.get(row.Product2.SKU_Code__c).toUpperCase(),row);
                                             }else{
                                                 if(!Penny_Alpha_Renew_Exceptions.contains(revisedSkuMap.get(row.Product2.SKU_Code__c))){
                                                     mapPBE.put('Renew '+revisedSkuMap.get(row.Product2.SKU_Code__c).toUpperCase(),row);
                                                 }
                                             }
                                             
                                         }else if(row.Product2.Revised_Product__c != null && 
                                                  ((currentDate <= renSameTierUpgradeDate && quoteObj.Account.Subscription_End_Date__c.month() == Date.today().Month() 
                                                     && quoteObj.Account.Subscription_End_Date__c.Year() == Date.today().Year()) ||
                                                    (currentDate < row.Product2.Effective_till__c && quoteObj.Account.Subscription_End_Date__c.month() == Date.today().addMonths(1).Month() 
                                                     && quoteObj.Account.Subscription_End_Date__c.Year() == Date.today().Year()))
                                                     && renSkuMap.containskey(row.Product2.SKU_Code__c) ){
                                                        mapPBE.put('Renew '+renSkuMap.get(row.Product2.SKU_Code__c).toUpperCase(),row);
                                         }
                                         
                                         if(!mapPBE.isEmpty() && !mapReturnPBE.containsKey(rowlevelCurr)) {
                                             mapReturnPBE.put(rowlevelCurr,mapPBE); 
                                         }
                                     }
                                  else if(rowlevelCurr > currentLevel){//upgrade
                                        
                                      if(row.Product2.Effective_till__c ==null || row.Product2.Revised_Product__c==null){ 
                                          if(renSkuMap.containskey(row.Product2.SKU_Code__c)){
                                              if(row.Product2.SKU_Code__c ==SYSTEM.LABEL.SKU_CODE_ADVANCE_PLUS && 
                                                 quoteObj.Account.Account_Rule_Code__c.toLowerCase() == SYSTEM.LABEL.ADVANCE_RENEW_EXCEPTION.toLowerCase()) {
                                                     mapPBE.put('Convert to '+renSkuMap.get(row.Product2.SKU_Code__c).toUpperCase(),row);
                                                 } else {
                                                     mapPBE.put('Upgrade to '+renSkuMap.get(row.Product2.SKU_Code__c).toUpperCase(),row);
                                                 }
                                          }else{
                                              mapPBE.put('Upgrade to '+revisedSkuMap.get(row.Product2.SKU_Code__c).toUpperCase(),row);
                                          } 
                                          
                                      }else if(((currentDate <= renSameTierUpgradeDate && quoteObj.Account.Subscription_End_Date__c.month() == Date.today().Month() 
                                                     && quoteObj.Account.Subscription_End_Date__c.Year() == Date.today().Year()) ||
                                                    (currentDate < row.Product2.Effective_till__c && quoteObj.Account.Subscription_End_Date__c.month() == Date.today().addMonths(1).Month() 
                                                     && quoteObj.Account.Subscription_End_Date__c.Year() == Date.today().Year()))
                                               && row.Product2.Revised_Product__c!=null && renSkuMap.containskey(row.Product2.SKU_Code__c)){
                                          mapPBE.put('Upgrade to '+renSkuMap.get(row.Product2.SKU_Code__c).toUpperCase(),row);
                                      }
                                      
                                      if(!mapPBE.isEmpty() && !mapReturnPBE.containsKey(rowlevelCurr)) {
                                          mapReturnPBE.put(rowlevelCurr,mapPBE); 
                                      }
                                  } 
                                }
        return mapReturnPBE;
    }
    
}