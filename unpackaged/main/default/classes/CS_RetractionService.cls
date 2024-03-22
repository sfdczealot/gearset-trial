/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to create Sales Order Screenshot as JSON attachment. When canceling retraction that JSON 
* is loaded and objects are rebuilt as they were before.
* Stored objects are: Sales Order, Product Basket, Product Configuration, Attribute, Attribute Field, 
* Fulfilment, Fulfilment Item, Ad Slot Targeting, Site Targeting, Browser Targeting, 
* Creative Upload Log, Targetable Targeting, Operating System Targeting, 
* Operating System Version Targeting and Geo Targeting.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Aldo Topic   <aldo.topic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v2.0            Aldo Topic   <aldo.topic@cloudsensesolutions.com>
* 2019-10-23      Removed Fulfilment Item and all objects below it. 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public without sharing class CS_RetractionService extends CS_DMLWorker {
	static String PROCESS_TYPE_RETRACTION = 'Retraction';
	static String PROCESS_TYPE_CANCEL = 'Cancel';

	static String RETRACTION_TYPE = '';
	static String RETRACTION_TYPE_PROPOSAL = 'Proposal';

	Id salesOrderId;

	static List<ObjectType> objectTypes = new List<ObjectType> {
			new ObjectType(Schema.csmso__Sales_Order__c.getSObjectType(), null, '', new Query('Id', 'salesOrderId', null, new Set<Schema.SObjectField>{Schema.csmso__Sales_Order__c.Last_Button_Clicked__c}, new Set<String>{'Last_Button_Clicked__c'}), 'Retraction', false),
			new ObjectType(Schema.cscfga__Product_Basket__c.getSObjectType(), Schema.csmso__Sales_Order__c.getSObjectType(), 'csmso__Sales_Order__c', new Query('csmso__Sales_Order__c', 'salesOrderId', null, null, new Set<String>{''}), 'Retraction', false),
			new ObjectType(Schema.csdf__Fulfilment__c.getSObjectType(), Schema.csmso__Sales_Order__c.getSObjectType(), 'Sales_Order__c', new Query('Sales_Order__c', 'salesOrderId', null, new Set<Schema.SObjectField>{Schema.csdf__Fulfilment__c.csdf__Ad_Server_Id__c, Schema.csdf__Fulfilment__c.csdf__Status__c, Schema.csdf__Fulfilment__c.csdf__Last_Modified_Date_Time__c}, new Set<String>{'csdf__Ad_Server_Id__c', 'csdf__Status__c', 'csdf__Last_Modified_Date_Time__c'}), 'Retraction', false),

			new ObjectType(Schema.cscfga__Product_Configuration__c.getSObjectType(), null, '', new Query('Id', 'productConfigurationIds', null, new Set<Schema.SObjectField>{Schema.cscfga__Product_Configuration__c.cscfga__Product_Definition__c}, new Set<String>{'cscfga__Product_Definition__c'}), 'Retraction, Cancel', true),
			new ObjectType(Schema.cscfga__Attribute__c.getSObjectType(), Schema.cscfga__Product_Configuration__c.getSObjectType(), 'cscfga__Product_Configuration__c', new Query('cscfga__Product_Configuration__c', 'productConfigurationIds', 'Id, Name, cscfga__Value__c, cscfga__Display_Value__c, cscfga__Product_Configuration__c', new Set<Schema.SObjectField>{Schema.cscfga__Attribute__c.cscfga__Attribute_Definition__c}, new Set<String>{'cscfga__Attribute_Definition__c'}), 'Retraction', false),
			new ObjectType(Schema.cscfga__Attribute_Field__c.getSObjectType(), Schema.cscfga__Product_Configuration__c.getSObjectType(), 'cscfga__Attribute__c', new Query('cscfga__Attribute__r.cscfga__Product_Configuration__c', 'productConfigurationIds', null, null, new Set<String>{''}), 'Retraction', false)
	};

	static List<SObjectType> SObjectTypes_Order {
		get {
			if(SObjectTypes_Order == null) {
				SObjectTypes_Order = new List<SObjectType>();
				for(ObjectType oType : objectTypes) {
					SObjectTypes_Order.add(oType.sObjectType);
				}
			}

			return SObjectTypes_Order;
		}
		set;
	}

	Map<String, Set<Id>> filters {
		get {
			if(filters == null) {
				filters = new Map<String, Set<Id>>();
			}

			return filters;
		}
		set;
	}

	/**
	 * Map of ObjectTypeName to ObjectType
	 */
	@TestVisible
	Map<String, ObjectType> objectTypeNameToObjectType {
		get {
			if(objectTypeNameToObjectType == null) {
				objectTypeNameToObjectType = new Map<String, ObjectType>();
				for(ObjectType objectType : objectTypes) {
					objectTypeNameToObjectType.put(objectType.sObjectType.getDescribe().getName(), objectType);
				}
			}

			return objectTypeNameToObjectType;
		}
		set;
	}

	public CS_RetractionService(Id salesOrderId) {
		super(false, SObjectTypes_Order);
		this.salesOrderId = salesOrderId;
		filters.put('salesOrderId', new Set<Id>{salesOrderId});
	}

	public static void prepareWork(Id salesOrderId, Map<Id, cscfga__Product_Configuration__c> productConfigurations, String oType, String screenshotName, String aajsScreenshotName) {
		CS_QueueableDispatcher dispatcher = new CS_QueueableDispatcher();
		List<Id> configIds = new List<Id>(productConfigurations.keySet());
		Integer totalConfigs = configIds.size();

		for(Integer i = 0; i < Math.ceil((Decimal)totalConfigs / CS_Custom_Settings__c.getInstance().Sync_Retraction_SOLI_Limit__c).intValue(); i++) {
			Set<Id> currentConfigIds = new Set<Id>();
			Integer currentConfigSize = configIds.size();
			for(Integer j = 0; j < CS_Custom_Settings__c.getInstance().Sync_Retraction_SOLI_Limit__c && j < currentConfigSize; j++) {
				currentConfigIds.add(configIds.remove(0));
			}

			dispatcher.addWorker(new CS_RetractionServiceWorker(new Map<String, Object> {
					'type' => oType,
					'salesOrderId' => salesOrderId,
					'productConfigurationIds' => currentConfigIds,
					'existingIds' => new Set<Id>(),
					'screenshotName' => screenshotName,
					'aajsScreenshotName' => aajsScreenshotName
			}));
		}

		dispatcher.dispatch();
	}

	public static Boolean generateScreenshot(Id salesOrderId, Map<Id, cscfga__Product_Configuration__c> productConfigurations, String screenshotName, String aajsScreenshotName) {
		CS_LogWorker log = CS_LogWorker.getInstance();

		System.Savepoint sPoint = Database.setSavepoint();
		try {
			prepareWork(salesOrderId, productConfigurations, 'generate', screenshotName, aajsScreenshotName);
		}
		catch(Exception e) {
			Database.rollback(sPoint);

			List<csmso__Sales_Order__c> salesOrdersToUpdate = new List<csmso__Sales_Order__c>();
			salesOrdersToUpdate.add(new csmso__Sales_Order__c(
					Id = salesOrderId,
					csmso__Process_Message__c = 'An error occured while preparing retraction. Please contact your admin',
					csmso__Process_Message_Type__c = CS_const_SalesOrder.ProcessMessageSeverity_Warning,
					Loading_Screen__c = 'Off'
			));
			log.addMessage(e, salesOrderId);

			log.save('CS_RetractionService', 'Synchronous', null, false);
			update salesOrdersToUpdate;

			return false;
		}

		return true;
	}

	public static Boolean cancelRetraction(Id salesOrderId, String screenshotName, String aajsScreenshotName){
		CS_LogWorker log = CS_LogWorker.getInstance();

		System.Savepoint sPoint = Database.setSavepoint();
		try {
			Map<Id, cscfga__Product_Configuration__c> productConfigurations = new Map<Id, cscfga__Product_Configuration__c>([SELECT Id FROM cscfga__Product_Configuration__c WHERE Sales_Order__c = :salesOrderId]);
			Integer totalConfigs = productConfigurations.size();

			prepareWork(salesOrderId, productConfigurations, 'cancel', screenshotName, aajsScreenshotName);
		}
		catch(Exception e) {
			Database.rollback(sPoint);

			csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c(
					Id = salesOrderId,
					csmso__Process_Message__c = 'An error occured while processing retraction. Please contact your admin',
					csmso__Process_Message_Type__c = CS_const_SalesOrder.ProcessMessageSeverity_Warning,
					Loading_Screen__c = 'Off',
					csmso__Status__c = CS_const_SalesOrder.Status_Retracted
			);

			log.addMessage(e, salesOrderId);

			log.save('CS_RetractionService', 'Synchronous', null, false);
			update salesOrder;

			return false;
		}

		return true;
	}

	public void generateScreenshot(Set<Id> productConfigurationIds, String screenshotName, String aajsScreenshotName) {
		filters.put('productConfigurationIds', productConfigurationIds);

		Map<SObjectType, List<SObject>> objectTypeToListOfObjectsMap = getSObjects(PROCESS_TYPE_RETRACTION);

		Map<String, List<SObjectInstance>> finalSObjectInstance = getSObjectInstance(objectTypeToListOfObjectsMap);

		Id basketId = [SELECT Id FROM cscfga__Product_Basket__c WHERE csmso__Sales_Order__c = :salesOrderId LIMIT 1].Id;

		List<Attachment> attachmentList = new List<Attachment>();
		for(ObjectType oType : objectTypes) {
			if(finalSObjectInstance.containsKey(oType.sObjectType.getDescribe().getName())) {
				for(SObjectInstance instance : finalSObjectInstance.get(oType.sObjectType.getDescribe().getName())) {
					Attachment attachment = CS_Attachment.generateAttachment(JSON.serialize(instance, false),
							oType.sObjectType.getDescribe().getName() == 'csmso__Sales_Order__c' ? basketId : instance.SobjectObj.Id, screenshotName);
					attachmentList.add(attachment);
				}
			}
		}

		attachmentList.addAll(generateAttributeAsJSONScreenshot(productConfigurationIds, aajsScreenshotName));

		CS_Attachment.createAttachments(attachmentList, true);
	}

	public List<Attachment> generateAttributeAsJSONScreenshot(Set<Id> productConfigurationIds, String aajsScreenshotName) {
		List<Attachment> attachmentListToGenerate = new List<Attachment>();

		Set<Id> productConfigurationIdsNew = (new Map<Id, cscfga__Product_Configuration__c>([
				SELECT Id
				FROM cscfga__Product_Configuration__c
				WHERE Id IN :productConfigurationIds
				AND Fulfilment_Item_Status__c != :CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased
		])).keySet();

		List<Attachment> attachmentList = [SELECT Id, Body, ParentId FROM Attachment WHERE Name = :CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON AND ParentId IN :productConfigurationIdsNew];

		for(Attachment attachment : attachmentList) {
			attachmentListToGenerate.add(new Attachment(
					IsPrivate = false,
					ParentId = attachment.ParentId,
					Name = aajsScreenshotName,
					Body = attachment.Body
			)
			);
		}

		return attachmentListToGenerate;
	}

	public Set<Id> cancelRetraction(Set<Id> productConfigurationIds, String screenshotName, String aajsScreenshotName){
		CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = true;

		if(screenshotName.equals(CS_const_SalesOrder.FILE_NAME_PROPOSAL_SALES_ORDER_SCREENSHOT)) {
			RETRACTION_TYPE = RETRACTION_TYPE_PROPOSAL;
		}

		filters.put('productConfigurationIds', productConfigurationIds);

		recreateAttributeAsJSONScreenshots(aajsScreenshotName);

		List<Attachment> attachmentList = getScreenshots(screenshotName);
		Set<Id> existingIds = recreateObjectsFromAttachment(attachmentList);

		CS_utl_User.isTriggerDeactivationEnabledForAllTriggers = false;

		return existingIds;
	}

	public Map<SObjectType, List<SObject>> getSObjects(String processType) {
		Map<SObjectType, List<SObject>> objectTypeToListOfObjectsMap = new Map<SObjectType, List<SObject>>();

		for(ObjectType objectType : objectTypes) {
			if(objectType.processType.contains(processType)) {
				String queryString = CS_utl_Soql.buildQuery(
						objectType.sObjectType,
						new Map<String, Set<Id>>{objectType.query.filter => filters.get(objectType.query.filterType)},
						null,
						objectType.query.ignoreFields,
						objectType.query.queryFields
				);
				List<SObject> returnedObjects = Database.Query(queryString);
				objectTypeToListOfObjectsMap.put(objectType.sObjectType, returnedObjects);
			}
		}

		return objectTypeToListOfObjectsMap;
	}

	public Map<String, List<SObjectInstance>> getSObjectInstance(Map<SObjectType, List<SObject>> objectTypeToListOfObjectsMap) {
		// [key - parent ID, value - list of SObjectInstance]
		Map<Id, List<SObjectInstance>> parentIdToListOfChildSObjectInstanceMap = new Map<Id, List<SObjectInstance>>();
		Map<String, List<SObjectInstance>> sObjectInstances = new Map<String, List<SObjectInstance>>();

		for(Integer i = objectTypes.size()-1; i >= 0; i--) {
			ObjectType objectType = objectTypes[i];
			List<SObject> sObjectList = objectTypeToListOfObjectsMap.get(objectType.sObjectType);

			for(SObject sObjectTemp : sObjectList) {
				List<SObjectInstance> listofChild = new List<SObjectInstance>();
				if(parentIdToListOfChildSObjectInstanceMap.containsKey(sObjectTemp.Id)) {
					listofChild = parentIdToListOfChildSObjectInstanceMap.get(sObjectTemp.Id);
				}

				Map<String, List<SObjectInstance>> objectToSObjectInstanceChild = new Map<String, List<SObjectInstance>>();
				for(SObjectInstance childSObjectInstance : listofChild) {
					if(!objectToSObjectInstanceChild.containsKey(childSObjectInstance.type)) {
						objectToSObjectInstanceChild.put(childSObjectInstance.type, new List<SObjectInstance>());
					}
					objectToSObjectInstanceChild.get(childSObjectInstance.type).add(childSObjectInstance);
				}

				SObjectInstance finalSObjectInstance = new SObjectInstance(objectType.sObjectType.getDescribe().getName(), sObjectTemp, objectToSObjectInstanceChild);

				if(!String.isBlank(objectType.parentFieldName)) {
					if(!parentIdToListOfChildSObjectInstanceMap.containsKey((Id) sObjectTemp.get(objectType.parentFieldName))) {
						parentIdToListOfChildSObjectInstanceMap.put((Id) sObjectTemp.get(objectType.parentFieldName), new List<SObjectInstance>());
					}
					parentIdToListOfChildSObjectInstanceMap.get((Id) sObjectTemp.get(objectType.parentFieldName)).add(finalSObjectInstance);
				}
				else {
					if(!sObjectInstances.containsKey(finalSObjectInstance.type)) {
						sObjectInstances.put(finalSObjectInstance.type, new List<SObjectInstance>());
					}
					sObjectInstances.get(finalSObjectInstance.type).add(finalSObjectInstance);
				}
			}
		}

		return sObjectInstances;
	}

	public Set<Id> recreateObjectsFromAttachment(List<Attachment> attachmentList){
		Map<String, List<SObjectInstance>> sObjectTypeToSObjectInstanceMap = new Map<String, List<SObjectInstance>>();

		for(Attachment attachment : attachmentList) {
			SObjectInstance instance = (SObjectInstance)JSON.deserialize(attachment.body.toString(), SObjectInstance.class);
			if(!sObjectTypeToSObjectInstanceMap.containsKey(instance.type)) {
				sObjectTypeToSObjectInstanceMap.put(instance.type, new List<SObjectInstance>());
			}
			sObjectTypeToSObjectInstanceMap.get(instance.type).add(instance);
		}

		Map<Id, SObject> idToSObjectCurrentStateMap = getIdToSObject();
		getSObjectListToUpdate(sObjectTypeToSObjectInstanceMap, idToSObjectCurrentStateMap, null);

		doUpsert();
		return getIdsFromSObjectInstance(sObjectTypeToSObjectInstanceMap);
	}

	public void removeObjects(Set<Id> existingIds) {
		Id basketId = [SELECT Id FROM cscfga__Product_Basket__c WHERE csmso__Sales_Order__c = :salesOrderId LIMIT 1].Id;

		Map<Id, cscfga__Product_Configuration__c> productConfigurations = new Map<Id, cscfga__Product_Configuration__c>(
		[SELECT Id From cscfga__Product_Configuration__c WHERE cscfga__Product_Basket__c = :basketId]);
		filters.put('productConfigurationIds', productConfigurations.keySet());

		getSObjectListToDelete(existingIds, getIdToSObject());
		doDelete();
	}

	public List<Attachment> getScreenshots(String screenshotName) {
		Set<Id> idsForAttachment = new Set<Id>();
		idsForAttachment.addAll(filters.get('productConfigurationIds'));

		Id basketId = [SELECT Id FROM cscfga__Product_Basket__c WHERE csmso__Sales_Order__c = :salesOrderId LIMIT 1].Id;
		idsForAttachment.add(basketId);

		List<Attachment> attachmentList = [SELECT Id, Name, Body FROM Attachment WHERE (Name LIKE :screenshotName OR Name LIKE :CS_const_SalesOrder.FILE_NAME_SALES_ORDER_SCREENSHOT) AND ParentId IN :idsForAttachment];

		Boolean hasNewAttachment = false;
		List<Attachment> attachmentToReturn = new List<Attachment>();
		List<Attachment> oldAttachments = new List<Attachment>();

		for(Attachment attachment : attachmentList) {
			if(attachment.Name == screenshotName) {
				attachmentToReturn.add(attachment);
				hasNewAttachment = true;
			}
			else {
				oldAttachments.add(attachment);
			}
		}

		if(!hasNewAttachment) {
			attachmentToReturn = oldAttachments;
		}

		return attachmentToReturn;
	}

	public void recreateAttributeAsJSONScreenshots(String aajsScreenshotName) {
		List<Attachment> attachmentListToGenerate = new List<Attachment>();

		Set<Id> productConfigurationIds = (new Map<Id, cscfga__Product_Configuration__c>([
				SELECT Id
				FROM cscfga__Product_Configuration__c
				WHERE Id IN :filters.get('productConfigurationIds')
				AND Fulfilment_Item_Status__c != :CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased
		])).keySet();

		List<Attachment> attachmentList = [SELECT Id, Name, Body, ParentId FROM Attachment WHERE (Name LIKE :aajsScreenshotName OR Name LIKE :CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_SCREENSHOT) AND ParentId IN :productConfigurationIds];

		Boolean hasNewAttachment = false;
		List<Attachment> attachmentToRecreate = new List<Attachment>();
		List<Attachment> oldAttachments = new List<Attachment>();

		for(Attachment attachment : attachmentList) {
			if(attachment.Name == aajsScreenshotName) {
				attachmentToRecreate.add(attachment);
				hasNewAttachment = true;
			}
			else {
				oldAttachments.add(attachment);
			}
		}

		if(!hasNewAttachment) {
			attachmentToRecreate = oldAttachments;
		}

		for(Attachment attachment : attachmentToRecreate) {
			attachmentListToGenerate.add(new Attachment(
					IsPrivate = false,
					ParentId = attachment.ParentId,
					Name = CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON,
					Body = attachment.Body
			)
			);
		}

		CS_Attachment.createAttachments(attachmentListToGenerate, true);
	}

	public Map<Id, SObject> getIdToSObject() {
		Map<Id, SObject> idToSObjectMap = new Map<Id, SObject>();
		Map<SObjectType, List<SObject>> objectTypeToListOfObjectsMap = getSObjects(PROCESS_TYPE_CANCEL);

		for(SObjectType sObjectType : objectTypeToListOfObjectsMap.keySet()) {
			idToSObjectMap.putAll(new Map<Id, SObject>(objectTypeToListOfObjectsMap.get(sObjectType)));
		}

		return idToSObjectMap;
	}

	public Set<Id> getIdsFromSObjectInstance(Map<String, List<SObjectInstance>> sObjectTypeToSObjectInstanceMap) {
		Set<Id> sObjectIds = new Set<Id>();

		for(String objectType : sObjectTypeToSObjectInstanceMap.keyset()) {
			for(SObjectInstance sObjectInstance : sObjectTypeToSObjectInstanceMap.get(objectType)) {
				sObjectIds.add((Id) sObjectInstance.sObjectObj.get('Id'));
				sObjectIds.addAll(getIdsFromSObjectInstance(sObjectInstance.objects));
			}
		}

		return sObjectIds;
	}

	public List<SObject> getSObjectListToDelete(Set<Id> existingIds, Map<Id, SObject> idToSObjectCurrentStateMap) {
		List<SObject> sObjectListToDelete = new List<SObject>();
		for(Id idFromCurrentSObject : idToSObjectCurrentStateMap.keyset()) {
			if(!existingIds.contains(idFromCurrentSObject)) {
				sObjectListToDelete.add(idToSObjectCurrentStateMap.get(idFromCurrentSObject));
				SObject sObjectTemp = idToSObjectCurrentStateMap.get(idFromCurrentSObject);
				addForDelete(new List<SObject>{sObjectTemp});
			}
		}

		return sObjectListToDelete;
	}

	public List<SObject> getSObjectListToUpdate(Map<String, List<SObjectInstance>> sObjectTypeToSObjectInstanceMap, Map<Id, SObject> idToSObjectCurrentStateMap, SObject parent) {
		List<SObject> sObjectListToUpdate = new List<SObject>();
		for(String sObjectType : sObjectTypeToSObjectInstanceMap.keySet()) {
			List<Schema.SObjectField> objFields = objectTypeNameToObjectType.get(sObjectType).sObjectType.getDescribe().fields.getMap().values();
			for(SObjectInstance sObjectInstance : sObjectTypeToSObjectInstanceMap.get(sObjectType)) {
				Id sObjectInstanceId = (Id) sObjectInstance.sObjectObj.get('Id');
				if(objectTypeNameToObjectType.get(sObjectType).onModify) {
					if(idToSObjectCurrentStateMap.containsKey(sObjectInstanceId)) {
						SObject sObjectCurrentState = idToSObjectCurrentStateMap.get(sObjectInstanceId);
						Map<String, Object> populatedFields = sObjectCurrentState.getPopulatedFieldsAsMap();
						if(populatedFields.containsKey('Last_Changed_Date__c')) {
							if((Datetime) sObjectInstance.sObjectObj.get('Last_Changed_Date__c') == (Datetime) populatedFields.get('Last_Changed_Date__c')) {
								continue;
							}
						}
						if(populatedFields.containsKey('Fulfilment_Item_Status__c')) {
							if(String.valueOf(populatedFields.get('Fulfilment_Item_Status__c')) == CS_const_SalesOrder.FulfilmentItemStatus_Paused
									|| String.valueOf(populatedFields.get('Fulfilment_Item_Status__c')) == CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased) {
								sObjectInstance.sObjectObj.put('Fulfilment_Item_Status__c', populatedFields.get('Fulfilment_Item_Status__c'));
								sObjectInstance.sObjectObj.put('cscfga__Configuration_Status__c', populatedFields.get('cscfga__Configuration_Status__c'));
								sObjectInstance.sObjectObj.put('Aggregated_Status__c', populatedFields.get('Aggregated_Status__c'));
								if(sObjectInstance.objects.containsKey('cscfga__Attribute__c')) {
									for(SObjectInstance instanceAttribute : sObjectInstance.objects.get('cscfga__Attribute__c')) {
										if(instanceAttribute.sObjectObj.get('Name') != null && instanceAttribute.sObjectObj.get('Name') == 'Fulfilment Item Status') {
											instanceAttribute.sObjectObj.put('cscfga__Value__c', populatedFields.get('Fulfilment_Item_Status__c'));
											instanceAttribute.sObjectObj.put('cscfga__Display_Value__c', populatedFields.get('Fulfilment_Item_Status__c'));
										}
									}
								}
							}
						}
					}
					else {
						sObjectInstance.sObjectObj.put('Id', null);
					}
				}

				if(sObjectType == 'csmso__Sales_Order__c'
						&& RETRACTION_TYPE.equals(RETRACTION_TYPE_PROPOSAL)){
					sObjectInstance.sObjectObj.put('csmso__Status__c', CS_const_SalesOrder.Status_Rejected);
				}

				if(sObjectType == 'cscfga__Attribute__c'){
					for(String field : (objectTypeNameToObjectType.get(sObjectType).query.queryFields).split(',')) {
						if(sObjectInstance.sObjectObj.get(field.trim()) == null){
							sObjectInstance.sObjectObj.put(field.trim(), null);
						}
					}
				}
				else {
					for(Schema.SObjectField field : objFields) {
						if(sObjectInstance.sObjectObj.get(field.getDescribe().getName()) == null
								&& !objectTypeNameToObjectType.get(sObjectType).query.ignoreFieldNames.contains(field.getDescribe().getName())
								&& field.getDescribe().isUpdateable()){
							sObjectInstance.sObjectObj.put(field.getDescribe().getName(), field.getDescribe().getType() == Schema.DisplayType.Boolean ? false : null);
						}
					}
				}

				addForUpsert(new List<SObject>{sObjectInstance.sObjectObj});
				sObjectListToUpdate.addAll(getSObjectListToUpdate(sObjectInstance.objects, idToSObjectCurrentStateMap, sObjectInstance.sObjectObj));
			}
		}

		return sObjectListToUpdate;
	}

	public class ObjectType {
		public SObjectType sObjectType {get; set;}
		public SObjectType parent {get; set;}
		public String parentFieldName {get; set;}
		public Query query {get; set;}
		public String processType {get; set;}
		public Boolean onModify {get; set;}

		public ObjectType(SObjectType sObjectType, SObjectType parent, String parentFieldName, Query query, String processType, Boolean onModify) {
			this.sObjectType = sObjectType;
			this.parent = parent;
			this.parentFieldName = parentFieldName;
			this.query = query;
			this.processType = processType;
			this.onModify = onModify;
		}
	}

	public class Query {
		public String filter {get; set;}
		public String filterType {get; set;}
		public String queryFields {get; set;}
		public Set<Schema.SObjectField> ignoreFields {get; set;}
		public Set<String> ignoreFieldNames {get; set;}

		public Query(String filter, String filterType, String queryFields, Set<Schema.SObjectField> ignoreFields, Set<String> ignoreFieldNames) {
			this.filter = filter;
			this.filterType = filterType;
			this.queryFields = queryFields;
			this.ignoreFields = ignoreFields;
			this.ignoreFieldNames = ignoreFieldNames;
		}
	}

	public class SObjectInstance {
		public String type {get; set;}
		public SObject sObjectObj {get; set;}
		public Map<String, List<SObjectInstance>> objects {get; set;}

		public SObjectInstance() {
		}

		public SObjectInstance(String type, SObject sObjectObj, Map<String, List<SObjectInstance>> objects) {
			this.type = type;
			this.sObjectObj = sObjectObj;
			this.objects = objects;
		}
	}

	public class CS_RetractionServiceWorker extends CS_QueueableWorker {
		public CS_RetractionServiceWorker(Object params) {
			super('CS_RetractionServiceWorker', params);
		}

		public override void doWork() {
			System.Savepoint sPoint = Database.setSavepoint();
			Map<String, Object> paramsType = (Map<String, Object>) this.params;
			Id salesOrderId = (Id) paramsType.get('salesOrderId');

			try {
				if(String.valueOf(paramsType.get('type')) == 'generate') {
					CS_RetractionService service = new CS_RetractionService(salesOrderId);
					service.generateScreenshot((Set<Id>) paramsType.get('productConfigurationIds'), (String) paramsType.get('screenshotName'), (String) paramsType.get('aajsScreenshotName'));

					if(this.nextWorker == null) {
						List<CSPOFA__Orchestration_Step__c> steps = [SELECT Id, CSPOFA__Status__c, CSPOFA__Message__c FROM CSPOFA__Orchestration_Step__c
						WHERE CSPOFA__External_Id__c = :salesOrderId AND CSPOFA__Status__c = 'Waiting For Feedback'];
						for(CSPOFA__Orchestration_Step__c step : steps) {
							step.CSPOFA__Status__c = 'Complete';
							step.CSPOFA__Message__c = 'Snapshot created.';
							step.CSPOFA__Completed_Date__c = Date.today();
						}

						update steps;
					}
				}
				else if(String.valueOf(paramsType.get('type')) == 'cancel') {
					CS_RetractionService service = new CS_RetractionService(salesOrderId);
					Set<Id> existingIds = (Set<Id>) paramsType.get('existingIds');
					existingIds.addAll(service.cancelRetraction((Set<Id>) paramsType.get('productConfigurationIds'), (String) paramsType.get('screenshotName'), (String) paramsType.get('aajsScreenshotName')));
					if(this.nextWorker != null) {
						Map<String, Object> nextWorkerParamsType = (Map<String, Object>) this.nextWorker.params;
						nextWorkerParamsType.put('existingIds', existingIds);
					}
					else {
						service.removeObjects(existingIds);

						csmso__Sales_Order__c salesOrder = [SELECT Id, Callout_Type__c FROM csmso__Sales_Order__c WHERE Id = :salesOrderId];
						salesOrder.Loading_Screen__c = 'Off';
						salesOrder.Reason_for_Retraction__c = '';

						update salesOrder;
					}
				}
			}
			catch(Exception e) {
				this.nextWorker = null;

				Database.rollback(sPoint);

				csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c(
						Id = salesOrderId,
						csmso__Process_Message__c = 'An error occured while processing retraction. Please contact your admin',
						csmso__Process_Message_Type__c = CS_const_SalesOrder.ProcessMessageSeverity_Warning,
						Loading_Screen__c = 'Off'
				);
				if(String.valueOf(paramsType.get('type')) == 'cancel') {
					salesOrder.csmso__Status__c = CS_const_SalesOrder.Status_Retracted;
				}
				log.addMessage(e, salesOrderId);

				log.save('CS_RetractionService', CS_const_ApexJob.JobType_Queueable, getJobId(), false);
				update salesOrder;
			}
		}
	}
}