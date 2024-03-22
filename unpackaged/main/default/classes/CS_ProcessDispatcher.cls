/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Generic dispatcher for automated processes.
* This class consumes concrete implementations of CS_ProcessBase, and dispatches them according to
* the API laid out in that class. The idea is to provide a unified framework for all automated
* processes called by a trigger, in order to increase code re-use and reduce the need for complex
* trigger handler classes to be implemented uniquely for each object.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_ProcessDispatcher {    
	
	@TestVisible private static boolean run = true;

 	public static boolean runOnce(){
 
 		if(run){

			run=false;
			
			return true;
 		
 		} else{return run;}
 		
 	}
 		
    private List<sObject> newList;
    private Map<Id,sObject> newMap;
    private List<sObject> oldList;
    private Map<Id,sObject> oldMap;
    
    private Boolean isBefore;
    private Boolean isUpdate;
    private Boolean isInsert;
    private Boolean isDelete;
    private Boolean isUndelete;
    
    @TestVisible
    private List<CS_ProcessBase> processes = new List<CS_ProcessBase>();
    
    /**
     * Class constructor
     */
    public CS_ProcessDispatcher() {
        if(Trigger.isExecuting) {
            this(
                Trigger.new,
                Trigger.newMap,
                Trigger.old,
                Trigger.oldmap,
                Trigger.isBefore,
                Trigger.isUpdate,
                Trigger.isInsert,
                Trigger.isDelete,
                Trigger.isUndelete
            );
        } 

        else {
            throw new CS_ProcessDispatcherException('This CS_ProcessDispatcher constructor is invalid when not in the context of a trigger.');
        }
    }
    
    /**
     * For testing, we will need to be able to simulate appropriate context variables.
     */
    @TestVisible
    private CS_ProcessDispatcher(List<sObject> newList, Map<Id,sObject> newMap, List<sObject> oldList, Map<Id,sObject> oldMap,
    						  Boolean isBefore, Boolean isUpdate, Boolean isInsert, Boolean isDelete, Boolean isUndelete) {
        this.newList = newList;
        this.newMap = newMap;
        this.oldList = oldList;
        this.oldMap = oldMap;
        this.isBefore = isBefore;
        this.isUpdate = isUpdate;
        this.isInsert = isInsert;
        this.isDelete = isDelete;
        this.isUndelete = isUndelete;
    }
    
    /**
     * Add processes to CS_ProcessDispatcher
     * @param  operations List<CS_ProcessBase>
     * @return            CS_ProcessDispatcher
     */
    public CS_ProcessDispatcher addProcesses(List<CS_ProcessBase> operations) {
        for(CS_ProcessBase op : operations) {
            this.addProcess(op);
        }

        return this;
    }
    
    /**
     * Add a single process to CS_ProcessDispatcher
     * @param  process CS_ProcessBase
     * @return           CS_ProcessDispatcher
     */
    public CS_ProcessDispatcher addProcess(CS_ProcessBase process) {
        if (process.isEnabledForMe()) {
        	this.processes.add(process);
        }

        return this;
    }
    
    /*
     * This method is the crux of this Process framework. The entire trigger contents are looped through once,
     * and for each record, the initialLoop() method from each registered process is called. This allows processes
     * to construct a private list of the records to be operated upon.
     * 
     * Next, the execute() method is called, so that the processes can operate on their whole list at once, outside
     * of any looping construct. This makes it easier to write code which reduces strain on limits.
     */
    public void dispatch() {
        List<SObject> affectedObjects = ( isUpdate || isInsert || isUndelete ) ? newList : oldList;
        
        for(SObject obj: affectedObjects) {
            for(CS_ProcessBase process : processes) {
                process.isRecordEligible(obj);
            }
        }
   		
        for(CS_ProcessBase process : processes) {
            process.execute();
        }
    }
    
    public class CS_ProcessDispatcherException extends Exception {}  
}