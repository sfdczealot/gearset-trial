/**
*─────────────────────────────────────────────────────────────────────────────────────────────────┐
*Process excuted on isUpdate Custom Report Execution object trigger. Checks if the report status
* has been chaged to completed. If so it then calls batch class to check and delete any third party duplicates
*──────────────────────────────────────────────────────────────────────────────────────────────────
*@author    Osvaldo Parra   <osvaldo.parrarascon@cloudsense.com>
*──────────────────────────────────────────────────────────────────────────────────────────────────
*@changes
*─────────────────────────────────────────────────────────────────────────────────────────────────┘
*/
public with sharing class CS_P_CustomReportStatusFilter extends CS_ProcessBase
{
    
    @TestVisible
	Map<Id, sObject> applicableObjects;

	@TestVisible
	Map<Id, sObject> oldObjects;
	
    /**
     * Class constructor - Initialize process
     */
     
    public CS_P_CustomReportStatusFilter(Map<Id, sObject> oldObjects) {
		super(CS_ProcessDefinition.CUSTOM_REPORT_STATUS_FILTER, 'CS_P_CustomReportStatusFilter');

		this.oldObjects = oldObjects;
		applicableObjects = new Map<Id, sObject>();
	}
 
    /**
     * InitialLoop method, it will filter and get applicableObjectIds.
     */
	public override void isRecordEligible(SObject obj) {

		csdf__Custom_Report_Execution__c newReport = (csdf__Custom_Report_Execution__c) obj;	
		csdf__Custom_Report_Execution__c oldReport = (csdf__Custom_Report_Execution__c) oldObjects.get(newReport.Id);
	
	    if( (newReport.csdf__Report_Status__c != oldReport.csdf__Report_Status__c) && (newReport.csdf__Report_Status__c == 'Completed') ){
	        applicableObjects.put(obj.Id, obj);
	    }
	    
		this.runProcess = !applicableObjects.isEmpty() && !CS_ProcessExecution.wasProcessExecuted(this.processName);		
	}
 
    /**
     * Queries the needed custom report execution objects based ont he ad server type.
     */
    @TestVisible
    protected override void logic()
    {  
         //query and process only if something to process
        if (!applicableObjects.isEmpty())
        {
            List<csdf__Custom_Report_Execution__c> applicableReports = 
            [
                SELECT  Id, Name
                FROM    csdf__Custom_Report_Execution__c
                WHERE   Id = :applicableObjects.keySet()
                AND     csdf__Custom_Report_Definition__r.csdf__Ad_Server__r.csdf__Type__c = 'Ad-Juster'
            ];

            if(!applicableReports.isEmpty()){
                
                List<String> applicableReportIds = new List<String>();
                
                for(csdf__Custom_Report_Execution__c currReport : applicableReports){
                    applicableReportIds.add(String.valueOf(currReport.Id));
                }
                
                CS_BatchDeleteThirdPartyDuplicates batchWorker = new CS_BatchDeleteThirdPartyDuplicates(applicableReportIds);
                batchWorker.execute();
            }
        }
    }
}