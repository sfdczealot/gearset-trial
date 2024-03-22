public class UpdateFulfilmentItemSyncToNS extends CS_ProcessBase {   
    @TestVisible 
    Map<Id, csmso__Sales_Order__c> applicableObjects;
    
    @TestVisible
    Map<Id, csmso__Sales_Order__c> oldObjects;
    public UpdateFulfilmentItemSyncToNS(Map<Id, csmso__Sales_Order__c> newObjects,Map<Id, csmso__Sales_Order__c> oldObjects) {
        super(CS_ProcessDefinition.FULFILMENTITEM_UPDATECOMPLETEDFULFILMENT, 'UpdateFulfilmentItemSyncToNS');
        
        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, csmso__Sales_Order__c>(); 
    }
    public override void isRecordEligible(SObject obj) {
        csmso__Sales_Order__c newSalesOrder = (csmso__Sales_Order__c) obj;
        csmso__Sales_Order__c oldSalesOrder = (csmso__Sales_Order__c) oldObjects.get(newSalesOrder.Id);
        if( newSalesOrder.csmso__Status__c == 'Booked' && oldSalesOrder.csmso__Status__c != 'Booked') {
            applicableObjects.put(newSalesOrder.Id, newSalesOrder);
        }
        
        this.runProcess = !applicableObjects.isEmpty();
    }
    public override void logic() {   
        
        Map<String,csdf__Fulfilment_Item__c> listFI = new Map<String,csdf__Fulfilment_Item__c> ([Select Id, csdf__Status__c,Product_Configuration__c, Status_Manual_Tracking__c,csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.RecordType.name 
                                                 from csdf__Fulfilment_Item__c 
                                                 where csdf__Fulfilment__r.Sales_Order__c IN : applicableObjects.keySet() 
                                                  and csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.RecordType.name != 'Direct Booking'
                                                 and (csdf__Status__c in ('Delivering','Completed') 
                                                      or (Status_Manual_Tracking__c = 'Completed' and  Served_By__c !='DFP'))]);
        List<string> apiName= getFieldsApi();
        List<csdf__Fulfilment_Item__c> newMpdList = new List<csdf__Fulfilment_Item__c>();
        List<id> s = new List<id>();
        s.addAll(applicableObjects.keySet());
        system.debug('applicableObjects.keySet() '+applicableObjects.keySet() );
        String query ='select '+String.join(apiName,',')+' from csdf__Fulfilment_Item__c where Product_Configuration__r.name = \'MPD Subscriptions\' and csdf__Fulfilment__r.Sales_Order__c in: s and csdf__Fulfilment__r.Sales_Order__r.NetSuite_Payment_Term__r.name=\'Monthly\'';


        system.debug(query);
        List<csdf__Fulfilment_Item__c> mpdList = database.query(query);
        for(csdf__Fulfilment_Item__c fi : mpdList){ 

            DateTime startD =  CS_utl_Datetime.getTimezoneOffset( fi.csdf__Flight_Beginning__c + ' ' + 'SGT')  ;
            DateTime endD = CS_utl_Datetime.getTimezoneOffset( fi.csdf__Flight_End__c + ' ' + 'SGT') ;
            Integer monthDiff = startD.date().monthsBetween(endD.date());
            Integer j =monthDiff;
            system.debug(monthDiff);
           String linkedId = fi.id;
            for(integer i = 0; i<monthDiff; i++){
                if(i ==0 ){
                    csdf__Fulfilment_Item__c newFi = fi;
                    
                    newFi.csdf__Name__c = (newFI.csdf__Name__c.split('ID:')[0]+ ' ID: ' + System.currentTimeMillis()).replace('&gt;', '>') +' - '+ i;
                    newFi.csdf__Flight_Beginning__c = startD.addMonths(i);
                    newFi.csdf__Flight_End__c = endD.addMonths(1-j);
                    newFi.Flight_Beginning_Line_Item__c = startD.date().addMonths(i);
                    newFi.Flight_End_Line_Item__c = endD.date().addMonths(1-j);
                    j--;
                    newFi.csdf__Quantity__c=1;
                    newFi.Insertion_Quantity__c =1;
                    newFI.Quantity_CPD__c =1;
                    newMpdList.add(newFi);
                }
                else{
                    csdf__Fulfilment_Item__c newFi = fi.clone();
                    //String newFulfilmentItemName = (newFI.csdf__Name__c + ' ID: ' + System.currentTimeMillis()).replace('&gt;', '>') + i;
                    newFi.Linked_Fulfilment_Item__c = linkedId;
                    newFi.csdf__Name__c = (newFI.csdf__Name__c.split('ID:')[0]+ ' ID: ' + System.currentTimeMillis()).replace('&gt;', '>') +' - '+ i;
                    newFi.csdf__Flight_Beginning__c = startD.addMonths(i);
                    newFi.csdf__Flight_End__c = endD.addMonths(1-j);
                    newFi.Flight_Beginning_Line_Item__c = startD.date().addMonths(i);
                    newFi.Flight_End_Line_Item__c = endD.date().addMonths(1-j);
                    j--;
                    newFi.csdf__Quantity__c=1;
                    newFi.Insertion_Quantity__c =1;
                    newFI.Quantity_CPD__c =1;
                    newMpdList.add(newFi);
                }
            }
        }
        
        if(!newMPDList.isempty())
            upsert newMPDList;  
        
        for(csdf__Fulfilment_Item__c fi : newMPDList){
            if((fi.csdf__Status__c == 'Delivering' || fi.csdf__Status__c == 'Completed') 
               || (fi.Status_Manual_Tracking__c == 'Completed' &&  fi.Served_By__c !='DFP')){
                   if(!listFI.containsKey(fi.id)){
                   listFI.put(fi.id,fi);
                   }
               }
        }
        //delete mpdList;               
        //for(parentchildMap)
        
        for(csdf__Fulfilment_Item__c fi : listFI.values()){
            fi.Sync_To_NetSuite__c = true;
        }
        update listFI.values();
    }
    public List<String> getFieldsApi(){
        List<String> sObjectFields = new List<String>{};
            sObjectFields.addAll(Schema.getGlobalDescribe().get('csdf__Fulfilment_Item__c').getDescribe().fields.getMap().keySet());
        return  sObjectFields;
    }
    
}