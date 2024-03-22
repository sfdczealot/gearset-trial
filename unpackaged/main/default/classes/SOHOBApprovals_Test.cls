@isTest 
public class SOHOBApprovals_Test {
	private static String soID;

	private static csmso__Sales_Order__c salesOrder;
	private static void createTestData() {
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

	
		Account[] accs = TestDataSetupBasic.createAccounts(1);
        accs[0].RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('B2B - Account').getRecordTypeId();
		update accs[0];	
		Contact[] cons = TestDataSetupBasic.createContacts(1, accs);
		Opportunity opp = TestDataSetupBasic.createOpportunity(accs[0], cons[0]);
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2B').getRecordTypeId();
		//opp.Pricebook2Id = pricebookPGSG.Id;
		insert opp;

		salesOrder = new csmso__Sales_Order__c();
		salesOrder.csmso__Opportunity__c = opp.Id;
		salesOrder.isTestRunning__c = true;
		salesOrder.csmso__Advertiser__c = accs[0].Id;
		salesOrder.SO_Lines_All_Valid__c = true;
		salesOrder.csmso__Status__c = 'Draft';
		salesOrder.SO_Lines_Ad_Server_Items__c = 2;
		salesOrder.SO_Lines_Number_of_lines__c = 1;
		salesOrder.Primary_Sales_Order__c = true;
		salesOrder.Inventory_Approval__c = 'Pending';
		salesOrder.Approval_Custom_Button__c = true;
		salesOrder.Approval_Inventory_Required__c = true;
		salesOrder.Billing_Calendar__c = 'Standard';
		salesOrder.csmso__Booking_Contact__c = cons[0].Id;
		salesOrder.Paper_Type__c = 'Spotify Paper';
		salesOrder.csmso__Purchase_Order_Number__c = '1234';
		salesOrder.Bill_To_Account__c = accs[0].Id;
		insert salesOrder;

		soID = salesOrder.Id;
	}

	@IsTest
	static void testButtonSOApprovalAccept() {
		createTestData();
         String jsonStr = '{"SOId":"'+soId+'","ApprovalStatus":"rejected","Comments":"testAPII"}';

         RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/api/salesorderHOBApproval/';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueof(jsonStr);

RestContext.request = req;
        RestContext.response= res;
        
        Test.startTest();
        SOHOBApprovals.approveRejectSalesOrder();
        Test.stopTest();    
    }
}