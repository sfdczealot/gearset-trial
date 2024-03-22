global without sharing class CS_LineCalendarWidgetController {
    global String salesOrderId {
        get {
            return ApexPages.currentPage().getParameters().get('salesOrderId');
        }
        set;
    }

    @RemoteAction
    global static String getMarkets(String parameters) {
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(parameters);

        Integer offset = (Integer.valueOf(params.get('page')) - 1) * 10;
        String queryString = '%' + String.valueOf(params.get('term')) + '%';
        return JSON.serialize([SELECT Id, Name
        FROM csmso__Product_Node__c
        WHERE Name Like :queryString Limit 10 Offset :offset]);
    }

    @RemoteAction
    global static String getProducts(String parameters) {
        Map<String, Object> params = (Map<String, Object>) JSON.deserializeUntyped(parameters);

        Integer offset = (Integer.valueOf(params.get('page')) - 1) * 10;
        String queryString = '%' + String.valueOf(params.get('term')) + '%';
        return JSON.serialize([SELECT Id, Name
        FROM csmso__Node_Advert_Assignment__c
        WHERE Line_Item_Type__c = 'Sponsorship'
        AND Name Like :queryString Limit 10 Offset :offset]);
    }

    @RemoteAction
    global static Boolean getUserProfile() {
        Id profileId = UserInfo.getProfileId();
        String profileName = [
                SELECT Name
                FROM Profile
                WHERE Id = :profileId
        ].Name;
        List<String> calendarWidgetPopupDisabledProfiles = SO_CalendarWidget_Details__c.getInstance().Hoover_box_disable_profiles__c.split(',');
        if(calendarWidgetPopupDisabledProfiles.contains(profileName)){
            return false;
        }
        return true;

    }

    @RemoteAction
    global static String poll(String parameters) {
        Set<Id> fulfilmentItemIds = (Set<Id>) JSON.deserialize(parameters, Set<Id>.class);
        List<SponsorshipCalendarResult> result = new List<SponsorshipCalendarResult>();
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Name, csdf__Fulfilment__c, csdf__Availability_Check_Status__c, csdf__Flight_Beginning__c,
                csdf__Flight_End__c, csdf__Availability_Check_Delivery_Amount__c, Booking_Timezone__c,
                csdf__Availability_Check_Available_Amount__c, Flight_Beginning_Date_YYYY_MM_DD__c, Flight_End_Date_YYYY_MM_DD__c,
                csdf__Availability_Check_Total_Amount__c, Contending_Items_Extended__c
        FROM csdf__Fulfilment_Item__c WHERE Id in :fulfilmentItemIds]);
        Set<Id> completedFulfilmentItems = new Set<Id>();
        for(csdf__Fulfilment_Item__c fulfilmentItem : fulfilmentItems.values()) {
            if (fulfilmentItem.csdf__Availability_Check_Status__c == 'Completed') {
                completedFulfilmentItems.add(fulfilmentItem.Id);
            } else if (fulfilmentItem.csdf__Availability_Check_Status__c.contains('Error')) {
                completedFulfilmentItems.add(fulfilmentItem.Id);
            }
        }

        if(!completedFulfilmentItems.isEmpty()) {
            Map<String, CS_ContendingLineItemsService.ContendingLineItems> contendingItems = CS_ContendingLineItemsService.getContendingItems(completedFulfilmentItems);

            for(Id fulfilmentItemId : completedFulfilmentItems) {
                CS_ContendingLineItemsService.ContendingLineItems items = contendingItems.get(fulfilmentItemId);
                csdf__Fulfilment_Item__c fulfilmentItem = fulfilmentItems.get(fulfilmentItemId);

                for(CS_ContendingLineItemsService.ContendingLineItem item : items.contendingLineItems) {


                    if(item.startDatetime != null) {
                        //item.startDate = String.valueOf(item.startDatetime.addHours(getOffset(fulfilmentItem.Booking_Timezone__c, item.startDatetime)).date());
                        item.startDate = String.valueOf(item.flightBeginDate);
                    }
                    if(item.endDateTime != null) {
                        //item.endDate = String.valueOf(item.endDateTime.addHours(getOffset(fulfilmentItem.Booking_Timezone__c, item.endDateTime)).date().addDays(1));
                        item.endDate = String.valueOf(item.flightEndDate.addDays(1));
                    }

                }

                result.add(new SponsorshipCalendarResult(fulfilmentItem, items));
            }
        }

        if(completedFulfilmentItems.size() == fulfilmentItems.keySet().size()) {
            return JSON.serialize(result);
        }

        return JSON.serialize('');
    }

    @RemoteAction
    global static String deleteItems(String parameters) {
        Set<Id> fulfilmentItemIds = (Set<Id>) JSON.deserialize(parameters, Set<Id>.class);
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Name, csdf__Fulfilment__c, csdf__Availability_Check_Status__c, csdf__Flight_Beginning__c,
                csdf__Flight_End__c, csdf__Availability_Check_Delivery_Amount__c,
                csdf__Availability_Check_Available_Amount__c, Flight_Beginning_Date_YYYY_MM_DD__c, Flight_End_Date_YYYY_MM_DD__c,
                csdf__Availability_Check_Total_Amount__c, Contending_Items_Extended__c
        FROM csdf__Fulfilment_Item__c WHERE Id in :fulfilmentItemIds]);
        delete fulfilmentItems.values();

        return JSON.serialize('');
    }

    public static Integer getOffset(String tz, Datetime targetDate) {
        return TimeZone.getTimeZone(tz).getOffset(targetDate) / (1000 * 60 * 60);
    }

    @RemoteAction
    global static String performAction(String parameters) {
        SponsorshipCalendarAttributes payload = (SponsorshipCalendarAttributes) JSON.deserialize(parameters, SponsorshipCalendarAttributes.class);
        List<CS_FulfilmentService.DigitalFulfilmentAttributes> fulfilmentAttributes = payload.createFulfilmentPayload();

        delete [SELECT Id FROM csdf__Fulfilment_Item__c WHERE csdf__Fulfilment__r.Sales_Order__c = :payload.salesOrderId AND Product_Configuration__c = null];

        CS_FulfilmentService fulfilmentService = new CS_FulfilmentService(fulfilmentAttributes, true);
        List<csdf__Fulfilment_Item__c> fulfilmentItems = fulfilmentService.generateFulfilmentItems();

        for(csdf__Fulfilment_Item__c fi : fulfilmentItems) {
            fi.csdf__Availability_Check_Status__c = 'Waiting';
        }
        update fulfilmentItems;

        CS_FulfilmentWorker.prepareWork('Fulfilment Item Availability Check', fulfilmentItems.get(0).csdf__Fulfilment__c, new Map<Id, csdf__Fulfilment_Item__c>(fulfilmentItems).keySet());

        return JSON.serialize(new Map<Id, csdf__Fulfilment_Item__c>(fulfilmentItems).keySet());
    }

    public class SponsorshipCalendarAttributes {
        public String startDate {get; set;}
        public String endDate {get; set;}
        public Id market {get; set;}
        public Id nodeAdvertAssignment {get; set;}
        public Id salesOrderId {get; set;}

        public String getStartTime() {
            return '00:00';
        }

        public String getEndTime() {
            return '23:59';
        }

        public Integer getDaysBetween() {
            return Date.valueOf(startDate).daysBetween(Date.valueOf(endDate)) + 1;
        }

        public String getOffsetDate(Integer offset) {
            return String.valueOf(Date.valueOf(startDate).addDays(offset));
        }

        public csmso__Node_Advert_Assignment__c getNodeAdvertAssignment() {
            return [SELECT Id, Name, Ad_Type__c, Ad_Slot__c, Ad_Server__c, Browsers__c, Device_Categories__c, Key_values_and_Audience__c, Rate_Type__c,
                    Inventory_Sizes__c, Priority__c, Line_Item_Type__c,
                    Mobile_Devices__c, Operating_Systems__c, Operating_System_Versions__c, Product_Name__c, Product_Type__c, Served_by__c
            FROM csmso__Node_Advert_Assignment__c
            WHERE Id = :this.nodeAdvertAssignment
            LIMIT 1];
        }

        public csmso__Product_Node__c getMarket() {
            return [SELECT Id, Name, Sponsorship_Booking_Timezone__r.Name, Geo_Targeting__c
            FROM csmso__Product_Node__c
            WHERE Id = :this.market
            LIMIT 1];
        }

        public List<CS_FulfilmentService.DigitalFulfilmentAttributes> createFulfilmentPayload() {
            List<CS_FulfilmentService.DigitalFulfilmentAttributes> fulfilmentAttributes = new List<CS_FulfilmentService.DigitalFulfilmentAttributes>();
            csmso__Product_Node__c market = this.getMarket();
            csmso__Node_Advert_Assignment__c nodeAdvertAssignment = this.getNodeAdvertAssignment();

            for(Integer i = 0; i < this.getDaysBetween(); i++) {
                CS_FulfilmentService.DigitalFulfilmentAttributes fulfilmentAttribute = new CS_FulfilmentService.DigitalFulfilmentAttributes();
                fulfilmentAttribute.salesOrderId = this.salesOrderId;
                fulfilmentAttribute.itemName = nodeAdvertAssignment.Product_Name__c;
                fulfilmentAttribute.type = nodeAdvertAssignment.Line_Item_Type__c;
                fulfilmentAttribute.servedBy = nodeAdvertAssignment.Served_by__c;
                fulfilmentAttribute.bookingTimezone = market.Sponsorship_Booking_Timezone__r.Name;
                fulfilmentAttribute.inputFlightBegin = this.getOffsetDate(i);
                fulfilmentAttribute.inputFlightEnd = this.getOffsetDate(i);
                fulfilmentAttribute.inputStartTime = this.getStartTime();
                fulfilmentAttribute.inputEndTime = this.getEndTime();
                fulfilmentAttribute.SOV = String.valueOf(100);
                fulfilmentAttribute.quantity = 1;
                fulfilmentAttribute.customKeyTargeting = nodeAdvertAssignment.Key_values_and_Audience__c;
                fulfilmentAttribute.geoItemsIncludedExcludedString = 'INCLUDE:' + market.Geo_Targeting__c +';EXCLUDE:;';
                fulfilmentAttribute.adSlotIdsIncludedExcludedString = nodeAdvertAssignment.Ad_Slot__c;
                fulfilmentAttribute.browsersIncludedExcludedString = nodeAdvertAssignment.Browsers__c;
                fulfilmentAttribute.deviceCategoryIncludedExcludedString = nodeAdvertAssignment.Device_Categories__c;
                fulfilmentAttribute.mobileDevicesIncludedExcludedString = nodeAdvertAssignment.Mobile_Devices__c;
                fulfilmentAttribute.operatingSystemsIncludedExcludedString = nodeAdvertAssignment.Operating_Systems__c;
                fulfilmentAttribute.operatingSystemVersionsIncludedExcludedString = nodeAdvertAssignment.Operating_System_Versions__c;
                fulfilmentAttribute.sizes = nodeAdvertAssignment.Inventory_sizes__c;
                fulfilmentAttribute.billingCategory = nodeAdvertAssignment.Rate_Type__c;
                fulfilmentAttribute.priority = String.valueOf(nodeAdvertAssignment.Priority__c);

                fulfilmentAttributes.add(fulfilmentAttribute);
            }

            return fulfilmentAttributes;
        }
    }

    public class SponsorshipCalendarResult {
        public String startDate {get; set;}
        public String endDate {get; set;}
        public Decimal availableAmount {get; set;}
        public Decimal totalAmount {get; set;}
        public Decimal usedAmount {get; set;}
        public Decimal deliverableAmount {get; set;}
        public Boolean inventoryAvailable {get; set;}
        public Boolean error {get; set;}
        public CS_ContendingLineItemsService.ContendingLineItems contendingLineItems {get; set;}

        public SponsorshipCalendarResult(csdf__Fulfilment_Item__c fulfilmentItem, CS_ContendingLineItemsService.ContendingLineItems contendingLineItems) {
            this.startDate = String.valueOf(fulfilmentItem.Flight_Beginning_Date_YYYY_MM_DD__c);
            this.endDate = String.valueOf(fulfilmentItem.Flight_End_Date_YYYY_MM_DD__c);
            this.availableAmount = fulfilmentItem.csdf__Availability_Check_Available_Amount__c;
            this.totalAmount = fulfilmentItem.csdf__Availability_Check_Total_Amount__c;
            this.deliverableAmount = fulfilmentItem.csdf__Availability_Check_Delivery_Amount__c;
            this.usedAmount = this.totalAmount > 0 ? ((1 - (this.deliverableAmount / this.totalAmount)) * 100).setScale(2) : 0;
            this.inventoryAvailable = this.deliverableAmount >= this.totalAmount && this.deliverableAmount != 0;
            this.error = fulfilmentItem.csdf__Availability_Check_Status__c.contains('Error');
            this.contendingLineItems = contendingLineItems;
        }
    }
}