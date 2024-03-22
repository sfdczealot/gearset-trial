/*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : Batch job to assign Accounts with total spending more than $1000 to
Commandos queue manager, and the ones with total spending less than
$1000 to NBT queue manager

History
<Date>      <Authors Name>     <Brief Description of Change>
*/
global class AccountAssignment_Batch implements Database.Batchable<sObject> {
    // Remove EligibilityHandler Dependency 
    //static final string identifier = 'AC_AccountAssignment_Batch';
    //static final list<string> listCountry = EligibilityHandler.getCountryEligibility(identifier);
	static final List<String> listCountry = new List<String>{'Singapore', 'Malaysia'};
    static final String DEFAULT_QUERY =
        'SELECT Id,Agency__c, Account_Rule_Code__c, Total_Spending_12_Months__c, OwnerId,owner.ManagerId , Status__c ' +
        'FROM Account ' +
        'WHERE Country__c in (\''+string.join(listCountry, '\',\'')+'\') AND Account_Rule_Code__c != NULL AND Status__c <> \'Cancelled\'' + (Test.isRunningTest()?' AND (Account_Rule_Code__c = \'Premier\' OR Account_Rule_Code__c = \'Standard\') LIMIT 100':'');
    
    string tempCommmandosManagerId, tempNbtManagerId;
    Id commandosManagerId, nbtManagerId;
    Map<String,String> MapAccRT = new Map<String,String>();
    Map<String,String> findCommandos = new Map<String,String>(); 
    List<Account> tempAccount = new list<Account>();
    String query;
    Group qCommandos;
    List <GroupMember> rowCommandos;
    Group qNBT;        
    List <GroupMember> rowNBT; 
    
    global AccountAssignment_Batch(String query) {
        if(query == null) {
            this.query = DEFAULT_QUERY;
        } else {
            this.query = query;
        }
        this.tempNbtManagerId = getQueueManagerId('New Business Team');
        
        if(this.tempNbtManagerId <> ''){
            this.nbtManagerId = id.valueOf(this.tempNbtManagerId);
        }
        for (RecordType rt : [SELECT Id,Name FROM RecordType WHERE SObjectType='Account']){
            MapAccRT.put(rt.Name,rt.Id);
        }
        //Get Commandos Team Lead from Agencies field <Commandos_Team_Lead__c> and store it into map
        this.tempAccount = [select id, Commandos_Team_Lead__c from Account where recordtypeid =: MapACCRT.get('Agency') and Commandos_Team_Lead__c !=: null];
        for(Account Acc : tempAccount){
            this.findCommandos.put(Acc.id,Acc.Commandos_Team_Lead__c);
        }
        this.qCommandos = [SELECT Id, Name FROM Group WHERE Name =:'Commandos' AND Type = 'Queue'];        
        this.rowCommandos = new list<GroupMember>([SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :qCommandos.Id]);
        this.qNBT = [SELECT Id, Name FROM Group WHERE Name =:'New Business Team' AND Type = 'Queue'];        
        this.rowNBT = new list<GroupMember>([SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :qNBT.Id]);
    }
    
    global System.Iterable<sObject> start(Database.BatchableContext jobId) {
        return Database.getQueryLocator(query);
    }
    
    global Void execute(Database.BatchableContext jobId, List<sObject> recordList) {
        // Get all account
        List<Account> toUpdate = new List<Account>();
        for(sObject obj : recordList) {
            Account acc = (Account)obj;
            if(shouldGoToCommandos(acc)) {
                
                System.debug('should go to commandos');
                commandosManagerId = findCommandos.get(String.valueOF(acc.Agency__c));
                if(commandosManagerId <> null && acc.ownerId <> commandosManagerId && acc.owner.ManagerId <> commandosManagerId ){
                    acc.OwnerId = commandosManagerId;
                    toUpdate.add(acc);    
                }else if(commandosManagerId == null){
                    acc.OwnerId = id.valueOF(label.PG_LABEL_Default_Commandos_Team_Lead);
                    toUpdate.add(acc); 
                }
                
                
            } else if(shouldGoToNbt(acc)) {
                System.debug('should go to nbt');
                if(!isMember(acc,'New Business Team')){
                    if(nbtManagerId <> null && acc.ownerId <> nbtManagerId){
                        acc.OwnerId = nbtManagerId; 
                        toUpdate.add(acc);
                    }    
                }
                
            }
        }
        if(toUpdate.size() > 0) {
            Database.update(toUpdate, false);
        }
    }
    
    global Void finish(Database.BatchableContext jobId) {
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : get Queue NBT Manager 
Input 		: Salesforce Queue name.
History
<Date>      <Authors Name>     <Brief Description of Change>
*/
    private string getQueueManagerId(String queueName) {
        Group q = [SELECT Id, Name FROM Group WHERE Name = :queueName AND Type = 'Queue'];        
        list <GroupMember> row = new list<GroupMember>([SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :q.Id LIMIT 1]);
        if(row.size()>0){
            GroupMember gm = [SELECT Id, GroupId, UserOrGroupId FROM GroupMember WHERE GroupId = :q.Id LIMIT 1];
            User u = [SELECT Id, Name, ManagerId, Manager.Name FROM User WHERE Id = :gm.UserOrGroupId];
            return u.ManagerId;
        }
        return null;
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to specify which Agent should go to Commandos Manager. 
Input 		: Salesforce Account.

History
<Date>      <Authors Name>     <Brief Description of Change>
*/  
    private Boolean shouldGoToCommandos(Account acc) {
        String subscription = acc.Account_Rule_Code__c;
        Decimal total = acc.Total_Spending_12_Months__c;
        if(subscription.equalsIgnoreCase('Standard') || subscription.equalsIgnoreCase('Advance')) {
            System.debug('Standard or Advance');
            if(total != null && total >= 1000) {
                return true;
            }
        } else if(subscription.equalsIgnoreCase('Business') || subscription.equalsIgnoreCase('Premier') || subscription.equalsIgnoreCase('VIP')) {
            System.debug('Business, Premier or VIP');
            return true;
        }
        
        return false;
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to specify which Agent should go to NBT Manager. 
Input 		: Salesforce Account.

History
<Date>      <Authors Name>     <Brief Description of Change>
*/      
    private Boolean shouldGoToNbt(Account acc) {
        String subscription = acc.Account_Rule_Code__c;
        Decimal total = acc.Total_Spending_12_Months__c;
        if(subscription.equalsIgnoreCase('Standard') || subscription.equalsIgnoreCase('Advance')) {
            if(total != null && total < 1000) {
                return true;
            }
        }
        if(subscription.equalsIgnoreCase('Trial')){
            return true;
        }
        return false;
    }
    /*------------------------------------------------------------
Author      : Steven Junaidy
Company     : Viseo Asia PTE LTD
Description : to prevent account assignment goes to their own manager.
<Date>      <Authors Name>     <Brief Description of Change>
*/
    private Boolean isMember(Account acc, String queueName){
        
        if(queueName == 'Commandos'){
            for(GroupMember member: rowCommandos){
                if(acc.OwnerId == member.UserOrGroupId){
                    return true;
                }
            }
        }else if(queueName == 'New Business Team'){
            for(GroupMember member: rowNBT){
                if(acc.OwnerId == member.UserOrGroupId){
                    return true;
                }   
            }
        }else{
            return false;
        }    
        return false;
    }
}