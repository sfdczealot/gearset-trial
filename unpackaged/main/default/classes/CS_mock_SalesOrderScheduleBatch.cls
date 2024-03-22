/**
 * @name CS_mock_SalesOrderScheduleBatch
 * @description Mock class that extends abstract class CS_SalesOrderScheduleBatch
 * @revision
 *
 */
@isTest
public class CS_mock_SalesOrderScheduleBatch extends CS_SalesOrderScheduleBatch {
	/**
	 * Class constructor
	 * @return CS_mock_SalesOrderScheduleBatch
	 */
	public CS_mock_SalesOrderScheduleBatch() {
		super('CS_mock_SalesOrderScheduleBatch');
	}

	/**
	 * Method that implements work that needs to be done
	 * @param  obj List<SObject>
	 */
	public override void doWork(List<SObject> obj) {
		
	}
}