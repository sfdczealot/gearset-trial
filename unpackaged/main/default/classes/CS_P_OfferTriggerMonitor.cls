/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Disables Attribute triggers in transaction if Configuration comes from Offer.
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author         Ivan Ravnjak   <ivan.ravnjak@cloudsensesolutions.com>
* ─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public class CS_P_OfferTriggerMonitor extends CS_ProcessBase {
    Set<Id> applicableObjectIds;
    Set<Id> deletedObjectIds;
    Boolean isDelete;

    public CS_P_OfferTriggerMonitor(Boolean isDeleted) {
        super(CS_ProcessDefinition.OFFER_TRIGGERMONITOR, 'CS_P_OfferTriggerMonitor');

        applicableObjectIds = new Set<Id>();
        deletedObjectIds = new Set<Id>();
        this.isDelete = isDeleted;
    }

    public override void isRecordEligible(SObject obj) {
        cscfga__Product_Configuration__c newProductConfiguration = (cscfga__Product_Configuration__c) obj;

        if(newProductConfiguration.cscfga__originating_offer__c != null && newProductConfiguration.FLAG_Package_Item__c == 'Yes') {
            applicableObjectIds.add(newProductConfiguration.cscfga__originating_offer__c);
        }
        
        this.runProcess = !applicableObjectIds.isEmpty();
    }

    public override void logic() {
        CS_utl_user.isTriggerDeactivatedForOffers = true;
        
        if (!applicableObjectIds.isEmpty()){
            CS_utl_user.isTriggerDeactivatedForOffers = true;
        }
    }
}