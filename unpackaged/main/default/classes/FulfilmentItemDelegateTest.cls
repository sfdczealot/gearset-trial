@isTest
public class FulfilmentItemDelegateTest {  
    static csdf__Fulfilment__c getFulfilment() {
        return [SELECT id, name from csdf__Fulfilment__c LIMIT 1];
    }
    
    static csmso__Sales_Order__c getSalesOrder() {
        return [SELECT id, name from csmso__Sales_Order__c LIMIT 1];
    }
    
    static cscfga__Product_Configuration__c getProdConfig() {
        return [SELECT id, name from cscfga__Product_Configuration__c LIMIT 1];
    }
    
    static csdf__Fulfilment_Item__c getFulfilmentItem() {
        return [SELECT id, name, Long_Custom_Key_Targeting__c from csdf__Fulfilment_Item__c LIMIT 1];
    }
    
    static csdf__Ad_Slot__c getAdSlot() {
        return [SELECT id, name from csdf__Ad_Slot__c LIMIT 1];
    }

    static csdf__Ad_Server__c getAdServer() {
        return [SELECT id, name from csdf__Ad_Server__c LIMIT 1];
    }
    
    static csdf__Targetable__c getTargetable() {
        return [SELECT id, name from csdf__Targetable__c LIMIT 1];
    }
    
    static csdf__Targetable__c getTargetable_DeviceCategory() {
        return [SELECT id, name from csdf__Targetable__c where csdf__Type__c = 'Device Category' LIMIT 1];
    }
    
    static csdf__Site__c getSite() {
        return [SELECT id, name from csdf__Site__c LIMIT 1];
    }
    
    static csdf__Browser__c getBrowser() {
        return [SELECT id, name from csdf__Browser__c LIMIT 1];
    }
    
    static csdf__Operating_System__c getOperatingSystem() {
        return [SELECT id, name from csdf__Operating_System__c where Name = 'PlayStation3' LIMIT 1];
    }
    
    static csdf__Operating_System_Version__c getOperatingSystemVersion() {
        return [SELECT id, name from csdf__Operating_System_Version__c LIMIT 1];
    }
    
    static csdf__Geo_Item__c getGeoItem() {
        return [SELECT id, name from csdf__Geo_Item__c LIMIT 1];
    }

    @testsetup 
    static void setupCommonData() {
        CS_FulfilmentItemDelegateTest.setupCommonData();
    }

    @isTest
    public static void test_getFulfilmentIte() {
        CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.Fulfilment_Item_Propert_Map_Key__c = 'fitoattribute';
        settings.IgnoreCLT__c = false;
        settings.KeyValue_configuration__c = 'ID';
        insert settings;

        Id adServerId = getAdServer().Id;
        String dayPartTarg = 'Monday#0#24#Tuesday#2#24#Wednesday#2#24#Thursday#1#24#Friday#1#4#Friday#5#24#Saturday#0#2#Saturday#3#24#Sunday#0#24';

        csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(getProdConfig(), getSalesOrder(), getFulfilment() );
        testFulfilmentItem.Long_Custom_Key_Targeting__c = 'testLongCustomKeyTargeting is 123456789012345';
        testFulfilmentItem.Served_By__c = 'DFP';
        testFulfilmentItem.Booking_Timezone__c = 'Europe/London';
        testFulfilmentItem.csdf__Ad_Server_Id__c = adServerId;
        testFulfilmentItem.csdf__Day_Part_Targeting__c = dayPartTarg;
        testFulfilmentItem.Product_Configuration__c = getProdConfig().Id;
        //testFulfilmentItem.Ad_Slot__c = 'INCLUDE:'++';EXCLUDE:;';
        insert testFulfilmentItem;

        testFulfilmentItem = [SELECT id, name, Last_Action_from_DFP__c, Long_Custom_Key_Targeting__c from csdf__Fulfilment_Item__c where Id = :testFulfilmentItem.Id];

        csdf__Fulfilment__c fulfilment = getFulfilment();
        fulfilment.csdf__Ad_Server__c = adServerId;
        update fulfilment;

        //sd slot
        csdf__Ad_Slot__c adSlot = getAdSlot();
        adSlot.csdf__Ad_Server__c = adServerId;
        adSlot.csdf__Ad_Server_Id__c = (String) getAdServer().Id;
        adSlot.csdf__Active__c = true;
        UPDATE adSlot;

        csdf__Ad_Slot_Targeting__c adSlotTargeting = new csdf__Ad_Slot_Targeting__c();
        adSlotTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        adSlotTargeting.csdf__Ad_Slot__c = adSlot.Id;
        INSERT adSlotTargeting;

        csdf__Ad_Server__c adserver = [select id, name from csdf__Ad_Server__c];
        //browser
        csdf__Browser__c browser = new csdf__Browser__c();
        browser.csdf__Ad_Server_Id__c = '500083';
        browser.csdf__Browser_Name__c = 'Firefox';
        browser.csdf__Ad_Server__c = adserver.Id;
        insert browser;

        csdf__Browser_Targeting__c browserTargeting = new csdf__Browser_Targeting__c();
        browserTargeting.csdf__Fulfilment_Item__c = testFulfilmentItem.Id;
        browserTargeting.csdf__Browser__c = browser.Id;
        INSERT browserTargeting;

        // create Advert Assignment (csmso__Node_Advert_Assignment__c)
        csmso__Node_Advert_Assignment__c advertAssignment = new csmso__Node_Advert_Assignment__c();
        advertAssignment.Name = 'Test Market';
        advertAssignment.Product_Name__c = 'Test Product Name';
        advertAssignment.Rate_Type__c = 'CPM';
        advertAssignment.Rate_Type_Display__c = 'CPCV';
        advertAssignment.Line_Item_Type__c = 'Standard';
        advertAssignment.Inventory_sizes__c = '1000x1000';
        advertAssignment.Unique_Id__c = 'someUniqueTestId';
        advertAssignment.Product_Category__c = 'Standard Products';
        advertAssignment.Product_Group__c = 'Audio';
        advertAssignment.Line_Item_Category__c = 'House';
        advertAssignment.Product_Family__c = 'Audio';
        advertAssignment.Served_by__c = 'DFP';
        advertAssignment.Ad_Slot__c = 'Test Ad Slot';
        advertAssignment.Ad_Location_Description__c = 'Everywhere';
        advertAssignment.Ad_Server__c = adServerId;
        advertAssignment.Ad_Slot_Names__c = 'SPT_AD_Unit';
        advertAssignment.Invoice_GL_Code__c = '123456789';
        advertAssignment.Rev_Accrual_GL_Code__c = '123456789';
        advertAssignment.Priority__c = '6';
        insert advertAssignment;

        adSlotTargeting = [SELECT id, csdf__Fulfilment_Item__c, csdf__Ad_Slot__c from csdf__Ad_Slot_Targeting__c where Id = :adSlotTargeting.Id];
        
        Test.startTest();

        /*FulfilmentItemDelegate. params = new FulfilmentItemDelegate.KvaParams();
        params.fulfilmentItemId = testFulfilmentItem.Id;
        FulfilmentItemDelegate delegate = new FulfilmentItemDelegate();
        delegate.performAction(JSON.serialize(new List<FulfilmentItemDelegate.KvaParams>{params}));

        params = new FulfilmentItemDelegate.KvaParams();
        params.kva = testFulfilmentItem.Long_Custom_Key_Targeting__c;
        params.naa = advertAssignment.Id;

        delegate = new FulfilmentItemDelegate();
        delegate.performAction(JSON.serialize(new List<FulfilmentItemDelegate.KvaParams>{params}));
        */

        String parameters = JSON.serialize(new List<Id>{getProdConfig().Id});

        FulfilmentItemDelegate fulfilmentItemDelegate = new FulfilmentItemDelegate();
        String returnJSON = fulfilmentItemDelegate.performAction(parameters);

        Test.stopTest();        
    }
}