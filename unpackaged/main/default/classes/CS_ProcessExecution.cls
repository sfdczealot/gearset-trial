/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Class used to store information about processes that were executed in this transaction
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_ProcessExecution {
	@TestVisible
    private static Set<CS_ProcessDefinition> processesExecuted {
    	get {
    		if(processesExecuted == null) {
    			processesExecuted = new Set<CS_ProcessDefinition>();
    		}
    		return processesExecuted;
    	}
    	set;
    }

    /**
     * Add process to list of executed processes
     * @param process CS_ProcessDefinition
     */
    public static void addProcess(CS_ProcessDefinition process) {
    	processesExecuted.add(process);
    }

    /**
     * Checks if process was already executed
     * @param process CS_ProcessDefinition
     * @return 		  Boolean
     */
    public static Boolean wasProcessExecuted(CS_ProcessDefinition process) {
    	return processesExecuted.contains(process);
    }
}