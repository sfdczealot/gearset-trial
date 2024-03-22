/**
 * @name CS_utl_SObject
 * @description Utility methods for SObject type
 * @revision
 *
 */
public without sharing class CS_utl_SObject {
    /**
     * Get value from an SObject
     * @param fieldName String
     * @param obj       SObject
     * @return          Object
     */
    public static Decimal getDecimalValue(String fieldName, SObject obj) {
        return isNotNull(fieldName, obj) ? Decimal.valueOf(getFieldValue(obj, fieldName)) : 0;
    }

    /* Check if field is not null on SObject
     * @param fieldName String
     * @param obj       SObject
     * @return          Boolean
     */    
    public static Boolean isNotNull(String fieldName, SObject obj) {
        return String.isNotBlank(getFieldValue(obj, fieldName));
    }
    
    /**
     * Returns field value from a given object
     * @param  obj       SObject
     * @param  fieldName String
     * @return           String
     */
    public static String getFieldValue(SObject obj, String fieldName) {
        if(obj == null) {
            return null;
        }
        
        try {
            if(fieldName.contains('.')) {
                List<String> separatedField = fieldName.split('\\.', 2);
                return getFieldValue((SObject) obj.getSobject(separatedField.get(0)), separatedField.get(1));
            }
            else {
                return String.valueOf(obj.get(fieldName));
            }
        }

        catch(SObjectException ex) {
            return null;
        }
    }

    /**
     * Returns a comma separated list of fields of the SObject with the given name, which can be used
     * in SOQL queries.
     * @param obj SObjectType
     * @return    String
     */ 
    public static String getFieldList(SObjectType obj) {
        return getFieldList(obj, '');
    }
    
    /**
     * Returns a comma separated list of fields of the SObject with the given name, which can be used
     * in SOQL queries.
     * @param obj    SObjectType
     * @param prefix String
     * @return       String
     */ 
    public static String getFieldList(SObjectType obj, String prefix) {
        return getFieldList(obj, prefix, null);
    }    
    
    /**
     * Returns a comma separated list of fields of the SObject with the given name, which can be used
     * in SOQL queries. Fields defined in ignoreFields will be ignored.
     * @param obj           SObjectType
     * @param prefix        String
     * @param ignoreFields  Set<Schema.SObjectField>
     * @return              String
     */ 
    public static String getFieldList(SObjectType obj, String prefix, Set<Schema.SObjectField> ignoreFields) {
        List<Schema.SObjectField> objFields = obj.getDescribe().fields.getMap().values();
        List<String> fieldNames = new List<String>();
        for (Schema.SObjectField f : objFields) {
        	if(ignoreFields == null || !ignoreFields.contains(f)) {
                fieldNames.add(prefix + f.getDescribe().Name);
            }
        }
        
        return CS_utl_Array.join(fieldNames, ',');
    }
    
    /**
     * Join fields from given SObject separated by given separator, accepts lookup fields (ie. account.ParentAccount.Name)
     * @param  obj        SObject
     * @param  fieldNames Set<String>
     * @param  separator  String
     * @return            String
     */
    public static String joinFieldList(SObject obj, Set<String> fieldNames, String separator) {
        List<String> values = new List<String>();
        for(String fieldName : fieldNames) {
            values.add(getFieldValue(obj, fieldName));
        }

        return CS_utl_Array.join(values, separator);
    }
    
    /**
     * Get DescribeFieldResult for a relationship field
     * @param  parentObj SObjectType
     * @param  childObj  SObjectType
     * @return           DescribeFieldResult
     */
    public static Schema.DescribeFieldResult getRelationshipField(SObjectType parentObj, SObjectType childObj) {
        Schema.DescribeSObjectResult describeParentObj = parentObj.getDescribe();
        for(Schema.ChildRelationship cr : describeParentObj.getChildRelationships()) {
            if(cr.getChildSObject() == childObj) {
                return cr.getField().getDescribe();
            }
        }
        
        return null;
    }
    
    /**
     * Get Field Type
     * @param  obj       SObjectType
     * @param  fieldName String
     * @return           Schema.DisplayType
     */
     public static Schema.DisplayType getFieldType(SObjectType obj, String fieldName) {
        Schema.DescribeSObjectResult describeObj = obj.getDescribe();
        return describeObj.fields.getMap().get(fieldName).getDescribe().getType();
     }
     
    /**
     * Get Untyped value
     * @param  untyped Object
     * @return         Object
     */
     public static Object getObjectValue(Object untyped, Schema.DisplayType displayType) {
        return displayType == Schema.DisplayType.Date ? Date.valueOf(String.valueOf(untyped)) : untyped;
     }   
}