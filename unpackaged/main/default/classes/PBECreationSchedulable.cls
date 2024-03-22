global class PBECreationSchedulable implements Schedulable {

    global void execute(SchedulableContext ctx) {
    
        Set<Id> ProdIds = new Set<Id>();
        Set<PriceBookEntry> StanPBECreated15MinsIds = new Set<PriceBookEntry>();
        Map<Id,Boolean> MapProdIdStatus = new Map<Id,Boolean>();
        
        List<PriceBookEntry> PBEUpdated15mins = [SELECT Id,Pricebook2Id,Product2Id,Product2.IsActive,IsActive,CurrencyISOCode,Pricebook2.IsStandard,UnitPrice FROM PricebookEntry where Pricebook2.IsStandard = TRUE AND (CreatedDate >:Datetime.now().addMinutes(-15) OR LastModifiedDate >:Datetime.now().addMinutes(-15))];
        if(PBEUpdated15mins!=null && PBEUpdated15mins.size()>0){
            for(PriceBookEntry pbe:PBEUpdated15mins){
                StanPBECreated15MinsIds.add(pbe);
                ProdIds.add(pbe.Product2Id);
                MapProdIdStatus.put(pbe.Product2Id,pbe.Product2.IsActive);
            }
        }
           
        System.debug('StanPBECreated15MinsIds list size---->'+StanPBECreated15MinsIds.size());
        
        List<Product2> ProdUpdated15mins = new List<Product2>();        
        if(ProdIds!=null && ProdIds.size()>0){
            ProdUpdated15mins = [SELECT Id,Subsidiary__c,(SELECT Id,Pricebook2Id,Product2Id,IsActive,CurrencyISOCode,Pricebook2.IsStandard,UnitPrice FROM PricebookEntries) FROM Product2 where Id IN:ProdIds];
        }
        
        Map<Product2,Id> mapProdIdSubsId = new Map<Product2,Id>();

        if(ProdUpdated15mins!=null && ProdUpdated15mins.size()>0){
                                    
            for(Product2 prod:ProdUpdated15mins){
                if(prod.Subsidiary__c!=null){
                    mapProdIdSubsId.put(prod,prod.Subsidiary__c);
                }                       
            }
            
            Map<Id,Id> mapSubIdPBId = new Map<Id,Id>();
            Map<Id,Id> mapProdIdPBId = new Map<Id,Id>();
            //Map<Id,Decimal> MapProdIdPrice = new Map<Id,Decimal>();
            
            if(mapProdIdSubsId!=null && mapProdIdSubsId.size()>0 && mapProdIdSubsId.values() != null){
                List<Pricebook2> pbList = [SELECT Id,Name,Subsidiary__c,IsStandard,(select Id,product2Id,UnitPrice FROM PricebookEntries WHERE Product2Id IN: mapProdIdSubsId.keySet()) FROM PriceBook2 WHERE Subsidiary__c IN:mapProdIdSubsId.values()];
                if(pbList!=null && pbList.size()>0){
                    for(Pricebook2 pb:pbList){
                       if(pb.IsStandard == FALSE){
                           mapSubIdPBId.put(pb.Subsidiary__c,pb.Id);
                       }
                       /*else{
                           for(PricebookEntry pbe : pb.PricebookEntries){
                               MapProdIdPrice.put(pbe.product2Id,pbe.UnitPrice);
                           }
                       }*/
                    }
                }
            }
            
            List<PricebookEntry> pbesInsertList = new List<PricebookEntry>();            
            
            //insert pbes in custom pricebook ie., add prods to different pricebook
            if(mapProdIdSubsId!=null && mapProdIdSubsId.size()>0 && mapProdIdSubsId.keySet() != null){
                for(Product2 prod : mapProdIdSubsId.keySet()){
                    if(prod.PricebookEntries!=null && prod.PricebookEntries.size()>0){
                        Boolean PBEExists = FALSE;
                        
                        //insert
                       
                            for(PriceBookEntry modifiedPBE : StanPBECreated15MinsIds)
                            {  
                                System.debug('modifiedPBE pbe Id ----'+modifiedPBE.Id);                                                                                                                         
                                if(prod.id==modifiedPBE.Product2Id)
                                {
                                    Boolean PBEExistsForSubsidiary1 = FALSE;
                                    
                                    for(PriceBookEntry pbe: prod.PricebookEntries)
                                    {
                                        if(pbe.Pricebook2Id==mapSubIdPBId.get(prod.subsidiary__c) && 
                                           pbe.CurrencyIsoCode==modifiedPBE.CurrencyIsoCode )
                                        {
                                            PBEExistsForSubsidiary1=true;
                                            break;
                                        } 
                                    }
                                    
                                    if(PBEExistsForSubsidiary1==false)
                                    {
                                    System.debug('does not exists. so insert------'+modifiedPBE.Id); 
                                                                                                            
                                    PricebookEntry pbe = new PricebookEntry();
                                    pbe.Pricebook2Id = mapSubIdPBId.get(prod.subsidiary__c);
                                    //set custom pricebook status (active/inactive) based on product active status
                                    if(MapProdIdStatus!=null && MapProdIdStatus.size()>0 && MapProdIdStatus.ContainsKey(prod.Id) && MapProdIdStatus.get(prod.Id)!= null){
                                        pbe.IsActive = MapProdIdStatus.get(prod.Id);
                                    }
                                    else{
                                        pbe.IsActive = false;
                                    }
                                    pbe.Product2Id = prod.Id;
                                    pbe.UseStandardPrice = false;
                                    pbe.CurrencyISOCode = modifiedPBE.CurrencyISOCode;
                                    pbe.UnitPrice = modifiedPBE.UnitPrice;                                                      
                                                                           
                                    pbesInsertList.add(pbe);  
                                        }
                                }                            
                                
                            }   
                        
                    }                    
                }
            }                        
        
            if(pbesInsertList!=null && pbesInsertList.size()>0){
                insert pbesInsertList;
                for(Pricebookentry pbeInserted:pbesInsertList){
                    pbeInserted.UseStandardPrice = true;
                }
                update pbesInsertList;
            }
        
        }
        
    }


}