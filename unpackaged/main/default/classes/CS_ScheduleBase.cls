/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description :  Abstract class to handle operations on schedules
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public abstract class CS_ScheduleBase {
    /**
     * Existing schedules used for operations
     */
    public List<SObject> existingSchedules {get; set;}
    
    /**
     * Product Configuration used to handle schedules
     */
    public cscfga__Product_Configuration__c config {get; set;}
    
    /**
     * List of handled schedules
     */
    public List<SObject> schedules {
        get {
            if(schedules == null) {
                
                schedules = new List<SObject>();
            }
            return schedules;
        }
        set;
    }
    
    /**
     * Contains schedules mapped by date
     */
    public Map<Date, SObject> schedulesByDate {
        get {
            if(schedulesByDate == null) {
                schedulesByDate = new Map<Date, SObject>();
                if(existingSchedules != null) {
                    for(SObject schedule : existingSchedules) {
                        schedulesByDate.put(getScheduleStartDate(schedule), schedule);
                    }
                }
            }
            return schedulesByDate;
        }
        set;
    }
    
    /**
     * Billing Schedule rule used to handle actions
     */
    public Billing_Schedule_Rule__c scheduleRule {
        get {
            if(scheduleRule == null) {
                scheduleRule = getScheduleRule(config);
            }
            return scheduleRule;
        }
        set;
    }
    
    /**
     * Schedule mappings
     */
    private List<PropertyMappingEngine.FieldMappingPair> scheduleMappings {
        get {
            if(scheduleMappings == null) {
                scheduleMappings = new List<PropertyMappingEngine.FieldMappingPair>();
            }
            
            return scheduleMappings;
        }
        set;
    }

    /**
     * Returns start date for schedule
     * @param  obj SObject
     * @return     Date
     */ 
    public abstract Date getScheduleStartDate(SObject obj);
    
    /**
     * Returns end date for schedule
     * @param  obj SObject
     * @return     Date
     */ 
    public abstract Date getScheduleEndDate(SObject obj);
    
    /**
     * Returns billing schedule rule for schedule
     * @param  obj SObject
     * @return     Billing_Schedule_Rule__c
     */     
    public abstract Billing_Schedule_Rule__c getScheduleRule(SObject obj);
    
    /**
     * Returns a schedule mapping
     * @return Map<String, String>
     */
    public abstract Map<String, String> getScheduleMapping();
    
    /**
     * Gets a start date based on Product Configuration and Parent Schedule
     * @param productConfig cscfga__Product_Configuration__c
     * @param parent        SObject
     * @return              Date
     */ 
    public Date getStartDate(cscfga__Product_Configuration__c productConfig, SObject parent) {
        return parent.get('Last_Closed_Period_End__c') != null ? Date.valueOf(parent.get('Last_Closed_Period_End__c')).addDays(1) : Date.valueof(productConfig.Flight_Begin__c);
    }
    
    /**
     * Get remaining quantity based on Product Configuration and Parent Schedule
     * @param productConfig cscfga__Product_Configuration__c
     * @param parent        SObject
     * @return              Decimal
     */     
    public Decimal getQuantity(cscfga__Product_Configuration__c productConfig, SObject parent) {
        return productConfig.Insertion_Quantity__c - CS_utl_SObject.getDecimalValue('Total_Closed_Quantity_To_Date__c', parent);
    }

    /**
     * Get remaining booked quantity based on Product Configuration and Parent Schedule
     * @param productConfig cscfga__Product_Configuration__c
     * @param parent        SObject
     * @return              Decimal
     */
    public Decimal getBookedQuantity(cscfga__Product_Configuration__c productConfig, SObject parent) {
        return productConfig.Insertion_Quantity__c - CS_utl_SObject.getDecimalValue('Total_Closed_Booked_Quantity__c', parent);
    }
    
    /**
     * Checks if there is an active Bill Run for given Calendar Type and Flight Begin
     * @param config     cscfga__Product_Configuration__c
     * @param scheduleObject   String
     * @param periodDate Date
     * @return           Boolean
     */ 
    public Bill_Run__c hasActiveBillRun(cscfga__Product_Configuration__c config, String scheduleObject, Date periodDate) {
        for(Bill_Run__c billRun : CS_utl_Schedule.billRuns) {
            if(CS_utl_Schedule.isApplicable(billRun, scheduleObject, config)) {
                if(billRun.Billing_Date__c >= periodDate) {
                    return billRun;
                }
            }
        }
        
        return null;
    }
    
    /**
     * Get the status for Schedules based on Product Configuration
     * @param schedule       SObject
     * @param newSchedule    SObject
     * @param config         cscfga__Product_Configuration__c
     * @param periodDate     Date
     * @param scheduleObject String
     * @return               String
     */
    public String getStatus(SObject schedule, SObject newSchedule, cscfga__Product_Configuration__c config, Date periodDate, String scheduleObject) {
        if(schedule != null && schedule.get('Status__c') == CS_const_SalesOrder.ScheduleStatus_Cancelled) {
            return CS_const_SalesOrder.ScheduleStatus_Cancelled;
        }
        else if(schedule != null && schedule.get('Status__c') == CS_const_SalesOrder.ScheduleStatus_PendingClosure) {
            return CS_const_SalesOrder.ScheduleStatus_Closed;
        }
        else if(schedule != null && (schedule.get('Status__c') == CS_const_SalesOrder.ScheduleStatus_Closed
            || schedule.get('Status__c') == CS_const_SalesOrder.ScheduleStatus_Locked || schedule.get('Status__c') == CS_const_SalesOrder.ScheduleStatus_Ready
            || schedule.get('Status__c') == CS_const_SalesOrder.ScheduleStatus_Pending)) {
            return String.valueOf(schedule.get('Status__c'));
        }
        else if(CS_utl_SalesOrder.isInProgress(config.Sales_Order__r) && !CS_utl_SalesOrder.isRetracted(config.Sales_Order__r)) {
            return CS_const_SalesOrder.ScheduleStatus_Forecast;
        }
        else if(hasActiveBillRun(config, scheduleObject, periodDate) != null) {
            newSchedule.put('Bill_Run__c', hasActiveBillRun(config, scheduleObject, periodDate).Id);
            return CS_const_SalesOrder.ScheduleStatus_Locked;
        }
        
        return CS_const_SalesOrder.ScheduleStatus_Open;
    }
    
    /**
     * Do Property Mapping for Schedules
     * @param configs List<cscfga__Product_Configuration__c>
     * @return        List<SObject>
     */
    
    @TestVisible
    private SObject addScheduleMapping(SObject existingSchedule, SObject schedule) {
        if(existingSchedule != null) {
            scheduleMappings.add(new PropertyMappingEngine.FieldMappingPair(existingSchedule, new List<SObject>{schedule}));
        }
        
        return schedule;
    }
    
    @TestVisible
    private List<SObject> doScheduleMapping() {
        List<SObject> result = new List<SObject>();
        CS_Custom_Settings__c customSettings = CS_Custom_Settings__c.getInstance();
        
        if(!scheduleMappings.isEmpty()) {
            result.addAll(PropertyMappingEngine.mapsObjectFields(customSettings.Schedule_Item_Map__c, scheduleMappings));
        }
        
        return result;
    }

    /**
    * Updates schedules where "Valid for Auto-Cancellation" flag is set to True setting their statuses to 'Cancelled'
    * @param config            cscfga__Product_Configuration__c
    * @param existingSchedules List<SObject>
    * @return                  List<SObject>
    */ 
    public List<SObject> autoCancelSchedules(cscfga__Product_Configuration__c config, List<SObject> schedules) {
        List<SObject> schedulesToUpdate = new List<SObject>();
		if (schedules != null) {
			for (SObject schedule : schedules) {
				if ((Boolean)schedule.get('Valid_for_Auto_Cancellation__c')
					&& getScheduleStartDate(schedule) < config.Flight_Begin__c) {

					schedule.put('Status__c', CS_const_SalesOrder.ScheduleStatus_Cancelled);
                    String status = CS_utl_SObject.getFieldValue(schedule, 'Status__c');
                    if(status == CS_const_BillingScheduleItem.Status_PendingClosure || status == CS_const_BillingScheduleItem.Status_Closed) {
                        schedule.put('Cancelled_after_Closing__c', true);
                    }
					schedulesToUpdate.add(schedule);
				}
			}
		}
        return schedulesToUpdate;
    }
    
    /**
     * Creates Schedule Items
     * @param config            cscfga__Product_Configuration__c
     * @param parent            SObject
     * @param existingSchedules List<SObject>
     * @return                  List<SObject>
     */
    public List<SObject> createSchedules(cscfga__Product_Configuration__c config, SObject parent,
                                         List<SObject> existingSchedules) {
        this.config = config;
        this.existingSchedules = existingSchedules;
        CS_Custom_Settings__c customSettings = CS_Custom_Settings__c.getInstance();

        CS_ScheduleRuleBase scheduleRuleInstance = CS_ScheduleRuleBase.instantiate(scheduleRule.Digital_Calculation_Class__c);
        
        if (getStartDate(config, parent) <= config.Flight_End__c) {
            List<CS_ScheduleRuleBase.ScheduleLine> scheduleLines = scheduleRuleInstance.getScheduleLines(
                getStartDate(config, parent), config.Flight_End__c, config.Insertion_Quantity__c, getQuantity(config, parent), getBookedQuantity(config, parent), config.Flight_Begin__c,
                config.Flight_End__c, config.Id, config.Sales_Order__c, config.Net_Cost__c, config.Cost_Adjustment_Applied__c ? 0 : config.Net_Rate_Final__c, scheduleRule.Digital_Date_Strategy_Class__c
            );
            
            for(CS_ScheduleRuleBase.ScheduleLine line : scheduleLines) {
                SObject existingSchedule = schedulesByDate.get(line.startDate);
                SObject schedule = scheduleRuleInstance.setSObject(line, (SObject) Type.forName(scheduleRule.Schedule_Object__c).newInstance(), getScheduleMapping());
                addScheduleMapping(existingSchedule, schedule);
                schedule.put('Status__c', getStatus(existingSchedule, schedule, config, line.endDate, scheduleRule.Schedule_Object__c));
                Schema.DescribeFieldResult dfr = CS_utl_SObject.getRelationshipField(parent.getSObjectType(), schedule.getSObjectType());
                schedule.put(dfr.getName(), parent.Id);
                schedule.putSObject(dfr.getRelationshipName(), parent);
                schedules.add(schedule);
            }
            
            doScheduleMapping();
        }
        
        return schedules;
    }
    
    /**
     * Updates Schedule Items
     * @param config            cscfga__Product_Configuration__c
     * @param parent            SObject
     * @param existingSchedules List<SObject>
     * @return                  List<SObject>
     */ 
    public List<SObject> updateSchedules(cscfga__Product_Configuration__c config, SObject parent,
                                         List<SObject> existingSchedules) {
        this.config = config;
        this.existingSchedules = existingSchedules;
        
        try {
            if(existingSchedules != null) {
                SObject lastSchedule;
                for(SObject existingSchedule : existingSchedules) {
                    lastSchedule = lastSchedule == null ? existingSchedule : (getScheduleStartDate(lastSchedule) < getScheduleStartDate(existingSchedule) ? existingSchedule : lastSchedule);
                    if(getScheduleEndDate(existingSchedule) < getStartDate(config, parent)) {
                        existingSchedule.put('Status__c', getStatus(existingSchedule, existingSchedule, config, getScheduleEndDate(existingSchedule), scheduleRule.Schedule_Object__c));
                        schedules.add(existingSchedule);
                    }
                }
                lastSchedule = lastSchedule == null ? existingSchedules.get(0) : lastSchedule;
                
                if(getStartDate(config, parent) < (Date) lastSchedule.get('Flight_End__c')) {
                    CS_ScheduleRuleBase scheduleRuleInstance = CS_ScheduleRuleBase.instantiate(scheduleRule.Digital_Calculation_Class__c);
                    List<CS_ScheduleRuleBase.ScheduleLine> scheduleLines = scheduleRuleInstance.getScheduleLines(
                        getStartDate(config, parent),(Date) lastSchedule.get('Flight_End__c'), (Decimal) lastSchedule.get('Contracted_Quantity__c'),
                        ((Decimal) lastSchedule.get('Contracted_Quantity__c')) - CS_utl_SObject.getDecimalValue('Total_Closed_Quantity_To_Date__c', parent),
                        getBookedQuantity(config, parent), (Date) lastSchedule.get('Flight_Begin__c'),
                        (Date) lastSchedule.get('Flight_End__c'), config.Id, config.Sales_Order__c, (Decimal) lastSchedule.get('Total_Price__c'),
                        (Decimal) lastSchedule.get('Net_Rate__c'), scheduleRule.Digital_Date_Strategy_Class__c
                    );
                    for(CS_ScheduleRuleBase.ScheduleLine line : scheduleLines) {
                        SObject existingSchedule = schedulesByDate.get(line.startDate);
                        existingSchedule.put('Forecast_Quantity__c', line.forecastQuantity);
                        schedules.add(existingSchedule);
                    }
                }
            }
            
            return schedules;
        }
        catch (Exception e) {
            throw new ScheduleException('Error updating schedules. Please make sure the dates on the existing schedules are correct.');
        }
    }
    
    public class ScheduleException extends Exception {}
}