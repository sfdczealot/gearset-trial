global class PGCeligoContactUpadateDF implements Database.batchable<Sobject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String s='SELECT Id, netsuite_conn__Celigo_Update__c,netsuite_conn__NetSuite_Sync_Err__c,netsuite_conn__NetSuite_Id__c,netsuite_conn__Pushed_From_Opportunity__c,netsuite_conn__Push_To_NetSuite__c,netsuite_conn__Sync_In_Progress__c From contact '+
                 'Where (netsuite_conn__Celigo_Update__c!=null OR netsuite_conn__NetSuite_Id__c!=null OR netsuite_conn__Pushed_From_Opportunity__c!=null OR netsuite_conn__Push_To_NetSuite__c!=null OR netsuite_conn__Sync_In_Progress__c!=null)';
        
        return Database.getQueryLocator(s);
        
    }
    
    global void execute(Database.BatchableContext bc, List<contact> conlist )
        
    {
        
        for( contact con : conlist) {
            // Update the contact field 
            if(con.netsuite_conn__Celigo_Update__c!=null)
            con.Celigo_Update__c = con.netsuite_conn__Celigo_Update__c ;
            
            if(con.netsuite_conn__NetSuite_Sync_Err__c!=null)
            con.NetSuite_Sync_Error__c = con.netsuite_conn__NetSuite_Sync_Err__c;
            
            if(con.netsuite_conn__NetSuite_Id__c!=null)
            con.NetSuite_Id__c =con.netsuite_conn__NetSuite_Id__c;
            
            if(con.netsuite_conn__Pushed_From_Opportunity__c!=null)
            con.Pushed_From_Opportunity__c = con.netsuite_conn__Pushed_From_Opportunity__c;
            
            if(con.netsuite_conn__Push_To_NetSuite__c!=null)
            con.Push_To_NetSuite__c= con.netsuite_conn__Push_To_NetSuite__c;
            
            if(con.netsuite_conn__Sync_In_Progress__c!=null)
            con.Sync_In_Progress__c =con.netsuite_conn__Sync_In_Progress__c;
            
        }
        
        // Update the contact Record
        if(conlist.size()>0)
        update conlist;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }  
}