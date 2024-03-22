/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Remove Product Configuration related records on delete
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_OnConfigRemove extends CS_ProcessBase {
    Set<Id> applicableObjectIds;

    public CS_P_OnConfigRemove() {
        super(CS_ProcessDefinition.PC_ONREMOVE, 'CS_P_OnConfigRemove');

        applicableObjectIds = new Set<Id>();
    }

    public override void isRecordEligible(SObject obj) {
        cscfga__Product_Configuration__c newProductConfiguration = (cscfga__Product_Configuration__c) obj;
        if (newProductConfiguration.cscfga__package_guid__c != null && (newProductConfiguration.Fulfilment_Item_Status__c == 'Reserved' || 
                                                                        newProductConfiguration.Fulfilment_Item_Status__c == 'Active' || 
                                                                        newProductConfiguration.Fulfilment_Item_Status__c == 'Paused' || 
                                                                        newProductConfiguration.Fulfilment_Item_Status__c == 'Completed' || 
                                                                        newProductConfiguration.Fulfilment_Item_Status__c == 'Needs Creatives' || 
                                                                        newProductConfiguration.Fulfilment_Item_Status__c == 'Delivery Extended' ||
                                                                        newProductConfiguration.Fulfilment_Item_Status__c == 'Delivering' || 
                                                                        newProductConfiguration.Fulfilment_Item_Status__c == 'Ready' || 
                                                                        newProductConfiguration.Fulfilment_Item_Status__c == 'Inactive' || 
                                                                        newProductConfiguration.Fulfilment_Item_Status__c == 'Pending Approval')) {
                                                                            obj.adderror('Packages with Package Components in status other than Draft cannot be deleted.');
                                                                            throw new MyException('Packages with Package Components in status other than Draft cannot be deleted.');
                                                                        }
        applicableObjectIds.add(newProductConfiguration.Id);
        
        this.runProcess = !applicableObjectIds.isEmpty();
    }

    public override void logic() {
        delete [SELECT Id FROM csdf__Fulfilment_Item__c WHERE Product_Configuration__c = :applicableObjectIds];
        delete [SELECT Id FROM CS_Revenue_Schedule_Item__c WHERE Product_Configuration__c = :applicableObjectIds];
        delete [SELECT Id FROM CS_Billing_Schedule_Item__c WHERE Product_Configuration__c = :applicableObjectIds];        
    }

    public class MyException extends Exception {} 
        
    
}