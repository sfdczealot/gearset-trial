public without sharing class TriggerHelper{

    public static Map<String,Id> SubsidiaryNameIdMap(){
        
        Map<String,Id> SubsNameIdMap = new Map<String,Id>();
        
        List<Subsidiary__c> SubsList = [SELECT Id,Name FROM Subsidiary__c WHERE Id!=null];
        if(SubsList!=null && SubsList.size()>0){
            for(Subsidiary__c s:SubsList){
                SubsNameIdMap.put(s.Name,s.Id);
            }
        }
        
        return SubsNameIdMap;
        
    }    
    
    public static Map<Id,Id> SubsidiaryIdPricebookIdMap(){
    
        Map<Id,Id> SubsIdPBIdMap = new Map<Id,Id>();
    
        List<PriceBook2> CustomPBList = [SELECT Id, Subsidiary__c,IsStandard FROM PriceBook2 WHERE Subsidiary__c!=NULL AND IsStandard = FALSE];
        if(CustomPBList!=null && CustomPBList.size()>0){    
            for(PriceBook2 pb : CustomPBList){
                SubsIdPBIdMap.put(pb.Subsidiary__c,pb.Id);
            }
        }      
        
        return SubsIdPBIdMap;  
    
    }
    
    public static Map<Id,String> UserIdSubsIdMap(){
        
        Map<Id,String> OwnerSubsNameIdMap = new Map<Id,String>();
        
        List<User> UserList= [SELECT Id,Subsidiary__c FROM User WHERE isActive = TRUE];
        if(UserList!=null && UserList.size()>0){
            for(User u:UserList){
                OwnerSubsNameIdMap.put(u.Id,u.Subsidiary__c);
            }
        }
        
        return OwnerSubsNameIdMap;
        
    }

}