/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Used to handle insert update logic to update Configuration Aggregated status
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* v1.0            ivan.ravnjak@cloudsense.com
* 2019-05-07      Initial version 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_StatusUpdate extends CS_ProcessBase {   
	@TestVisible 
	Map<Id, cscfga__Product_Configuration__c> applicableObjects;
	
	@TestVisible
	Map<Id, cscfga__Product_Configuration__c> oldObjects;

	public CS_P_StatusUpdate(Map<Id, cscfga__Product_Configuration__c> oldObjects) {
		super(CS_ProcessDefinition.CONFIGURATION_STATUSUPDATE, 'CS_P_StatusUpdate');
		
		applicableObjects = new Map<Id, cscfga__Product_Configuration__c>();
		this.oldObjects = oldObjects;
	}
 
	public override void isRecordEligible(SObject obj) {
		cscfga__Product_Configuration__c newPC = (cscfga__Product_Configuration__c) obj;
		
		applicableObjects.put(newPC.Id, newPC);

		this.runProcess = !applicableObjects.isEmpty();
	}

	public override void logic() {	
		for (cscfga__Product_Configuration__c newPC : applicableObjects.values() ){
			if (newPC.cscfga__Configuration_Status__c != null) {
	            if (newPC.cscfga__Configuration_Status__c.contains('Incomplete')){
	                newPC.Configuration_Status_Tmp__c = 'Incomplete';
	            } else if (newPC.cscfga__Configuration_Status__c.contains('Valid')){
	                newPC.Configuration_Status_Tmp__c = 'Valid';
	            } else if (newPC.cscfga__Configuration_Status__c.contains('Requires_Update')){
	                newPC.Configuration_Status_Tmp__c = 'Requires_Update';
	            } else if (newPC.cscfga__Configuration_Status__c.contains('Requires Update')){
	                newPC.Configuration_Status_Tmp__c = 'Requires Update';
	            }
	        }
	        
	        if (newPC.Fulfilment_Item_Status__c != null ){
	            newPC.Aggregated_Status__c = newPC.Fulfilment_Item_Status__c + ' (' + newPC.Configuration_Status_Tmp__c + ')'  ;
	        }

			if(oldObjects == null && newPc.FLAG_Running_in_MLE__c) {
				newPc.Created_in_MLE__c = true;
				newPc.Last_time_edited_in_MLE__c = Datetime.now();
			}

			if(oldObjects != null && oldObjects.containsKey(newPc.Id) && newPc.FLAG_Running_in_MLE__c) {
				newPc.Last_time_edited_in_MLE__c = Datetime.now();
			}

			if(newPc.Fulfilment_Item_Status__c != null && oldObjects != null && oldObjects.containsKey(newPc.Id) && oldObjects.get(newPc.Id).Fulfilment_Item_Status__c != null && oldObjects.get(newPc.Id).Fulfilment_Item_Status__c != newPc.Fulfilment_Item_Status__c && newPc.Fulfilment_Item_Status__c == CS_const_SalesOrder.FulfilmentItemStatus_PausedInventoryReleased) {
				newPc.Line_Archived__c = Datetime.now();
			}
		}
	}
}