/**
 * @name CS_utl_ComparisonTest
 * @description Test for 
 * @revision
 *
 */
@isTest
public class CS_utl_ComparisonTest {
	/**
	 * Tests compare booleans
	 */
	@isTest
	public static void test_compareBooleans() {
		Test.startTest();
		
		System.assertEquals(CS_utl_Comparison.Comparison.EQUALS, CS_utl_Comparison.compare(true, true));
		System.assertEquals(CS_utl_Comparison.Comparison.EQUALS, CS_utl_Comparison.compare(false, false));
		System.assertEquals(CS_utl_Comparison.Comparison.NOT_EQUALS, CS_utl_Comparison.compare(true, false));
		
		Test.stopTest();
	}
	
	/**
	 * Tests compare dates
	 */
	@isTest
	public static void test_compareDates() {
		Test.startTest();
		
		System.assertEquals(CS_utl_Comparison.Comparison.EQUALS, CS_utl_Comparison.compare(Date.today(), Date.today()));
		System.assertEquals(CS_utl_Comparison.Comparison.LESS_THAN, CS_utl_Comparison.compare(Date.today(), Date.today().addDays(5)));
		System.assertEquals(CS_utl_Comparison.Comparison.GREATER_THAN, CS_utl_Comparison.compare(Date.today(), Date.today().addDays(-5)));
		
		Test.stopTest();
	}
	
	/**
	 * Tests compare times
	 */
	@isTest
	public static void test_compareTimes() {
		Test.startTest();
		
		System.assertEquals(CS_utl_Comparison.Comparison.EQUALS, CS_utl_Comparison.compare(Time.newInstance(1, 0, 0, 0), Time.newInstance(1, 0, 0, 0)));
		System.assertEquals(CS_utl_Comparison.Comparison.LESS_THAN, CS_utl_Comparison.compare(Time.newInstance(1, 0, 0, 0), Time.newInstance(2, 0, 0, 0)));
		System.assertEquals(CS_utl_Comparison.Comparison.GREATER_THAN, CS_utl_Comparison.compare(Time.newInstance(1, 0, 0, 0), Time.newInstance(0, 1, 0, 0)));
		
		Test.stopTest();
	}
	
	/**
	 * Tests compare datetimes
	 */
	@isTest
	public static void test_compareDateTimes() {
		Test.startTest();
		
		System.assertEquals(CS_utl_Comparison.Comparison.EQUALS, CS_utl_Comparison.compare(Datetime.now(), Datetime.now()));
		System.assertEquals(CS_utl_Comparison.Comparison.LESS_THAN, CS_utl_Comparison.compare(Datetime.now(), Datetime.now().addDays(5)));
		System.assertEquals(CS_utl_Comparison.Comparison.GREATER_THAN, CS_utl_Comparison.compare(Datetime.now(), Datetime.now().addDays(-5)));
		
		Test.stopTest();
	}
	
	/**
	 * Tests compare numbers
	 */
	@isTest
	public static void test_compareNumbers() {
		Test.startTest();
		
		System.assertEquals(CS_utl_Comparison.Comparison.EQUALS, CS_utl_Comparison.compare((Decimal) 5, (Decimal) 5));
		System.assertEquals(CS_utl_Comparison.Comparison.LESS_THAN, CS_utl_Comparison.compare((Decimal) 5, (Decimal) 10));
		System.assertEquals(CS_utl_Comparison.Comparison.GREATER_THAN, CS_utl_Comparison.compare((Decimal) 5, (Decimal) 1));
		
		Test.stopTest();
	}
	
	/**
	 * Tests compare ids
	 */
	@isTest
	public static void test_compareIds() {
		Id firstId = CS_utl_Id.getFakeId(Account.getSobjectType());
		Id secondId = CS_utl_Id.getFakeId(Account.getSobjectType());
		
		Test.startTest();
		
		System.assertEquals(CS_utl_Comparison.Comparison.EQUALS, CS_utl_Comparison.compare(firstId, firstId));
		System.assertEquals(CS_utl_Comparison.Comparison.NOT_EQUALS, CS_utl_Comparison.compare(firstId, secondId));
		
		Test.stopTest();
	}
	
	/**
	 * Tests compare numbers
	 */
	@isTest
	public static void test_compareStrings() {
		Test.startTest();
		
		System.assertEquals(CS_utl_Comparison.Comparison.EQUALS, CS_utl_Comparison.compare('TestString', 'TestString'));
		System.assertEquals(CS_utl_Comparison.Comparison.LESS_THAN, CS_utl_Comparison.compare('TestString', 'TestStringLong'));
		System.assertEquals(CS_utl_Comparison.Comparison.GREATER_THAN, CS_utl_Comparison.compare('TestString', 'Test'));
		System.assertEquals(CS_utl_Comparison.Comparison.GREATER_THAN, CS_utl_Comparison.compare('TestString', ''));
		System.assertEquals(CS_utl_Comparison.Comparison.NOT_EQUALS, CS_utl_Comparison.compare('TestString', null));
		
		Test.stopTest();
	}
	
	/**
	 * Tests compare not equals
	 */
	@isTest
	public static void test_compareNotEquals() {
		Test.startTest();
		
		System.assertEquals(CS_utl_Comparison.Comparison.NOT_EQUALS, CS_utl_Comparison.compare('TestString', 4));
		
		Test.stopTest();
	}
	
	/**
	 * Tests contains
	 */
	@isTest
	public static void test_contains() {
		Test.startTest();
		
		//boolean
		System.assert(CS_utl_Comparison.contains(new Set<Boolean>{true, false}, true));
		System.assert(!CS_utl_Comparison.contains(new Set<Boolean>{true}, false));
		
		//dates
		System.assert(CS_utl_Comparison.contains(new Set<Date>{Date.today(), Date.today().addDays(5)}, Date.today()));
		System.assert(!CS_utl_Comparison.contains(new Set<Date>{Date.today(), Date.today().addDays(5)}, Date.today().addDays(-5)));
		
		//decimal
		System.assert(CS_utl_Comparison.contains(new Set<Decimal>{5, 10}, (Decimal) 5));
		System.assert(!CS_utl_Comparison.contains(new Set<Decimal>{5, 10}, (Decimal) 1));
		
		//double
		System.assert(CS_utl_Comparison.contains(new Set<Double>{5, 10}, (Double) 5));
		System.assert(!CS_utl_Comparison.contains(new Set<Double>{5, 10}, (Double) 1));
		
		//id
		Id testId = CS_utl_Id.getFakeId(Account.getSobjectType());
		System.assert(CS_utl_Comparison.contains(new Set<Id>{testId, CS_utl_Id.getFakeId(Account.getSobjectType())}, testId));
		System.assert(!CS_utl_Comparison.contains(new Set<Id>{CS_utl_Id.getFakeId(Account.getSobjectType())}, testId));
		
		//integer
		System.assert(CS_utl_Comparison.contains(new Set<Integer>{5, 10}, (Integer) 5));
		System.assert(!CS_utl_Comparison.contains(new Set<Integer>{5, 10}, (Integer) 1));
		
		//long
		System.assert(CS_utl_Comparison.contains(new Set<Long>{5, 10}, (Long) 5));
		System.assert(!CS_utl_Comparison.contains(new Set<Long>{5, 10}, (Long) 1));
		
		//string
		System.assert(CS_utl_Comparison.contains(new Set<String>{'TestString1', 'TestString2'}, 'TestString1'));
		System.assert(!CS_utl_Comparison.contains(new Set<String>{'TestString1', 'TestString2'}, 'TestString3'));
		
		//exception
		Boolean exceptionThrown = false;
		try {
			System.assert(CS_utl_Comparison.contains(new List<String>{'TestString1', 'TestString2'}, 'TestString1'));
		}
		catch (CS_utl_Comparison.ComparisonException ex) {
			exceptionThrown = true;
		}
		System.assert(exceptionThrown);
		
		Test.stopTest();
	}
}