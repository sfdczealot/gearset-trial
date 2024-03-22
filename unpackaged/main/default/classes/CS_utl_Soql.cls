/**
 * @name CS_utl_Soql
 * @description Utility class for SOQL
 * @revision
 *
 */
public class CS_utl_Soql {
	/**
	 * Returns the query filter based on the field values in the provided sObject.
	 * @param  obj SObject
	 * @return     String
	 */
	@TestVisible
	private static String buildCriteria(SObject obj) {
		String result = '';
		Map<String, Schema.SObjectField> fields = obj.getSObjectType().getDescribe().fields.getMap();
		for(String field : fields.keySet()) {
			Object value = obj.get(field);
		    if (value != null) {
		    	result += (String.isBlank(result) ? ' WHERE ' : ' AND ');
		    	if(value instanceof String) {
		    		value = String.escapeSingleQuotes('' + value);
		    		result += field + '=\'' + value + '\'';
		    	}
		    	else {
		    		result += field + '=' + value;
		    	}
		    }
		}

		return result;
	}
    
	/**
	 * Returns the query filter based on the provided ids
	 * @param  objIds Map<String, Set<Id>>
	 * @return        String
	 */
	@TestVisible
	private static String buildCriteria(Map<String, Set<Id>> objIds) {
        return buildCriteria(objIds, null);
    }

	/**
	 * Returns the query filter based on the provided ids
	 * @param  objIds             Map<String, Set<Id>>
	 * @param  additionalCriteria String
	 * @return                    String
	 */
	@TestVisible
	private static String buildCriteria(Map<String, Set<Id>> objIds, string additionalCriteria) {
		String criteria = '';
        if (objIds.size() > 0) {
            List<String> objIdsCriteria = new List<String>();
		    for (String fieldName : objIds.keySet()) {
			    objIdsCriteria.add(fieldName + ' IN (\'' + CS_utl_Array.join(new List<Id>(objIds.get(fieldName)), '\',\'') + '\')');
		    }
            criteria = '(' + String.join(objIdsCriteria, ' OR ') + ')';
        }
        if (String.isNotBlank(additionalCriteria)) {
            if (String.isNotBlank(criteria)) {
                criteria += ' AND ';
            }
            criteria += ('(' + additionalCriteria + ')');
        }
        if (String.isNotBlank(criteria)) {
            criteria = ' WHERE ' + criteria;
        }
        return criteria;
	}

	/**
	 * Returns query based on given fields
	 * @param  obj SObject
	 * @return     String
	 */
	public static String buildQuery(SObject obj) {
		return buildQuery(obj, null);
	}

	/**
	 * Returns query based on given fields
	 * @param  obj 			   SObject
	 * @param  additionalFields List<String>
	 * @return  				   String
	 */
	public static String buildQuery(SObject obj, String additionalFields) {
		return 'SELECT ' + CS_utl_SObject.getFieldList(obj.getSObjectType()) + 
				(String.isNotBlank(additionalFields) ? ',' + additionalFields : '') +
				' FROM ' + obj.getSObjectType().getDescribe().getName() + buildCriteria(obj);
	}

	/**
	 * Returns query based on given fields
	 * @param  objType SObjectType
	 * @param  objIds  Map<String, Set<Id>>
	 * @return         String
	 */
	public static String buildQuery(SObjectType objType, Map<String, Set<Id>> objIds) {
		return buildQuery(objType, objIds, null, null);
	}
	
	/**
	 * Returns query based on given fields
	 * @param  objType 			SObjectType
	 * @param  objIds  			Map<String, Set<Id>>
	 * @param  additionalFields List<String>
	 * @return         			String
	 */
	public static String buildQuery(SObjectType objType, Map<String, Set<Id>> objIds, String additionalFields) {
		return buildQuery(objType, objIds, additionalFields, null);
	}
    
	/**
	 * Returns query based on given fields
	 * @param  objType 			SObjectType
	 * @param  objIds  			Map<String, Set<Id>>
	 * @param  additionalFields List<String>
	 * @param  ignoreFields		Set<Schema.SObjectField> 
	 * @return                  String
	 */
	public static String buildQuery(SObjectType objType, Map<String, Set<Id>> objIds, String additionalFields, Set<Schema.SObjectField> ignoreFields) {
		return buildQuery(objType, objIds, additionalFields, ignoreFields, null);
	}
	
	/**
	 * Returns query based on given fields
	 * @param  objType 			SObjectType
	 * @param  objIds  			Map<String, Set<Id>>
	 * @param  additionalFields List<String>
	 * @param  ignoreFields		Set<Schema.SObjectField> 
	 * @param  queryFields		String
	 * @return                  String
	 */
	public static String buildQuery(SObjectType objType, Map<String, Set<Id>> objIds, String additionalFields, Set<Schema.SObjectField> ignoreFields, String queryFields) {
		return buildQuery(objType, objIds, additionalFields, ignoreFields, queryFields, null);
	}
    
	/**
	 * Returns query based on given fields
	 * @param  objType 			  SObjectType
	 * @param  objIds  			  Map<String, Set<Id>>
	 * @param  additionalFields   List<String>
	 * @param  ignoreFields		  Set<Schema.SObjectField> 
	 * @param  queryFields		  String
	 * @param  additionalCriteria String
	 * @return                    String
	 */
	public static String buildQuery(SObjectType objType, Map<String, Set<Id>> objIds, String additionalFields, Set<Schema.SObjectField> ignoreFields, 
                                    String queryFields, String additionalCriteria) {
		return 'SELECT ' + (String.isNotBlank(queryFields) ? queryFields : CS_utl_SObject.getFieldList(objType, '', ignoreFields)) +
				(String.isNotBlank(additionalFields) ? ',' + additionalFields : '') +
				' FROM ' + objType.getDescribe().getName() + buildCriteria(objIds, additionalCriteria);
	}
}