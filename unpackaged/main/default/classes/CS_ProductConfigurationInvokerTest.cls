/**
 * Created by tvrtko.matosevic on 15/07/2019.
 */

@IsTest
private class CS_ProductConfigurationInvokerTest {
    @IsTest
    static void testInvokeProductConfigurationInvoker() {
        Test.startTest();
        Account acc = TestDataSetupSO.createAccount();
        insert acc;

        Contact con = TestDataSetupSO.createContact(acc);
        insert con;

        Opportunity opp = TestDataSetupSO.createOpportunity(acc, con);
        insert opp;

        csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
        salesOrder.csmso__Opportunity__c = opp.Id;
        salesOrder.csmso__Status__c = StandardSalesOrderStateManager.SO_BOOKED;
        salesOrder.SO_Lines_Ad_Server_Items__c = 2;
        salesOrder.Reason_for_Retraction__c = 'Optimization request by Spotify';
        salesOrder.Last_Date_Retracted__c = Date.today();
        salesOrder.Last_Date_Booked__c = Date.today().addDays(-1);
        salesOrder.csmso__Advertiser__c = acc.Id;
        salesOrder.Advertiser_Final__c = acc.Id;
        insert salesOrder;

        //Product Definition Creation.
        List<cscfga__Product_Definition__c> prodDef = TestDataSetupSO.createProductDefinitions(1);
        prodDef[0].Name = 'Digital DFP Spotify v1.6';
        update prodDef;

        //Attribute definition Creation.
        List<cscfga__Attribute_Definition__c> attDefs = TestDataSetupSO.createAttributeDefinitions(1, prodDef);
        attDefs[0].Name = 'Keyvalues and Audience JSON';
        update attDefs;

        //Product Baskets  Creation.
        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1, new List<csmso__Sales_Order__c>{
                salesOrder/*, salesOrder1*/
        });

        //Product Configs creation.
        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1, prodBaskets, prodDef);

        Test.stopTest();

        System.debug('prodConfigs[0].Id => ' + prodConfigs[0].Id);

        CS_ProductConfigurationInvoker productConfigurationInvoker = new CS_ProductConfigurationInvoker();
        String pcJSON = productConfigurationInvoker.performAction(JSON.serialize(prodConfigs[0].Id));

        System.assert(!String.isEmpty(pcJSON));
    }
}