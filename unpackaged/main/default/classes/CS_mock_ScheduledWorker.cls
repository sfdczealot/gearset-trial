/**
 * @name CS_mock_ScheduledWorker
 * @description Mock class that extends abstract class CS_ScheduledWorker
 * @revision
 *
 */
@isTest
public class CS_mock_ScheduledWorker extends CS_ScheduledWorker {
	/**
	 * Class constructor
	 * @param params 	  Object
	 * @return 			  CS_mock_ScheduledWorker
	 */
	public CS_mock_ScheduledWorker() {
		super('CS_mock_ScheduledWorker');	
	}
	
	/**
	 * Method that implements work that needs to be done
	 */
	public override void doWork() {
		List<Account> accounts = [SELECT Id FROM Account LIMIT 200];
		
		if(accounts.size() > 1) {
			update accounts;
		}
		else {
			throw new CS_mock_ScheduledWorkerException('TestError');
		}
	}

	public class CS_mock_ScheduledWorkerException extends Exception {}
}