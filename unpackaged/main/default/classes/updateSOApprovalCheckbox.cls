public class updateSOApprovalCheckbox extends CS_ProcessBase {   
    @TestVisible  
    Map<Id, cscfga__Product_Configuration__c> applicableObjects;
    
    @TestVisible
    Map<Id, cscfga__Product_Configuration__c> oldObjects;
    public updateSOApprovalCheckbox(Map<Id, cscfga__Product_Configuration__c> newObjects,Map<Id, cscfga__Product_Configuration__c> oldObjects) {
        super(CS_ProcessDefinition.SO_APPROVALFIELDSUPDATE, 'updateSOApprovalCheckbox');
        
        this.oldObjects = oldObjects;
        applicableObjects = new Map<Id, cscfga__Product_Configuration__c>(); 
    }
    public override void isRecordEligible(SObject obj) {
        cscfga__Product_Configuration__c newPC = (cscfga__Product_Configuration__c) obj;
       // cscfga__Product_Configuration__c oldPC = (cscfga__Product_Configuration__c) oldObjects.get(newPC.Id);
        
            applicableObjects.put(newPC.Id, newPC);
      
        
        this.runProcess = !applicableObjects.isEmpty();
    }
    public override void logic() {
        
        Map<id,csmso__Sales_Order__c> updateSOMap = new Map<id,csmso__Sales_Order__c>();
        Map<id,csmso__Sales_Order__c> SOMap = new Map<id,csmso__Sales_Order__c>([select id, SD_Approval__c,CM_APProval__c,isSDApproved__c,
                                                                                 isCBOApproved__c,isCMApproved__c,isHOBApproved__c
                                                                                 from csmso__Sales_Order__c
                                                                                 where ID in (select Sales_order__c 
                                                                                               from cscfga__Product_Configuration__c
                                                                                               where id in: applicableObjects.keySet())]);
        for(String pcId : applicableObjects.keySet()){
        
        if(Trigger.isDelete){
               cscfga__Product_Configuration__c newPC = applicableObjects.get(pcId);
              csmso__Sales_order__c so = SOMap.get(newPC.Sales_Order__c);
                  if(SOMap.containsKey(newPC.Sales_Order__c)){

                      so.isSDApproved__c = false;
                      so.isCBOApproved__c = false;
                      so.isCMApproved__c = false;
                      so.isHOBAwardApproved__c = false;
                      so.isHOBCNSApproved__c = false;
                      so.isHOBEventsApproved__c = false;
                      so.isHOBFastkeyApproved__c = false;
                      so.isHOBMAASApproved__c = false;
                      updateSOMap.put(so.id,so);
                  }
        } else{
            cscfga__Product_Configuration__c newPC = applicableObjects.get(pcId);
            cscfga__Product_Configuration__c oldPC = oldObjects.get(pcId);
            system.debug(newPC.Gross_Rate__c +' '+OldPC.Gross_Rate__c );
            system.debug(newPC.Flight_Begin__c +' '+OldPC.Flight_Begin__c );
            system.debug(newPC.Flight_End__c +' '+OldPC.Flight_End__c );

            if(newPC.cscfga__Configuration_Offer__c != oldPC.cscfga__Configuration_Offer__c || 
               newPC.cscfga__Contract_Term__c != oldPC.cscfga__Contract_Term__c || 
               newPC.cscfga__Contract_Term_Period__c != oldPC.cscfga__Contract_Term_Period__c || 
               newPC.Digital_Product__c != oldPC.Digital_Product__c || 
               newPC.csmso__Flight_Begin__c != oldPC.csmso__Flight_Begin__c || 
               newPC.csmso__Flight_End__c != oldPC.csmso__Flight_End__c || 
               newPC.Gross_Rate__c != oldPC.Gross_Rate__c || 
               newPC.Gross_Total__c != oldPC.Gross_Total__c || 
               newPC.Insertion_Quantity__c != oldPC.Insertion_Quantity__c || 
               newPC.Net_Rate_Final__c != oldPC.Net_Rate_Final__c || 
               newPC.Net_Rate__c != oldPC.Net_Rate__c || 
               newPC.Unit_Price_after_Discount__c != oldPC.Unit_Price_after_Discount__c || 
               newPC.Net_Total__c != oldPC.Net_Total__c || 
               newPC.cscfga__one_off_charge_line_discount_value__c != oldPC.cscfga__one_off_charge_line_discount_value__c || 
               newPC.cscfga__one_off_charge_product_discount_value__c != oldPC.cscfga__one_off_charge_product_discount_value__c || 
               newPC.cscfga__Quantity__c != oldPC.cscfga__Quantity__c || 
               newPC.cscfga__recurring_charge_product_discount_value__c != oldPC.cscfga__recurring_charge_product_discount_value__c || 
               newPC.cscfga__Total_Price__c != oldPC.cscfga__Total_Price__c || 
               newPC.Total_Quantity__c != oldPC.Total_Quantity__c 
              ){
                 
                  csmso__Sales_order__c so = SOMap.get(newPC.Sales_Order__c);
                  if(SOMap.containsKey(newPC.Sales_Order__c)){

                      so.isSDApproved__c = false;
                      so.isCBOApproved__c = false;
                      so.isCMApproved__c = false;
                      so.isHOBAwardApproved__c = false;
                      so.isHOBCNSApproved__c = false;
                      so.isHOBEventsApproved__c = false;
                      so.isHOBFastkeyApproved__c = false;
                      so.isHOBMAASApproved__c = false;
                      updateSOMap.put(so.id,so);
                  }
                  }
        }
        }
        if(updateSOMap.size() > 0)
        update updateSOMap.values();
        
    }
    
}