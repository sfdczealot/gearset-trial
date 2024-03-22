@isTest
private class ConnectToRootControllerTest {
    
    @isTest static void TestConnectToRootController() {

        csdf__Ad_Server__c testAdServer = new csdf__Ad_Server__c();
        testAdServer.csdf__Username__c = 'testUsername';
        testAdServer.csdf__Password__c = 'testPassword';
        testAdServer.csdf__Network_Code__c = 'testNetworkCode';
        insert testAdServer;

        csdf__Ad_Slot__c adunitRoot = new csdf__Ad_Slot__c();
        adunitRoot.csdf__Name__c = 'Ad Units';
        adunitRoot.csdf__Ad_Server_Id__c = testAdServer.id;
        adunitRoot.csdf__Code__c ='TestCode';
        insert adunitRoot;

        csdf__Ad_Slot__c placementsRoot = new csdf__Ad_Slot__c();
        placementsRoot.csdf__Name__c = 'Placements';
        placementsRoot.csdf__Ad_Server_Id__c = testAdServer.id;
        placementsRoot.csdf__Code__c ='TestCode';
        insert placementsRoot;

        csdf__Ad_Slot__c adUnit = new csdf__Ad_Slot__c();
        adUnit.csdf__Name__c = 'testName1';
        adUnit.csdf__Type__c = 'Ad Unit';
        adUnit.csdf__Ad_Server_Id__c = testAdServer.id;
        adUnit.csdf__Code__c ='TestCode';
        insert adUnit;

        csdf__Ad_Slot__c placement = new csdf__Ad_Slot__c();
        placement.csdf__Name__c = 'testName2';
        placement.csdf__Type__c = 'Placement';
        placement.csdf__Ad_Server_Id__c = testAdServer.id;
        placement.csdf__Code__c ='TestCode';
        insert placement;

        ApexPages.StandardController sc = new ApexPages.StandardController(new csdf__Ad_Server__c());
        ConnectToRootController ctrc = new ConnectToRootController(sc); 
        ctrc.connectRoots();
    }

    
    
    
}