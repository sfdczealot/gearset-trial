//Engine used for mapping attributes to object fields
//Added the functionality to Map in both directions - Fields to Attributes and Attributes to Fields.
//Also to group mappings with other fields mappings together with Attribute mappings under Property Mappings
public class AttributeMappingEngine {
    private static final String BOOLEAN_TYPE = 'Boolean';
    private static final String DECIMAL_TYPE = 'Decimal';
    private static final String DOUBLE_TYPE = 'Double';
    private static final String INTEGER_TYPE = 'Integer';
    private static final String STRING_TYPE = 'String';

    private static final String GeneralText_Yes = 'Yes';
    private static final String GeneralText_True = 'true';

    private static final map<String, Set<Schema.DisplayType>> validTypeCombinations = new map<String, Set<Schema.DisplayType>> {
        BOOLEAN_TYPE => new Set<Schema.DisplayType> {Schema.DisplayType.Boolean, Schema.DisplayType.String, Schema.DisplayType.Picklist},
        DECIMAL_TYPE => new Set<Schema.DisplayType> {Schema.DisplayType.Currency, Schema.DisplayType.Double, Schema.DisplayType.Integer, Schema.DisplayType.String, Schema.DisplayType.Picklist},
        DOUBLE_TYPE => new Set<Schema.DisplayType> {Schema.DisplayType.Currency, Schema.DisplayType.Double, Schema.DisplayType.Integer, Schema.DisplayType.String, Schema.DisplayType.Picklist},
        INTEGER_TYPE => new Set<Schema.DisplayType> {Schema.DisplayType.Integer, Schema.DisplayType.String, Schema.DisplayType.Picklist},
        STRING_TYPE => new Set<Schema.DisplayType> {}
    };
    
    private final static String DIRECTION_FIELDS_TO_ATTRIBUTES = 'Map Fields to Attributes';
    private final static String DIRECTION_ATTRIBUTES_TO_FIELDS = 'Map Attributes to Fields';
    

    private static Map<String,Schema.SObjectType> globalDescribe;
    private static Map<String, Map<String, Schema.SObjectField>> objectFields;
    private static Map<String, Map<String, Schema.DescribeFieldResult>> objectFieldDescribe;
    private static Map<Id, cscfga__Attribute_Definition__c> atttributeDefinitions;

    static {
        if(globalDescribe == null) {
            globalDescribe = Schema.getGlobalDescribe();
        }

        if(objectFields == null) {
            objectFields = new map<String, Map<String, Schema.SObjectField>>();
        }

        if(objectFieldDescribe == null) {
            objectFieldDescribe = new Map<String, map<String, Schema.DescribeFieldResult>>();
        }

        if(atttributeDefinitions == null) {
            atttributeDefinitions = new map<Id, cscfga__Attribute_Definition__c>
                                            ([Select
                                                Id, cscfga__Data_Type__c, cscfga__Type__c
                                              From
                                                cscfga__Attribute_Definition__c
                                              Where
                                                cscfga__Product_Definition__r.cscfga__Active__c = true]);
        }
    }

    public static void handleBeforeInsert(List<Attribute_Mapper__c> attributeMappers) {
        checkAttributeMapperValidity(attributeMappers);
    }

    public static void handleBeforeUpdate(List<Attribute_Mapper__c> attributeMappers) {
        checkAttributeMapperValidity(attributeMappers);
    }
    @TestVisible
    private static void checkAttributeMapperValidity(List<Attribute_Mapper__c> attributeMappers) {
        for(Attribute_Mapper__c attMapper : attributeMappers) {
            if(sObjectExists(attMapper.Object_Name__c) == false) {
                attMapper.addError('The given Object does not exist.');
                return;
            }

            if(fieldExists(attMapper.Object_Name__c, attMapper.Field_Name__c) == false) {
                attMapper.addError('The given Field does not exist on the Object.');
                return;
            }
            
            if(fieldIsCompatible(attMapper.Object_Name__c, attMapper.Field_Name__c, attMapper.Attribute_Definition__c) == false) {
                attMapper.addError('The given Field and selected Attribute do not have compatible types.');
                return;
            }
        }
    }

    private static Boolean sObjectExists(String sObjectName) {
        return globalDescribe.containsKey(sObjectName);
    }

    private static Boolean fieldExists(String sObjectName, String fieldName) {
        Schema.SObjectField objField = getField(sObjectName, fieldName);
        if(objField != null) {
            return true;
        }

        else {
            return false;
        }
    }

    private static Boolean fieldIsUpdateable(String sObjectName, String fieldName) {
        return getFieldDescribe(sObjectName, fieldName).isUpdateable();
    }

    private static Boolean fieldIsCompatible(String sObjectName, String fieldName, Id attDefId) {
        return true;
    }

@TestVisible
    private static Object convertStringToFieldType(String value, String sObjectName, String fieldName) {
        Schema.DisplayType fieldType = getFieldType(sObjectName, fieldName);

        if(fieldType == Schema.DisplayType.Boolean) {
            return (value == GeneralText_Yes || value == GeneralText_True);
        }

        else if(fieldType == Schema.DisplayType.String || fieldType == Schema.DisplayType.Picklist || fieldType == Schema.DisplayType.TextArea) {
            return value;
        }

        else if(fieldType == Schema.DisplayType.Date) {
            return convertStringToDate(value);
        }

        else if(fieldType == Schema.DisplayType.Double) {
            return convertStringToDecimal(value);
        }

        else if(fieldType == Schema.DisplayType.Integer) {
            return convertStringToInteger(value);
        }

        else if(fieldType == Schema.DisplayType.Reference) {
            return convertStringToId(value);
        }

        else {
            return null;
        }
    }

@TestVisible
    private static Date convertStringToDate(String dateString) {
        Date convertedDate;

        if(String.isNotBlank(dateString)) {
            try {
                convertedDate = Date.parse(dateString);
            }

            catch (Exception e) {
            }
        }

        return convertedDate;
    }


@TestVisible
    private static Integer convertStringToInteger(String integerString) {
        Integer convertedInteger;

        if(String.isNotBlank(integerString)) {
            try {
                convertedInteger = Integer.valueOf(integerString);
            }

            catch (Exception e) {
            }
        }

        return convertedInteger;
    }

@TestVisible
    private static Decimal convertStringToDecimal(String decimalString) {
        Decimal convertedDecimal;

        if(String.isNotBlank(decimalString)) {
            try {
                convertedDecimal = Decimal.valueOf(decimalString);
            }

            catch (Exception e) {
            }
        }

        return convertedDecimal;
    }

@TestVisible
    private static Id convertStringToId(String idString) {
        Id convertedId;

        if(String.isNotBlank(idString)) {
            try {
                convertedId = Id.valueOf(idString);
            }

            catch (Exception e) {
            }
        }

        return convertedId;
    }

    private static Schema.SObjectField getField(String sObjectName, String fieldName) {
        if(objectFields.containsKey(sObjectName)) {
            return objectFields.get(sObjectName).get(fieldName);
        }

        else {
            SObjectType objType = globalDescribe.get(sObjectName);
            if(objType == null) {
                return null;
            }
            
            Map<String, Schema.SObjectField> objFields = objType.getDescribe().fields.getMap();
            objectFields.put(sObjectName, objFields);

            return objectFields.get(sObjectName).get(fieldName);
        }
    }

    private static Schema.DescribeFieldResult getFieldDescribe(String sObjectName, String fieldName) {
        if(!objectFieldDescribe.containsKey(sObjectName)) {
            objectFieldDescribe.put(sObjectName, new Map<String, Schema.DescribeFieldResult>());
        }

        if (objectFieldDescribe.get(sObjectName).containsKey(fieldName)) {
            return objectFieldDescribe.get(sObjectName).get(fieldName);
        }

        else {
            Schema.DescribeFieldResult fieldDescribe = getField(sObjectName, fieldName).getDescribe();
            objectFieldDescribe.get(sObjectName).put(fieldName, fieldDescribe);

            return fieldDescribe;
        }
    }
@TestVisible
    private static Schema.DisplayType getFieldType(String sObjectName, String fieldName) {
        return getFieldDescribe(sObjectName, fieldName).getType();
    }

     /*
     *
     * New Mapping of Attributes my Property Mapper. Allow 2 way mapping, and selecting
     * Attribute mappings by PropertyMapping Groups.
     *
     */
     public static set<cscfga__Attribute__c> mapAttributes(Property_Map__c propertyMapping, map<Id, List<SObject>> configToSObjects) 
     {
        map<String, List<Attribute_Mapper__c>> sObjectToAttributeMappers = findAttributeMappers(propertyMapping.Id);
        map<Id, map<String, cscfga__Attribute__c>> configToAttributes = findAttributes(configToSObjects.keySet(), sObjectToAttributeMappers);
        set<cscfga__Attribute__c> retVal = new set<cscfga__Attribute__c>();        
    
        for(Id configId : configToSObjects.keySet()) 
        {
            map<String, cscfga__Attribute__c> attributes = configToAttributes.get(configId);
            List<SObject> sObjects = configToSObjects.get(configId);

            for(SObject sObj : sObjects) 
            {
                List<Attribute_Mapper__c> attributeMappers = sObjectToAttributeMappers.get(sObj.getSObjectType().getDescribe().getName());
                if(attributeMappers != null&& attributes!=null) 
                {
                    for(Attribute_Mapper__c attMapper : attributeMappers) 
                    {
                        if(attributes.containsKey(attMapper.Name)) 
                        {
                            cscfga__Attribute__c att = attributes.get(attMapper.Name);
                                                    
                            // ARE READING FROM ATTS OR WRITING TOO ATS ?
                            if (propertyMapping.Attribute_Mapping_Direction__c != DIRECTION_ATTRIBUTES_TO_FIELDS)
                            {
                                // Attribute value is limited to 32k characters - this check is to prevent Limit exception
                                String attrValue = string.valueOf(sobj.get(attMapper.Field_Name__c));
                                if(attrValue!=null) {
                                    Integer valueLength = attrValue.length();
                                    if(valueLength<=32000) {
                                      att.cscfga__Value__c = attrValue;
                                    }
                                    else {
                                        att.cscfga__Value__c = null;
                                    }
                                }
                                else {
                                    att.cscfga__Value__c = attrValue;
                                }
                            }
                            else
                            {
                                sObj.put(attMapper.Field_Name__c, convertStringToFieldType(att.cscfga__Value__c, attMapper.Object_Name__c, attMapper.Field_Name__c));
                            }
                            retVal.add(att);
                        }
                    }
                }
            }
        }
        
        return retVal;
    }

@TestVisible
    private static Set<String> findObjects(List<List<SObject>> sObjects) {
        List<SObject> allSObjects = new List<SObject>();
        for(List<SObject> sObjList : sObjects) {
            allSObjects.addAll(sObjList);
        }

        Set<String> sObjectTypes = new Set<String>();
        for(SObject sObj : allSObjects) {
            sObjectTypes.add(sObj.getSObjectType().getDescribe().getName());
        }

        return sObjectTypes;
    }

    private static map<Id, map<String, cscfga__Attribute__c>> findAttributes(Set<Id> configIds, map<String, List<Attribute_Mapper__c>> sObjectToAttributeMappers) {
        map<Id, map<String, cscfga__Attribute__c>> configToAttributes = new map<Id, map<String, cscfga__Attribute__c>>();
        Set<String> attDefNames = new Set<String>();
        Set<String> attNames = new Set<String>();

        for(List<Attribute_Mapper__c> attMapperList : sObjectToAttributeMappers.values()) {
            for(Attribute_Mapper__c attMapper : attMapperList) {
                attDefNames.add(attMapper.Attribute_Definition_Name__c);
                attNames.add(attMapper.Name);
            }
        }

        List<cscfga__Attribute__c> attributes = [Select
                                                    Id, cscfga__Value__c, Name,
                                                    cscfga__Product_Configuration__c,
                                                    cscfga__Attribute_Definition__r.cscfga__Product_Definition__r.Name 
                                                 From
                                                    cscfga__Attribute__c
                                                 Where
                                                    cscfga__Product_Configuration__c In :configIds And
                                                    cscfga__Attribute_Definition__r.cscfga__Product_Definition__r.Name IN :attDefNames And 
                                                    Name IN :attNames];
        for(cscfga__Attribute__c att : attributes) {
            if(configToAttributes.containsKey(att.cscfga__Product_Configuration__c)) {
                configToAttributes.get(att.cscfga__Product_Configuration__c).put(att.Name, att);
            }
            else {
                configToAttributes.put(att.cscfga__Product_Configuration__c, new map<String, cscfga__Attribute__c>{att.Name => att});
            }
        }
        return configToAttributes;
    }
    
    /*
    * New way of grouping these rather than just having one mapping per sObject Type.
    */
    private static map<String, List<Attribute_Mapper__c>> findAttributeMappers(id propertyMapId) {
        map<String, List<Attribute_Mapper__c>> sObjectToAttributeMappers = new map<String, List<Attribute_Mapper__c>>();

        List<Attribute_Mapper__c> attributeMappers = [Select
                                                        Id, Field_Name__c, Object_Name__c, Attribute_Name__c, Attribute_Definition_Name__c, Name  
                                                     From
                                                        Attribute_Mapper__c
                                                     Where
                                                        Property_Map__c = :propertyMapId];
        for(Attribute_Mapper__c attMapper : attributeMappers) 
        {
             if(sObjectToAttributeMappers.containsKey(attMapper.Object_Name__c)) {
                sObjectToAttributeMappers.get(attMapper.Object_Name__c).add(attMapper);
            }
            else {
                sObjectToAttributeMappers.put(attMapper.Object_Name__c, new List<Attribute_Mapper__c>{attMapper});
            }
        }

        return sObjectToAttributeMappers;
    }
    
   
    
}