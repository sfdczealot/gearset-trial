/**
 * @name CS_BatchPodcastLineStatusChange
 * @description Class that handles Podcast Lines Status Change when:
  * 								- Start Date is Today then Status goes from Ready to Delivering
  * 								- End Date is Today then Status goes from Delivering to Completed
 * @revision
 *
 */

public class CS_BatchPodcastLineStatusChange extends CS_BatchWorker implements Schedulable {
	/**
	 * Class constructor
	 * @return CS_BatchPodcastLineStatusChange
	 */
	public CS_BatchPodcastLineStatusChange(Integer batchSize) {
		super('CS_BatchPodcastLineStatusChange', batchSize);
		this.queryString = getQueryString();
	}

	/**
	 * Method that handles processing of Orders
	 * @param  sObjects List<SObject>
	 */
	public override void doWork(List<SObject> sObjects) {
		CS_DMLWorker dmlWorker = new CS_DMLWorker(false);

		for (SObject obj : sObjects) {
			String status;
			Datetime startDate = Datetime.valueOf(CS_utl_SObject.getFieldValue(obj, 'csdf__Flight_Beginning__c'));
			Datetime endDate = Datetime.valueOf(CS_utl_SObject.getFieldValue(obj, 'csdf__Flight_End__c'));

			if (startDate <= Datetime.now()) {
				status = CS_const_SalesOrder.FulfilmentItemStatus_Delivering;
			}

			if (endDate <= Datetime.now()) {
				status = CS_const_SalesOrder.FulfilmentItemStatus_Completed;
			}

			dmlWorker.addForUpsert(new List<csdf__Fulfilment_Item__c>{
					new csdf__Fulfilment_Item__c(Id = (Id) obj.get('Id'), csdf__Status__c = status, Last_Action_from_DFP__c = Datetime.now())
			});
		}

		dmlWorker.doUpsert();
	}

	/**
	 * Method that creates the query string for batch
	 * @return 	String
	 */
	private String getQueryString() {
		return 'SELECT Id, csdf__Status__c, Last_Action_from_DFP__c, csdf__Flight_Beginning__c, csdf__Flight_End__c ' +
				'FROM csdf__Fulfilment_Item__c ' +
				'WHERE Served_By__c = \'Megaphone\' ' +
				'AND (csdf__Flight_Beginning__c <= NOW ' +
				'OR csdf__Flight_End__c <= NOW)';
	}

	public static void scheduleIt(Integer batchSize) {
		System.schedule('Update Fulfilments ' + System.currentTimeMillis(),
				'0 0 0/3 ? * * *',
				new CS_BatchPodcastLineStatusChange(batchSize));
	}
}