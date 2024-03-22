/**
 * @name CS_utl_CronTest
 * @description Test for CS_utl_Cron
 * @revision
 *
 */
@isTest
public class CS_utl_CronTest {
    /**
     * Tests creating Cron expression from Datetime
     */
    @isTest
    public static void test_getCronDatetime() {
        Datetime dt = Datetime.newInstance(2000, 1, 1, 10, 0, 0);
        String expectedCron = '0 0 10 1 1 ? 2000';
        
        Test.startTest();
        
        System.assertEquals(expectedCron, CS_utl_Cron.getCron(dt));

        Test.stopTest();
    }
    
    /**
     * Tests creating daily cron expression
     */
    @isTest
    public static void test_getCronDaily() {
        Time tm = Time.newInstance(10, 0, 0, 0);
        String expectedCron = '0 0 10 * * ? *';
        
        Test.startTest();
        
        System.assertEquals(expectedCron, CS_utl_Cron.getCron(tm));
        
        Test.stopTest();
    }
}