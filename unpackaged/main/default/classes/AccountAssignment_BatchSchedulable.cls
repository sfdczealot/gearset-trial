/**
* -----------------------------------------------------------------------------------------
* Author       	: 	Abimanyu
* Company      	: 	Viseo
* Date       	: 	18-Jul-18
* Description	: 	Schedulable class to run the batch job.
* Test Class    :   
* ----------------------------------------------------------------------------------------
*/
public class AccountAssignment_BatchSchedulable implements System.Schedulable {

	public Void execute(System.SchedulableContext context) {
		if(Test.isRunningTest()){
			Database.executeBatch(new AccountAssignment_Batch(null),200);
		}else{
			Database.executeBatch(new AccountAssignment_Batch(null),1);
		}
	}
}