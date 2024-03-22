/* Created On : December 7,2020
 * Description:Coverage of Update_Contact_Netsuite_Id_Batch.apxc
 */
@isTest
public class Update_Contact_Netsuite_Id_Batch_Test {
    

    @isTest
    static void testMethod1() 
    {
        List<Contact> lstCon= new List<Contact>();
        for(Integer i=0 ;i <200;i++)
        {
            Contact con = new Contact();
            con.FirstName = 'FirstName'+i;
            con.LastName = 'LastName'+i;
            con.Email = 'test'+i+'@'+'test'+i+'.com'; 
            con.NetSuite_Id_Clone__c = 'externalId'+i;
            lstCon.add(con);
        }
        
        insert lstCon;
        
        Test.startTest();

            Update_Contact_Netsuite_Id_Batch obj = new Update_Contact_Netsuite_Id_Batch();
            DataBase.executeBatch(obj); 
            
        Test.stopTest();
    }
}