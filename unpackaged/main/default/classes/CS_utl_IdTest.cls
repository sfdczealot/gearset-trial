/**
 * @name CS_utl_IdTest
 * @description Test for CS_utl_Id class
 * @revision
 *
 */
@isTest
public class CS_utl_IdTest {
    /**
     * Test getFakeId method
     */
    @isTest
    public static void test_getFakeId() {
        Schema.SObjectType accountType = Account.getSobjectType();

        Test.startTest();

        Id accountId = CS_utl_Id.getFakeId(accountType);

        Boolean exceptionThrown = false;
        try {
            Account acc = new Account(Id = accountId);
        }
        catch(Exception e) {
            exceptionThrown = true;
        }

        System.assert(!exceptionThrown);

        Test.stopTest();
    }

    /**
     * Test getUniqueId method
     */
    @isTest
    public static void test_getUniqueId() {
        Schema.SObjectType accountType = Account.getSobjectType();

        Test.startTest();

        String uId = CS_utl_Id.getUniqueId(accountType);

        System.assert(String.isNotBlank(uId));
        System.assert(uId.contains(accountType.getDescribe().getName()));

        Test.stopTest();
    }

    @IsTest
    public static void test_generateKey() {
        String key = CS_utl_Id.generateKey();
        System.assert(String.isNotBlank(key));
    }
}