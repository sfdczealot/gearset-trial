public without sharing class CS_ApprovalService {
    public static final String ApprovalPass_First = 'first';
    public static final String ApprovalPass_Second = 'second';
    public static final String ApprovalPass_Any = 'any';

    public static final String DataType_String = 'String';
    public static final String DataType_List = 'List';
    public static final String DataType_Boolean = 'Boolean';
    public static final String DataType_Decimal = 'Decimal';

    public static final Map<String, CS_utl_Comparison.Comparison> ApprovalComparison = new Map<String, CS_utl_Comparison.Comparison>{
            'less than' => CS_utl_Comparison.Comparison.LESS_THAN,
            'greater than' => CS_utl_Comparison.Comparison.GREATER_THAN,
            'equals' => CS_utl_Comparison.Comparison.EQUALS,
            'not equals' => CS_utl_Comparison.Comparison.NOT_EQUALS,
            'less than or equals' => CS_utl_Comparison.Comparison.LESS_THAN_OR_EQUALS,
            'greater than or equals' => CS_utl_Comparison.Comparison.GREATER_THAN_OR_EQUALS
    };

    public static Map<String, Approval_Type__mdt> approvalTypes {
        get {
            List<Approval_Type__mdt> approvalTypesList = new List<Approval_Type__mdt>();
            if (approvalTypes == null) {
                approvalTypesList = [
                        SELECT Id, Label, Snapshot_Filename__c, Order_Result_Filename__c, Order_Line_Result_Filename__c, Field_Name__c, Approval_Process__c, Approval_Group__c, Sequence__c, Monitor_Fields__c
                        FROM Approval_Type__mdt
                        ORDER BY Sequence__c
                ];
            }
            if (!approvalTypesList.isEmpty()) {
                approvalTypes = new Map<String, Approval_Type__mdt>();
                for (Approval_Type__mdt currApprovalType : approvalTypesList) {
                    approvalTypes.put(currApprovalType.Label, currApprovalType);
                }
            }
            return approvalTypes;
        }
        set;
    }

    public static ApprovalDefinition approvalDefinition {
        get {
            if (approvalDefinition == null) {
                StaticResource apd = [SELECT Id, Body FROM StaticResource WHERE Name = 'CS_ApprovalDefinition' LIMIT 1];
                approvalDefinition = (ApprovalDefinition) JSON.deserialize(apd.Body.toString(), ApprovalDefinition.class);
            }

            return approvalDefinition;
        }
        set;
    }

    public Map<String, String> approvalIndicators {
        get {
            if(approvalIndicators == null) {
                approvalIndicators = new Map<String, String>{
                        'Inventory' => '',
                        'SD' => '',
                        'CM' => '',
                        'HOB' => '',
                        'HOB Fintech' => '',
                        'HOB Fastkey' => '',
                        'HOB MaaS' => '',
                        'HOB Events' => '',
                        'HOB Awards' => '',
                        'HOB CNS' => '',
                        'Pricing' => '',
                        'Account Check' => '',
                        'Customer' => '',
                        'Legal' => '',
                        'Countersign IO' => '',
                        'Compliance' => ''
                };
            }

            return approvalIndicators;
        }
        set;
    }

    public static Object getValue(String dataType, String value) {
        if (dataType == DataType_Boolean) {
            return String.isNotBlank(value) && (value.equalsIgnoreCase('yes') || value.equalsIgnoreCase('true'));
        } else if (dataType == DataType_Decimal) {
            return value == null ? 0 : Decimal.valueOf(value);
        } else if (dataType == DataType_String) {
            return value == null ? '' : value;
        } else if (dataType == DataType_List) {
            return value.split(',');
        }

        else throw new ApprovalException('Unsupported Data Type: ' + dataType);
    }

    public static Object getValue(String dataType, String value, Map<String, String> values) {
        return getValue(dataType, value.startsWith('{') ? values.get(value.substringBetween('{', '}')) : value);
    }

    public static void checkApprovals(Set<Id> salesOrderIds) {
        CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();

        for (Id salesOrderId : salesOrderIds) {
            dispatcher.addWorker(new ApprovalQueueableWorker(new Map<String, Object>{
                    'salesOrderId' => salesOrderId
            }));
        }

        dispatcher.dispatch();
    }

    public static void submitForApprovals(Id salesOrderId) {
        csmso__Sales_Order__c salesOrder = CS_utl_SalesOrder.getSalesOrder(salesOrderId);

        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        req1.setComments(salesOrder.Comments__c);
        req1.setObjectId(salesOrder.Id);
        req1.setSubmitterId(salesOrder.Submitted_By__c);
        Approval.ProcessResult result = Approval.process(req1);
        //sales order was updated in the meantime
        salesOrder = CS_utl_SalesOrder.getSalesOrder(salesOrder.Id);
        if(result.isSuccess()) {
            salesOrder.Comments__c = '';
            salesOrder.Order_Synced_before_final_approval__c = false;

            update salesOrder;

            List<CSPOFA__Orchestration_Step__c> steps = [SELECT Id, CSPOFA__Status__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c
            WHERE CSPOFA__External_Id__c = :salesOrder.Id AND CSPOFA__Status__c = 'Waiting For Feedback'];
            for(CSPOFA__Orchestration_Step__c step : steps) {
                step.CSPOFA__Status__c = 'Complete';
                step.CSPOFA__Message__c = 'Sales Order submitted for approval.';
                step.CSPOFA__Completed_Date__c = Date.today();
            }

            update steps;
        }
        else {
            salesOrder.Submitted_By__c = null;
            salesOrder.csmso__Process_Message__c = result.getErrors()[0].getMessage();
            salesOrder.csmso__Process_Message_Type__c = 'error';
            salesOrder.Loading_Screen__c = 'Off';

            update salesOrder;
        }
    }

    // STARTS Approval Logic
    public csmso__Sales_Order__c checkApprovals(csmso__Sales_Order__c salesOrder) {
        List<cscfga__Product_Configuration__c> productConfigurationsList = new List<cscfga__Product_Configuration__c>();
        //stores state of SO approval indicators before approval logic has updated them.
        Map<String, String> oldApprovalIndicatorValues = new Map<String, String>();
        Map<String, List<ApprovalResultSnapshot>> approvalLineResultSnapshotsToType = new Map<String, List<ApprovalResultSnapshot>>();
        Map<String, List<ApprovalResultSnapshot>> approvalOrderResultSnapshotsToType = new Map<String, List<ApprovalResultSnapshot>>();
        //Get current data
        Map<Id, Map<String, String>> values = getSalesOrderLineItemValues(salesOrder.Id, productConfigurationsList);
        if(values.isEmpty()){
            return salesOrder;
        }

        Id basketId = getBasketId(salesOrder.Id);
        List<String> snapshotsFileNames = getSnapshotsFileNames();
        //get PC snapshot attachments from all Configurations and for all approvals
        Map<String, Map<Id, ApprovalSnapshot>> csApprovalSnapshotAttachmentToTypeMap = getSnapshotDataFromAttachment(values.keySet(), snapshotsFileNames);
        for (String approvalType : approvalDefinition.getApprovalTypes()) {
            //store initial values of SO approval indicators for later use
            Id firstlineId = new List<Id>(values.keySet()).get(0);
            String previousApprovalStatus = values.get(firstlineId).get('Sales_Order__r.' + CS_ApprovalService.approvalTypes.get(approvalType).Field_Name__c);
            oldApprovalIndicatorValues.put(CS_ApprovalService.approvalTypes.get(approvalType).Field_Name__c, previousApprovalStatus);

            List<ApprovalResultSnapshot> approvalLineResultSnapshotsList = new List<ApprovalResultSnapshot>();
            List<ApprovalResultSnapshot> approvalOrderResultSnapshotsList = new List<ApprovalResultSnapshot>();
            Map<Id, Map<String, String>> oldValues = new Map<Id, Map<String, String>>();

            Map<Id, ApprovalSnapshot> csApprovalSnapshotAttachmentMap = new Map<Id, ApprovalSnapshot>();
            if(csApprovalSnapshotAttachmentToTypeMap.get(approvalType) != null){
                csApprovalSnapshotAttachmentMap = csApprovalSnapshotAttachmentToTypeMap.get(approvalType);
            }

            // Customer approval requires results from first n approvals. Put approval results in map of current values.
            if (approvalType == 'Customer' && !csApprovalSnapshotAttachmentMap.isEmpty()) {
                for (Id lineId : values.keySet()) {
                    values.get(lineId).put('Sales_Order__r.SD_Approval__c', this.approvalIndicators.get('SD'));
                    values.get(lineId).put('Sales_Order__r.CM_Approval__c', this.approvalIndicators.get('CM'));
                    values.get(lineId).put('Sales_Order__r.HOB_FastKey_Approval__c', this.approvalIndicators.get('HOB Fastkey'));
                    values.get(lineId).put('Sales_Order__r.HOB_Fintech_Approval__c', this.approvalIndicators.get('HOB Fintech'));
                    values.get(lineId).put('Sales_Order__r.HOB_MaaS_Approval__c', this.approvalIndicators.get('HOB MaaS'));
                    values.get(lineId).put('Sales_Order__r.HOB_Awards_Approval__c', this.approvalIndicators.get('HOB Awards'));
                    values.get(lineId).put('Sales_Order__r.HOB_CNS_Approval__c', this.approvalIndicators.get('HOB CNS'));
                    values.get(lineId).put('Sales_Order__r.CBO_Approval__c', this.approvalIndicators.get('CBO'));
                }
            }

            // OMC approval requires results from Customer Approval
            if (approvalType == 'OMC') {
                for (Id lineId : values.keySet()) {
                    values.get(lineId).put('Sales_Order__r.Customer_Approval__c', this.approvalIndicators.get('Customer'));
                }
            }

            //MAIN APPROVAL LOGIC STARTS HERE
            if (csApprovalSnapshotAttachmentMap.isEmpty()) {
                //first time approval, no snapshot available on PC
                isApprovalRequired(approvalType, values, new Map<Id, Map<String, String>>(), basketId, approvalLineResultSnapshotsList, approvalOrderResultSnapshotsList);
            } else {
                oldValues = prepareOldValuesFromSnapshot(oldValues, csApprovalSnapshotAttachmentMap);
                //IFC approval, previous snapshot available on PC
                isApprovalRequired(approvalType, values, oldValues, basketId, approvalLineResultSnapshotsList, approvalOrderResultSnapshotsList);
            }

            //prepare data
            if (!approvalLineResultSnapshotsList.isEmpty()) {
                this.approvalIndicators.put(approvalType, 'Pending');
                approvalLineResultSnapshotsToType.put(approvalType, approvalLineResultSnapshotsList);
            }
            if (!approvalOrderResultSnapshotsList.isEmpty()) {
                this.approvalIndicators.put(approvalType, 'Pending');
                approvalOrderResultSnapshotsToType.put(approvalType, approvalOrderResultSnapshotsList);
            }
        }
        //Delete old Result Attachments
        List<String> resultSnapshotFileNames = getAllSnapshotsResultsFileNames();

        CS_Attachment.removeAttachments(resultSnapshotFileNames, basketId);

        //Create Result Attachments
        if (!approvalLineResultSnapshotsToType.isEmpty()) {
            Map<String, String> snapshotsResultsLineFileNames = getSnapshotsResultsFileNames('Line');
            prepareAndGenerateAttachements(approvalLineResultSnapshotsToType, basketId, snapshotsResultsLineFileNames);
        }
        if (!approvalOrderResultSnapshotsToType.isEmpty()) {
            Map<String, String> snapshotsResultsOrderFileNames = getSnapshotsResultsFileNames('Order');
            prepareAndGenerateAttachements(approvalOrderResultSnapshotsToType, basketId, snapshotsResultsOrderFileNames);
        }

        //update approval indicator fields on Sales Order
        for (String currApproval : CS_ApprovalService.approvalTypes.keySet()) {
            String nextStatus;
            if (this.approvalIndicators.get(currApproval) == CS_const_SalesOrder.ApprovalStatus_Pending) {
                nextStatus = this.approvalIndicators.get(currApproval);
            } else if (this.approvalIndicators.get(currApproval) == '') {
                String previousApprovalStatus = oldApprovalIndicatorValues.get(CS_ApprovalService.approvalTypes.get(currApproval).Field_Name__c);
                nextStatus = previousApprovalStatus == CS_const_SalesOrder.ApprovalStatus_Approved ? CS_const_SalesOrder.ApprovalStatus_Approved : '';
            }
            salesOrder.put(CS_ApprovalService.approvalTypes.get(currApproval).Field_Name__c, nextStatus);
        }
        return salesOrder;
    }


    public void isApprovalRequired(String approvalType, Map<Id, Map<String, String>> values, Map<Id, Map<String, String>> oldValues,
            Id basketId, List<ApprovalResultSnapshot> approvalLineResultSnapshotsList, List<ApprovalResultSnapshot> approvalResultSnapshotsList) {
        ApprovalLevels currApprovalLineLevel = approvalDefinition.getApprovalLineLevel();
        ApprovalLevels currApprovalOrderLevel = approvalDefinition.getApprovalOrderLevel();
        List<ApprovalResult> approvalResultsListLine = new List<ApprovalResult>();

        for (Id lineId : values.keySet()) {
            ApprovalResultSnapshot approvalResultSnapshotLine = new ApprovalResultSnapshot();
            approvalResultSnapshotLine.ProductBasketId = basketId;
            approvalResultSnapshotLine.ProductConfigurationId = lineId;
            approvalResultSnapshotLine.ApprovalResultList = new List<ApprovalResult>();

            //Check if product is skipping approval for this line
            if (values.get(lineId).containsKey('Skip Approvals') && String.isNotBlank(values.get(lineId).get('Skip Approvals'))) {
                List<String> skipApprovalsForLineList = new List<String>();
                skipApprovalsForLineList = values.get(lineId).get('Skip Approvals').split(';');

                if (skipApprovalsForLineList.contains(approvalType)) {
                    system.debug('skipping approval ' + approvalType + ' for line ' + lineId);
                    continue;
                }
            }
            //Process Line approval results
            approvalResultsListLine = isApprovalLineRequired(approvalType, values, oldValues, currApprovalLineLevel, lineId);
            if (!approvalResultsListLine.isEmpty()) {
                sortLineToResultsMap(approvalResultsListLine, approvalResultSnapshotLine, approvalLineResultSnapshotsList);
            }
        }
        //process Order level approval results
        ApprovalResultSnapshot approvalResultSnapshotOrder = new ApprovalResultSnapshot();
        approvalResultSnapshotOrder.ProductBasketId = basketId;
        approvalResultSnapshotOrder.ProductConfigurationId = null;
        approvalResultSnapshotOrder.ApprovalResultList = new List<ApprovalResult>();

        List<ApprovalResult> approvalResultsListOrder = new List<ApprovalResult>();
        approvalResultsListOrder = isApprovalOrderRequired(approvalType, values, oldValues, currApprovalOrderLevel);

        if (!approvalResultsListOrder.isEmpty()) {
            sortOrderToResultsMap(approvalResultsListOrder, approvalResultSnapshotOrder, approvalResultSnapshotsList);
        }
    }

    public void sortOrderToResultsMap(List<ApprovalResult> approvalResultsListOrder, ApprovalResultSnapshot approvalResultSnapshotOrder, List<ApprovalResultSnapshot> approvalResultSnapshotsList) {
        if (!approvalResultsListOrder.isEmpty()) {
            approvalResultSnapshotOrder.ApprovalResultList.addAll(approvalResultsListOrder);
            approvalResultSnapshotsList.add(approvalResultSnapshotOrder);
        }
    }

    public void sortLineToResultsMap(List<ApprovalResult> approvalResultsListLine, ApprovalResultSnapshot approvalResultSnapshotLine, List<ApprovalResultSnapshot> approvalResultSnapshotsList) {
        if (!approvalResultsListLine.isEmpty()) {
            approvalResultSnapshotLine.ApprovalResultList.addAll(approvalResultsListLine);
            approvalResultSnapshotsList.add(approvalResultSnapshotLine);
        }
    }

    public List<ApprovalResult> isApprovalLineRequired(String approvalType, Map<Id, Map<String, String>> values, Map<Id, Map<String, String>> oldValues, ApprovalLevels currentApprovalLevel, Id lineId) {

        List<ApprovalResult> approvalResultsList = new List<ApprovalResult>();
        Map<String, CS_ApprovalService.ApprovalType> currentApprovalType = new Map<String, CS_ApprovalService.ApprovalType>();
        currentApprovalType = currentApprovalLevel.approvalTypes.get(approvalType);

        approvalResultsList = isApprovalRequired(approvalType, values.get(lineId), oldValues.get(lineId), currentApprovalType);
        return approvalResultsList;
    }

    public List<ApprovalResult> isApprovalOrderRequired(String approvalType, Map<Id, Map<String, String>> values, Map<Id, Map<String, String>> oldValues, ApprovalLevels currentApprovalLevel) {
        Id lineId = new List<Id>(values.keySet()).get(0);

        List<ApprovalResult> approvalResultsList = new List<ApprovalResult>();
        Map<String, CS_ApprovalService.ApprovalType> currentApprovalType = new Map<String, CS_ApprovalService.ApprovalType>();
        currentApprovalType = currentApprovalLevel.approvalTypes.get(approvalType);

        approvalResultsList = isApprovalRequired(approvalType, values.get(lineId), oldValues.get(lineId), currentApprovalType);

        return approvalResultsList;
    }

    public Map<Id, Map<String, String>> prepareOldValuesFromSnapshot(Map<Id, Map<String, String>> oldValues, Map<Id, ApprovalSnapshot> csApprovalSnapshotAttachmentMap) {
        for (Id pcId : csApprovalSnapshotAttachmentMap.keySet()) {
            Map<String, String> tempMap = new Map<String, String>();
            for (String currentAttrKey : csApprovalSnapshotAttachmentMap.get(pcId).AttributeMap.keySet()) {
                tempMap.put(currentAttrKey, csApprovalSnapshotAttachmentMap.get(pcId).AttributeMap.get(currentAttrKey));
            }
            oldValues.put(pcId, tempMap);
        }

        return oldValues;
    }

    public void prepareAndGenerateAttachements(Map<String, List<ApprovalResultSnapshot>> approvalResultSnapshotsToType, Id basketId, Map<String, String> snapshotsResultsFileNames) {
        List<Attachment> attachmentList = new List<Attachment>();
        for (String approvalType : CS_ApprovalService.approvalTypes.keySet()) {
            String fileName = snapshotsResultsFileNames.get(approvalType);
            if (basketId != null && !String.isBlank(fileName) && approvalResultSnapshotsToType.get(approvalType) != null) {
                this.approvalIndicators.put(approvalType, 'Pending');
                Attachment attach = CS_Attachment.generateAttachment(JSON.serializePretty(approvalResultSnapshotsToType.get(approvalType), true), basketId, fileName);
                attachmentList.add(attach);
            }
        }
        if (!attachmentList.isEmpty()) {
            CS_Attachment.createAttachments(attachmentList, true);
        }
    }

    public List<String> getSnapshotsFileNames(){
        List<String> snapshotsFileNames = new List<String>();
        for (String approvalType : approvalDefinition.getApprovalTypes()) {
            snapshotsFileNames.add(CS_ApprovalService.approvalTypes.get(approvalType).Snapshot_Filename__c);
        }
        return snapshotsFileNames;
    }

    public List<String> getAllSnapshotsResultsFileNames(){
        List<String> resultSnapshotFileNames = new List<String>();
        for (String approvalType : approvalDefinition.getApprovalTypes()) {
            resultSnapshotFileNames.add(CS_ApprovalService.approvalTypes.get(approvalType).Order_Line_Result_Filename__c);
            resultSnapshotFileNames.add(CS_ApprovalService.approvalTypes.get(approvalType).Order_Result_Filename__c);
        }
        return resultSnapshotFileNames;
    }

    public Map<String, String> getSnapshotsResultsFileNames(String approvalLevel){
        Map<String, String> snapshotsFileNames = new Map<String, String>();

        for (String approvalType : approvalDefinition.getApprovalTypes()) {
            if(approvalLevel == 'Line'){
                snapshotsFileNames.put(approvalType, CS_ApprovalService.approvalTypes.get(approvalType).Order_Line_Result_Filename__c);
            } else if(approvalLevel == 'Order'){
                snapshotsFileNames.put(approvalType, CS_ApprovalService.approvalTypes.get(approvalType).Order_Result_Filename__c);
            }
        }
        return snapshotsFileNames;
    }

    public Map<Id, Map<String, String>> getSalesOrderLineItemValues(Id salesOrderId, List<cscfga__Product_Configuration__c> productConfigurationList) {
        Map<Id, Map<String, String>> values = new Map<Id, Map<String, String>>();

        //add field Fulfilment_Item_Status to be queried, shows if line is archived
        List<String> queryFieldsList = new List<String>{approvalDefinition.approvalProperties.getQueryFields(), 'Fulfilment_Item_Status__c'};
        String queryFields = CS_utl_Array.join(queryFieldsList, ',');
           

        List<cscfga__Product_Configuration__c> configurations = Database.Query ('select ' + queryFields + ' from cscfga__Product_Configuration__c where Sales_Order__c = :salesOrderId');
        String configurationIdsString = '';
        for (cscfga__Product_Configuration__c pc : configurations) {
            configurationIdsString += '\'' + pc.id + '\',';
        }
        configurationIdsString = configurationIdsString.removeEnd(',');
    
        List<cscfga__Attribute__c> queryAttributeList =  Database.Query(
        'select Id, Name, cscfga__Value__c, cscfga__Product_Configuration__c from cscfga__Attribute__c where cscfga__Product_Configuration__c IN (' + configurationIdsString + ') and Name in (\'' + approvalDefinition.approvalProperties.getQueryAttributes() + '\')');
                
                

        productConfigurationList = configurations;
        
        for (cscfga__Product_Configuration__c cfg : configurations) {
            //don't return values for archived lines
            if(cfg.Fulfilment_Item_Status__c == CS_Constants.STATUS_PAUSED_INVENTORY_RELEASED){
                continue;
            }
            Map<String, String> configValues = new Map<String, String>();

            for (String fieldName : approvalDefinition.approvalProperties.fields) {

                configValues.put(fieldName, CS_utl_SObject.getFieldValue(cfg, fieldName));
            }
            for (cscfga__Attribute__c attribute : queryAttributeList) {
                if (attribute.cscfga__Product_Configuration__c ==  cfg.id) {
                configValues.put(attribute.Name, attribute.cscfga__Value__c);
                }
            }

            values.put(cfg.Id, configValues);
        }

        return values;
    }

    public List<ApprovalResult> isApprovalRequired(String approvalType, Map<String, String> values, Map<String, String> oldValues, Map<String, CS_ApprovalService.ApprovalType> currentApprovalType) {
        Map<String, ApprovalType> approvals = currentApprovalType;
        List<ApprovalResult> approvalResultsList = new List<ApprovalResult>();
        for (ApprovalType at : approvals.values()) {
            approvalResultsList.addAll(at.isApplicable(values, oldValues, approvalType));
        }
        return approvalResultsList;
    }

    public Id getBasketId(Id salesOrderId) {
        Id basketId = [SELECT Id FROM cscfga__Product_Basket__c WHERE csmso__Sales_Order__c = :salesOrderId].Id;
        return basketId;
    }

    /// DATA FETCH
    public Map<Id, ApprovalSnapshot> getSnapshotData(List<cscfga__Product_Configuration__c> productConfigurationList) {

        Set<Id> productConfigurationIdSet = new Set<Id>();
        Set<Id> salesOrderIdSet = new Set<Id>();
        for (cscfga__Product_Configuration__c currentConfig : productConfigurationList) {
            productConfigurationIdSet.add(currentConfig.Id);
            salesOrderIdSet.add(currentConfig.Sales_Order__c);
        }

        Map<Id, ApprovalSnapshot> approvalSnapshotMap = new Map<Id, ApprovalSnapshot> ();
        Map<Id, Map<String, Object>> configToAttributesMap = new Map<Id, Map<String, String>>();

        //get relevant attributes names & values
        for (Id currentSOId : salesOrderIdSet) {
            configToAttributesMap.putAll(getSalesOrderLineItemValues(currentSOId, productConfigurationList));
        }

        for (cscfga__Product_Configuration__c currentProductConfiguration : productConfigurationList) {
            ApprovalSnapshot approvalSnapshot = new ApprovalSnapshot();
            approvalSnapshot.ProductConfigurationId = currentProductConfiguration.Id;
            approvalSnapshot.ProductBasketId = currentProductConfiguration.cscfga__Product_Basket__c;
            approvalSnapshot.AttributeMap = (Map<String, String>) configToAttributesMap.get(currentProductConfiguration.Id);

            approvalSnapshotMap.put(currentProductConfiguration.Id, approvalSnapshot);
        }

        return approvalSnapshotMap;
    }

    public Map<String, Map<Id, ApprovalSnapshot>> getSnapshotDataFromAttachment(Set<Id> productConfigurationSetIds, List<String> attachmentFileNames) {
        Map<String, Map<Id, ApprovalSnapshot>> approvalSnapshotToTypeMap = new Map<String, Map<Id, ApprovalSnapshot>>();

        Map<String, List<String>> attachmentContentToDeserializeMap = CS_Attachment.getAttachmentContentToDeserializeList(
                productConfigurationSetIds, attachmentFileNames);
        for(String approvalType : approvalDefinition.getApprovalTypes()) {
            Map<Id, ApprovalSnapshot> approvalSnapshotMap = new Map<Id, ApprovalSnapshot>();
            List<String> attachmentContentToDeserializeList = attachmentContentToDeserializeMap.get(CS_ApprovalService.approvalTypes.get(approvalType).Snapshot_Filename__c);

            if (attachmentContentToDeserializeList != null) {
                for (String currentAttachmentContentString : attachmentContentToDeserializeList) {
                    ApprovalSnapshot approvalSnapshot = new ApprovalSnapshot();
                    try{
                        approvalSnapshot = (ApprovalSnapshot) JSON.deserialize(currentAttachmentContentString, ApprovalSnapshot.class);
                        approvalSnapshotMap.put(approvalSnapshot.ProductConfigurationId, approvalSnapshot);
                    } catch (Exception e) {
                        System.debug('Unable to read snapshot attachment. error: '+e.getMessage()+' '+e.getStackTraceString());
                    }

                }
            }
            if(!approvalSnapshotMap.isEmpty()){
                approvalSnapshotToTypeMap.put(approvalType, approvalSnapshotMap);
            }
        }
        return approvalSnapshotToTypeMap;
    }


    public class ApprovalDefinition {
        public ApprovalProperties approvalProperties { get; set; }
        public ApprovalLevels approvalOrderLevel { get; set; }
        public ApprovalLevels approvalLineLevel { get; set; }

        public Set<String> getApprovalTypes() {
            return approvalLineLevel.approvalTypes.keySet();
        }

        public ApprovalLevels getApprovalLineLevel() {
            return approvalLineLevel;
        }

        public ApprovalLevels getApprovalOrderLevel() {
            return approvalOrderLevel;
        }
    }

    public class ApprovalLevels {
        public Map<String, Map<String, ApprovalType>> approvalTypes { get; set; }
    }

    public class ApprovalProperties {
        public List<String> fields { get; set; }
        public List<String> attributes { get; set; }

        public String getQueryFields() {
            return CS_utl_Array.join(fields, ',');
        }

        public String getQueryAttributes() {
            return CS_utl_Array.join(attributes, '\',\'');
        }
    }

    //RULES
    public class ApprovalType {
        public String approvalPass { get; set; }
        public List<ApprovalCriteria> criteria { get; set; }

        public List<ApprovalResult> isApplicable(Map<String, String> values, Map<String, String> oldValues, String approvalType) {
            List<ApprovalResult> approvalResultsList = new List<ApprovalResult>();

            if(isApprovalTypeApplicable(values, oldValues)){
                return isCriteriaApplicable(values, oldValues, approvalType);
            } else {
                return approvalResultsList;
            }

        }

        public Boolean isApprovalTypeApplicable(Map<String, String> values, Map<String, String> oldValues) {
            String currentApprovalPass = oldValues != null ? CS_ApprovalService.ApprovalPass_Second : CS_ApprovalService.ApprovalPass_First;

            if (this.approvalPass == CS_ApprovalService.ApprovalPass_Any) return true; else if (currentApprovalPass == this.approvalPass) return true; else return false;
        }

        public List<ApprovalResult> isCriteriaApplicable(Map<String, String> values, Map<String, String> oldValues, String approvalType) {
            List<ApprovalResult> approvalResultsList = new List<ApprovalResult>();
            Boolean criteriaApplicable = true;

            for(ApprovalCriteria c : criteria) {
                List <ApprovalResult> criteriaResultsList = c.isApplicable(values, oldValues, approvalType);
                if(!criteriaResultsList.isEmpty()) {
                    approvalResultsList.addAll(criteriaResultsList);
                }

                criteriaApplicable = criteriaApplicable && !criteriaResultsList.isEmpty();
            }

            if (!criteriaApplicable){
                approvalResultsList = new List<ApprovalResult>();
            }

            return approvalResultsList;
        }
    }

    public class ApprovalCriteria {
        public String operation { get; set; }
        public List<ApprovalProperty> property { get; set; }
        public String value { get; set; }
        public String dataType { get; set; }
        public String message { get; set; }

        public List <ApprovalResult> isApplicable(Map<String, String> values, Map<String, String> oldValues, String approvalType) {
            Object compareValue;
            if (!this.operation.equalsIgnoreCase('changed')) {
                compareValue = CS_ApprovalService.getValue(this.dataType, this.value, values);
            }
            List<ApprovalResult> approvalResultsList = new List<ApprovalResult>();

            for (ApprovalProperty p : this.property) {
                Boolean isApplicable = p.isApplicable(this.operation, compareValue, values, oldValues);

                if (isApplicable) {
                    ApprovalResult ar = p.getApprovalResult(this.operation, this.value, oldValues, values, approvalType);
                    if (ar != null) {
                        approvalResultsList.add(ar);
                    }
                }
            }

            return approvalResultsList;
        }
    }

    public class ApprovalProperty {
        public String name { get; set; }
        public String type { get; set; }
        public String dataType { get; set; }
        public String messageTemplate { get; set; }

        public ApprovalResult getApprovalResult(String operation, String value, Map<String, String> oldValues, Map<String, String> values, String approvalType) {
            if (messageTemplate != null) {
                return new ApprovalResult(this.messageTemplate, this.name, operation, value, this.getValue(oldvalues), this.getValue(values), approvalType);
            } else {
                return null;
            }
        }

        public Boolean isApplicable(String operation, Object value, Map<String, String> values, Map<String, String> oldValues) {
            if (exists(values)) {

                if (operation.equalsIgnoreCase('changed')) {
                    return this.getValue(values) != this.getValue(oldValues);
                } else if (operation == 'in' || operation == 'not in') {
                    return (operation == 'in' && CS_utl_Comparison.contains(new Set<String>((List<String>) value), this.getValue(values))) ||
                            (operation == 'not in' && !CS_utl_Comparison.contains(new Set<String>((List<String>) value), this.getValue(values)));
                }
                //condition needed because string comparison doesn't return 'not equals'
                else if (operation == 'not equals') {
                    return CS_utl_Comparison.compare(CS_ApprovalService.getValue(this.dataType, this.getValue(values)), value) !=
                            CS_ApprovalService.ApprovalComparison.get('equals');
                } else {
                    return CS_utl_Comparison.compare(CS_ApprovalService.getValue(this.dataType, this.getValue(values)), value) ==
                            CS_ApprovalService.ApprovalComparison.get(operation);
                }
            }

            return false;
        }

        public Boolean exists(Map<String, String> values) {
            // used for customer pg rule
            if(this.type == 'attribute' && name.contains('.')) return values.containsKey(this.name.substringBefore('.'));
            if(this.type == 'attribute') return values.containsKey(this.name);
            else if(this.type == 'field') return true;
            else throw new ApprovalException('Unsupported Approval Property: ' + this.name + ' : ' + this.type + ' : ' + this.dataType);
        }

        public String getValue(Map<String, String> values) {
            if (values == null) {
                return '';
            } else {
                // used for customer pg rule to get Geography keyvalues from attribute Current Targetings
                if (this.type == 'attribute' && this.name.contains('.')) {
                    if (values.get(this.name.substringBefore('.')) != null) {
                        try {
                            return (((Map<String, Object>) JSON.deserializeUntyped(values.get(this.name.substringBefore('.')))).get(this.name.substringAfter('.'))).toString();
                        } catch (exception e) {
                            system.debug('Unable to parse Geography value from attribute Current Targetings');
                            return '';
                        }
                    }
                }
                return (String) values.get(this.name);
            }
        }
    }

    public class ApprovalResult {
        public String message { get; set; }
        public String propertyName { get; set; }
        public String oldValue { get; set; }
        public String newValue { get; set; }
        public String approvalType { get; set; }


        public ApprovalResult() {
        }

        public ApprovalResult(String messageTemplate, String name, String operation, String expectedValue, String oldValue, String value, String approvalType) {
            this.propertyName = name;
            this.oldValue = oldValue;
            this.newValue = value;
            this.approvalType = approvalType;

            if (expectedValue.contains('{') && expectedValue.contains('}')) {
                expectedValue = expectedValue.remove('{').remove('}');
            }
            this.message = String.format(messageTemplate, new List<String>{
                    name, operation, expectedValue, value
            });
        }
    }

    public class ApprovalSnapshot {
        public Id ProductConfigurationId { public get; public set; }
        public Id ProductBasketId { public get; public set; }
        public Map<String, String> AttributeMap { public get; public set; }
    }

    public class ApprovalResultSnapshot {
        public Id ProductConfigurationId { public get; public set; }
        public Id ProductBasketId { public get; public set; }
        public List<ApprovalResult> ApprovalResultList { public get; public set; }
    }

    public class ApprovalException extends Exception {
    }

    public class ApprovalQueueableWorker extends CS_QueueableWorker {
        public ApprovalQueueableWorker(Object params) {
            super('ApprovalQueueableWorker', params);
        }

        public override void doWork() {
            Map<String, Object> paramsType = (Map<String, Object>) this.params;
            Id salesOrderId = (Id) paramsType.get('salesOrderId');

            CS_ApprovalService service = new CS_ApprovalService();
            csmso__Sales_Order__c salesOrder = service.checkApprovals((new csmso__Sales_Order__c(Id = salesOrderId)));
            update salesOrder;
        }
    }

    public static List<WorkItemWrapper> getSortedWorkItems(List<ProcessInstanceWorkitem> workItems) {
        Map<String, Approval_Type__mdt> approvalTypesByQueue = new Map<String, Approval_Type__mdt>();
        Map<String, Approval_Type__mdt> approvalTypesByApproval = new Map<String, Approval_Type__mdt>();
        for (Approval_Type__mdt at : approvalTypes.values()) {
            approvalTypesByQueue.put(at.Approval_Group__c, at);
            approvalTypesByApproval.put(at.Approval_Process__c, at);
        }

        List<WorkItemWrapper> workItemWrappers = new List<WorkItemWrapper>();
        for (ProcessInstanceWorkitem wi : workItems) {
            Approval_Type__mdt approvalType = new Approval_Type__mdt();

            if ( wi.Actor.Type == 'Queue') {
                approvalType = approvalTypesByQueue.get(wi.Actor.Name);
            } else {
                approvalType = approvalTypesByApproval.get(wi.ProcessInstance.ProcessDefinition.DeveloperName);
            }

            workItemWrappers.add(new WorkItemWrapper(wi, approvalType));
        }

        workItemWrappers.sort();

        return workItemWrappers;
    }

    public class WorkItemWrapper implements Comparable {
        public ProcessInstanceWorkitem wi { get; set; }
        public Approval_Type__mdt approvalType { get; set; }

        public WorkItemWrapper(ProcessInstanceWorkitem wi, Approval_Type__mdt approvalType) {
            this.wi = wi;
            this.approvalType = approvalType;
        }

        public Integer compareTo(Object compareTo) {
            WorkItemWrapper compareToWrapper = (WorkItemWrapper) compareTo;

            return this.approvalType.Sequence__c > compareToWrapper.approvalType.Sequence__c ? 1 : -1;
        }

        public Boolean isApprover(String profileName, Map<Id, GroupMember> groupMembership) {
            Boolean hasCustomPermission = FeatureManagement.checkPermission('System_Admin_Compliance_Access');
            return (groupMembership.containsKey(this.wi.ActorId) || hasCustomPermission || profileName == 'S: Systems Administrator');
        }
    }
}