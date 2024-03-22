public class SalesOrder_HistoryController {
    public List<aTableRow> tableRows {get; set;}
    public class aTableRow implements Comparable{
        public object theObjectName {get; set;}
        public object theNewValue {get; set;}
        public object theOldValue {get; set;}
        public string theFieldName {get; set;}
        public datetime theCreatedDate {get; set;}
        public object theCreatedBy {get; set;}
        public aTableRow (object parentName, object newValue, object oldValue, string fieldName, datetime createddatetime, object createdbyname){
            theObjectName = parentName;
            theNewValue = newValue;
            theOldValue = oldValue;
            theFieldName = fieldName;
            theCreatedDate = createddatetime;
            theCreatedBy = createdbyname;
        }
        
        public Integer compareTo(Object compareTo){
            aTableRow atr = (aTableRow)compareTo;
            if(theCreatedDate == atr.theCreatedDate ) return 0;
            if(theCreatedDate > atr.theCreatedDate) return -1;
            return 1;
        }
    }

    public SalesOrder_HistoryController() {
        String myId = ApexPages.currentPage().getParameters().get('Id');
        tableRows = new List<aTableRow>();

        for(cscfga__Product_Configuration__History p : [SELECT 
                                                            Parent.Name,
                                                            Parent.Line_ID__c,
                                                            Parent.Sales_Order__c,
                                                            OldValue,
                                                            NewValue,
                                                            Field,
                                                            CreatedById,
                                                            CreatedBy.Name,
                                                            CreatedDate 
                                                        FROM cscfga__Product_Configuration__History 
                                                        WHERE parent.Sales_Order__c =:myId] ){

            if(String.valueOf(p.Field).equals('Sales_Order__c') == false){
                tableRows.add(new aTableRow(p.Parent.Line_ID__c,p.NewValue,p.OldValue, p.Field, p.CreatedDate, p.CreatedBy.Name ));
            }
        }
        for(csmso__Sales_Order__History s : [SELECT 
                                                ParentId,
                                                Parent.Name,
                                                OldValue,
                                                NewValue,
                                                Field,
                                                CreatedById,
                                                CreatedBy.Name,
                                                CreatedDate 
                                            FROM csmso__Sales_Order__History 
                                            WHERE parentid =:myId]){
            tableRows.add(new aTableRow(s.Parent.Name, s.NewValue,s.OldValue, s.Field, s.CreatedDate, s.CreatedBy.Name));
        }

        // for(csdf__Fulfilment__History f : [SELECT ParentId,Parent.Name, OldValue, NewValue, Field, CreatedById,CreatedBy.Name, CreatedDate FROM csdf__Fulfilment__History where Parent.Sales_Order__c =:myId]){
        //     tableRows.add(new aTableRow(f.Parent.Name, f.OldValue, f.NewValue, f.Field, f.CreatedDate, f.CreatedBy.Name));
        // }
        // for(csdf__Fulfilment_Item__History b : [SELECT ParentId,Parent.Name, OldValue, NewValue, Field, CreatedById,CreatedBy.Name, CreatedDate FROM csdf__Fulfilment_Item__History where Parent.Sales_Order__c =:myId]){
        //     tableRows.add(new aTableRow(b.Parent.Name, b.OldValue, b.NewValue, b.Field, b.CreatedDate, b.CreatedBy.Name));
        // }
         
    }
    
    public PageReference doSort(){
        tableRows.sort();
        return null;
    }        

}