/**
 * @name CS_QueueableDispatcher
 * @description Generic dispatcher for CS_QueueableWorker
 * @revision
 *
 */
public class CS_QueueableDispatcher {
	@TestVisible
	private List<CS_QueueableWorker> workers;
	
	@TestVisible
	private Boolean dispatched;
	
	/**
	 * Class constructor
	 * @return CS_QueueableDispatcher
	 */
	public CS_QueueableDispatcher() {
		this.workers = new List<CS_QueueableWorker>();
		this.dispatched = false;
	}
	
	/**
	 * Returns size of the queue
	 * @return Integer
	 */	
	@TestVisible
	private Integer getQueueSize() {
		return this.workers.size();
	}
	
	/**
	 * Add worker to the queue
	 * @param worker CS_QueueableWorker
	 */
	public void addWorker(CS_QueueableWorker worker) {
        workers.add(worker);
        if(getQueueSize() > 1) {
            this.workers[getQueueSize() - 2].setNextWorker(this.workers[getQueueSize() - 1]);
        }
    }
    
    /**
     * Dispatcher method used to start the enqueued Queueable jobs
     */
    public void dispatch() {        
        if (getQueueSize() > 0 && !dispatched) {
            System.enqueueJob(this.workers[0]);
            dispatched = true;
        }
    }
}