@IsTest
public class CS_utl_CurrencyTest {
	@IsTest
	public static void test_getCurrrency() {
		System.assert(!CS_utl_Currency.currencies.isEmpty());
	}

	@IsTest
	public static void test_getDecimalPlaces() {
		System.assertEquals(2, CS_utl_Currency.getDecimalPlaces('UNDEFINED'));
	}

	@IsTest
	public static void test_getDecimalPlacesSGD() {
		System.assertEquals(4, CS_utl_Currency.getDecimalPlaces('SGD'));
	}
}