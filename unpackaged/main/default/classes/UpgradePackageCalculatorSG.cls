//Test Class: UpgradePackageCalculatorSG_Test
public class UpgradePackageCalculatorSG {
    
    public class WrapUpgradeSG {
        public integer weekNumber;
        public integer currentWeekUtilized;
        public date startDate; //starts from current week
        public date endDate;
        public string packageName;
        public string packageId;
        public decimal packageAmount;
        public decimal currentProRate;
        public decimal upgradePackageAC;
        public decimal upgradePackagePC;
        public decimal totalAmount; //packageAmount - proRate - additional Discount(if any)
    }
    
    public class WrapResponseSG {
        public decimal previousProRate;
        public integer weekUtilized;
        public integer totalWeeks;
        public decimal currentPackageAC;
        public decimal currentPackagePC;
        public List<wrapUpgradeSG> listForecast;
    }
    
    public static WrapResponseSG getUpgradeForecast(String accId) {
        return getUpgradeForecast(accId, null, null, null);
    }
    
    // Main method to return wrapper for Price Forecast
    public static WrapResponseSG getUpgradeForecast(String accId, List<PricebookEntry> upgradeProdList, Decimal loyaltyPerc,String currentPackageSKUCode) {
        WrapResponseSG wrapResObj = new WrapResponseSG();
        Set<Id> upgradeProductId = new Set<Id>();
        Map<Id,Decimal> mapOfPackageProdIdVsAC = new Map<Id,Decimal>();
        Map<Id,Decimal> mapOfPackageProdIdVsPC = new Map<Id,Decimal>();
        List<wrapUpgradeSG> listPackageForecast = new List<wrapUpgradeSG>();
        String skuCodeOfACProd = System.Label.PRODUCT_SKUCODE_AD_CREDIT;
        String skuCodeOfPCProd = System.Label.PRODUCT_SKUCODE_PRIME_CREDIT;
        
        Account accObj = [select Id, PG_Tenure__c, Name,Account_Rule_Code__c, Status__c,
                          Current_Subscription_Code__c, Subscription_Start_Date__c,
                          Subscription_End_Date__c, Current_Subscription_Spending_Amount__c,
                          Pro_Rate_Amount__c, Country__c, CurrencyIsoCode,Loyalty_Start_Date__c,
                          VIP__c,Approval_Status__c,Account_Previous_Status__c
                          from Account where Id=:accId];
        if(upgradeProdList == null) {
            upgradeProdList = getUpgradeProdList(accObj);
        }
        if(!upgradeProdList.isEmpty()) {
            for(PricebookEntry pbe : upgradeProdList) {
                upgradeProductId.add(pbe.Product2Id);  
            }

            if(!upgradeProductId.isEmpty()) {
                for(Item_Bundle__c CreditProd : [SELECT Child_Product__r.Name,Child_product__r.SKU_Code__c,
                                                   Qty__c,Parent_Product__r.Name,Parent_Product__c,
                                                   Parent_Product__r.SKU_Code__c
                                                   FROM Item_Bundle__c 
                                                   WHERE (Parent_Product__c In: upgradeProductId 
                                                   OR Parent_Product__r.SKU_Code__c =: currentPackageSKUCode)
                                                   AND (Child_product__r.SKU_Code__c =: skuCodeOfACProd
                                                        OR Child_product__r.SKU_Code__c =: skuCodeOfPCProd
                                                       OR Child_product__r.SKU_Code__c  =: SYSTEM.LABEL.SKU_CODE_MONTHLY_AC)]
                   ) {
                       if(CreditProd.Parent_Product__r.SKU_Code__c == currentPackageSKUCode) {
                           if(CreditProd.Child_product__r.SKU_Code__c == skuCodeOfACProd || CreditProd.Child_product__r.SKU_Code__c == SYSTEM.LABEL.SKU_CODE_MONTHLY_AC) {
                                wrapResObj.currentPackageAC = CreditProd.Qty__c;
                           } else {
                                wrapResObj.currentPackagePC = CreditProd.Qty__c;
                           }
                          
                       } else {
                           if(CreditProd.Child_product__r.SKU_Code__c == skuCodeOfACProd || CreditProd.Child_product__r.SKU_Code__c == SYSTEM.LABEL.SKU_CODE_MONTHLY_AC) {
                           mapOfPackageProdIdVsAC.put(CreditProd.Parent_Product__c,CreditProd.Qty__c);
                           } else {
                               mapOfPackageProdIdVsPC.put(CreditProd.Parent_Product__c,CreditProd.Qty__c);
                           }
                       }
                   }
            }
        }
        wrapResObj.previousProRate = accObj.Pro_Rate_Amount__c;
        
        Date nextMonOfSubsStartDate = getNextMonEvenIfItsMon(accObj.Subscription_Start_Date__c);
        
        Date nextMonOfSubsEndDate = getNextMonEvenIfItsMon(accObj.Subscription_End_Date__c);
        
        Integer totalWeekOfSubs = calculateNoOfWeeks(nextMonOfSubsStartDate,nextMonOfSubsEndDate);
        
        wrapResObj.totalWeeks = totalWeekOfSubs;
        
        Date getNextMonOfToday = getNextMonEvenIfItsMon(system.today());
        
        wrapResObj.weekUtilized = calculateNoOfWeeks(nextMonOfSubsStartDate,getNextMonOfToday);
        
        Integer totalNoOfWeeks = calculateNoOfWeeks(getNextMonOfToday,nextMonOfSubsEndDate);
        
        Decimal upgTenure = OpportunityProductRegistrationStinger_cc.CalculateUpgradeTenure(accObj);
        
        if(loyaltyPerc == null) {
            loyaltyPerc =0.00;
            if(
                !accObj.VIP__c && 
                (String.isBlank(accObj.Approval_Status__c) || 
                !accObj.Approval_Status__c.containsIgnoreCase('Approved'))
            ) {
                loyaltyPerc = getLoyaltyDiscountPercentage(upgTenure,accObj.Country__c);
            }
        }
        listPackageForecast = getListWrapUpgradeSG(accObj,upgradeProdList,wrapResObj.weekUtilized,totalNoOfWeeks,loyaltyPerc,totalWeekOfSubs,mapOfPackageProdIdVsAC,mapOfPackageProdIdVsPC);
        wrapResObj.listForecast = listPackageForecast;
        return wrapResObj;
    }
    
    
    // To calculate week end date (refers to Sunday)
    public static Date calculateWeekEndDate(Date startDateOfWeek) {
        Map<String,Integer> weekDayVsNoOfDaysToBeAdded = new Map<String,Integer> {
            'Sun'=> 0,
            'Mon'=> 6,
            'Tue'=> 5,
            'Wed'=> 4,
            'Thu'=> 3,
            'Fri'=> 2,
            'Sat'=> 1 
         };
             
        Datetime weekStartDateTime = DateTime.newInstance(startDateOfWeek.year(), startDateOfWeek.month(), startDateOfWeek.day());
        Integer noOfDaysToBeAdded = weekDayVsNoOfDaysToBeAdded.get(weekStartDateTime.format('EEE'));
        date weekEndDate = Date.newInstance(startDateOfWeek.year(), startDateOfWeek.month(), startDateOfWeek.day()+noOfDaysToBeAdded);
        return weekEndDate;
    }
    
    //To calculate previous Monday if its Not Monday
    @testvisible   
    public static Date getPreviousMonIfItsNotMon(Date startDate) {
        Map<String,Integer> weekDayVsNoOfDaysToBeSubtracted = new Map<String,Integer> {
            'Sun'=> 6,
            'Mon'=> 0,
            'Tue'=> 1,
            'Wed'=> 2,
            'Thu'=> 3,
            'Fri'=> 4,
            'Sat'=> 5 
        };
            
        Datetime startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
        Integer noOfDaysToBeSubtracted = weekDayVsNoOfDaysToBeSubtracted.get(startDateTime.format('EEE'));
        date previousMon = Date.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day()-noOfDaysToBeSubtracted);
        return previousMon;
    }
    
    //To calculate next Monday even if its Monday
    public static Date getNextMonEvenIfItsMon(Date startDate){
        Map<String,Integer> weekDayVsNoOfDaysToBeAdded = new Map<String,Integer> {
            'Sun'=> 1,
            'Mon'=> 7,
            'Tue'=> 6,
            'Wed'=> 5,
            'Thu'=> 4,
            'Fri'=> 3,
            'Sat'=> 2 
        };
                    
        Datetime startDateTime = DateTime.newInstance(startDate.year(), startDate.month(), startDate.day());
        Integer noOfDaysToBeAdded = weekDayVsNoOfDaysToBeAdded.get(startDateTime.format('EEE'));
        date nextMon = Date.newInstance(startDateTime.year(), startDateTime.month(), startDateTime.day()+noOfDaysToBeAdded);  
        return nextMon;
    }
    
    // To calculate number of weeks between two dates
    private static Integer calculateNoOfWeeks(Date startDate, Date endDate) {
        Integer totalNoOfWeeks = ((startDate.daysBetween(endDate))/7);
        return totalNoOfWeeks;
    }
    
    // To calculate weekly data
    private static List<wrapUpgradeSG> getListWrapUpgradeSG(Account accObj,
                                                            List<PricebookEntry> upgradeProdList,
                                                            Integer weekUtilized,
                                                            Integer totalNoOfWeeks,
                                                            Decimal loyaltyDiscPerc,
                                                            Integer totalWeekOfSubs,
                                                            Map<Id,Decimal> mapOfPackageProdIdVsAC,
                                                            Map<Id,Decimal> mapOfPackageProdIdVsPC
    ) { 
        List<wrapUpgradeSG> listPackageForecast = new List<wrapUpgradeSG>();
        Integer totalWeekIncludingLast = totalNoOfWeeks + 1;
        Date nextMonOfSubsEndDate = getNextMonEvenIfItsMon(accObj.Subscription_End_Date__c);
        for(PricebookEntry pbe : upgradeProdList) { 
            Date weekEndDate = null;
            for(integer i=0; i<totalWeekIncludingLast; i++) {
                wrapUpgradeSG packageForecast = new wrapUpgradeSG();
                packageForecast.weekNumber = i;
                if(packageForecast.weekNumber == 0) {
                    packageForecast.startDate = system.today();
                } else {
                    packageForecast.startDate = (weekEndDate.addDays(+1));
                }
                
                packageForecast.endDate = calculateWeekEndDate(packageForecast.startDate);
                if(nextMonOfSubsEndDate < packageForecast.endDate) {
                    break;
                }
                weekEndDate = packageForecast.endDate;
                packageForecast.packageName = pbe.Name;
                packageForecast.packageId = pbe.Id;
                packageForecast.packageAmount = pbe.UnitPrice;
                packageForecast.currentWeekUtilized =  (weekUtilized + i) ; 
                packageForecast.currentProRate = getCurrentProRate(accObj.Current_Subscription_Spending_Amount__c,
                                                                   accObj.Pro_Rate_Amount__c,
                                                                   weekUtilized,
                                                                   totalNoOfWeeks,
                                                                   totalWeekOfSubs,
                                                                   packageForecast.weekNumber);
                if(pbe.Product2.SKU_Code__c == SYSTEM.LABEL.SKU_CODE_ADVANCE_PLUS && accObj.Account_Rule_Code__c == 'ADVANCE') {
                    packageForecast.totalAmount = pbe.UnitPrice;
                } else {
                    packageForecast.totalAmount = pbe.UnitPrice - ((loyaltyDiscPerc*pbe.UnitPrice)/100) - packageForecast.currentProRate;
                }
                
                if(!mapOfPackageProdIdVsAC.isEmpty() && mapOfPackageProdIdVsAC.containsKey(pbe.Product2Id) && !mapOfPackageProdIdVsPC.isEmpty() && mapOfPackageProdIdVsPC.containsKey(pbe.Product2Id)) {
                    packageForecast.upgradePackageAC = mapOfPackageProdIdVsAC.get(pbe.Product2Id);
                    packageForecast.upgradePackagePC = mapOfPackageProdIdVsPC.get(pbe.Product2Id);
                } 
                listPackageForecast.add(packageForecast);                
            }
        }
        return listPackageForecast;
    }
    
    // To calculate Current Pro Rate according to particular week
    private static Decimal getCurrentProRate(Decimal currentSubsSpendingAmt, Decimal proRate,
                                             Integer weekUtilized, Integer totalNoOfWeeks,
                                             Integer totalWeekOfSubs,
                                             Integer weekNo
    ) {
        
        if (proRate == null) {
            proRate = 0.00;
        }
        if(currentSubsSpendingAmt == null) {
            currentSubsSpendingAmt = 0.00;
        }
        Decimal currentSubsPerWeekAmt = ((currentSubsSpendingAmt+proRate)/totalWeekOfSubs);
        Integer currUnutilizedWeek =  (totalWeekOfSubs - weekUtilized) - weekNo;                                        
        Decimal totalCurrProRate =  currentSubsPerWeekAmt*currUnutilizedWeek;
        return totalCurrProRate;                                     
    } 
    
    // To get List of Upgrade Packages available for agent (Main method)
    private static List<PriceBookEntry> getUpgradeProdList(Account accObj) {
        Map<string, Subsidiary__c> subsidiaryMap = new Map<string, Subsidiary__c>();
        List<PricebookEntry> listPricebookEntry = new List<PricebookEntry>();
        User usr = [SELECT Id, CurrencyIsoCode, Subsidiary__c
                    FROM User 
                    WHERE Id=:UserInfo.getUserId() 
                    LIMIT 1
        ];
        Pricebook2 PriceBook = getPricebook(usr, subsidiaryMap); 
        listPricebookEntry = getSubscriptionProd(accObj, usr.CurrencyIsoCode, PriceBook.Id,
                                                 subsidiaryMap.get(usr.Subsidiary__c).Country__c, 'Upgrade_SKU__c');
        return listPricebookEntry;
    }
    
    // To get PriceBook relevant to User's Subsidiary
    private static PriceBook2 getPricebook(User usr, map<string, Subsidiary__c> subsidiaryMap) {
        Pricebook2 pbObj;
        for(Subsidiary__c row: [select Id, Name, Country__c from Subsidiary__c
                                where Name=:usr.Subsidiary__c]
        ) {
            row.Country__c = row.Country__c.toUpperCase();
            subsidiaryMap.put(row.Name, row);
        }
        if (subsidiaryMap.keyset().size() > 0) {
            for (Pricebook2 row: [select Id, Name, CurrencyIsoCode from Pricebook2
                                  where Subsidiary__c=:subsidiaryMap.get(usr.Subsidiary__c).Id
                                  and IsActive=true]
            ) {
                pbObj = row;
            }
        }
        return pbObj;
    }
    
    // To get Upgrade Packages available 
    private static List<PricebookEntry> getSubscriptionProd(Account agentObj, string currencyCode,
                                                            string pricebookId, string country, string whichSku
    ) {
        String query;
        Boolean includeLookup = false;
        Integer idxLevel;
        List<String> listUpgrade = new List<String>();
        List<PricebookEntry> listPricebookEntry = new List<PricebookEntry>();
        List<String> listOfNewPackageSKU = Label.SKU_CODE_OF_CULLINAN_PACKAGE.Split(';');
        
        if(agentObj.Status__c != null && agentObj.Status__c == 'Active' && agentObj.Account_Previous_Status__c != null && 
           (agentObj.Account_Previous_Status__c == 'Trial' || agentObj.Account_Previous_Status__c == 'Expired')) {
               for (Upgrade_Package_Lookup__c row: [select Name, Upgrade_SKU__c, Level__c 
                                                    from Upgrade_Package_Lookup__c 
                                                    where Country__c=:country and Upgrade_SKU__c IN :listOfNewPackageSKU
                                                    order by Level__c]
                   ) {
                       if(whichSku == 'Upgrade_SKU__c') {
                           if(includeLookup && idxLevel<row.Level__c) {
                               if(!(idxLevel == 0 && row.Level__c == 1))
                                   listUpgrade.add(string.valueOf(row.get(whichSku)));
                           } else if(row.Name.containsIgnoreCase(agentObj.Account_Rule_Code__c)) {
                               includeLookup = true;
                               idxLevel = integer.valueOf(row.Level__c);
                           }
                       }
                   }
           } else { 
               for (Upgrade_Package_Lookup__c row: [select Name, Upgrade_SKU__c, Level__c 
                                                    from Upgrade_Package_Lookup__c 
                                                    where Country__c=:country and IsActive__c = True
                                                    order by Level__c]
                   ) {
                       if(whichSku == 'Upgrade_SKU__c') {
                           if(includeLookup && idxLevel<row.Level__c) {
                               if(!(idxLevel == 0 && row.Level__c == 1))
                                   listUpgrade.add(string.valueOf(row.get(whichSku)));
                           } else if(row.Name.containsIgnoreCase(agentObj.Account_Rule_Code__c)) {
                               includeLookup = true;
                               idxLevel = integer.valueOf(row.Level__c);
                           }
                       }
                   }
           }
        if (listUpgrade.size() > 0) {
            query = 'select Id, Name, UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c, Product2.Description, Product2.Is_Bundle__c, Product2.SKU_Code__c, Product2.Product_Category__c, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, Product2.Tax_Code__r.Tax_Rate__c, Product2.CustItem_Duration_Value__c, Product2.CustItem_Duration_Unit__c  from PricebookEntry where Pricebook2Id=\''+pricebookId+'\' and Product2.IsActive=true and IsActive=true and Product2.Segment__c in (\'B2C Only\', \'B2B & B2C\') and Product2.Product_Category__c=\'Subscription\' and CurrencyIsoCode=\''+currencyCode+'\' and Product2.CurrencyIsoCode=\''+currencyCode+'\' and Product2.SKU_Code__c in (\''+ string.join(listUpgrade, '\', \'') + '\')';
            for (PricebookEntry row: database.query(query)) {
                if (row.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode) {
                    listPricebookEntry.add(row);
                }
            }
        }
        return listPricebookEntry;
    }
       
    private static Decimal getLoyaltyDiscountPercentage(Decimal agentTenure , String country) {
        Decimal loyaltyDiscPerc = 0.00;
        List<Loyalty__c> listLoyalty = [select Name, Campaign__c, Campaign__r.Name, Discount_Percentage__c, PG_Tenure__c
                                        from Loyalty__c 
                                        where Campaign__r.Country__c=:country and 
                                        Campaign__r.IsActive=true 
                                        order by PG_Tenure__c desc];
        
        for (Loyalty__c row : listLoyalty) {
            if (agentTenure >= row.PG_Tenure__c) {
                loyaltyDiscPerc = row.Discount_Percentage__c;
                break;
            }
        }
        return loyaltyDiscPerc;
    }    
}