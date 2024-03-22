global class SPMarketFilteringPlugin extends cscfga.ALookupSearch { 
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
    **************************************************************************************************************************************************************************/
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit){
        // basic lookup with filtering
        String attrMarket  = searchFields.get( 'Market' );
        String salesOrderId  = searchFields.get( 'Sales Order Id' );
        String searchValue = searchFields.get( 'searchValue' );

        List<csmso__Product_Node__c> returnLstMarket = new List<csmso__Product_Node__c>();

        system.debug('in doLookupSearch market filtering');
        system.debug('search_fields>>>>>>' + JSON.serialize(searchFields));

        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE = 25;
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT= 26;
        Integer recordOffset = pageOffset * SELECT_LIST_LOOKUP_PAGE_SIZE;

        //new
        String userName = UserInfo.getUserId();
        id profileid = Userinfo.getProfileId();
        List<Contact> lstContacts = new List<Contact>();
        List<Account> lstAccounts = new List<Account>();
        Boolean isReseller = false;
        Set<id> nodesSet = new Set<Id>();
        Set<id> coprBrandNamesSet = new Set<Id>();

        User currentUser = [Select User.ContactId, User.Email, profile.Name from User where User.Id = :userName];

        // filter markets for Reseller profile based on account/rate card
        if(currentUser.profile.Name == 'S: Reseller') {
            isReseller = true;
            lstContacts = [Select id, name, AccountID, account.name, account.Corporate_Brand_Name__c, account.id from contact where id =:currentUser.ContactId];

            //fetch related corporate brand accounts
            lstAccounts = [Select id, name  from Account where Corporate_Brand_Name__c =:lstContacts[0].account.Corporate_Brand_Name__c];
            for(Account currentAcc : lstAccounts){
                coprBrandNamesSet.add(currentAcc.id);
            }
            
            List<csmso__Rate_Card__c> rateCardList = new List<csmso__Rate_Card__c>();
            rateCardList = [select id, name, csmso__Product_Node__c from csmso__Rate_Card__c where Account__c IN :coprBrandNamesSet];
            
            for (csmso__Rate_Card__c currentRC : rateCardList){
                nodesSet.add(currentRC.csmso__Product_Node__c);
            }
        }

        String searchQuery;
        if (searchValue == null || searchValue == '') {
            searchQuery = 'SELECT Id, Name, Geo_Targeting__c, csmso__Description__c, Sponsorship_Booking_Timezone__c FROM csmso__Product_Node__c';
            if(isReseller){
                searchQuery += ' WHERE Id IN :nodesSet';
            }
            searchQuery += ' LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT OFFSET :recordOffset';
        } else {
            searchValue = '%'+searchValue+'%';
            searchQuery = 'SELECT Id, Name, Geo_Targeting__c, csmso__Description__c, Sponsorship_Booking_Timezone__c FROM csmso__Product_Node__c';
            if(isReseller){
                searchQuery += ' WHERE (csmso__Description__c LIKE :searchValue OR Name LIKE :searchValue) AND Id IN :nodesSet';
            } else {
                searchQuery += ' WHERE (csmso__Description__c LIKE :searchValue OR Name LIKE :searchValue)';
            }
            searchQuery += ' LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT OFFSET :recordOffset';
        }
        system.debug('searchQuery>>>>>>' + searchQuery);
        List<csmso__Product_Node__c> lstMarket = Database.query(searchQuery); 
        return lstMarket;
    }


    public override Object[] doDynamicLookupSearch(Map<String, String> searchFields, String productDefinitionID){
        // dynamic lookup from rule
        List<csmso__Product_Node__c> lstMarket = new List<csmso__Product_Node__c>();

        String market = searchFields.get( 'Market' );
        
        lstMarket = [SELECT 
                        Id, Name, Geo_Targeting__c, csmso__Description__c, Sponsorship_Booking_Timezone__c
                    FROM 
                        csmso__Product_Node__c WHERE Id =:market
                    ];
        return lstMarket;
    }

    public override String getRequiredAttributes(){ return '["Sales Order Id", "Market"]'; } 
}