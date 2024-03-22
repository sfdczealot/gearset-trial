/**
 * @name CS_mock_BatchWorker
 * @description Mock class that extends abstract class CS_BatchWorker
 * @revision
 *
 */
@isTest
public class CS_mock_BatchWorker extends CS_BatchWorker {
	/**
	 * Class constructor
	 * @return CS_mock_BatchWorker
	 */
	public CS_mock_BatchWorker() {
		super('TestProcess');
		this.queryString = 'SELECT Id FROM Account LIMIT 200';
	}
	
	/**
	 * Class constructor
	 * @param batchSize Integer
	 * @return 			CS_mock_BatchWorker
	 */
	public CS_mock_BatchWorker(Integer batchSize) {
		super('TestProcess', batchSize);
		this.queryString = 'SELECT Id FROM Account LIMIT 200';
	}

	/**
	 * Method that implements work that needs to be done
	 * @param  accounts List<SObject>
	 */
	public override void doWork(List<SObject> accounts) {
		if(accounts.size() > 1) {
			update accounts;
		}
		else {
			throw new CS_mock_BatchWorkerException('TestError');
		}
	}

	public class CS_mock_BatchWorkerException extends Exception {}
}