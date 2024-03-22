@IsTest
private class CS_CustomSettingsInvokerTest {
	@IsTest
	static void testInvokingCSCustomSettingsInvoker() {
		CS_CustomSettingsInvoker csCustomSettingsInvoker = new CS_CustomSettingsInvoker();
		String response = csCustomSettingsInvoker.performAction(null);
		System.assert(response != null);
	}
}