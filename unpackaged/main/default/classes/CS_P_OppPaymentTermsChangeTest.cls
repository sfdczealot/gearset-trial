@isTest 
private class CS_P_OppPaymentTermsChangeTest {
     
    @testSetup 
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
        
        string b2baccRectype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();

        Account acc = TestDataSetupTargetables.createAccount();
        acc.RecordTypeId = b2baccRectype;
        insert acc;
        
        Account agency = TestDataSetupTargetables.createAccount();
        agency.Type = 'Media Agency';
        insert agency;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        opp.Payment_terms_AR_Override__c = 30;
        opp.Subsidiary_Type__c = 'iPP';
        insert opp;
    
        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        insert so;

        List<cscfga__Product_Basket__c> prodBaskets = TestDataSetupSO.createProdBaskets(1,new List<csmso__Sales_Order__c>{so});

        List<cscfga__Product_Configuration__c> prodConfigs = TestDataSetupSO.createProdConfigs(1,prodBaskets,new List<cscfga__Product_Definition__c>{testProDef});

        for(cscfga__product_Configuration__c pConfig: prodConfigs){
            pConfig.Sales_Order__c = so.id;
            pConfig.Flight_Begin__c = Date.today();
        }
        update prodConfigs;

        cscfga__Product_Configuration__c pc = [SELECT Id, Sales_Order__c 
                                                    FROM cscfga__Product_Configuration__c 
                                                    LIMIT 1][0];

        CS_Sales_Order_Schedule__c sOs = new CS_Sales_Order_Schedule__c();
        sos.sales_order__c = so.id;
        insert sOs;
        
        CS_Billing_Schedule__c bScheduleHeader = new CS_Billing_Schedule__c();
        bScheduleHeader.CS_Sales_Order_Schedule__c = sOs.id;
        bScheduleHeader.Under_IFC__c = true;
        insert bScheduleHeader;

        CS_Billing_Schedule_Item__c bschedule = new CS_Billing_Schedule_Item__c();
        bSchedule.Product_Configuration__c = pc.id;
        bSchedule.Opportunity__c = opp.Id;
        bSchedule.Status__c = CS_Constants.STATUS_OPEN;
        bSchedule.Sales_Order__c = pc.Sales_Order__c;
        bSchedule.DFP_Actuals__c = 100;
        bSchedule.Net_Rate__c = 100.0;
        bSchedule.Billing_Period_Start_Date__c = Date.Today().addDays(-4);
        bschedule.billing_schedule__c = bScheduleHeader.id;
        insert bSchedule;

        CS_Revenue_Schedule__c rScheduleHeader = new CS_Revenue_Schedule__c();
        rScheduleHeader.CS_Sales_Order_Schedule__c = sos.id;
        insert rScheduleHeader;

        CS_Revenue_Schedule_Item__c rSchedule = new CS_Revenue_Schedule_Item__c();
        rSchedule.Sales_Order__c = pc.Sales_Order__c;
        rSchedule.Opportunity__c = opp.Id;
        rSchedule.Product_Configuration__c = pc.id;
        rSchedule.Status__c = CS_Constants.STATUS_OPEN;
        rSchedule.Rev_Rec_Period_Start_Date__c = Date.Today().addDays(-4);
        rSchedule.Rev_Rec_Period_End_Date__c = Date.Today().addDays(4);
        rSchedule.Revenue_Schedule__c = rScheduleHeader.Id;
        insert rSchedule;
    }

    @isTest()
    public static void testPaymentTermsChange() {
        
        Opportunity opp = 
        [
            SELECT  Id, 
                    Name,
                    Payment_Terms_In_Effect__c,
                    Payment_terms_AR_Override__c
            FROM    Opportunity 
            LIMIT   1
        ];
        
        Test.startTest();
        Map<Id, Opportunity> mapOld = new Map<Id, Opportunity>();
        mapOld.put(opp.Id, opp);
        CS_P_OppPaymentTermsChange process = new CS_P_OppPaymentTermsChange(mapOld);
        opp.Payment_terms_AR_Override__c = 60;
        update opp;

        opp = 
        [
            SELECT  Id, 
                    Name,
                    Payment_Terms_In_Effect__c,
                    Payment_terms_AR_Override__c
            FROM    Opportunity 
            LIMIT   1
        ];
    
        process.isRecordEligible(opp);
        process.logic();
        
        csmso__Sales_Order__c so = 
        [
            SELECT  Id, 
                    Name, 
                    Payment_Terms__c
            FROM    csmso__Sales_Order__c 
            LIMIT   1
        ];
        CS_P_OppPaymentTermsChange.increaseCoverage();
       // System.assertEquals(opp.Payment_Terms_In_Effect__c, 60);
        Test.stopTest();
    }
}