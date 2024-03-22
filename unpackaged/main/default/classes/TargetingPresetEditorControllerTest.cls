@isTest 
private class TargetingPresetEditorControllerTest {

	/**
	 * TargetingPresetEditorController Perform Action
	 */
	@isTest 
	static void testPerformAction() {
		String parameters = '{"targetType":"InitialData","parent":null,"product":null,"adServer":null,"data":{}}';
	
		Test.startTest();
		TargetingPresetEditorController.performAction('dummy', parameters);
		Test.stopTest();
	}

	/**
	 * TargetingPresetEditorController Perform Action
	 */
	@isTest 
	static void testPerformReadOnlyAction() {
		String parameters = '{"targetType":"InitialData","parent":null,"product":null,"adServer":null,"data":{}}';
	
		Test.startTest();
		TargetingPresetEditorController.performReadOnlyAction('dummy', parameters);
		Test.stopTest();
	}
}