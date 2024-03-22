//Class for selective cloning the sales order implementing the CloneFilter API
global class SalesOrderSelectiveCloning implements csmso.SalesOrderAPI.CloneFilter {

    global static string CUSTOM_CLONING_EMPTY = 'Empty';
    global static string CUSTOM_CLONING_CURRENT = 'Current';
    global static string CUSTOM_CLONING_DEFAULT = 'Default Value';
    global static string CUSTOM_CLONING_DYNAMIC = 'Dynamic';
    global Map<Id, sObject> opportunities;
    global Map<Id, sObject> attributes;
    global csmso__Sales_Order__c clonedSalesOrder;

    Map<String, Object> initValues = new Map<String, Object> {
            'Availability_Check__c' => 'Not Completed',
            'cscfga__Configuration_Status__c' => 'Requires Update',
            'cscfga__Validation_Message__c' => 'Missing Mandatory fields',
            'Delivered_Impressions__c' => null,
            'Fulfilment_Item_Status__c' => 'Draft',
            'FLAG_Price_Recalculated__c' => 'No',
            'IFC_Change__c' => null,
            'Inventory_Available__c' => null,
            'Line_ID__c' => null,
            'Order_ID__c' => null,
            'Order_Line_ID__c'=> null,
            'Overbook__c'=> false,
            'Reservation_Status__c' => null,
            'Reserve_Inventory__c' => false
    };

    /*****************************************************************************
    * Method Name : prepareReferences
    * Description : Used to prepare the reference data to be used in filter method
    * Parameters  : Sales Order Id which is to be cloned
    * Return      : void
    *****************************************************************************/
    global void prepareReferences(Id salesOrderId){
        // PDs could then be mapped to provide default attribute values, prices, display values...
        try
        {
            if (salesOrderId != null) {
                getOpportunitiesToSO(salesOrderId);
            }
        }
        catch (Exception ex)
        {
            // Log the error
            System.debug('Logging Exception:' + ex.getMessage());
            throw ex;
        }

    }

    /**************************************************************************************************
    * Method Name : filter
    * Description : Used to clone the required information based on the each object involved in cloning
    * Parameters  :
            @apiName            -           api name of the object which is to be cloned
            @SObject            -           the object to be cloned
            @clone              -           the object which is cloned
    * Return      : List of sObjects which are cloned
    **************************************************************************************************/
    global List<SObject> filter(String apiName, SObject source, SObject clone){
        // this is called once per every record involved in the clone in the order of Sales Order, Basket, Product Configuration, Attribute, Attribute Field
        System.debug('+++++ Cloning in filter: ' + clone);
        List<SObject> clones = new List<SObject>{clone};
        try
        {

            if (apiName == 'csmso__Sales_Order__c') {
                clonedSalesOrder = (csmso__Sales_Order__c)clone;
                csmso__Sales_Order__c sourceSalesOrder = (csmso__Sales_Order__c)source;

                // Update Opportunity to new Opp
                getOpportunitiesById(clonedSalesOrder.csmso__Opportunity__c) ;

                PropertyMappingEngine.FieldMappingPair[] fmps = new PropertyMappingEngine.FieldMappingPair[]{};
                PropertyMappingEngine.FieldMappingPair pair = new PropertyMappingEngine.FieldMappingPair();

                if (!opportunities.containsKey(clonedSalesOrder.csmso__Opportunity__c))
                {
                    throw new CustomCloneException('Could not find opportunity in map: ' + clonedSalesOrder.csmso__Opportunity__c);
                }

                System.debug('+++++ clonedSalesOrder: ' + clonedSalesOrder);

                pair.Source = (Opportunity)opportunities.get(clonedSalesOrder.csmso__Opportunity__c);
                pair.Destinations = new sObject[]{clonedSalesOrder};
                fmps.add(pair);
                sobject[] toUpdate = PropertyMappingEngine.mapsObjectFields('OppToSalesOrderCloning', fmps);

                clonedSalesOrder.Related_Sales_Order__c = source.id;

                clonedSalesOrder.csmso__Purchase_Order_Number__c = sourceSalesOrder.csmso__Purchase_Order_Number__c == 'Not required by Client' ? 'Not required by Client' : '';

                System.debug('+++++ OppToSalesOrderCloning applied to clonedSalesOrder: ' + clonedSalesOrder);
            }

            else if (apiName == 'cscfga__Product_Basket__c'){
                cscfga__Product_Basket__c basket = (cscfga__Product_Basket__c) clone;
                basket.cscfga__Basket_Status__c = 'Requires Update';
            }

            else if (apiName == 'cscfga__Product_Configuration__c'){
                cscfga__Product_Configuration__c config = (cscfga__Product_Configuration__c) clone;
                config.Sales_Order__c = [SELECT csmso__Sales_Order__c
                FROM cscfga__Product_Basket__c
                WHERE Id = :config.cscfga__Product_Basket__c
                LIMIT 1][0].csmso__Sales_Order__c;

                for(String fieldName : initValues.keySet()) {
                    config.put(fieldName, initValues.get(fieldName));
                }

                Map<String, Object> configData = cscfga.API_1.getProductConfigurations (new List<Id>{config.Id});
                List<cscfga__attribute__c> attributes = (List<cscfga__Attribute__c>) configData.get(config.Id + '-attributes');

                //get all attribute definitions for configPD
                Map<Id, cscfga__Attribute_Definition__c> attrDefinitionsMap = new Map<Id, cscfga__Attribute_Definition__c>(
                [SELECT Id, Custom_Cloning_Default_Value__c, Shadow_Default_Value__c
                FROM cscfga__Attribute_Definition__c
                WHERE cscfga__Product_Definition__c = :((cscfga__Product_Configuration__c)configData.get(config.Id)).cscfga__Product_Definition__c]);

                for(cscfga__attribute__c attribute : attributes) {
                    cscfga__Attribute_Definition__c attributeDefinition = attrDefinitionsMap.get(attribute.cscfga__Attribute_Definition__c);
                    if (attributeDefinition.Custom_Cloning_Default_Value__c == CUSTOM_CLONING_EMPTY) {
                        attribute.cscfga__Value__c = '';
                        attribute.cscfga__Display_Value__c = '';
                    }
                    else if (attributeDefinition.Custom_Cloning_Default_Value__c == CUSTOM_CLONING_CURRENT) {
                    }
                    else if (attributeDefinition.Custom_Cloning_Default_Value__c == CUSTOM_CLONING_DEFAULT) {
                        attribute.cscfga__Value__c = attributeDefinition.Shadow_Default_Value__c;
                    }
                }

                cscfga.API_1.updateProductConfigurations(configData);
            }

            else if (apiname == 'cscfga__Attribute__c') {
                cscfga__Attribute__c attr = (cscfga__Attribute__c)clone;

                if (attr.Custom_Cloning_Default_Value__c == CUSTOM_CLONING_EMPTY) {
                    attr.cscfga__Value__c = '';
                    attr.cscfga__Display_Value__c = '';
                }
                else if (attr.Custom_Cloning_Default_Value__c == CUSTOM_CLONING_CURRENT) {
                }
                else if (attr.Custom_Cloning_Default_Value__c == CUSTOM_CLONING_DEFAULT) {
                    attr.cscfga__Value__c = attr.AD_Default_Value__c;
                }
            }
        }
        catch (Exception ex)
        {
            // Log the error
            System.debug('Logging Exception:' + ex.getMessage());
            throw ex;
        }


        return clones;
    }

    /*****************************************************************************
    * Method Name : cloningFinished
    * Description : Used for upgrading the cloned product configurations using API
    * Parameters  : Boolean identifying whether the cloning was succesful or not
    * Return      : void
    *****************************************************************************/
    global void cloningFinished(Boolean success){

        // call upgrade products tool with a list of configs

    }

    /*************************************************************************************************
    * Method Name : getOpportunitiesToSO
    * Description : Used to retrive the Opportunities whose information should be clone to Sales Order
    * Parameters  : Sales Order Id
    * Return      : void
    *************************************************************************************************/
    @testVisible
    private void getOpportunitiesToSO(Id salesOrderId) {

        try
        {

            csmso__Sales_Order__c so = [SELECT Id, Name, csmso__Opportunity__c FROM csmso__Sales_Order__c WHERE Id = :salesOrderId];
            String oppId = so.csmso__Opportunity__c;
            sobjectHelper oppHelper = new sObjecthelper('Opportunity');
            String oppFields = oppHelper.getFieldListAsCSV(false);
            if (!String.isEmpty(oppFields)) {
                String opptyQuery = 'SELECT ' + oppFields + ' FROM Opportunity WHERE Id = :oppId';
                opportunities = new Map<Id, sObject>(Database.Query(opptyQuery));
            }

        }
        catch (Exception ex)
        {
            // Log the error
            System.debug('Logging Excetption:' + ex.getMessage());
            throw ex;
        }

    }

    /*************************************************************************************************
    * Method Name : getOpportunitiesToSO
    * Description : Used to retrive the Opportunities whose information should be clone to Sales Order
    * Parameters  : Sales Order Id
    * Return      : void
    *************************************************************************************************/
    @testVisible
    private void getOpportunitiesById(Id OpportunityId) {


        Map<Id, sObject> localMap;
        try
        {

            if (opportunities == null) opportunities = new Map<Id, sObject>();
            if (opportunities.containsKey(OpportunityId)) return;

            sobjectHelper oppHelper = new sObjecthelper('Opportunity');
            String oppFields = oppHelper.getFieldListAsCSV(false);
            if (!String.isEmpty(oppFields)) {
                String opptyQuery = 'SELECT ' + oppFields + ' FROM Opportunity WHERE Id = :OpportunityId';
                localMap = new Map<Id, sObject>(Database.Query(opptyQuery));
            }

            for (Id key : localMap.keyset())
            {
                opportunities.put(key,localmap.get(key));
            }


        }
        catch (Exception ex)
        {
            // Log the error
            System.debug('Logging Excetption:' + ex.getMessage());
            throw ex;
        }

    }

    global class CustomCloneException extends Exception {}

}