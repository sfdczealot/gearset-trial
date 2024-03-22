@isTest
public class CS_CustomReportExecutionTriggerTest {
    
    @testSetup
	public static void createData() {
        csdf__Ad_Server__c testAdserver = new csdf__Ad_Server__c(Name = 'Ad-Juster', csdf__Type__c = 'Ad-Juster', csdf__Description__c ='Description',
            csdf__Network_Code__c = 'Code', csdf__Network_Name__c = 'Network', csdf__Client_Id__c = 'clientID', 
                csdf__Client_Secret__c = 'Secret', csdf__Refresh_Token__c = 'Token');
                
        INSERT testAdserver;
        
        csdf__Custom_Report_Definition__c testDefinition = new csdf__Custom_Report_Definition__c(Name = 'Test Def', csdf__Ad_Server__c = testAdserver.Id, 
            csdf__Query_Id__c = 'id', csdf__Result_Object_Name__c = 'obj');
        
        INSERT testDefinition;
        
        csdf__Custom_Report_Execution__c testReport = new csdf__Custom_Report_Execution__c(Name = 'Report', csdf__Custom_Report_Definition__c = testDefinition.Id,
            csdf__Map_Parameters__c = 'parameters', csdf__Report_Status__c = 'status');
            
        INSERT testReport;
        
        Third_Party_Actual__c testActual = new Third_Party_Actual__c(Custom_Report_Execution__c = testReport.Id, 
            Order_Line_Id__c = 'testid', Report_Date__c = Date.newInstance(2018,11, 17));
        
        INSERT testActual;
        
        Third_Party_Actual__c testActual2 = new Third_Party_Actual__c(Custom_Report_Execution__c = testReport.Id, 
            Order_Line_Id__c = 'testid', Report_Date__c = Date.newInstance(2018,11, 17));
        
        INSERT testActual2;
        
        Third_Party_Actual__c testActual3 = new Third_Party_Actual__c(Custom_Report_Execution__c = testReport.Id, 
            Order_Line_Id__c = 'testid', Report_Date__c = Date.newInstance(2018,11, 17));
        
        INSERT testActual3;
        
         Worker__c settings = CS_th_Worker.create();
	}


    @isTest
	public static void runTriggerTest() {
        Test.startTest();
        List<csdf__Custom_Report_Execution__c> reportExecutionList = [SELECT Id, Name, csdf__Report_Status__c FROM csdf__Custom_Report_Execution__c WHERE Name = 'Report'];
        System.debug('list'+reportExecutionList);
        reportExecutionList[0].csdf__Report_Status__c = 'Completed';
        UPDATE reportExecutionList;
        Test.stopTest();
	}
	
	@isTest
	public static void runDeletionActualTest(){
	    Test.startTest();
	    List<String> reportStringIds = new List<String>();
        List<csdf__Custom_Report_Execution__c> reportExecutionList = [SELECT Id, Name, csdf__Report_Status__c FROM csdf__Custom_Report_Execution__c WHERE Name = 'Report'];
 	    
 	    for(csdf__Custom_Report_Execution__c currReport : reportExecutionList){
 	        reportStringIds.add(String.valueOf(currReport.Id));
 	    }
 	    
 	    Id batchTest = Database.executeBatch(new CS_BatchDeleteThirdPartyDuplicates(reportStringIds), 100);
	    Test.stopTest();
	    
	    Integer actualCount = [SELECT COUNT() FROM Third_Party_Actual__c];
	    
	    System.assertEquals(1, actualCount);
	}
	
}