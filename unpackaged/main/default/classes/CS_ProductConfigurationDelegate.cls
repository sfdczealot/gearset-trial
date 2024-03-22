public with sharing class CS_ProductConfigurationDelegate extends CS_TriggerHandler.DelegateBase{
    
    list<csdf__Fulfilment_Item__c> fiToBeDeletedList = new list<csdf__Fulfilment_Item__c>();
    list<cscfga__Product_Configuration__c> configList = new list<cscfga__Product_Configuration__c>();
    list<CS_Revenue_Schedule_Item__c> revenueSchedulesToBeDeletedList = new list<CS_Revenue_Schedule_Item__c>();
    list<CS_Billing_Schedule_Item__c> billingSchedulesToBeDeletedList = new list<CS_Billing_Schedule_Item__c>();
    
    
    public override void beforeInsert(sObject o) {
        cscfga__Product_Configuration__c pc = (cscfga__Product_Configuration__c) o;
        fixStatuses(pc);
    }
    
    public override void beforeUpdate(sObject old, sObject o) {
        cscfga__Product_Configuration__c newPC = (cscfga__Product_Configuration__c) o;
        cscfga__Product_Configuration__c oldPC = (cscfga__Product_Configuration__c) old;
        fixStatuses(newPC);
    }
    
    public override void afterInsert(sObject o) {
        cscfga__Product_Configuration__c new_pc = (cscfga__Product_Configuration__c) o;
        
        configList.add(new_pc);
    }
        
    public override void beforeDelete(sObject o) {
        cscfga__Product_Configuration__c old_pc = (cscfga__Product_Configuration__c) o;

        list<csdf__Fulfilment_Item__c> fiList = [select id, name from csdf__Fulfilment_Item__c where Product_Configuration__c = :old_pc.Id];
        revenueSchedulesToBeDeletedList = [select id  from CS_Revenue_Schedule_Item__c where Product_Configuration__c = :old_pc.Id];
        billingSchedulesToBeDeletedList = [select id  from CS_Billing_Schedule_Item__c where Product_Configuration__c = :old_pc.Id];
        if (fiList != null && !fiList.isEmpty()) {
            for (csdf__Fulfilment_Item__c fi : fiList)
                fiToBeDeletedList.add(fi);
        }
    }
    
    public override void finish() {
        
        if (fiToBeDeletedList != null && !fiToBeDeletedList.isEmpty())
            delete fiToBeDeletedList;
            
        if (revenueSchedulesToBeDeletedList != null && !revenueSchedulesToBeDeletedList.isEmpty())
             delete revenueSchedulesToBeDeletedList;
             
        if (billingSchedulesToBeDeletedList != null && !billingSchedulesToBeDeletedList.isEmpty())
             delete billingSchedulesToBeDeletedList;     
    }
    
    private void fixStatuses(cscfga__Product_Configuration__c newPC) {
        // configurator now only accepts statuses: Valid, Incomplete, Requires_update
        if (newPC.cscfga__Configuration_Status__c != null) {
            if (newPC.cscfga__Configuration_Status__c.contains('Incomplete')){
                newPC.Configuration_Status_Tmp__c = 'Incomplete';
            } else if (newPC.cscfga__Configuration_Status__c.contains('Valid')){
                newPC.Configuration_Status_Tmp__c = 'Valid';
            } else if (newPC.cscfga__Configuration_Status__c.contains('Requires_Update')){
                newPC.Configuration_Status_Tmp__c = 'Requires_Update';
            }
        }
        
        if (newPC.Fulfilment_Item_Status__c != null ){
            newPC.Aggregated_Status__c = newPC.Fulfilment_Item_Status__c + ' (' + newPC.Configuration_Status_Tmp__c + ')'  ;
        }
        
        // Workaround until ticket T-40387 is resolved
        if (newPC.cscfga__Screen_Flow__c != null)
            newPC.cscfga__Screen_Flow__c = null;
    }
}