public class BatchToUpdateOLIProdCategory implements database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext BC)  {
        return Database.getQueryLocator('select id,name,Product_Category__c,Rate_card__c,Product_class__c,Product_subclass__c,Commercial_Product__c from opportunitylineitem where opportunity.recordtype.name=\'b2b\' and Product_Configuration__c!=null and (Product_Category__c=null or Product_class__c=null or Product_subclass__c=null) and( rate_card__c!= null or Commercial_Product__c!=null)');
    }
    public void execute(Database.BatchableContext BC, List<OpportunityLineItem > oliList) {
        Map<String,String> pickListLabel = getAPIValues();
        List<String> comProdList = new List<String>();
          List<String> RateCardList = new List<String>();
        for(OpportunityLineItem oli : oliList){
            if(oli.Commercial_Product__c != null)
            comProdList.add(oli.Commercial_Product__c);
             if(oli.Rate_Card__c != null)
            RateCardList.add(oli.Rate_Card__c);
        }
        map<String,cspmb__Price_Item__c> commprodMap = new map<String,cspmb__Price_Item__c>([select id,product_Class__c,
                                                                                             product_category__c,Product_subclass__c
                                                                                             from cspmb__Price_Item__c where 
                                                                                             id in: comProdList]);
        map<String,csmso__Rate_Card_Item_Price__c> RateCardMap = new map<String,csmso__Rate_Card_Item_Price__c>([select id,product_Class__c,
                                                                                             product_category__c,Product_subclass__c
                                                                                             from csmso__Rate_Card_Item_Price__c where 
                                                                                             id in: RateCardList]);
        for(OpportunityLineItem oli : oliList){
            if(oli.Commercial_Product__c != null){
            if(commprodMap.containskey(oli.Commercial_Product__c)){
                if(oli.Product_Category__c == null)
                    oli.Product_Category__c = commprodMap.get(oli.Commercial_Product__c).Product_Category__c;
                if(oli.Product_Class__c == null)
                    oli.Product_Class__c = commprodMap.get(oli.Commercial_Product__c).Product_Class__c;
                if(oli.product_subCLass__c == null){
                    system.debug('oli.product_subCLass__c '+oli.product_subCLass__c );
                                        system.debug('oli '+commprodMap.get(oli.Commercial_Product__c).Product_subclass__c );
                    if(pickListLabel.containsKey(commprodMap.get(oli.Commercial_Product__c).Product_subclass__c)){
                        oli.product_subCLass__c = pickListLabel.get(commprodMap.get(oli.Commercial_Product__c).Product_subclass__c);
                    }
                }
            }
            }
            else  if(oli.Rate_Card__c != null){
            if(RateCardMap.containskey(oli.Rate_Card__c)){
                if(oli.Product_Category__c == null)
                    oli.Product_Category__c = RateCardMap.get(oli.Rate_Card__c).Product_Category__c;
                if(oli.Product_Class__c == null)
                    oli.Product_Class__c = RateCardMap.get(oli.Rate_Card__c).Product_Class__c;
                if(oli.product_subCLass__c == null){
                    system.debug('oli.product_subCLass__c '+oli.product_subCLass__c );
                                        system.debug('oli '+RateCardMap.get(oli.Rate_Card__c).Product_subclass__c );
                    if(pickListLabel.containsKey(RateCardMap.get(oli.Rate_Card__c).Product_subclass__c)){
                        oli.product_subCLass__c = pickListLabel.get(RateCardMap.get(oli.Rate_Card__c).Product_subclass__c);
                    }
                }
            }
            }
            
        }         
        Database.update(oliList,false);
    }
    static map<String,String> getAPIValues(){
        
        Map<String,String>  myPicklist = new Map<String,String>();
        Schema.DescribeFieldResult field = cspmb__Price_Item__c.Product_Subclass__c.getDescribe();
        
        for (Schema.PicklistEntry f : field.getPicklistValues())
            myPicklist.put(f.getvalue(),f.getLabel());
        
        return myPicklist;
    }
    public void finish(Database.BatchableContext BC) {
        
    }
    
}