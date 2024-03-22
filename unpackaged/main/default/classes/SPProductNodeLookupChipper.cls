global class SPProductNodeLookupChipper extends cscfga.ALookupSearch {
    
    /**************************************************************************************************************************************************************************
* @author       Ankur
* @description  Implementation of method for customised lookup, filters NAA based on Market and RateCard
* @date         2020-10-28
* @param        searchFields(Map<String, String>) map of search fields from config
* @param        productDefinitionId(Id) Id of product definition
* @param        excludeIds(Id[]) Ids to exclude
* @param        pageOffset(Integer) Offset for current page
* @param        pageLimit(Integer) Records on page
* @return       Object[] List of found items based on search criteria
**************************************************************************************************************************************************************************/
    
    public override String getRequiredAttributes() {
        System.debug('@@@@@ getRequiredAttributes() ');
        return '["Product Subsidiary", "Account Tier", "Rate Card", "Market", "Served By", "Site-Section","FLAG Package Creation"]';
    }
    
    public override Object[] doLookupSearch(Map<String, String> searchFields, String productDefinitionId, Id[] excludeIds, Integer pageOffset, Integer pageLimit) {
        System.debug('@@@@@ doLookupSearch() ');
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE = 25;
        final Integer SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT= 26;
        Integer recordOffset = pageOffset * SELECT_LIST_LOOKUP_PAGE_SIZE;
        
        System.debug(searchFields);
        String productSubsidiary = searchFields.get('Product Subsidiary');
        String servedBy = searchFields.get('Served By');
        String accountTier  = searchFields.get('Account Tier');
        String rateCard = searchFields.get('Rate Card');
        String market = searchFields.get('Market');
        String sitesection = searchFields.get('Site-Section');
        String searchValue = searchFields.get('searchValue');
        String isPackageCreation = searchFields.get('FLAG Package Creation');
        //CR-775
        Boolean canUseHouseBooking = FeatureManagement.checkPermission('Sales_Order_Access_House_Booking');
        List<csmso__Rate_Card_Item_Price__c> rcip = new List<csmso__Rate_Card_Item_Price__c>();
        IF(productSubsidiary == 'iPP'){
            rcip = [Select
                    Id, Name, csmso__Advert_Assignment__c,csmso__Advert_Assignment__r.Line_Item_Type__c
                    FROM
                    csmso__Rate_Card_Item_Price__c
                    WHERE
                    csmso__Rate_Card__c = :rateCard AND
                    Account_Tier__c = :accountTier AND
                    csmso__Advert_Assignment__r.csmso__Title_Product_Node__r.csmso__Parent_Product_Node__c  = :market AND
                    csmso__Advert_Assignment__r.Served_by__c = :servedBy AND
                    csmso__Advert_Assignment__r.csmso__Title_Product_Node__c = :sitesection AND
                    (csmso__Advert_Assignment__r.Product_Subsidiary__c = 'ipp') ];
            
        } else {
            rcip = [Select
                    Id, Name, csmso__Advert_Assignment__c,csmso__Advert_Assignment__r.Line_Item_Type__c
                    FROM
                    csmso__Rate_Card_Item_Price__c
                    WHERE
                    csmso__Rate_Card__c = :rateCard AND
                    Account_Tier__c = :accountTier AND
                    csmso__Advert_Assignment__r.csmso__Title_Product_Node__r.csmso__Parent_Product_Node__c  = :market AND
                    csmso__Advert_Assignment__r.Served_by__c = :servedBy AND
                    csmso__Advert_Assignment__r.csmso__Title_Product_Node__c = :sitesection 
                   ];
        }
        
        Set<Id> nodeAdvertIds = new Set<Id>();
        for (csmso__Rate_Card_Item_Price__c rci : rcip) {
            if ( !canUseHouseBooking && rci.csmso__Advert_Assignment__r.Line_Item_Type__c == 'House') {
                continue; //CR-775
            }
            nodeAdvertIds.add(rci.csmso__Advert_Assignment__c);
        }
        if(isPackageCreation == 'Yes'){
            if(String.isBlank(searchValue)) {
                return [SELECT Ad_Location_Description__c, Ad_Slot__c, Ad_Type__c, Do_not_Apply_Agency_Commission__c,Duration_Term__c, Duration__c, Royalty_Payment__c, Id,
                        Expiration_Date__c, Inventory_sizes__c, Invoice_GL_Code__c, Is_Video_Creative_Set__c, Key_values_and_Audience_JSON__c, Name,
                        Key_values_and_Audience__c, Line_Item_Category__c, Line_Item_Type__c, Overwrite_Billing_Source__c, Product_Category__c, Priority__c,
                        Product_Family__c, Product_Group__c, Product_Name__c, Rate_Type_Display__c, Rate_Type__c, Rev_Accrual_GL_Code__c, Served_by__c, Quantity_Type__c,
                        Invoice_Agency_Fee_GL_Code__c, Rev_Accrual_Agency_Fee_GL_Code__c, Device_Categories__c, Default_Frequency_Capping__c, Lock_Frequency_Capping__c, Ad_Slot_Template__c, Targeting_Template__c,Skip_Approvals__c,Targeting_Visibility_Tags__c,
                        SOV__c, Product_Info__c, csmso__Title_Product_Node__c, Starting_Day__c,isDistrict__c,bundle_only__c,Lock_end_date__c    
                        FROM csmso__Node_Advert_Assignment__c
                        WHERE Id IN :nodeAdvertIds
                        ORDER BY Product_Name__c LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT OFFSET :recordOffset];
            }
            else {
                searchValue = '%' + searchValue + '%';
                return [SELECT Ad_Location_Description__c, Ad_Slot__c, Ad_Type__c, Do_not_Apply_Agency_Commission__c, Duration__c,Duration_Term__c, Royalty_Payment__c, Id,
                        Expiration_Date__c, Inventory_sizes__c, Invoice_GL_Code__c, Is_Video_Creative_Set__c, Key_values_and_Audience_JSON__c, Name,
                        Key_values_and_Audience__c, Line_Item_Category__c, Line_Item_Type__c, Overwrite_Billing_Source__c, Product_Category__c, Priority__c,
                        Product_Family__c, Product_Group__c, Product_Name__c, Rate_Type_Display__c, Rate_Type__c, Rev_Accrual_GL_Code__c, Served_by__c, Quantity_Type__c,
                        Invoice_Agency_Fee_GL_Code__c, Rev_Accrual_Agency_Fee_GL_Code__c, Device_Categories__c, Default_Frequency_Capping__c, Lock_Frequency_Capping__c, Ad_Slot_Template__c, Targeting_Template__c,Skip_Approvals__c,Targeting_Visibility_Tags__c
                        ,SOV__c, Product_Info__c, csmso__Title_Product_Node__c, Starting_Day__c,isDistrict__c,Lock_end_date__c 
                        FROM csmso__Node_Advert_Assignment__c
                        WHERE Id IN :nodeAdvertIds AND (Product_Name__c LIKE :searchValue OR Line_Item_Type__c LIKE :searchValue OR Inventory_sizes__c LIKE :searchValue OR Rate_Type__c LIKE :searchValue OR Rate_Type_Display__c LIKE :searchValue)
                        ORDER BY Product_Name__c LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT OFFSET :recordOffset];
            }
        }
        else
            if(String.isBlank(searchValue)) {
                return [SELECT Ad_Location_Description__c, Ad_Slot__c, Ad_Type__c, Do_not_Apply_Agency_Commission__c, Duration__c,Duration_Term__c, Royalty_Payment__c, Id,
                        Expiration_Date__c, Inventory_sizes__c, Invoice_GL_Code__c, Is_Video_Creative_Set__c, Key_values_and_Audience_JSON__c, Name,
                        Key_values_and_Audience__c, Line_Item_Category__c, Line_Item_Type__c, Overwrite_Billing_Source__c, Product_Category__c, Priority__c,
                        Product_Family__c, Product_Group__c, Product_Name__c, Rate_Type_Display__c, Rate_Type__c, Rev_Accrual_GL_Code__c, Served_by__c, Quantity_Type__c,
                        Invoice_Agency_Fee_GL_Code__c, Rev_Accrual_Agency_Fee_GL_Code__c, Device_Categories__c, Default_Frequency_Capping__c, Lock_Frequency_Capping__c, Ad_Slot_Template__c, Targeting_Template__c,Skip_Approvals__c,Targeting_Visibility_Tags__c,
                        SOV__c, Product_Info__c, csmso__Title_Product_Node__c, Starting_Day__c,isDistrict__c,bundle_only__c,Lock_end_date__c
                        FROM csmso__Node_Advert_Assignment__c
                        WHERE Id IN :nodeAdvertIds and bundle_only__c = false
                        ORDER BY Product_Name__c LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT OFFSET :recordOffset];
            }
        else {
            searchValue = '%' + searchValue + '%';
            return [SELECT Ad_Location_Description__c, Ad_Slot__c, Ad_Type__c, Do_not_Apply_Agency_Commission__c, Duration__c,Duration_Term__c, Royalty_Payment__c, Id,
                    Expiration_Date__c, Inventory_sizes__c, Invoice_GL_Code__c, Is_Video_Creative_Set__c, Key_values_and_Audience_JSON__c, Name,
                    Key_values_and_Audience__c, Line_Item_Category__c, Line_Item_Type__c, Overwrite_Billing_Source__c, Product_Category__c, Priority__c,
                    Product_Family__c, Product_Group__c, Product_Name__c, Rate_Type_Display__c, Rate_Type__c, Rev_Accrual_GL_Code__c, Served_by__c, Quantity_Type__c,
                    Invoice_Agency_Fee_GL_Code__c, Rev_Accrual_Agency_Fee_GL_Code__c, Device_Categories__c, Default_Frequency_Capping__c, Lock_Frequency_Capping__c, Ad_Slot_Template__c, Targeting_Template__c,Skip_Approvals__c,Targeting_Visibility_Tags__c
                    ,SOV__c, Product_Info__c, csmso__Title_Product_Node__c, Starting_Day__c,isDistrict__c ,Lock_end_date__c
                    FROM csmso__Node_Advert_Assignment__c
                    WHERE Id IN :nodeAdvertIds AND bundle_only__c =false AND (Product_Name__c LIKE :searchValue OR Line_Item_Type__c LIKE :searchValue OR Inventory_sizes__c LIKE :searchValue OR Rate_Type__c LIKE :searchValue OR Rate_Type_Display__c LIKE :searchValue)
                    ORDER BY Product_Name__c LIMIT :SELECT_LIST_LOOKUP_PAGE_SIZE_LIMIT OFFSET :recordOffset];
        }
    }
}