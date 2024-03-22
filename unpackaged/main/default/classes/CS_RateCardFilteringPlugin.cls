global with sharing class CS_RateCardFilteringPlugin implements csmso.SalesOrderAPI.SalesOrderLookupPlugin {
	/**************************************************************************************************************************************************************************
	* @author       Ivan Ravnjak
	* @description  Implementation of method for customised lookup on Rate Card Manual, filters Rate Cards based on Market, Account, Currency and Type.
	* @date         2018-09-11
	* @param        params(Map<String, String>) map of search fields from config
	* @param        parentFieldValue(String) Value of parent Field Value
	* ──────────────────────────────────────────────────────────────────────────────────────────────────
	* @changes
	* v1.1            aldo.topic@cloudsensesolutions.com
	* 2019-01-15      Commented out condition not to show suggested (selected) rate card.
	**************************************************************************************************************************************************************************/
	global String query(Map<String, String> params, String parentFieldValue) {
		System.debug('search_fields>>>>>>' + JSON.serialize(params));

		Sales_Order_Filtering__c linkedSOF = [
				SELECT Id, Name, Linked_Sales_Order__c
				FROM Sales_Order_Filtering__c
				WHERE Id = :parentFieldValue
		];

		csmso__Sales_Order__c currentSo = [
				SELECT Id, Name, Bill_To_Account__c, Market__c, CurrencyIsoCode, Rate_Card__c, Order_Type__c
				FROM csmso__Sales_Order__c
				WHERE Id = :linkedSOF.Linked_Sales_Order__c
		];

		List<csmso__Rate_Card__c> rateCardList = [
				SELECT Id, Name, Short_Description__c, Order_Type__c, csmso__Product_Node__c, Type__c, Account__c, csmso__From_Date__c, csmso__To_Date__c
				FROM csmso__Rate_Card__c
				WHERE
				(
						(Type__c = 'Base'
						AND csmso__To_Date__c >= TODAY
						AND Order_Type__c = :currentSo.Order_Type__c
						AND csmso__Product_Node__c = :currentSo.Market__c
						)
						OR
						(Type__c = 'Customer Price List'
						AND csmso__To_Date__c >= TODAY
						AND Order_Type__c = :currentSo.Order_Type__c
						AND csmso__Product_Node__c = :currentSo.Market__c
						)
				)
				AND Type__c != 'Seasonal'
				//AND Id != :currentSo.Rate_Card__c
		];
		return JSON.serialize(rateCardList);
	}
}