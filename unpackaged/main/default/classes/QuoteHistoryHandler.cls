//TEST CLASS:PGQuoteTriggerHandler_Test
public class QuoteHistoryHandler {
    
    //PGAUTO-3074 Quote  History Tracker Implementation ---START
    public static void trackHistory(List<Quote> newRecords, Map<Id, Quote> oldMap){
        List<Quote_History__c> quotehistories = new List<Quote_History__c>();
        for (Quote eachrecord : newRecords)
        {
            List<Schema.FieldSetMember> schemaset= SObjectType.Quote.FieldSets.Track_History.getFields();
            for(Schema.FieldSetMember each :schemaset){
                If(eachrecord.get(each.getFieldPath()) != oldMap.get(eachrecord.id).get(each.getFieldPath()) ){
                    system.debug('-Quotechanged--'+each.getFieldPath());
                    String oldValue='Blank Value';
                    String newValue ='Blank Value';
                    if(eachrecord.get(each.getFieldPath()) != null && eachrecord.get(each.getFieldPath()) != ''){
                        newValue = string.valueOf(eachrecord.get(each.getFieldPath()));
                    }
                    
                    if(oldMap.get(eachrecord.id).get(each.getFieldPath()) !=null && oldMap.get(eachrecord.id).get(each.getFieldPath()) != '' ){
                        oldValue = string.valueOf(oldMap.get(eachrecord.id).get(each.getFieldPath()));
                    }
                    system.debug('-oldvalue-'+oldValue+'-newValue-'+newValue);
                    quotehistories.add(getHistories(newValue,oldValue,each.getFieldPath(),eachrecord));
                }
            } 
            
        }
        IF(quotehistories!=null && quotehistories.size()>0){
            system.debug('--quotehistories--'+quotehistories);
            insert quotehistories;
        }
    }
    public static Quote_History__c getHistories(String newValue,String oldValue, String fieldName,Quote eachrecord){
        String actionString;
        
        Quote_History__c objHistory = new Quote_History__c ();
        actionString = 'Changed '+ fieldName+' from '+ oldValue +' to '+ newValue+'' ;
        objHistory.Action__c= actionString;
        objHistory.OpportunityId__c=eachrecord.OpportunityId;
        objHistory.Quote__c=eachrecord.Id;
        
        return objHistory;
    }
    public static void DeletedQuote(List<Quote> oldQLI){
        List<Quote_History__c> historiesList = new List<Quote_History__c>();
        for(Quote eachrecord : oldQLI){
            String actionString='';
            Quote_History__c objHistory = new Quote_History__c ();
            actionString = 'Deleted '+ eachrecord.Id+'' ;
            objHistory.OpportunityId__c=eachrecord.OpportunityId;
            objHistory.Action__c = actionString;
            historiesList.add(objHistory);
        }
        if(historiesList.size()>0){
            insert historiesList;
        } 
    }
    //PGAUTO-3074  -----END
    
}