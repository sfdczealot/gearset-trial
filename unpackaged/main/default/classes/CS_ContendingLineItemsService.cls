/**
 * @name CS_ContendingLineItemsService
 * @description Service class for contending line items
 * @revision
 *
 */
public without sharing class CS_ContendingLineItemsService {
    public static Map<String, ContendingLineItems> getContendingItems(Set<Id> fulfilmentItemIds) {
        List<csdf__Fulfilment_Item__c> fulfilmentItems = [SELECT Id, Contending_Items_Extended__c, Flight_Beginning_Line_Item__c
        FROM csdf__Fulfilment_Item__c
        WHERE Id = :fulfilmentItemIds];
        Map<String, ContendingLineItems> contendingLineItems = new Map<String, ContendingLineItems>();
        Set<String> dfpOrderLineItemIds = new Set<String>();

        for(csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems) {
            contendingLineItems.put(String.valueOf(fulfilmentItem.Id), new ContendingLineItems());

            if(String.isNotBlank(fulfilmentItem.Contending_Items_Extended__c)) {
                ContendingLineItems currentItems = (ContendingLineItems) JSON.deserialize(fulfilmentItem.Contending_Items_Extended__c, ContendingLineItems.class);
                if(currentItems.contendingLineItems != null) {
                    for(ContendingLineItem cli : currentItems.contendingLineItems) {
                        dfpOrderLineItemIds.add(cli.lineItemId);
                    }

                    contendingLineItems.put(String.valueOf(fulfilmentItem.Id), currentItems);
                }
            }
        }

        if (!dfpOrderLineItemIds.isEmpty()) {
            Map<String, csdf__Fulfilment_Item__c> contendingFulfilmentItems = new Map<String, csdf__Fulfilment_Item__c>();
            for (csdf__Fulfilment_Item__c fulfilmentItem : [
                    SELECT Id, Name, Product_Configuration__r.cscfga__Description__c, csdf__Fulfilment__r.csdf__Name__c,
                            csdf__Fulfilment__r.Sales_Order__r.Name, csdf__Fulfilment__r.Sales_Order__r.csmso__Status__c,
                            Product_Configuration__c, csdf__Status__c, csdf__Type__c, csdf__Flight_Beginning__c,
                            csdf__Flight_End__c, csdf__Rate__c, csdf__Quantity__c, csdf__Ad_Server_Id__c, Flight_Beginning_Line_Item__c, Flight_End_Line_Item__c,
                            csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.Owner.Name,
                            csdf__Fulfilment__r.Sales_Order__r.Bill_To_Account__r.Name,
                            csdf__Fulfilment__r.Sales_Order__r.Sold__c,
                            csdf__Fulfilment__r.Sales_Order__r.SO_Reserved_Flag__c,
                            csdf__Availability_Check_Total_Amount__c, csdf__Availability_Check_Delivery_Amount__c, Reservation_Status__c,
                            New_Line_ID__c, csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__c, csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.Name
                    FROM csdf__Fulfilment_Item__c
                    WHERE csdf__Ad_Server_Id__c IN :dfpOrderLineItemIds
            ]) {
                contendingFulfilmentItems.put(fulfilmentItem.csdf__Ad_Server_Id__c, fulfilmentItem);
            }

            for (ContendingLineItems contendingItems : contendingLineItems.values()) {
                for (ContendingLineItem cli : contendingItems.contendingLineItems) {
                    if (contendingFulfilmentItems.containsKey(cli.lineItemId)) {
                        cli.setValues(contendingFulfilmentItems.get(cli.lineItemId));
                    }
                }
            }
        }

        return contendingLineItems;
    }

    public class ContendingLineItems {
        public Integer totalContendingUnits { get; set; }
        public List<ContendingLineItem> contendingLineItems { get; set; }

        public ContendingLineItems() {
            this.contendingLineItems = new List<ContendingLineItem>();
        }
    }

    public class ContendingLineItem {
        public String lineItemId { get; set; }
        public Decimal contendingImpressions { get; set; }
        public Id fulfilmentItemId { get; set; }
        public String dfpItemName { get; set; }
        public String dfpName { get; set; }
        public String salesOrderId { get; set; }
        public String salesOrderName { get; set; }
        public String salesOrderStatus { get; set; }
        public String configId { get; set; }
        public String status { get; set; }
        public String fulfilmentItemType { get; set; }
        public String startDate { get; set; }
        public String endDate { get; set; }
        public Datetime startDatetime {get; set;}
        public Datetime endDatetime {get; set;}
        public Decimal rate { get; set; }
        public Decimal quantity { get; set; }
        public string adServerLink { get; set; }

        public String fulfilmentItemName { get; set; }
        public String oppOwner { get; set; }
        public String fiAccount { get; set; }
        public Decimal usedPercentage { get; set; }
        public Decimal totalAmount { get; set; }
        public Boolean wasBooked { get; set; }
        public Boolean isReserved { get; set; }

        public String oppName { get; set; }
        public Id oppId { get; set; }
        public String lineItemLineId { get; set; }

        public Date flightBeginDate { get; set; }
        public Date flightEndDate { get; set; }

        public ContendingLineItem() {
            this.adServerLink = 'https://admanager.google.com/70892138#delivery/LineItemDetail/lineItemId=' + lineItemId;
        }

        public void setValues(csdf__Fulfilment_Item__c fulfilmentItem) {
            fulfilmentItemId = fulfilmentItem.Id;
            dfpItemName = fulfilmentItem.Product_Configuration__r.cscfga__Description__c;
            dfpName = fulfilmentItem.csdf__Fulfilment__r.csdf__Name__c;
            salesOrderId = fulfilmentItem.csdf__Fulfilment__r.Sales_Order__c;
            salesOrderName = fulfilmentItem.csdf__Fulfilment__r.Sales_Order__r.Name;
            salesOrderStatus = fulfilmentItem.csdf__Fulfilment__r.Sales_Order__r.csmso__Status__c;
            configId = fulfilmentItem.Product_Configuration__c;
            status = fulfilmentItem.csdf__Status__c;
            fulfilmentItemType = fulfilmentItem.csdf__Type__c;
            startDate = String.valueOf(fulfilmentItem.csdf__Flight_Beginning__c.date());
            startDatetime = fulfilmentItem.csdf__Flight_Beginning__c;
            endDate = String.valueOf(fulfilmentItem.csdf__Flight_End__c.date());
            endDatetime = fulfilmentItem.csdf__Flight_End__c;
            flightBeginDate = fulfilmentItem.Flight_Beginning_Line_Item__c;
            flightEndDate = fulfilmentItem.Flight_End_Line_Item__c;
            rate = fulfilmentItem.csdf__Rate__c;
            quantity = fulfilmentItem.csdf__Quantity__c;

            fulfilmentItemName = fulfilmentItem.Name;
            oppOwner = fulfilmentItem.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.Owner.Name;
            fiAccount = fulfilmentItem.csdf__Fulfilment__r.Sales_Order__r.Bill_To_Account__r.Name;
            totalAmount = fulfilmentItem.csdf__Availability_Check_Total_Amount__c;
            contendingImpressions = fulfilmentItem.csdf__Availability_Check_Delivery_Amount__c != null ? fulfilmentItem.csdf__Availability_Check_Delivery_Amount__c : 0;

            usedPercentage = totalAmount > 0 ? ((1 - (contendingImpressions / totalAmount)) * 100).setScale(2) : 0;
            wasBooked = fulfilmentItem.csdf__Fulfilment__r.Sales_Order__r.Sold__c;
            if(fulfilmentItem.csdf__Fulfilment__r.Sales_Order__r.SO_Reserved_Flag__c == 'Yes' || fulfilmentItem.Reservation_Status__c == 'RESERVED'){
                isReserved = true;
            }

            oppName = fulfilmentItem.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.Name;
            oppId = fulfilmentItem.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__c;
            lineItemLineId = fulfilmentItem.New_Line_ID__c;
        }
    }
}