//Test Class : createOpportunitiesAPI_Test
@RestResource(urlMapping='/api/createOpportunitiesAndQuotes/*')
global class createOpportunitiesAPI {
    @HttpPost
    global static void createOpportunities() {
        string result = '';
        list<opportunity> oppList = new list<opportunity>();
        Http http = new Http();
        RestRequest request = Restcontext.request;
        system.debug('request.requestBody.tostring()@@'+request.requestBody.tostring());           
        RestResponse res = RestContext.response;
        Savepoint sp = Database.setSavepoint();    
        Try{  
            Map<String,Object> reqbody = (Map<String,Object>)JSON.deserializeUntyped(RestContext.request.requestBody.tostring());
            List<sObject> objects = new List<sObject>();
            Set<String> iPProdList = new Set<String>();
            opportunity dummyOpp = new opportunity();
            Account dummyAcc = new Account();
            list<Account> accList = new list<Account>();
            String accId;
            Boolean allowInsert = true;
            String failureReason;
            String recordtype =  (String)reqbody.get('desrecordtype');
            String userEmail =  (String)reqbody.get('email');
            String sObjName = (String)reqbody.get('sObjName');
            String externalId = (String)reqbody.get('objectId');
            String accountId = (String)reqbody.get('accountId');
            List<object> resList = (List<object>)reqbody.get('sendResponse');
            List<Object> prodList = (List<object>)reqbody.get('prodList');
            Date startdate;
            boolean isOverlapping;
            
            if(reqbody.containskey('StartDate')&& (String)reqbody.get('StartDate')!=null){
                String quotedate = (String)reqbody.get('StartDate');
                Date d = date.valueOf(quotedate);
                Date finalDate = date.newInstance(d.year(), d.month(), d.day());
                startdate = finalDate; 
            }
            System.debug('prodList@@ '+prodList);
            list<User> userList = [Select Id from user where email =: userEmail ];
            list<String> prodskucode = new list<String>();
            for(Object obj : prodList){
                String code = (String)obj;
                prodskucode.add(code);
            }
            List<Search_and_tag_admin__c> sdList = new List<Search_and_tag_admin__c> ();
            
            sdList = [select id, Destination_Object_API__c , Client__c, ClientID__c, Destination_Recordtype_Id__c, 
                      Password__c, UserName__c, EndPoint__c,External_Field__c  , Source_Object_API__c ,
                      (Select id, from__c, To__c,Instance_Name__c,label__c,DataType__c,Related_List_Label__c,
                       related_Object_API__c,Picklist_values__c,Sequennce__c
                       from Field_Mappings__r where isActive__c =true and recordCreation__c=true order by Sequennce__c )
                      from Search_and_tag_admin__c  where Source_Object_API__c  =: sObjName and Active__c =true
                      and Source_RecordTypeID__c  =: recordtype];
            Map<String,Field_Mapping__c> fmList = new Map<String,Field_Mapping__c>();
            if(!sdList.isEmpty()){
                Search_and_tag_admin__c  sd = sdList[0];
                for(Field_Mapping__c fm : sd.Field_Mappings__r){
                    fmList.put(fm.from__c,fm);
                }
            }
            System.debug('fmList@@'+fmList);
            for(object obj : resList){
                Map<String,object> response = (Map<String,object>)obj;
                
                if(sObjName == 'Opportunity'){
                    
                    if(fmList.containskey((String)response.get('label'))){
                        if(response.get('label') =='Accountid'){
                            accId = (String)response.get('value');
                        }
                        else if(fmList.get((String)response.get('label')).DataType__c !='Date'){
                            
                            dummyOpp.put((String)response.get('label'),(String)response.get('value'));  
                            
                        }else if(fmList.get((String)response.get('label')).DataType__c =='Date'){
                            String closedate = (String)response.get('value');
                            Date d = date.valueOf(closedate);
                            Date finalDate = date.newInstance(d.year(), d.month(), d.day());
                            dummyOpp.put((String)response.get('label'),finalDate);  
                        }
                    }
                    dummyOpp.put('External_field__c',externalId);       
                }else if(sObjName == 'Account'){
                   
                    if(fmList.containskey((String)response.get('label'))){
                        if(fmList.get((String)response.get('label')).DataType__c =='Date'){
                            String closedate = (String)response.get('value');
                            Date d = date.valueOf(closedate);
                            Date finalDate = date.newInstance(d.year(), d.month(), d.day());
                            dummyAcc.put((String)response.get('label'),finalDate);  
                        }else if(fmList.get((String)response.get('label')).DataType__c =='Checkbox'){
                            
                            dummyAcc.put((String)response.get('label'),(Boolean)response.get('value'));  
                            boolean  Overlap_Agent = false;
                            boolean Brickz_Agent = false;
                                    
                            if((String)response.get('label') == 'Brickz_Agent__c'){
                                Brickz_Agent = (boolean)dummyAcc.get('Brickz_Agent__c');    
                            }
                            else if((String)response.get('label') == 'Overlap_Agent__c'){
                                
                                Overlap_Agent = (boolean)dummyAcc.get('Overlap_Agent__c');
                            }
                            if(Brickz_Agent||Overlap_Agent){
                                isOverlapping = true;   
                            }
                            
                            else {
                                isOverlapping = false;
                            }
                            
                            
                        }
                        
                        else{
                            dummyAcc.put((String)response.get('label'),(String)response.get('value'));  
                            
                        }
                    } 
                }
                
            }
            if(accountId!=null){
                accList = [Select Id,External_field__c,country__c,AgentNet_ID__c,Test_Account__c,NetSuite_Id__c
                           from account where id =: accountId];
                if(!accList.isempty()){
                    if(accList[0].External_field__c==null){
                        allowInsert = false;
                        failureReason = 'Related Account should be overlapping';
                    }else if(accList[0].AgentNet_ID__c == null){
                        allowInsert = false;
                        failureReason = 'Please sync related account record to AdminNet'; 
                        
                    }
                    else if(accList[0].Test_Account__c == true){
                        allowInsert = false;
                        failureReason = 'Related account  a test account';  
                        
                    }
                    else if(accList[0].NetSuite_Id__c == null){
                        allowInsert = false;
                        failureReason = 'Please sync related account record to Netsuite'; 
                        
                    }
                    else if(accList[0].country__c != 'Malaysia'){
                        allowInsert = false;
                        failureReason = 'Cross Sell Opportunities can only be created for MY agents'; 
                        
                    }
                }
            }
            if(allowInsert){
                if(sObjName == 'Opportunity'){
                    dummyOpp.put('recordtypeid',recordtype);
                    if(!userList.isempty()){
                        dummyOpp.put('ownerid',userList[0].id);  
                    }
                    if(accountId!=null){
                        dummyOpp.put('accountid',accountId);     
                    }
                    objects.add(dummyOpp); 
                }
                if(sObjName == 'Account'){
                    dummyAcc.put('recordtypeid',recordtype);
                    String phoneNumber = (String)dummyAcc.get('PersonMobilePhone');
                    if(phoneNumber.startsWith('+60')){
                      String phone = (String)phoneNumber.substring(3);
                      dummyAcc.put('PersonMobilePhone',phone);  
                    }
                    if(!userList.isempty()){
                        dummyAcc.put('ownerid',userList[0].id);  
                    }
                     if(isOverlapping!=null && isOverlapping == true){
                        dummyAcc.put('External_field__c',externalId);   
                    }  
                    objects.add(dummyAcc); 
                }
                System.debug(objects);
                if(!objects.isempty())
                    insert objects; 
                if(sObjName == 'Opportunity'){
                    Set<String> oppIds = new Set<String>();
                    for(sobject opp:objects) {
                        oppIds.add(opp.Id);
                    }
                    createOpportunities.createQuote(oppIds,prodskucode,StartDate);
                } 
                if(sObjName == 'Account'){
                    Biforst_Sync__e biforstSync = new Biforst_Sync__e();
                    biforstSync.AccountId__c = objects[0].id;
                    Eventbus.publish(biforstSync);
                }
                result =   (Id)objects[0].id;
            }else{
                result =   (String)failureReason; 
            }
            res.responseBody = blob.valueOf(result);
            
            
        }
        catch(DmlException e){
            Database.rollback(sp);
            res.statusCode = 400;
            system.debug('ERROR' + e.getMessage() + e.getLineNumber());
            result =  e.getMessage();
            res.responseBody = blob.valueOf(result);
            
        }
    }
    
}