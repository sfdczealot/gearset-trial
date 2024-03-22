/**
 * @name CS_utl_Array
 * @description Utility class for lists and sets
 * @revision
 *
 */
public class CS_utl_Array {
    /**
     * Default separator
     */
    public static final String DEFAULT_SEPARATOR = ';';

    /**
     * Join list of Strings to String separated by DEFAULT_SEPARATOR
     * @param  values
     * @return String
     */
    public static String join(List<Object> values) {
        return join(values, DEFAULT_SEPARATOR);
    }
    
    /**
     * Join list of Strings to String separated by given separator
     * @param  values
     * @param  separator
     * @return String
     */
    public static String join(List<Object> values, String separator) {
        String ret = '';

        if(values != null){
            for(Object s : values) {
                ret += String.valueOf(s) + separator;
            }
        }

        return (String.isBlank(ret)) ? ret : ret.substring(0, ret.length() - separator.length());
    }

    /**
     * Remove blank values for a given list of strings
     * @param  values List<String>
     * @return        List<String>
     */
    public static List<String> removeBlanks(List<String> values) {
        Integer i = 0;
        while(i < values.size()) {
            if(String.isBlank(values[i])) {
                values.remove(i);
            }
            else {
                i++;
            }
        }

        return values;
    }
    
    /**
     * Plucks field values from records into a list
     * @param  records List<SObject>
     * @param  field   Schema.SObjectField
     * @return         Object
     */
    public static List<Object> pluck(List<SObject> records, Schema.SObjectField field) {
        List<Object> results = (List<Object>) CS_utl_Type.getListInstance(field.getDescribe().getType().name());
        for (SObject rec : records) {
            results.add(rec.get(field));
        }
        
        return results;
    }
    
    /**
     * Groups values from a list into a map using given field
     * @param  records List<SObject>
     * @param  field   Schema.SObjectField
     * @return         Object
     */  
    public static Map<Object, List<SObject>> groupBy(List<SObject> records, Schema.SObjectField field) {
        Map<Object, List<SObject>> grouped = new Map<Object, List<SObject>>();
        for (SObject rec : records) {
            Object fieldValue = rec.get(field);
            if (!grouped.containsKey(fieldValue)) {
                grouped.put(fieldValue, new List<SObject>());
            }
            grouped.get(fieldValue).add(rec);
        }
        return grouped;
    }

    /**
     * Create an instance of the list based on sobject type
     * @param  sObjectType String
     * @return         	   List<SObject>
     */     
    public static List<SObject> getInstance(String sObjectType) {
    	return (List<SObject>) Type.forName('List<' + sObjectType + '>').newInstance();
    }
}