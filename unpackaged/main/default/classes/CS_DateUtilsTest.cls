@isTest(seeAllData=false)
private class CS_DateUtilsTest {
	@IsTest
	public static void convertToGMTTest() {
		CS_DateUtils dateUtils = new CS_DateUtils();

		String testDate = '2018-09-27 10:59:00 America/Mexico_City';
		Test.startTest();
		DateTime convertedTimeGTM = CS_DateUtils.getGMTTimeForTimezone(testDate);
		Test.stopTest();

		System.assertNotEquals(String.valueOfGmt(convertedTimeGTM), '2018-09-27 10:59:00');
	}
}