global class PGUserSandboxRefresh_Batch implements Database.Batchable<sObject>{

    String query, strParameter;
    

    global Database.QueryLocator start(Database.BatchableContext BC)  {
        // to fetch Integration profile and admin profile
        query = 'Select id,email from user where (profileid = \'00e7F000001AbicQAC\' or profile.name=\'Integration Profile\') and isactive = true';
        system.debug(query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, list<User> UserReset) {
        
        if(UserReset.size() > 0){
            
            for(User d : UserReset){
                //system.debug(d.email);
                if(d.email.contains('.invalid')){
                    system.debug(d.email);
                    String e = d.Email;
                    e.replace('.invalid', '');
                    System.debug(e);
                    d.email = e;
                    update d;
                }
            }
            
        }
        
    }
    
    global void finish(Database.BatchableContext BC) {

    }
    
}