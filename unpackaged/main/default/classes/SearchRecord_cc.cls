public class SearchRecord_cc {
    
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
        wrapperClass(){}
        wrapperClass(Map<String,String> getSearchedLabels,String destinationField,
                     List<String> getLabels,Map<String,String> fieldsAPI, List<Map<String,Object>> fmDisplayList,
                     String EndPoint,String mappedId){
                         
                         this.getLabels = getLabels;
                         this.destinationField = destinationField;
                         this.getSearchedLabels = getSearchedLabels;
                         this.fieldsAPI = fieldsAPI;
                         this.fmDisplayList = fmDisplayList;
                         this.endpoint = endpoint;
                         this.mappedId = mappedId;
                     }
    } 
    public class bothWrapper{
        @auraEnabled
        public  wrapperClass wc;
        @auraEnabled
        public fieldswrapperClass fwc;
        @auraEnabled 
        public string ObjectName;
        
    }
    public class fieldswrapperClass{
        @auraEnabled
        public string objName;
        @auraEnabled
        public List<field_Mapping__c> fmList;
    }
    public static List<sObject> validation(String objRecId ){
        system.debug('validation');
        Date d = date.parse('03/01/2022');
        Id objId = (Id) objRecId;
        //  String externalId;
        String sObjName = objId.getSObjectType().getDescribe().getName();
        
        //if(sObjName == 'account'){
        String recQuery ='select recordtypeid ';
        if(sObjName == 'account'){
            recQuery+= ',NetSuite_Id__c,isPersonAccount,AgentNet_ID__c,Test_Account__c ,Country__c ';
        }
        if(sObjName == 'Opportunity'){
            recQuery+= ',account.NetSuite_Id__c,Country__c,account.isPersonAccount,account.AgentNet_ID__c,createddate,'+
                +'account.Test_Account__c ';
        }
        recQuery += 'from ' +sObjName+'  where id =: objRecId';
        
        List<Sobject> sobjrecType = database.query(recQuery);
        sobject sObjectRec = sobjrecType[0];
        if(sObjName == 'account'){
            system.debug('for Account');
            
            if((Boolean)sObjectRec.get('Test_Account__c')){
                throw new AurahandledException('This is a test account');
            }
            if((Boolean)sObjectRec.get('isPersonAccount')){
                if(sObjectRec.get('AgentNet_ID__c')==null){
                    throw new AurahandledException('Please sync record to AdminNet');
                }
            }
            else if(sObjectRec.get('NetSuite_Id__c')==null){
                throw new AurahandledException('Please sync record to Netsuite');
                
            }
        } 
        else  if(sObjName == 'Opportunity'){
            system.debug('for opportunity');
            system.debug((Boolean) sObjectRec.getSobject('Account').get('Test_Account__c'));
            system.debug((Boolean) sObjectRec.getSobject('Account').get('isPersonAccount'));
            system.debug(sObjectRec.getSobject('Account').get('AgentNet_ID__c')==null);
            if((Boolean) sObjectRec.getSobject('Account').get('Test_Account__c')){
                throw new AurahandledException('Related account is a test account');
            }
            if((Boolean)sObjectRec.getSobject('Account').get('isPersonAccount')){
                if(sObjectRec.getSobject('Account').get('AgentNet_ID__c')==null){
                    throw new AurahandledException('Please sync related account to AdminNet');
                }
            }
            if(sObjectRec.getSobject('Account').get('NetSuite_Id__c')==null){
                throw new AurahandledException('Please sync related account to Netsuite');
                
            } 
            DateTime dT = (DateTime)sObjectRec.get('CreatedDate');
            Date createdDate = date.newinstance(dT.year(), dT.month(), dT.day());
            system.debug(createdDate < d);
            if(createdDate < d){
                throw new AurahandledException('opportunities created after 3rd Jan can be mark as overlapping');
            }
        }
        return sobjrecType;
    }
    @auraEnabled
    public static wrapperClass fetchRecords(String objRecId,String objData){
        system.debug('fetchRecords'+objData);
        
        //  List<Map<String,Object>> keyValueList = new List<Map<String,Object>> ();
        List<Map<String,Object>> fmDisplayList = new  List<Map<String,Object>> ();
        String mappedId;
        Id objId = (Id) objRecId;
        String sObjName = objId.getSObjectType().getDescribe().getName();
        List<Search_and_tag_admin__c > sdList = new List<Search_and_tag_admin__c > ();
        String recordtype;
        List<Sobject> sobjrecType = validation(objRecId);
        recordtype = (String) sobjrecType[0].get('recordtypeid');
        
        sdList = [select id, Destination_Object_API__c , Client__c, ClientID__c, Source_Object_API__c ,Search_Field__c, 
                  Password__c, UserName__c, EndPoint__c,External_Field__c  ,Destination_Recordtype_Id__c , 
                  (Select id, from__c, To__c,label__c,Only_for_creation__c,where_clause__c,Search_List__c, 
                   related_Object_API__c 
                   from Field_Mappings__r
                   where isActive__c =true and Search_List__c  = true order by related_Object_API__c desc)
                  from Search_and_tag_admin__c   where Source_Object_API__c =: sObjName 
                  and Source_RecordTypeID__c  =: recordtype and Active__c =true];
        
        Map<String,String> APIMap = new Map<String,String>();
        if(sdList.isEmpty()){
            
            throw new AuraHandledException('No configuration found related to '+ sObjName);
        }
        else{
            
            // sObject obj = (sObject)JSON.deserialize(objData,sObject.class);
            Search_and_tag_admin__c  sd = sdList[0];
            Map<String,String> res = getToken(sd);
            MAP<String,String> licenseDetailsMap = new  MAP<String,String> ();
            Map<String,String> sourceMap = new Map<String,String>();
            Map<String,object> destinationMap = new Map<String,object>();
            Map<String,String>desFieldDataTypeMap = new Map<String,String>();
            //  String sourceQuery = 'Select ';
            List<String> tempList = new List<String>();
            Map<String,List<String>> innerQueryMap = new Map<String,List<String>>();
            Map<String,Field_Mapping__c> fmMap = new Map<String,Field_Mapping__c>();
            for(Field_Mapping__c fm : sd.Field_Mappings__r){
                
                if(fm.related_Object_API__c!=null){
                    //  system.debug()
                    fmMap.put(fm.related_Object_API__c+fm.to__c,fm);
                    if(innerQueryMap.containsKey(fm.related_Object_API__c)){
                        list<String> temp = new List<String>();
                        temp.addAll(innerQueryMap.get(fm.related_Object_API__c));
                        temp.add(fm.To__c);
                        innerQueryMap.put(fm.related_Object_API__c,temp);
                    }
                    else{
                        list<String> temp = new List<String>();
                        temp.add(fm.To__c);
                        innerQueryMap.put(fm.related_Object_API__c,temp);
                    }
                    
                }else{
                    fmMap.put(fm.to__c,fm);
                    APIMap.put(fm.to__c,fm.label__c);
                }
                system.debug(innerQueryMap);
                if(fm.where_clause__c )
                    sourceMap.put(fm.from__c,fm.to__c) ;  
                //desFieldDataTypeMap.put(fm.to__c,fm.DataType__c);                
            }
            if(sd.Source_Object_API__c != 'Opportunity') {
                List<Object> objList = (List<Object>)JSON.deserializeUntyped(objData);
                
                for(Object obj : objList){
                    MAP<String,Object> temp=(MAP<String,Object>)obj;
                    if(temp.get('relatedObject')==null){
                        destinationMap.put(temp.get('key').toString(),temp.get('value').toString().trim());
                        desFieldDataTypeMap.put(temp.get('key').toString(),temp.get('dataType').toString());
                    }
                    else{
                        licenseDetailsMap.put(temp.get('key').toString(),temp.get('value').toString().trim());
                    }
                    
                }
                if(sd.Destination_Recordtype_Id__c  !=null)
                    destinationMap.put('recordtypeid',sd.Destination_Recordtype_Id__c );
                tempList = new List<String>(); 
                tempList.addAll(destinationMap.keySet());
            }
            String whereClause='';
            String orQuery='';
            Opportunity opp;
            if(sd.Source_Object_API__c  == 'Opportunity'){
                opp = [select id,Account.External_field__c,External_field__c,country__c from opportunity
                       where id=: objRecId];
                mappedId = opp.External_field__c;
                if(opp.country__c != 'Malaysia'){
                    throw new AurahandledException('Search & tag should only be used with Malaysia records');
                }
                
                if(opp.Account.External_field__c == null){
                    throw new AuraHandledException('Related Account is not mapped to REA');
                }
                whereClause+='+where+accountid=\''+opp.Account.External_field__c+'\'';
            }
            else {
                whereClause+='+Where+(recordtypeid=\''+destinationMap.get('recordtypeid')+'\'';
                if(destinationMap.containsKey('Country__pc')){
                    if(destinationMap.get('Country__pc')!=null ){
                        whereClause +='+AND+Country__pc'+'+=+\''+destinationMap.get('Country__pc')+'\'';
                        
                    }
                }
                if(destinationMap.containsKey('Country__c')){
                    if(destinationMap.get('Country__c')!=null ){
                        whereClause +='+AND+Country__c'+'+=+\''+destinationMap.get('Country__c')+'\'';
                        
                    }
                }
                whereClause += ')';
                integer i=0;
                
                
                for(String field : destinationMap.keySet()){
                    if(field != 'Country__pc' && field != 'recordtypeid' && field != 'Country__c'){
                        if(i!=0)
                            orQuery +='+AND+';
                        if(desFieldDataTypeMap.get(field) == 'text'){
                            if(field == 'PersonMobilePhone'){
                                String ph= (String)destinationMap.get(field);
                                orQuery+=  field+'+like+\'%25'+ph.replace('+','')+'%25\'';
                            }else
                                orQuery+=  field+'+=+\''+destinationMap.get(field)+'\'';
                        }
                        else
                            orQuery+=  field+'+=+'+destinationMap.get(field);
                        i++;
                    }
                    
                }
                
            }
            
            if(orQuery != ''){
                whereClause += '+AND('+orQuery+')';
            }
            String s = whereClause.replaceAll(' ','+');
            String selectQuery='Select+';
            if(sd.Source_Object_API__c  == 'Account')
                selectQuery+='(select+id,CaseNumber,subject+From+Cases+Where+isCLosed+=+False+AND+(subject=\'Tag+overlapping+agent\'+or+Subject=\'Un-Tag+overlapping+agent\')),';
            
            system.debug('****'+whereClause);
            String endpoint=res.get('URL')+ '/services/data/v50.0/query/?q=';
            if(licenseDetailsMap.isEmpty()){
                for(String iqm : innerQueryMap.keySet()){
                    selectQuery += '(Select+'+String.join(innerQueryMap.get(iqm),',')+'+FROM+'+iqm+
                        +'+order+by+CreatedDate+limit+1),';
                }
                endpoint += selectQuery+sd.Search_Field__c.replace(' ','+')+'+from+'+
                    sd.Destination_Object_API__c +s;
            }else{
                endpoint +=selectQuery;
                list<String> a = new list<String>();
                for(String field : sd.Search_Field__c.split(',')){
                    a.add('Account__r.'+field);
                }
                system.debug(innerQueryMap.get('Licences__r'));
                a.addAll(innerQueryMap.get('Licences__r'));
                
                endpoint +=String.join(a,',')+'+from+Licence__c+where+Licence_Number__c+like\''+
                    +licenseDetailsMap.get('Licence_Number__c')+'\'';
            }
            List<Object> sobjectList =  getRecords(endpoint,'GET',res.get('token'),'Get',null);
            
            Map<String,String> LabelAPi = new Map<String,String>();
            
            for(object aa: sObjectList){
                MAP<STring,Object> f;
                
                f = (MAP<STring,Object>)(aa);
                system.debug(f.containsKey('Cases'));
                if(f.containsKey('Cases')){
                    MAP<STring,Object> caseMap = (MAP<STring,Object>)(f.get('Cases'));
                    if( caseMap!=null && caseMap.containsKey('records')){
                        List<Object> caserec =  (List<Object>) caseMap.get('records');
                        for(object caseObj : caserec){
                            Map<String,Object> oCase = (Map<String,Object>)caseObj;
                            throw new AurahandledException('Case for '+oCase.get('Subject')+' '+OCase.get('CaseNumber')+' is already opened in iPP Instance');
                        }
                        system.debug(caserec);
                    }
                }
                if(!licenseDetailsMap.isEmpty()){
                    MAP<STring,Object> j;
                    j =(MAP<STring,Object>)f.get('Account__r');
                    f=j;
                }
                
                
                Map<String,Object>  fmValueMap = new Map<String,Object> ();
                system.debug(fmMap);
                for(String dm : sd.Search_Field__c.split(',')){
                    system.debug(dm);
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
                                system.debug('dm '+ dm);
                                system.debug('fm ' +fmNew);
                                
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
                        system.debug('dm '+ dm);
                        system.debug('fm ' +fmNew);
                        fmValueMap.put(dm,fmNew);
                        if(opp != null){
                            if(dm == 'Id' &&  fmNew.from__c == opp.External_field__c){
                                system.debug(f.get('StageName'));
                                if(f.get('StageName') == 'Closed Won' || f.get('StageName') == 'Closed Lost'){
                                    Throw new AurahandledException('Overlapping Opportunity is already closed won/lost');
                                }
                            }
                        }
                    }
                }
                if(!licenseDetailsMap.isEmpty())  {
                    f = (MAP<STring,Object>)(aa);
                    labelAPi.put('Licences__r','Licences');
                    list<String> fieldList = innerqueryMap.get('Licences__r');
                    String iqm ='Licences__r';
                    Map<String,Field_Mapping__c> fmList = new  map<String,Field_Mapping__c>();
                    
                    for(String d : fieldList){
                        
                        for(String p : f.keySet()){
                            
                            if(p !='attributes'){
                                
                                //  a1.put(p,l.get(p)+'');
                                if( fmMap.containsKey(iqm+p)){
                                    Field_Mapping__c fm = fmMap.get(iqm+p);
                                    field_mapping__c fmNew = new field_mapping__c();
                                    fmNew.from__c = f.get(p)+'';
                                    fmNew.label__c=fm.label__c;
                                    fmNew.to__c =fm.to__c;
                                    
                                    fmList.put(p,fmNew);
                                }
                            }
                        }
                    }
                    fmValueMap.put(iqm,fmList);
                }   else{
                    for(String iqm:innerqueryMap.keySet()){
                        if(iqm == 'Licences__r')
                            labelAPi.put(iqm,'Licences');
                        else if(iqm == 'Account_Legal_Entities__r')
                            labelAPi.put(iqm,'Billing Information');
                        else
                            labelAPi.put(iqm,iqm);
                        
                        list<String> fieldList = innerqueryMap.get(iqm);
                        Map<String,Object> obj= (Map<String,Object>)f.get(iqm);
                        
                        
                        if(obj != null){
                            List<Object> a = (List<object>)obj.get('records');
                            for(object t : a){
                                
                                Map<String,object> l =  (Map<String,object>) (t);
                                // Map<String,String> a1= new Map<String,String>();
                                
                                Map<String,Field_Mapping__c> fmList = new  map<String,Field_Mapping__c>();
                                for(String p: l.keySet()){
                                    
                                    if(p!='attributes'){
                                        
                                        //  a1.put(p,l.get(p)+'');
                                        
                                        Field_Mapping__c fm = fmMap.get(iqm+p);
                                        field_mapping__c fmNew = new field_mapping__c();
                                        fmNew.from__c = l.get(p)+'';
                                        fmNew.label__c=fm.label__c;
                                        fmNew.to__c =fm.to__c;
                                        
                                        fmList.put(p,fmNew);
                                        
                                    }
                                }
                                
                                fmValueMap.put(iqm,fmList);
                                
                            }
                        }
                    }}
                fmDisplayList.add(fmValueMap);
                
                
            }
            
            templist = new List<String>();
            tempList.addAll(sourceMap.keySet());
            for(Map<String,Object> fm : fmDisplayList){
                system.debug('********');
                system.debug(fm.get('FirstName'));
                
            }
            
            wrapperClass oWrapper = new wrapperClass(labelAPi,
                                                     sd.External_Field__c,tempList,APIMap,
                                                     fmDisplayList,res.get('URL'),mappedId);
            return oWrapper;  
        }
    }
    
    public static Map<String,String> getToken(Search_and_tag_admin__c sd){
        system.debug('getToken');
        String endPoint= sd.EndPoint__c+'?grant_type=password&password='+sd.password__c+'&username='+
            +sd.UserName__c+'&client_id='+sd.ClientID__c+
            '&client_secret='+sd.Client__c;
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse response;
        reqHeaders.put('accept','*/*');
        if(!test.isRunningTest())
            response = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,endPoint,'','POST',false,false,null,null);
        else{
            response = new HTTPResponse();
            response.setStatusCode(200);
            // response.setBodyAsBlob(body)t
            response.setBody('{"access_token":"SESSION_ID_REMOVED",'+
                             +'"instance_url":"https://propertyguru--sandbox.my.salesforce.com",'+
                             +'"id":"https://test.salesforce.com/id/00D1y0000000ZO2EAM/0051y0000025iQLAAY",'+
                             +'"token_type":"Bearer","issued_at":"1639030881323","signature":"OIy288m89wyRhEGAZb0byh'+
                             +'DzTGJzf9bwK/BWMW/ozao="}');
        }
        if(response.getStatusCode() == 200) { 
            String resBody=response.getBody();
            //  system.debug(response.getBody());
            map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(resBody);
            String token=(String) responseJSON.get('access_token');
            Map<String,String> res = new Map<String,String>();
            res.put('token',token);
            res.put('URL',(String) responseJSON.get('instance_url'));
            return res;
        }
        else{
             system.debug(response.getStatusCode());
             system.debug(response.getStatus());
            throw new AuraHandledException('connection failed' );
        }
    }
    public static List<Object> getRecords(String endPoint,String method,String token,String transType,String reqBody){
        system.debug('getRecords');
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse response;
        //  reqHeaders.put('accept','*/*');
        reqHeaders.put('Authorization','Bearer '+token);
        if(!test.isRunningTest())
            response = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,endPoint,'',method,false,false,null,null);
        else {
            response = new HTTPResponse();
            response.setStatusCode(200);
            
            response.setBody(' {"totalSize":1,"done":true,"records":[{"attributes":{"type":"Account",'+
                             +'"url":"/services/data/v50.0/sobjects/Account/0011y00000Nd0QsAAJ"},'+
                             +'"Name":"Francene Lamoreux","Status__c":null,"Country__c":"Singapore",'+
                             +'"AgentNet_ID__c":null,"Amount":2222.0,'+
                             +'"Id":"0011y00000Nd0QsAAJ",'+ 
                             +'"Next_Subscription_Activation_Date__c":null},{"attributes":{"type":"Opportunity","url":"/services/data/v50.0/sobjects/Opportunity/0068G0000050FBDQA2"},"Name":"Referral Promo RM25-Aug 2020","Id":"0068G0000050FBDQA2","CloseDate":"2020-08-24","Description":null,"Account":{"attributes":{"type":"Account","url":"/services/data/v50.0/sobjects/Account/0018G000008618GQAQ"},"REA_ID__c":"REAC010133","OwnerId":"0055f000000uShmAAE"},"Amount":null,"StageName":"Qualified","AccountId":"0018G000008618GQAQ"}]}');
        }
        if(transType =='Get' && response!=null){
            if(response.getStatusCode() == 200) { 
                String resBody=response.getBody();
                system.debug(resBody);
                map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(resBody);
                integer totalSize= (Integer)responseJSON.get('totalSize');
                if(totalSize>0){
                    LIST<Object> objlist =(LIST<Object>)JSON.deserializeUntyped('['+resBody+']') ;
                    for(object o : objlist){
                        system.debug(o);
                        Map<String,object> m =  (Map<String,object>) (o);
                        List<Object> a = (List<object>)m.get('records');
                        return a;
                    }
                }
                
                else{
                    throw new AuraHandledException('There are no records found with given criteria' );
                }
            }
            else{
                throw new AuraHandledException('connection failed' );
            }
        }
        else if (transType =='Create') {
            reqHeaders.put('Content-Type','application/json');
            reqHeaders.put('accept','application/json');
            if(!test.isRunningTest())
                response = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,endPoint,reqBody,method,true,false,
                                                                         null,null);
            else{
                response = new HTTPResponse();
                response.setStatusCode(201);
                response.setBody('{"id":"0068G0000051G1oQAE","success":true,"errors":[]}');
            }
            system.debug('****'+response.getBody());
            if(response.getStatusCode() == 201) { 
                String resBody=response.getBody();
                
                Map<String,Object> objList = (Map<String,Object>) JSON.deserializeUntyped(resBody);
                system.debug(objList.get('id'));
                list<object> d = new list<Object>();
                d.add(objList);
                return d;
            }
            else  if(response.getStatusCode() == 204) { 
                return null;
            }
            else{
                String resBody=response.getBody();
                List<Object> objList = (List<Object>) JSON.deserializeUntyped(resBody);
                system.debug(objList);
                
                Map<String, Object> obj = (Map<String, Object>)objList[0];
                system.debug(obj);
                
                system.debug(obj.get('errorCode') +': '+obj.get('message'));
                throw new AuraHandledException(obj.get('errorCode') +': '+obj.get('message'));
            }
        }
        return null;
    }
    
    @auraEnabled
    public static String updateRec(String externalField,String recordId,String type){
        
        String agentType;
        
        if(type.contains('brickz')){
            agentType='Brickz Only';
            
        }else{
            agentType='Overlapping';
            
        }
        Id objId = (Id) recordId;
        
        String sObjName = objId.getSObjectType().getDescribe().getName();
        String query='Select id,external_field__c';
        if(sObjName == 'Account'){
            query += ',Overlap_Agent__c,Brickz_Agent__c';
        }
        query+=' from '+sObjName+' where id =: recordId';
        
        List<SObject> sobjList = database.Query(query);
        // if(sObjName==)
        if(sObjName == 'Opportunity'){
            if(sobjList[0].get('External_Field__c') != null){
                
                throw new AuraHandledException('Please untag ' +sObjName + ' first');
            }   
        }
        else
        {
            if(sobjList[0].get('External_Field__c') != null){
                if(agentType == 'Brickz Only'){
                    if(sobjList[0].get('Brickz_Agent__c') == true){
                        throw new AuraHandledException('Please untag ' +sObjName + ' first');
                    }
                } else if(agentType == 'Overlapping'){
                    if(sobjList[0].get('Overlap_Agent__c') == true){
                        throw new AuraHandledException('Please untag ' +sObjName + ' first');
                    }
                }
            }
        }
     
        
        
        Map<String,object> selectedRec = ( Map<String,object>) JSON.deserializeUntyped(externalField);
        system.debug(selectedRec);
        String sub = 'Tag '+agentType+' agent';
        if(sObjName == 'Account'){
            List<Case> OpenCaseList = [select id,caseNumber from case where accountid=: recordId 
                                       and subject like :sub and isClosed = false];
            if(OpenCaseList.size()>0)
                Throw new AuraHandledException('There is a existing case '+OpenCaseList[0].caseNumber+' for tagging of an agent.');
            system.debug(externalField);
            // Map<String,object> selectedRec = ( Map<String,object>) JSON.deserializeUntyped(externalField);
            
            String caseDes='';
            String tempAccID;
            for(String label : selectedRec.keySet()){
                Map<String,object> selectedRow = (  Map<String,object>)selectedRec.get(label);
                system.debug(selectedRow);
                if((String)selectedRow.get('Label__c') != null)
                    caseDes+=(String)selectedRow.get('Label__c')+' : '+(String)selectedRow.get('from__c')+'\n';
                if((String)selectedRow.get('Label__c') == 'Id'){
                    tempAccID=(String)selectedRow.get('from__c');
                }
            }
            caseDes+= '\nThank you.';
            String caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Enablement').getRecordTypeId();
            String salesEnablementQueue = [select id,name from group where name ='MY Sales Admin Queue'].id;
            Case oCase = new Case(Status ='new',Priority ='Medium', Type  ='Sales Support (General)',
                                  Case_Sub_Category__c ='Others', RecordTypeId =caseRecType,ownerid=salesEnablementQueue);
            
            caseDes ='Hi Team,\n \n I would like to request tagging of following agent as '+AgentType+' agent.\n\n'+caseDes;
            oCase.Subject='Tag '+AgentType+' agent';
            oCase.Description =caseDes;
            oCase.AccountId =recordId;
            oCase.Account_Temp_ExternalField__c  = tempAccID;
            try{
                
                insert oCase;
                case newCase = [select id,CaseNumber from case where id =: ocase.id];
                system.debug(newCase.CaseNumber);
                return newCase.CaseNumber;
            }   catch(Exception e){
                
                Throw new AuraHandledException(e.getMessage());
            }
        }
        else {
            
            SObject o1 = objId.getSObjectType().newSObject(recordId);
            Map<String,object>  oppID= ( Map<String,object>) selectedRec.get('Id');
            tagUntagRecord(objId,(String)oppID.get('from__c'),'tag',type,null);
            //caseDes+=(String)selectedRow.get('Label__c')+' : '+(String)selectedRow.get('from__c')+'\n';
            try{
                o1.put('External_Field__c', (String)oppID.get('from__c'));
                o1.put('id', objId);
                
                update o1;
                system.debug(o1);
                
            }
            catch(Exception e){
                //system.debug(e.)
                Throw new AuraHandledException(e.getMessage());
            }
            return null;
        }
        
        
    }
    public static string tagUntagRecord(String recordId,String value,String taggingType,String quickAction,String externalField){
        Id objId = (Id) recordId;
        
        String sObjName = objId.getSObjectType().getDescribe().getName();
        String recQuery ='select recordtypeid from ' +sObjName+'  where id =: objId';
        List<Sobject> sobjrecType = database.query(recQuery);	
        
        String recordtype = (String) sobjrecType[0].get('recordtypeid');
        List<Search_and_tag_admin__c > sdList = new List<Search_and_tag_admin__c >();
        
        sdList = [select id, Destination_Object_API__c , Client__c, ClientID__c, Source_Object_API__c , 
                  Destination_Recordtype_Id__c ,OwnerID__c,
                  Password__c, UserName__c, EndPoint__c,External_Field__c  , 
                  (Select id, from__c, To__c,DataType__c   from Field_Mappings__r where isActive__c =true 
                   and Only_for_creation__c = true)
                  from Search_and_tag_admin__c   where Source_Object_API__c  =: sObjName 
                  and Source_RecordTypeID__c  =: recordtype and Active__c =true];
        if(sdList.isEmpty()){
            throw new AuraHandledException('no configuration found related to' +sObjName);
            //
        } 
        Map<String,String> res = SearchRecord_cc.getToken(sdList[0]);
        String token = res.get('token'); 
        String endpoint =res.get('URL')+ '/services/data/v50.0/sobjects/'+sObjName+'/'+value;
        Map<String,Object> JSONBody = new Map<String,Object>();
        // JSONBody.put('Id',value);
        if(sObjName == 'Account'){
            if( taggingType =='un-tag'){
                if(quickAction == 'Brickz Only')
                    JSONBody.put('Brickz_Agent__c',false);
                if(quickAction == 'Overlapping')
                    JSONBody.put('Overlap_Agent__c',false);
                JSONBody.put('External_field__c',externalField);
            }
            else{
                JSONBody.put('External_field__c',recordId);
                
                if(quickAction == 'Brickz Only')
                    JSONBody.put('Brickz_Agent__c',true);
                if(quickAction == 'Overlapping')
                    JSONBody.put('Overlap_Agent__c',true);
                
                
            }  
        }
        else{
            if( taggingType =='un-tag'){
                JSONBody.put('External_field__c',null);
            }
            else
                JSONBody.put('External_field__c',recordId);
        }
        
        
        
        String reqBody = JSON.serialize(JSONBody);
        system.debug(reqbody);
        
        List<Object> sobjectList =  getRecords(endpoint,'PATCH',res.get('token'),'Create',reqbody);
        
        return null;
    }
    @auraEnabled
    public static String createRec(String recordId,String ownerid,String quickAction){
        system.debug('createRec');
        Id objId = (Id) recordId;
        
        //  String externalId;
        String sObjName = objId.getSObjectType().getDescribe().getName();
        List<Search_and_tag_admin__c > sdList = new List<Search_and_tag_admin__c >();
        
        List<Sobject> sobjrecType =   validation(recordid);
        String recordtype = (String) sobjrecType[0].get('recordtypeid');
        
        
        
        sdList = [select id, Destination_Object_API__c , Client__c, ClientID__c, Source_Object_API__c , 
                  Destination_Recordtype_Id__c ,OwnerID__c,
                  Password__c, UserName__c, EndPoint__c,External_Field__c  , 
                  (Select id, from__c, To__c,DataType__c   from Field_Mappings__r where isActive__c =true 
                   and Only_for_creation__c = true)
                  from Search_and_tag_admin__c   where Source_Object_API__c  =: sObjName 
                  and Source_RecordTypeID__c  =: recordtype and Active__c =true];
        if(sdList.isEmpty()){
            throw new AuraHandledException('no configuration found related to' +sObjName);
            //
        } 
        else {
            Map<String,String> sourceMap = new Map<String,String>();
            List<String> dateList = new List<String>();
            Search_and_tag_admin__c  sd = sdList[0];
            String sourceQuery = 'Select ';
            Map<String,Object> JSONBody = new Map<String,Object>();
            for(Field_Mapping__c fm : sd.Field_Mappings__r){
                sourceMap.put(fm.from__c,fm.to__c) ;
                if(fm.DataType__c =='Date'){
                    dateList.add(fm.from__c);
                }
            }
            Map<String,String> res = getToken(sd);
            List<String> tempList = new List<String>();
            tempList.addAll(sourceMap.keySet());
            sourceQuery += String.join(tempList,',')+',Mobile_country__c from '+sObjName+' where id =: recordId';
            system.debug(sourceQuery);
            List<sObject> records = database.query(sourceQuery);
            system.debug(records);
            
            for(String s : tempList){
                
                //  system.debug( sourceMap.get(s)+'. '+records[0].get(s)+'');
                if(dateList.contains(s)){
                    
                    if(records[0].get(s) !=null){
                        String datevalue  =records[0].get(s)+'';
                        system.debug(records[0].get(s) + '    '+s);
                        
                        JSONBody.put(sourceMap.get(s),datevalue.replace(' ','T')+'Z');
                        
                    }                
                    
                } else if(s.contains('.')){
                    system.debug('in if');
                    system.debug(s);
                    String[] childparent = s.split('\\.');
                    String sFieldSub1 = childParent[0];
                    String sFieldSub2 =childParent[1];
                    //s.SubString(s.indexof('.') + 1,s.Length()); //though I imagine you could use a spilt string also.
                    String sValue = (String)records[0].getSobject(sFieldSub1).get(sFieldSub2);
                    system.debug(svalue);
                    if(svalue!=null){
                        JSONBody.put(sourceMap.get(s),svalue);
                        system.debug(svalue);
                    }
                }
                else if(s == 'stageName'){
                    JSONBody.put(sourceMap.get(s),'New');
                }
                else if(s == 'PersonMobilePhone'){
                    String code = (String) records[0].get('Mobile_Country__c');
                    JSONBody.put(sourceMap.get(s),'+'+ code +records[0].get(s)+'');
                    
                }
                
                else{
                    system.debug('*********');
                    system.debug(s);
                    
                    if(records[0].get(s)!=null){
                        if(sd.Source_Object_API__c  == 'Opportunity' && s== 'Name'){
                            JSONBody.put(sourceMap.get(s),'[Cross-sell] '+ records[0].get(s)+'');
                        }
                        else
                            JSONBody.put(sourceMap.get(s),records[0].get(s)+'');
                    }
                }
            }
            if(sd.Destination_Recordtype_Id__c !=null)
                JSONBODY.PUT('Recordtypeid',sd.Destination_Recordtype_Id__c);
            if(sd.OwnerID__c != null){
                JSONBODY.PUT('ownerid',sd.OwnerID__c);
            }
            else if(ownerid!=null){
                JSONBODY.PUT('ownerid',ownerid);
            } else{
                String accId=(String)JSONBODY.get('AccountId');
                String queryEndPoint=res.get('URL')+ '/services/data/v50.0/query/?q=SELECT+id,ownerid+from+account+where+id=\''+accId+'\'';
                List<Object> sobjectList = getRecords(queryEndPoint,'GET',res.get('token'),'Get',null);
                system.debug(sobjectList);
                Map<String,Object> result = (Map<String,Object>) sobjectList[0];
                // ownerid=result.get('OwnerId');
                JSONBODY.PUT('ownerid',(STring)result.get('OwnerId'));
                system.debug('sobjectList'+result.get('OwnerId')) ;
                
            }
            system.debug('quickAction type. '+quickAction);
            if(sObjName=='Account'){
                if(quickAction.contains('brickz')){
                    quickAction='Brickz only';
                    JSONBody.put('Brickz_Agent__c',true);
                }
                else if(quickAction.contains('Overlapping')){
                    JSONBody.put('Overlap_Agent__c',true);
                    quickAction='Overlapping only';
                }
            }
            
            String reqBody = JSON.serialize(JSONBody);
            system.debug(reqbody);
            
            //services/data/v53.0/sobjects/Account/
            String endpoint =res.get('URL')+ '/services/data/v50.0/sobjects/'+sObjName+'/';
            
            List<Object> sobjectList =  getRecords(endpoint,'POST',res.get('token'),'Create',reqbody);
            Map<String,Object> result = (Map<String,Object>) sobjectList[0];
            
            system.debug('sobjectList'+result.get('id')) ;
            
            SObject o1 = objId.getSObjectType().newSObject(recordId);
            o1.put('External_Field__c', result.get('id')+'');
            o1.put('id', recordId);
            if(sObjName=='Account'){
                
                if(quickAction == 'Brickz Only')
                    o1.put('Brickz_Agent__c',true);
                if(quickAction == 'Overlapping only')
                    o1.put('Overlap_Agent__c',true);
            }
            update o1;
            system.debug(o1);
        }
        
        return null;
    }
    @auraEnabled
    public static bothWrapper getObjFields(String recordId){
        system.debug('getObjFields');
        bothWrapper bw = new bothWrapper();
        //List<Map<String,Object>> keyValueList = new List<Map<String,Object>> ();
        fieldswrapperClass fws = new fieldswrapperClass();
        Id objId = (Id) recordId;
        List<Sobject> sobjrecType =   validation(recordid);
        String recordtype = (String) sobjrecType[0].get('recordtypeid');
        
        String sObjName = objId.getSObjectType().getDescribe().getName();
        List<Search_and_tag_admin__c> sdList = new List<Search_and_tag_admin__c> ();
        
        sdList = [select id, Destination_Object_API__c , Client__c, ClientID__c, Destination_Recordtype_Id__c, 
                  Password__c, UserName__c, EndPoint__c,External_Field__c  , Source_Object_API__c ,
                  (Select id, from__c, To__c,Only_for_creation__c,label__c,where_clause__c,Search_List__c,DataType__c,related_Object_API__c from
                   Field_Mappings__r where isActive__c =true and where_clause__c=true )
                  from Search_and_tag_admin__c  where Source_Object_API__c  =: sObjName and Active__c =true
                  and Source_RecordTypeID__c  =: recordtype];
        
        if(sdList.isEmpty()){
            throw new AuraHandledException ('No configuration found related to '+sObjName);
        }
        else if(sdList[0].Source_Object_API__c  == 'Account'){
            system.debug('Account');
            Search_and_tag_admin__c  sd = sdList[0];
            List<Field_Mapping__c> fmList = new List<Field_Mapping__c>();
            fmList = sd.Field_Mappings__r;
            SObject so = Schema.getGlobalDescribe().get(sdList[0].Source_Object_API__c  ).newSObject();
            
            
            Map<String,String> sourceMap = new Map<String,String>();
            
            String sourceQuery = 'Select ';
            for(Field_Mapping__c fm : sd.Field_Mappings__r){
                system.debug(fm);
                if(fm.where_clause__c){
                    boolean isFieldExist=true;
                    try{
                        isFieldExist =   so.getSobjectType().getDescribe().fields.getMap().containsKey(fm.from__c);
                    }
                    catch(Exception e){
                        isFieldExist=false;
                    }
                    if(isFieldExist){
                        sourceMap.put(fm.from__c,null) ; 
                    }
                }
            }
            list<String> tempList = new list<String>();
            templist.addAll(sourceMap.keySet());
            if(!templist.contains('Country__c')){
                templist.add('Country__c');
            }
            sourceQuery += String.join(tempList,',')+' from '+sd.Source_Object_API__c  +' where id =:recordId';
            SObject sobjrecord = database.query(sourceQuery);
            
            if(sobjrecord.get('Country__c') != 'Malaysia'){
                throw new AurahandledException('Search & tag should only be used with Malaysia records');
            }
            for(field_Mapping__c fm : fmList){
                if(sourceMap.containsKey(fm.from__c)){
                    fm.from__c = sobjrecord.get(fm.from__c)+'';
                }else
                    fm.from__c = '';
            }
            fws.objName = sObjName;
            fws.fmList = fmList;
            bw.fwc = fws;
        }else if(sdList[0].Source_Object_API__c  == 'Opportunity'){
            bw.wc = fetchRecords(objId,null);
            
        }
        bw.objectName =sdList[0].Source_Object_API__c ;
        
        return bw;
        //   return fws;
        
    }
    
    @auraEnabled
    public static String untagAccount(String recordId,String eventType){
        Id objId = (Id) recordId;
        String sObjName = objId.getSObjectType().getDescribe().getName();
        String query='Select id,external_field__c';
        if(sObjName == 'Account'){
            query += ',Overlap_Agent__c,Brickz_Agent__c,(select id from opportunities where external_field__c != null) from Account where id =: recordId';
        }
        else
            query+=' from '+sObjName+' where id =: recordId';
        String agentType;
        if(eventType.contains('brickz')){
            agentType='Brickz Only';
            
        }else{
            agentType='Overlapping';
            
        }
        List<SObject> sobjList = database.Query(query);
        system.debug('external field' +sobjList[0].get('External_Field__c'));
        if(sObjName == 'Account'){
            String sub = 'Un-tag '+agentType+' agent';
            List<Case> OpenCaseList = [select id,caseNumber from case where accountid=: recordId 
                                       and subject =: sub and isClosed = false];
            if(OpenCaseList.size()>0){
                Throw new AuraHandledException('There is a existing case '+OpenCaseList[0].caseNumber+' for un-tagging of a agent.');
            }
            Account acc = (Account) sobjList[0];
            if(acc.opportunities.size() > 0){
                throw new AuraHandledException('Unable to untag as Agent have cross selling Opportunities');
            }   
            if(acc.External_Field__c == null){
                throw new AuraHandledException('Agent do not have any overlapping account from REA');
            }else{
                if(agentType == 'Brickz Only'){
                    if(acc.Brickz_Agent__c == false){
                        throw new AuraHandledException('Agent do not have any overlapping account from REA');
                    }
                }else if(agentType == 'Overlapping'){
                    if(acc.Overlap_Agent__c == false){
                        throw new AuraHandledException('Agent do not have any overlapping account from REA');
                    }
                }
            }
            
            
        } else {
            if(sobjList[0].get('External_Field__c') == null){
                throw new AuraHandledException('Opportunity does not have any cross selling Opportunity from REA');
                
                
            } 
            
        }
        
        
        try{
            String caseDes='';
            /*  SObject sObj = sobjList[0];
Sobj.put('External_Field__c',null);
Sobj.put('Id',Sobj.id);

update Sobj;*/
            
            if(sObjName == 'Account'){
                String caseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Sales Enablement').getRecordTypeId();
                String salesEnablementQueue = [select id,name from group where name ='MY Sales Admin Queue'].id;
                Case oCase = new Case(Status ='new',Priority ='Medium',Type  ='Sales Support (General)',
                                      Case_Sub_Category__c ='Others', RecordTypeId =caseRecType,ownerid=salesEnablementQueue); 
                oCase.Account_Temp_ExternalField__c =(String) sobjList[0].get('External_Field__c');
                caseDes ='Hi Team,\n \n I would like to request un-tagging of agent as '+agentType+' agent.';
                oCase.Subject='Un-Tag '+agentType+' agent';
                oCase.Description =caseDes;
                oCase.AccountId =recordId;
                
                insert oCase;
                system.debug(caseDes);
                case newCase = [select id,CaseNumber from case where id =: ocase.id];
                system.debug(newCase.CaseNumber);
                return newCase.CaseNumber;
            }
            else {
                SObject sObj = sobjList[0];
                tagUntagRecord(Sobj.id,(string)Sobj.get('External_Field__c'),'un-tag',null,null);
                
                Sobj.put('External_Field__c',null);
                Sobj.put('Id',Sobj.id);
                
                update Sobj;
            }
            
            return null;
        }catch(Exception e){
            throw new AuraHandledException(e.getMessage()+e.getLineNumber());
        }
        
    }   
}