/*
* TestClass : GetRequestForPGCampaigns_Test
*/
@RestResource(urlMapping='/api/renewalsscampaign/*')
global class SSCampaignsGETAPI {
    
    @HttpGet
    global static void getDetails(){
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
        List<Campaign> camp = [select id,LastModifiedDate,Createddate,IsActive ,(select id from Campaign_Eligibilities__r) from Campaign where id =: CampaignId];
        if(camp.size() == 0){
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('status', 'failure');
            gen.writeStringField('message', 'Campaign does not exist.');
            gen.writeEndObject();
            
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return;
        } else {
            List<Promo_mechanic__c> pmList = [Select id, From_Product_Code__c , Renewal_Type__c , To_Product_Code__c, 
                                              (Select id, Discounted_amt__c, Start_Date__c, End_date__c, Duration__c,
                                               Duration_term__c, Discount__c,Product_Sku__c,Quantity__c  
                                               from Entitlement_Product__r)
                                              from Promo_Mechanic__c 
                                              where Campaign_eligibility__c in: camp[0].Campaign_Eligibilities__r ];
            JSONGenerator gen = JSON.createGenerator(true);
            gen.writeStartObject();
            gen.writeStringField('id', camp[0].id);
            // gen.writeStringField('CampaignId', camp[0].id);
            gen.writeFieldName('PromoMechanic');
            gen.writeStartArray();
            for(Promo_Mechanic__c pm : pmList){
                gen.writeStartObject();
                gen.writeStringField('id', pm.id);
                if(pm.From_Product_Code__c != null)
                    gen.writeStringField('fromProductCode', pm.From_Product_Code__c );
                if(pm.To_Product_Code__c != null)
                    gen.writeStringField('toProductCode', pm.To_Product_Code__c );
                if(pm.Renewal_Type__c != null){
                    if(pm.Renewal_Type__c =='renew')
                        gen.writeStringField('incentiveType','renewal');
                    else
                gen.writeStringField('incentiveType',pm.Renewal_Type__c );
                }
                gen.writeFieldName('EntitlementPromo');
                gen.writeStartArray();
                for(Entitlement_Promotion__c ep : pm.Entitlement_Product__r){
                    gen.writeStartObject();
                    gen.writeStringField('id',ep.id );
                    if(ep.Discount__c != null || ep.Discounted_amt__c !=null){
                        gen.writeStringField('incentiveType','Discount');
                        if(ep.Discount__c !=null){
                            gen.writeNumberField('DiscountPercent',ep.Discount__c );
                        }else {
                            gen.writeNumberField('DiscountAmount',ep.Discounted_amt__c );
                        }
                    } else if(ep.Product_Sku__c != null){
gen.writeStringField('validity','3 months');
                        gen.writeStringField('Product',ep.Product_Sku__c);
                        gen.writeNumberField('quantity',ep.Quantity__c );  
                    }
                    if(ep.Start_Date__c != null)
                        gen.writeStringField('StartDate',String.ValueOf(ep.Start_Date__c));
                    if(ep.End_Date__c != null)
                        gen.writeStringField('EndDate',String.ValueOf(ep.End_Date__c));
                    if(ep.Duration__c != null)
                        gen.writeNumberField('Duration',ep.Duration__c );
                    if(ep.Duration_Term__c != null)
                        gen.writeStringField('DurationTerm',ep.Duration_Term__c );
                    
                    gen.writeEndObject();
                }
                gen.writeEndArray();
                
                gen.writeEndObject();
            }
            
            //  
            gen.writeEndArray();
            gen.writeBooleanField('active',camp[0].IsActive);
            
            gen.writeStringField('createdDate',String.ValueOf(camp[0].CreatedDate));
            gen.writeStringField('modified',String.ValueOf(camp[0].LastModifiedDate));
            gen.writeEndObject();
            res.statusCode = 200;
            res.responseBody =Blob.valueOf(gen.getAsString());
            return;
        }
        
    }
}