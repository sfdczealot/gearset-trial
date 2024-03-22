public class BatchToUpdateFullfilmentItems implements Database.Batchable<sObject>{
    public Database.QueryLocator start(Database.BatchableContext bc) {
        /*return Database.getQueryLocator(
            'Select id, name,Flight_Beginning_Line_Item__c,csdf__Flight_Beginning__c,Flight_End_Line_Item__c,csdf__Flight_End__c, csdf__Rate__c,Rate_Card_Item_Price__c,Product_Configuration__c from csdf__Fulfilment_Item__c where id = \'a3G9D0000008wv9\''
        );*/
        return Database.getQueryLocator(
            'Select id, name,Product_Configuration__r.name,Flight_Beginning_Line_Item__c,csdf__Flight_Beginning__c,Flight_End_Line_Item__c,csdf__Flight_End__c, csdf__Rate__c,Rate_Card_Item_Price__c,Product_Configuration__c from csdf__Fulfilment_Item__c where (Rate_Card_Item_Price__c = null or csdf__Rate__c = null or Flight_End_Line_Item__c = null or Flight_Beginning_Line_Item__c = null) and Served_By__c = \'Non-Ad Served\''
        );
    }
    public void execute(Database.BatchableContext bc, List<csdf__Fulfilment_Item__c> scope){
        set<Id> setOfProductConfiguration = new set<Id>();
        map<Id,Id> mapOfFulFilmentItemVsProdConfig = new map<Id,Id>();
        map<Id,cscfga__Attribute__c> mapOfIdVsAttribute = new map<Id,cscfga__Attribute__c>();
        list<csdf__Fulfilment_Item__c> listOfFulFilmentItemToUpdate = new list<csdf__Fulfilment_Item__c>();
        for (csdf__Fulfilment_Item__c fulFilItem : scope) {
            setOfProductConfiguration.add(fulFilItem.Product_Configuration__c);
            mapOfFulFilmentItemVsProdConfig.put(fulFilItem.Id,fulFilItem.Product_Configuration__c);
        }
        list<cscfga__Product_Configuration__c> listOfProdConfig = [Select id,(Select id,cscfga__Price__c,cscfga__List_Price__c from cscfga__Attributes__r where cscfga__Is_Line_Item__c = true LIMIT 1) from cscfga__Product_Configuration__c where id IN :setOfProductConfiguration];
        for(cscfga__Product_Configuration__c prodConfiguration : listOfProdConfig){
            mapOfIdVsAttribute.put(prodConfiguration.Id, prodConfiguration.cscfga__Attributes__r);
        }
        for (csdf__Fulfilment_Item__c fulFilItem : scope) {
            Id prodConfiguration = mapOfFulFilmentItemVsProdConfig.get(fulFilItem.Id);
            cscfga__Attribute__c attr = mapOfIdVsAttribute.get(prodConfiguration);
            if(fulFilItem.Rate_Card_Item_Price__c == null || fulFilItem.Rate_Card_Item_Price__c == 0){
                fulFilItem.Rate_Card_Item_Price__c = attr.cscfga__List_Price__c;
            }
            if(fulFilItem.csdf__Rate__c == null || fulFilItem.csdf__Rate__c == 0){
                fulFilItem.csdf__Rate__c = attr.cscfga__Price__c;
            }
            if(fulFilItem.Flight_Beginning_Line_Item__c == null){
                fulFilItem.Flight_Beginning_Line_Item__c = Date.ValueOf(fulFilItem.csdf__Flight_Beginning__c);
            }
            if(fulFilItem.Flight_End_Line_Item__c == null){
                fulFilItem.Flight_End_Line_Item__c = Date.ValueOf(fulFilItem.csdf__Flight_End__c);
            }
            listOfFulFilmentItemToUpdate.add(fulFilItem);
        }
        update listOfFulFilmentItemToUpdate;
    }
    public void finish(Database.BatchableContext bc){
    }
}