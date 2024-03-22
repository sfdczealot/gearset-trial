global class PGCeligoAccountUpdateDF implements Database.batchable<Sobject> {
    
    global Database.QueryLocator start(Database.BatchableContext bc)
    {
        String s='SELECT Id, netsuite_conn__Celigo_Update__c,netsuite_conn__Sync_In_Progress__c,netsuite_conn__Unbilled_Orders__c,netsuite_conn__NetSuite_Id__c,netsuite_conn__NetSuite_Sync_Err__c,netsuite_conn__Account_Overdue_Balance__c,netsuite_conn__Pushed_From_Opportunity__c,netsuite_conn__Credit_Limit__c,netsuite_conn__Credit_Hold__c,netsuite_conn__Push_To_NetSuite__c,netsuite_conn__Channel_Tier__c,netsuite_conn__Days_Overdue__c,netsuite_conn__Account_Balance__c  FROM Account '+
            'Where (netsuite_conn__Celigo_Update__c!=null OR netsuite_conn__Sync_In_Progress__c!=null OR netsuite_conn__Unbilled_Orders__c!=null OR netsuite_conn__NetSuite_Id__c!=null OR netsuite_conn__Account_Overdue_Balance__c!=null OR netsuite_conn__Pushed_From_Opportunity__c!=null OR netsuite_conn__Credit_Limit__c!=null OR netsuite_conn__Credit_Hold__c!=null OR netsuite_conn__Push_To_NetSuite__c!=null OR netsuite_conn__Channel_Tier__c!=null OR '+
            'netsuite_conn__Days_Overdue__c!=null OR netsuite_conn__Account_Balance__c!=null)';
        
        return Database.getQueryLocator(s);
        
    }
    global void execute(Database.BatchableContext bc, List<Account> accList )
        
    {
        
        for(Account acc : accList) {
            // Update the Account Name
          
            if(acc.netsuite_conn__Celigo_Update__c!=null)
            acc.Celigo_Update__c = acc.netsuite_conn__Celigo_Update__c;
            
            if(acc.netsuite_conn__Days_Overdue__c!=null)
            acc.Days_Overdue__c= acc.netsuite_conn__Days_Overdue__c;
            
            if(acc.netsuite_conn__Push_To_NetSuite__c!=null)
            acc.Push_To_NetSuite__c = acc.netsuite_conn__Push_To_NetSuite__c;
            
            if(acc.netsuite_conn__Channel_Tier__c!=null)
            acc.Channel_Tier__c = acc.netsuite_conn__Channel_Tier__c;
            
            if(acc.netsuite_conn__Credit_Hold__c!=null)
            acc.Credit_Hold__c=acc.netsuite_conn__Credit_Hold__c;
            
            if(acc.netsuite_conn__Credit_Limit__c!=null)
            acc.Credit_Limit__c =acc.netsuite_conn__Credit_Limit__c;
            
            if(acc.netsuite_conn__Pushed_From_Opportunity__c!=null)
            acc.Pushed_From_Opportunity__c =acc.netsuite_conn__Pushed_From_Opportunity__c;
            
            if(acc.netsuite_conn__Account_Overdue_Balance__c!=null)
            acc.Account_Overdue_Balance__c =acc.netsuite_conn__Account_Overdue_Balance__c;
            
            if(acc.netsuite_conn__NetSuite_Id__c!=null)
            acc.NetSuite_Id__c = acc.netsuite_conn__NetSuite_Id__c;
            
            if(acc.netsuite_conn__NetSuite_Sync_Err__c!=null)
            acc.NetSuite_Sync_Error__c = acc.netsuite_conn__NetSuite_Sync_Err__c;
            
            if(acc.netsuite_conn__Unbilled_Orders__c!=null)
            acc.Unbilled_Orders__c =  acc.netsuite_conn__Unbilled_Orders__c;
            
            if(acc.netsuite_conn__Sync_In_Progress__c!=null)
            acc.Sync_In_Progress__c = acc.netsuite_conn__Sync_In_Progress__c;
            
            if(acc.netsuite_conn__Account_Balance__c!=null)
            acc.Account_Balance__c = acc.netsuite_conn__Account_Balance__c;
        }
        
            if(accList.size()>0)
            update accList;
    }
    
    global void finish(Database.BatchableContext bc)
    {
        
    }
    
}