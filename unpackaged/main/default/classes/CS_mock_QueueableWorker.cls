/**
 * @name CS_mock_QueueableWorker
 * @description Mock class that extends abstract class CS_QueueableWorker
 * @revision
 *
 */
@isTest
public class CS_mock_QueueableWorker extends CS_QueueableWorker {
	/**
	 * Class constructor
	 * @param params 	  Object
	 * @return 			  CS_mock_QueueableWorker
	 */
	public CS_mock_QueueableWorker(Object params) {
		super('CS_mock_QueueableWorker', params);	
	}
	
	/**
	 * Method that implements work that needs to be done
	 */
	public override void doWork() {
		List<Account> accounts = (List<Account>) this.params;
		
		if(accounts.size() > 1) {
			update accounts;
		}
		else {
			throw new CS_mock_QueueableWorkerException('TestError');
		}
	}

	public class CS_mock_QueueableWorkerException extends Exception {}
}