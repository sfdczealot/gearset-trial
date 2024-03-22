/**
 * @name CS_utl_RecordType
 * @description Utility class for RecordType object
 * @revision
 *
 */
public class CS_utl_RecordType {
    /**
     * Get record types for given object type
     * @param  objectType Schema.SObjectType
     * @return            Map<String, Schema.RecordTypeInfo>
     */
    public static Map<Id, Schema.RecordTypeInfo> getRecordTypesById(Schema.SObjectType objectType) {
        return objectType.getDescribe().getRecordTypeInfosById();
    }

    /**
     * Get record types for given object type
     * @param  objectType Schema.SObjectType
     * @return            Map<String, Schema.RecordTypeInfo>
     */
    public static Map<String, Schema.RecordTypeInfo> getRecordTypesByName(Schema.SObjectType objectType) {
        return objectType.getDescribe().getRecordTypeInfosByName();
    }

    /**
     * Get record type id based on name and object type
     * @param  objectType     Schema.SObjectType
     * @param  recordTypeName String
     * @return                Id
     */
    public static Id getRecordTypeId(Schema.SObjectType objectType, String recordTypeName) {
        Map<String, Schema.RecordTypeInfo> recordTypeInfosByName = getRecordTypesByName(objectType);

        if(recordTypeInfosByName.containsKey(recordTypeName)) {
            return recordTypeInfosByName.get(recordTypeName).getRecordTypeId();
        }
        else {
            throw new RecordTypeException('Invalid Record Type Name specified.');
        }
    }

    /**
     * Get record type name based on id and object type
     * @param  objectType   Schema.SObjectType
     * @param  recordTypeId Id
     * @return              String
     */
    public static String getRecordTypeName(Schema.SObjectType objectType, Id recordTypeId) {
        Map<Id, Schema.RecordTypeInfo> recordTypeInfosById = getRecordTypesById(objectType);

        if(recordTypeInfosById.containsKey(recordTypeId)) {
            return recordTypeInfosById.get(recordTypeId).getName();
        }
        else {
            throw new RecordTypeException('Invalid Record Type Id specified.');
        }
    }

    public class RecordTypeException extends Exception {}  
}