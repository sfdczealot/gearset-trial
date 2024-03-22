/*
* TestClass : ProcessingBatch_Test
*/
public class ProcessingBatch implements DataBase.Batchable<id>, Database.Stateful { 
    
    public map<id,list<sObject>> idVslistobjectsMap;
    public list<id> finalList;
    public string fieldForMapping;
    public map<id,list<String>> allQueriesMap;
    public map<id,string> allMethodsMap;
    
    public ProcessingBatch(map<id,list<String>> allQueriesMap, map<id,string> allMethodsMap, String fieldForMapping){
        
        system.debug('allQueriesMap--->>> '+allQueriesMap);
        system.debug('allMethodsMap--->>> '+allMethodsMap);
        system.debug('fieldForMapping--->>> '+fieldForMapping);
        idVslistobjectsMap = new map<id,list<sObject>>();
        finalList = new list<id>();
        this.fieldForMapping = fieldForMapping;
        this.allQueriesMap = allQueriesMap;
        this.allMethodsMap = allMethodsMap;
        
        if(allQueriesMap != null && !allQueriesMap.isEmpty())
            finalList.addAll(allQueriesMap.keySet());
        
        if(allMethodsMap != null && !allMethodsMap.isEmpty())
            finalList.addAll(allMethodsMap.keySet());
        
        
    }
    public Iterable<Id> start(DataBase.BatchableContext Bc){
        
        return finalList;
    }
    
    public void execute(DataBase.BatchableContext Bc,List<Id> scope ){
        
        Map<String, Object> methodParams = new Map<String, Object>();
        if(allMethodsMap.containsKey(scope[0])){
            String ClassAndMethod = allMethodsMap.get(scope[0]);
            list<sObject> result = new list<sObject>();
            if(ClassAndMethod.contains(';') && ClassAndMethod.contains('#')){
                list<string> ClassAndMethodList = ClassAndMethod.split(';');
                List<String> params = ClassAndMethodList[1].split('#');
                String methodName = params[0];
                params.remove(0);
                system.debug('className>>> '+ClassAndMethodList[0]);
                system.debug('methodName>>> '+methodName);
                system.debug('params>>> '+params);
                for(Integer i=0;i<params.size();i++){
                    methodParams.put(String.valueOf(i),params[i]);
                }
                system.debug('methodParams>>> '+methodParams);
                try{
                    Callable extension = (Callable) Type.forName(ClassAndMethodList[0]).newInstance();
                    result = (list<sObject>) extension.call(methodName,methodParams);
                }catch(Exception e){}
                if(result != null && !result.isEmpty())
                    System.enqueueJob(new CREQueueable(scope[0],result));
            }else if(ClassAndMethod.contains(';')){
                list<string> ClassAndMethodList = ClassAndMethod.split(';');
                if(ClassAndMethodList != null && ClassAndMethodList.size() == 2
                   && String.isNotBlank(ClassAndMethodList[0].replaceAll( '\\s+', ''))
                   && String.isNotBlank(ClassAndMethodList[1].replaceAll( '\\s+', ''))
                  ){
                      try{
                          Callable extension = (Callable) Type.forName(ClassAndMethodList[0]).newInstance();
                          result = (list<sObject>) extension.call(ClassAndMethodList[1],null);    	
                      }catch(Exception e){}
                      
                  }
                if(result != null && !result.isEmpty())
                    System.enqueueJob(new CREQueueable(scope[0],result));
            }
        }else{
            list<sObject> listOfsObjectALL = new list<sObject>();
            list<string> listForSOQL = allQueriesMap.get(scope[0]);
            if(listForSOQL != null && !listForSOQL.isEmpty()){
                for(String str : listForSOQL){
                    try{
                        list<sObject> sObjListFromQuery= Database.query(str); 
                        if(sObjListFromQuery != null && !sObjListFromQuery.isEmpty()){
                            listOfsObjectALL.addAll(sObjListFromQuery);
                        }
                    }catch(Exception e){}
                }
                if(!listOfsObjectALL.isEmpty()){
                    System.enqueueJob(new CREQueueable(scope[0],listOfsObjectALL));
                    
                }
            }
        }
    }
    
    public void finish(DataBase.BatchableContext bc){
        // idVslistobjectsMap here after all processing 
        //if(idVslistobjectsMap != null && !idVslistobjectsMap.isEmpty() && !Test.isRunningTest())
        //Database.executeBatch(new CampaignMemberOperationsBatch(idVslistobjectsMap),1);
    }    
}