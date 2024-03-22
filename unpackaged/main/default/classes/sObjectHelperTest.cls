@IsTest
private class sObjectHelperTest {
    private static Account account;

    static void setupTestData(){
        account = TestDataSetupBasic.createAccount();
        insert account;
    }
    
    @IsTest
    static void testGetObjectFieldListAsCSV() {
        setupTestData();

        sObjectHelper helper = new sObjectHelper();
        helper.getFieldValue(account,'Name');

        String accountAsCSV = sObjectHelper.getObjectFieldListAsCSV('Opportunity',false);
        System.assertNotEquals(null, accountAsCSV);
    }
    
    @IsTest
    static void testGetSelectStarFrom() {
        setupTestData();

        List<Account> accounts = sObjectHelper.getSelectStarFrom('Account','Website=\'www.cloudsense.com\'', 1, false);
        System.assertEquals(1, accounts.size());
    }

    @IsTest
    static void testGetFieldValue() {
        setupTestData();

        sObjectHelper helper = new sObjectHelper();
        String accountName = (String) helper.getFieldValue(account, 'Website');

        System.assertEquals('www.cloudsense.com', accountName);
    }

    @IsTest
    static void testGetFieldType() {
        setupTestData();

        sObjectHelper helper = new sObjectHelper('Account');
        String accountNameType = (String) helper.getFieldType('Name');

        System.assertEquals('STRING', accountNameType);
    }
}