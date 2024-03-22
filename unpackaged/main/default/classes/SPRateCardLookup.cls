global class SPRateCardLookup extends cscfga.ALookupSearch {

    //PLS CHANGE START
    public override Object [] doDynamicLookupSearch(Map<String, String> searchFields, String productDefinitionId) {
      return this.doLookupSearch(searchFields, productDefinitionId, null, 0, 1);
    }
    //PLS CHANGE END
    /**************************************************************************************************************************************************************************
    * @author       Ivan Ravnjak
    * @description  Implementation of method for customised lookup, filters Markets based on Markets associated to Offers (Package Markets)
    * @date         2018-09-11
    * @param        searchFields(Map<String, String>) map of search fields from config
    * @param        productDefinitionId(Id) Id of product definition
    * @param        excludeIds(Id[]) Ids to exclude
    * @param        pageOffset(Integer) Offset for current page
    * @param        pageLimit(Integer) Records on page
    * @return       Object[] List of found items based on search criteria
    * Updates       [AM:20201029]Added CurrencyIsoCode to SOQL
    * Updates       [AM:20201228]Added SalesOrder ID and Currency ISO Code to the Filter condition
    **************************************************************************************************************************************************************************/
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit) {
        // basic lookup with filtering
        String attrMarket = searchFields.get('Market');
        String orderType = searchFields.get('Order Type');
        String soCurrency = searchFields.get('SO Currency');
        String searchValue = searchFields.get('searchValue');
        String soNumber = searchFields.get('Sales Order Id');

        System.debug('in doLookupSearch market filtering');
        System.debug('search_fields>>>>>>' + JSON.serialize(searchFields));

        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE = 25;
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT = 26;
        Integer recordOffset = pageOffset * SELECT_LIST_LOOKUP_PAGE_SIZE;

        string loggedInUserProfileName = [SELECT Profile.name FROM user WHERE Id = : UserInfo.getUserId()].Profile.name;

        String searchQuery = 'SELECT Id, Name, Rate_Card_Type__c, Short_Description__c, csmso__Product_Node__r.csmso__Description__c, Order_Type__c, Account__r.Name, From_Date__c, To_Date__c, csmso__From_Date__c, csmso__To_Date__c, Rate_Card_Premium_Type__c, CurrencyIsoCode FROM csmso__Rate_Card__c WHERE csmso__Product_Node__c = :attrMarket AND Order_Type__c = :orderType AND Rate_Card_Expired__c = false ';
        
        if(loggedInUserProfileName == 'B2B Sales User')
            searchQuery += ' AND Rate_Card_Type__c = \'B2B\'';
        else if(loggedInUserProfileName == 'B2C Sales User' || loggedInUserProfileName == 'B2C Sales Head')
            searchQuery += ' AND Rate_Card_Type__c = \'B2C\'';
        
        if(String.isNotBlank(soNumber)) {
            searchQuery += ' AND CurrencyIsoCode = :soCurrency';
        }
        if (String.isNotBlank(searchValue)) {
            searchValue = '%' + searchValue + '%';
            searchQuery += ' AND (Short_Description__c LIKE :searchValue OR Name LIKE :searchValue)';
        }
        searchQuery += ' ORDER BY csmso__From_Date__c ASC LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT OFFSET :recordOffset';
        
        return (List<csmso__Rate_Card__c>) Database.query(searchQuery);
    }

    public override String getRequiredAttributes() {
        return '["Order Type", "Market", "SO Currency","Sales Order Id"]';
    }
}