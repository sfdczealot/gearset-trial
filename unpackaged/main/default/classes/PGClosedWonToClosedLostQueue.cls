public class PGClosedWonToClosedLostQueue implements Queueable{
    public Set<Id> setOfQuoteIds;
    
    public PGClosedWonToClosedLostQueue(set<Id> setOfQuoteIds){
        this.setOfQuoteIds = setOfQuoteIds;
    }
    public void execute(QueueableContext context){
        
        PGChangeCMstatusFromOppStinger sbc = new PGChangeCMstatusFromOppStinger(setOfQuoteIds);
        Database.executeBatch(sbc,1);   
    }
}