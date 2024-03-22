public with sharing class CS_DateUtils {
	public CS_DateUtils() {
	}

	// inputDate format 'YYYY-MM-DD hh-mm-ss timeZone'
	public static Datetime getGMTTimeForTimezone(String inputDate) {
		Datetime outputDatetime = null;
		if(String.isNotBlank(inputDate)) {
			List<String> inputDateTime = inputDate.split(' ');
			if(inputDateTime.size() == 3) {
				List<String> dmy = inputDateTime[0].split('-');
				List<String> hm = inputDateTime[1].split(':');
		
				String inputcustomTimezone = inputDateTime[2];
				Datetime dt = Datetime.newInstanceGmt(Integer.valueOf(dmy[0]), Integer.valueOf(dmy[1]), Integer.valueOf(dmy[2]), Integer.valueOf(hm[0]), Integer.valueOf(hm[1]), 0); // seconds are zeroed
				Timezone tz = Timezone.getTimeZone(inputcustomTimezone);
		
				//Calculate offset in hours and minutes (Round hours to DOWN)
				Decimal timezoneOffsetHoursDecimal = Decimal.valueOf(hm[0]) - Decimal.valueOf(tz.getOffset(dt))/3600/1000;
				Integer timezoneOffsetHours = Integer.valueOf(timezoneOffsetHoursDecimal.round(System.RoundingMode.DOWN));
				Integer timezoneOffsetMinutes = Integer.valueOf((timezoneOffsetHoursDecimal - Integer.valueOf(timezoneOffsetHoursDecimal)) * 60) + Integer.valueOf(hm[1]);
		
				return Datetime.newInstanceGmt(Integer.valueOf(dmy[0]), Integer.valueOf(dmy[1]), Integer.valueOf(dmy[2]), timezoneOffsetHours, timezoneOffsetMinutes, 0); // seconds are zeroed
			}
		}
	
		return null;
	}

	/**
   * @description Parses date time string value to Force.com DateTime type. Expected input format 'dd/MM/yyyy hh:mm' or 'yyyy-MM-dd hh:mm'.
   * @param attributeValue string input in format 'dd/MM/yyyy hh:mm'
   * @response Force.com DateTime object
   */
	public static DateTime parseDateTime(String attributeValue) {
	    List<String> dateTimeParts = attributeValue.split(' ');
	    String datePart = dateTimeParts[0];
	    String timePart = dateTimeParts[1];
	    Integer year;
	    Integer month;
	    Integer day;
	    Integer monthIdx, dayIdx;

	    List<String> dateParts;
	    List<String> timeParts = timePart.split(':');

	    Date d = Date.newInstance(2017, 01, 31);
	    String f = d.format();

	    if (f == '31/01/2017') {
			monthIdx = 1;
			dayIdx = 0;
	    } else {
			monthIdx = 0;
			dayIdx = 1;
	    }

	    if (datePart.indexOf('-') > -1) {
			dateParts = datePart.split('-');
			year = Integer.valueOf(dateParts[0]);
			month = Integer.valueOf(dateParts[1]);
			day = Integer.valueOf(dateParts[2]);
	    } else {
			dateParts = datePart.split('/');
			year = Integer.valueOf(dateParts[2]);
			month = Integer.valueOf(dateParts[monthIdx]);
			day = Integer.valueOf(dateParts[dayIdx]);
	    }

	    DateTime dt = DateTime.newInstanceGMT(year, month, day, Integer.valueOf(timeParts[0]), Integer.valueOf(timeParts[1]), 0);
	    return dt;
  	}
}