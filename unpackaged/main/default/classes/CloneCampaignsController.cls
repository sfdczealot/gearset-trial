public class CloneCampaignsController {
    
    static boolean initialized= true;
    
    @AuraEnabled
    public static sobject cloneChild(String objectAPIName,  Map<Id,sobject> orginialCloned, List<Id> recordIds){
        Id currentUserId = UserInfo.getUserId();
        List<UserRecordAccess> currentUserRecAccess = [SELECT HasEditAccess,RecordId 
                                                       FROM UserRecordAccess 
                                                       WHERE UserId =: currentUserId
                                                       AND RecordId In : recordIds 
                                                      ];
        
        
        if(currentUserRecAccess.size()>0 && !currentUserRecAccess[0].HasEditAccess) {
            return null;
        } else {
            //Objects eligible to clone
            //Set<String> querysobject = new Set<String>{'Campaign','Campaign_Eligibility__c','Promo_Mechanic__c','Entitlement_Promotion__c','Excluded_Promotion__c'};
            Set<String> querysobject = new Set<String>{'Campaign','Campaign_Eligibility__c','Promo_Mechanic__c','Entitlement_Promotion__c'};
                //Fetch the fields of the object to be cloned   
                Map <String, Schema.sobjectType> schemaMap = Schema.getGlobalDescribe();
            Set <String> fieldMap = schemaMap.get(objectAPIName).getDescribe().fields.getMap().keySet();
            List<String> finalFields = new List<String>() ;
            finalFields.addAll(fieldMap);
            
            Map<String,String> childs = new Map<String,String>();//Store childs with relationshipname
            Map<String,String> childsFields = new Map<String,String>();//Store fields of child object
            
            //Update maps with fileds and relationshipname of the object
            for (Schema.ChildRelationship cr: schemaMap.get(objectAPIName).getDescribe().getChildRelationships()) 
            {
                
                if(cr.getField().getDescribe().isAccessible()&& cr.getField().getDescribe().isCreateable()&&cr.getField().getDescribe().isAccessible() && cr.getRelationshipName()!=null){
                    
                    if(querysobject.contains(''+cr.getChildsobject())){
                        childs.put(''+cr.getChildsobject()  , ''+cr.getRelationshipName());
                        childsFields.put(''+cr.getRelationshipName()  , ''+cr.getField());
                        
                    }
                }
            } 
            //Prepare query 
            List<String> subqueries = prepareSubqueries(childs, schemaMap);
            String query ='';
            
            if(!subqueries.isempty()){
                query =
                    'SELECT ' + String.join(finalFields, ',')+
                    ','+String.join(subqueries, ',') +
                    ' FROM ' +objectAPIName +
                    ' WHERE Id IN : recordIds';
            }else{
                query =
                    'SELECT ' + String.join(finalFields, ',')+
                    ' FROM ' +objectAPIName +
                    ' WHERE Id IN : recordIds';  
            }     
            
            List<sobject> parentObj = Database.query(query);
            
            sobject clonedRecord;
            sobject parentRecordId;
            if(parentObj == null || parentObj.isEmpty()){
                return null;
            }
            parentRecordId = parentObj[0];
            List<sobject> ToclonedRecords = new List<sobject>();      
            Map<Id,sobject> OriginalClone = new Map<Id,sobject>();
            
            wrapper wr = new  wrapper();
            
            //Excecutes only once to clone the parent
            if(initialized ==true){
                initialized = false;
                clonedRecord = parentRecordId.clone(false,false,false,false);
                //Since the length of name field is 80
                String name = clonedRecord.get('Name') +' Clone';
                if(name.length()>80)
                    clonedRecord.put('Name', name.substring(0, 80));
                else
                    clonedRecord.put('Name', name);
                
                clonedRecord.put('IsActive', false);
                clonedRecord.put('StartDate',  Date.newInstance(2000,1,1)); 
                clonedRecord.put('EndDate',  Date.newInstance(2000,1,31));
                clonedRecord.put('Campaign_Start_DateTime__c', DateTime.newInstance(2000,1,1));
                clonedRecord.put('Campaign_End_DateTime__c', DateTime.newInstance(2000,1,31));
                insert clonedRecord;
                // Clone the direct child of the parent
                wr = cloneChildren(parentRecordId, clonedRecord, childs  ,childsFields);
                ToclonedRecords.addall(wr.ToclonedRecords);
                OriginalClone.putall(wr.OriginalClone);
                
            }else{
                // Clone the grand childs of the parent
                
                for(sobject s : parentObj){
                    wr = cloneChildren( s,orginialCloned.get(s.id), childs  ,childsFields); 
                    ToclonedRecords.addall(wr.ToclonedRecords);
                    OriginalClone.putall(wr.OriginalClone);
                }
                
            }
            if(!OriginalClone.values().isempty())
                Database.insert(OriginalClone.values(),false); 
            
            
            String objectAPI = '';
            String objId ='';
            
            
            if (!OriginalClone.isempty() && !ToclonedRecords.isempty()) {
                
                //Store the record Id with respective object API name
                Map<String,list<Id>> objectApiWithRecords = new Map<String,list<Id>>();
                
                for(sobject parent : ToclonedRecords){
                    
                    objId = parent.id;
                    String keyPrefix = objId.substring(0,3);
                    for( Schema.SObjectType obj : schemaMap.Values() ){
                        String prefix = obj.getDescribe().getKeyPrefix();
                        if(prefix == keyPrefix){
                            objectAPI = obj.getDescribe().getName();
                            //To segregrate records with their API name
                            if(!objectApiWithRecords.containskey(objectAPI))
                                objectApiWithRecords.put(objectAPI,new list<id>{parent.id});
                            else{
                                objectApiWithRecords.get(objectAPI).add(parent.id);
                            }
                        }
                    } 
                }
                System.debug(objectAPI);
                for(String api : objectApiWithRecords.keyset()){
                    cloneCampaignsController.cloneChild(api,OriginalClone,objectApiWithRecords.get(api)); 
                }       
            }
            return clonedRecord;
        }
    }  
    
    //To clone the child records
    public static wrapper cloneChildren(sobject parent,sobject cloneParent,Map<String , String> childRelatedListObjects, Map<String , String> childRelatedListObjects1 ){
        
        //Stores all the childs of the parent to be cloned 
        list<sobject>  allParentRecords = new list<sobject>();
        //Stores the original record with their cloned ones
        Map<Id,sobject> OriginalClone = new Map<Id,sobject>();
        
        for (String childObjectDefinition : childRelatedListObjects.values()) {
            Map<Id,sobject> orginialCloned = new Map<Id,sobject>();
            List<sobject> parentRecords = new list<sobject>();
            
            parentRecords = parent.getsobjects(childObjectDefinition);//Child of parent to be cloned
            
            if(parentRecords!=null){
                allParentRecords.addall(parentRecords);
                for(sobject parntRecord : parentRecords){
                    
                    sobject cloned = parntRecord.clone(false,false,false,false);
                    OriginalClone.put(parntRecord.id,cloned);
                    orginialCloned.put(parntRecord.id,cloned);
                }
                for (sobject record : orginialCloned.values()) {
                    
                    record.put(childRelatedListObjects1.get(childObjectDefinition), cloneParent.Id);//Assign Id of cloned parent to child for parenting
                    // Append Clone to name of records
                    String name = record.get('Name') +' Clone';
                    if(name.length()>80)
                        record.put('Name', name.substring(0, 80));
                    
                    else
                        record.put('Name', name);
                    if(childObjectDefinition== 'ChildCampaigns'){
                        record.put('IsActive', false);
                        record.put('StartDate', Date.newInstance(2000,1,1)); 
                        record.put('EndDate', Date.newInstance(2000,1,31));
                        record.put('Campaign_Start_DateTime__c', DateTime.newInstance(2000,1,1));
                        record.put('Campaign_End_DateTime__c', DateTime.newInstance(2000,1,31));
                    }
                    
                }   
                orginialCloned = new Map<Id,sobject>();
                
            }
            
            
        }
        
        wrapper wr = new wrapper();
        wr.ToclonedRecords.addall(allParentRecords);
        wr.OriginalClone = OriginalClone;
        
        return wr;
    }
    
    public static List<String> prepareSubqueries(Map<String , String> childrelatedListObjects, Map <String, Schema.sobjectType> schemaMap ){
        
        List<String> subqueries = new List<String>();
        for(String childObject : childrelatedListObjects.keySet()){
            List<String> childFields = new List<String>();
            Map <String, Schema.sobjectField> fieldMap = schemaMap.get(childObject).getDescribe().fields.getMap();
            for(Schema.sobjectField sof : fieldMap.values()){
                DescribeFieldResult dfr = sof.getDescribe();
                if(dfr.isCreateable()){
                    childFields.add(dfr.getName());
                }
            }
            if(!childFields.isEmpty()){
                String query = '(SELECT ' + String.join(childFields, ',') + ' FROM ' + childrelatedListObjects.get(childObject) + ')';
                subqueries.add(query);
            }
            
        }
        return subqueries;
    }
    //  Wrapper to store records to be cloned and map to store them with records they are cloned to
    public class wrapper{
        
        List<sobject> ToclonedRecords = new List<sobject>();
        Map<Id,sobject> OriginalClone = new Map<Id,sobject>();
    }   
}