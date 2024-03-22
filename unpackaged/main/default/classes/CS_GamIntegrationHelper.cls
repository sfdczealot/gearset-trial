/**
 * Created by jameshladek on 3/10/20.
 */

public with sharing class CS_GamIntegrationHelper implements Callable {

    private String calloutType;
    private String field;

    public CSPOFA__Orchestration_Step__c checkAvails(Id salesOrderId, CSPOFA__Orchestration_Step__c step) {
        Map<Id, cscfga__Product_Configuration__c> mapProductConfigs = new Map<Id, cscfga__Product_Configuration__c>();
        //Map<Id, cscfga__Product_Configuration__c> mapDeveloperProductConfigs = new Map<Id, cscfga__Product_Configuration__c>();

        for (cscfga__Product_Configuration__c pc : getSalesOrderData(salesOrderId).Product_Configurations__r) {
            if (pc.Eligible_for_Check_Availability__c) {
                mapProductConfigs.put(pc.Id, pc);
            }
          /*  if (pc.Developer_listing__c) {
                mapDeveloperProductConfigs.put(pc.Id, pc);
            }*/
        }
        
        /*if (mapDeveloperProductConfigs.values().size() > 0) {
            DeveloperListingInventoriesCheck.checkAvailability(mapDeveloperProductConfigs);
            //return updateOrchestratorStep(salesOrderId, step, 'Waiting For Feedback', 'Waiting for Check avails.');
        }*/
        if (mapProductConfigs.values().size() > 0) {
            DigitalFulfilmentAdapterUtil.doGlobalCheckAvails(mapProductConfigs);
            return updateOrchestratorStep(salesOrderId, step, 'Waiting For Feedback', 'Waiting for Check avails.');
        } else {
            return updateOrchestratorStep(salesOrderId, step, 'Complete', 'Check avails completed.');
        }
    }

    public CSPOFA__Orchestration_Step__c pushToGam(Id salesOrderId, CSPOFA__Orchestration_Step__c step) {
        Boolean validConfigs = false;
        for (cscfga__Product_Configuration__c pc : getSalesOrderData(salesOrderId).Product_Configurations__r) {
            if (pc.Served_By__c == 'DFP' && pc.Fulfilment_Item_Status__c != 'Paused Inventory Released') {
                validConfigs = true;
            }
        }
        if (validConfigs) {
            DigitalFulfilmentAdapterUtil.pushToAdServer(salesOrderId);
            return updateOrchestratorStep(salesOrderId, step, 'Waiting For Feedback', 'Waiting for Push.');
        } else {
            return updateOrchestratorStep(salesOrderId, step, 'Complete', 'Push to GAM completed.');
        }
    }

    public CSPOFA__Orchestration_Step__c statusPushToGam(Id salesOrderId, CSPOFA__Orchestration_Step__c step) {
        List<Id> fulfilmentIds = new List<Id>();
        csmso__Sales_Order__c salesOrder = getSalesOrderData(salesOrderId);
        for (cscfga__Product_Configuration__c pc : salesOrder.Product_Configurations__r) {
            if (pc.Served_By__c == 'DFP') {
                fulfilmentIds.add(salesOrder.Fulfilments__r.get(0).Id);
                break;
            }
        }
        if (fulfilmentIds.size() > 0) {
            DigitalFulfilmentAdapterUtil.pushToAdServerSOStatus(fulfilmentIds);
            return updateOrchestratorStep(salesOrderId, step, 'Waiting For Feedback', 'Waiting for Status Push.');
        } else {
            return updateOrchestratorStep(salesOrderId, step, 'Complete', 'Status Push to GAM completed.');
        }

    }

    public CSPOFA__Orchestration_Step__c refreshFulfilment(Id salesOrderId, CSPOFA__Orchestration_Step__c step) {
        List<Id> fulfilmentIds = new List<Id>();
        csmso__Sales_Order__c salesOrder = getSalesOrderData(salesOrderId);
        for (cscfga__Product_Configuration__c pc : salesOrder.Product_Configurations__r) {
            if (pc.Served_By__c == 'DFP') {
                fulfilmentIds.add(salesOrder.Fulfilments__r.get(0).Id);
                break;
            }
        }

        if (fulfilmentIds.size() > 0) {
            csam.ObjectGraphCalloutHandler.queueMessageFromIds('Fulfilment Refresh', fulfilmentIds);
            return updateOrchestratorStep(salesOrderId, step, 'Waiting For Feedback', 'Waiting for Refresh.');
        } else {
            return updateOrchestratorStep(salesOrderId, step, 'Complete', 'Refresh completed.');
        }
    }

    public CSPOFA__Orchestration_Step__c inventoryReserve(Id salesOrderId, CSPOFA__Orchestration_Step__c step) {
        Set<Id> applicableLines = new Set<Id>();
        for (cscfga__Product_Configuration__c pc : getSalesOrderData(salesOrderId).Product_Configurations__r) {
            if ((pc.Ad_Type__c == 'Standard' || pc.Ad_Type__c == 'Sponsorship') && pc.Sales_Order__r.Order_Type__c != 'House Non-Guaranteed' && pc.Served_By__c == 'DFP' && pc.Fulfilment_Item_Status__c != 'Paused Inventory Released' && pc.Reservation_Status__c != 'RESERVED' && pc.Reservation_Status__c != 'CHECK_LINE_ITEM_RESERVATION_STATUS') {
                applicableLines.add(pc.Id);
            }
        }
        if (!applicableLines.isEmpty()) {
            DigitalFulfilmentAdapterUtil.fulfilmentItemReserveRelease(salesOrderId, applicableLines);
            return updateOrchestratorStep(salesOrderId, step, 'Waiting For Feedback', 'Waiting for Reserve.');
        } else {
            return updateOrchestratorStep(salesOrderId, step, 'Complete', 'Reserve completed.');
        }
    }

    public CSPOFA__Orchestration_Step__c inventoryRelease(Id salesOrderId, CSPOFA__Orchestration_Step__c step) {
        Set<Id> applicableLines = new Set<Id>();
        for (cscfga__Product_Configuration__c pc : getSalesOrderData(salesOrderId).Product_Configurations__r) {
            if ((pc.Ad_Type__c == 'Standard' || pc.Ad_Type__c == 'Sponsorship') && pc.Served_By__c == 'DFP' && pc.Fulfilment_Item_Status__c != 'Paused Inventory Released' && (pc.Reservation_Status__c == 'RESERVED' || pc.Reservation_Status__c == 'CHECK_LINE_ITEM_RESERVATION_STATUS')) {
                applicableLines.add(pc.Id);
            }
        }
        if (!applicableLines.isEmpty()) {
            DigitalFulfilmentAdapterUtil.fulfilmentItemReserveRelease(salesOrderId, applicableLines);
            return updateOrchestratorStep(salesOrderId, step, 'Waiting For Feedback', 'Waiting for Release.');
        } else {
            return updateOrchestratorStep(salesOrderId, step, 'Complete', 'Release completed.');
        }
    }

    public CSPOFA__Orchestration_Step__c requestAssistanceUpdateOrder(Id salesOrderId, CSPOFA__Orchestration_Step__c step) {
        DigitalFulfilmentAdapterUtil.requestAcceptance(salesOrderId);
        return updateOrchestratorStep(salesOrderId, step, 'Waiting For Feedback', 'Waiting for Request Acceptance.');
    }

    public CSPOFA__Orchestration_Step__c retractProposal(Id salesOrderId, CSPOFA__Orchestration_Step__c step) {
        DigitalFulfilmentAdapterUtil.retractPGProposal(salesOrderId);
        return updateOrchestratorStep(salesOrderId, step, 'Waiting For Feedback', 'Waiting for Request Acceptance.');
    }


    public Object call(String calloutType, Map<String, Object> data) {
        this.calloutType = calloutType.toLowerCase();
        switch on this.calloutType {
            when 'check availability' {
                return this.checkAvails((Id) data.get('salesOrderId'), (CSPOFA__Orchestration_Step__c) data.get('step'));
            }
            when 'push to gam' {
                return this.pushToGam((Id) data.get('salesOrderId'), (CSPOFA__Orchestration_Step__c) data.get('step'));
            }
            when 'status push to gam' {
                return this.statusPushToGam((Id) data.get('salesOrderId'), (CSPOFA__Orchestration_Step__c) data.get('step'));
            }
            when 'inventory release' {
                return this.inventoryRelease((Id) data.get('salesOrderId'), (CSPOFA__Orchestration_Step__c) data.get('step'));
            }
            when 'request buyer assistance' {
                return this.requestAssistanceUpdateOrder((Id) data.get('salesOrderId'), (CSPOFA__Orchestration_Step__c) data.get('step'));
            }
            when 'update order' {
                return this.requestAssistanceUpdateOrder((Id) data.get('salesOrderId'), (CSPOFA__Orchestration_Step__c) data.get('step'));
            }
            when 'reserve inventory' {
                return this.inventoryReserve((Id) data.get('salesOrderId'), (CSPOFA__Orchestration_Step__c) data.get('step'));
            }
            when 'refresh fulfilment' {
                return this.refreshFulfilment((Id) data.get('salesOrderId'), (CSPOFA__Orchestration_Step__c) data.get('step'));
            }
            when 'retract proposal' {
                return this.retractProposal((Id) data.get('salesOrderId'), (CSPOFA__Orchestration_Step__c) data.get('step'));
            }
            when else {
               return updateOrchestratorStep((Id) data.get('salesOrderId'), (CSPOFA__Orchestration_Step__c) data.get('step'), 'Error', 'Unrecognized action.');
            }
        }
    }

    private csmso__Sales_Order__c getSalesOrderData(Id soId) {
        return [
                SELECT Id, (
                        SELECT Id, Eligible_for_Check_Availability__c, Fulfilment_Item_Status__c, Served_By__c, Reserve_Inventory__c, Reservation_Status__c,
                                Sales_Order__r.Order_Type__c, Ad_Type__c,Developer_listing__c
                        FROM Product_Configurations__r
                ), (SELECT Id FROM Fulfilments__r)
                FROM csmso__Sales_Order__c
                WHERE Id = :soId
        ];
    }

    public CSPOFA__Orchestration_Step__c updateOrchestratorStep(Id salesOrderId, CSPOFA__Orchestration_Step__c step, String status, String message) {
        step.CSPOFA__Status__c = status;
        step.CSPOFA__Message__c = message;
        step.CSPOFA__external_id__c = salesOrderId;
        step.CSPOFA__Completed_Date__c = status == 'Complete' || status == 'Error' ? Date.today() : null;
        step.CSPOFA__Execute_Count__c = step.CSPOFA__Execute_Count__c != null ? step.CSPOFA__Execute_Count__c + 1 : 1;

        return step;
    }
}