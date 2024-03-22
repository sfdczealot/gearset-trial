public with sharing class CS_FulfilmentItemDelegate extends CS_TriggerHandler.DelegateBase {

    map<id,sobject[]> fiToSObjectMap = new map<id, sObject[]>();

    public override void prepareBefore() {
    }

    public override void prepareAfter() {
    }

    public override void beforeInsert(sObject o) {
    }

    public override void beforeUpdate(sObject old, sObject o) {
    }

    public override void afterInsert(sObject o) {
    }

    public override void afterUpdate(sObject old, sObject o) {
    }

    public override void finish() {
        for (Sobject sobj : trigger.new) {
            csdf__Fulfilment_Item__c fi = (csdf__Fulfilment_Item__c) sobj;

            if(fi.Served_By__c != 'DFP') {
                continue;
            }

            if (trigger.isUpdate || trigger.isDelete) {
                csdf__Fulfilment_Item__c fi_old = (csdf__Fulfilment_Item__c) Trigger.oldMap.get(fi.Id);
                if ( ((fi_old.Last_Action_from_DFP__c == null &&  fi.Last_Action_from_DFP__c == null) ||
                        (fi_old.Last_Action_from_DFP__c != null && fi.Last_Action_from_DFP__c != null &&
                                fi_old.Last_Action_from_DFP__c == fi.Last_Action_from_DFP__c)))
                {
                    return;
                }
            }
        }

        if (trigger.isAfter && trigger.isUpdate)
        {
            updateAttributesFromFulfilmentItem();
        }
    }

    public void updateAttributesFromFulfilmentItem() {
        List<PropertyMappingEngine.FieldMappingPair> fmps = new List<PropertyMappingEngine.FieldMappingPair>();

        for (SObject sobj : trigger.new)
        {
            csdf__Fulfilment_Item__c fi = (csdf__Fulfilment_Item__c) sobj;

            fiToSObjectMap.put(fi.Product_Configuration__c, new sobject[]{fi});
            if(fi.Product_Configuration__c!=null)
            fmps.add(new PropertyMappingEngine.FieldMappingPair(fi, new List<SObject>{new cscfga__Product_Configuration__c (Id = fi.Product_Configuration__c)}));
        }

        CS_Custom_Settings__c settings = CS_Custom_Settings__c.getInstance();
        if (settings!= null && settings.Fulfilment_Item_Propert_Map_Key__c != null)
        {
            // AND EXECUTE THE PROPERTY MAPPING
            cscfga__Attribute__c[] mappedAttributes = PropertyMappingEngine.mapAtrributesAndFields(settings.Fulfilment_Item_Propert_Map_Key__c, fiToSObjectMap);
            update MappedAttributes;

            update PropertyMappingEngine.mapsObjectFields(settings.Fulfilment_Item_Propert_Map_Key__c, fmps);
        }
    }
}