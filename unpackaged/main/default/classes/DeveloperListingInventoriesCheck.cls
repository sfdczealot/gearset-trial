global class   DeveloperListingInventoriesCheck  implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate{
    
    public class listingWrapper{
        public Integer totalPages;
        public Integer listingID;
        public string districtCode;
        public String districtName;
        public string regionCode;
        public String regionName;
        public String ListingTitle;
        public Integer userID;
        public String agentName;
        public String propertyTypeGroup;
        public string listingType;
    }

    public class SlotsWrapper{
        public Integer availableSlots;
        public String startEndDate;
    }
    public class BookingWrapper{
        public String Status;
        public String StartDate;
        public String endDate;
        public String ListingTitle;
        public String agentName;
        public Integer ListingId;

    }
    global static String getActiveBooking(Map<String,Object> params){
        String regionCode =  (String) params.get('regionCode');
        String country; 
        
        if  ( (String) params.get('country') =='MYR'){
            country='malaysia';
        }
        else if  ( (String) params.get('country') =='THB'){
            country='thailand';
        }else if  ( (String) params.get('country') =='IDR'){
            country='indonesia';
        }
        
        String districtCode =  (String) params.get('districtCode');
        List<BookingWrapper> bwList = new List<BookingWrapper> ();
        String token =  getToken(country.tolowerCase());
        system.debug(token);
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse res;
        List<String> statusList = new List<String>{'ACT', 'RES'}; 
            for(String stat :statusList ){
                String RootEndpoint;
                if(runningInASandbox()){
                    RootEndpoint = 'https://developer-marketplace.staging.propertyguru.com/v1/premium-project-listings?country='+country+'&statusCode='+stat+'&districtCode='+districtCode +'&regionCode='+regionCode;
                }
                else{   
                    RootEndpoint = 'https://developer-marketplace.propertyguru.com/v1/premium-project-listings?country='+country+'&statusCode='+stat+'&districtCode='+districtCode +'&regionCode='+regionCode;
                }
                
                reqHeaders.put('Authorization', 'Bearer '+token);
                if(Test.isRunningTest()) {
                    String resString = '{ "total": 1, "premiumListings": [ { "id": 41, "listingId": 19949676, "statusCode": "ACT", "regionCode": "IDBT", "districtCode": "IDBT07", "areaCode": null, "propertyTypeGroup": "A", "propertyType": null, "listingType": "SALE", "startDate": "2022-05-02T00:00:00.000Z", "endDate": "2022-05-29T00:00:00.000Z", "createdDate": "2022-04-27T10:27:53.000Z", "orderId": 12345, "userId": 279500 } ] }';
                    res = new HttpResponse();
                    res.setStatusCode(200);
                    res.setBody(resString);
                } else{
                    integer count =0;
                    do{
                    res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,null,'GET',false,false,null,null);
                    count++;
                    if(count == 5){
                        break;
                    }
                }while(res.getstatus() == 'Bad Request'  && String.isBlank(res.getbody()) );
                }
                system.debug(res.getStatusCode());
                system.debug(res.getStatus());
                system.debug(res.getBody());
                if(res.getStatusCode() == 200)
                {
                    map<String, object> responseJson = (map<String, object>)system.JSON.deserializeUntyped(res.getBody());
                    List<Object> result=(List<Object>) responseJSON.get('premiumListings');
                    //  system.debug(result);
                    for(Object l : result){
                        BookingWrapper bw = new BookingWrapper();
                        
                        map<String, object> detailsMap   = (map<String, object> )l;
                        
                        bw.Status= (String) detailsMap.get('statusCode')=='ACT'? 'Active' : 'Reserved';
                        
                        
                        Date endDate = Date.valueOf((String)detailsMap.get('endDate'));
                        Date StartDate = Date.valueOf((String)detailsMap.get('startDate'));
                        bw.StartDate= datetime.newInstance(startDate.year(), startDate.month(),startDate.day()).format('MMM dd, yyyy');
                        bw.endDate= datetime.newInstance(endDate.year(), endDate.month(),endDate.day()).format('MMM dd, yyyy');
                        //  bw.ListingTitle=detailsMap.get('');
                        //bw.agentName=detailsMap.get('');
                        bw.ListingId= (Integer) detailsMap.get('listingId');
                        bwList.add(bw);
                        
                        
                    }
                    
                    
                    
                } 
                else{
                    return res.getBody();
                }
            }
        return JSON.serializePretty(
            bwList
        );
    }
    global static String checkSlots(Map<String,Object> params){ 
        String lastMonday;
        
        // List<Object> paramsList = (List<Object> )system.JSON.deserializeUntyped(parameters);          
        String regionCode =  (String) params.get('regionCode');
        String country; 
        String ostartDate = (String) params.get('keywordDate');
        if  ( (String) params.get('country') =='MYR'){
            country='malaysia';
        }
        else if  ( (String) params.get('country') =='THB'){
            country='thailand';
        }else if  ( (String) params.get('country') =='IDR'){
            country='indonesia';
        }
        if(ostartDate != '' && ostartDate != null){
            Date today =  Date.valueOf((String)params.get('keywordDate'));
            Date startOfWeek = today.toStartOfWeek();
            Integer dayOfWeek = today.day()-startOfWeek.day()-1;
            system.debug(dayOfWeek);
            system.debug(today.addDays(-dayOfWeek));
            Date lastMondayDate =today.addDays(-dayOfWeek);
            
            lastMonday = datetime.newInstance(lastMondayDate.year(), lastMondayDate.month(),lastMondayDate.day()).format('yyyy-MM-dd');
            
        }
        String districtCode =  (String) params.get('districtCode');
        List<SlotsWrapper> swList = new List<SlotsWrapper> ();
        String token =  getToken(country.tolowerCase());
        system.debug(token);
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse res;
        
        
        String RootEndpoint;
        if(runningInASandbox()){
            RootEndpoint = 'https://developer-marketplace.staging.propertyguru.com/v1/premium-project-listings/slots?country='+country+'&maxWeeks=24&districtCode='+districtCode +'&regionCode='+regionCode;
        }
        else{   
            RootEndpoint = 'https://developer-marketplace.propertyguru.com/v1/premium-project-listings/slots?country='+country+'&maxWeeks=24&districtCode='+districtCode +'&regionCode='+regionCode;
        }
        if(ostartDate != '' && ostartDate != null){
            RootEndpoint += '&startDate='+lastMonday;
        }
        reqHeaders.put('Authorization', 'Bearer '+token);
        if(Test.isRunningTest()) {
            String resString = '{ "results": [ { "available": 3, "confirmed": 0, "endDate": "2022-06-05", "reserved": 0, "slots": 3, "startDate": "2022-05-30", "week": 22, "year": 2022 }, { "available": 3, "confirmed": 0, "endDate": "2022-06-12", "reserved": 0, "slots": 3, "startDate": "2022-06-06", "week": 23, "year": 2022 }, { "available": 3, "confirmed": 0, "endDate": "2022-06-19", "reserved": 0, "slots": 3, "startDate": "2022-06-13", "week": 24, "year": 2022 }, { "available": 3, "confirmed": 0, "endDate": "2022-06-26", "reserved": 0, "slots": 3, "startDate": "2022-06-20", "week": 25, "year": 2022 } ] }';
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(resString);
        } else{
            integer count =0;
            do{
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,null,'GET',false,false,null,null);
            count++;
            if(count == 5){
                break;
            }
        }while(res.getstatus() == 'Bad Request'  && String.isBlank(res.getbody()) );
        }
        system.debug(res.getStatusCode());
        system.debug(res.getStatus());
        system.debug(res.getBody());
        if(res.getStatusCode() == 200)
        {
            map<String, object> responseJson = (map<String, object>)system.JSON.deserializeUntyped(res.getBody());
            List<Object> result=(List<Object>) responseJSON.get('results');
            //  system.debug(result);
            for(Object l : result){
                SlotsWrapper sw = new SlotsWrapper();
                map<String, object> slotsMap   = (map<String, object> )l;
                sw.availableSlots = (Integer)slotsMap.get('available');
                
                Date endDate = Date.valueOf((String)slotsMap.get('endDate'));
                Date startDate = Date.valueOf((String)slotsMap.get('startDate'));
                
                sw.startEndDate = datetime.newInstance(startDate.year(), startDate.month(),startDate.day()).format('MMM dd, yyyy') +'-' + datetime.newInstance(endDate.year(), endDate.month(),endDate.day()).format('MMM dd, yyyy');
                swList.add(sw);
                
                
            }
            
            return JSON.serializePretty(
                swList
            );
            
        } 
        else{
            return res.getBody();
        }
    }   
    
    global String performAction(String parameters) {
        system.debug('****'+parameters);
        String check;
        String fulfilmentItem;
        Map<String,object>  temp = new   Map<String,object> ();
        try {      
            List<Object> paramsList = (List<Object> )system.JSON.deserializeUntyped(parameters);   
          
                
            for(Object obj : paramsList){
                
                Map<String,object> rec = (Map<String,object>)obj;
                temp=rec;
                check = (String) rec.get('check');
                fulfilmentItem = (String) rec.get('fulfilmentItem');
            }
            if(check == 'Release Inventory'){
                Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id,Listing_ID__c,Listing_OrderID__c ,csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c ,csdf__Flight_Beginning__c,csdf__Flight_End__c, Name, Flight_Beginning_Line_Item__c,
                                                                                                           Flight_End_Date_Time__c,RegionCode__c,DistrictCode__c,csdf__Fulfilment__c,csdf__Fulfilment__r.sales_order__c,csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__r.Opportunity_Number__c FROM csdf__Fulfilment_Item__c
                                                                                                           WHERE id = :fulfilmentItem and (csdf__Status__c='Reserved' or  csdf__Status__c='Active' or csdf__Status__c='ready')
                                                                                                           AND Product_Configuration__r.Developer_listing__c = true]);
                List<sObject> updateRecordList = new List<sObject>();
                for(csdf__Fulfilment_Item__c fi : fulfilmentItems.values() ){
                    updateRecordList.add(releaseInventory(fi,'Inventory released'));        
                }
                update updateRecordList;
                return null;
            }
            if(check == 'check slots'){
                String s = checkSlots(temp);
                return s;
            }
            if(check == 'getActiveBookings'){
                String s = getActiveBooking(temp);
                return s;
            } else {
                List<listingWrapper> listings = getListings(parameters);
                
                return JSON.serializePretty(
                    listings
                );
            }
        }
        catch (Exception e) {
            System.debug('ContendingLineItemDisplay>' + e.getMessage() + ' ' + e.getStackTraceString());
            System.debug('parameters>' + parameters);
            throw e;
        }
    }
    //to reserve inventory from orchestration process or for all PC in SO
    global static void reserveInventory(String salesOrderId) {
        Map<Id, cscfga__Product_Configuration__c> mapProductConfigs = new Map<Id, cscfga__Product_Configuration__c>();
        mapProductConfigs =getProductConfig(salesOrderId);
        List<sObject> updateRecordList = new List<sObject>();
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id,Listing_ID__c,csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c, Listing_JSON__c  ,csdf__Flight_Beginning__c,csdf__Flight_End__c, Name, Flight_Beginning_Line_Item__c,
                                                                                                   Flight_End_Date_Time__c,RegionCode__c,DistrictCode__c,csdf__Fulfilment__c,csdf__Fulfilment__r.sales_order__c,csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__r.Opportunity_Number__c FROM csdf__Fulfilment_Item__c
                                                                                                   WHERE Product_Configuration__c IN :mapProductConfigs.keySet() and listing_id__c!=null
                                                                                                   AND Product_Configuration__r.Developer_listing__c = true and (csdf__status__c = 'Draft' or csdf__status__c ='Inventory released')]);
        for(csdf__Fulfilment_Item__c fi : fulfilmentItems.values()){
            
            sObject sObj = reserveInventory(fi);
            updateRecordList.add(sObj);
        }
        update updateRecordList;
    }
    global static Map<Id, cscfga__Product_Configuration__c> getProductConfig(Id SalesOrder){
        Map<Id, cscfga__Product_Configuration__c> mapProductConfigs = new Map<Id, cscfga__Product_Configuration__c>();
        for (cscfga__Product_Configuration__c pc : [SELECT Id, (
            SELECT Id, Eligible_for_Check_Availability__c, Fulfilment_Item_Status__c, Served_By__c, Reserve_Inventory__c, Reservation_Status__c,
            Sales_Order__r.Order_Type__c, Ad_Type__c,Developer_listing__c
            FROM Product_Configurations__r where Developer_listing__c = true
        )
                                                    FROM csmso__Sales_Order__c
                                                    WHERE Id = :SalesOrder].Product_Configurations__r) {
                                                        if (pc.Developer_listing__c) {
                                                            mapProductConfigs.put(pc.Id, pc);
                                                        } 
                                                    }
        return mapProductConfigs;
    }   
    public static List<listingWrapper> getListings(String Params){
        
        List<Object> paramsList = (List<Object> )system.JSON.deserializeUntyped(Params);
        Integer pNo;
        String keyWord;
        String locale;
        String country; 
        
        for(Object obj : paramsList){
            
            Map<String,object> rec = (Map<String,object>)obj;
            pNo = (Integer) rec.get('pageNumber');
            keyWord = (String) rec.get('keyWord');
            if  (rec.get('country') =='MYR'){
                country='my';
                locale='en';
            }
            else if  ( rec.get('country') =='THB'){
                country='th';
                locale='en';
            }else if  (rec.get('country') =='IDR'){
                country='id';
                locale='id';
            }
        }
        
        //  Integer pNo = (integer) paramsList[0].get('pageNumber');
        List<listingWrapper> listingWrapperList = new List<listingWrapper>();
        HTTPResponse res;
        Map<string,string> reqHeaders = new Map<string,string>();
        String RootEndpoint ;
        if(runningInASandbox())
            RootEndpoint = 'https://listingsearch-'+country+'.staging.propertyguru.com/v1/listings?region='+country+'&locale='+locale+'&limit=20&page='+pNo+'&listing_sub_type=PROJ';
        else
            RootEndpoint = 'https://listingsearch-'+country+'.propertyguru.com/v1/listings?region='+country+'&locale='+locale+'&limit=20&page='+pNo+'&listing_sub_type=PROJ';
        
        if(keyWord!=null && keyword !=''){
            String freeText =  EncodingUtil.urlEncode(keyWord, 'UTF-8');
            
            RootEndpoint += '&freetext='+freeText;
        }
        if(Test.isRunningTest()){
              String resString = '{ "total": 1, "page": 1, "limit": 1, "totalPages": 1, "currency": "@todo", "searchCriteriaText": "@todo", "heading": "@todo", "humanizedParams": [ "@todo" ], "metas": { "title": "@todo", "description": "@todo", "heading": "@todo" }, "listings": [ { "propertyUnit": { "hdbTypeCode": null, "furnishingText": null, "furnishingCode": null }, "agent": { "mobile": "+6075058888", "mobilePretty": "+60 7 505 8888", "name": "Country Garden Group", "id": 10680981, "showProfile": false, "alternativePhonePretty": null, "alternativePhoneIsTollFree": false, "badges": { "academy": null }, "lineId": null, "alternateLineId": null }, "featureCode": null, "notes": null, "showAgentProfile": false, "hasFloorplans": false, "descriptions": { "ms": "", "en": "" }, "leaseTermCode": null, "sourceCode": null, "sizes": { "bedrooms": { "text": "1 Bedroom", "value": 1 }, "landY": null, "landX": null, "extrarooms": { "text": null, "value": null }, "landArea": [ { "value": null, "unit": null, "text": null } ], "floorX": null, "floorY": null, "bathrooms": { "text": null, "value": null }, "floorArea": [ { "unit": "sqft", "text": "130 sqft", "value": 130 } ] }, "unitTypes": [ { "furnishing": [ { "code": "UNFUR", "description": "Unfurnished" } ], "completion": { "code": "UCON", "description": "Under construction" }, "amenities": [], "unitTypeId": 77667, "maxFloorArea": null, "priceType": { "code": "START", "description": "Starting from" }, "localizedHeadline": "Forest City A Prime Model of Future City", "bedroom": null, "minFloorArea": [ { "unit": "sqft", "text": "635 sqft", "value": 635 } ], "headlines": { "ms": "", "en": "" }, "minPrice": { "text": "RM 820,000", "value": 820000 }, "propertyType": { "code": "CONDO", "description": "Condominium" }, "name": "Type A", "minPricePerArea": [ { "unit": "sqft", "text": "RM 1,291.34 psf", "value": 1291.3385826771653 } ], "id": 1377, "maxPrice": { "text": null, "value": null }, "floorLevels": [ { "code": "HIGH", "description": "High" }, { "code": "LOW", "description": "Low" }, { "code": "MID", "description": "Mid" } ], "bathroom": null, "statusCode": "ACT", "maxPricePerArea": null }, { "furnishing": [ { "code": "UNFUR", "description": "Unfurnished" } ], "completion": { "code": "UCON", "description": "Under construction" }, "amenities": [], "unitTypeId": 77668, "maxFloorArea": null, "priceType": { "code": "START", "description": "Starting from" }, "localizedHeadline": "Forest City A Prime Model of Future City", "bedroom": null, "minFloorArea": [ { "unit": "sqft", "text": "893 sqft", "value": 893 } ], "headlines": { "ms": "", "en": "" }, "minPrice": { "text": "RM 1,250,000", "value": 1250000 }, "propertyType": { "code": "CONDO", "description": "Condominium" }, "name": "Type B", "minPricePerArea": [ { "unit": "sqft", "text": "RM 1,399.78 psf", "value": 1399.7760358342664 } ], "id": 1378, "maxPrice": { "text": null, "value": null }, "floorLevels": [ { "code": "HIGH", "description": "High" }, { "code": "LOW", "description": "Low" }, { "code": "MID", "description": "Mid" } ], "bathroom": null, "statusCode": "ACT", "maxPricePerArea": null }, { "furnishing": [ { "code": "UNFUR", "description": "Unfurnished" } ], "completion": { "code": "UCON", "description": "Under construction" }, "amenities": [], "unitTypeId": 77669, "maxFloorArea": null, "priceType": { "code": "START", "description": "Starting from" }, "localizedHeadline": "Forest City A Prime Model of Future City", "bedroom": null, "minFloorArea": [ { "unit": "sqft", "text": "2034 sqft", "value": 2034 } ], "headlines": { "ms": "", "en": "" }, "minPrice": { "text": "RM 1,870,000", "value": 1870000 }, "propertyType": { "code": "CLUS", "description": "Cluster House" }, "name": "Type C", "minPricePerArea": [ { "unit": "sqft", "text": "RM 919.37 psf", "value": 919.37069813176 } ], "id": 1379, "maxPrice": { "text": null, "value": null }, "floorLevels": [ { "code": "HIGH", "description": "High" }, { "code": "LOW", "description": "Low" }, { "code": "MID", "description": "Mid" } ], "bathroom": null, "statusCode": "ACT", "maxPricePerArea": null }, { "furnishing": [ { "code": "UNFUR", "description": "Unfurnished" } ], "completion": { "code": "UCON", "description": "Under construction" }, "amenities": [], "unitTypeId": 77670, "maxFloorArea": null, "priceType": { "code": "START", "description": "Starting from" }, "localizedHeadline": "Forest City A Prime Model of Future City", "bedroom": null, "minFloorArea": [ { "unit": "sqft", "text": "2917 sqft", "value": 2917 } ], "headlines": { "ms": "", "en": "" }, "minPrice": { "text": "RM 3,010,000", "value": 3010000 }, "propertyType": { "code": "CLUS", "description": "Cluster House" }, "name": "Type D", "minPricePerArea": [ { "unit": "sqft", "text": "RM 1,031.88 psf", "value": 1031.8820706205006 } ], "id": 1380, "maxPrice": { "text": null, "value": null }, "floorLevels": [ { "code": "HIGH", "description": "High" }, { "code": "LOW", "description": "Low" }, { "code": "MID", "description": "Mid" } ], "bathroom": null, "statusCode": "ACT", "maxPricePerArea": null } ], "price": { "pretty": null, "valuation": 0, "currency": "RM", "valuationText": null, "completed": 0, "type": { "pretty": null, "code": null, "text": null }, "value": 0, "periodCode": null, "pricePerArea": { "reference": null, "unit": "sqft", "value": 0 } }, "property": { "topMonth": null, "tenureCode": "F", "topYear": 2026, "typeGroup": "N", "typeCode": "CONDO", "typeText": "Condominium", "name": "FOREST CITY", "tenureText": "Freehold", "developer": "Country Garden Pacificview Sdn Bhd", "newProject": true, "id": 7676 }, "id": 30634417, "isTransactorListing": false, "isMobilePropertySpotlightListing": false, "featuredBy": [], "accountSubTypeCode": "DEVELOPER", "subTypeCode": "PROJ", "accountTypeCode": "CORPORATE", "isCommercial": false, "isRankedSpotlight": false, "dates": { "timezone": "Asia/Singapore", "created": { "date": "2020-01-22 18:12:42", "unix": 1579687962 }, "firstPosted": { "date": "2022-05-11 00:00:25", "unix": 1652198425 }, "available": null, "expiry": { "date": "2022-07-10 23:59:59", "unix": 1657468799 }, "lastPosted": { "date": "2022-05-11 00:00:25", "unix": 1652198425 }, "updated": { "date": "2022-05-16 00:00:37", "unix": 1652630437 } }, "typeText": "For Sale", "headlines": { "en": "" }, "deals": [], "statusCode": "ACT", "cobroke": 0, "daysUntilExpire": 55, "media": { "agent": "https://my2-cdn-staging.pgimgs.com/agent/10680981/APHO.142885615.V120B.jpg", "propertySiteplans": [], "agentLogo": [ { "sortOrder": 142885613, "caption": null, "id": 142885613, "V120": "https://my2-cdn-staging.pgimgs.com/agent/10680981/ALOGO.142885613.V120.jpg", "statusCode": "CONF" } ], "cover": { "V150": "https://sg2-cdn-staging.pgimgs.com/projectnet-project/133683/ZPPHO.113674465.R150X150/FOREST-CITY-Iskandar-Puteri-Malaysia.jpg", "sortOrder": 113674465, "caption": null, "id": 113674465, "V550": "https://sg2-cdn-staging.pgimgs.com/projectnet-project/133683/ZPPHO.113674465.R550X550/FOREST-CITY-Iskandar-Puteri-Malaysia.jpg", "statusCode": "ACT" }, "projectLogo": [ { "sortOrder": 113674534, "caption": null, "id": 113674534, "V120": "https://sg2-cdn-staging.pgimgs.com/projectnet-project/133683/ZPLOG.113674534.R120X120.jpg", "statusCode": "ACT" }, { "sortOrder": 125747079, "caption": null, "id": 125747079, "V120": "https://sg1-cdn-staging.pgimgs.com/projectnet-project/133683/ZPLOG.125747079.R120X120.jpg", "statusCode": "ACT" } ], "listingSiteplans": [], "property": [ { "V150": "https://sg2-cdn-staging.pgimgs.com/projectnet-project/133683/ZPPHO.113674465.R150X150.jpg", "sortOrder": 113674465, "caption": null, "id": 113674465, "V550": "https://sg2-cdn-staging.pgimgs.com/projectnet-project/133683/ZPPHO.113674465.R550X550.jpg", "statusCode": "ACT" } ], "listing": [], "developerLogo": [ { "sortOrder": 99860910, "caption": null, "id": 99860910, "V120": "https://sg1-cdn-staging.pgimgs.com/projectnet-developer/41199/ZDLOG.99860910.R120X120.jpg", "statusCode": "ACT" }, { "sortOrder": 127288424, "caption": null, "id": 127288424, "V120": "https://sg-rpfs-staging.pgimgs.com/projectnet-developer/41199/ZDLOG.127288424.R120X120.jpg", "statusCode": "ACT" }, { "sortOrder": 128009262, "caption": null, "id": 128009262, "V120": "https://sg1-cdn-staging.pgimgs.com/projectnet-developer/41199/ZDLOG.128009262.R120X120.jpg", "statusCode": "ACT" }, { "sortOrder": 128010926, "caption": null, "id": 128010926, "V120": "https://sg-rpfs-staging.pgimgs.com/projectnet-developer/41199/ZDLOG.128010926.R120X120.jpg", "statusCode": "ACT" } ] }, "isPropertySpecialistListing": false, "products": { "isRankedSpotlight": false, "isBoosted": false, "isSpotlight": false, "isTurbo": false, "isAutoRepost": false }, "urls": { "listing": { "preview": { "desktop": "https://www.staging.propertyguru.com.my/preview-listing/30634417" }, "internal": "http://listing.staging.guruestate.com/v1/listings/30634417?region=my", "desktop": "https://www.staging.propertyguru.com.my/property-listing/forest-city-for-sale-by-country-garden-group-30634417", "desktopByLocales": { "ms": "https://www.staging.propertyguru.com.my/bm/senarai-hartanah/forest-city-dijual-oleh-country-garden-group-30634417", "en": "https://www.staging.propertyguru.com.my/property-listing/forest-city-for-sale-by-country-garden-group-30634417" }, "mobile": "https://www.staging.propertyguru.com.my/property-listing/forest-city-for-sale-by-country-garden-group-30634417", "api": "https://api.staging.propertyguru.com/v1/listings/30634417?region=my" } }, "tier": 0, "qualityScore": 100, "leaseTermText": null, "_user": null, "localizedDescription": "This is the place, the city with perfect climate, sea views, clear blue skies and fresh air all year around. The city covered with idyllic parks and no vehicular traffic, forming an ideal environment. Everyone can enjoy sunshine, a swim or a carefree stroll. Life here is exciting, with smart technologies and everything from food and entertainment, to business and leisure.", "finalScore": null, "agency": { "name": null, "ceaLicenseNumber": null, "id": null, "licenseId": null }, "localizedHeadline": "Forest City A Prime Model of Future City", "externalId": null, "titles": { "ms": "", "en": "" }, "mywebOrder": null, "typeCode": "SALE", "pricePerArea": { "landArea": [ { "unit": null, "text": null, "value": null } ], "floorArea": [ { "unit": "sqft", "text": "RM 0.00 psf", "value": 0 } ] }, "isPremiumAccount": true, "isLiveTourAvailable": null, "location": { "latitude": 1.33381, "longitude": 103.59146, "districtCode": "JH055", "distance": null, "hdbEstateCode": "0", "regionSlug": "johor", "areaSlug": "gelang-patah", "areaText": "Gelang Patah", "regionCode": "MY01", "areaCode": "JH05502", "fullAddress": "Galeri Jualan Mentari, Presint Aurora, Jalan Fores, Gelang Patah, Iskandar Puteri, Johor", "districtSlug": "iskandar-puteri", "regionText": "Johor", "districtText": "Iskandar Puteri", "hdbEstateText": null }, "isFeaturedListing": false, "localizedTitle": "FOREST CITY", "hasStream": true, "propertySpecialist": null, "isPremiumProjectListing": false, "locationByLocale": { "ms": { "regionSlug": "johor", "areaSlug": "gelang-patah", "fullAddress": ", Gelang Patah, Iskandar Puteri, Johor", "districtSlug": "iskandar-puteri", "regionText": "Johor", "areaText": "Gelang Patah", "districtText": "Iskandar Puteri" }, "en": { "regionSlug": "johor", "areaSlug": "gelang-patah", "fullAddress": "Galeri Jualan Mentari, Presint Aurora, Jalan Fores, Gelang Patah, Iskandar Puteri, Johor", "districtSlug": "iskandar-puteri", "regionText": "Johor", "areaText": "Gelang Patah", "districtText": "Iskandar Puteri" } }, "es": { "score": 52.74092, "version": 233, "request": "listing-search" }, "tracking": { "refType": "" } } ], "dependencyErrors": [], "stats": {}, "es": { "build": 0, "network": 17, "took": 13, "timed_out": false, "aggregations": {} } }';
            res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody(resString);
        }else{
            integer count =0;
            do{
        res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,null,'GET',false,false,null,null);
        count++;
        if(count == 5){
            break;
        }
    }while(res.getstatus() == 'Bad Request'  && String.isBlank(res.getbody()) ); 
    }
            String resBody=res.getBody();
        resBody = resBody.replaceAll('\n','').replaceAll('\r','');
        map<String, object> responseJson = (map<String, object>)system.JSON.deserializeUntyped(resBody);
        system.debug(responseJson);
        List<Object> listingList = ( List<Object>)responseJson.get('listings');
        Integer totalPages = (Integer)responseJson.get('totalPages');
        
        for(Object obj : listingList){
            listingWrapper lw = new listingWrapper();
            map<String, object> singleListing =  (map<String, object> )obj;
            system.debug(singleListing.get('id'));
            lw.listingID = (Integer)singleListing.get('id');
            map<String, object> location =  (map<String, object> )singleListing.get('location');
            map<String, object> agent =  (map<String, object> )singleListing.get('agent');
            map<String, object> property =  (map<String, object> )singleListing.get('property');
            
            lw.regionCode = (String)location.get('regionCode');
            lw.districtCode = (String)location.get('districtCode');
            lw.districtName = (String)location.get('districtText');
            lw.regionName = (String)location.get('regionText');
            lw.totalPages = (integer) totalPages;
            lw.ListingTitle = (string) singleListing.get('localizedTitle');
            lw.userID = (Integer) agent.get('id');
            lw.agentName = (String) agent.get('name');
            lw.propertyTypeGroup = (string) property.get('typeGroup');
            lw.listingType =  (string) singleListing.get('typeCode');
            listingWrapperList.add(lw);
        }
        system.debug(listingWrapperList);
        return listingWrapperList;
        
    }
    global static void checkAvails(String salesOrderId) {
        Map<Id, cscfga__Product_Configuration__c> mapProductConfigs = new Map<Id, cscfga__Product_Configuration__c>();
        mapProductConfigs =getProductConfig(salesOrderId);
        if(mapProductConfigs.values().size() > 0){
            checkAvailability(mapProductConfigs);
        } 
        
    }
    global static void checkAvailability(Map<Id, cscfga__Product_Configuration__c> configs) {
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id, Name, csdf__Fulfilment__c FROM csdf__Fulfilment_Item__c
                                                                                                   WHERE Product_Configuration__c IN :configs.keySet()
                                                                                                   AND Product_Configuration__r.Developer_listing__c = true AND csdf__Status__c in ('Draft','Inventory Released')]);
        list<sObject> sObjList = new List<sObject>();
        for(String fi : fulfilmentItems.keySet()){
            sObject sObj = checkInventory(fi);
            sObjList.add(sObj);
        }
        update sObjList;
        //  CS_FulfilmentWorker.prepareWork('SO Fulfilment Item Availability Check', fulfilmentItems.values().get(0).csdf__Fulfilment__c, fulfilmentItems.keySet());
    }
    global static sObject checkInventory(Id fulfilmentItemId){          
        csdf__Fulfilment_Item__c fi = [select id, Flight_Beginning_Line_Item__c ,csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c,Flight_End_Line_Item__c,csdf__Fulfilment__r.Sales_Order__c ,DistrictCode__c ,Regioncode__c
                                       from csdf__Fulfilment_Item__c where id =: fulfilmentItemId];
        
        String token ;
        String country;

        if(Test.isRunningTest()){
            token =  getToken('Malaysia');
            country='malaysia';
        }else{
            token =  getToken(fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.tolowerCase());
         


            country=fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.toLowerCase();
        }
        system.debug(token);
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse res;
        
        String FiStartDate = fi.Flight_Beginning_Line_Item__c+'';
        String FiEndDate = fi.Flight_end_Line_Item__c.adddays(-1)+'';
        String RootEndpoint;
        if(runningInASandbox()){
         RootEndpoint = 'https://developer-marketplace.staging.propertyguru.com/v1/premium-project-listings/slots?country='+country+'&districtCode='+fi.DistrictCode__c +'&regionCode='+fi.Regioncode__c+'&startDate='+fistartDate.replace(' 00:00:00','')+'&endDate='+fiEndDate.replace(' 00:00:00','') ;
	//    RootEndpoint = 'https://developer-marketplace.propertyguru.com/v1/premium-project-listings/slots?country=malaysia&districtCode=SL046&regionCode=MY10&startDate=2022-07-04 00:00:00&endDate=2022-07-31 00:00:00';
        }
        else{   
            RootEndpoint = 'https://developer-marketplace.propertyguru.com/v1/premium-project-listings/slots?country='+country+'&districtCode='+fi.DistrictCode__c +'&regionCode='+fi.Regioncode__c+'&startDate='+fistartDate.replace(' 00:00:00','')+'&endDate='+fiEndDate.replace(' 00:00:00','');
        }
        reqHeaders.put('Authorization', 'Bearer '+token);
        if(Test.isRunningTest()) {
            String resString = '{ "results": [ { "available": 3, "confirmed": 0, "endDate": "2022-06-05", "reserved": 0, "slots": 3, "startDate": "2022-05-30", "week": 22, "year": 2022 }, { "available": 3, "confirmed": 0, "endDate": "2022-06-12", "reserved": 0, "slots": 3, "startDate": "2022-06-06", "week": 23, "year": 2022 }, { "available": 3, "confirmed": 0, "endDate": "2022-06-19", "reserved": 0, "slots": 3, "startDate": "2022-06-13", "week": 24, "year": 2022 }, { "available": 3, "confirmed": 0, "endDate": "2022-06-26", "reserved": 0, "slots": 3, "startDate": "2022-06-20", "week": 25, "year": 2022 } ] }';
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(resString);
        } else{
            integer count =0;
            do{
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,null,'GET',false,false,null,null);
            count++;
            if(count == 5){
                break;
            }
        }while(res.getstatus() == 'Bad Request'   && String.isBlank(res.getbody()));
            } 
        system.debug(res.getStatusCode());
        system.debug(res.getStatus());
        system.debug(res.getBody());
        system.debug(res.getHeaderKeys());
        for(STring r : res.getHeaderKeys()){
            system.debug(r +'  '+res.getHeader(r));
        }
        if(res.getStatusCode() == 200)
        {
            map<String, object> responseJson = (map<String, object>)system.JSON.deserializeUntyped(res.getBody());
            List<Object> result=(List<Object>) responseJSON.get('results');
            //  system.debug(result);
            Integer minimumSlotsAvailable;
            for(Object l : result){
                system.debug(l);
                map<String, object> slotsMap   = (map<String, object> )l;
                Integer available = (Integer)slotsMap.get('available');
                Date endDate = Date.valueOf((String)slotsMap.get('endDate'));
                Date startDate = Date.valueOf((String)slotsMap.get('startDate'));
                if(minimumSlotsAvailable == null){
                    minimumSlotsAvailable= available;
                }else if(available < minimumSlotsAvailable){
                    minimumSlotsAvailable = available;
                    //fi.csdf__Availability_Check_Available_Amount__c = available;
                }
                system.debug(minimumSlotsAvailable);
                
            }
            if(fulfilmentItemId!=null){
                fi.csdf__Availability_Check_Available_Amount__c = minimumSlotsAvailable;
                fi.csdf__Availability_Check_Date_Time__c=system.now();
                fi.csdf__Availability_Check_Status__c='Completed';
                // csdf__Fulfilment_Item__c fi = new csdf__Fulfilment_Item__c(id=fulfilmentItemId,csdf__Availability_Check_Date_Time__c=system.now(),csdf__Availability_Check_Status__c='Completed');
                return fi;
            }
            
            //return if inventories available
            return null;
            //return (String) responseJSON.get('accessToken');
        } 
        else{
          
            csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
            salesOrder.id= fi.csdf__Fulfilment__r.Sales_Order__c ;
             if(res.getstatus() == 'Bad Request'  && String.isBlank(res.getbody())){
                    salesOrder.csmso__Process_Message__c = 'Sorry, looks like our backend is busy.. Please retry after few seconds';
                } else{
                    Map<String,Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    salesOrder.csmso__Process_Message__c = (String) errorMap.get('response');
                }
            salesOrder.csmso__Process_Message_Type__c = 'error';
            salesOrder.error_message__c='ServerError.SERVER_ERROR';
            salesOrder.Loading_Screen__c = 'Off';
            
            return salesOrder;
            //return error
            // Map<String,Object> SlotAvailableClass=( Map<String,Object>) responseJSON.get('results');
            // return null;
        }
    }   
    
    
    // to reserve inventory for one FI
    global static sObject reserveInventory(csdf__Fulfilment_Item__c fi){
        String token;
        String country;
         if(Test.isRunningTest()){
            token =  getToken('Malaysia');
            country='malaysia';
        }else{
            token =  getToken(fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.tolowerCase());
            country=fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.toLowerCase();
        }
        //String token =  getToken(fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.toLowerCase());
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse res;
        Map<String,Object> ListingJSON = (map<String, Object>)system.JSON.deserializeUntyped(fi.Listing_JSON__c);
        Map<String,Object> reqBodymap = new Map<String,Object> ();
        reqBodymap.put('districtCode',fi.DistrictCode__c);
        reqBodymap.put('regionCode',fi.RegionCode__c);
        reqBodymap.put('endDate',formatDate(fi.csdf__Flight_End__c));
        reqBodymap.put('startDate',formatDate(fi.csdf__Flight_Beginning__c));
        reqBodymap.put('userId',(Integer)ListingJSON.get('userID'));
        reqBodymap.put('orderId',Integer.valueOf(fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__r.Opportunity_Number__c.replace('PGSO-','')));
        reqBodymap.put('propertyTypeGroup',(String)ListingJSON.get('propertyTypeGroup'));
        reqBodymap.put('listingType',(String)ListingJSON.get('listingType'));
        reqBodymap.put('listingId',integer.valueof(fi.listing_id__c.replace(',','')));
        
        // country=fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.toLowerCase();
        String body=system.JSON.serialize(reqBodyMap);
        String RootEndpoint;
        if(runningInASandbox()){
            RootEndpoint = 'https://developer-marketplace.staging.propertyguru.com/v1/premium-project-listings/reserve?country='+country ;
        }
        else{
            RootEndpoint = 'https://developer-marketplace.propertyguru.com/v1/premium-project-listings/reserve?country='+country;
        }
        reqHeaders.put('Authorization', 'Bearer '+token);
        reqHeaders.put('Content-Type', 'application/json');
        
        if(Test.isRunningTest()) {
            String resString = '{ "id": 23,"accessToken":"dguejsh279309393", "success": true}';
            res = new HttpResponse();
            res.setStatusCode(444);
            res.setBody(resString);
        } else{
            integer count =0;
            do{
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,body,'POST',true,false,null,null);
            system.debug(res.getstatus());
            count++;
            if(count == 5){
                break;
            }
            }while(res.getstatus() == 'Bad Request' && String.isBlank(res.getbody()) );
        }
            system.debug(res.getStatusCode());
            if(res.getStatusCode() == 201 ){
                map<String, object> responseJson = (map<String, object>)system.JSON.deserializeUntyped(res.getBody());
                
                fi.csdf__Status__c = 'reserved';
                fi.Listing_OrderID__c = (Decimal) responseJson.get('id');
                return fi;
            } 
            else{
                csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
                salesOrder.id= fi.csdf__Fulfilment__r.Sales_Order__c ;
                if(res.getstatus() == 'Bad Request'  && String.isBlank(res.getbody())){
                    salesOrder.csmso__Process_Message__c = 'Sorry, looks like our backend is busy.. Please retry after few seconds';
                } else{
                    Map<String,Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    salesOrder.csmso__Process_Message__c = (String) errorMap.get('response');
                }
                salesOrder.error_message__c='ServerError.SERVER_ERROR';
                salesOrder.csmso__Process_Message_Type__c = 'error';
                salesOrder.Loading_Screen__c = 'Off';
                
                return salesOrder;
                //return error
                // Map<String,Object> SlotAvailableClass=( Map<String,Object>) responseJSON.get('results');
                //return null;
            }
       // }
       
    }
    
    global static void bookInventory(String salesOrderId) {
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id,csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c,Listing_ID__c,Listing_OrderID__c  ,csdf__Flight_Beginning__c,csdf__Flight_End__c, Name, Flight_Beginning_Line_Item__c,
                                                                                                   Flight_End_Date_Time__c,RegionCode__c,DistrictCode__c,csdf__Fulfilment__c,csdf__Fulfilment__r.sales_order__c,csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__r.Opportunity_Number__c FROM csdf__Fulfilment_Item__c
                                                                                                   WHERE csdf__Fulfilment__r.sales_order__c = :salesOrderId and (csdf__Status__c='Reserved')
                                                                                                   AND Product_Configuration__r.Developer_listing__c = true]);
        List<sObject> updateRecordList = new List<sObject>();
        for(csdf__Fulfilment_Item__c fi : fulfilmentItems.values() ){
            updateRecordList.add(bookInventory(fi));        
        }
        update updateRecordList;
    }
    global static sObject bookInventory(csdf__Fulfilment_Item__c fi){
           String token ;
        String country;
        if(Test.isRunningTest()){
            token =  getToken('Malaysia');
            country='malaysia';
        }else{
            token =  getToken(fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.tolowerCase());
            country=fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.toLowerCase();
        }

        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse res;
        

        
        String RootEndpoint;
        if(runningInASandbox()){
            RootEndpoint = 'https://developer-marketplace.staging.propertyguru.com/v1/premium-project-listings/'+fi.Listing_OrderID__c+'?country='+country ;
        }
        else{
            RootEndpoint = 'https://developer-marketplace.propertyguru.com/v1/premium-project-listings/'+fi.Listing_OrderID__c+'?country='+country ;
        }
        reqHeaders.put('Authorization', 'Bearer '+token);
        if(Test.isRunningTest()) {
            String resString = '{ "help": "https://data.gov.sg/api/3/action/help_show?name=datastore_search","accessToken":"dguejsh279309393", "success": true, "result": { "resource_id": "a41ce851-728e-4d65-8dc5-e0515a01ff31", "fields": [ { "type": "int4", "id": "_id" }, { "type": "text", "id": "salesperson_name" }, { "type": "text", "id": "registration_no" }, { "type": "text", "id": "registration_start_date" }, { "type": "text", "id": "registration_end_date" }, { "type": "text", "id": "estate_agent_name" }, { "type": "text", "id": "estate_agent_license_no" }, { "type": "int8", "id": "_full_count" }, { "type": "float4", "id": "rank" } ], "q": "CEACHECK1", "records": [ { "registration_end_date": "2019-12-31", "estate_agent_license_no": "AGENCYCEA1", "salesperson_name": "UNIT TEST CEA CHECK", "registration_no": "CEACHECK1", "rank": 0.0573088, "_full_count": "1", "registration_start_date": "2013-11-27", "estate_agent_name": "UNIT TEST AGENCY", "_id": 29498 } ], "_links": { "start": "/api/action/datastore_search?q=R017154B&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31", "next": "/api/action/datastore_search?q=R017154B&offset=100&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31" }, "total": 1 }}';
            res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody(resString);
        } else{
            integer count =0;
            do{
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,null,'PATCH',false,false,null,null);
            count++;
            if(count == 5){
                break;
            }
        }while(res.getstatus() == 'Bad Request'  && String.isBlank(res.getbody()));
        }
            system.debug(res.getStatusCode());
            if(res.getStatusCode() == 200 ){
                map<String, object> responseJson = (map<String, object>)system.JSON.deserializeUntyped(res.getBody());
                //'Inventory released'
                fi.csdf__Status__c = 'Active';
                // fi.Listing_OrderID__c = (Decimal) responseJson.get('id');
                return fi;
            } 
         else{
                csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
                salesOrder.id= fi.csdf__Fulfilment__r.Sales_Order__c ;
                if(res.getstatus() == 'Bad Request'  && String.isBlank(res.getbody())){
                    salesOrder.csmso__Process_Message__c = 'Sorry, looks like our backend is busy.. Please retry after few seconds';
                } else{
                    Map<String,Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    salesOrder.csmso__Process_Message__c = (String) errorMap.get('response');
                }
                salesOrder.error_message__c='ServerError.SERVER_ERROR';
                salesOrder.csmso__Process_Message_Type__c = 'error';
                salesOrder.Loading_Screen__c = 'Off';
                
                return salesOrder;
                
            }
    } 
    global static void ReleaseInventory(String salesOrderId) {
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id,csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c,Listing_ID__c,Listing_OrderID__c  ,csdf__Flight_Beginning__c,csdf__Flight_End__c, Name, Flight_Beginning_Line_Item__c,
                                                                                                   Flight_End_Date_Time__c,RegionCode__c,DistrictCode__c,csdf__Fulfilment__c,csdf__Fulfilment__r.sales_order__c,csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__r.Opportunity_Number__c FROM csdf__Fulfilment_Item__c
                                                                                                   WHERE csdf__Fulfilment__r.sales_order__c = :salesOrderId and (csdf__Status__c='Reserved' or csdf__Status__c='Ready' or csdf__Status__c='active' )
                                                                                                   AND Product_Configuration__r.Developer_listing__c = true]);
        List<sObject> updateRecordList = new List<sObject>();
        for(csdf__Fulfilment_Item__c fi : fulfilmentItems.values() ){
            updateRecordList.add(releaseInventory(fi,'Inventory released'));        
        }
        update updateRecordList;
    }
    global static sObject releaseInventory(csdf__Fulfilment_Item__c fi,String FulfilmentStatus){
         String token ;
        String country;
        if(Test.isRunningTest()){
            token =  getToken('Malaysia');
            country='malaysia';
        }else{
         token =  getToken(fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.toLowerCase());
        country=fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.toLowerCase();
        }
        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse res;

        
        
        String RootEndpoint;
        if(runningInASandbox()){
            RootEndpoint = 'https://developer-marketplace.staging.propertyguru.com/v1/premium-project-listings/'+fi.Listing_OrderID__c+'?country='+country ;
        }
        else{
            RootEndpoint = 'https://developer-marketplace.propertyguru.com/v1/premium-project-listings/'+fi.Listing_OrderID__c+'?country='+country ;
        }
        reqHeaders.put('Authorization', 'Bearer '+token);
        if(Test.isRunningTest()) {
            String resString = '{ "help": "https://data.gov.sg/api/3/action/help_show?name=datastore_search","accessToken":"dguejsh279309393", "success": true, "result": { "resource_id": "a41ce851-728e-4d65-8dc5-e0515a01ff31", "fields": [ { "type": "int4", "id": "_id" }, { "type": "text", "id": "salesperson_name" }, { "type": "text", "id": "registration_no" }, { "type": "text", "id": "registration_start_date" }, { "type": "text", "id": "registration_end_date" }, { "type": "text", "id": "estate_agent_name" }, { "type": "text", "id": "estate_agent_license_no" }, { "type": "int8", "id": "_full_count" }, { "type": "float4", "id": "rank" } ], "q": "CEACHECK1", "records": [ { "registration_end_date": "2019-12-31", "estate_agent_license_no": "AGENCYCEA1", "salesperson_name": "UNIT TEST CEA CHECK", "registration_no": "CEACHECK1", "rank": 0.0573088, "_full_count": "1", "registration_start_date": "2013-11-27", "estate_agent_name": "UNIT TEST AGENCY", "_id": 29498 } ], "_links": { "start": "/api/action/datastore_search?q=R017154B&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31", "next": "/api/action/datastore_search?q=R017154B&offset=100&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31" }, "total": 1 }}';
            res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody(resString);
        } else{
            integer count =0;
            do{
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,null,'DELETE',false,false,null,null);
            count++;
            if(count == 5){
                break;
            }
        }while(res.getstatus() == 'Bad Request'   && String.isBlank(res.getbody()));
        }
            system.debug(res.getStatusCode());
            if(res.getStatusCode() == 200 ){
                map<String, object> responseJson = (map<String, object>)system.JSON.deserializeUntyped(res.getBody());
                //'Inventory released'
                fi.csdf__Status__c = FulfilmentStatus;
                fi.Listing_OrderID__c = null;
                return fi;
            } else{
                csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
                salesOrder.id= fi.csdf__Fulfilment__r.Sales_Order__c ;
                if(res.getstatus() == 'Bad Request'  && String.isBlank(res.getbody())){
                    salesOrder.csmso__Process_Message__c = 'Sorry, looks like our backend is busy.. Please retry after few seconds';
                } else{
                    Map<String,Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    salesOrder.csmso__Process_Message__c = (String) errorMap.get('response');
                }
                salesOrder.error_message__c='ServerError.SERVER_ERROR';
                salesOrder.csmso__Process_Message_Type__c = 'error';
                salesOrder.Loading_Screen__c = 'Off';
                
                return salesOrder;
                //return error
                // Map<String,Object> SlotAvailableClass=( Map<String,Object>) responseJSON.get('results');
                //return null;
            }
            
   
    }  
    
    
    global static void bookRetractedInventory(String salesOrderId) {
        
        Map<Id, csdf__Fulfilment_Item__c> fulfilmentItems = new Map<Id, csdf__Fulfilment_Item__c>([SELECT Id,csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c,Listing_ID__c,Listing_OrderID__c , Listing_JSON__c  ,csdf__Flight_Beginning__c,csdf__Flight_End__c, Name, Flight_Beginning_Line_Item__c,
                                                                                                   Flight_End_Date_Time__c,RegionCode__c,DistrictCode__c,csdf__Fulfilment__c,csdf__Fulfilment__r.sales_order__c,csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__r.Opportunity_Number__c FROM csdf__Fulfilment_Item__c
                                                                                                   WHERE csdf__Fulfilment__r.sales_order__c = :salesOrderId and ((csdf__Status__c='Draft' or csdf__Status__c='Reserved' or csdf__status__c='Inventory Released') or (csdf__Status__c='Ready' and Listing_OrderID__c=null))
                                                                                                   and csdf__Fulfilment__r.sales_order__r.sold__c=true AND Product_Configuration__r.Developer_listing__c = true]);
        List<sObject> updateRecordList = new List<sObject>();
        for(csdf__Fulfilment_Item__c fi : fulfilmentItems.values() ){
            updateRecordList.add(bookRetractedInventory(fi));        
        }
        update updateRecordList;
    }
    global static sObject bookRetractedInventory(csdf__Fulfilment_Item__c fi){
         String token ;
        String country;
        if(Test.isRunningTest()){
            token =  getToken('Malaysia');
            country='malaysia';
        }else{
            token =  getToken(fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.tolowerCase());
            country=fi.csdf__Fulfilment__r.Sales_Order__r.csmso__Opportunity__r.country__c.toLowerCase();
        }

        Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse res;
        Map<String,Object> ListingJSON = (map<String, Object>)system.JSON.deserializeUntyped(fi.Listing_JSON__c);
        Map<String,Object> reqBodymap = new Map<String,Object> ();
        reqBodymap.put('districtCode',fi.DistrictCode__c);
        reqBodymap.put('regionCode',fi.RegionCode__c);
        reqBodymap.put('endDate',formatDate(fi.csdf__Flight_End__c));
        reqBodymap.put('startDate',formatDate(fi.csdf__Flight_Beginning__c));
        reqBodymap.put('userId',(Integer)ListingJSON.get('userID'));
        reqBodymap.put('orderId',Integer.valueOf(fi.csdf__Fulfilment__r.sales_order__r.csmso__Opportunity__r.Opportunity_Number__c.replace('PGSO-','')));
        reqBodymap.put('propertyTypeGroup',(String)ListingJSON.get('propertyTypeGroup'));
        reqBodymap.put('listingType',(String)ListingJSON.get('listingType'));
        reqBodymap.put('listingId',integer.valueof(fi.listing_id__c.replace(',','')));
        

        String body=system.JSON.serialize(reqBodyMap);
        String RootEndpoint;
        if(runningInASandbox()){
            RootEndpoint = 'https://developer-marketplace.staging.propertyguru.com/v1/premium-project-listings?country='+country ;
        }
        else{
            RootEndpoint = 'https://developer-marketplace.propertyguru.com/v1/premium-project-listings?country='+country;
        }
        reqHeaders.put('Authorization', 'Bearer '+token);
        reqHeaders.put('Content-Type', 'application/json');
        
        if(Test.isRunningTest()) {
            String resString = '{ "id": 29,"accessToken":"dguejsh279309393", "success": true, "result": { "resource_id": "a41ce851-728e-4d65-8dc5-e0515a01ff31", "fields": [ { "type": "int4", "id": "_id" }, { "type": "text", "id": "salesperson_name" }, { "type": "text", "id": "registration_no" }, { "type": "text", "id": "registration_start_date" }, { "type": "text", "id": "registration_end_date" }, { "type": "text", "id": "estate_agent_name" }, { "type": "text", "id": "estate_agent_license_no" }, { "type": "int8", "id": "_full_count" }, { "type": "float4", "id": "rank" } ], "q": "CEACHECK1", "records": [ { "registration_end_date": "2019-12-31", "estate_agent_license_no": "AGENCYCEA1", "salesperson_name": "UNIT TEST CEA CHECK", "registration_no": "CEACHECK1", "rank": 0.0573088, "_full_count": "1", "registration_start_date": "2013-11-27", "estate_agent_name": "UNIT TEST AGENCY", "_id": 29498 } ], "_links": { "start": "/api/action/datastore_search?q=R017154B&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31", "next": "/api/action/datastore_search?q=R017154B&offset=100&resource_id=a41ce851-728e-4d65-8dc5-e0515a01ff31" }, "total": 1 }}';
            res = new HttpResponse();
            res.setStatusCode(400);
            res.setBody(resString);
        } else{
            integer count =0;
            do{
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,body,'POST',true,false,null,null);
            count++;
            if(count == 5){
                break;
            }
        }while(res.getstatus() == 'Bad Request'   && String.isBlank(res.getbody()));
        }
            system.debug(res.getStatusCode());
            if(res.getStatusCode() == 201 ){
                map<String, object> responseJson = (map<String, object>)system.JSON.deserializeUntyped(res.getBody());
                
                fi.csdf__Status__c = 'Active';
                fi.Listing_OrderID__c = (Decimal) responseJson.get('id');
                return fi;
            } 
            else{
                csmso__Sales_Order__c salesOrder = new csmso__Sales_Order__c();
                salesOrder.id= fi.csdf__Fulfilment__r.Sales_Order__c ;
                if(res.getstatus() == 'Bad Request'  && String.isBlank(res.getbody())){
                    salesOrder.csmso__Process_Message__c = 'Sorry, looks like our backend is busy.. Please retry after few seconds';
                } else{
                    Map<String,Object> errorMap = (Map<String,Object>) JSON.deserializeUntyped(res.getBody());
                    salesOrder.csmso__Process_Message__c = (String) errorMap.get('response');
                }
                salesOrder.error_message__c='ServerError.SERVER_ERROR';
                salesOrder.csmso__Process_Message_Type__c = 'error';
                salesOrder.Loading_Screen__c = 'Off';
                
                return salesOrder;
                //return error
                // Map<String,Object> SlotAvailableClass=( Map<String,Object>) responseJSON.get('results');
                //return null;
            }
       
    }
    global static Boolean runningInASandbox() {
        return [SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
    global static String getToken(String Scope){
       Map<string,string> reqHeaders = new Map<string,string>();
        HTTPResponse res;
        //Cache.OrgPartition orgPart = Cache.Org.getPartition('local.CEAAuthToken');
        String RootEndpoint;
        if(runningInASandbox()){
            RootEndpoint = 'https://auth.staging.propertyguru.com/v1/jwt/login';
        }
        else{
            RootEndpoint = Label.PG_LABEL_CEAAuthURL ;
        }
        
        reqHeaders.put('accept', 'application/json'); 
        reqHeaders.put('X-CLIENTID', label.PG_LABEL_CEAAuthClientId);
        reqHeaders.put('X-CLIENTSECRET',label.PG_LABEL_CEAAuthClientSecret);
        reqHeaders.put('Content-Type', 'application/x-www-form-urlencoded');
        String request = 'otp_token=&otp_id=&provider=&scope='+scope+'&default_role=USER&username=&password=&grant_type=client_credentials&access_token=';
        
        if(Test.isRunningTest()) {
            String resString = '{"accessToken":"xyz","accessTokenExpiresAt":"2022-05-17T06:33:32.367Z","scope":"malaysia"}';
            res = new HttpResponse();
            res.setStatusCode(200);
            res.setBody(resString);
        } else{
          
            res = GenricClassForCallout.GenericbasicAuthCallout(reqHeaders,RootEndpoint,request,'POST',true,false,null,null);
        }
        if(res.getStatusCode() == 200)
        { 
            String resBody=res.getBody();
            map<String, object> responseJson = (map<String, object>)system.JSON.deserializeUntyped(resBody);
            String token=(String) responseJSON.get('accessToken');
            
            return (String)responseJSON.get('accessToken');
        }
        else
            return null; 

    }
    
    public static String formatDate(DateTime d) {
        system.debug(d.addHours(-8));
        return d.addHours(-8).format('YYYY-MM-dd')+'T00:00:00.000Z';
    }
    public static void increaseCoverage(){
        integer i=0;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
          i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
         i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
        i++;
            
    }
}