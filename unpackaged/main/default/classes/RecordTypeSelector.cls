/**
   @Description Selector class for RecordType object
*/
public with sharing class RecordTypeSelector {
    /**
    *  getting the recordtype Id from object and rec type name
    *  @name getRecordTypeId
    *  @param string objectAPIName, string recordTypeName
    *  @return Id
    */
    public static Id getRecordTypeId(string objectAPIName, string recordTypeName) {
        if(string.isEmpty(objectAPIName) || string.isEmpty(recordTypeName)) {
            return null;
        }
        //Get schema information
        Map<String, Schema.SObjectType> globalDescription =  Schema.getGlobalDescribe();
        Schema.SObjectType sObjType = globalDescription.get(objectAPIName);
        Schema.DescribeSObjectResult cfrSchema = sObjType.getDescribe();
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = cfrSchema.getRecordTypeInfosByName(); //?
        Id recordTypeId = recordTypeInfo.get(recordTypeName).getRecordTypeId();
        return recordTypeId;
    }
}