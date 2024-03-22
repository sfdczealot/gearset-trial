/**
 * @name CS_utl_EmailTest
 * @description Test for CS_utl_Email class
 * @revision
 *
 */
@isTest
public class CS_utl_EmailTest {
    /**
     * Test isAddressValid method using null or blank string
     */
    @isTest
    public static void test_isAddressValidEmptyOrNull() {
        System.assert(!CS_utl_Email.isAddressValid('  '), 'Blank address is not valid.');
        System.assert(!CS_utl_Email.isAddressValid(null), 'Null is not valid.');
    }

    /**
     * Test isAddressValid method using invalid emails
     */
    @isTest
    public static void test_isAddressValidInvalid() {
        System.assert(!CS_utl_Email.isAddressValid('abc123'), 'Given address is not valid.');
        System.assert(!CS_utl_Email.isAddressValid('abc123@'), 'Given address is not valid.');
        System.assert(!CS_utl_Email.isAddressValid('test.com'), 'Given address is not valid.');
    }

    /**
     * Test isAddressValid method using valid emails
     */
    @isTest
    public static void test_isAddressValid() {
        System.assert(CS_utl_Email.isAddressValid('abc123@test.com'), 'Given address is valid.');
        System.assert(CS_utl_Email.isAddressValid('abc123@y.com'), 'Given address is valid.');
        System.assert(CS_utl_Email.isAddressValid('test.com@email.com'), 'Given address is valid.');
    }

    /**
     * Test sendEmail method
     */
    @isTest
    public static void test_sendEmail() {
        String address = 'test@test.com';
        String plainTextBody = 'TestBody';
        String htmlBody = '<b>TestBody</b>';
        String subject = 'Test';

        Test.startTest();

        List<Messaging.SendEmailResult> results = CS_utl_Email.sendEmail(new List<String>{address}, plainTextBody,
                                                                      htmlBody, subject);
        System.assert(!results.isEmpty());
        System.assert(results.get(0).success);

        Test.stopTest();
    }
}