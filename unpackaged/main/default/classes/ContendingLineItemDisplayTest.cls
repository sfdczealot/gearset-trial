@isTest(seeAllData=false)
public class ContendingLineItemDisplayTest {
	
	@isTest 
	public static void lineItemTest(){
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupBasic.createAccount();
		insert acc;
		
		Contact con = TestDataSetupBasic.createContact(acc);
		insert con;
		
		Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
		insert opp;
		
		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;
		
		cscfga__Product_Basket__c prodBasket = TestDataSetupTargetables.createProdBasket(so);
		insert prodBasket;
		
		csdf__Fulfilment__c testFulfilment = TestDataSetupTargetables.createFulfilment(so,acc);		   
		insert testFulfilment;
	
		cscfga__Product_Configuration__c prodConfig = TestDataSetupTargetables.createProdConfig(prodBasket);
		insert prodConfig;
		
		csdf__Fulfilment_Item__c testFulfilmentItem = TestDataSetupTargetables.createFulfilmentItem(prodConfig,so,testFulfilment); 
		insert testFulfilmentItem;				
		
		Test.startTest();
		String parameters = JSON.serialize(testFulfilmentItem.Id);
		ContendingLineItemDisplay contLineDispClass = new ContendingLineItemDisplay();
		//ContendingLineItemDisplay.getCliData(acc.Id);
		String str = contLineDispClass.performAction(parameters);
		/*
		ContendingLineItemDisplay.ContendingLineItems conLine = new ContendingLineItemDisplay.ContendingLineItems();
		ContendingLineItemDisplay.ContendingLineItem conitem = new ContendingLineItemDisplay.ContendingLineItem();
		conLine.contendingLineItems = new List<ContendingLineItemDisplay.ContendingLineItem>();
		conitem.lineItemId = 'testline';
		conitem.contendingImpressions = 8;
		ContendingLineItemDisplay.SingleCLI sing  = new ContendingLineItemDisplay.SingleCLI(testFulfilmentItem,9);
		ContendingLineItemDisplay.SingleCLI sing1  = new ContendingLineItemDisplay.SingleCLI('test',9);
		*/
		Test.stopTest();
	}

	@isTest 
	public static void lineItemTestException(){
		CS_utl_User.disableAllTriggers(UserInfo.getUserId());
		csmso__SalesOrderAPI__c soapi = TestDataSetupSO.createSalesOrderAPI();
		insert soapi;

		Account acc = TestDataSetupBasic.createAccount();
		insert acc;
		
		Contact con = TestDataSetupBasic.createContact(acc);
		insert con;
		
		Opportunity opp = TestDataSetupBasic.createOpportunity(acc, con);
		insert opp;
		
		csmso__Sales_Order__c so = TestDataSetupSO.createSalesOrder(acc, opp);
		insert so;

		Test.startTest();
		String parameters = JSON.serialize(so);

		try {
			ContendingLineItemDisplay contLineDispClass = new ContendingLineItemDisplay();
			String str = contLineDispClass.performAction(parameters);
		}
		catch (Exception e) {

		}
		
		Test.stopTest();
	}
}