/**
 * @name CS_utl_Id
 * @description Utility class for Id object
 * @revision
 *
 */
public class CS_utl_Id {
    private static Integer counter = 0;

    /**
     * Creates a fake Id for given object type
     * @param  objectType Schema.SObjectType
     * @return            Id
     */
    public static Id getFakeId(Schema.SObjectType objectType) {
        String offset = String.valueOf(counter++);
        return objectType.getDescribe().getKeyPrefix() + '0'.repeat(12 - offset.length()) + offset;
    }

    /**
     * Creates an unique Id for the give object type
     * @param  objectType Schema.SObjectType
     * @return            String
     */
    public static String getUniqueId(Schema.SObjectType objectType) {
        String offset = String.valueOf(counter++);
        String key = CS_utl_Array.join(new List<String>{'key', Datetime.now().format('yyyMMdd_HHmmss'),
                                                     offset, String.valueof(Math.random()),
                                                     objectType.getDescribe().getName()}, '__');
        return key;
    }

    /**
     * Creates an unique Key
     * @return            String
     */    
    public static String generateKey() {
    	Blob b = Crypto.generateAesKey(128);
		String h = EncodingUtil.ConvertTohex(b);
		return h.SubString(0, 8) + '-' + h.SubString(8, 12) + '-' + h.SubString(12, 16) + '-' + h.SubString(16, 20) + '-' + h.substring(20);
    }
}