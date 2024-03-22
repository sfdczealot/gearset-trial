/**
 * Created by ivan.ravnjak on 16.3.2020..
 */

@IsTest
private class CS_ApprovalDefinitionTest {
    @IsTest
    static void testFields() {
        StaticResource apd = [SELECT Id, Body FROM StaticResource WHERE Name = 'CS_ApprovalDefinition' LIMIT 1];
        CS_ApprovalService.ApprovalDefinition approvalDefinition = new CS_ApprovalService.ApprovalDefinition();
        approvalDefinition = (CS_ApprovalService.ApprovalDefinition) JSON.deserialize(apd.Body.toString(), CS_ApprovalService.approvalDefinition.class);

        for (String defFieldName : approvalDefinition.approvalProperties.fields) {
            Set<String> objectFields = Schema.SObjectType.csmso__Sales_Order__c.fields.getMap().keySet();
            for (String fieldNameFromSObject : objectFields) {
                System.assertEquals(true, objectFields.contains(fieldNameFromSObject), 'SO Field used in ApprovalDefinition cannot be found on Sales Order object');
            }
        }
    }

    @IsTest (SeeAllData=true)
    static void testAttributes() {
        StaticResource apd = [SELECT Id, Body FROM StaticResource WHERE Name = 'CS_ApprovalDefinition' LIMIT 1];
        CS_ApprovalService.ApprovalDefinition approvalDefinition = new CS_ApprovalService.ApprovalDefinition();
        approvalDefinition = (CS_ApprovalService.ApprovalDefinition) JSON.deserialize(apd.Body.toString(), CS_ApprovalService.approvalDefinition.class);

        List<cscfga__Attribute_Definition__c> listAttributeDefinitions = [
                SELECT Id, Name, cscfga__Product_Definition__r.Name
                FROM cscfga__Attribute_Definition__c
                WHERE cscfga__Product_Definition__r.cscfga__Active__c = TRUE
        ];
        List<String> attrDefNames = new List<String>();
        for (cscfga__Attribute_Definition__c attrDefinition : listAttributeDefinitions) {
            attrDefNames.add(attrDefinition.Name);
        }

        for (String defFieldName : approvalDefinition.approvalProperties.attributes) {
            //System.assertEquals(true, attrDefNames.contains(defFieldName), 'Attribute, '+defFieldName+', used in ApprovalDefinition cannot be found on active Product Definitions');
        }
    }

    @IsTest
    static void testLoad() {
        StaticResource apd = [SELECT Id, Body FROM StaticResource WHERE Name = 'CS_ApprovalDefinition' LIMIT 1];
        CS_ApprovalService.ApprovalDefinition approvalDefinition = new CS_ApprovalService.ApprovalDefinition();
        approvalDefinition = (CS_ApprovalService.ApprovalDefinition) JSON.deserialize(apd.Body.toString(), CS_ApprovalService.approvalDefinition.class);

        System.assertEquals(true, approvalDefinition != null);
        System.assertEquals(true, approvalDefinition.approvalProperties != null);
        System.assertEquals(true, approvalDefinition.approvalLineLevel != null);
        System.assertEquals(true, approvalDefinition.approvalOrderLevel != null);
        System.assertEquals(true, approvalDefinition.approvalProperties.fields.size() > 0);
        System.assertEquals(true, approvalDefinition.approvalProperties.attributes.size() > 0);

        List<Approval_Type__mdt> approvalTypesList = new List<Approval_Type__mdt>();
        Map<String, Approval_Type__mdt> approvalTypes = new Map<String, Approval_Type__mdt>();
        approvalTypesList = [
                SELECT Id, Label, Snapshot_Filename__c, Order_Result_Filename__c, Order_Line_Result_Filename__c, Field_Name__c, Approval_Process__c, Approval_Group__c, Sequence__c, Monitor_Fields__c
                FROM Approval_Type__mdt
                ORDER BY Sequence__c
        ];

        if (!approvalTypesList.isEmpty()) {
            approvalTypes = new Map<String, Approval_Type__mdt>();
            for (Approval_Type__mdt currApprovalType : approvalTypesList) {
                approvalTypes.put(currApprovalType.Label, currApprovalType);
            }
        }
        System.assertEquals(true, approvalTypes != null);

        List<String> approvalPassList = new List<String>();
        approvalPassList.add(CS_ApprovalService.ApprovalPass_First);
        approvalPassList.add(CS_ApprovalService.ApprovalPass_Second);
        approvalPassList.add(CS_ApprovalService.ApprovalPass_Any);

        Set<String> usedAttributesList = new Set<String>();
        Set<String> usedFieldsList = new Set<String>();

        for (String currApprovalName : CS_ApprovalService.approvalTypes.keySet()) {
            List<Map<String, CS_ApprovalService.ApprovalType>> approvalLevels = new List<Map<String, CS_ApprovalService.ApprovalType>>();
            approvalLevels.add(approvalDefinition.approvalLineLevel.approvalTypes.get(currApprovalName));
            approvalLevels.add(approvalDefinition.approvalOrderLevel.approvalTypes.get(currApprovalName));
            for (Map<String, CS_ApprovalService.ApprovalType> currentOrderLevel : approvalLevels) {
                for (String approvalTypeName : currentOrderLevel.keySet()) {
                    CS_ApprovalService.ApprovalType currentApprovalType = currentOrderLevel.get(approvalTypeName);

                    System.assertEquals(true, approvalPassList.contains(currentApprovalType.approvalPass));

                    for (CS_ApprovalService.ApprovalCriteria currentCriteria : currentApprovalType.criteria) {
                        validateCriteria(currentCriteria);
                        List<CS_ApprovalService.ApprovalProperty> currentApprovalPropertyList = currentCriteria.property;
                        for (CS_ApprovalService.ApprovalProperty currentApprovalProperty : currentApprovalPropertyList) {
                            if (currentApprovalProperty.type == 'attribute') usedAttributesList.add(currentApprovalProperty.name);
                            if (currentApprovalProperty.type == 'field') usedFieldsList.add(currentApprovalProperty.name);
                        }
                    }
                }
            }

        }

        if (!usedFieldsList.isEmpty()) {
            for (String usedField : usedFieldsList) {
                System.assertEquals(true, approvalDefinition.approvalProperties.fields.contains(usedField), 'Missing field ' + usedField);
            }
        }
        if (!usedAttributesList.isEmpty()) {
            for (String usedAttribute : usedAttributesList) {
                if(usedAttribute.contains('.')){
                    System.assertEquals(true, approvalDefinition.approvalProperties.attributes.contains(usedAttribute.substringBefore('.')), 'Missing attribute ' + usedAttribute);
                } else {
                    System.assertEquals(true, approvalDefinition.approvalProperties.attributes.contains(usedAttribute), 'Missing attribute ' + usedAttribute);
                }
            }
        }

    }

    private static void validateCriteria(CS_ApprovalService.ApprovalCriteria approvalCriteria) {
        List<String> validOperations = new List<String>{
                'less than', 'greater than', 'equals', 'not equals', 'less than or equals', 'greater than or equals', 'changed', 'in', 'not in'
        };
        System.assertEquals(true, validOperations.contains(approvalCriteria.operation));

        if (approvalCriteria.operation == 'changed') {
            System.assertEquals(true, approvalCriteria.value == '');
        }

        List<String> validDataTypes = new List<String>{
                'List', 'Decimal', 'String', 'Boolean'
        };
        if (approvalCriteria.operation == 'changed') {
            System.assertEquals(true, approvalCriteria.dataType == '');
        } else {
            System.assertEquals(true, validDataTypes.contains(approvalCriteria.dataType));
        }
    }

}