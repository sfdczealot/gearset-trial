@isTest
public class PGCeligoFinancialUpdateDF_test {
    public static testmethod void unitTest1(){
         netsuite_conn__NetSuite_Financial__c FinRec = new netsuite_conn__NetSuite_Financial__c();
        FinRec.netsuite_conn__NetSuite_Id__c= '3763639';
        FinRec.netsuite_conn__Type__c   = 'Invoice';
        FinRec.netsuite_conn__Document_Id__c = '';
        FinRec.Name = 'TestTransaction';
        insert FinRec;
          test.startTest();
        
         PGCeligoFinancialUpdateDF obj = new PGCeligoFinancialUpdateDF();
        DataBase.executeBatch(obj); 
       
        test.stopTest();
    }
}