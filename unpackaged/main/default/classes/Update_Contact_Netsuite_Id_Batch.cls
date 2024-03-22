/*----------------------------------------------------
* Created On : December 7,2020
* Description : To update custom field NetSuite_Id__c on Contact with value of NetSuite_Id_Clone__c from same contact
* UnitTest : Update_Contact_Netsuite_Id_Batch_Test.apxc
* --------------------------------------------------
*/

global class Update_Contact_Netsuite_Id_Batch  implements Database.Batchable<sObject> { 
    global Database.QueryLocator start(Database.BatchableContext BC)  {
        String query = 'Select Id,NetSuite_Id_Clone__c,NetSuite_Id__c from Contact where NetSuite_Id_Clone__c!=null and NetSuite_Id__c=null';
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC,List<Contact> contacts)  {
        System.debug('#Size of List# '+contacts.size());
        System.debug('#Contact List in Update_Contact_Netsuite_Id # '+contacts);
        List<Contact> conList  = new LIst<Contact>();
        for(Contact c:contacts){
            if(!String.isBlank(c.NetSuite_Id_Clone__c) && (c.NetSuite_Id_Clone__c != c.NetSuite_Id__c))
            {
                Contact con = new Contact(Id = c.Id, NetSuite_Id__c = c.NetSuite_Id_Clone__c);
                conList.add(con);
            }
        }
        System.debug('# conlist to update in Update_Contact_Netsuite_Id# '+conList);
        if(!conList.isEmpty())
            Database.update(conList);
        
    }
    global void finish(Database.BatchableContext BC)  {
        
    }

}