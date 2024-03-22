trigger taskCreationSSTrigger on Task_creation_for_Self_Serve__e (after insert) {

    List<Task> taskList = new List<task>();
    List<String> agentIDList = new List<String>();
    Map<String,Task_creation_for_Self_Serve__e> taskMap = new  Map<String,Task_creation_for_Self_Serve__e>();
    for(Task_creation_for_Self_Serve__e tc : Trigger.New){
        String agentKey = tc.Region__c+tc.AgentID__c;
        agentIDList.add(agentKey.toLowerCase());
        taskMap.put(agentKey.toLowerCase(),tc);
        
    }
    system.debug(Trigger.New);
    system.debug(taskmap);
    system.debug(agentIDList);
    Map<String,List<Task>> assignTaskOwner = new Map<String,List<Task>>();
    for(Account acc : [SELECT id, Name, AgentKey__c, Phone,personcontactid, (select id,ownerid,
                                                             owner.userrole.ParentRoleId,owner.isActive from opportunities 
                                                             where (stageName not in ('Converted','Closed Lost','Closed won'))
                                                             and Opportunity_Type__c ='B2C - Renewal')
                       FROM Account where AgentKey__c  in: agentIDList]){
                           Task t = new Task();
                           DateTime dT = taskMap.get(acc.AgentKey__c.toLowerCase()).preferred_slot_from_date__c;
                           Date fromDate = date.newinstance(dT.year(), dT.month(), dT.day());
                           DateTime dT1 = taskMap.get(acc.AgentKey__c.toLowerCase()).preferred_slot_from_date__c;
                           t.ActivityDate = date.newinstance(dT1.year(), dT1.month(), dT1.day());
                           system.debug(acc.name);
                           system.debug(taskMap.get(acc.AgentKey__c.toLowerCase()));
                          // Datetime dt = System.now();

//Convert it into Indian Standard Time(dtIST).
String dtSGT = dt.addHours(8).format('yyyy-MM-dd HH:mm', 'SGT');


                           t.Subject='Renewal Agent '+acc.name+' Request Callback at '+
                               +dtSGT;
                           if(acc.Opportunities.size()>0){
                               t.whatid = acc.Opportunities[0].id;
                           }
                           else
                               t.whatid = acc.id;
                           t.whoid=acc.personcontactid;
                           // t.time__c = taskMap.get(acc.AgentKey__c.toLowerCase()).Time__c;
                           t.phone__c = acc.Phone;
                           t.preferred_slot_to_date__c = taskMap.get(acc.AgentKey__c.toLowerCase()).preferred_slot_to_date__c ;
                           t.preferred_slot_from_date__c = taskMap.get(acc.AgentKey__c.toLowerCase()).preferred_slot_from_date__c ;
                           
                           t.status='open';
                           if(acc.Opportunities.size()>0){
                               if(acc.Opportunities[0].Owner.IsActive){
                                   t.OwnerId = acc.Opportunities[0].OwnerId;
                                   taskList.add(t);
                               } else {
                                   if(assignTaskOwner.containsKey(acc.Opportunities[0].owner.userrole.ParentRoleId)){
                                       List<Task> tempList =New List<Task>();
                                       tempList.addAll(assignTaskOwner.get(acc.Opportunities[0].owner.userrole.ParentRoleId));
                                       tempList.add(t);
                                       assignTaskOwner.put(acc.Opportunities[0].owner.userrole.ParentRoleId,tempList);
                                   }else{
                                       List<Task> tempList =New List<Task>();
                                       tempList.add(t);
                                       assignTaskOwner.put(acc.Opportunities[0].owner.userrole.ParentRoleId,templist);
                                   }
                                   
                               }
                           }
                       }
     system.debug('qwerty -- '+ taskList);
    list<String> roleId = new List<String>(); 
    if(!assigntaskOwner.isEmpty()){
        for(User u : [select id,userRoleId from User where userRoleId in: assigntaskOwner.keySet()]){
            List<task> tList = assigntaskOwner.get(u.userRoleId);
            system.debug('qwerty -- '+tList);
            
            if(!roleId.contains(u.userRoleId)){
            for(Task t : tList){
               
                t.Ownerid= u.id;
            }
            
            roleId.add(u.userRoleId);
           // assigntaskOwner.remove(u.userRoleId);
            taskList.addAll(tList);
        }
        }
    }
    system.debug('qwerty -- '+ taskList);
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.emailHeader.triggerUserEmail = true;
        database.insert(taskList,dlo);
}