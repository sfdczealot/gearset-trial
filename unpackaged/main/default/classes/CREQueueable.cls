/*
 * TestClass : CREQueueable_Test
 */
public class CREQueueable implements Queueable {

    Id scope;
    List<Sobject> sObjectList;
    public CREQueueable(Id scope,List<Sobject> sObjectList){
        this.scope = scope;
        this.sObjectList = sObjectList;
    }
    public void execute(QueueableContext Qu){ 
        
        Database.executeBatch(new CMOperationsBatch(this.scope,this.sObjectList),8000);
    }
}