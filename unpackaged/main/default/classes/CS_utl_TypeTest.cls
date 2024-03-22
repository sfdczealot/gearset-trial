/**
 * @name CS_utl_TypeTest
 * @description Test for CS_utl_Type
 * @revision
 *
 */
@isTest
public class CS_utl_TypeTest {
    /**
     * Tests getting a new instance of object
     */
    @isTest
    public static void test_getInstance() {
        Test.startTest();
        
        System.assert(CS_utl_Type.getInstance('Account') instanceOf Account);

        Test.stopTest();
    }
    
    /**
     * Tests getting a new instance of  list<object>
     */
    @isTest
    public static void test_getListInstance() {
        Test.startTest();
        
        System.assert(CS_utl_Type.getListInstance('String') instanceOf List<String>);
        System.assert(CS_utl_Type.getListInstance('Account') instanceOf List<Account>);

        Test.stopTest();
    }
}