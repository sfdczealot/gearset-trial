global  class PGCeligoFinancialUpdateDF implements Database.batchable<Sobject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String s='SELECT Id,netsuite_conn__Account__c,Actuals__c,netsuite_conn__Applied__c,netsuite_conn__Currency__c,netsuite_conn__Discount_Total__c,netsuite_conn__Document_Id__c, netsuite_conn__Due_Date__c,netsuite_conn__Memo__c,netsuite_conn__NetSuite_Id__c,netsuite_conn__Opportunity__c,Opty_Owner_Email__c,netsuite_conn__PDF_File__c,netsuite_conn__Shipping_Total__c,netsuite_conn__Status__c,netsuite_conn__Subtotal__c,netsuite_conn__Tax_Total__c, netsuite_conn__Terms__c,netsuite_conn__Total__c,netsuite_conn__Transaction_Date__c, netsuite_conn__Type__c,netsuite_conn__Unapplied__c,Upload_Tag__c from netsuite_conn__NetSuite_Financial__c ';
        return Database.getQueryLocator(s);
        
    }
    global void execute(Database.BatchableContext bc, List<netsuite_conn__NetSuite_Financial__c> FinancialList )
        
    {
        System.debug('@@@'+ FinancialList);
        list<Financial__c> newFinancial = new list<Financial__c>();
        for( netsuite_conn__NetSuite_Financial__c fin : FinancialList) {
            newFinancial.add(new Financial__c(
                
                Account__c = fin.netsuite_conn__Account__c,
                Applied__c = fin.netsuite_conn__Applied__c,
                Currency__c = fin.netsuite_conn__Currency__c,
                Discount_Total__c = fin.netsuite_conn__Discount_Total__c,
                Document_Id__c = fin.netsuite_conn__Document_Id__c,
                Due_Date__c = fin.netsuite_conn__Due_Date__c,
                Memo__c = fin.netsuite_conn__Memo__c,
                NetSuite_Id__c= fin.netsuite_conn__NetSuite_Id__c,
                Opportunity__c = fin.netsuite_conn__Opportunity__c ,
                Opty_Owner_Email__c = fin.Opty_Owner_Email__c,
                Shipping_Total__c = fin.netsuite_conn__Shipping_Total__c,
                Status__c= fin.netsuite_conn__Status__c,
                Subtotal__c = fin.netsuite_conn__Subtotal__c,
                Transaction_subtotal_before_any_discount__c  = fin.netsuite_conn__Tax_Total__c,
                Terms__c = fin.netsuite_conn__Terms__c,
                Total__c = fin.netsuite_conn__Total__c,
                Transaction_Date__c= fin.netsuite_conn__Transaction_Date__c,
                Type__c = fin.netsuite_conn__Type__c,
                Unapplied__c = fin.netsuite_conn__Unapplied__c,
                Upload_Tag__c = fin.Upload_Tag__c));
        }
        
        
        database.insert(newFinancial,false);
       
    }
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
}