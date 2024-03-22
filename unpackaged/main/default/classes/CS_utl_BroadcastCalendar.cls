/**
 * @name CS_utl_BroadcastCalendar
 * @description Utility methods for Broadcast Calendar
 * @revision
 *
 */
public class CS_utl_BroadcastCalendar {
	/**
	 * Contains all broadcast calendars
	 */
	@TestVisible
	private static List<Broadcast_Calendar__c> broadcastCalendars {
		get {
			if(broadcastCalendars == null) {
				broadcastCalendars = [SELECT Start_Date__c, End_Date__c
									  FROM Broadcast_Calendar__c
									  WHERE (Start_Date__c >= :startDate AND End_Date__c <= :endDate)
									  OR (Start_Date__c <= :startDate AND End_Date__c >= :startDate)
									  OR (Start_Date__c <= :endDate AND End_Date__c >= :endDate)
									  ORDER BY Start_Date__c];
			}
			
			return broadcastCalendars;
		}
		set;
	}
	
	/**
	 * Start date
	 */	
	public static Date startDate {get; set;}
	
	/**
	 * End date
	 */
	public static Date endDate {get; set;}
	
    /**
     * Initializes the class
     * @param startDate Date
     * @param endDate   Date
     */
	public static void init(Date startDate, Date endDate) {
		CS_utl_BroadcastCalendar.startDate = startDate;
		CS_utl_BroadcastCalendar.endDate = endDate;
		broadcastCalendars = null;
	}
	
    /**
     * Returns a list of broadcast calendars based on start and end date
     * @param startDate Date
     * @param endDate   Date
     * @return          List<Broadcast_Calendar__c>
     */
	public static List<Broadcast_Calendar__c> getBroadcastCalendars(Date startDate, Date endDate) {
		List<Broadcast_Calendar__c> bCalendars = new List<Broadcast_Calendar__c>();
		
		for(Broadcast_Calendar__c bCalendar : CS_utl_BroadcastCalendar.broadcastCalendars) {
			if(isApplicable(bCalendar, startDate, endDate)) {
				bCalendars.add(bCalendar);
			}
		}
		
		return bCalendars;
	}
	
    /**
     * Checks if broadcast calendar is applicable for given date range
     * @param bCalendar Broadcast_Calendar__c
     * @param startDate Date
     * @param endDate   Date
     * @return          Boolean
     */
	@TestVisible
	private static Boolean isApplicable(Broadcast_Calendar__c bCalendar, Date startDate, Date endDate) {
		return (bCalendar.Start_Date__c >= startDate && bCalendar.End_Date__c <= endDate) ||
			   (bCalendar.Start_Date__c <= startDate && bCalendar.End_Date__c >= startDate) ||
			   (bCalendar.Start_Date__c <= endDate && bCalendar.End_Date__c >= endDate);
	}
}