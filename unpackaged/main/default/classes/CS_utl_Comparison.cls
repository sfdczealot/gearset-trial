/**
 * @name CS_utl_Comparison
 * @description Utility class for comparing values
 * @revision
 *
 */
public class CS_utl_Comparison {
	/**
	 * @name Comparison
	 * @description 
	 * @revision
	 *
	 */
	public enum Comparison {
		LESS_THAN,
		GREATER_THAN,
		EQUALS,
		NOT_EQUALS,
		LESS_THAN_OR_EQUALS,
		GREATER_THAN_OR_EQUALS,
		IS_IN,
		NOT_IN,
		UNKNOWN
	}
	
	/**
	 * Compare booleans
	 * @param a Boolean
	 * @param b Boolean
	 * @return 	Comparison
	 */
	public static Comparison compareBooleans(Boolean a, Boolean b) {
		if (a == b) { 
			return Comparison.EQUALS;
		} else {
			return Comparison.NOT_EQUALS;
		}
	}

	/**
	 * Compare dates
	 * @param a Date
	 * @param b Date
	 * @return 	Comparison
	 */	
	public static Comparison compareDates(Date a, Date b) {
		if (a < b) { 
			return Comparison.LESS_THAN;
		} else if (a == b) {
			return Comparison.EQUALS;
		} else {
			return Comparison.GREATER_THAN;
		}
	}

	/**
	 * Compare times
	 * @param a Time
	 * @param b Time
	 * @return 	Comparison
	 */			
	public static Comparison compareTimes(Time a, Time b) {
		if (a < b) { 
			return Comparison.LESS_THAN;
		} else if (a == b) {
			return Comparison.EQUALS;
		} else {
			return Comparison.GREATER_THAN;
		}
	}

	/**
	 * Compare datetimes
	 * @param a Datetime
	 * @param b Datetime
	 * @return 	Comparison
	 */			
	public static Comparison compareDatetimes(Datetime a, Datetime b) {
		if (a < b) { 
			return Comparison.LESS_THAN;
		} else if (a == b) {
			return Comparison.EQUALS;
		} else {
			return Comparison.GREATER_THAN;
		}
	}

	/**
	 * Compare numbers
	 * @param a Decimal
	 * @param b Decimal
	 * @return 	Comparison
	 */		
	public static Comparison compareNumbers(Decimal a, Decimal b) {
		if (a < b) { 
			return Comparison.LESS_THAN;
		} else if (a == b) {
			return Comparison.EQUALS;
		} else {
			return Comparison.GREATER_THAN;
		}
	}

	/**
	 * Compare ids
	 * @param a Id
	 * @param b Id
	 * @return 	Comparison
	 */		
	public static Comparison compareIds(Id a, Id b) {
		if (a == b) {
			return Comparison.EQUALS;
		} else {
			return Comparison.NOT_EQUALS;
		}
	}
	
	/**
	 * Compare strings
	 * @param a String
	 * @param b String
	 * @return 	Comparison
	 */	
	public static Comparison compareStrings(String a, String b) {
		if (a < b) { 
			return Comparison.LESS_THAN;
		} else if (a == b) {
			return Comparison.EQUALS;
		} else {
			return Comparison.GREATER_THAN;
		} 
	}

	/**
	 * A Comparison for primitive data types
	 * @param first  Object
	 * @param second Object
	 * @return 		 Comparison
	 */
	public static Comparison compare(Object first, Object second) {	
		if (first instanceof Boolean && second instanceof Boolean) {
			return compareBooleans((Boolean)first, (Boolean)second);
		}
		else if (first instanceof Date && second instanceof Date) {
			return compareDates((Date)first, (Date)second);
		}
		else if (first instanceof Datetime && second instanceof Datetime) {
			return compareDatetimes((Datetime)first, (Datetime)second);
		}
		else if (first instanceof Decimal && second instanceof Decimal) {
			return compareNumbers((Decimal)first, (Decimal)second);
		}
		else if (first instanceof Id && second instanceof Id) {
			return compareIds((Id)first, (Id)second);
		}
		else if (first instanceof String && second instanceof String) {
			return compareStrings((String)first, (String)second);
		}
		else if (first instanceof Time && second instanceof Time) {
			return compareTimes((Time)first, (Time)second);
		} else {
			return Comparison.NOT_EQUALS;
		}
	}
	
	/**
	 * A Comparison for contains operation
	 * @param valueSet  Object
	 * @param value 	Object
	 * @return 		 	Boolean
	 */	
	public static Boolean contains(Object valueSet, Object value) {
		if (valueSet instanceof Set<Boolean>) {
			Set<Boolean> validValues = (Set<Boolean>) valueSet;
			return validValues.contains((Boolean) value);
		}
		else if (valueSet instanceof Set<Date>) {
			Set<Date> validValues = (Set<Date>) valueSet;
			return validValues.contains((Date) value);
		}
		else if (valueSet instanceof Set<Decimal>) {
			Set<Decimal> validValues = (Set<Decimal>) valueSet;
			return validValues.contains((Decimal) value);
		}
		else if (valueSet instanceof Set<Double>) {
			Set<Double> validValues = (Set<Double>) valueSet;
			return validValues.contains((Double) value);
		}
		else if (valueSet instanceof Set<Id>) {
			Set<Id> validValues = (Set<Id>) valueSet;
			return validValues.contains((Id) value);
		}
		else if (valueSet instanceof Set<Integer>) {
			Set<Integer> validValues = (Set<Integer>) valueSet;
			return validValues.contains((Integer) value);
		}
		else if (valueSet instanceof Set<Long>) {
			Set<Long> validValues = (Set<Long>) valueSet;
			return validValues.contains((Long) value);
		}
		else if (valueSet instanceof Set<String>) {
			Set<String> validValues = (Set<String>) valueSet;
			return validValues.contains((String) value);
		}
		
		throw new ComparisonException('Object type is not supported.');
	}
	
	public class ComparisonException extends Exception {}
}