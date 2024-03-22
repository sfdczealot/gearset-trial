public class PGFinancial_BatchSchedulable implements System.Schedulable {
    public Void execute(System.SchedulableContext context) {
        Database.executeBatch(new PGFinancial_Batch(),1);
    }
}