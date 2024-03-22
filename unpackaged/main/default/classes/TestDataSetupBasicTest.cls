@isTest
private class TestDataSetupBasicTest {
	
	@isTest static void TestDataSetupBasicTest() {
			Account acc = TestDataSetupBasic.createAccount();
			Account[] accounts = TestDataSetupBasic.createAccounts(1);
        
            Account[] accList = TestDataSetupBasic.createAccountForB2B(1);

			Contact con = TestDataSetupBasic.createContact(acc);
			Contact[] contacts = TestDataSetupBasic.createContacts(1, accounts);

			Opportunity opp = TestDataSetupBasic.createOpportunity(accList[0],con);
			Opportunity[] opportunities = TestDataSetupBasic.createOpportunities(1, accList, contacts);
        
            
	}
	
	
	
}