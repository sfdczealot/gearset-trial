/**
 * @name CS_utl_RecordTypeTest
 * @description Test for CS_utl_RecordType class
 * @revision
 *
 */
@isTest
public class CS_utl_RecordTypeTest {
    /**
     * Test getRecordTypesById and getRecordTypesByName methods
     */
    @isTest
    private static void test_getRecordTypes() {
        RecordType rt = [SELECT
                            Id, Name
                         FROM
                            RecordType
                         WHERE
                            SObjectType = 'Account' LIMIT 1];
        Schema.SObjectType accountType = Account.getSobjectType();

        Test.startTest();

        Map<String, Schema.RecordTypeInfo> recordTypeInfosByName = CS_utl_RecordType.getRecordTypesByName(accountType);
        System.assert(recordTypeInfosByName.containsKey(rt.Name));

        Map<Id, Schema.RecordTypeInfo> recordTypeInfosById = CS_utl_RecordType.getRecordTypesById(accountType);
        System.assert(recordTypeInfosById.containsKey(rt.Id));

        Test.stopTest();
    }

    /**
     * Test getRecordTypeName method
     */
    @isTest
    private static void test_getRecordTypeName() {
        RecordType rt = [SELECT
                            Id, Name
                         FROM
                            RecordType
                         WHERE
                            SObjectType = 'Account' LIMIT 1];
        Schema.SObjectType accountType = Account.getSobjectType();

        Test.startTest();

        String recordTypeName = CS_utl_RecordType.getRecordTypeName(accountType, rt.Id);
        System.assertEquals(rt.Name, recordTypeName);

        Test.stopTest();
    }

    /**
     * Test getRecordTypeName method, invalid Name
     */
    @isTest
    private static void test_getRecordTypeNameInvalidName() {
        RecordType rt = [SELECT
                            Id, Name
                         FROM
                            RecordType
                         WHERE
                            SObjectType = 'Account' LIMIT 1];
        Schema.SObjectType accountType = Account.getSobjectType();

        Test.startTest();

        try {
            String nonExistingRecordTypeName = CS_utl_RecordType.getRecordTypeName(accountType, CS_utl_Id.getFakeId(accountType));
            System.assert(false, 'Exception expected.');
        }
        catch(CS_utl_RecordType.RecordTypeException e) {
            System.assertEquals('Invalid Record Type Id specified.', e.getMessage());
        }

        Test.stopTest();
    }

    /**
     * Test getRecordTypeId method
     */
    @isTest
    private static void test_getRecordTypeId() {
        RecordType rt = [SELECT
                            Id, Name
                         FROM
                            RecordType
                         WHERE
                            SObjectType = 'Account' LIMIT 1];
        Schema.SObjectType accountType = Account.getSobjectType();

        Test.startTest();

        String recordTypeId = CS_utl_RecordType.getRecordTypeId(accountType, rt.Name);
        System.assertEquals(rt.Id, recordTypeId);

        Test.stopTest();
    }

    /**
     * Test getRecordTypeId method, invalid Id
     */
    @isTest
    private static void test_getRecordTypeIdInvalidId() {
        RecordType rt = [SELECT
                            Id, Name
                         FROM
                            RecordType
                         WHERE
                            SObjectType = 'Account' LIMIT 1];
        Schema.SObjectType accountType = Account.getSobjectType();

        Test.startTest();

        try {
            String nonExistingRecordTypeId = CS_utl_RecordType.getRecordTypeId(accountType, '');
            System.assert(false, 'Exception expected.');
        }
        catch(CS_utl_RecordType.RecordTypeException e) {
            System.assertEquals('Invalid Record Type Name specified.', e.getMessage());
        }

        Test.stopTest();
    }   
}