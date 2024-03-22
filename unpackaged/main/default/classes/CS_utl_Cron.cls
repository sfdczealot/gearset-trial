/**
 * @name CS_utl_Cron
 * @description Utility class for Cron operations
 * @revision
 *
 */
public class CS_utl_Cron {
    public static final String CRON = '{0} {1} {2} {3} {4} \'?\' {5}';
    public static final String CRON_EXP = 's m H d M \'?\' yyyy';
    public static final String ANYPERIOD = '*';

    /**
     * Get Cron from Datetime
     * @param dt Datetime
     * @return   String
     */
    public static String getCron(Datetime dt) {
        return dt.format(CRON_EXP);
    }
    
    /**
     * Create Cron that repeats daily
     * @param tm Time
     * @return   String
     */
    public static String getCron(Time tm) {
        return String.format(CRON, new List<String>{
            String.valueOf(tm.second()),
            String.valueOf(tm.minute()),
            String.valueOf(tm.hour()),
            ANYPERIOD, ANYPERIOD, ANYPERIOD});
    }
}