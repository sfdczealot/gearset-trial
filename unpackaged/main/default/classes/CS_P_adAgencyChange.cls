/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Update Advertiser/Agency fields on SO after they are updated on the respective Opportunity
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Osvaldo Parra   <osvaldo.parrarascon@cloudsense.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* vX.X            name@email.com
* 2019-05-27      Added logic when Media Agency is changed to update Media Agency Comission on SO 
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_adAgencyChange extends CS_ProcessBase {

    @TestVisible 
    Map<Id, Opportunity> applicableObjects;

    @TestVisible
    Map<Id, Opportunity> oldOpps;
    
    public CS_P_adAgencyChange(Map<Id, Opportunity> oldOpps) {
        super(CS_ProcessDefinition.AD_AGENCY_CHANGE, 'CS_P_adAgencyChange');

        applicableObjects = new Map<Id, Opportunity>();
        this.oldOpps = oldOpps; 
    }
 
    public override void isRecordEligible(SObject obj) {  
        Opportunity newOpp = (Opportunity) obj;
        Opportunity oldOpp = oldOpps.get(newOpp.Id);
       
        if(oldOpp.Media_Agency2__c !=  newOpp.Media_Agency2__c){
            applicableObjects.put(newOpp.Id, newOpp);
        } 
        else if(oldOpp.Agency_Client_del__c !=  newOpp.Agency_Client_del__c){
            applicableObjects.put(newOpp.Id, newOpp);
        }
        else if(oldOpp.AccountId != newOpp.AccountId) {
        	applicableObjects.put(newOpp.Id, newOpp);
        }

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        if(!applicableObjects.isEmpty()) {
         
            List<csmso__Sales_Order__c> applicableSalesOrders = new List<csmso__Sales_Order__c>(); 
            Map<Id, csdf__Fulfilment__c> applicableFulfilment = new Map<Id, csdf__Fulfilment__c>();
            
            applicableSalesOrders = 
            [
                SELECT  Id,
                        csmso__Status__c,
                        Media_Agency_Commission__c,
                		csmso__Advertiser__c,
                		Media_Agency__c,
                		Agency_Final__c,
                        Bill_To_Account__r.Id,
                        csmso__Opportunity__r.Id,
                        Advertiser_Final__c,
                        Bill_To_Account_Final__c,
                        Bill_To_Account_Filter__c,
                        (SELECT Id, csdf__Advertiser__c, csdf__Agency__c, csdf__Ad_Server_Id__c
                         FROM Fulfilments__r)
                FROM    csmso__Sales_Order__c 
                WHERE   csmso__Opportunity__r.Id IN :applicableObjects.keySet()
            ];
            
            for(csmso__Sales_Order__c currSalesOrder : applicableSalesOrders){
                
                Opportunity currOpp = applicableObjects.get(currSalesOrder.csmso__Opportunity__r.Id);
                
                if(currOpp.Media_Agency2__c != currSalesOrder.Media_Agency__c || currOpp.Media_Agency2__c != currSalesOrder.Agency_Final__c) {
                    //new
                    if(currOpp.Media_Agency2__c != currSalesOrder.Agency_Final__c){
                        if(currSalesOrder.csmso__Status__c == 'Draft' || currSalesOrder.csmso__Status__c == 'In Progress' || currSalesOrder.csmso__Status__c == 'Rejected'){
                            currSalesOrder.Media_Agency_Commission__c = currOpp.Media_Agency_Commission__c;
                            //currSalesOrder.csmso__Status__c = CS_const_SalesOrder.Status_PriceRecalculationRequired;
                            if(currOpp.Media_Agency2__c != null){
                                if(currSalesOrder.Media_Agency_Commission__c != currOpp.Media_Agency_Commission__c){
                                    currSalesOrder.Media_Agency_Commission__c = currOpp.Media_Agency_Commission__c;
                                }
                            } else {
                                currSalesOrder.Media_Agency_Commission__c = null;
                            }
                        } 
                        else {
                            currSalesOrder.csmso__Process_Message__c = 'Media Agency Commission has not been updated with this Media Agency change. This might affect pricing.';
                            currSalesOrder.csmso__Process_Message_Type__c = 'warning';
                        }
                    }
                    //new end

                    currSalesOrder.Agency_Final__c = currOpp.Media_Agency2__c;
                    for(csdf__Fulfilment__c fulfilment : currSalesOrder.Fulfilments__r) {
                    	if(String.isBlank(fulfilment.csdf__Ad_Server_Id__c)) {
                    		fulfilment.csdf__Agency__c = currOpp.Media_Agency2__c;
                    		applicableFulfilment.put(fulfilment.Id, fulfilment);
                    	}
                    }
                }
                
                if(currOpp.Agency_Client_del__c != currSalesOrder.csmso__Advertiser__c || currOpp.Agency_Client_del__c != currSalesOrder.Advertiser_Final__c) {
                    currSalesOrder.Advertiser_Final__c = currOpp.Agency_Client_del__c;
                    currSalesOrder.csmso__Advertiser__c = currOpp.Agency_Client_del__c;
                    for(csdf__Fulfilment__c fulfilment : currSalesOrder.Fulfilments__r) {
                        if(String.isBlank(fulfilment.csdf__Ad_Server_Id__c)) {
                            fulfilment.csdf__Advertiser__c = currOpp.Agency_Client_del__c;
                            applicableFulfilment.put(fulfilment.Id, fulfilment);
                    	}
                    }
                }
                
                if(currOpp.AccountId != currSalesOrder.Bill_To_Account__c || currOpp.AccountId != currSalesOrder.Bill_To_Account_Final__c) {
                	currSalesOrder.Bill_To_Account_Final__c = currOpp.AccountId;
                    currSalesOrder.Bill_To_Account_Filter__c = currOpp.AccountId;
                }
                
            }
            
            update applicableSalesOrders;
            update applicableFulfilment.values();
            
           // CS_ScheduleService.generateSchedules(applicableObjects.keySet(), null);
        }
    }
}