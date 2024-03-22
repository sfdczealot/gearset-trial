/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Framework class for automated processes
* Automated processes are carried out during triggers. In the interests of code
* encapsulation and separation-of-concerns, it is useful to group all of the code
* for a single automated process into a single class, and for there to be a standard
* interface in order that all triggers end up with a familiar and easily-maintained
* structure.
* 
* This class provides such an interface, and is designed to work in combination with
* ProcessDispatcher to provide a drop.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public abstract class CS_ProcessBase extends CS_DMLWorker {
    @TestVisible
    protected CS_ProcessDefinition processName;
    //Flag to allow the operation to be run from a future method
    public Boolean runAsync {get; private set;}
    //Flag to indicate if the process should run or be bypassed
    public Boolean runProcess {get; protected set;}
    //Can't use reflection to get the name of the process class to run async so
    //have to hardcode the name of the class during construction
    public String className {get; protected set;}
    //When running asynchronously need to be able to pass the ids of the affected objects
    //to the process which will then have to retrieve all the objects from the database.
    @TestVisible
    protected Set<Id> applicableObjectIds {get; set;}
    
    public CS_ProcessBase(CS_ProcessDefinition processName, String className) {
        super();
        // Sets the processName
        this.processName = processName;
        this.className = className;
        //Default the async flag to not run asynchronously
        this.runAsync = false;
        //Default the run process flag to run the process, if the inital loop finds no objects to
        //run against set this to false so the the ProcessDispatcher doen't try to run the process
        //make sure that this is set when the process could run as an async process to avoid adding
        //processes to the queue that will result in no change.
        this.runProcess = true;
    }

    public CS_ProcessBase(CS_ProcessDefinition processName, String className, Boolean runAsync) {
        super();
        // Sets the processName
        this.processName = processName;
        this.className = className;
        //Attempting run the process asynchronously, but need to check that we aren't already 
        //running async.
        this.runAsync = !System.isFuture() && !System.isBatch() && !System.isScheduled() && runAsync;
        //Default the run process flag to run the process, if the inital loop finds no objects to
        //run against set this to false so the the ProcessDispatcher doen't try to run the process
        //make sure that this is set when the process could run as an async process to avoid adding
        //processes to the queue that will result in no change.
        this.runProcess = true;
    }
    
    public boolean isEnabledForMe() {
        return CS_utl_User.isProcessActiveForMe(this.processName);
    }

    public void execute() {
        if(this.runProcess) {
            if(this.runAsync) {
                runAsync(this.applicableObjectIds, this.className);
            }
            else {
                CS_ProcessExecution.addProcess(this.processName);    
				this.logic();  
            }
        }
    }
    
    // Test a single sObject to see whether it is applicable to your process
    // You may have a private static list in which you store the relevant objects
    public abstract void isRecordEligible(SObject obj);

    // Perform the logic associated with your process. If your logic affects only
    // a subset of records, you should have stored them in a private variable inside
    // the initialLoop method.
    @TestVisible
    protected abstract void logic();

    // Runs the process in future
    @TestVisible
    @Future
    private static void runAsync(Set<Id> objectIds, String operationClassName) {
        Type operationType = Type.forName(operationClassName);
        CS_ProcessBase operation = (CS_ProcessBase)operationType.newInstance();
        try {
            operation.applicableObjectIds = objectIds;
            operation.execute();
        }
        catch(Exception e) {
            system.debug(e);
        }
    }
}