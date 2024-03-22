//Test Class : OverlappingAgentDetailsController_test
public class OverlappingAgentDetailsApexController {
    public class wrapperClass{
        
        @auraEnabled
        public Map<String,String> fieldsAPI;
        @auraEnabled
        public List<String> getLabels;
        @auraEnabled
        public Map<String,String> getSearchedLabels;
        @auraEnabled
        public String destinationField;
        @auraEnabled
        public String EndPoint;
        @auraEnabled
        public List<Map<String,Object>> fmDisplayList;
        @auraEnabled
        public string mappedId;
        @auraEnabled
        public String sObjName;
        @auraEnabled
        public relatedListWrapper RLW;
        @auraEnabled
        public Map<String,String> innerFieldsAPI;
        @auraEnabled
        public Map<String,String> detailsFieldsAPI;
        @auraenabled
        Public boolean isOverlappingAgent;
        @auraEnabled
        public String AgentId;
        @auraEnabled
        public  Map<String,List<object>> fmInnerList;
        @auraEnabled
        public  Map<String,list<String>> innerFields;
        @auraEnabled
        public Map<String,list<String>> relatedFieldsAPI;
        
        wrapperClass(){}
        wrapperClass(Map<String,String> getSearchedLabels,String destinationField,
                     List<String> getLabels,Map<String,String> fieldsAPI, List<Map<String,Object>> fmDisplayList,
                     String EndPoint,String mappedId,String sObjName,Map<String,String> innerFieldsAPI,Map<String,String> detailsFieldsAPI,boolean isOverlappingAgent,String AgentId,
                     Map<String,List<object>> fmInnerList, Map<String,list<String>> innerFields,Map<String,list<String>> relatedFieldsAPI){
                         
                         this.getLabels = getLabels;
                         this.destinationField = destinationField;
                         this.getSearchedLabels = getSearchedLabels;
                         this.fieldsAPI = fieldsAPI;
                         this.fmDisplayList = fmDisplayList;
                         this.endpoint = endpoint;
                         this.mappedId = mappedId;
                         this.sObjName = sObjName;
                         this.innerFieldsAPI = innerFieldsAPI;
                         this.detailsFieldsAPI = detailsFieldsAPI;
                         this.isOverlappingAgent = isOverlappingAgent;
                         this.AgentId = AgentId;
                         this.fmInnerList = fmInnerList;
                         this.innerFields = innerFields;
                         this.relatedFieldsAPI = relatedFieldsAPI;
                     }
    }
    
    public class relatedListWrapper{
        @auraEnabled
        public  String Label;
        @auraEnabled
        public  List<Map<String,Object>> relatedList;
    }
    
    @auraEnabled
    public static wrapperClass fetchRecords(String objRecId){
        
        
        List<Map<String,Object>> fmDisplayList = new  List<Map<String,Object>> ();
        List<Map<String,Object>> detailsDisplaylist = new  List<Map<String,Object>> ();
        
        String mappedId;
        Id objId = (Id) objRecId;
        String AgentId;
        String sObjName = objId.getSObjectType().getDescribe().getName();
        Boolean showComponent = true;
        Account acc = new Account();
        Opportunity opp;
        if(sObjName == 'Account'){
            acc = [select id,External_field__c from Account
                   where id=: objRecId]; 
            if(acc.External_field__c==null||acc.External_field__c == 'undefined'||acc.External_field__c==''){
                showComponent = false;
            }
        }else{
            opp = [select id,Account.External_field__c,External_field__c,country__c from opportunity
                   where id=: objRecId];
            if(opp.Account.External_field__c == null){
                showComponent = false;
            }
        }
        List<Search_and_tag_admin__c > sdList = new List<Search_and_tag_admin__c > ();
        String recordtype;
        List<Sobject> sobjrecType = SearchRecord_cc.validation(objRecId);
        recordtype = (String) sobjrecType[0].get('recordtypeid');
        
        sdList = [select id, Destination_Object_API__c , Client__c, ClientID__c, Source_Object_API__c ,Search_Field__c, 
                  Password__c, UserName__c, EndPoint__c,External_Field__c  ,Destination_Recordtype_Id__c , 
                  (Select id, from__c, To__c,label__c,Only_for_creation__c,where_clause__c,Search_List__c, Agent_Display__c,
                   related_Object_API__c ,Related_List_Label__c,Sequennce__c
                   from Field_Mappings__r
                   where isActive__c =true and Agent_Display__c  = true order by Sequennce__c asc)
                  from Search_and_tag_admin__c   where Source_Object_API__c =: sObjName 
                  and Source_RecordTypeID__c  =: recordtype and Active__c =true];
        
        Map<String,String> APIMap = new Map<String,String>();
        if(sdList.isEmpty()){
            
            throw new AuraHandledException('No configuration found related to '+ sObjName);
        }
        else{
            
            Search_and_tag_admin__c  sd = sdList[0];
            Map<String,String> res = SearchRecord_cc.getToken(sd);
            MAP<String,String> licenseDetailsMap = new  MAP<String,String> ();
            Map<String,String> sourceMap = new Map<String,String>();
            Map<String,object> destinationMap = new Map<String,object>();
            Map<String,String>desFieldDataTypeMap = new Map<String,String>();
            List<String> tempList = new List<String>();
            List<String> diplayListFields = new List<String>();
            Map<String,String> innerFieldsAPI = new Map<String,String>();
            Map<String,list<String>> innerFields = new Map<String,list<String>>();
            Map<String,list<String>> relatedFieldsAPI = new Map<String,list<String>>();
            Map<String,String> detailsFieldsAPI = new Map<String,String>();
            Map<String,List<String>> innerQueryMap = new Map<String,List<String>>();
            Map<String,Field_Mapping__c> fmMap = new Map<String,Field_Mapping__c>();
            Map<String,List<object>> fmInnerList = new  Map<String,List<object>>();  
            List<String> innerQuery = new List<String>();      
            Map<String,String> LabelAPi = new Map<String,String>();
            
            for(Field_Mapping__c fm : sd.Field_Mappings__r){
                
                if(fm.related_Object_API__c!=null){
                    //  system.debug()
                    fmMap.put(fm.related_Object_API__c+fm.to__c,fm);
                    if(innerQueryMap.containsKey(fm.related_Object_API__c)){
                        list<String> temp = new List<String>();
                        temp.addAll(innerQueryMap.get(fm.related_Object_API__c));
                        temp.add(fm.To__c);
                        innerQueryMap.put(fm.related_Object_API__c,temp);
                        if(!innerFields.containskey(fm.related_Object_API__c)){
                            list<String> fields = new list<String>();
                            fields.add(fm.label__c);
                            innerFields.put(fm.related_Object_API__c,fields); 
                        }else{
                            innerFields.get(fm.related_Object_API__c).add(fm.label__c); 
                        }
                        if(!relatedFieldsAPI.containskey(fm.related_Object_API__c)){
                            list<String> fieldAPI = new list<String>();
                            fieldAPI.add(fm.from__c);
                            relatedFieldsAPI.put(fm.related_Object_API__c,fieldAPI); 
                        }else{
                            relatedFieldsAPI.get(fm.related_Object_API__c).add(fm.from__c); 
                        }
                    }
                    else{
                        list<String> temp = new List<String>();
                        temp.add(fm.To__c);
                        innerQueryMap.put(fm.related_Object_API__c,temp);
                        APIMap.put(fm.related_Object_API__c,fm.related_list_label__c);
                        labelAPi.put(fm.related_Object_API__c,fm.related_list_label__c);
                        innerFieldsAPI.put(fm.related_Object_API__c,fm.Related_List_Label__c);
                        if(!innerFields.containskey(fm.related_Object_API__c)){
                            list<String> fields = new list<String>();
                            fields.add(fm.label__c);
                            innerFields.put(fm.related_Object_API__c,fields); 
                        }else{
                            innerFields.get(fm.related_Object_API__c).add(fm.label__c); 
                        }
                        if(!relatedFieldsAPI.containskey(fm.related_Object_API__c)){
                            list<String> fieldAPI = new list<String>();
                            fieldAPI.add(fm.from__c);
                            relatedFieldsAPI.put(fm.related_Object_API__c,fieldAPI); 
                        }else{
                            relatedFieldsAPI.get(fm.related_Object_API__c).add(fm.from__c); 
                        }
                        
                    }
                    
                }else{
                    fmMap.put(fm.to__c,fm);
                    APIMap.put(fm.to__c,fm.label__c);
                    detailsFieldsAPI.put(fm.to__c,fm.label__c);
                }
                system.debug(innerQueryMap);
                if(fm.Agent_Display__c && fm.related_Object_API__c==null)
                    diplayListFields.add(fm.To__c);
                
                
            }  system.debug(diplayListFields);
            if(sd.Source_Object_API__c != 'Opportunity') {
                
                if(sd.Destination_Recordtype_Id__c  !=null)
                    destinationMap.put('recordtypeid',sd.Destination_Recordtype_Id__c );
                tempList = new List<String>(); 
                tempList.addAll(destinationMap.keySet());
            }
            String whereClause='';
            
            
            if(sd.Source_Object_API__c  == 'Opportunity'){
                
                mappedId = opp.External_field__c;
                if(opp.country__c != 'Malaysia'){
                    // throw new AurahandledException('Search & tag should only be used with Malaysia records');
                    showComponent = false;
                }
                
                if(opp.Account.External_field__c == null){
                    // throw new AuraHandledException('Related Account is not mapped to REA');
                    showComponent = false;
                }
                if(opp.Account.External_field__c != null){
                     whereClause+=' Where+id=\''+opp.External_field__c+'\'';
                }
               
            }
            else {
                
                
                whereClause+='+Where+(recordtypeid=\''+destinationMap.get('recordtypeid')+'\'';
                if(acc.External_field__c!=null)
                    whereClause+='AND+id=\''+acc.External_field__c+'\'';
                
                whereClause += ')';
                integer i=0;
                
            }
            
            String s = whereClause.replaceAll(' ','+');
            String selectQuery='Select+';
            system.debug('****'+whereClause);
            String endpoint=res.get('URL')+ '/services/data/v50.0/query/?q=';
            
            for(String iqm : innerQueryMap.keySet()){
                selectQuery += '(Select+'+String.join(innerQueryMap.get(iqm),',')+'+FROM+'+iqm+
                    +'+order+by+CreatedDate),';
            }
            endpoint += selectQuery;
            integer i =0;
            for(String field : diplayListFields){
                System.debug(field);
                if(i==0)
                    endpoint+= field; 
                else
                    endpoint+= ','+field;
                i++;
            } 
            endpoint += '+from+'+sd.Destination_Object_API__c +s;
            
            List<Object> sobjectList =  SearchRecord_cc.getRecords(endpoint,'GET',res.get('token'),'Get',null);
            
            
            for(object aa: sObjectList){
                
                MAP<STring,Object> f;
                
                f = (MAP<STring,Object>)(aa);
                
                Map<String,Object>  fmDetailMap = new Map<String,Object> ();
                Map<String,Object>  fmValueMap = new Map<String,Object> ();
                
                for(String dm : diplayListFields){
                    
                    labelAPi.put(dm,APIMap.get(dm));
                    if(dm.contains('.')){
                        list<String> str = dm.Split('\\.');
                        
                        Map<String,Object> a1 =(Map<String,Object>)f.get(str[0]);
                        
                        if(a1!=null){
                            if(a1.containsKey(str[1])){
                                
                                Field_Mapping__c fm = fmMap.get(dm);
                                
                                field_mapping__c fmNew = new field_mapping__c();
                                fmNew.from__c = a1.get(str[1])+'';
                                fmNew.label__c=fm.label__c;
                                fmNew.to__c =fm.to__c;
                                
                                fmValueMap.put(dm,fmNew);
                                
                            }
                        }
                    }
                    else{
                        
                        Field_Mapping__c fm = fmMap.get(dm);
                        field_mapping__c fmNew = new field_mapping__c();
                        fmNew.from__c = f.get(dm)+'';
                        if(fmMap.containsKey(dm)){
                            fmNew.label__c=fm.label__c;
                            fmNew.to__c =fm.to__c;
                        }
                        if(fmNew.label__c =='Id'){
                            AgentId = fmNew.from__c;
                        }
                        
                        fmValueMap.put(dm,fmNew);
                        /*if(opp != null){
                            if(dm == 'Id' &&  fmNew.from__c == opp.External_field__c){
                                system.debug(f.get('StageName'));
                                if(f.get('StageName') == 'Closed Won'){
                                    Throw new AurahandledException('Overlapping Opportunity is already closed won');
                                }
                            }
                        }*/
                    }
                }
                Map<String,Object> relatedList = new Map<String,Object>();
                for(String iqm:innerqueryMap.keySet()){
                    
                    list<String> fieldList = innerqueryMap.get(iqm);
                    Map<String,Object> obj= (Map<String,Object>)f.get(iqm);
                    if(obj != null){
                        List<Object> a = (List<object>)obj.get('records');
                        fmInnerList.put(iqm,a);
                        
                        
                    }
                    relatedListWrapper wrp = new relatedListWrapper(); 
                }
                fmDisplayList.add(fmValueMap);
                
                
            }
            
            templist = new List<String>();
            tempList.addAll(sourceMap.keySet());
            
            wrapperClass oWrapper = new wrapperClass(labelAPi,
                                                     sd.External_Field__c,tempList,APIMap,
                                                     fmDisplayList,res.get('URL'),mappedId,sObjName,innerFieldsAPI,detailsFieldsAPI,showComponent,AgentId,
                                                     fmInnerList,innerFields,relatedFieldsAPI);
            return oWrapper;  
        }
    }   
}