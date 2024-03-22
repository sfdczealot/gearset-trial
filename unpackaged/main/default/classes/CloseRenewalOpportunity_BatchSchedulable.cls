/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Schedulable class to run the batch job.
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
public class CloseRenewalOpportunity_BatchSchedulable implements System.Schedulable{
    public Void execute(System.SchedulableContext context) {
        Database.executeBatch(new CloseRenewalOpportunity_Batch(),1);
    }
}