/*
* TestClass : GetRequestForPGCampaigns_Test
*/
@RestResource(urlMapping='/api/pgcampaign/*')
global class GetRequestForPGCampaigns {
    
    @HttpGet
    global static void getCampaignAndRelatedDetails(){
        
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String CampaignId = req.requestURI.substring(req.requestURI.lastIndexOf('/')+1);
        
        system.debug('CampaignId>>> '+CampaignId);
        Campaign cam;
        
        if(CampaignId == null || CampaignId == ''){
            
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status', 'failure');
            gen.writeStringField('message', 'CampaignId is Empty.');
            gen.writeEndObject();
            String jsonData = gen.getAsString();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return;
            
            
        }
        Map<String,CamMemberStatusValue__c> mapOfRecordTypeIdVsValue = CamMemberStatusValue__c.getAll();
        List<Campaign> campList =  [SELECT Id,  RecordTypeId,Coupon_code__c,All_Agents__c,PG_Campaign_Id__c,Name,Campaign_Start_DateTime__c,Campaign_End_DateTime__c,IsActive,Country__c,Type,ParentId, Terms_and_conditions__c,Theme__c FROM Campaign where Id = : CampaignId ];
        if(campList.isEmpty()){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status', 'failure');
            gen.writeStringField('message', 'Campaign does not exist');
            gen.writeEndObject();
            String jsonData = gen.getAsString();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return;
        }
        
        cam = campList[0];
        list<Campaign_Eligibility__c> ceList = [Select id,Campaign__c,Name,Status__c,Criteria_Type__c,Rule_Name_Extension__c,Run_Frequency__c,Next_Run_scheduled__c from Campaign_Eligibility__c where Campaign__c =:cam.Id limit 1];
        Campaign_Eligibility__c CE;
        if(ceList != null && !ceList.isEmpty()){
            CE = ceList[0];
        }
        List<String> CMStatus = new List<String>();
        if(mapOfRecordTypeIdVsValue.containsKey(cam.RecordTypeId)){
            if(String.isNotBlank(mapOfRecordTypeIdVsValue.get(cam.RecordTypeId).Values__c)){
                CMStatus = mapOfRecordTypeIdVsValue.get(cam.RecordTypeId).Values__c.split(',');
            }
        }
        //list<Campaign_Eligibility__c> ceList = [Select id,Campaign__c,Campaign__r.Coupon_code__c,Campaign__r.All_Agents__c,Campaign__r.PG_Campaign_Id__c,Campaign_Eligibility__r.Campaign__r.Name,Campaign_Eligibility__r.Campaign__r.StartDate,Campaign__r.EndDate,Campaign__r.IsActive,Campaign__r.Country__c,Campaign__r.Type,Campaign__r.ParentId from Campaign_Eligibility__c limit 1]
        
        
        List<Promo_Mechanic__c> promoMechanicList = new List<Promo_Mechanic__c>() ;
        if(CampaignId != null){
            promoMechanicList = [select Id, Name,Status__c,Min_Qty__c,Max_Qty__c,Denomination__c,Usage__c,Renewal_Type__c,Discount_Reason__c,Opportunity_Type__c,Start_Date__c,Eligible_Product__c,Eligible_Product__r.Name,Eligible_Product__r.NetSuite_Id__c,
                                 eCommerceCatalogueProductReference__c,Discount_Limit_Type__c,Minimum_Spend__c,eCommerceCatalogueProductReference__r.cspmb__Price_Item_Code__c ,eCommerceCatalogueProductReference__r.Name,eCommerceCatalogueProductReference__r.sku__c, eCommerceCatalogueProductReference__r.currencyIsoCode,eCommerceCatalogueProductReference__r.Offering_Type__c,Campaign_Eligibility__c,Campaign_Eligibility__r.Id,Campaign_Eligibility__r.Name,Campaign_Eligibility__r.Status__c,Campaign_Eligibility__r.Criteria_Type__c,Campaign_Eligibility__r.Rule_Name_Extension__c,Campaign_Eligibility__r.Run_Frequency__c,Campaign_Eligibility__r.Next_Run_scheduled__c,
                                 Campaign_Eligibility__r.Campaign__c,Campaign_Eligibility__r.Campaign__r.Coupon_code__c,Campaign_Eligibility__r.Campaign__r.All_Agents__c,Campaign_Eligibility__r.Campaign__r.PG_Campaign_Id__c,Campaign_Eligibility__r.Campaign__r.Name,Campaign_Eligibility__r.Campaign__r.Campaign_Start_DateTime__c,Campaign_Eligibility__r.Campaign__r.Campaign_End_DateTime__c,Campaign_Eligibility__r.Campaign__r.IsActive,Campaign_Eligibility__r.Campaign__r.Country__c,Campaign_Eligibility__r.Campaign__r.Type,Campaign_Eligibility__r.Campaign__r.ParentId,
                                 (select id, name,Discount__c,Discounted_amt__c,Discount_Cap__c, Quantity__c,Entitlement_Product__c,Entitlement_Product__r.Name,Entitlement_Product__r.NetSuite_Id__c  from Entitlement_Product__r)
                                 from Promo_Mechanic__c where Campaign_Eligibility__r.Campaign__c = : CampaignId];
        }
        
        Map<String,String> mapOfStatusVsValue = new Map<String,String>();
        if(CMStatus.size()>0){
            for(AggregateResult cmp : [SELECT Status, COUNT(Id) From CampaignMember where CampaignId = : CampaignId and Status IN : CMStatus GROUP BY Status]){
                
                mapOfStatusVsValue.put(String.valueOf(cmp.get('Status')),String.valueOf(cmp.get('expr0')));
                
            }
        }
        system.debug('mapOfStatusVsValue>>> '+mapOfStatusVsValue);
        JSONGenerator gen = JSON.createGenerator(true);
        gen.writeStartObject();
        gen.writeStringField('campaignId', cam.Id);
        
        if(String.isNotBlank(cam.Name))
            gen.writeStringField('name', cam.Name);
        else
            gen.writeStringField('name', '');
        
        if(cam.Campaign_Start_DateTime__c != null)
            gen.writeStringField('startDate', String.valueOf(cam.Campaign_Start_DateTime__c));
        else
            gen.writeStringField('startDate', '');
        
        if(cam.Campaign_End_DateTime__c != null)
            gen.writeStringField('endDate', String.valueOf(cam.Campaign_End_DateTime__c.addSeconds(59)));
        else
            gen.writeStringField('endDate', '');
        
        gen.writeBooleanField('isActive', cam.IsActive);
        
        if(String.isNotBlank(cam.Country__c))
            gen.writeStringField('country', cam.Country__c);
        else
            gen.writeStringField('country', '');
        
        if(String.isNotBlank(cam.Type))
            gen.writeStringField('type', cam.Type);
        else
            gen.writeStringField('type', '');
        
        
        gen.writeBooleanField('allAgents',cam.All_Agents__c);
        if(String.isNotBlank(cam.Coupon_code__c))
            gen.writeStringField('couponCode', cam.Coupon_code__c);
        else
            gen.writeStringField('couponCode', '');
        
        if(String.isNotBlank(cam.PG_Campaign_Id__c))
            gen.writeStringField('pgCampaignId', cam.PG_Campaign_Id__c);
        else
            gen.writeStringField('pgCampaignId', '');
        
        if(String.isNotBlank(cam.Terms_and_conditions__c))
            gen.writeStringField('terms', cam.Terms_and_conditions__c);
        else
            gen.writeStringField('terms', '');
        if(String.isNotBlank(cam.Theme__c))
            gen.writeStringField('theme', cam.Theme__c);
        else
            gen.writeStringField('theme', '');
        
        gen.writeFieldName('campaignMember');
        gen.writeStartArray();
        for(String key : mapOfStatusVsValue.keyset()){
            gen.writeStartObject();
            gen.writeStringField('status', key);
            gen.writeNumberField('count', Integer.valueOf(mapOfStatusVsValue.get(key)));
            gen.writeEndObject();
        }
        gen.writeEndArray();
        if(CE != null){
            gen.writeFieldName('campaignEligibility');
            gen.writeStartObject();
            gen.writeStringField('id', CE.Id);
            
            if(String.isNotBlank(CE.Name))
                gen.writeStringField('name', CE.Name);
            else
                gen.writeStringField('name', '');  
            
            if(String.isNotBlank(CE.Status__c))
                gen.writeStringField('status', CE.Status__c);
            else
                gen.writeStringField('status', '');
            
            if(String.isNotBlank(CE.Criteria_Type__c))
                gen.writeStringField('criteriaType', CE.Criteria_Type__c);
            else
                gen.writeStringField('criteriaType', '');   
            
            //  String ruleName = pm.Campaign_Eligibility__r.Rule_Name_Extension__c;
            if(String.isNotBlank(CE.Rule_Name_Extension__c))
                gen.writeStringField('ruleName', CE.Rule_Name_Extension__c);
            else
                gen.writeStringField('ruleName', '');
            
            if(String.isNotBlank(CE.Run_Frequency__c))
                gen.writeStringField('runFrequency', CE.Run_Frequency__c);
            else
                gen.writeStringField('runFrequency', ''); 
            
            if(CE.Next_Run_scheduled__c != null)
                gen.writeStringField('nextRun', String.valueOf(CE.Next_Run_scheduled__c));
            else
                gen.writeStringField('nextRun', '');
            if(promoMechanicList.size()>0){
                gen.writeFieldName('promoMechanic');
                gen.writeStartArray();
                for(Promo_Mechanic__c pm : promoMechanicList){
                    
                    gen.writeStartObject();
                    gen.writeStringField('id', pm.Id);
                    
                    if(String.isNotBlank(pm.Name))
                        gen.writeStringField('name', pm.Name);
                    else
                        gen.writeStringField('name', ''); 
                    
                    if(String.isNotBlank(pm.Status__c))
                        gen.writeStringField('status', pm.Status__c);
                    else
                        gen.writeStringField('status', ''); 
                    
                    gen.writeFieldName('eligibleProduct');
                    gen.writeStartObject();
                    if(String.isNotBlank(pm.Eligible_Product__c))
                        gen.writeStringField('id', pm.Eligible_Product__c);
                    else
                        gen.writeStringField('id', ''); 
                    
                    if(String.isNotBlank(pm.Eligible_Product__r.Name))
                        gen.writeStringField('name', pm.Eligible_Product__r.Name);
                    else
                        gen.writeStringField('name', ''); 
                    
                    if(String.isNotBlank(pm.Eligible_Product__r.NetSuite_Id__c))
                        gen.writeStringField('netsuiteId', pm.Eligible_Product__r.NetSuite_Id__c);
                    else
                        gen.writeStringField('netsuiteId', ''); 
                    
                    gen.writeEndObject();
                    
                    if(pm.Min_Qty__c != null)
                        gen.writeNumberField('minQty', pm.Min_Qty__c);
                    else
                        gen.writeNumberField('minQty', 0); 
                    
                    if(pm.Max_Qty__c != null)
                        gen.writeNumberField('maxQty', pm.Max_Qty__c);
                    else
                        gen.writeNumberField('maxQty', 0); 
                    
                    if(pm.Denomination__c != null)
                        gen.writeNumberField('denomination', pm.Denomination__c);
                    else
                        gen.writeNumberField('denomination', 0); 
                    
                    if(pm.Minimum_Spend__c != null)
                        gen.writeNumberField('minSpend', pm.Minimum_Spend__c);
                    else
                        gen.writeNumberField('minSpend', 0); 
                    
                    if(pm.Discount_Limit_Type__c != null)
                        gen.writeStringField('discountLimitType', pm.Discount_Limit_Type__c);
                    else
                        gen.writeStringField('discountLimitType','');
                    if(pm.Usage__c != null)
                        gen.writeNumberField('usage', pm.Usage__c);
                    
                    if(String.isNotBlank(pm.Renewal_Type__c))
                        gen.writeStringField('renewalType', pm.Renewal_Type__c);
                    else
                        gen.writeStringField('renewalType', ''); 
                    
                    if(String.isNotBlank(pm.Discount_Reason__c))
                        gen.writeStringField('discountReason', pm.Discount_Reason__c);
                    else
                        gen.writeStringField('discountReason', ''); 
                    
                    if(String.isNotBlank(pm.Opportunity_Type__c))
                        gen.writeStringField('opportunityType', pm.Opportunity_Type__c);
                    else
                        gen.writeStringField('opportunityType', ''); 
                    
                    // gen.writeFieldName('eCommCatProductReference');
                    if(String.isNotBlank(pm.eCommerceCatalogueProductReference__c)){
                        gen.writeFieldName('eCommCatProductReference');
                        gen.writeStartObject();
                        
                        gen.writeStringField('id', pm.eCommerceCatalogueProductReference__c); 
                        gen.writeStringField('name', pm.eCommerceCatalogueProductReference__r.Name); 
                        gen.writeStringField('sku', pm.eCommerceCatalogueProductReference__r.SKU__c); 
                        gen.writeStringField('code', pm.eCommerceCatalogueProductReference__r.cspmb__Price_Item_Code__c ); 
                        gen.writeEndObject();
                    }
                    else
                        gen.writeStringField('eCommCatProductReference','');
                    gen.writeFieldName('entitlementPromotion');
                    gen.writeStartArray();
                    for(Entitlement_Promotion__c ep : pm.Entitlement_Product__r){
                        
                        gen.writeStartObject();
                        
                        if(String.isNotBlank(ep.Id))
                            gen.writeStringField('id', ep.Id);
                        else
                            gen.writeStringField('id', ''); 
                        
                        if(String.isNotBlank(ep.Name))
                            gen.writeStringField('name', ep.Name);
                        else
                            gen.writeStringField('name', ''); 
                        
                        gen.writeFieldName('entitlementProduct');
                        gen.writeStartObject();
                        if(String.isNotBlank(ep.Entitlement_Product__c))
                            gen.writeStringField('id', ep.Entitlement_Product__c);
                        else
                            gen.writeStringField('id', ''); 
                        
                        if(String.isNotBlank(ep.Entitlement_Product__r.Name))
                            gen.writeStringField('name', ep.Entitlement_Product__r.Name);
                        else
                            gen.writeStringField('name', ''); 
                        
                        if(String.isNotBlank(ep.Entitlement_Product__r.NetSuite_Id__c))
                            gen.writeStringField('netsuiteId', ep.Entitlement_Product__r.NetSuite_Id__c);
                        else
                            gen.writeStringField('netsuiteId', ''); 
                        
                        gen.writeEndObject();
                        
                        if(ep.Quantity__c != null)
                            gen.writeNumberField('quantity', ep.Quantity__c);
                        else
                            gen.writeNumberField('quantity', 0); 
                        
                        if(ep.Discount__c != null)
                            gen.writeNumberField('discountPercent', ep.Discount__c);
                        else
                            gen.writeNumberField('discountPercent', 0);
                        
                        if(ep.Discounted_amt__c != null)
                            gen.writeNumberField('discountAmount', ep.Discounted_amt__c);
                        else
                            gen.writeNumberField('discountAmount', 0);
                        
                        if(ep.Discount_Cap__c != null)
                            gen.writeNumberField('discountCap', ep.Discount_Cap__c);
                        else
                            gen.writeNumberField('discountCap', 0); 
                        gen.writeEndObject();
                        
                    }
                    gen.writeEndArray();
                    
                    gen.writeEndObject();
                    
                }
                gen.writeEndArray();
                gen.writeEndObject();
                gen.writeEndObject();
                
                
            }
        }else{
            JSONGenerator jsonGen = JSON.createGenerator(true);
            jsonGen.writeStartObject();
            jsonGen.writeStringField('status', 'failure');
            jsonGen.writeStringField('message', 'Promo Mechanic Info is Empty.');
            jsonGen.writeEndObject();
            String jsonData = jsonGen.getAsString();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return;
        }
        
        String jsonData = gen.getAsString();
        res.statusCode = 200;
        res.responseBody =Blob.valueOf(gen.getAsString());
        return;
        
    }
    
}