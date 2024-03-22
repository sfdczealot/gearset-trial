/**
 * @name CS_mock_WorkerBase
 * @description Mock class that extends abstract class WorkerBase
 * @revision
 *
 */
@isTest
public class CS_mock_WorkerBase extends CS_WorkerBase {
    /**
     * Class constructor
     * @return mock_WorkerBase
     */
    public CS_mock_WorkerBase() {
        super('TestProcess');
    }
    
    /**
     * Get the message for log
     */
    public override String getMessage() {
        return 'TestMessage';
    }
    
    /**
     * Gets the job type
     */
    public override String getJobType() {
        return 'CS_mock_WorkerBase';
    }
    
    /**
     * Gets the job id
     */
    public override Id getJobId() {
        return CS_utl_Id.getFakeId(Account.getSObjectType());
    }
    
    /**
     * Sets success
     */
    public void setSuccess(Boolean success) {
        this.success = success;
    }
}