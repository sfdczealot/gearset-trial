//Test Class : customLookupController_Test
public without sharing class customLookupController {

    @AuraEnabled(cacheable=true)
    public static List<sObject> search(String searchTerm, string myObject, String filter,String objPage) {
        System.debug('filter'+filter);
        String myQuery = null;
        if(filter != null && filter != ''){
             if(searchTerm == null || searchTerm == ''){
           myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL AND '+filter+' ORDER BY LastViewedDate DESC LIMIT 10';
              }else{
              myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT 10';
               
             }
        }
        else {
            if(searchTerm == null || searchTerm == ''){
                myQuery = 'Select Id, Name from '+myObject+' Where LastViewedDate != NULL ORDER BY LastViewedDate DESC';
            }
            else {
                if(filter != null && filter != ''){
                 myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm + '%\' AND '+filter+' LIMIT 10';
                  
                }else{
                myQuery = 'Select Id, Name from '+myObject+' Where Name Like  \'%' + searchTerm;
                }
            }
        }
        system.debug('myQuery@@'+myQuery);
        List<sObject> lookUpList = database.query(myQuery);
        return lookUpList;
    }
}