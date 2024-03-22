global class SPRateCardOverwriteLookup extends cscfga.ALookupSearch { 
	/**************************************************************************************************************************************************************************
    * @author       Ivan Ravnjak
    * @description  Implementation of method for customised lookup, filters Rate Cards based on Market, Order Type, Currency and Package Id
    * @date         2018-09-11
    * @param        searchFields(Map<String, String>) map of search fields from config
    * @param        productDefinitionId(Id) Id of product definition
    * @return       Object[] List of found items based on search criteria
    **************************************************************************************************************************************************************************/
	public override Object[] doDynamicLookupSearch(Map<String, String> searchFields, String productDefinitionID){

		String market		 = searchFields.get( 'Market' );
		String orderType	 = searchFields.get( 'Order Type' );
		String currencySO	 = searchFields.get( 'SO Currency' );
		String packageIdString	 = searchFields.get( 'Package Id' );
		String productId	 = searchFields.get( 'Node Advert Assignments' );

		List<csmso__Rate_Card__c> customerRCs = new List<csmso__Rate_Card__c>();
		List<csmso__Rate_Card__c> baseRCs = new List<csmso__Rate_Card__c>();
		List<csmso__Rate_Card__c> filteredRCs = new List<csmso__Rate_Card__c>();
		List<String> allowedTypes = new List<String>{'Customer Price List','Base'}; 

		csmso__Rate_Card__c returnRateCard = new csmso__Rate_Card__c();

		Map<Id, List<csmso__Rate_Card_Item_Price__c>> rateCardToRCIPMap = new Map<Id, List<csmso__Rate_Card_Item_Price__c>>();
		List<csmso__Rate_Card_Item_Price__c> rcipToReturn = new List<csmso__Rate_Card_Item_Price__c>();

		system.debug('search_fields>>>>>>' + JSON.serialize(searchFields));

		List<csmso__Rate_Card__c> rateCardsList = [Select 
														Id, Name, csmso__Product_Node__c, csmso__From_Date__c, 
														csmso__To_Date__c, Type__c, Order_Type__c, CurrencyIsoCode 
													FROM 
														csmso__Rate_Card__c 
													WHERE 
														csmso__Product_Node__c = :market
													AND Order_Type__c = :orderType
													AND csmso__To_Date__c >= TODAY
													AND csmso__From_Date__c <= TODAY
													AND Type__c IN :allowedTypes
													ORDER BY CreatedDate DESC
													];
		Set<Id> rateCardsSet = new Set<Id>();
		for (csmso__Rate_Card__c currRC : rateCardsList){
			rateCardsSet.add(currRC.Id);
		}
		
		List<csmso__Rate_Card_Item_Price__c> rateCardsItemPriceList = [Select 
																			Id, Name, csmso__Rate_Card__c, Package__r.Name
																		FROM 
																			csmso__Rate_Card_Item_Price__c 
																		WHERE 
																			csmso__Rate_Card__c IN :rateCardsSet
																			AND csmso__Advert_Assignment__c = :productId
																		ORDER BY CreatedDate DESC
																		];
		for (csmso__Rate_Card_Item_Price__c currRCIP : rateCardsItemPriceList) {
			if(rateCardToRCIPMap.containsKey(currRCIP.csmso__Rate_Card__c)){
                rateCardToRCIPMap.get(currRCIP.csmso__Rate_Card__c).add(currRCIP);
            }
            else {
                rateCardToRCIPMap.put(currRCIP.csmso__Rate_Card__c, new List<SObject>{currRCIP});
            }
		}
		system.debug('rateCardsItemPriceList>>> '+rateCardsItemPriceList);
		system.debug('rateCardsList>>> '+rateCardsList);
		system.debug('rateCardToRCIPMap>>> '+rateCardToRCIPMap);
		
		if ( rateCardsList.Size() > 1 ) {
			// If, after all the above, there are more than one Rate Card:
			//- Prioritise RC for Customer over Base
			//- Prioritise RC with same Package ID as current Package, then
			//- Prioritise same Currency as the SO is selected, otherwise any other will be selected
			for (csmso__Rate_Card__c currentRC : rateCardsList) {
				if (currentRC.Type__c == allowedTypes[0]) {
					customerRCs.add(currentRC);
				} else {
					baseRCs.add(currentRC);
				}
			}

			if (customerRCs.Size() == 1){
				returnRateCard = customerRCs[0];
			} else if(customerRCs.Size() < 1) {
				if (baseRCs.Size() == 1){
					returnRateCard = baseRCs[0];
				} else if (baseRCs.Size() > 1) {
					filteredRCs = filterByPackageAndCurrency(baseRCs, currencySO, packageIdString, rateCardToRCIPMap);
				}
			} else if (customerRCs.Size() > 1) {
				filteredRCs = filterByPackageAndCurrency(customerRCs, currencySO, packageIdString, rateCardToRCIPMap);
			}
			if (!filteredRCs.isEmpty()) {
				returnRateCard = filteredRCs[0];
			}

		} else if (rateCardsList.Size() == 1) {
			returnRateCard = rateCardsList[0];
		} 
		
		// return RCIP record for filtered RCs
		if(returnRateCard.Id != null) {
			rcipToReturn = rateCardToRCIPMap.get(returnRateCard.Id);
		}

		system.debug('rcipToReturn>>> '+rcipToReturn);
		
		if (rcipToReturn != null){
			return new List<csmso__Rate_Card_Item_Price__c>{rcipToReturn[0]}; 
		} else {
			return new List<csmso__Rate_Card_Item_Price__c>{}; 
		}
		
	}

	public static List<csmso__Rate_Card__c> filterByPackageAndCurrency(List<csmso__Rate_Card__c> inputRCs, String currencySO, String packageId, Map<Id, List<csmso__Rate_Card_Item_Price__c>> rateCardToRCIPMapLocal){
		List<csmso__Rate_Card__c> packageRCs = new List<csmso__Rate_Card__c>();
		List<csmso__Rate_Card__c> rcsInSoCurrency = new List<csmso__Rate_Card__c>();
		List<csmso__Rate_Card__c> rcsOtherCurrencies = new List<csmso__Rate_Card__c>();
		List<csmso__Rate_Card__c> returnRCs = new List<csmso__Rate_Card__c>();
		
		system.debug('inputRCs>>> '+inputRCs);
		system.debug('currencySO>>> '+currencySO);
		system.debug('packageId>>> '+packageId);
		
		for (csmso__Rate_Card__c currentRC : inputRCs) {
			List<csmso__Rate_Card_Item_Price__c> relatedRcips = rateCardToRCIPMapLocal.get(currentRC.Id);
			
			if (relatedRcips != null){
				for (csmso__Rate_Card_Item_Price__c currentRCIP : relatedRcips) {
					if ( currentRCIP.Package__r.Name != null){
						if (String.valueOf(currentRCIP.Package__r.Name) == packageId) {
							packageRCs.add(currentRC);
							continue;
						}
					}
				}
			}
		}
		
		if (packageRCs.isEmpty()){
			for (csmso__Rate_Card__c currentRC : inputRCs) {
				if (currentRC.CurrencyIsoCode == currencySO) {
					rcsInSoCurrency.add(currentRC);
				} else {
					rcsOtherCurrencies.add(currentRC);
				}
			}
		} else {
			if (packageRCs.Size()==1){
				return packageRCs;
			} else {
				for (csmso__Rate_Card__c currentRC : packageRCs) {
					if (currentRC.CurrencyIsoCode == currencySO) {
						rcsInSoCurrency.add(currentRC);
					} else {
						rcsOtherCurrencies.add(currentRC);
					}
				}
			}
		}
		
		if (!rcsInSoCurrency.isEmpty()) {
			return rcsInSoCurrency;
		}
		if (!rcsOtherCurrencies.isEmpty()) {
			return rcsOtherCurrencies;
		}

		return returnRCs;

	}

	public override String getRequiredAttributes(){ return '["Market", "Order Type", "SO Currency", "Package Id", "Node Advert Assignments"]'; } 
}