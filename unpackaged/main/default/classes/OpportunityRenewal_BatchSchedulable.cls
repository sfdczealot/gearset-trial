/*------------------------------------------------------------
Author:        Whisnu Satriya Wardhana
Company:       Viseo Asia PTE LTD
Description:   Schedule class to call Batch class OpportunityRenewal_Batch
Inputs:        

Test Class:    
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
global class OpportunityRenewal_BatchSchedulable implements Schedulable {
    /*------------------------------------------------------------
    Author:			Whisnu Satriya Wardhana
    Company:	 Viseo Asia PTE LTD
    Description:	Executes the Apex job based on provided schedule.
    Inputs:        sc <SchedulableContext>: Represents the parameter type of a method in a class that implements the Schedulable interface and contains the scheduled job ID. This interface is implemented internally by Apex.
    
    Return null;
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    ------------------------------------------------------------*/ 
    global void execute(SchedulableContext sc) {
        OpportunityRenewal_Batch b = new OpportunityRenewal_Batch(); 
        database.executeBatch(b, 10);
    }    
}