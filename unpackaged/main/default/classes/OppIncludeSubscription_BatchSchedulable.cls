/*------------------------------------------------------------
Author:        Whisnu Satriya Wardhana
Company:       Viseo Asia PTE LTD
Description:   Schedule class to call Batch class OppIncludeSubscription_BatchSchedule
Inputs:        

Test Class:    
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
global class OppIncludeSubscription_BatchSchedulable implements Schedulable {
    /*------------------------------------------------------------
    Author:			Whisnu Satriya Wardhana
    Company:	 Viseo Asia PTE LTD
    Description:	Executes the Apex job based on provided schedule.
    Inputs:        sc <SchedulableContext>: Represents the parameter type of a method in a class that implements the Schedulable interface and contains the scheduled job ID. This interface is implemented internally by Apex.
    
    Return null;
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    ------------------------------------------------------------*/ 
    
    String paramId; boolean runparam;
    
    global OppIncludeSubscription_BatchSchedulable(String AccountId){
        paramId = AccountId;
    }
    global void execute(SchedulableContext sc) {
        OppIncludeSubscription_Batch b = new OppIncludeSubscription_Batch(paramId); 
        database.executeBatch(b, 1);
    }    
}