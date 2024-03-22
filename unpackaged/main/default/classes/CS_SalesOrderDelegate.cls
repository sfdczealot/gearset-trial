/**
* @name CS_SalesOrderDelegate
* @description trigger handler for object Sales Order.
* @revision
* Ivan Ravnjak (CloudSense) 11-09-2018 Created class
*/
public with sharing class CS_SalesOrderDelegate extends CS_TriggerHandler.DelegateBase {

    private static Map<String, Double> currencyMap = new Map<String, Double>();

    List<csmso__Rate_Card__c> rateCardListFinal = new List<csmso__Rate_Card__c>();

    public override void prepareBefore() {
    }

    public override void prepareAfter() {
    }

    public override void beforeInsert(sObject o) {
        system.debug('>>>>in beforeInsert');
        populateRateCard();
        populatePricingFields();
        updateMarketForResellers();
    }

    public override void beforeUpdate(sObject old, sObject o) {
        system.debug('>>>>in beforeUpdate');
        populatePricingFields();
    }

    public override void afterInsert(sObject o) {
        createSalesOrderFilter();
    }

    public override void afterUpdate(sObject old, sObject o) {
        recallApprovalFromFulfilments();
    }
    
    public override void finish() {
    }


    /**************************************************************************************************************************************************************************
    * @author       Ivan Ravnjak
    * @description  This method populates Rate Card field on Sales Order on insert. Finds Rate Card based on SO field values.
    * @date         2018-11-09
    **************************************************************************************************************************************************************************/
    public void populateRateCard() {
        
        List<Id> listOfSOAccounts = new List<Id>();
        List<Id> listOfMarkets = new List<Id>();
        List<String> listOfOrderTypes = new List<String>();

        for (Sobject sobj : trigger.new) {
            csmso__Sales_Order__c soNew = (csmso__Sales_Order__c) sobj;
            
            listOfSOAccounts.add(soNew.Bill_To_Account__c);
            listOfMarkets.add(soNew.Market__c);
            listOfOrderTypes.add(soNew.Order_Type__c);
        }

        rateCardListFinal = [SELECT 
                                Id, Account__c, CurrencyIsoCode, Type__c, Order_Type__c,  
                                csmso__From_Date__c, csmso__To_Date__c, csmso__Product_Node__c   
                            FROM 
                                csmso__Rate_Card__c
                            WHERE 
                                csmso__Product_Node__c IN :listOfMarkets
                                AND csmso__From_Date__c <= TODAY AND csmso__To_Date__c >= TODAY
                                AND Order_Type__c IN :listOfOrderTypes
                            ORDER BY CreatedDate DESC];

        
        if ( rateCardListFinal.isEmpty() ){
            return;
        }

        List<csmso__Rate_Card__c> customerRCs = new List<csmso__Rate_Card__c>();

        for (Sobject sobj : trigger.new) {
            csmso__Sales_Order__c soNew = (csmso__Sales_Order__c) sobj;

            //Select RC by priority  (company->agency->advertiser->base)
            customerRCs = getCustomerRCforAccount( soNew.Company_on_Agreement__c, soNew.Media_Agency__c, soNew.csmso__Advertiser__c, soNew.CurrencyIsoCode );
            
            // there should NOT be 2 Rate Cards with same type for the same period, in that case take newer one
            if ( !customerRCs.isEmpty() ) {
                soNew.Rate_Card__c = customerRCs[0].Id;
            } 
        }
    }

    /**************************************************************************************************************************************************************************
    * @author       Ivan Ravnjak
    * @description  This method filters Rate Cards based on priority for Customer Price List or takes a Base card
    * @date         2018-11-09
    **************************************************************************************************************************************************************************/
    public List<csmso__Rate_Card__c> getCustomerRCforAccount( Id companyAccount, Id agencyAccount, Id advertiserAccount, String currencyCode ){
        List<csmso__Rate_Card__c> listToReturn = new List<csmso__Rate_Card__c>();
        List<csmso__Rate_Card__c> listCompanies = new List<csmso__Rate_Card__c>();
        List<csmso__Rate_Card__c> listAgencies = new List<csmso__Rate_Card__c>();
        List<csmso__Rate_Card__c> listAdvertisers = new List<csmso__Rate_Card__c>();
        List<csmso__Rate_Card__c> listBaseCards = new List<csmso__Rate_Card__c>();
        if (rateCardListFinal == null ) return null;


        System.debug('rateCardListFinal => ' + rateCardListFinal);
        for (csmso__Rate_Card__c currRc : rateCardListFinal ){
            if ( currRc.Type__c == 'Customer Price List' ) {
                if (currRc.Account__c == companyAccount) {
                    listCompanies.add( currRc );
                }
                if (currRc.Account__c == agencyAccount) {
                    listAgencies.add( currRc );
                }
                if (currRc.Account__c == advertiserAccount) {
                    listAdvertisers.add( currRc );
                }
            } else if ( currRc.Type__c == 'Base' ) {
                listBaseCards.add( currRc );
            }
        }
        
        //Select RC by priority  (company->agency->advertiser->base)
        if ( listCompanies.isEmpty() ) {
            if ( listAgencies.isEmpty() ) {
                if ( listAdvertisers.isEmpty() ) {
                    if ( !listBaseCards.isEmpty() ) {
                        listToReturn = listBaseCards;
                    }
                } else {
                    listToReturn = listAdvertisers;
                }
            } else {
                listToReturn = listAgencies;
            }
        } else {
            listToReturn = listCompanies;
        }
        
        // select RC with same currency as Opp currency, otherwise select any RC
        List<csmso__Rate_Card__c> listRateCardsWithSameCurrency = new List<csmso__Rate_Card__c>();
        if ( listToReturn.Size() > 1 ) {
            for ( csmso__Rate_Card__c currRc : listToReturn ) {
                if ( currRc.CurrencyIsoCode == currencyCode ) {
                    listRateCardsWithSameCurrency.add( currRc );
                }
            }
        }

        if ( !listRateCardsWithSameCurrency.isEmpty() ){
            return listRateCardsWithSameCurrency;
        } else {
            return listToReturn;
        }
    }


    
    /**************************************************************************************************************************************************************************
    * @author       Ivan Ravnjak
    * @description  This method populates Sales Order fields Volume IO discount, Maximum Production Cost %, Minimum Deal Value from related Rate Card on beforeUpdate
    * @date         2018-11-09
    **************************************************************************************************************************************************************************/
    public void populatePricingFields() {

        List<csmso__Rate_Card__c> rateCardList = new List<csmso__Rate_Card__c>();
        
        Map<String, csmso__Sales_Order__c> rcToSoMap = new Map<String, csmso__Sales_Order__c>();

        Decimal exchangeRate = 1.00;
        Decimal defaultExchangeRate = 1.00;
        currencyMap = getCurrencyMap();

        for (Sobject sobj : trigger.new) {
            csmso__Sales_Order__c soNew = (csmso__Sales_Order__c) sobj;

            if ( Trigger.isUpdate ) {
                csmso__Sales_Order__c soOld = (csmso__Sales_Order__c) Trigger.oldMap.get(soNew.Id);

                // if RC - Manual was updated
                if ( (soNew.Rate_Card__c != null && soOld.Rate_Card__c != soNew.Rate_Card__c) ) {
                    rcToSoMap.put(soNew.Rate_Card__c, soNew);
                }
                else if (soNew.Total_Markets__c != soOld.Total_Markets__c) {
                        rcToSoMap.put(soNew.Rate_Card__c, soNew);
                }
            }

            if ( Trigger.isInsert ) {
                if ( soNew.Rate_Card__c != null ) {
                    rcToSoMap.put(soNew.Rate_Card__c, soNew);
                }
            }
        }
        
        if(!rcToSoMap.isEmpty()) {
            rateCardList = [SELECT 
                                 Id, Name, IO_Volume_Discount_Range_1__c, IO_Volume_Discount_Range_2__c, IO_Volume_Discount_Range_3__c, 
                                 IO_Volume_Discount_Range_4__c, IO_Volume_Discount_Range_5__c, Maximum_Production_Cost__c, Minimum_Deal_Value__c, CurrencyIsoCode 
                            FROM 
                                csmso__Rate_Card__c
                            WHERE 
                                Id IN :rcToSoMap.keyset()];
            
            for (csmso__Rate_Card__c currRC : rateCardList) {
                csmso__Sales_Order__c currSO = rcToSoMap.get(currRC.Id);
    
                // If Currency from retrieved/ selected Rate Card is different than the SO currency, exchange rate will be applied on SO.
                if ( currSO.CurrencyIsoCode != currRC.CurrencyIsoCode ){
                    // populate SO.Exchange Rate with exchange rate
                    exchangeRate = convertCurrency( currRC.CurrencyIsoCode, currSO.CurrencyIsoCode, 1);
    
                    currSO.Exchange_Rate__c = exchangeRate;
                } else {
                    currSO.Exchange_Rate__c = defaultExchangeRate;
                }
    
                //populate values on SO in target currency
                if ( exchangeRate != 1.0000 ) {
                    currSO.IO_Volume_Discount_Range_1__c = convertCurrency( currSO.CurrencyIsoCode, currRC.CurrencyIsoCode, currRC.IO_Volume_Discount_Range_1__c);
                    currSO.IO_Volume_Discount_Range_2__c = convertCurrency( currSO.CurrencyIsoCode, currRC.CurrencyIsoCode, currRC.IO_Volume_Discount_Range_2__c);
                    currSO.IO_Volume_Discount_Range_3__c = convertCurrency( currSO.CurrencyIsoCode, currRC.CurrencyIsoCode, currRC.IO_Volume_Discount_Range_3__c);
                    currSO.IO_Volume_Discount_Range_4__c = convertCurrency( currSO.CurrencyIsoCode, currRC.CurrencyIsoCode, currRC.IO_Volume_Discount_Range_4__c);
                    currSO.IO_Volume_Discount_Range_5__c = convertCurrency( currSO.CurrencyIsoCode, currRC.CurrencyIsoCode, currRC.IO_Volume_Discount_Range_5__c);
                    currSO.Minimum_Deal_Value__c = convertCurrency( currSO.CurrencyIsoCode, currRC.CurrencyIsoCode, currRC.Minimum_Deal_Value__c);
                } else {
                    currSO.IO_Volume_Discount_Range_1__c = currRC.IO_Volume_Discount_Range_1__c;
                    currSO.IO_Volume_Discount_Range_2__c = currRC.IO_Volume_Discount_Range_2__c;
                    currSO.IO_Volume_Discount_Range_3__c = currRC.IO_Volume_Discount_Range_3__c;
                    currSO.IO_Volume_Discount_Range_4__c = currRC.IO_Volume_Discount_Range_4__c;
                    currSO.IO_Volume_Discount_Range_5__c = currRC.IO_Volume_Discount_Range_5__c;
                    currSO.Minimum_Deal_Value__c = currRC.Minimum_Deal_Value__c;
                }
    
                currSO.Maximum_Production_Cost__c = currSo.Total_Markets__c > 1 ? CS_Custom_Settings__c.getInstance().Maximum_Production_Cost__c : currRC.Maximum_Production_Cost__c;
            }
        }
    }

    private static Map<String,Double> getCurrencyMap(){
        if (currencyMap.size() == 0){
            for( CurrencyType curr: [SELECT IsoCode, ConversionRate FROM CurrencyType WHERE isActive = true]){          
                    currencyMap.put( curr.IsoCode, curr.ConversionRate);        
            }
        }
        return currencyMap;

    }

    // taken from CurrencyConverterUtility
    public static Decimal convertCurrency( String targetCurrency, String sourceCurrency, Decimal value){
        if ( value == null ) {
            return null;
        }
        currencyMap = getCurrencyMap();

        if( currencyMap.get(targetCurrency) == currencyMap.get(sourceCurrency)){
            return value;
        }
        else if( currencyMap.get(sourceCurrency) == 1){
            return (value * currencyMap.get(targetCurrency)).setscale(6);
        }
        else if( currencyMap.get(targetCurrency) == 1){
            return (value / currencyMap.get(sourceCurrency)).setscale(6);
        }
        else{
            return (value / currencyMap.get(sourceCurrency) * currencyMap.get(targetCurrency)).setscale(6);
        }


    }

    /**************************************************************************************************************************************************************************
    * @author       Ivan Ravnjak
    * @description  This method creates new Sales Order Filtering record on Sales Order insert trigger populates lookup on Sales Order. Sales Order Filtering record is used
    *               to provide Custom filtering functionality for Rate Card Manual on Sales Order.
    * @date         2018-11-09
    **************************************************************************************************************************************************************************/
    public void createSalesOrderFilter() {
        List<Sales_Order_Filtering__c> listSOIFs = new List<Sales_Order_Filtering__c>();
        // map for Sales Order to Sales Order filtering record
        Map<Id, Id> mapSoToSOIR = new Map<Id, Id>();
        // map to hold relation Sales Order to Sales Order Filtering record
        Map<Id, Sales_Order_Filtering__c> mapSoToSOF = new Map<Id, Sales_Order_Filtering__c>();

        for (Sobject sobj : trigger.new) {
            csmso__Sales_Order__c soNew = (csmso__Sales_Order__c) sobj;
            
            Sales_Order_Filtering__c tempSOIF = new Sales_Order_Filtering__c();
            tempSOIF.Name = soNew.Name;
            tempSOIF.Linked_Sales_Order__c = soNew.Id;
            listSOIFs.add(tempSOIF);

            mapSoToSOIR.put(soNew.Id, tempSOIF.Id);
        }
        
        Map<Id, csmso__Sales_Order__c> soMap = new Map<Id, csmso__Sales_Order__c>([SELECT Id, Sales_Order_Filtering__c 
                                                                                    FROM csmso__Sales_Order__c
                                                                                    WHERE Id IN :mapSoToSOIR.keyset()]);

        if (!listSOIFs.isEmpty()) {
            INSERT listSOIFs;
        }

        List<Sales_Order_Filtering__c> soipList = [SELECT 
                                                         Id, Linked_Sales_Order__c 
                                                    FROM 
                                                        Sales_Order_Filtering__c
                                                    WHERE 
                                                        Linked_Sales_Order__c IN :soMap.keyset()];

        
        for ( Sales_Order_Filtering__c currSOIP : soipList ) {
            mapSoToSOF.put(currSOIP.Linked_Sales_Order__c, currSOIP);
        }

        // Update SO.Sales_Order_Filtering__c to related SOF record
        List<csmso__Sales_Order__c> soUpdateList = new List<csmso__Sales_Order__c>();
        for (Sobject sobj : trigger.new) {
            csmso__Sales_Order__c soNew = (csmso__Sales_Order__c) sobj;

            csmso__Sales_Order__c soTemp = soMap.get(soNew.Id);
            soTemp.Sales_Order_Filtering__c = mapSoToSOF.get(soNew.Id).Id;
            soUpdateList.add(soTemp);
        }
        if (!soUpdateList.isEmpty()){
            UPDATE soUpdateList;
        }
    }

    /**************************************************************************************************************************************************************************
    * @author       Ivan Ravnjak
    * @description  This method filters and updates Market for Reseller users
    * @date         2018-11-09
    **************************************************************************************************************************************************************************/
    public void updateMarketForResellers() {
        String userName = UserInfo.getUserId();
        List<Contact> lstContacts = new List<Contact>();
        List<csmso__Product_Node__c> lstMarket = new List<csmso__Product_Node__c>();
        List<csmso__Rate_Card__c> rateCardList = new List<csmso__Rate_Card__c>();
        Set<id> nodesSet = new Set<Id>();

        User currentUser = [Select User.ContactId, User.Email, profile.Name from User where User.Id = :userName];

        // filter markets for Reseller profile based on account/rate card
        if(currentUser.profile.Name != 'S: Reseller') {
            return;
        } 

        lstContacts = [Select id, name, AccountID, account.name, account.Corporate_Brand_Name__c, account.id from contact where id =:currentUser.ContactId];
        
        rateCardList = [select id, name, csmso__Product_Node__c from csmso__Rate_Card__c where Account__c =:lstContacts[0].account.id];
        
        for (csmso__Rate_Card__c currentRC : rateCardList){
            nodesSet.add(currentRC.csmso__Product_Node__c);
        }

        lstMarket = [SELECT Id, Name, csmso__Description__c FROM csmso__Product_Node__c WHERE Id IN :nodesSet];

        for (Sobject sobj : trigger.new) {
            csmso__Sales_Order__c soNew = (csmso__Sales_Order__c) sobj;
            soNew.Market__c = lstMarket[0].Id;
        }
    }

    /**************************************************************************************************************************************************************************
    * @author       Vivek 
    * @description  This method recall approval process for child fulfillments 
    * @date         2021-12-22
    **************************************************************************************************************************************************************************/
    public void recallApprovalFromFulfilments() {
            set<Id> setSOIdWExpiryDateNull = new set<Id>();
            
            for(Sobject sobj : trigger.new) {
                csmso__Sales_Order__c soNew = (csmso__Sales_Order__c) sobj;
                csmso__Sales_Order__c soOld = (csmso__Sales_Order__c) Trigger.oldMap.get(soNew.Id);
                if(soNew.Expiration_Date__c == null && soNew.Expiration_Date__c != soOld.Expiration_Date__c)
                    setSOIdWExpiryDateNull.add(soNew.id);
            }
            
            map<Id,csdf__Fulfilment__c> mapFulfillments = new map<Id,csdf__Fulfilment__c>([Select Id from csdf__Fulfilment__c Where Sales_Order__c In: setSOIdWExpiryDateNull]);
            list<Approval.ProcessWorkitemRequest> listProcessRecs = new list<Approval.ProcessWorkitemRequest>();
            
            for(ProcessInstanceWorkitem objFulFillmentId : [SELECT Id FROM ProcessInstanceWorkitem WHERE ProcessInstance.TargetObjectId In : mapFulfillments.keyset()])
            {
                Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
                req.setAction('Removed');       
                req.setWorkitemId(objFulFillmentId.Id);
                listProcessRecs.add(req);
            }
            
            Approval.process(listProcessRecs,false);
    }
    
}