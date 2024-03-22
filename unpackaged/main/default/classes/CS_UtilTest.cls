@IsTest
public class CS_UtilTest {

    @IsTest
    public static void testStraightForwardUtilMethods() {
        String fieldListAsCSV = CS_Util.getFieldListAsCSV(Account.SObjectType);
        System.assert(!String.isEmpty(fieldListAsCSV));

        String fieldListAsCSV2 = CS_Util.getFieldListAsCSV('Account');
        System.assert(!String.isEmpty(fieldListAsCSV));
        System.assert(fieldListAsCSV == fieldListAsCSV2);

        String fieldListAsWithPrefix = CS_Util.getFieldListAsWithPrefix(Account.SObjectType, 'Name');
        System.assert(!String.isEmpty(fieldListAsWithPrefix));

        String fieldListAsWithOutPrefix = CS_Util.getFieldListAsWithOutPrefix(Account.SObjectType, 'Name');
        System.assert(!String.isEmpty(fieldListAsWithOutPrefix));

        String fieldListAsCSVOnlyUpdatable = CS_Util.getFieldListAsCSVOnlyUpdatable(Account.SObjectType);
        System.assert(!String.isEmpty(fieldListAsCSVOnlyUpdatable));

        Map<String, Schema.SObjectField> objectUpdateFieldsMap = CS_Util.getObjectUpdateFields(Account.SObjectType);
        System.assert(!objectUpdateFieldsMap.isEmpty());

        DescribeFieldResult fieldDescribeResult = CS_Util.getFieldDescribe(Account.SObjectType, 'Name');
        System.assert(fieldDescribeResult != null);

        DescribeSObjectResult sObjectResult = CS_Util.getObjectDescribe(Account.SObjectType);
        System.assert(sObjectResult != null);

        Boolean fieldExists = CS_Util.FieldExists(Account.SObjectType, 'Name');
        System.assert(fieldExists);

        Object correctStringType = CS_Util.getCorrectType(Account.SObjectType, 'Name', 'abc');
        System.assert(!String.isEmpty((String)correctStringType));

        Datetime datetimeNow = Datetime.now();
        Object correctType = CS_Util.getCorrectType(Account.SObjectType, 'AA_Completed_Date__c', String.valueOf(datetimeNow));
        System.assert(String.valueOf((Datetime)correctType) == String.valueOf(datetimeNow));

        Date dateToday = Date.today();
        Object correctType1 = CS_Util.getCorrectType(Account.SObjectType, 'cscfga__SLAExpirationDate__c', String.valueOf(dateToday));
        System.assert(String.valueOf((Date)correctType1) == String.valueOf(dateToday));

        Object correctType3 = CS_Util.getCorrectType(Account.SObjectType, 'AnnualRevenue', '10.60');
        System.assert((Decimal)correctType3 == 10.6);

        Object correctType4 = CS_Util.getCorrectType(Lead.SObjectType, 'NumberOfEmployees', '123');
        System.assert((Integer)correctType4 == 123);

        String keyPrefix = CS_Util.findKeyPrefix(Account.SObjectType);
        System.assert(keyPrefix == '001');

        String guid = CS_Util.GenerateGuid();
        System.assert(!String.isEmpty(guid));

        String trimmedCtlData = CS_Util.trimCltDataFrom('#11823193 is #448034020020 or #448034019693 or #448034020023 or #448034019696');
        System.assert(trimmedCtlData == '#11823193 is #448034020020 or #448034019693 or #448034020023 or #448034019696');

        String ctlData = CS_Util.getCltDataFrom('#11823193 is #448034020020 or #448034019693 or #448034020023 or #448034019696');
        System.assert(String.isEmpty(ctlData));

        Boolean containsCltData = CS_Util.containsCltData('#11823193 is #448034020020 or #448034019693 or #448034020023 or #448034019696');
        System.assert(!containsCltData);
    }

    @IsTest
    public static void testConvertToJSON() {
        Test.startTest();
        String thing = 'city is 11005_floral_park or 11020_great_neck or 11010_franklin_square AND Optimum is yes OR mflashlt is true and Audience segment is male,female';

        Map<String, csdf__Custom_Targeting_Key__c> listOfCTargetingMap = new Map<String, csdf__Custom_Targeting_Key__c>();
        List<csdf__Custom_Targeting_Key__c> listOfCTargeting = new List<csdf__Custom_Targeting_Key__c>{
                new csdf__Custom_Targeting_Key__c(csdf__Display_Name__c = 'city', Name = 'city', csdf__Ad_Server_Id__c = '71121'),
                new csdf__Custom_Targeting_Key__c(csdf__Display_Name__c = '11005_floral_park', Name = '11005_floral_park', csdf__Ad_Server_Id__c = '711212'),
                new csdf__Custom_Targeting_Key__c(csdf__Display_Name__c = '11020_great_neck', Name = '11020_great_neck', csdf__Ad_Server_Id__c = '711213'),
                new csdf__Custom_Targeting_Key__c(csdf__Display_Name__c = '11010_franklin_square', Name = '11010_franklin_square', csdf__Ad_Server_Id__c = '711214')
        };
        insert listOfCTargeting;

        for(csdf__Custom_Targeting_Key__c cTargeting : listOfCTargeting) {
            listOfCTargetingMap.put(cTargeting.csdf__Ad_Server_Id__c, cTargeting);
            listOfCTargetingMap.put(cTargeting.Name, cTargeting);
        }

        csdf__Ad_Server__c testAdServer = TestDataSetupTargetables.createAdServer();
        insert testAdServer;

        Map<String, csdf__Targetable__c> targetableMap = new Map<String, csdf__Targetable__c>();
        List<csdf__Targetable__c> listOfTargetable = new List<csdf__Targetable__c>{
                new csdf__Targetable__c(csdf__Targetable_Name__c = 'male', csdf__Ad_Server_Id__c = '404351609', csdf__Type__c = 'gender', csdf__Ad_Server__c = testAdServer.Id),
                new csdf__Targetable__c(csdf__Targetable_Name__c = 'female', csdf__Ad_Server_Id__c = '397815454', csdf__Type__c = 'gender', csdf__Ad_Server__c = testAdServer.Id)
        };
        insert listOfTargetable;

        for(csdf__Targetable__c targetable : listOfTargetable) {
            targetableMap.put(targetable.csdf__Ad_Server_Id__c, targetable);
        }

        CS_Custom_Settings__c customSettings = TestDataSetupTargetables.createCSCustomSettings();

        String s = CS_Util.convertToJSON(thing, listOfCTargetingMap, targetableMap, customSettings);

        Set<String> test1 = CS_Util.getKeyValues(thing);
        Set<String> test2 = CS_Util.getKeys(thing);

        thing = '71121 is 711212 or 711213 or 711214 AND 711215 is 711216 OR 711217 is 711218 and Audience segment is 404351609,397815454';
        customSettings.KeyValue_configuration__c = 'ID';
        update customSettings;

        s = CS_Util.convertToJSON(thing, listOfCTargetingMap, targetableMap, customSettings);

        test1 = CS_Util.getKeyValues(thing);
        test2 = CS_Util.getKeys(thing);

        System.debug(s);
        Test.stopTest();
    }

    @IsTest
    public static void testCreateErrorLog() {
        cscfga__Log_Entry__c errorLog = CS_Util.createErrorLog('OriginalProcess', Id.valueOf('00125000000CiV0EAK'), 'Error message');
        System.assert(errorLog != null);
    }
}