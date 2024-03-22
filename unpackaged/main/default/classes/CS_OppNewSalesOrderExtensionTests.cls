@isTest
private class CS_OppNewSalesOrderExtensionTests {

  

    static testMethod void testValidToCreate() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        List<Account> accounts = TestDataSetupSO.createAccounts(1);
        List<Contact> contacts = TestDataSetupSO.createContacts(1, accounts);
        List<Opportunity> opportunities = TestDataSetupSO.createOpportunities(1, accounts, contacts);
       
        
        id oppId = opportunities[0].id;
        
        Opportunity opp = [select Id, SO_Creation_Allowed__c,Primary_Salesperson__c from Opportunity where Id = :oppId];
        system.assert(opp.SO_Creation_Allowed__c);
        
        
        PageReference pageRef = Page.Opportunity;
        Test.setCurrentPage(pageRef);

        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(opp);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        test.startTest();
        CS_OppNewSalesOrderExtension oppExtensions = new CS_OppNewSalesOrderExtension(stdController);
        
        PageReference pr = oppExtensions.NewSalesorder();
        test.stopTest();
        
    }
    
    static testMethod void testNOTValidToCreate() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());
        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;
        
        List<Account> accounts = TestDataSetupSO.createAccounts(1);
        List<Contact> contacts = TestDataSetupSO.createContacts(1, accounts);
        List<Opportunity> opportunities = TestDataSetupSO.createOpportunities(1, accounts, contacts);
        List<csmso__Sales_Order__c> salesOrders = TestDataSetupSO.createSalesOrders(1, accounts, opportunities);
         // create Ad Server (csdf__Ad_Server__c)
        csdf__Ad_Server__c adServer = new csdf__Ad_Server__c();
        adServer.Name = 'Test Ad Server';
        adServer.csdf__Type__c = 'DFP';
        adServer.csdf__Network_Code__c = 'Test Network Code';
        adServer.csdf__Network_Name__c = 'Test Network Name';
        adServer.csdf__Description__c = '‚Test Ad Server Description';
        adServer.csdf__Client_Id__c = 'Test Client Id';
        adServer.csdf__Client_Secret__c = 'Test Client Secret';
        adServer.csdf__Refresh_Token__c = 'Test Refresh Token';
        insert adServer;
        
        csdf__buyer__c buyer = new csdf__buyer__c();
        buyer.csdf__Name__c = 'Test1234';
        buyer.csdf__Ad_Server_id__c = 'xx12';
        buyer.csdf__Ad_Server__c = adServer.Id;
        insert buyer;
        
        
       id oppId = opportunities[0].id;
       
               
       
       
        Opportunity opp = [select Id, Primary_Sales_Order__c, SO_Creation_Allowed__c, Primary_Salesperson__c from Opportunity where Id = :oppId];
        opp.Order_type__c = 'Programmatic Guaranteed';
        opp.Primary_Sales_Order__c = salesorders[0].id;
        opp.Buyer__c = buyer.id;
        update opp;
        opp = [select Id, Primary_Sales_Order__c, SO_Creation_Allowed__c, Primary_Salesperson__c from Opportunity where Id = :opportunities[0].id];
        
       system.debug('### Opp is ' +opp );
        //system.assert(!opp.SO_Creation_Allowed__c);
        
        
        PageReference pageRef = Page.Opportunity;
        Test.setCurrentPage(pageRef);

        ApexPages.Standardcontroller stdController = new ApexPages.Standardcontroller(opp);
        ApexPages.currentPage().getParameters().put('id', opp.Id);
        
        test.startTest();
        CS_OppNewSalesOrderExtension oppExtensions = new CS_OppNewSalesOrderExtension(stdController);
        
        PageReference pr = oppExtensions.NewSalesorder();
        //system.assert(pr == null);
        test.stopTest();
        
    }
}