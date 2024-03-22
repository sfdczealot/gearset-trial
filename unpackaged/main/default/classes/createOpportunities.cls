//Test Class : createOpportunities_Test
public class createOpportunities {
    
    @AuraEnabled(cacheable = true)
    public static LightningResponse fetchProductDetails(String quickAction,String recordId){
        try {
            
            fieldswrapperClass objResponse = getObjFields(quickAction,recordId);
            return new LightningResponse(true, 'Success', JSON.serialize(objResponse));
            
        } catch (Exception ex) {
            return new LightningResponse(false,ex.getMessage(),'');
        }   
    }
    private static fieldswrapperClass getObjFields(String quickAction,String recordId){
        String errorMsg = 'No error';
        fieldswrapperClass fws = new fieldswrapperClass();
        String recordtype;
        // List<Sobject> sobjrecType =   SearchRecord_cc.validation(recordid);
        String accRecordtype = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
        String oppRecordtype = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('B2C').getRecordTypeId();
        
        String sObjName;
        sObjName = quickAction;
        if(quickAction == 'Opportunity'){
            recordtype = oppRecordtype; 
            if(recordId !=null && recordId !=' '){
                System.debug('recordId'+recordId);
                list<Account> acc = [Select id,name from Account where id =:recordId];
                if(!acc.isempty())
                    fws.recordName = acc[0].name;   
            }
            
        }else if(quickAction == 'Account'){
            recordtype = accRecordtype;  
            
        }
        
        
        List<Search_and_tag_admin__c> sdList = new List<Search_and_tag_admin__c> ();
        
        sdList = [select id, Destination_Object_API__c , Client__c, ClientID__c, Destination_Recordtype_Id__c, 
                  Password__c, UserName__c, EndPoint__c,External_Field__c  , Source_Object_API__c ,
                  (Select id, from__c, To__c,Instance_Name__c,label__c,DataType__c,Related_List_Label__c,
                   related_Object_API__c,Picklist_values__c,Sequennce__c,filter_query__c,Required__c
                   from Field_Mappings__r where isActive__c =true and recordCreation__c=true order by Sequennce__c )
                  from Search_and_tag_admin__c  where Source_Object_API__c  =: sObjName and Active__c =true
                  and Source_RecordTypeID__c  =: recordtype];
        
        if(sdList.isEmpty()){
            errorMsg ='No configuration found related to '+sObjName;
        }
        else {
            
            Search_and_tag_admin__c  sd = sdList[0];
            List<Field_Mapping__c> fmList = new List<Field_Mapping__c>();
            fmList = sd.Field_Mappings__r;
            fws.objName = sObjName;
            fws.fmList = fmList;
            fws.recordtype = recordtype;
            
        }
        list<MY_Products__c> products = MY_Products__c.getAll().values();
        fws.products = products;
        return fws;
        
        
    }
    @AuraEnabled
    public static LightningResponse saveOpportunity(String jsonResponse,String sObjName,String recordtype){
        
        try {
            resultWrapper objResponse = saveOpp(jsonResponse,sObjName,recordtype);
            if(objResponse.error == null){
                return new LightningResponse(true, 'Success', JSON.serialize(objResponse));  
            }else{
                return new LightningResponse(false, objResponse.error, '');
            }
        } catch (Exception ex) {
            return new LightningResponse(false, ex.getMessage(), '');
        }
    }
    
    private static resultWrapper saveOpp(String jsonResponse,String sObjName,String recordtype){
        String errorMsg = 'No error';
        list<Object> reslist = (list<Object>) JSON.deserializeUntyped(jsonResponse);
        List<Search_and_tag_admin__c> sdList = new List<Search_and_tag_admin__c> ();
        String currentEmail = Userinfo.getUserEmail();
        boolean success;
        responseClass resp = new responseClass();
        resultWrapper resWrap = new resultWrapper();
        resp.email = currentEmail;
        resp.sObjName = sObjName;
        
        sdList = [select id, Destination_Object_API__c , Client__c, ClientID__c, Destination_Recordtype_Id__c, 
                  Password__c, UserName__c, EndPoint__c,External_Field__c  , Source_Object_API__c ,
                  (Select id, from__c, To__c,Instance_Name__c,label__c,DataType__c,Related_List_Label__c,related_Object_API__c,Picklist_values__c
                   from Field_Mappings__r where isActive__c =true and recordCreation__c=true  )
                  from Search_and_tag_admin__c  where Source_Object_API__c  =: sObjName and Active__c =true
                  and Source_RecordTypeID__c  =: recordtype];
        
        
        Map<String,Field_Mapping__c> fmList = new Map<String,Field_Mapping__c>();
        
        if(!sdList.isEmpty()){
            
            Search_and_tag_admin__c  sd = sdList[0];
            resp.desrecordtype = sd.Destination_Recordtype_Id__c;
            for(Field_Mapping__c fm : sd.Field_Mappings__r){
                fmList.put(fm.from__c,fm);
            }
            
            
            
            
            List<Object> sendResponse = new List<Object>();
            List<sObject> objects = new List<sObject>();
            List<String> PGProdList = new List<String>();
            List<Object> iPProdList = new List<Object>();
            boolean isOverlapping;
            Date startDate;
            String accId;
            Opportunity dummyOpp = new Opportunity();
            Account dummyAcc = new Account();
            
            for(object obj : reslist){
                map<String,object> res = (map<String,object>)obj;
                
                if((String)res.get('label') =='PGProducts'){
                    PGProdList.add((String)res.get('value')); 
                }else if((String)res.get('label') =='iPProducts'){
                    iPProdList.add(res.get('value'));   
                } else if((String)res.get('label') =='StartDate'){
                    String closedate = (String)res.get('value');
                    Date d = date.valueOf(closedate);
                    Date finalDate = date.newInstance(d.year(), d.month(), d.day());
                    StartDate = finalDate;
                    
                    
                }
                else{
                    if(fmList.containskey((String)res.get('label'))){
                        if(fmList.get((String)res.get('label')).Instance_Name__c == 'both'||fmList.get((String)res.get('label')).Instance_Name__c == 'PG'){
                            if(sObjName == 'Opportunity'){
                                if((String)res.get('label') =='AccountId'){
                                    accId = (String)res.get('value');
                                }
                                if(fmList.get((String)res.get('label')).DataType__c !='Date'){
                                    
                                    dummyOpp.put((String)res.get('label'),(String)res.get('value'));  
                                    
                                }else{
                                    String closedate = (String)res.get('value');
                                    Date d = date.valueOf(closedate);
                                    Date finalDate = date.newInstance(d.year(), d.month(), d.day());
                                    dummyOpp.put((String)res.get('label'),finalDate);  
                                }
                                
                            }else if(sObjName == 'Account'){
                                if(fmList.get((String)res.get('label')).DataType__c =='Checkbox'){
                                    
                                    dummyAcc.put((String)res.get('label'),(Boolean)res.get('value'));  
                                    boolean  Overlap_Agent = false;
                                    boolean Brickz_Agent = false;
                                    if((String)res.get('label') == 'Brickz_Agent__c'){
                                        Brickz_Agent = (boolean)dummyAcc.get('Brickz_Agent__c');    
                                    }
                                    else if((String)res.get('label') == 'Overlap_Agent__c'){
                                        
                                        Overlap_Agent = (boolean)dummyAcc.get('Overlap_Agent__c');
                                    }
                                    if(Brickz_Agent||Overlap_Agent){
                                        isOverlapping = true;   
                                    }
                                    
                                    else {
                                        isOverlapping = false;
                                    }
                                    
                                    
                                }
                                else if(fmList.get((String)res.get('label')).DataType__c !='Date'){
                                    
                                    dummyAcc.put((String)res.get('label'),(String)res.get('value'));  
                                    
                                }else{
                                    String closedate = (String)res.get('value');
                                    Date d = date.valueOf(closedate);
                                    Date finalDate = date.newInstance(d.year(), d.month(), d.day());
                                    dummyAcc.put((String)res.get('label'),finalDate);  
                                }
                                
                            }
                        }
                        if(fmList.get((String)res.get('label')).Instance_Name__c == 'both'||fmList.get((String)res.get('label')).Instance_Name__c == 'iPP'){
                            if((String)res.get('label')!='AccountId'){
                                sendResponse.add(obj);      
                            }
                            
                        }   
                    }
                }  
                
            }
            if(startdate!=null){
                DateTime dT = System.today();
                Date currentDate = date.newinstance(dT.year(), dT.month(), dT.day());
                if(startdate < currentDate){
                    resWrap.error = 'Start Date cannot be in past'; 
                    return resWrap;   
                }   
            }
            if(accId!=null){
                Account acc = [Select id,External_field__c,AgentNet_ID__c,country__c,Test_Account__c,NetSuite_Id__c from Account where id =: accId];
                
                if(acc.External_field__c == null){
                    resWrap.error = 'Related Account should be an overlapping account'; 
                    return resWrap;
                }else if(acc.AgentNet_ID__c == null){
                    resWrap.error = 'Please sync account record to AdminNet'; 
                    return resWrap;
                }
                else if(acc.Test_Account__c == true){
                    resWrap.error = 'This is a test account';  
                    return resWrap;
                }
                else if(acc.NetSuite_Id__c == null){
                    resWrap.error = 'Please sync account record to Netsuite'; 
                    return resWrap;
                }
                else if(acc.country__c != 'Malaysia'){
                    resWrap.error = 'Cross Sell Opportunities can only be created for MY agents'; 
                    return resWrap;
                }
                if(acc.External_field__c != null){
                    resp.accountId = acc.External_field__c;
                } 
                
            }
            if(sObjName == 'Opportunity'){
                dummyOpp.put('recordtypeid',recordtype);
                objects.add(dummyOpp); 
            }
            else if(sObjName == 'Account'){
                dummyAcc.put('recordtypeid',recordtype);
                objects.add(dummyAcc); 
            }
            
            resp.sendResponse = sendResponse;
            resp.prodList = iPProdList;
            resp.StartDate = StartDate;
            
            String endPoint= sd.EndPoint__c+'?grant_type=password&password='+sd.password__c+'&username='+
                +sd.UserName__c+'&client_id='+sd.ClientID__c+
                '&client_secret='+sd.Client__c;
            if(!objects.isempty())
                insert objects;
            resp.objectId = objects[0].id;
            resWrap.objId = objects[0].id;
            String reqBody = JSON.serialize(resp);
            
            getToken(endPoint,reqBody,isOverlapping,sObjName,objects[0].id);
            if(sObjName == 'Opportunity'){
                Set<String> oppIds = new Set<String>();
                for(sobject opp:objects) {
                    oppIds.add(opp.Id);
                }
                createQuote(oppIds,PGProdList,StartDate);
            }
        }
        
        return resWrap;
    }
    @future(callout=true)
    public static void getToken(String endPoint,String reqBody,Boolean isOverlapping,String sObjName,String objectId){
        
        Account acc = new Account();
        Opportunity opp = new Opportunity();
        if(sObjName == 'Account'){
            acc = [Select id,External_Field__c from account where id =:objectId];
            
        }   
        if(sObjName == 'Opportunity'){
            opp = [Select id,External_Field__c from Opportunity where id =:objectId];
            
        }    
        Id accId;
        Map<string,string> reqHeaders = new Map<string,string>();
        
        String error = null;
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
        if(response!=null && response.getStatusCode() == 200) { 
            String resBody=response.getBody();
            
            map<String, object> responseJson = (map<String, object>)JSON.deserializeUntyped(resBody);
            String token=(String) responseJSON.get('access_token');
            Map<String,String> res = new Map<String,String>();
            res.put('token',token);
            res.put('URL',(String) responseJSON.get('instance_url'));
            
            
            if(!res.isempty()){
                endpoint=res.get('URL')+ '/services/apexrest/api/createOpportunitiesAndQuotes';
                
                reqHeaders.clear();
                //  reqHeaders.put('accept','*/*');
                reqHeaders.put('Authorization','Bearer '+token);
                reqHeaders.put('Content-Type','application/json');
                reqHeaders.put('accept','application/json');
                if(!test.isRunningTest())
                    response = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,endPoint,reqBody,'POST',true,false,
                                                                             null,30000);
                else{
                    response = new HTTPResponse();
                    response.setStatusCode(201);
                    response.setBody('{"id":"0068G0000051G1oQAE","success":true,"errors":[]}');
                }
                if(response!=null){
                    system.debug('****'+response.getBody());
                    system.debug('****'+response.getStatusCode());
                    
                    if((response.getStatusCode() != 200)){
                        
                        if(response.getStatusCode() == 201) { 
                            String resBody2=response.getBody();
                            
                            Map<String,Object> objList = (Map<String,Object>) JSON.deserializeUntyped(resBody2);
                            
                            list<object> d = new list<Object>();
                            d.add(objList);
                            
                            
                        }
                        else  if(response.getStatusCode() == 204) { 
                            error = 'error';
                            
                        }
                        else  if(response.getStatusCode() == 400) { 
                            error = (String)response.getBody();
                            
                        }
                        
                        else{
                            String resBody1=response.getBody();
                            List<Object> objList = (List<Object>) JSON.deserializeUntyped(resBody1);
                            Map<String, Object> obj = (Map<String, Object>)objList[0];
                            
                            system.debug(obj.get('errorCode') +': '+obj.get('message'));
                            error = (String)obj.get('message');
                        }   
                    }else{
                        String successResp =  (String)response.getBody();
                        Boolean isObject ;
                        if(successResp.startsWithIgnoreCase('001') || successResp.startsWithIgnoreCase('006')){
                            isObject = true;  
                        }else{
                            isObject = false; 
                            error = successResp;
                        }
                        if(isObject){
                            String objId = (id)response.getBody();
                            
                            if(sObjName == 'Account'){
                                if(isOverlapping!=null && isOverlapping && objId!=null){
                                    acc.put('External_Field__c',objId);
                                }
                                update acc;
                            }   
                            if(sObjName == 'Opportunity'){
                                if(objId!=null){
                                    opp.put('External_Field__c',objId);
                                }
                                update opp;    
                            }  
                        }
                    }
                }
            }  
        }
        else{
            error = 'connection failed';
            
        }
        //return resultwrp;
        Id recId;
        if(error!=null){
            if(sObjname =='Account'){
                acc.iPP_Sync_Error__c = error;
                update acc;
                recId = acc.id;
            } 
            if(sObjname =='Opportunity'){
                opp.iPP_Sync_Error__c = error;
                update opp;
                recId = opp.id;
            } 
            // To send alert on PG Automation Channel           
            String slack_user = label.PG_LABEL_INSTANCE_SYNC;
            String text = '', payload = '';
            String title = slack_user +' '+ 'Please find detailed Error information on creation of overlapping data\n';
            text += '```"RECORDID", "ERROR"\n';
            text += '"'+recId+'", "'+error+'"\n';
            if(String.isNotBlank(text)){
                text += '```';
                payload += title + text; 
            }
            if(payload!= '') {
                SlackAlert.notifyPGAutoChannel(payload);
            }
            
        }
    }
    public static void createQuote(Set<String> oppIds,list<String> prodskucode,Date StartDate){
        Map<String, Subsidiary__c> mapOfSubsidiary = PGOpportunityTriggerHandler.getSubsidiaryMap();
        Map<Id, String> OwnerSubsNameIdMap = PGOpportunityTriggerHandler.UserIdSubsIdMap();
        Map<Id, Id> SubsIdPBIdMap = PGOpportunityTriggerHandler.SubsidiaryIdPricebookIdMap();
        
        Set<String> currencyIsoCode = new Set<String>();
        Set<String> priceBook2Ids = new Set<String>();
        List<Opportunity> oppList = [SELECT Id,Name,Account_Email__c,Account_Phone__c,Account_Rule_Code__c,
                                     Addressee__c,Agency_Name__c,Agent_Accepted_Time__c,Allowed_Payment_Type__c,
                                     Apply_VIP_Discount__c,Approval_Requester_Comment__c,Approval_Selector__c,
                                     Approval_Status__c,Billing_Contact__c,billing_OMC_Approved__c,Budget_Confirmed__c,
                                     ByAuto__c, Create_NS_Customer__c,Customer_PO__c,Discount_Remarks__c,
                                     Discovery_Completed__c,FOC_Approved__c,From_Button__c,Guruland_Link_Created_Date__c,
                                     Include_Subscription_Ext__c,IsClone__c,Is_Current_Subscription__c,Last_Outbound_Sync__c,
                                     Loss_Reason__c,Lost_Sub_Reason__c,Managerial_Approved__c,Memo__c,Months_Included__c,
                                     OMC_Approved_Date__c,OMC_Rejected_Reason__c,OMC_Submitted_Time__c,OMC_Urgent__c,
                                     Order_Date__c,Outbound_Sync_Error__c,Payment_Amount__c,Guruland_Quote_Link__c,
                                     Payment_Reference__c,Payment_Term__c,Payment_Time__c,PG_Tenure__c,
                                     Project_Opportunity_Amount__c,Pro_Rate__c,Push_Counter__c,Renewal_State__c,
                                     Re_print_Contract__c,ROI_Analysis_Completed__c,SO_Order__c,StageName,
                                     Submit_to_OMC_Manually__c,Subscription_Code__c,Subscription_End_Date__c,
                                     Sync_To_NetSuite__c,Total_Amount_Before_Discount_display__c,
                                     Total_Amount_of_FOC_Before_Discount_MY__c,Total_Complimentary_Value_display__c,
                                     Total_Discounted_Amount_display__c,Total_Gross_Amount_display__c,
                                     Total_Mgr_Disc_of_Discretionary_Amount__c,Total_Mgr_Disc_of_Discretionary_Percent__c,
                                     Total_Mgr_Disc_of_Subscription_Amount__c,Total_Mgr_Disc_of_Subscription_Percent__c,
                                     Total_Spending__c,Total_Tax_Amount_display__c,Upload_Tag__c,VIP_Approved__c,
                                     Subsidiary__c,Opportunity_Type__c,User_Sales_Head__c,
                                     SyncedQuoteId,
                                     Pricebook2Id,CurrencyIsoCode,accountid,ownerid,recordtypeid
                                     from opportunity where id in:oppIds];
        
        for(Opportunity opp:oppList) {
            currencyIsoCode.add(opp.CurrencyIsoCode);
        }
        
        
        Map<String,String> mapOfSkuCodeVsProdId = new Map<String,String>();
        
        for(Product2 prod:[SELECT Id,SKU_Code__c,Name FROM Product2 WHERE SKU_Code__c IN: prodskucode]) {
            mapOfSkuCodeVsProdId.put(prod.SKU_Code__c,prod.Id);
            
        }
        
        List<Quote> quoList = [SELECT Id,Name,PriceBook2Id,ownerid,issyncing,CurrencyIsoCode FROM Quote WHERE OpportunityId IN :oppIds];
        List<Quote> quoPriceBookIds = new List<Quote>();
        list<Opportunity> oppToupdate = new list<Opportunity>();
        List<Quote> createQuoteList = new list<Quote>();
        
        if(quoList.isempty()){
            createQuoteList = QuoteSyncHandler.quoteData(oppList,false);
            createQuoteList[0].ownerid = oppList[0].ownerid;
            
            if(!createQuoteList.isEmpty())
                insert createQuoteList ;
        }else{
            if(quoList[0].ownerid != oppList[0].ownerid)
                quoList[0].ownerid = oppList[0].ownerid;
            
            update quoList;
        }
        for(Quote q : [SELECT Id,Name,PriceBook2Id,issyncing,Opportunityid,Opportunity.Pricebook2Id,Opportunity.ownerId  FROM Quote WHERE OpportunityId IN :oppIds]){
            q.PriceBook2Id =  SubsIdPBIdMap.get(mapOfSubsidiary.get(OwnerSubsNameIdMap.get(q.Opportunity.ownerId)).Id);
            quoPriceBookIds.add(q);
            Opportunity op = new Opportunity(id =q.Opportunityid,PriceBook2Id = SubsIdPBIdMap.get(mapOfSubsidiary.get(OwnerSubsNameIdMap.get(q.Opportunity.ownerId)).Id) );
            oppToupdate.add(op);  
            priceBook2Ids.add(q.PriceBook2Id);
        }
        update quoPriceBookIds;
        update oppToupdate;
        Map<String,PriceBookEntry> mapOfProdIdVsPbeId = new Map<String,PriceBookEntry>();
        for(PriceBookEntry pbe:[SELECT Id,Pricebook2Id,Product2Id,Product2.SKU_Code__c,UnitPrice FROM PriceBookEntry 
                                WHERE IsActive=true AND Product2Id IN:mapOfSkuCodeVsProdId.values() AND 
                                CurrencyIsoCode=:currencyIsoCode AND Product2.SKU_Code__c IN:prodSkuCode]) {
                                    mapOfProdIdVsPbeId.put(pbe.Product2Id,pbe);
                                }
        
        
        List<Opportunity> syncQuo2Opp = new List<Opportunity>();
        for(Quote qu : [SELECT Id,Name,issyncing,Opportunityid FROM Quote WHERE OpportunityId IN :oppIds]){
            syncQuo2Opp.add(new Opportunity(id=qu.OpportunityId,syncedQuoteId=qu.Id));
            
        }
        update syncQuo2Opp;
        list<QuoteLineItem> listOfQliToInsert = new list<QuoteLineItem>();
        Map<Id,List<Item_Bundle__c>> prodIdVsItemBundle = new Map<Id,List<Item_Bundle__c>>();
        Map<string, Item_Bundle__c> mapItemBundle = new Map<string, Item_Bundle__c>();
        list<String> listChildProdWithSeqNo=new list<String>();
        
        for(Item_Bundle__c itemBundle :[select Id,Parent_Product__c, Child_Product__c, Qty__c,Sno__c, Upload_Tag__c from Item_Bundle__c
                                        where Parent_Product__c in :mapOfSkuCodeVsProdId.values() order By Sno__c ASC]) {
                                            System.debug('itemBundle :'+itemBundle);
                                            if(!prodIdVsItemBundle.containskey(itemBundle.Parent_Product__c)) {
                                                prodIdVsItemBundle.put(itemBundle.Parent_Product__c,new List<Item_Bundle__c>{itemBundle});
                                            } else {
                                                prodIdVsItemBundle.get(itemBundle.Parent_Product__c).add(itemBundle);
                                            }
                                            mapItemBundle.put(itemBundle.Child_Product__c, itemBundle);
                                            listChildProdWithSeqNo.add(itemBundle.Sno__c+'_'+itemBundle.Child_Product__c);
                                        }
        
        
        List<PricebookEntry> listchildPricebookEntry = [select Id, Name,UnitPrice, Pricebook2Id, Product2.Id, Product2.Name, Product2.Product_Type__c,
                                                        Product2.Description, Product2.Product_Category__c, Product2.Is_Bundle__c, Product2.SKU_Code__c,
                                                        Product2.CurrencyIsoCode, CurrencyIsoCode, Pricebook2.CurrencyIsoCode, Product2.Tax_Code__c, 
                                                        Product2.Tax_Code__r.Tax_Rate__c, Product2.Income_Account_Name__c FROM PricebookEntry 
                                                        WHERE  Product2.IsActive=TRUE AND IsActive=TRUE AND Pricebook2Id IN:priceBook2Ids  
                                                       ];
        
        listChildProdWithSeqNo.sort();
        
        Map<Id,PricebookEntry> mapOfProductWithPbe=new Map<Id,PricebookEntry>();
        for(PricebookEntry eachPbe: listchildPricebookEntry) {
            if(mapItemBundle.containsKey(eachPbe.Product2Id)) {
                mapOfProductWithPbe.put(eachPbe.Product2.Id,eachPbe);
            }
        }
        if(!mapOfSkuCodeVsProdId.isempty()){
            QuoteLineItem qliRecord = new QuoteLineItem();
            if(quoList.isempty() && !createQuoteList.isempty()){
                qliRecord.QuoteId = createQuoteList[0].id;
                
            }else{
                qliRecord.QuoteId = quoList[0].Id;  
                
            }
            if(StartDate!=null){
                qliRecord.Start_Date__c = StartDate; 
            }else{
                qliRecord.Start_Date__c = System.today();
            }
            qliRecord.SNo__c = 1;
            qliRecord.Quantity = 1;
            qliRecord.end_Date__c = qliRecord.Start_Date__c.addyears(1).adddays(-1);
            qliRecord.PricebookEntryId =mapOfProdIdVsPbeId.get(mapOfSkuCodeVsProdId.get(prodSkuCode[0])).Id;
            qliRecord.UnitPrice = mapOfProdIdVsPbeId.get(mapOfSkuCodeVsProdId.get(prodSkuCode[0])).UnitPrice;
            qliRecord.Product2Id = mapOfSkuCodeVsProdId.get(prodSkuCode[0]);
            listOfQliToInsert.add(qliRecord);
            
            if(prodIdVsItemBundle.containskey(mapOfSkuCodeVsProdId.get(prodSkuCode[0]))){
                listOfQliToInsert.addAll(insertChildQli(mapItemBundle,listChildProdWithSeqNo,mapOfProductWithPbe,mapOfSkuCodeVsProdId.get(prodSkuCode[0]),qliRecord,listchildPricebookEntry));
            }
            if(!listOfQliToInsert.isempty()){
                insert listOfQliToInsert;   
            }
        }  
        Set<id> setOfQliIdInserted = new Set<Id>();
        Set<id> Quoteid = new Set<Id>();
        
        for(QuoteLineItem qli : listOfQliToInsert){
            setOfQliIdInserted.add(qli.id); 
            Quoteid.add(qli.quoteid);
        }
        if(setOfQliIdInserted.size()>0){
            QliToOliSyncOnInsert(setOfQliIdInserted);
        } 
    }
    public static void QliToOliSyncOnInsert(Set<Id> setofQliId){
        
        List<QuoteLineItem> lstOfQLI=[Select Id,OpportunityLineItemId,Complimentary__c,Discount_Amount__c,Discount__c,End_Date__c,GST_VAT_Rate__c,Line_Description2__c,PO__c,Pro_Rate_Amount__c,Push_To_NetSuite__c,Record_Type__c,SNo__c,Start_Date__c,Quote.Invoice_Id__c,Discount_Reason__c,Amount_Despite_VIP__c,Product_Category__c from QuoteLineItem where Id IN :setofQliId];
        
        List<OpportunityLineItem> lstOppItem=new List<OpportunityLineItem>();
        for(QuoteLineItem eachQLI: lstOfQLI){
            OpportunityLineItem objOLI=new OpportunityLineItem(Id=eachQLI.OpportunityLineItemId);
            objOLI.Complimentary__c=eachQLI.Complimentary__c;
            objOLI.Discount_Amount__c=eachQLI.Discount_Amount__c; 
            objOLI.Discount__c=eachQLI.Discount__c;
            objOLI.End_Date__c=eachQLI.End_Date__c;
            objOLI.GST_VAT_Rate__c=eachQLI.GST_VAT_Rate__c;
            objOLI.Line_Description2__c=eachQLI.Line_Description2__c;
            objOLI.PO__c=eachQLI.PO__c;
            objOLI.Pro_Rate_Amount__c=eachQLI.Pro_Rate_Amount__c;
            objOLI.Push_To_NetSuite__c=eachQLI.Push_To_NetSuite__c;
            objOLI.Record_Type__c=eachQLI.Record_Type__c;
            objOLI.SNo__c=eachQLI.SNo__c;
            objOLI.Start_Date__c=eachQLI.Start_Date__c;
            objOLI.Discount_Reason__c=eachQLI.Discount_Reason__c;
            objOLI.Amount_Despite_VIP__c=eachQLI.Amount_Despite_VIP__c;
            objOLI.Product_Category__c=eachQLI.Product_Category__c;
            lstOppItem.add(objOLI);
        }
        If(lstOppItem.size()>0){
            QuoteSyncHandler.isQLITriggerFire=false;
            Update lstOppItem;
        }
        
    }
    public static List<QuoteLineItem> insertChildQli (Map<string, Item_Bundle__c> mapItemBundle,list<String> listChildProdWithSeqNo,Map<Id,PricebookEntry> mapOfProductWithPbe,Id parentProdId,QuoteLineItem qLIObj,List<PricebookEntry> childPriceBookEntry) {
        
        
        List<QuoteLineItem> childQLIList = new List<QuoteLineItem>();
        for (String each: listChildProdWithSeqNo){
            
            Decimal qliSno;
            if(each.substringBefore('_') != null) {
                qliSno = Decimal.valueOf(each.substringBefore('_'));
                
            }
            PricebookEntry row=mapOfProductWithPbe.get(each.substringAfter('_'));
            
            if(mapOfProductWithPbe.containskey(each.substringAfter('_'))){
                
                if (row.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode && row.Product2.CurrencyIsoCode == row.Pricebook2.CurrencyIsoCode) {
                    
                    QuoteLineItem childQLI = new QuoteLineItem();
                    childQLI.QuoteId = qLIObj.QuoteId;
                    childQLI.PricebookEntryId =row.Id;
                    childQLI.UnitPrice = 0;
                    childQLI.SNo__c = qliSno!=null?qliSno:null;
                    childQLI.Start_Date__c = qLIObj.Start_Date__c;
                    childQLI.End_Date__c = qLIObj.End_Date__c;
                    childQLI.Product_Type__c = row.Product2.Product_Type__c;
                    childQLI.Quantity = integer.valueOf(mapItemBundle.get(row.Product2.Id).Qty__c);
                    childQLI.Product2Id = row.Product2Id;
                    childQLI.Product2 = row.product2;
                    childQLI.Product2.Name = row.product2.Name;
                    childQLI.Description = row.Product2.Description;
                    childQLI.Parent__c = parentProdId;
                    childQLI.Child_Category__c = 'Package';
                    childQLI.Complimentary__c = true;
                    childQLI.Line_Description2__c = row.Product2.Description;
                    childQLI.Product_Category__c = row.Product2.Product_Category__c;
                    childQLI.Original_Price__c = childQLI.UnitPrice==null?0:childQLI.UnitPrice;
                    childQLI.Push_to_NetSuite__c = false;
                    if (row.Product2.Tax_Code__c != null) {
                        childQLI.GST_VAT_Code__c = row.Product2.Tax_Code__c;
                    } else {
                        childQLI.GST_VAT_Code__c = null;
                    }
                    if (row.Product2.Tax_Code__r != null ) {
                        childQLI.GST_VAT_Rate__c = row.Product2.Tax_Code__r.Tax_Rate__c;
                    } else {
                        childQLI.GST_VAT_Rate__c = 0;
                    }
                    childQLI.Income_Account_Name__c = row.Product2.Income_Account_Name__c;
                    childQLI.PO__c = true;
                    childQLIList.add(childQLI);
                }
            }
        }
        return childQLIList;
    }
    
    public class fieldswrapperClass{
        @auraEnabled
        public string objName;
        @auraEnabled
        public List<field_Mapping__c> fmList;
        @Auraenabled
        public list<MY_Products__c> products;
        @AuraEnabled
        public String recordtype;
        @AuraEnabled
        public String recordName;
        
    }
    public class responseClass{
        String email; 
        String sObjName;
        String desrecordtype;
        String objectId;
        String accountId;
        Date StartDate;
        list<Object> sendResponse;
        list<Object> prodList;
    }
    public class resultWrapper{
        @AuraEnabled
        public String error;
        @AuraEnabled
        public Id objId;
    }
}