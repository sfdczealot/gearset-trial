public class AggregateIterable implements Iterable<AggregateResult>, Iterator<AggregateResult> {
  List<AggregateResult> ar;
  Integer i;
  public AggregateIterable(String Query) {
    ar = Database.query(Query);
    i  = 0;
  }
  public Iterator<AggregateResult> Iterator() {
    return this;
  }
  public boolean hasNext() {
    if(ar.size() <= i )
      return false;
    else
      return true;
  }
  public AggregateResult next() {
   i++;
   return ar[i-1];
  }
}