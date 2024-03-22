/**
 * @name CS_utl_ArrayTest
 * @description Test for CS_utl_Array class
 * @revision
 *
 */
@isTest
public class CS_utl_ArrayTest {
    /**
     * Test join method, using strings
     */
    @isTest
    public static void test_joinString() {
        String str = 'a;b;c;d;e;f;g;h;i;j';
        String altstr = 'a,b,c,d,e,f,g,h,i,j';
        List<String> l = str.split(';');
        
        Test.startTest();

        System.assertEquals(10, l.size());
        System.assertEquals(str, CS_utl_Array.join(l));
        System.assertEquals(altstr, CS_utl_Array.join(l, ','));

        Test.stopTest();
    }

    /**
     * Tests removeBlanks method
     */
    @isTest
    public static void test_removeBlanks() {
        List<String> values;
        List<String> expectedResult;

        Test.startTest();

        values = new List<String>{'a', 'b', '', 'c', '   '};
        expectedResult = new List<String>{'a', 'b', 'c'};
        System.assert(expectedResult.equals(CS_utl_Array.removeBlanks(values)));

        values = new List<String>{'a', 'b', 'c'};
        expectedResult = new List<String>{'a', 'b', 'c'};
        System.assert(expectedResult.equals(CS_utl_Array.removeBlanks(values)));

        Test.stopTest();
    }
    
    /**
     * Tests plucking values
     */
    @isTest
    public static void test_pluckName() {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            accounts.add(CS_th_Account.create('Test' + i, false));
        }
        insert accounts;

        Test.startTest();

        List<String> result = (List<String>) CS_utl_Array.pluck(accounts, Account.Name);
        System.assertEquals(5, result.size());
        System.assertEquals(accounts.get(0).Name, result.get(0));

        Test.stopTest();
    }
    
    /**
     * Tests plucking values
     */
    @isTest
    public static void test_pluckId() {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            accounts.add(CS_th_Account.create('Test' + i, false));
        }
        insert accounts;

        Test.startTest();

        List<Id> result = (List<Id>) CS_utl_Array.pluck(accounts, Account.Id);
        System.assertEquals(5, result.size());
        System.assertEquals(accounts.get(0).Id, result.get(0));

        Test.stopTest();
    }
    
    /**
     * Tests grouping sobjects by values, name
     */
    @isTest
    public static void test_groupByName() {
        List<Account> accounts = new List<Account>();
        for(Integer i = 0; i < 5; i++) {
            accounts.add(CS_th_Account.create('Test' + Math.mod(i, 2), false));
        }
        insert accounts;

        Test.startTest();

        Map<Object, List<SObject>> result = (Map<Object, List<SObject>>) CS_utl_Array.groupBy(accounts, Account.Name);
        System.assertEquals(2, result.keySet().size());
        System.assertEquals(3, result.get('Test0').size());
        System.assertEquals(2, result.get('Test1').size());

        Test.stopTest();
    }
}