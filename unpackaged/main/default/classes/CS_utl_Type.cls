/**
 * @name CS_utl_Type
 * @description Utility methods for Type class
 * @revision
 *
 */
public class CS_utl_Type {
    public static final String LIST_TYPE = 'List<{0}>';
    
    /**
     * Creates a list of object type
     * @param objectType String
     * @return           Object
     */
    public static Object getListInstance(String objectType) {
        String lType = String.format(LIST_TYPE, new List<String>{objectType});
        return getInstance(lType);
    }

    /**
     * Creates an object instance of object type
     * @param objectType String
     * @return           Object
     */
    public static Object getInstance(String objectType) {
        return Type.forName(objectType).newInstance();
    }
}