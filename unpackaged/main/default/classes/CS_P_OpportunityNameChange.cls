/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Update Opportunity Name on Sales Order after Opportunity Name is changed
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Sasa Marjancic
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @changes
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_OpportunityNameChange extends CS_ProcessBase {

    @TestVisible 
    Map<Id, Opportunity> applicableObjects;

    @TestVisible
    Map<Id, Opportunity> oldOpps;
    
    public CS_P_OpportunityNameChange(Map<Id, Opportunity> oldOpps) {
        super(CS_ProcessDefinition.OPPORTUNITY_NAMECHANGE, 'CS_P_OpportunityNameChange');

        applicableObjects = new Map<Id, Opportunity>();
        this.oldOpps = oldOpps; 
    }
 
    public override void isRecordEligible(SObject obj) {  
        Opportunity newOpp = (Opportunity) obj;
        Opportunity oldOpp = oldOpps.get(newOpp.Id);
       
        if(oldOpp.Name !=  newOpp.Name){
            applicableObjects.put(newOpp.Id, newOpp);
        } 

        this.runProcess = !applicableObjects.isEmpty();
    }

    public override void logic() {
        if(!applicableObjects.isEmpty()){          
            List<csmso__Sales_Order__c> applicableSalesOrders = 
            [
                SELECT  Id,
                		Opportunity_Name__c,
                		csmso__Opportunity__r.Id
                FROM    csmso__Sales_Order__c 
                WHERE   csmso__Opportunity__r.Id IN :applicableObjects.keySet()
            ];
            
            for(csmso__Sales_Order__c currSalesOrder : applicableSalesOrders) {
                Opportunity currOpp = applicableObjects.get(currSalesOrder.csmso__Opportunity__r.Id);
                
                currSalesOrder.Opportunity_Name__c = currOpp.Name;
            }
            
            update applicableSalesOrders;
        }
    }
}