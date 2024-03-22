/**
 * @name CS_BatchGenerateBookScreenshots
 * @description Class that handles generating Book Screenshots
 * @revision
 *
 */
public class CS_BatchGenerateBookScreenshots extends CS_BatchWorker {
	/**
	 * Class constructor with batchSize
	 * @return CS_BatchGenerateBookScreenshots
	 */
	public CS_BatchGenerateBookScreenshots(Integer batchSize) {
		super('CS_BatchGenerateBookScreenshots', batchSize);
		this.queryString = getQueryStringForBookedSOs();
	}

	/**
	 * Method that handles processing of Sales Orders
	 * @param  sObjects List<SObject>
	 */
	public override void doWork(List<SObject> sObjects) {

		for (SObject obj : sObjects) {
			Id salesOrderId = (Id) obj.get('Id');

			CS_RetractionService.generateScreenshot(salesOrderId, getProductConfigurations(salesOrderId), CS_const_SalesOrder.FILE_NAME_ORDER_SALES_ORDER_SCREENSHOT, CS_const_SalesOrder.FILE_NAME_ATTRIBUTES_AS_JSON_ORDER_SCREENSHOT);
		}
	}

	/**
	 * Method that gets Product Configurations by Sales Order Id
	 * @param 	Id soId
	 */
	private Map<Id, cscfga__Product_Configuration__c> getProductConfigurations(Id soId){
		return new Map<Id, cscfga__Product_Configuration__c>([SELECT Id FROM cscfga__Product_Configuration__c WHERE Sales_Order__c = :soId]);
	}

	/**
	 * Method that creates the query string for batch for Booked Sales Orders
	 * @return 	String
	 */
	private String getQueryStringForBookedSOs() {
		return 'SELECT Id ' +
				'FROM csmso__Sales_Order__c ' +
				'WHERE csmso__Status__c = \'Booked\' ' +
				'ORDER BY CreatedDate DESC';
	}
}