@isTest 
private class CS_P_OppPrimaryTraffickerChangeTest {
    private static csdf__User__c primaryTrafficker2;
     
    static void testSetup() {
        CS_utl_User.disableAllTriggers(UserInfo.getUserId());

        csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
        insert soapi;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;

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

        csdf__User__c primaryTrafficker1 = new csdf__User__c();
        primaryTrafficker1.Name = 'Primary Trafficker';
        primaryTrafficker1.csdf__Ad_Server__c = adServer.Id;
        primaryTrafficker1.csdf__Ad_Server_Id__c = '123456789';
        insert primaryTrafficker1;

        primaryTrafficker2 = new csdf__User__c();
        primaryTrafficker2.Name = 'Primary Trafficker';
        primaryTrafficker2.csdf__Ad_Server__c = adServer.Id;
        primaryTrafficker2.csdf__Ad_Server_Id__c = '987654321';
        insert primaryTrafficker2;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.SO_Booking_Contact__c = con.Id;
        opp.Ad_Server__c = adServer.Id;
        insert opp;
    
        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        insert so;
    }

    @isTest()
    public static void testPrimaryTraffickerChange() {
        testSetup();

        Opportunity opp = 
        [
            SELECT  Id, 
                    Name
            FROM    Opportunity 
            LIMIT   1
        ];
        
        Test.startTest();
        Map<Id, Opportunity> mapOld = new Map<Id, Opportunity>();
        mapOld.put(opp.Id, opp);
        CS_P_OppPrimaryTraffickerChange process = new CS_P_OppPrimaryTraffickerChange(mapOld);
        process.applicableObjects = mapOld;
        //opp.Primary_Trafficker__c = primaryTrafficker2.Id;
        update opp;

        opp = 
        [
            SELECT  Id, 
                    Name
            FROM    Opportunity 
            LIMIT   1
        ];
    
        process.isRecordEligible(opp);
        process.logic();
        
        csmso__Sales_Order__c so = 
        [
            SELECT  Id, 
                    Name, 
                    Ad_Server_Trafficker__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];
        
        /*System.assertEquals(opp.Primary_Trafficker__c, so.Ad_Server_Trafficker__c);*/
        Test.stopTest();
    }
}