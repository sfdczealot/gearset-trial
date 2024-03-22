@isTest
private class RootPathBatchSchedulerTest {
    
    @testsetup 
    static void setupCommonData(){
        
        // insert test root path jobs;
        insert new List<Targeting_Widget_Root_Path__c>{
            new Targeting_Widget_Root_Path__c (
                Name = 'Ad Slot',
                Object_API_Name__c = 'csdf__Ad_Slot__c',
                Targeting_Widget_Hierarchy_Depth_Limit__c = 9
            ),
            new Targeting_Widget_Root_Path__c (
                Name = 'Geo Item',
                Object_API_Name__c = 'csdf__Geo_Item__c',
                Targeting_Widget_Hierarchy_Depth_Limit__c = 9
            ),
            new Targeting_Widget_Root_Path__c (
                Name = 'Operating System Version',
                Object_API_Name__c = 'csdf__Operating_System_Version__c',
                Targeting_Widget_Hierarchy_Depth_Limit__c = 1
            ),
            new Targeting_Widget_Root_Path__c ( 
                Name = 'Targetable',
                Object_API_Name__c = 'csdf__Targetable__c',
                Targeting_Widget_Hierarchy_Depth_Limit__c = 1
            )
        };
        
        csdf__Ad_Slot__c testAdUnitsAdSlotRoot = TestDataSetupTargetables.createAdSlot();
        testAdUnitsAdSlotRoot.csdf__Ad_Server_Id__c = '0';
        insert testAdUnitsAdSlotRoot;
        
        csdf__Ad_Slot__c testPlacementsAdSlotRoot = TestDataSetupTargetables.createAdSlot();
        testPlacementsAdSlotRoot.csdf__Ad_Server_Id__c = '1';
        insert testPlacementsAdSlotRoot;
    }

    @isTest
    static void testRootPathData_Bulk(){
            
        csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
        insert testAdServer;

        // insert test csdf__Operating_System_Version__c data;
        csdf__Operating_System__c testOSParent = TestDataSetupTargetables.createOS(testAdServer);
        insert testOSParent;

        csdf__Operating_System_Version__c testOSVersionChild = TestDataSetupTargetables.createOSVer(testOSParent);
        insert testOSVersionChild;
        
        // insert test csdf__Targetable__c data;
        csdf__Targetable__c testTargetableParent = TestDataSetupTargetables.createTargetable(testAdServer);
        insert testTargetableParent;
        
        csdf__Targetable__c testTargetableChild = TestDataSetupTargetables.createTargetable(testAdServer);
        testTargetableChild.Targetable_Parent__c = testTargetableParent.Id;
        insert testTargetableChild;
        
        // insert test csdf__Geo_Item__c data;
        List<csdf__Geo_Item__c> testGeoItemsList = new List<csdf__Geo_Item__c>();
        List<csdf__Geo_Item_Assignment__c> testGeoItemAssignmentsList = new List<csdf__Geo_Item_Assignment__c>();
        for (Integer i = 0; i < 12; i++){
            testGeoItemsList.add(TestDataSetupTargetables.createGeoItem());
        }
        insert testGeoItemsList;
        for (Integer i = 1; i < 10; i++){
            testGeoItemAssignmentsList.add(new csdf__Geo_Item_Assignment__c( 
                csdf__Geo_Item_Parent__c = testGeoItemsList[i - 1].Id,
                csdf__Geo_Item_Child__c = testGeoItemsList[i].Id
            ));
        }
        for (Integer i = 10; i < 12; i++){
            testGeoItemAssignmentsList.add(new csdf__Geo_Item_Assignment__c( 
                csdf__Geo_Item_Parent__c = testGeoItemsList[8].Id,
                csdf__Geo_Item_Child__c = testGeoItemsList[i].Id
            ));
        }
        insert testGeoItemAssignmentsList;

        // insert test placement csdf__Ad_Slot__c data;
        csdf__Ad_Slot__c testPlacementAdSlotParent = TestDataSetupTargetables.createAdSlot();
        testPlacementAdSlotParent.csdf__Type__c = 'Placement';
        insert testPlacementAdSlotParent;
        
        csdf__Ad_Slot__c testPlacementAdSlotChild = TestDataSetupTargetables.createAdSlot();
        testPlacementAdSlotChild.csdf__Type__c = 'Placement';
        insert testPlacementAdSlotChild;

        insert new csdf__Ad_Slot_Assignment__c( 
            csdf__Ad_Slot_Parent__c = testPlacementAdSlotParent.Id,
            csdf__Ad_Slot_Child__c = testPlacementAdSlotChild.Id
        );
        
        // insert test ad unit csdf__Ad_Slot__c data;
        csdf__Ad_Slot__c testAdUnitAdSlotParent = TestDataSetupTargetables.createAdSlot();
        testAdUnitAdSlotParent.csdf__Type__c = 'Ad Unit';
        insert testAdUnitAdSlotParent;
        
        csdf__Ad_Slot__c testAdUnitAdSlotChild = TestDataSetupTargetables.createAdSlot();
        testAdUnitAdSlotChild.csdf__Type__c = 'Ad Unit';
        insert testAdUnitAdSlotChild;

        insert new csdf__Ad_Slot_Assignment__c( 
            csdf__Ad_Slot_Parent__c = testAdUnitAdSlotParent.Id,
            csdf__Ad_Slot_Child__c = testAdUnitAdSlotChild.Id
        );

        Test.startTest();
            (new RootPathBatchScheduler()).execute(null);
        Test.stopTest();
        
        csdf__Ad_Slot__c testAdUnitsAdSlotRoot = [SELECT Id FROM csdf__Ad_Slot__c WHERE csdf__Ad_Server_Id__c = '0'][0];
        csdf__Ad_Slot__c testPlacementsAdSlotRoot = [SELECT Id FROM csdf__Ad_Slot__c WHERE csdf__Ad_Server_Id__c = '1'][0];

        testOSVersionChild = [SELECT Id, Parent_Node_Id__c, Root_Path__c, Top_Level_Node__c FROM csdf__Operating_System_Version__c WHERE Id = :testOSVersionChild.Id][0];
        System.assertEquals(false, testOSVersionChild.Top_Level_Node__c);
        System.assertEquals(String.valueOf(testOSVersionChild.Parent_Node_Id__c), String.valueOf(testOSVersionChild.Root_Path__c).substring(0, 15));

        testAdUnitAdSlotParent = [SELECT Id, csdf__Type__c, Root_Path__c, Top_Level_Node__c FROM csdf__Ad_Slot__c WHERE Id = :testAdUnitAdSlotParent.Id][0];
        System.assertEquals(false, testAdUnitAdSlotParent.Top_Level_Node__c);
        System.assertEquals(String.valueOf(testAdUnitsAdSlotRoot.Id), testAdUnitAdSlotParent.Root_Path__c);

        testAdUnitAdSlotChild = [SELECT Id, csdf__Type__c, Root_Path__c, Top_Level_Node__c FROM csdf__Ad_Slot__c WHERE Id = :testAdUnitAdSlotChild.Id][0];
        System.assertEquals(false, testAdUnitAdSlotChild.Top_Level_Node__c);
        System.assertEquals(String.valueOf(testAdUnitsAdSlotRoot.Id) + ',' + String.valueOf(testAdUnitAdSlotParent.Id), testAdUnitAdSlotChild.Root_Path__c);
        
        testPlacementAdSlotParent = [SELECT Id, csdf__Type__c, Root_Path__c, Top_Level_Node__c FROM csdf__Ad_Slot__c WHERE Id = :testPlacementAdSlotParent.Id][0];
        System.assertEquals(false, testPlacementAdSlotParent.Top_Level_Node__c);
        System.assertEquals(String.valueOf(testPlacementsAdSlotRoot.Id), testPlacementAdSlotParent.Root_Path__c);

        testPlacementAdSlotChild = [SELECT Id, csdf__Type__c, Root_Path__c, Top_Level_Node__c FROM csdf__Ad_Slot__c WHERE Id = :testPlacementAdSlotChild.Id][0];
        System.assertEquals(false, testPlacementAdSlotChild.Top_Level_Node__c);
        System.assertEquals(String.valueOf(testPlacementsAdSlotRoot.Id), testPlacementAdSlotChild.Root_Path__c);
        
        for (Integer i = 0; i < 12; i++){
            testGeoItemsList[i] = [SELECT Id, Root_Path__c, Top_Level_Node__c FROM csdf__Geo_Item__c WHERE Id = :testGeoItemsList[i].Id][0];
        }

        System.assertEquals(true, testGeoItemsList[0].Top_Level_Node__c);
        System.assertEquals(null, testGeoItemsList[0].Root_Path__c);

        String geoTempRootPath = String.valueOf(testGeoItemsList[0].Id);
        String geoTempRootPathPrevious = geoTempRootPath;
        for (Integer i = 1; i < 10; i++){
            System.assertEquals(false, testGeoItemsList[i].Top_Level_Node__c);
            System.assertEquals(geoTempRootPath, testGeoItemsList[i].Root_Path__c);
            geoTempRootPathPrevious = geoTempRootPath;
            geoTempRootPath = geoTempRootPath + ',' + String.valueOf(testGeoItemsList[i].Id);
        }
        for (Integer i = 10; i < 12; i++){
            System.assertEquals(false, testGeoItemsList[i].Top_Level_Node__c);
            System.assertEquals(geoTempRootPathPrevious, testGeoItemsList[i].Root_Path__c);
        }
    }
    
    @isTest
    static void testRootPathBatchScheduler(){
        Test.startTest();
        	RootPathBatchScheduler.scheduleIt();
        Test.stopTest();
    }
}