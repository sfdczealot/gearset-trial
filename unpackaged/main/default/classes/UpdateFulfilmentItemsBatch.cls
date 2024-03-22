//Batch Class to update Fulfilment Item records based on DFP
global class UpdateFulfilmentItemsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {
    public String queryString {get; set;}

    public Integer chunkSize {get; set;}
        
    global UpdateFulfilmentItemsBatch() {
        this.chunkSize = CS_Custom_Settings__c.getInstance().Integration_Chunk_Size__c.intValue();
    }

    global UpdateFulfilmentItemsBatch(String queryString, Integer chunkSize) {
        this.queryString = queryString;
        this.chunkSize = chunkSize;
    }
    
    global Database.QueryLocator start(Database.BatchableContext bc){
        String adServerNetworkCode = null;
        CS_Custom_Settings__c cs = CS_Custom_Settings__c.getOrgDefaults();
        if(cs != null && cs.Ad_Server_Network_Code__c != null){
            adServerNetworkCode = cs.Ad_Server_Network_Code__c;
        }

        if(String.isBlank(this.queryString)) {
            return Database.getQueryLocator([SELECT Id, Name FROM csdf__Fulfilment__c WHERE csdf__Ad_Server_Id__c != NULL AND
        	    									csdf__Ad_Server__r.csdf__Network_Code__c = :adServerNetworkCode AND
        		    								Sales_Order__r.To_Date_Time_Calculated__c >= YESTERDAY]);
        }
        else {
            return Database.getQueryLocator(this.queryString);
        }
    }

    global void execute(Database.BatchableContext bc, List<sObject> scope) {
        if (scope.isEmpty()){
            return;
        }
    	CS_Util.spinWait(1000);
    	
    	Map<Id, csdf__Fulfilment__c> fulfilments = new Map<Id, csdf__Fulfilment__c>((List<csdf__Fulfilment__c>)scope);
    	
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItemstoUpdate = new Map<Id, csdf__Fulfilment_Item__c>();
		Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>(
			[SELECT Id, Name, csdf__Fulfilment__r.Sales_Order__r.Last_Date_Booked__c,
                    csdf__Fulfilment__r.Sales_Order__r.Last_Date_Retracted__c
             FROM csdf__Fulfilment_Item__c
			 WHERE csdf__Ad_Server_Id__c != NULL AND 
			 Served_By__c = 'DFP' AND
             Is_Archived__c = false AND
			 csdf__Fulfilment__c = :fulfilments.keySet()]);

        for(csdf__Fulfilment_Item__c fi : fulfilmentItems.values()) {
            fi.csdf__Status_Update_Message_Status__c = 'Waiting';
            fulfilmentItemstoUpdate.put(fi.Id, fi);
        }

        if(!fulfilmentItemstoUpdate.isEmpty()) {
            update fulfilmentItemstoUpdate.values();
        
            CS_FulfilmentWorker.prepareWork('Fulfilment Item Refresh', fulfilments.values().get(0).Id, fulfilmentItemstoUpdate.keySet(), this.chunkSize, 0);
        }
    }
    
    global void finish(Database.BatchableContext bc){
    }
}