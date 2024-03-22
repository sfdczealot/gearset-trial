@isTest 
private class CS_P_OppBookingContactChangeTest {
    private static Account acc;
    private static Account acc2;
    private static Opportunity opp;
     
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
        
        acc = TestDataSetupTargetables.createAccount();
        acc2 = TestDataSetupTargetables.createAccount();
        List<Account> accToInsert = new List<Account>{acc, acc2};
        insert accToInsert;
        
        Account agency = TestDataSetupTargetables.createAccount();
        agency.Type = 'Media Agency';
        insert agency;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.SO_Booking_Contact__c = con.Id;
        insert opp;
    
        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        insert so;
    }

    @isTest()
    public static void testBookingContactChange() {
        testSetup();

        Opportunity opp = 
        [
            SELECT  Id, 
                    Name,
                    SO_Booking_Contact__c
            FROM    Opportunity 
            LIMIT   1
        ];

        Contact con2 = TestDataSetupTargetables.createContact(acc2);
        con2.firstName = 'NEW';
        insert con2;
        
        Test.startTest();
        Map<Id, Opportunity> mapOld = new Map<Id, Opportunity>();
        mapOld.put(opp.Id, opp);
        CS_P_OppBookingContactChange process = new CS_P_OppBookingContactChange(mapOld);
        process.applicableObjects = mapOld;
        opp.SO_Booking_Contact__c = con2.Id;
        update opp;

        opp = 
        [
            SELECT  Id, 
                    Name,
                    SO_Booking_Contact__c
            FROM    Opportunity 
            LIMIT   1
        ];
    
        process.isRecordEligible(opp);
        process.logic();
        
        csmso__Sales_Order__c so = 
        [
            SELECT  Id, 
                    Name, 
                    csmso__Booking_Contact__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];
        
        System.assertEquals(opp.SO_Booking_Contact__c, so.csmso__Booking_Contact__c);
        Test.stopTest();
    }
}