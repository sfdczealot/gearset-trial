@isTest 
private class CS_GetPlaylistKeyvaluesTest {

	@isTest
	static void test_getplaylistkeyvalues() {
		CS_Custom_Settings__c settings = new CS_Custom_Settings__c();
        settings.DFP_Playlist_Folder__c = 'context';
        insert settings;

        cscfga__Product_Category__c testProdCateg = TestDataSetupTargetables.createProdCateg();
        insert testProdCateg;
        
        cscfga__Product_Definition__c testProDef = TestDataSetupTargetables.createProDef(testProdCateg);
        insert testProDef;
        
        cscfga__Attribute_Definition__c testAttrDef = TestDataSetupTargetables.createAttrDef(testProDef);        
        insert testAttrDef;
        
        Account acc = TestDataSetupTargetables.createAccount();
        insert acc;
        
        Contact con = TestDataSetupTargetables.createContact(acc);
        insert con;
        
        Opportunity opp = TestDataSetupTargetables.createOpportunity(acc, con);
        insert opp;
        
        csmso__Sales_Order__c so = TestDataSetupTargetables.createSalesOrder(acc, opp);
        insert so;

        String playlistName = 'spotify:playlist:37i9dQZF1DXcF6B6QPhFDv';

        csdf__Ad_Server__c adServer = new csdf__Ad_Server__c();
        adServer.Name = 'Newsday DFP Production';
        adServer.csdf__Network_Code__c = '5819';
        adServer.csdf__Username__c = 'userTest';
        adServer.csdf__Password__c = 'userPass';
        insert adServer;

        //targeting key
        csdf__Custom_Targeting_Key__c custTargKey = new csdf__Custom_Targeting_Key__c();
        custTargKey.Name = 'context';
        custTargKey.csdf__Display_Name__c = 'specific playlists for sponsorship';
        custTargKey.csdf__Ad_Server__c = adServer.Id;
        custTargKey.csdf__Type__c = 'Freeform';
        custTargKey.csdf__Ad_Server_Id__c = (String) adServer.Id;
        INSERT custTargKey;

        csdf__Custom_Targeting_Value__c custTargValue = new csdf__Custom_Targeting_Value__c();
        custTargValue.csdf__Custom_Targeting_Key__c = custTargKey.Id;
        custTargValue.Name = playlistName;
        custTargValue.csdf__Display_Name__c = playlistName;
        custTargValue.csdf__Ad_Server_Id__c = (String) adServer.Id;
        INSERT custTargValue;

        Map<String, Object> params = new Map<String, Object>();
        params.put('salesOrders', so.Id);
        params.put('adServerId', adServer.Id);

        Test.startTest();
        CS_GetPlaylistKeyvalues getPlaylistHandler = new CS_GetPlaylistKeyvalues();
        getPlaylistHandler.performAction(JSON.serialize(params));
        Test.stopTest();
	}
}