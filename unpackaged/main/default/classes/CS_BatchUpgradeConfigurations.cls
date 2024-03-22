/**
 * @name CS_BatchUpgradeConfigurations
 * @description Class that handles upgrading configurations
 * @revision
 *
 */
public class CS_BatchUpgradeConfigurations extends CS_BatchWorker {
	/**
	 * Class constructor with old Product Definition Id
	 * @return CS_BatchUpgradeConfigurations
	 */
	public CS_BatchUpgradeConfigurations(Id oldProductDefinitionId, Integer batchSize) {
		super('CS_BatchUpgradeConfigurations', batchSize);
		this.queryString = getQueryStringForPDID(oldProductDefinitionId);
	}

	/**
	 * Class constructor with List of Sales Orders
	 * @return CS_BatchUpgradeConfigurations
	 */
	public CS_BatchUpgradeConfigurations(List<Id> salesOrderListIds, Integer batchSize) {
		super('CS_BatchUpgradeConfigurations', batchSize);
		this.queryString = getQueryStringForSalesOrderList(salesOrderListIds);
	}

	/**
	 * Method that handles processing of Orders
	 * @param  sObjects List<SObject>
	 */
	public override void doWork(List<SObject> sObjects) {
		Map<Id, SObject> objToUpdate = new Map<Id, SObject>();

		List<Id> configIds = new List<Id>();
		for (SObject obj : sObjects) {
			configIds.add((Id) obj.get('Id'));

			objToUpdate.put((Id) obj.get('Id'), new cscfga__Product_Configuration__c(Id = (Id) obj.get('Id'),
					cscfga__Configuration_Status__c = (String) obj.get('cscfga__Configuration_Status__c')));
		}

		if (!Test.isRunningTest()) {
			cfgug1.ProductConfigurationUpgrader.upgradeConfigurations(configIds);
		}

		List<cscfga__Attribute__c> attributes = [
				SELECT Id, cscfga__Value__c, cscfga__Product_Configuration__c, cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c
				FROM cscfga__Attribute__c
				WHERE cscfga__Product_Configuration__c IN :configIds
				AND cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c != NULL
		];

		// Map pc to attr
		Map<Id, List<cscfga__Attribute__c>> pcToAttributes = new Map<Id, List<cscfga__Attribute__c>>();
		for (cscfga__Attribute__c attribute : attributes) {
			if (pcToAttributes.get(attribute.cscfga__Product_Configuration__c) == null) {
				pcToAttributes.put(attribute.cscfga__Product_Configuration__c, new List<cscfga__Attribute__c>());
			}
			pcToAttributes.get(attribute.cscfga__Product_Configuration__c).add(attribute);
		}

		// Go through all configs and update values
		//List<SObject> configsToUpdate = new List<SObject>();
		Map<String, Schema.SObjectField> fieldMap = cscfga__Product_Configuration__c.getSObjectType().getDescribe().fields.getMap();
		for (Id objId : objToUpdate.keySet()) {
			cscfga__Product_Configuration__c pc = (cscfga__Product_Configuration__c) objToUpdate.get(objId);

			if (pcToAttributes.get(pc.Id) != null) {
				for (cscfga__Attribute__c attribute : pcToAttributes.get(pc.Id)) {
					if (String.isNotBlank(attribute.cscfga__Value__c)) {
						Schema.DescribeFieldResult dfr = fieldMap.get(attribute.cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c).getDescribe();

						if ((dfr.getSoapType() == Schema.SoapType.STRING) || (dfr.getSoapType() == Schema.SoapType.ID)) {
							pc.put(attribute.cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c, attribute.cscfga__Value__c);
						} else if (dfr.getSoapType() == Schema.SoapType.DATETIME) {
							pc.put(attribute.cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c, Datetime.parse(attribute.cscfga__Value__c));
						} else if (dfr.getSoapType() == Schema.SoapType.DATE) {
							List<String> dateSplit = attribute.cscfga__Value__c.split('-');
							Date ADate = Date.newInstance(Integer.valueOf(dateSplit[0]), Integer.valueOf(dateSplit[1]), Integer.valueOf(dateSplit[2]));
							pc.put(attribute.cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c, ADate);
						} else if (dfr.getSoapType() == Schema.SoapType.DOUBLE) {
							pc.put(attribute.cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c, Double.valueOf(attribute.cscfga__Value__c));
						} else if (dfr.getSoapType() == Schema.SoapType.INTEGER) {
							pc.put(attribute.cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c, Integer.valueOf(attribute.cscfga__Value__c));
						} else if (dfr.getSoapType() == Schema.SoapType.BOOLEAN) {
							if (attribute.cscfga__Value__c == 'Yes' || attribute.cscfga__Value__c == 'YES' || attribute.cscfga__Value__c == 'yes' || attribute.cscfga__Value__c == 'True') {
								pc.put(attribute.cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c, true);
							} else {
								pc.put(attribute.cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c, false);
							}
						}
					} else {
						pc.put(attribute.cscfga__Attribute_Definition__r.cscfga__configuration_output_mapping__c, null);
					}
				}
				objToUpdate.put(pc.Id, pc);
			}
		}

		if (!objToUpdate.values().isEmpty()) {
			update objToUpdate.values();
		}
	}

	/**
	 * Method that creates the query string for batch for old Product Definition Id
	 * @return 	String
	 */
	private String getQueryStringForPDID(Id oldProductDefinitionId) {
		return 'SELECT Id, cscfga__Configuration_Status__c ' +
				'FROM cscfga__Product_Configuration__c ' +
				'WHERE cscfga__Product_Definition__c = \'' + oldProductDefinitionId + '\'' +
				'ORDER BY CreatedDate DESC';
	}

	/**
	 * Method that creates the query string for batch for old Product Definition Id
	 * @return 	String
	 */
	private String getQueryStringForSalesOrderList(List<Id> salesOrderListIds) {
		return 'SELECT Id, cscfga__Configuration_Status__c ' +
				'FROM cscfga__Product_Configuration__c ' +
				'WHERE Sales_Order__c IN (\'' + CS_utl_Array.join(salesOrderListIds, '\',\'') + '\')' +
				'ORDER BY CreatedDate DESC';
	}
}