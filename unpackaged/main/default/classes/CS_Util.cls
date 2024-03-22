public with sharing class CS_Util {

    public static Pattern orderLevelTargetingPattern = Pattern.compile('(\"((?!\").)+\":((?!;).)+;)*(((?!;).)+)(;\"((?!\").)+\":((?!;).)+)*');
    public static Pattern cltPattern = Pattern.compile('(\"((?!\").)+\":((?!;).)+)');

    /* Salesforce schema helper methods - start */
    @TestVisible
    private static Map<SObjectType, Map<String, Schema.SObjectField>> mapFieldsToObject =
            new Map<SObjectType, Map<String, Schema.SObjectField>>();

    @TestVisible
    private static Map<Schema.SObjectType, Map<String, Schema.DescribeFieldResult>> mapFieldDescribeToObject =
            new Map<Schema.SObjectType, Map<String, Schema.DescribeFieldResult>>();

    @TestVisible
    private static Map<Schema.SObjectType, Schema.DescribeSObjectResult> mapObjectDescribe =
            new Map<Schema.SObjectType, Schema.DescribeSObjectResult>();

    public static String getFieldListAsCSV(SObjectType sobject_type) {
        Map<String, Schema.SObjectField> field_map = getObjectFields(sobject_type);
        return String.join(new List<String>(field_map.keySet()), ',');
    }

    public static String getFieldListAsCSV(String objectName) {
        List<Schema.DescribeSObjectResult> results = Schema.describeSObjects(new List<String>{
                objectName
        });
        if (!results.isEmpty()) {
            Map<String, Schema.SObjectField> field_map = results[0].fields.getMap();
            return String.join(new List<String>(field_map.keySet()), ',');
        }
        return '';
    }

    public static final String KEYVALUE_CONFIGURATION_ID = 'ID';


    public static String getFieldListAsWithPrefix(SObjectType sobject_type, String prefix) {
        String retVal = '';
        Map<String, Schema.SObjectField> field_map = getObjectFields(sobject_type);
        for (String field : field_map.keySet()) {
            if (retVal != '')
                retVal += ',';
            retVal += prefix + field;
        }
        return retVal;
    }

    public static String getFieldListAsWithOutPrefix(SObjectType sobject_type, String prefix) {
        String retVal = '';
        Map<String, Schema.SObjectField> field_map = getObjectFields(sobject_type);
        for (String field : field_map.keySet()) {
            if (retVal != '')
                retVal += ',';
            retVal += field;
        }
        return retVal;
    }

    public static String getFieldListAsCSVOnlyUpdatable(SObjectType sobject_type) {
        Map<String, Schema.SObjectField> field_map = getObjectUpdateFields(sobject_type).clone();
        return String.join(new List<String>(field_map.keySet()), ',');
    }

    public static Map<String, Schema.SObjectField> getObjectFields(SObjectType sobject_type) {
        Map<String, Schema.SObjectField> field_map;
        if (!mapFieldsToObject.containsKey(sobject_type)) {
            //describe the sobject
            DescribeSObjectResult sobject_describe = sobject_type.getDescribe();
            //get a map of fields for the passed sobject
            field_map = sobject_describe.fields.getMap();
            mapFieldsToObject.put(sobject_type, field_map);
        }

        field_map = mapFieldsToObject.get(sobject_type); //get a map of fields for the passed sobject
        return field_map;
    }

    public static Map<String, Schema.SObjectField> getObjectUpdateFields(SObjectType sobject_type) {
        Map<String, Schema.SObjectField> field_map = getObjectFields(sobject_type).clone(); //get a map of fields for the passed sobject
        DescribeFieldResult srvFieldDesc;

        Set<String> removeFieldSet = new Set<String>();
        for (String key : field_map.keySet()) {
            srvFieldDesc = CS_Util.getFieldDescribe(sobject_type, key);
            if (!srvFieldDesc.isUpdateable() || !srvFieldDesc.isCustom())
                removeFieldSet.add(key);
        }
        for (String illKey : removeFieldSet)
            field_map.remove(illKey);

        return field_map;
    }

    public static DescribeFieldResult getFieldDescribe(SObjectType sobject_type, String fieldName) {
        Map<String, DescribeFieldResult> fieldDescribes = mapFieldDescribeToObject.get(sobject_type);
        if (fieldDescribes == null) {
            fieldDescribes = new Map<String, Schema.DescribeFieldResult>();
            mapFieldDescribeToObject.put(sobject_type, fieldDescribes);
        }

        DescribeFieldResult describeField = fieldDescribes.get(fieldName);
        if (describeField == null) {
            Map<String, SObjectField> field_map = getObjectFields(sobject_type);
            describeField = field_map.get(fieldName).getDescribe();
            fieldDescribes.put(fieldName, describeField);
            mapFieldDescribeToObject.put(sobject_type, fieldDescribes);

        }
        return describeField;
    }

    public static Schema.DescribeSObjectResult getObjectDescribe(SObjectType sobject_type) {
        Schema.DescribeSObjectResult retResult = mapObjectDescribe.get(sobject_type);
        if (retResult == null) {
            retResult = sobject_type.getDescribe();
            mapObjectDescribe.put(sobject_type, retResult);
        }
        return retResult;
    }

    /* checks does field exists on certain object type */
    public static Boolean FieldExists(SObjectType sobject_type, String fieldName) {
        Map<String, SObjectField> field_map = getObjectFields(sobject_type); //get a map of fields for the passed sobject
        return field_map.get(fieldName) != null;
    }

    /* gets value in correct data type  */
    public static Object getCorrectType(SObjectType sobject_type, String fieldName, String fieldValue) {
        //get object describe
        Schema.DescribeSObjectResult sobject_describe = getObjectDescribe(sobject_type); //describe the sobject
        Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject

        //get field type
        DisplayType fieldType = getFieldDescribe(sobject_type, fieldName).getType();
        System.debug('Petary:' + fieldType + ' - fieldName:' + fieldName + ' - fieldValue:' + fieldValue);
        //return correct type
        if (fieldType == DisplayType.BOOLEAN) {
            if (fieldValue == null || fieldValue == '') {
                return false;
            } else if (fieldValue.toLowerCase() == 'no')
                return false; else if (fieldValue.toLowerCase() == 'yes')
                return true;
            return Boolean.valueOf(fieldValue);
        }
        if (fieldType == DisplayType.CURRENCY ||
                fieldType == DisplayType.PERCENT ||
                fieldType == DisplayType.DOUBLE) {
            if (fieldValue == null || fieldValue == '') {
                return 0;
            } else return Decimal.valueOf(fieldValue);
        }
        if (fieldType == DisplayType.INTEGER) {
            if (fieldValue == null || fieldValue == '') {
                return 0;
            } else return Integer.valueOf(fieldValue);
        }
        if (fieldType == DisplayType.DATE) {
            if (fieldValue == null || fieldValue == '') {
                return '';
            } else return Date.valueOf(fieldValue);
        }
        if (fieldType == DisplayType.DATETIME) {
            if (fieldValue == null || fieldValue == '') {
                return '';
            } else return Datetime.valueOf(fieldValue);
        }

        return fieldValue;
    }

    public static void populateFields(SObject currObj, Map<String, Object> fieldValues) {
        Map<String, Schema.SObjectField> objFields = getObjectFields(currObj.getSObjectType());
        for (String name : fieldValues.keySet()) {
            //check it exists
            if (objFields.containsKey(name))
                currObj.put(name, fieldValues.get(name));
        }
    }

    public static String findKeyPrefix(Schema.SObjectType currSobjectType) {
        Schema.DescribeSObjectResult r = currSobjectType.getDescribe();
        String keyPrefix = r.getKeyPrefix();
        return keyPrefix;
    }
    /* Salesforce schema helper methods - end*/

    /* helper methods start */
    public static String GenerateGuid() {
        Blob aes = Crypto.generateAesKey(128);
        String hex = EncodingUtil.convertToHex(aes);
        return hex;
    }
    /* helper methods end */

    /* JSON generator*/
    public static String convertToJSON(String thing,  Map<String, csdf__Custom_Targeting_Key__c> listOfCTargeting, Map<String, csdf__Targetable__c> targetable, CS_Custom_Settings__c customSettings) {

        System.debug('### convertToJSON ###' + thing + '###' + listOfCTargeting + '###' + targetable + '###' + customSettings + '###');

        String thing1 = thing.replace('Audience Segment', 'Audiencesegment');
        thing1 = thing1.replace('Audience segment', 'Audiencesegment');

        String thing2 = thing1.replace(' AND ', ' and ');
        String thing3 = CS_Util.replaceAll(' is not ', ' isnot ', thing2, true);

        System.debug(thing);
        System.debug(thing2);

        String[] ORparams = thing3.split(' OR ');

        JSONGenerator gen = JSON.createGenerator(false);


        Integer setcounter = 0;

        //Json obj
        gen.writeStartObject();
        for (String sethere : ORparams) {
            setcounter++;

            System.debug(sethere);

            gen.writeFieldName('set_' + setcounter);

            String step1 = sethere.replace(' or ', ',');

            String[] keyParams = step1.split(' and ');


            Integer keycounter = 0;

            gen.writeStartObject();

            for (String key1 : keyParams) {
                keycounter++;

                key1 = key1.replace(', ', ',');

                gen.writeFieldName('key_' + keycounter);
                String[] keyMembers = key1.split(' ');
                csdf__Custom_Targeting_Key__c dbKey = CS_Util.findCustomTargetingKey(keyMembers[0], listOfCTargeting, customSettings);
                String auSeg = keyMembers[0];
                if (keyMembers[0] != null && keyMembers[0].equalsIgnoreCase('Audiencesegment')) auSeg = 'Audience Segment';


                gen.writeStartObject();
                if (dbKey != null && !auSeg.equalsIgnoreCase('Audience Segment')) {
                    gen.writeStringField('sfId', dbKey.Id);
                    gen.writeStringField('userLabel', dbKey.csdf__Display_Name__c);
                    gen.writeStringField('adId', keyMembers[0]);
                } else if (auSeg.equalsIgnoreCase('Audience Segment')) {
                    gen.writeStringField('sfId', 'Audience Segment');
                    gen.writeStringField('userLabel', 'Audience Segment');
                    gen.writeStringField('adId', 'Audience Segment');
                } else {

                    gen.writeStringField('sfId', 'CustomTargetingKey not found in SFDC');
                    gen.writeStringField('userLabel', keyMembers[0]);
                    gen.writeStringField('adId', keyMembers[0]);
                }

                if (keyMembers[1] != null && keyMembers[1].equals('isnot')) {
                    gen.writeStringField('operator', 'is not');
                } else {
                    gen.writeStringField('operator', keyMembers[1]);
                }

                String[] valueParams = keyMembers[2].split(',');
                Integer valuecounter = 0;
                gen.writeFieldName('values');
                gen.writeStartObject();

                for (String valhere : valueParams) {
                    valhere.trim();
                    gen.writeFieldName('value_' + valuecounter);
                    gen.writeStartObject();

                    if (!auSeg.equalsIgnoreCase('Audience Segment')) {


                        if (dbKey != null) {

                            if (customSettings != null
                                    && customSettings.KeyValue_configuration__c == KEYVALUE_CONFIGURATION_ID) {

                                String adServerIDStr = valhere.right(valhere.length() - 1);

                                for (csdf__Custom_Targeting_Value__c val : dbKey.csdf__Custom_Targeting_Values__r) {

                                    if (val.csdf__Ad_Server_Id__c == adServerIDStr) {
                                        gen.writeStringField('sfId', val.Id);
                                        gen.writeStringField('userLabel', val.csdf__Display_Name__c);
                                        break;
                                    } else {
                                        continue;
                                    }
                                }
                            } else {

                                for (csdf__Custom_Targeting_Value__c val : dbKey.csdf__Custom_Targeting_Values__r) {

                                    if (val.Name == valhere) {
                                        gen.writeStringField('sfId', val.Id);
                                        gen.writeStringField('userLabel', val.csdf__Display_Name__c);
                                        break;
                                    } else {
                                        continue;
                                    }
                                }
                            }
                        }
                    } else {

                        csdf__Targetable__c obj = CS_Util.findTargetable(valhere, targetable);
                        if (obj != null) {
                            gen.writeStringField('sfId', obj.Id);
                            gen.writeStringField('userLabel', obj.csdf__Targetable_Name__c);

                        } else {
                            gen.writeStringField('sfId', 'Targetable ID not found in SFDC');
                            gen.writeStringField('userLabel', valhere);

                        }


                    }
                    gen.writeStringField('adId', valhere);
                    gen.writeEndObject();

                    valuecounter++;
                }
                gen.writeEndObject();

                gen.writeEndObject();
            }
            gen.writeEndObject();
        }
        gen.writeEndObject();

        return encodeURIComponent(gen.getAsString());
    }

    public static String encodeURIComponent(String inputStr) {
        return EncodingUtil.base64Encode(Blob.valueOf(inputStr));
    }

    public static Set<String> getKeyValues(String thing) {

        Set<String> theList = new Set<String>();

        if (thing == null || String.isBlank(thing)) return theList;

        String thing1 = thing.replace(' AND ', ' and ');

        String thing2 = CS_Util.replaceAll(' is not ', ' isnot ', thing1, true);

        String[] ORparams = thing2.split(' OR ');

        for (String sett : ORparams) {

            System.debug('sett: ' + sett);

            String step1 = sett.replace(' or ', ',');

            String[] keyParams = step1.split(' and ');


            for (String a : keyParams) {

                System.debug('keyParam: ' + a);

                if (a.containsIgnoreCase('Audience Segment')) continue;

                String[] keyMembers = a.split(' ');

                String[] valueParams = keyMembers[2].split(',');
                System.debug('valueParams: ' + valueParams);
                for (String c : valueParams) {
                    System.debug('valueParam:  ' + c);
                    theList.add(c);

                }
            }
        }

        System.debug(theList);

        return theList;
    }

    public static Set<String> getKeys(String thing) {

        Set<String> theList = new Set<String>();
        if (thing == null || String.isBlank(thing)) return theList;

        String thing1 = thing.replace(' AND ', ' and ');
        String thing2 = CS_Util.replaceAll(' is not ', ' isnot ', thing1, true);
        String[] ORparams = thing2.split(' OR ');

        for (String sett : ORparams) {

            System.debug('sett: ' + sett);

            String step1 = sett.replace(' or ', ',');
            String[] keyParams = step1.split(' and ');

            for (String a : keyParams) {
                System.debug('keyParams: ' + keyParams);
                if (a.containsIgnoreCase('Audience Segment')) continue;
                String[] keyMembers = a.split(' ');
                for (String b : keyParams) {
                    System.debug('keyMembers: ' + keyMembers);

                    if (keyMembers.size() == 3)
                        theList.add(keyMembers[0]);
                }
            }
        }

        System.debug(theList);
        return theList;
    }

    public static Set<String> getAudienceSegmentKeyValues(String keyValuesExpression) {
        Set<String> audienceKeyValuesSet = new Set<String>();

        if (keyValuesExpression == null || String.isBlank(keyValuesExpression))
            return audienceKeyValuesSet;

        String thing1 = keyValuesExpression.replace(' AND ', ' and ');
        String thing2 = CS_Util.replaceAll(' is not ', ' isnot ', thing1, true);
        String[] sets = thing2.split(' OR ');

        for (String setString : sets) {
            System.debug('setString: ' + setString);
            String replacedSetString = setString.replace(' or ', ',');
            String[] keyValuesElements = replacedSetString.split(' and ');

            for (String keyValuesElement : keyValuesElements) {
                System.debug('keyValuesElement: ' + keyValuesElement);
                if (!keyValuesElement.containsIgnoreCase('Audience Segment'))
                    continue;

                if (keyValuesElement.containsIgnoreCase('Audience Segment')) {
                    String[] keyValueElementsSplit = keyValuesElement.split(' ');

                    String[] values = keyValueElementsSplit[3].split(',');
                    System.debug('values: ' + values);
                    for (String value : values) {
                        System.debug('value:  ' + value);
                        audienceKeyValuesSet.add(value);
                    }
                }
            }
        }

        System.debug(audienceKeyValuesSet);
        return audienceKeyValuesSet;
    }

    private static csdf__Custom_Targeting_Key__c findCustomTargetingKey(String key,  Map<String, csdf__Custom_Targeting_Key__c> listOfCTargeting, CS_Custom_Settings__c customSettings) {
        System.debug('### findCustomTargetingKey ###' + key + '###' + listOfCTargeting + '###' + customSettings + '###');

        String KeyCustom = key;
        csdf__Custom_Targeting_Key__c keyObj = null;
        if (key != null && !listOfCTargeting.isEmpty()) {
            if (KeyCustom == 'Audiencesegment') {
                KeyCustom = 'Audience Segment';
            }

            if (!KeyCustom.equalsIgnoreCase('Audience Segment')
                    && customSettings != null
                    && customSettings.KeyValue_configuration__c == KEYVALUE_CONFIGURATION_ID) {

                String adServerIdStr = KeyCustom.right(KeyCustom.length() - 1);
                keyObj = listOfCTargeting.get(adServerIdStr);
            } else {
                keyObj = listOfCTargeting.get(KeyCustom);
            }
        }

        return keyObj;
    }

    private static csdf__Targetable__c findTargetable(String value, Map<String, csdf__Targetable__c> listOfTargetable) {
        return listOfTargetable.containsKey(value) ? listOfTargetable.get(value) : null;
    }

    public static String replaceAll(String findtxt, String replacetxt, String str,
            Boolean isCaseInsensitive) {
        if (str == null) {
            return null;
        }
        if (findtxt == null || findtxt.length() == 0) {
            return str;
        }
        if (findtxt.length() > str.length()) {
            return str;
        }
        Integer counter = 0;
        String thesubstr = '';
        while ((counter < str.length())
                && (str.substring(counter).length() >= findtxt.length())) {
            thesubstr = str.substring(counter, counter + findtxt.length());
            if (isCaseInsensitive) {
                if (thesubstr.equalsIgnoreCase(findtxt)) {
                    str = str.substring(0, counter) + replacetxt
                            + str.substring(counter + findtxt.length());
                    // Failing to increment counter by replacetxt.length() leaves you open
                    // to an infinite-replacement loop scenario: Go to replace "a" with "aa" but
                    // increment counter by only 1 and you'll be replacing 'a's forever.
                    counter += replacetxt.length();
                } else {
                    counter++; // No match so move on to the next character from
                    // which to check for a findtxt string match.
                }
            } else {
                if (thesubstr.equals(findtxt)) {
                    str = str.substring(0, counter) + replacetxt
                            + str.substring(counter + findtxt.length());
                    counter += replacetxt.length();
                } else {
                    counter++;
                }
            }
        }
        return str;
    }

    /* end of: JSON generator*/


    // METHOD TO LOG ERRORS INTO A NEW CSCFGA LOG ENTRY object
    public static cscfga__Log_Entry__c createErrorLog(String originalProcess, Id sourcerecordId, String errorMessage) {
        cscfga__Log_Entry__c logEntry = new cscfga__Log_Entry__c();
        logEntry.cscfga__Log_Date__c = System.now();
        logEntry.cscfga__Log_Detail__c = errorMessage;
        logEntry.cscfga__Severity__c = 'ERROR';
        logEntry.Origin__c = originalProcess;
        logEntry.Source_Record_Id__c = sourcerecordId;
        return logEntry;
    }

    // METHOD TO PARSE AND LOG AN EXCEPTION DIRECTLY INTO AN NEW CSCFGA LOG_ENTRY OBJECT
    public static cscfga__Log_Entry__c createErrorLog(String originalProcess, Id sourceRecordId, Exception ex) {
        String message = ex.getMessage() + ' - ' + ex.getCause() + ' - ' + ex.getStackTraceString();
        return createErrorLog(originalProcess, sourceRecordId, message);
    }

    // Method to get String before ';', data without Creatives
    public static String trimCltDataFrom(String getLongCustomKeyTargetingStr) {
        if (String.isBlank(getLongCustomKeyTargetingStr)) {
            return '';
        }
        Matcher longCustomKeyTargetingPatternMatcher = orderLevelTargetingPattern.matcher(getLongCustomKeyTargetingStr);
        if (longCustomKeyTargetingPatternMatcher.find()) {
            return longCustomKeyTargetingPatternMatcher.group(4);
        }
        return getLongCustomKeyTargetingStr;
    }

    // Method to get String with data after ';' - if no then empty string
    public static String getCltDataFrom(String getLongCustomKeyTargetingStr) {
        if (String.isBlank(getLongCustomKeyTargetingStr)) {
            return '';
        }
        Matcher cltPatternMatcher = cltPattern.matcher(getLongCustomKeyTargetingStr);
        List<String> cltStringsList = new List<String>();
        while (cltPatternMatcher.find()) {
            cltStringsList.add(cltPatternMatcher.group(0));
        }
        return String.join(cltStringsList, ';');
    }

    // Method to see if String contains ';'
    public static Boolean containsCltData(String getLongCustomKeyTargetingStr) {
        return !String.isBlank(getLongCustomKeyTargetingStr) && (getLongCustomKeyTargetingStr.indexOf(';') != -1);
    }

    public static void spinWait(Long delayInMilliseconds) {
        Long startingTime = System.now().getTime();
        while (System.now().getTime() - startingTime < delayInMilliseconds) { }
    }
}