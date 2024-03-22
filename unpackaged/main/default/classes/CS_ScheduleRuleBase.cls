/**
* ─────────────────────────────────────────────────────────────────────────────────────────────────┐
* Description :  Schedule Rule base class
* ──────────────────────────────────────────────────────────────────────────────────────────────────
* @author        Sasa Marjancic   <sasa.marjancic@cloudsensesolutions.com>
* ──────────────────────────────────────────────────────────────────────────────────────────────────
*/
public abstract class CS_ScheduleRuleBase {
	public static CS_ScheduleRuleBase instantiate(String className) {
        Type t = Type.forName(className);
        CS_ScheduleRuleBase instance = (CS_ScheduleRuleBase) t.newInstance();
        
        return instance;	
	}
	
    /**
     * Returns a list of schedule lines based on date strategy and schedule information
     * @param startDate 	  	 Date
     * @param endDate 		  	 Date
     * @param contractedQuantity Decimal
     * @param cappedQuantity  	 Decimal
     * @param bookedQuantity     Decimal
     * @param flightBegin 	  	 Date
     * @param flightEnd   	  	 Date
     * @param configId		  	 Id
     * @param salesOrderId	  	 Id
     * @param price 		  	 Decimal
     * @param unitPrice 	  	 Decimal
     * @param dateStrategy	  	 String
     * @return 				  	 List<ScheduleLine>
     */
	public abstract List<ScheduleLine> getScheduleLines(Date startDate, Date endDate, Decimal contractedQuantity, Decimal cappedQuantity,
														Decimal bookedQuantity, Date flightBegin, Date flightEnd, Id configId, Id salesOrderId,
														Decimal price, Decimal unitPrice, String dateStrategy);
                                       
    /**
     * Sets Schedule object records based on ScheduleLine and SObject
     * @param line 				ScheduleLine
     * @param sObj 				SObject
     * @param schedulineLineMap Map<String, String> 
     * @return             
     */
	public abstract SObject setSObject(ScheduleLine line, SObject sObj, Map<String, String> schedulineLineMap);
                                                        
	/**
	 * Class used to define schedule lines
	 */
    public class ScheduleLine {
    	public Date scheduleDate {get; set;}
    	public Date startDate {get; set;}
    	public Date endDate {get; set;}
    	public Integer contractedQuantity {get; set;}
    	public Integer scheduledQuantity {get; set;}
    	public Integer forecastQuantity {get; set;}
		public Integer bookedQuantity {get; set;}
    	public Date flightBegin {get; set;}
        public Date flightEnd {get; set;}
        public Id productConfigId {get; set;}
        public Id salesOrderId {get; set;}
        public Decimal totalPrice {get; set;}
        public Decimal unitPrice {get; set;}
        public Decimal amount {get; set;}
        
        public ScheduleLine(Date scheduleDate, Date startDate, Date endDate, Integer contractedQuantity, Integer scheduledQuantity, Integer forecastQuantity,
        					Integer bookedQuantity, Date flightBegin, Date flightEnd, Id configId, Id salesOrderId, Decimal totalPrice, Decimal unitPrice, Decimal amount) {
        	this.scheduleDate = scheduleDate;
        	this.startDate = startDate;
        	this.endDate = endDate;
        	this.contractedQuantity = contractedQuantity;
        	this.scheduledQuantity = scheduledQuantity;
        	this.forecastQuantity = forecastQuantity;
			this.bookedQuantity = bookedQuantity;
        	this.flightBegin = flightBegin;
        	this.flightEnd = flightEnd;
        	this.productConfigId = configId;
        	this.salesOrderId = salesOrderId;
        	this.totalPrice = totalPrice;
        	this.unitPrice = unitPrice;
        	this.amount = amount;
        }
    }
}