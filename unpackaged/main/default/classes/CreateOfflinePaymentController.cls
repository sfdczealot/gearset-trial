/*
* TestClass : CreateOfflinePaymentController_Test
*/
public without sharing class CreateOfflinePaymentController {
    
    public class userInfoOppRecordWrapper {
        @AuraEnabled public String userProfile;
        @AuraEnabled public Quote quo;
        @AuraEnabled public Opportunity opp;
        @AuraEnabled public Payment__c payment;
        
    }
    
    @AuraEnabled
    public static userInfoOppRecordWrapper getUserInfoAndOppRecord(string oppId) {
        userInfoOppRecordWrapper wrapper = new userInfoOppRecordWrapper(); 
        String profileId = userInfo.getProfileId();
        wrapper.userProfile = [select name from profile where id = :profileId].Name;
        Quote result = [select Id, Name, Country__c,Total_Gross_Amount__c,Total_WHT_Amount__c,Status,Pricebook2Id,CurrencyIsoCode,OpportunityId from Quote where Id=:oppId];
        Opportunity opp = [select Id, Name, Country__c,Is_Testing__c,Pricebook2Id,CurrencyIsoCode,CampaignId, Campaign.Name,StageName,Account.PersonContactId from Opportunity where Id=:result.OpportunityId];
        decimal amountPaid = 0;
        //get total paid amount
        for(Payment__c pay : [Select id,Amount2__c from Payment__c where Opportunity_Record__c =: result.OpportunityId]){
            if(pay.Amount2__c != null){
                amountPaid += pay.Amount2__c;
            }
        }
        Decimal Total_WHT_Amount = 0;
        if(result.Total_WHT_Amount__c!= null && result.Total_WHT_Amount__c>0){
            Total_WHT_Amount =result.Total_WHT_Amount__c;
        }
        
        Payment__c pay = new Payment__c();
        //pay.Amount2__c = (result.Total_Gross_Amount__c - amountPaid.setscale(2,system.RoundingMode.DOWN));//.setscale(2
        //pay.Amount2__c = result.Total_Gross_Amount__c - amountPaid - Total_WHT_Amount;//Prod
        pay.Amount2__c = (result.Total_Gross_Amount__c - amountPaid-Total_WHT_Amount).setscale(2);
        pay.Payment_Mode__c = 'Offline';
        pay.Opportunity_Record__c = opp.id;
        pay.Quote_Record__c = result.id;
        wrapper.quo = result;
        wrapper.opp = opp;
        wrapper.payment = pay;
        
        return wrapper;
    }
    @AuraEnabled
    public static String savePayment(Payment__c payment) {
        decimal value = 0;
        decimal amountPaid = 0;
        decimal WHT_Amount = 0;
        
        try{
            insert payment;
            Quote result = [select Id, Name,Total_Gross_Amount__c,OpportunityId,Country__c,Total_WHT_Amount__c,Allowed_Payment_Type__c from Quote where Id=:payment.Quote_Record__c];
            if(result.Allowed_Payment_Type__c =='Online only'){
                return 'Error: Cannot create offline payment when Allowed payment type is Online only.';
            }
            for(Payment__c pay : [Select id,Amount2__c from Payment__c where Opportunity_Record__c =: result.OpportunityId]){
                if(pay.Amount2__c != null){
                    amountPaid += pay.Amount2__c;
                }
            }
            if(result.Country__c == 'Thailand' && result.Total_WHT_Amount__c != null && result.Total_WHT_Amount__c>0){
               WHT_Amount = result.Total_WHT_Amount__c; 
            }
            value = (result.Total_Gross_Amount__c - amountPaid - WHT_Amount).setscale(2);
        }
        catch(exception exp){
            return 'Error: '+ exp.getMessage();   
        }
        return String.valueOf(value);
    }
    @AuraEnabled
    public static List<Payment_Method__c> getPaymentMethod(){
        
        return [SELECT Id, Name,NS_Internal_ID__c FROM Payment_Method__c];
    }
}