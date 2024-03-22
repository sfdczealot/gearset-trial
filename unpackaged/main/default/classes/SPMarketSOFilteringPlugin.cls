global with sharing class SPMarketSOFilteringPlugin implements csmso.SalesOrderAPI.SalesOrderLookupPlugin {
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
		String searchQuery = 'SELECT Id, Name, csmso__Description__c FROM csmso__Product_Node__c';
		List<csmso__Product_Node__c> lstMarket = Database.query(searchQuery);

		return JSON.serialize(lstMarket);
	}
}