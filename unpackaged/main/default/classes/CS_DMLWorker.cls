/**
 * @name CS_DMLWorker
 * @DMLWorker class for DML operations
 * @revision
 *
 */
public virtual class CS_DMLWorker {
	/**
	 * Log Worker used for storing logs
	 */
    public CS_LogWorker log;
	
    public Integer recordCount;
    
    @TestVisible
    protected String processName;
    
    @TestVisible
    protected Boolean success;
    
    @TestVisible
    protected Boolean doLog; 
    
    @TestVisible
    List<SObjectType> sObjectOrder {
    	get {
    		if(sObjectOrder == null) {
    			sObjectOrder = new List<SObjectType>();
    		}
    		return sObjectOrder;
    	}
    	set;
    }  
	
	/**
	 * Map of objects to insert
	 */
	@TestVisible
	protected Map<SObjectType, List<SObject>> objectsToUpsert {
		get {
			if(objectsToUpsert == null) {
				objectsToUpsert = new Map<SObjectType, List<SObject>>();
				for(SObjectType sType : sObjectOrder) {
					objectsToUpsert.put(sType, CS_utl_Array.getInstance(sType.getDescribe().getName()));
				}
			}
			return objectsToUpsert;
		}
		set;
	}
	
	/**
	 * Map of objects to delete
	 */
	protected Map<SObjectType, List<SObject>> objectsToDelete {
		get {
			if(objectsToDelete == null) {
				objectsToDelete = new Map<SObjectType, List<SObject>>();
				for(SObjectType sType : sObjectOrder) {
					objectsToDelete.put(sType, CS_utl_Array.getInstance(sType.getDescribe().getName()));
				}
			}
			return objectsToDelete;
		}
		set;		
	}

    /**
     * Class constructor
     * @return CS_DMLWorker
     */
	public CS_DMLWorker() {
        this(true);
	}
	
    /**
     * Class constructor
     * @param  doLog
     * @return CS_DMLWorker
     */
	public CS_DMLWorker(Boolean doLog) {
        this(doLog, null);
	}
	
    /**
     * Class constructor
     * @param  doLog
     * @return CS_DMLWorker
     */
	public CS_DMLWorker(Boolean doLog, List<SObjectType> sObjectOrder) {
        log = CS_LogWorker.getInstance();
        this.recordCount = 0;
        this.success = true;
        this.doLog = doLog;
        this.sObjectOrder = sObjectOrder;
	}
	
	/**
	 * Adds objects for insert using sObject name
	 * @param objs List<SObject>
	 * @return     List<SObject>
	 */
	@TestVisible
	public virtual List<SObject> addForUpsert(List<SObject> objs) {
		if(objs != null && !objs.isEmpty()) {
			if(!objectsToUpsert.containsKey(objs.get(0).getSObjectType())) {
				objectsToUpsert.put(objs.get(0).getSObjectType(), CS_utl_Array.getInstance(objs.get(0).getSObjectType().getDescribe().getName()));
			}
			
			objectsToUpsert.get(objs.get(0).getSObjectType()).addAll(objs);
		}
		
		return objs;
	}
	
	/**
	 * Adds objects for delete using sObject name
	 * @param objs List<SObject>
	 * @return     List<SObject>
	 */
	@TestVisible
	public virtual List<SObject> addForDelete(List<SObject> objs) {
		if(objs != null && !objs.isEmpty()) {
			if(!objectsToDelete.containsKey(objs.get(0).getSObjectType())) {
				objectsToDelete.put(objs.get(0).getSObjectType(), CS_utl_Array.getInstance(objs.get(0).getSObjectType().getDescribe().getName()));
			}
			
			objectsToDelete.get(objs.get(0).getSObjectType()).addAll(objs);
		}
		
		return objs;
	}
	
	/**
	 * Finishes upsert operation
	 */
	@TestVisible
	public virtual void doUpsert() {
		doUpsert(true);
	}
	
	/**
	 * Finishes upsert operation
	 * @param allOrNone Boolean
	 */
	@TestVisible
	public virtual void doUpsert(Boolean allOrNone) {
		Integer totalNumberOfRecords = 0;
		List<SObjectType> upsertOrder = !sObjectOrder.isEmpty() ? sObjectOrder : new List<SObjectType>(objectsToUpsert.keySet());
		for(SObjectType sType : upsertOrder) {
			if(!objectsToUpsert.get(sType).isEmpty()) {
				totalNumberOfRecords += objectsToUpsert.get(sType).size();
				//to remove duplicate records
				Set<SObject> getUpsRecordsSet = new Set<SObject>(objectsToUpsert.get(sType));
                //to convert set back to list 
                List<SObject> getUpsRecordList = new List<SObject>(getUpsRecordsSet);
				List<Database.UpsertResult> results = Database.upsert(getUpsRecordList, allOrNone);
		        for(Integer i = 0; i < results.size(); i++) {
            		if (!results.get(i).isSuccess()) {
                    	totalNumberOfRecords--;
                    	if(this.doLog) log.addMessage(objectsToUpsert.get(sType).get(i), results.get(i));
                    	this.success = false;
            		}
                }
				
				for(Schema.ChildRelationship cr : sType.getDescribe().getChildRelationships()) {
					if(objectsToUpsert.containsKey(cr.getChildSObject())) {
						List<SObject> childObjects = objectsToUpsert.get(cr.getChildSObject());
						Schema.DescribeFieldResult dfr = CS_utl_SObject.getRelationshipField(sType, cr.getChildSObject());
						for(SObject childObject : childObjects) {
							if(childObject.getSObject(dfr.getRelationshipName()) != null) {
								if(childObject.get(dfr.getName()) == null) {
									childObject.put(dfr.getName(), childObject.getSObject(dfr.getRelationshipName()).Id);
								}
							}
						}
					}
				}
			}
		}
		
		this.recordCount += totalNumberOfRecords;
	}
	
	/**
	 * Finishes delete operation
	 */
	@TestVisible
	public virtual void doDelete() {
		doDelete(true);
	}
	
	/**
	 * Finishes delete operation
	 * @param allOrNone Boolean
	 */	
	@TestVisible
	public virtual void doDelete(Boolean allOrNone) {	
		Integer totalNumberOfRecords = 0;
		List<SObjectType> deleteOrder = !sObjectOrder.isEmpty() ? sObjectOrder : new List<SObjectType>(objectsToDelete.keySet());
		for(Integer i = deleteOrder.size() - 1; i >= 0; i--) {
			Schema.SObjectType sType = deleteOrder.get(i);
			if(!objectsToDelete.get(sType).isEmpty()) {
				totalNumberOfRecords += objectsToDelete.get(sType).size();
                //to remove duplicate records
				Set<SObject> getDelrecordsSet = new Set<SObject>(objectsToDelete.get(sType));
                //to convert set back to list 
                List<SObject> getDelRecordList = new List<SObject>(getDelrecordsSet);
				List<Database.DeleteResult> results = Database.delete(getDelRecordList,allOrNone);
		        for(Integer j = 0; j < results.size(); j++) {
            		if (!results.get(j).isSuccess()) {
                    	totalNumberOfRecords--;
                    	if(this.doLog) log.addMessage(objectsToDelete.get(sType).get(j), results.get(j));
                    	this.success = false;
            		}
                }
			}
		}	
		
		this.recordCount += totalNumberOfRecords;
	}
	
	/**
	 * Adds objects for upsert and finishes the operation
	 * @param objs 		List<SObject>
	 * @param allOrNone Boolean
	 * @return    		List<SObject>
	 */
	@TestVisible
	public List<SObject> upsertRecords(List<SObject> objs, Boolean allOrNone) {
		addForUpsert(objs);
		doUpsert(allOrNone);
		return objs;
	}
	
	/**
	 * Adds objects for delete and finishes the operation
	 * @param objs 		List<SObject>
	 * @param allOrNone Boolean
	 * @return    		List<SObject>
	 */
	@TestVisible
	public List<SObject> deleteRecords(List<SObject> objs, Boolean allOrNone) {
		addForDelete(objs);
		doDelete(allOrNone);
		return objs;
	}
}