//this batch is used to update owner of renewal oppty
public class UpdateRenewalOppOwner_Batch implements DataBase.Batchable<sObject>{
    list<Opportunity> oppList = new list<Opportunity>();
    
    public UpdateRenewalOppOwner_Batch(list<Opportunity> oppList){
        this.oppList = oppList;
    }
    public Iterable<sObject> start(DataBase.BatchableContext Bc){
        
        return oppList;
    }
    public void execute(DataBase.BatchableContext Bc,List<Opportunity> scope ){
        update scope;
    }
    public void finish(DataBase.BatchableContext bc){
    }    
}