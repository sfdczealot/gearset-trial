public class CrossSellOpportunity_cc {
    @auraEnabled
    public static Map<String,String> getCrossSellValue(String recordId ){
        Map<String,String> returnMap = new Map<String,String>();
        Search_and_tag_admin__c sta = [select id , Client__c, ClientID__c , 
                                       Password__c, UserName__c, EndPoint__c    
                                       
                                       from Search_and_tag_admin__c   where Source_Object_API__c ='Opportunity' 
                                       and Active__c =true limit 1];
        Opportunity opp = [Select id,external_field__c,Total_Gross_Amount__c,CurrencyISOcode from opportunity where id=: recordId];
        if(opp.External_field__c != null){
            Map<String,String> res = SearchRecord_cc.getToken(sta);
            String token = res.get('token'); 
            String query = 'Select+Id,Amount+from+opportunity+where+id=\''+opp.External_field__c+'\'';
            String endpoint =res.get('URL')+ '/services/data/v50.0/query/?q='+query;
            
            List<Object> sobjectList =  SearchRecord_cc.getRecords(endpoint,'GET',token,'Get',null);
            for(object aa: sObjectList){
                MAP<STring,Object> f=(MAP<STring,Object>)(aa);
                system.debug(f.get('Amount'));
                Decimal total = (Decimal)f.get('Amount')+opp.Total_Gross_Amount__c;
                returnMap.put('amount',total.setScale(2,System.RoundingMode.HALF_UP)+'');
                returnMap.put('CurrencyISOCode',opp.CurrencyISOCOde);
                returnMap.put('redirectURL',res.get('URL')+'/'+opp.External_field__c);
                return returnMap;
            }
            
        }
        return null;
    }
}