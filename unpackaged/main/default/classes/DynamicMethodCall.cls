// Test Class: DynamicMethodCall_Test
public class DynamicMethodCall implements Callable {

    // Actual method
    public String concatStrings(String stringValue) {
        return stringValue + stringValue;
    }

    // Actual method
    public Decimal multiplyNumbers(Decimal decimalValue) {
        return decimalValue * decimalValue;
    }

    // Dispatch actual methods
    public Object call(String action, Map<String, Object> args) {
        switch on action {
            when 'Winback' {
                return this.Winback();
            }
            when 'AMeligible' {
                return this.AMeligible();
            }
            when 'concatStrings' {
                return 'Success';
            }
            when 'multiplyNumbers' {
                return 'Success';
            }
            when 'JUNStdAM2020'{
                return this.JUNStdAM2020();
            }

            when 'JUNStdAM2020PG2'{
                return this.JUNStdAM2020PG2();
            }

            when 'januaryBirthdayStd'{
                return this.januaryBirthdayStd();
            }
            when 'januaryBirthdayAdvance'{
                return this.januaryBirthdayAdvance();
            }
            when 'januaryBirthdayBusPremium'{
                return this.januaryBirthdayBusPremium();
            }
            when 'februaryBirthdayStd'{
                return this.februaryBirthdayStd();
            }
            when 'februaryBirthdayAdvance'{
                return this.februaryBirthdayAdvance();
            }
            when 'februaryBirthdayBusPremium'{
                return this.februaryBirthdayBusPremium();
            }
            when 'marchBirthdayStd'{
                return this.marchBirthdayStd();
            }
            when 'marchBirthdayAdvance'{
                return this.marchBirthdayAdvance();
            }
            when 'marchBirthdayBusPremium'{
                return this.marchBirthdayBusPremium();
            }
            when 'aprilBirthdayStd'{
                return this.aprilBirthdayStd();
            }
            when 'aprilBirthdayAdvance'{
                return this.aprilBirthdayAdvance();
            }
            when 'aprilBirthdayBusPremium'{
                return this.aprilBirthdayBusPremium();
            }
            when 'mayBirthdayStd'{
                return this.mayBirthdayStd();
            }
            when 'mayBirthdayAdvance'{
                return this.mayBirthdayAdvance();
            }
            when 'mayBirthdayBusPremium'{
                return this.mayBirthdayBusPremium();
            }
            when 'juneBirthdayStd'{
                return this.juneBirthdayStd();
            }
            when 'juneBirthdayAdvance'{
                return this.juneBirthdayAdvance();
            }
            when 'juneBirthdayBusPremium'{
                return this.juneBirthdayBusPremium();
            }
            when 'julyBirthdayStd'{
                return this.julyBirthdayStd();
            }
            when 'julyBirthdayAdvance'{
                return this.julyBirthdayAdvance();
            }
            when 'julyBirthdayBusPremium'{
                return this.julyBirthdayBusPremium();
            }
            when 'AugustBirthdayStd'{
                return this.AugustBirthdayStd();
            }
            when 'AugustBirthdayAdvance'{
                return this.AugustBirthdayAdvance();
            }
            when 'AugustBirthdayBusPremium'{
                return this.AugustBirthdayBusPremium();
            }
            when 'septemberBirthdayStd'{
                return this.septemberBirthdayStd();
            }
            when 'septemberBirthdayAdvance'{
                return this.septemberBirthdayAdvance();
            }
            when 'septemberBirthdayBusPremium'{
                return this.septemberBirthdayBusPremium();
            }
            when 'octoberBirthdayStd'{
                return this.octoberBirthdayStd();
            }
            when 'octoberBirthdayAdvance'{
                return this.octoberBirthdayAdvance();
            }
            when 'octoberBirthdayBusPremium'{
                return this.octoberBirthdayBusPremium();
            }
            when 'novemberBirthdayStd'{
                return this.novemberBirthdayStd();
            }
            when 'novemberBirthdayAdvance'{
                return this.novemberBirthdayAdvance();
            }
            when 'novemberBirthdayBusPremium'{
                return this.novemberBirthdayBusPremium();
            }
            when 'decemberBirthdayStd'{
                return this.decemberBirthdayStd();
            }
            when 'decemberBirthdayAdvance'{
                return this.decemberBirthdayAdvance();
            }
            when 'decemberBirthdayBusPremium'{
                return this.decemberBirthdayBusPremium();
            }
            when 'jul2020Tnr1AM_1'{
                return this.jul2020Tnr1AM_1();
            }
            when 'jul2020Tnr2AM_1'{
                return this.jul2020Tnr2AM_1();
            }
            when 'jul2020Tnr3AM_1'{
                return this.jul2020Tnr3AM_1();
            }
            when 'jul2020Tnr4AM_1'{
                return this.jul2020Tnr4AM_1();
            }
            when 'jul2020Tnr5AM_1'{
                return this.jul2020Tnr5AM_1();
            }
            when 'jul2020Tnr6AM_1'{
                return this.jul2020Tnr6AM_1();
            }
            when 'jul2020Tnr1AM'{
                return this.jul2020Tnr1AM();
            }
            when 'jul2020Tnr2AM'{
                return this.jul2020Tnr2AM();
            }
            when 'jul2020Tnr3AM'{
                return this.jul2020Tnr3AM();
            }
            when 'jul2020Tnr4AM'{
                return this.jul2020Tnr4AM();
            }
            when 'jul2020Tnr5AM'{
                return this.jul2020Tnr5AM();
            }
            when 'jul2020Tnr6AM'{
                return this.jul2020Tnr6AM();
            }
            when 'aug2020Tnr1AM_1'{
                return this.aug2020Tnr1AM_1();
            }
            when 'aug2020Tnr2AM_1'{
                return this.aug2020Tnr2AM_1();
            }
            when 'aug2020Tnr3AM_1'{
                return this.aug2020Tnr3AM_1();
            }
            when 'aug2020Tnr4AM_1'{
                return this.aug2020Tnr4AM_1();
            }
            when 'aug2020Tnr5AM_1'{
                return this.aug2020Tnr5AM_1();
            }
            when 'aug2020Tnr6AM_1'{
                return this.aug2020Tnr6AM_1();
            }
            when 'aug2020Tnr1AM'{
                return this.aug2020Tnr1AM();
            }
            when 'aug2020Tnr2AM'{
                return this.aug2020Tnr2AM();
            }
            when 'aug2020Tnr3AM'{
                return this.aug2020Tnr3AM();
            }
            when 'aug2020Tnr4AM'{
                return this.aug2020Tnr4AM();
            }
            when 'aug2020Tnr5AM'{
                return this.aug2020Tnr5AM();
            }
            when 'aug2020Tnr6AM'{
                return this.aug2020Tnr6AM();
            }   when 'jun2020Tnr1AM_1'{
                return this.jun2020Tnr1AM_1();
            }
            when 'jun2020Tnr2AM_1'{
                return this.jun2020Tnr2AM_1();
            }
            when 'jun2020Tnr3AM_1'{
                return this.jun2020Tnr3AM_1();
            }
            when 'jun2020Tnr4AM_1'{
                return this.jun2020Tnr4AM_1();
            }
            when 'jun2020Tnr5AM_1'{
                return this.jun2020Tnr5AM_1();
            }
            when 'jun2020Tnr6AM_1'{
                return this.jun2020Tnr6AM_1();
            }
            when 'MYjul2020AM'{
                return this.MYjul2020AM();
            }
            when 'MYaug2020AM'{
                return this.MYaug2020AM();
            }
            when 'SG_Advance_Package_Promo'{
                return this.SG_Advance_Package_Promo();
            }
            when 'SG_Advance_Package_Promo_6'{
                return this.SG_Advance_Package_Promo_6();
            }

            when 'SG_Advance_Package_Promo_18'{
                return this.SG_Advance_Package_Promo_18();
            }
            when 'SG_Advance_Package_Promo_March21'{
                return this.SG_Advance_Package_Promo_March21();
            }
            when 'SG_NewExpiredAgentContacts12'{
                return this.fetchSGNewExpiredAgentContacts(12);
            }
            when 'SG_Advance_Package_Promo_14'{
                return this.SG_Advance_Package_Promo_14();
            }
            when 'SGMidTermUpgradeMarketingPromoTNR0'{
                return this.SGMidTermUpgradeMarketingPromoTNR0();
            }
            when 'SGMidTermUpgradeMarketingPromoTNR1'{
                return this.SGMidTermUpgradeMarketingPromoTNR1();
            }
            when 'SGMidTermUpgradeMarketingPromoTNR2'{
                return this.SGMidTermUpgradeMarketingPromoTNR2();
            }
            when 'SGMidTermUpgradeMarketingPromoTNR3'{
                return this.SGMidTermUpgradeMarketingPromoTNR3();
            }
            when 'SGMidTermUpgradeMarketingPromoTNR4'{
                return this.SGMidTermUpgradeMarketingPromoTNR4();
            }
            when 'SGMidTermUpgradeMarketingPromoTNR5'{
                return this.SGMidTermUpgradeMarketingPromoTNR5();
            }
            when 'SGMidTermUpgradeMarketingPromoTNR6'{
                return this.SGMidTermUpgradeMarketingPromoTNR6();
            }
            when 'minus13Months'{
                return this.minus13Months();
            }
            when 'THDecOffer2'{
                return this.THDecOffer2();
            }
            when 'fetchRiangRiaRayaSaleAprBaseAgents' {
                return this.fetchRiangRiaRayaSale(4);
            }
            when 'fetchRiangRiaRayaSaleMayBaseAgents' {
                return this.fetchRiangRiaRayaSale(5);
            }
            when 'fetchRiangRiaRayaSaleJuneBaseAgents' {
                return this.fetchRiangRiaRayaSale(6);
            }
            when 'fetchRiangRiaRayaSaleJulyBaseAgents' {
                return this.fetchRiangRiaRayaSale(7);
            }
            when 'fetchAgentsWithSpending1k' {
                return this.fetchAgentsWithSpending(1000);
            }
            when 'fetchMYAgentsForEBCamp' {
                return this.fetchRenewalMYOrTHAgents('EB','Malaysia');
            }
            when 'fetchMYAgentsForAMCamp' {
                return this.fetchRenewalMYOrTHAgents('AM','Malaysia');
            }
            when 'fetchMYAgentsForAM+1Camp' {
                return this.fetchRenewalMYOrTHAgents('AM+1','Malaysia');
            }
            when 'fetchMYAgentsForJuneEBCamp' {
                return this.fetchRenewalJuneMYOrTHAgents('EB','Malaysia');
            }
            when 'fetchMYAgentsForJuneAMCamp' {
                return this.fetchRenewalJuneMYOrTHAgents('AM','Malaysia');
            }
            when 'fetchMYAgentsForJuneAM+1Camp' {
                return this.fetchRenewalJuneMYOrTHAgents('AM+1','Malaysia');
            }
            when 'fetchRenewalMYEBCommercial' {
                return this.fetchRenewalMYCommercialAgents('EB','Malaysia');
            }
            when 'fetchRenewalMYAMCommercial' {
                return this.fetchRenewalMYCommercialAgents('AM','Malaysia');
            }
            when 'fetchRenewalMYAM+1Commercial' {
                return this.fetchRenewalMYCommercialAgents('AM+1','Malaysia');
            }
            when 'fetchTHAgentsForEBCamp' {
                return this.fetchRenewalMYOrTHAgents('EB','Thailand');
            }
            when 'fetchTHAgentsForAMCamp' {
                return this.fetchRenewalMYOrTHAgents('AM','Thailand');
            }
            when 'fetchTHAgentsForAM+1Camp' {
                return this.fetchRenewalMYOrTHAgents('AM+1','Thailand');
            }
            when 'fetchSGAgentsForTNR1Camp' {
                return this.fetchRenewalSGAgents(1);
            }
            when 'fetchSGAgentsForTNR2Camp' {
                return this.fetchRenewalSGAgents(2);
            }
            when 'fetchSGAgentsForTNR3Camp' {
                return this.fetchRenewalSGAgents(3);
            }
            when 'fetchSGAgentsForTNR4Camp' {
                return this.fetchRenewalSGAgents(4);
            }
            when 'fetchSGAgentsForTNR5Camp' {
                return this.fetchRenewalSGAgents(5);
            }
            when 'fetchSGAgentsForTNR6Camp' {
                return this.fetchRenewalSGAgents(6);
            }
            when 'anniversarySilverElite' {
                return this.fetchAnniversaryAgents(new Set<String>{'Silver', 'Elite'});
            }
            when 'anniversaryTitaniumPlatinumGold' {
                return this.fetchAnniversaryAgents(new Set<String>{'Titanium','Platinum', 'Gold'});
            }
            when 'anniversarySolitaire' {
                return this.fetchAnniversaryAgents(new Set<String>{'Solitaire'});
            }
            when 'mySeptSpecialistCampaign' {
                return this.mySeptSpecialistCampaign();
            }
            when 'SGMidTermUpgradeMarketingPromoTENURE0'{
                return this.SGMidTermUpgradeMarketingPromo(0);
            }
            when 'SGMidTermUpgradeMarketingPromoTENURE1'{
                return this.SGMidTermUpgradeMarketingPromo(1);
            }
            when 'SGMidTermUpgradeMarketingPromoTENURE2'{
                return this.SGMidTermUpgradeMarketingPromo(2);
            }
            when 'SGMidTermUpgradeMarketingPromoTENURE3'{
                return this.SGMidTermUpgradeMarketingPromo(3);
            }
            when 'SGMidTermUpgradeMarketingPromoTENURE4'{
                return this.SGMidTermUpgradeMarketingPromo(4);
            }
            when 'SGMidTermUpgradeMarketingPromoTENURE5'{
                return this.SGMidTermUpgradeMarketingPromo(5);
            }
            when 'SGMidTermUpgradeMarketingPromoTENURE6'{
                return this.SGMidTermUpgradeMarketingPromo(6);
            }
            when 'MYNewSignupPromotion'{
                return this.MYNewSignupPromotion();
            }
            when 'MYNewSignupPromotionTrial'{
                return this.MYNewSignupPromotionTrial();
            }
            when 'MYNewSignupPromotionTrialJuly'{
                return this.MYNewSignupPromotionTrialJuly();
            }
             when 'MYNewSignupiBasic'{
                return this.MYNewSignupiPP('iBasic Package');
            }
             when 'MYNewSignupiPlatinum'{
                return this.MYNewSignupiPP('iPlatinum Package');
            }
             when 'MYNewSignupiGold'{
                return this.MYNewSignupiPP('iGold Package');
            }
             when 'MYNewSignupiClassic'{
                return this.MYNewSignupiPP('iClassic Package');
            }
            when 'MYNewSignupOneMonthiBasic'{
                return this.MYNewSignupiPPOneMonth('iBasic Package');
            }
             when 'MYNewSignupOneMonthiPlatinum'{
                return this.MYNewSignupiPPOneMonth('iPlatinum Package');
            }
             when 'MYNewSignupOneMonthiGold'{
                return this.MYNewSignupiPPOneMonth('iGold Package');
            }
             when 'MYNewSignupOneMonthiPower'{
                return this.MYNewSignupiPPOneMonth('iPower Package');
            }
             when 'MYNewSignupOneMonthiClassic'{
                return this.MYNewSignupiPPOneMonth('iClassic Package');
            }
             when 'MYNewSignupOneMonthiStarter'{
                return this.MYNewSignupiPPOneMonth('iStarter Package');
            }
            when 'MYNewSignupOneMonthiBasicPlus'{
                return this.MYNewSignupiPPOneMonth('iBasic Plus Package');
            }
            when 'MYNewSignupOneMonthiGoldPlus'{
                return this.MYNewSignupiPPOneMonth('iGold Plus Package');
            }
            when 'MYNewSignupOneMonthiPlatinumPlus'{
                return this.MYNewSignupiPPOneMonth('iPlatinum Plus Package');
            }
            when 'MYNewSignupJulyMonthiBasic'{
                return this.MYNewSignupiPPJulyOneMonth('iBasic Package');
            }
             when 'MYNewSignupJulyMonthiPlatinum'{
                return this.MYNewSignupiPPJulyOneMonth('iPlatinum Package');
            }
             when 'MYNewSignupJulyMonthiGold'{
                return this.MYNewSignupiPPJulyOneMonth('iGold Package');
            }
             when 'MYNewSignupJulyMonthiClassic'{
                return this.MYNewSignupiPPJulyOneMonth('iClassic Package');
            }
             when 'MYNewSignupJulyMonthiStarter'{
                return this.MYNewSignupiPPJulyOneMonth('iStarter Package');
            }           
              when 'MYNewSignupPromoPropexiClassic'{
                return this.MYNewSignupPromoPropex('iClassic Package');
            }
            when 'MYNewSignupPromoPropexiBasic'{
                return this.MYNewSignupPromoPropex('iBasic Package');
            }
             when 'MYNewSignupPromoPropexiPlatinum'{
                return this.MYNewSignupPromoPropex('iPlatinum Package');
            }
             when 'MYNewSignupPromoPropexiGold'{
                return this.MYNewSignupPromoPropex('iGold Package');
            }
             when 'MYNewSignupLite'{
                return this.MYNewSignupPromotionLite();
            } 
            when 'MYrenewalPropexPromotion'{
                return this.MYrenewalPropexPromotion();
            }
            when 'fetchUpsellAgentsNov' {
                return this.fetchUpsellAgentsNov('Malaysia');
            }
            when else {
                return 'Error : Method does not exist';
            } 
        }
    }
    public list<sObject> MYNewSignupPromoPropex(String ippSubscription){
        Date months = system.today().addMonths(-14);
        Date iPPSubDate = system.today().addDays(90);
            return [Select id,name from Contact where Account.country__c = 'Malaysia' 
                    and account.recordtype.developerName = 'agent' 
                    and account.external_Field__c != null
                     and account.Test_Account__c =false
                    and account.iPP_Subscription__c =: ippSubscription
                    and account.IPP_Subscription_End_Date__c >=: iPPSubDate
                    and (account.status__c = 'Trial'
                    or Account.Subscription_End_Date__c <: months) 
                    and account.agency__r.name='PropNex Realty Sdn Bhd'];

    }
    public list<sObject> MYNewSignupPromotion(){
        Date months = system.today().addMonths(-14);
            return [Select id,name from Contact where Account.country__c = 'Malaysia' 
                    and account.recordtype.developerName = 'agent' 
                    and account.external_Field__c = null
                    and account.Test_Account__c =false
                    and (account.status__c = 'Trial'
                    or Account.Subscription_End_Date__c <: months)];

    }
    public list<sObject> MYNewSignupPromotionTrial(){
        return [
            Select id,name from Contact where Account.country__c = 'Malaysia'
            and account.recordtype.developerName = 'agent' 
            and account.external_Field__c = null
            and account.Test_Account__c =false
            and account.status__c = 'Trial'
        ];

    }
    
    public list<sObject> MYNewSignupPromotionTrialJuly(){
        return [
            Select id,name from Contact where Account.country__c = 'Malaysia'
            and account.recordtype.developerName = 'agent' 
            and account.external_Field__c = null
            and account.Test_Account__c =false
            and (account.status__c = 'Trial' or account.status__c = 'Expired')
        ];
    }
     public list<sObject> MYrenewalPropexPromotion(){
        Date months = system.today().addMonths(-1);
                  list<Contact> returnList = new List<Contact>();

           for( Contact con :[Select id,name,Account.Subscription_End_Date__c from Contact where Account.country__c = 'Malaysia' 
                    and account.recordtype.developerName = 'agent' 
                    and account.Test_Account__c =false
                    and account.status__c = 'Active'
                    and Account.Subscription_End_Date__c >: months
                              and account.agency__r.name='PropNex Realty Sdn Bhd']){
                                  if(Date.today() > con.Account.Subscription_End_Date__c.addMonths(-1) && Date.today() < con.Account.Subscription_End_Date__c)
                                      returnList.add(con);
                              }
         
         system.debug(returnList.size());
         
         return returnList;

    }
    public list<sObject> MYNewSignupPromotionLite(){
        Date months = system.today().addMonths(-14);
            return [Select id,name from Contact where Account.country__c = 'Malaysia' 
                    and account.recordtype.developerName = 'agent' 
                    and account.external_Field__c != null
                    and account.IPP_Subscription_End_Date__c >= today
                    and (account.status__c = 'Trial'
                    or Account.Subscription_End_Date__c <: months)];

    }
    public list<sObject> MYNewSignupiPP(String ippSubscription){
        Date months = system.today().addMonths(-14);
            return [Select id,name from Contact where Account.country__c = 'Malaysia' 
                    and account.recordtype.developerName = 'agent' 
                    and account.external_Field__c != null
                     and account.Test_Account__c =false
                    and account.iPP_Subscription__c =: ippSubscription
                    and account.IPP_Subscription_End_Date__c >= today
                    and (account.status__c = 'Trial'
                    or Account.Subscription_End_Date__c <: months)];

    }
     public list<sObject> MYNewSignupiPPOneMonth(String ippSubscription){
        Set<String> agentStatus = new Set<String>{'Trial','Expired'};
        Date months = system.today().addMonths(-1);
            return [Select id,name from Contact where Account.country__c = 'Malaysia' 
                    and account.recordtype.developerName = 'agent' 
                    and account.external_Field__c != null
                     and account.Test_Account__c =false
                    and account.iPP_Subscription__c =: ippSubscription
                    and account.IPP_Subscription_End_Date__c >= today
                    and ((account.status__c = 'Trial' and Account.Subscription_End_Date__c = LAST_MONTH) OR 
                         (account.status__c = 'Expired' and Account.Subscription_End_Date__c <= LAST_N_MONTHS:6))];

    }
    
    public list<sObject> MYNewSignupiPPJulyOneMonth(String ippSubscription){
        Date months = system.today().addMonths(-1);
            return [Select id,name from Contact where Account.country__c = 'Malaysia' 
                    and account.recordtype.developerName = 'agent' 
                    and account.external_Field__c != null
                     and account.Test_Account__c =false
                    and account.iPP_Subscription__c =: ippSubscription
                    and account.IPP_Subscription_End_Date__c >= today
                    and (account.status__c = 'Trial'
                    or Account.Subscription_End_Date__c <: months)];

    }


    public list<sObject> Winback(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,Account.Subscription_End_Date__c From Contact where Account.Country__c = 'Malaysia' AND Account.Status__c = 'Expired' AND  Account.Account_Rule_Code__c != 'Trial' AND (Account.Next_Subscription_Activation_Date__c < Today OR Account.Next_Subscription_Activation_Date__c = null) AND Account.Subscription_End_Date__c != null];
        for(Contact sObj : sobjList){
            Date today = System.today();
            Date endDate = sObj.Account.Subscription_End_Date__c;
            if(endDate.monthsBetween(today) == 3 || endDate.monthsBetween(today) == 4){
                listToReturn.add(sObj);
            }
        }
        return listToReturn;
    }
    Public list<sObject> AMeligible(){

        return database.query('Select id,name from Contact where Account.Status__c = \'Active\' AND Account.country__c = \'Malaysia\' and account.recordtype.developerName = \'agent\' and Account.Subscription_End_Date__c =NEXT_MONTH limit 50000');
    }

    public list<sObject> JUNStdAM2020(){
        return [Select id,name from Contact where Account.country__c = 'Thailand' and account.recordtype.developerName = 'agent' and CALENDAR_YEAR( Account.Subscription_End_Date__c) =2020 and (CALENDAR_Month(Account.Subscription_End_Date__c) =6 OR CALENDAR_Month(Account.Subscription_End_Date__c) = 5)and account.PG_Tenure__c =1];
    }
    public list<sObject> JUNStdAM2020PG2(){
        return [Select id,name from Contact where Account.country__c = 'Thailand' and account.recordtype.developerName = 'agent' and CALENDAR_YEAR( Account.Subscription_End_Date__c) =2020 and (CALENDAR_Month(Account.Subscription_End_Date__c) =6 OR CALENDAR_Month(Account.Subscription_End_Date__c) = 5)and account.PG_Tenure__c >1];
    }
    public list<sobject> januaryBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 1 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> januaryBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 1 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> januaryBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 1 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> februaryBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 2 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> februaryBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 2 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> februaryBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 2 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> marchBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 3 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> marchBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 3 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> marchBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 3 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> aprilBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 4 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> aprilBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 4 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> aprilBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 4 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> mayBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 5 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> mayBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 5 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> mayBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 5 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }


    public list<sobject> juneBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 6 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> juneBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 6 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> juneBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 6 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> julyBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 7 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> julyBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 7 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> julyBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 7 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> AugustBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 8 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> AugustBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 8 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> AugustBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 8 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> SeptemberBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 9 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> SeptemberBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 9 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> SeptemberBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 9 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> OctoberBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 10 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> OctoberBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 10 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> OctoberBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 10 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> NovemberBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 11 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> NovemberBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 11 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> NovemberBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 11 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> decemberBirthdayStd(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'STANDARD' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 12 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> decemberBirthdayAdvance(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  Account.Account_Rule_Code__c = 'ADVANCE' AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 12 ];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    public list<sobject> decemberBirthdayBusPremium(){
        list<sObject> listToReturn = new list<sObject>();
        list<Contact> sobjList = [Select id,(Select id,Contact__c from Activities__r where Type__c ='Birthday verification') From Contact where Account.Country__c = 'Singapore' AND Account.Status__c = 'Active' AND  (Account.Account_Rule_Code__c = 'BUSINESS' OR Account.Account_Rule_Code__c = 'PREMIER') AND Account.recordtype.developerName = 'Agent' AND CALENDAR_Month(Account.PersonBirthdate) = 12];
        for(Contact sObj : sobjList){
            if(!sObj.Activities__r.isEmpty()){
                listToReturn.add(sObj);
            }


        }
        return listToReturn;
    }
    /***************************************************/

    public list<sObject> jul2020Tnr1AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=1 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8))];
    }
    public list<sObject> jul2020Tnr2AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=2 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8))];
    }
    public list<sObject> jul2020Tnr3AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=3 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8))];
    }
    public list<sObject> jul2020Tnr4AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=4 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8))];
    }
    public list<sObject> jul2020Tnr5AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=5 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8))];
    }
    public list<sObject> jul2020Tnr6AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c>=6 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8))];
    }
    public list<sObject> jul2020Tnr1AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=1 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8)];
    }
    public list<sObject> jul2020Tnr2AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=2 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) ];
    }
    public list<sObject> jul2020Tnr3AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=3 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) ];
    }
    public list<sObject> jul2020Tnr4AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=4 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) ];
    }
    public list<sObject> jul2020Tnr5AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=5 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) ];
    }
    public list<sObject> jul2020Tnr6AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c>=6 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) ];
    }

    public list<sObject> aug2020Tnr1AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=1 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9))];
    }
    public list<sObject> aug2020Tnr2AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=2 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9))];
    }
    public list<sObject> aug2020Tnr3AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=3 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9))];
    }
    public list<sObject> aug2020Tnr4AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=4 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9))];
    }
    public list<sObject> aug2020Tnr5AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=5 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9))];
    }
    public list<sObject> aug2020Tnr6AM(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c>=6 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and ((account.status__c='Active' and CALENDAR_Month(Account.Subscription_End_Date__c) =8) or (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9))];
    }
    public list<sObject> aug2020Tnr1AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=1 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9)];
    }
    public list<sObject> aug2020Tnr2AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=2 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9) ];
    }
    public list<sObject> aug2020Tnr3AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=3 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9) ];
    }
    public list<sObject> aug2020Tnr4AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=4 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9) ];
    }
    public list<sObject> aug2020Tnr5AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=5 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9) ];
    }
    public list<sObject> aug2020Tnr6AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c>=6 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =9) ];
    }

    public list<sObject> jun2020Tnr1AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=1 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =7)];
    }
    public list<sObject> jun2020Tnr2AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=2 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) ];
    }
    public list<sObject> jun2020Tnr3AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=3 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) ];
    }
    public list<sObject> jun2020Tnr4AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=4 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) ];
    }
    public list<sObject> jun2020Tnr5AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c=5 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) ];
    }
    public list<sObject> jun2020Tnr6AM_1(){
        return [Select id,name from Contact where Account.country__c='Singapore' and account.recordtype.developerName='agent' and Account.PG_Tenure__c>=6 and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and (account.status__c='Downgraded' and CALENDAR_Month(Account.Subscription_End_Date__c) =7) ];
    }


    public list<sObject> MYjul2020AM(){
        return [Select id,name from Contact where Account.country__c='Malaysia' and account.recordtype.developerName='agent' and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and account.status__c in('Active','Suspended') and CALENDAR_Month(Account.Subscription_End_Date__c)=7];
    }
    public list<sObject> MYaug2020AM(){
        return [Select id,name from Contact where Account.country__c='Malaysia' and account.recordtype.developerName='agent' and CALENDAR_YEAR(Account.Subscription_End_Date__c)=2020 and account.status__c in('Active','Suspended') and CALENDAR_Month(Account.Subscription_End_Date__c)=7];
    }

    public list<sObject> SG_Advance_Package_Promo(){
        Date minusNineMonths = System.today().addMonths(-9);
        return [select id from contact where Account.Country__c = 'Singapore' AND ( ( account.Status__c = 'Trial' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c=null ) or ( account.Status__c = 'Expired' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c=null ) or ( account.Status__c = 'Expired' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c!=null AND  account.Subscription_End_Date__c<: minusNineMonths ))];
    }
    public list<sObject> SG_Advance_Package_Promo_6(){
        Date minusSixMonths = System.today().addMonths(-6);
        return [select id from contact where Account.Country__c = 'Singapore' AND ( ( account.Status__c = 'Trial' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c=null ) or ( account.Status__c = 'Expired' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c=null ) or ( account.Status__c = 'Expired' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c!=null AND  account.Subscription_End_Date__c<: minusSixMonths ))];
    }
    public list<sObject> SG_Advance_Package_Promo_14(){
        Date minusSixMonths = System.today().addMonths(-14);
        return [select id from contact where Account.Country__c = 'Singapore' AND ( ( account.Status__c = 'Trial' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c=null ) or ( account.Status__c = 'Expired' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c=null ) or ( account.Status__c = 'Expired' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c!=null AND  account.Subscription_End_Date__c<: minusSixMonths ))];
    }

    public list<sObject> SG_Advance_Package_Promo_18(){
        Date minusEighteenMonths = System.today().addMonths(-18);
        return [select id from contact where Account.Country__c = 'Singapore' AND ( ( account.Status__c = 'Trial' and account.Account_Rule_Code__c='TRIAL' ) or ( account.Status__c = 'Expired' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c IN ('Standard', 'Advanced', 'Premier', 'Business')  AND  account.Subscription_End_Date__c<: minusEighteenMonths ))];
    }
    public list<sObject> SG_Advance_Package_Promo_March21(){
        Date minusEighteenMonths = System.today().addMonths(-18);
        return [select id from contact where Account.Country__c = 'Singapore' AND ( ( account.Status__c = 'Trial' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c=null ) or ( account.Status__c = 'Expired' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c=null ) or ( account.Status__c = 'Expired' and account.Account_Rule_Code__c='TRIAL' and account.Previous_Account_Rule__c!=null AND  account.Subscription_End_Date__c<: minusEighteenMonths ))];
    }

    /**
*  fetching contacts for SG-2021-05 Advance Package Promo for $700 Off
*  @name fetchSGNewExpiredAgentContacts
*  @param integer
*  @reference PGAUTO-5207
*/
    public list<sObject> fetchSGNewExpiredAgentContacts(integer intMonth){
        Date minusMonths = System.today().addMonths(-intMonth);
        return [
            SELECT Id FROM Contact WHERE
            Account.Country__c = 'Singapore' AND
            ((Account.Status__c = 'Trial' AND
              Account.Account_Rule_Code__c = 'TRIAL' AND
              Account.Previous_Account_Rule__c = null )
             OR
             (Account.Status__c = 'Expired' AND
              Account.Account_Rule_Code__c = 'TRIAL' AND
              Account.Previous_Account_Rule__c = null )
             OR
             (Account.Status__c = 'Expired' AND
              Account.Account_Rule_Code__c = 'TRIAL' AND
              Account.Previous_Account_Rule__c !=null AND
              Account.Subscription_End_Date__c <: minusMonths ))
        ];
    }

    public list<sObject> SGMidTermUpgradeMarketingPromoTNR0(){
        list<Id> listToReturn = new list<Id>();
        for(Account acc:[select id,personContactId,Status__C,Loyalty_Start_Date__c,(Select Id from Opportunities where stageName not in ('Closed Won','Closed Lost') AND Opportunity_type__c = 'B2C - Renewal') from Account where Country__c = 'Singapore' AND  RecordTYpe.Name = 'Agent'AND Status__C IN ('Active') ]){
            if(CalculateUpgradeTenure(acc) == 0 && (acc.Opportunities == null || acc.Opportunities.size() == 0)){
                listToReturn.add(acc.personContactId);
            }
        }
        return [Select id from Contact where Id in:listToReturn ];
    }
    public list<sObject> SGMidTermUpgradeMarketingPromoTNR1(){
        list<Id> listToReturn = new list<Id>();
        for(Account acc:[select id,personContactId,Status__C,Loyalty_Start_Date__c,(Select Id from Opportunities where stageName not in ('Closed Won','Closed Lost') AND Opportunity_type__c = 'B2C - Renewal') from Account where Country__c = 'Singapore' AND  RecordTYpe.Name = 'Agent'AND Status__C IN ('Active')]){
            if(CalculateUpgradeTenure(acc) == 1 && (acc.Opportunities == null || acc.Opportunities.size() == 0)){
                listToReturn.add(acc.personContactId);
            }
        }
        return [Select id from Contact where Id in:listToReturn ];
    }
    public list<sObject> SGMidTermUpgradeMarketingPromoTNR2(){
        list<Id> listToReturn = new list<Id>();
        for(Account acc:[select id,personContactId,Status__C,Loyalty_Start_Date__c,(Select Id from Opportunities where stageName not in ('Closed Won','Closed Lost') AND Opportunity_type__c = 'B2C - Renewal') from Account where Country__c = 'Singapore' AND  RecordTYpe.Name = 'Agent'AND Status__C IN ('Active')]){
            if(CalculateUpgradeTenure(acc) == 2 && (acc.Opportunities == null || acc.Opportunities.size() == 0)){
                listToReturn.add(acc.personContactId);
            }
        }
        return [Select id from Contact where Id in:listToReturn ];
    }
    public list<sObject> SGMidTermUpgradeMarketingPromoTNR3(){
        list<Id> listToReturn = new list<Id>();
        for(Account acc:[select id,personContactId,Status__C,Loyalty_Start_Date__c,(Select Id from Opportunities where stageName not in ('Closed Won','Closed Lost') AND Opportunity_type__c = 'B2C - Renewal') from Account where Country__c = 'Singapore' AND  RecordTYpe.Name = 'Agent'AND Status__C IN ('Active')]){
            if(CalculateUpgradeTenure(acc) == 3 && (acc.Opportunities == null || acc.Opportunities.size() == 0)){
                listToReturn.add(acc.personContactId);
            }
        }
        return [Select id from Contact where Id in:listToReturn ];
    }
    public list<sObject> SGMidTermUpgradeMarketingPromoTNR4(){
        list<Id> listToReturn = new list<Id>();
        for(Account acc:[select id,personContactId,Status__C,Loyalty_Start_Date__c,(Select Id from Opportunities where stageName not in ('Closed Won','Closed Lost') AND Opportunity_type__c = 'B2C - Renewal') from Account where Country__c = 'Singapore' AND  RecordTYpe.Name = 'Agent'AND Status__C IN ('Active')]){
            if(CalculateUpgradeTenure(acc) == 4 && (acc.Opportunities == null || acc.Opportunities.size() == 0)){
                listToReturn.add(acc.personContactId);
            }
        }
        return [Select id from Contact where Id in:listToReturn ];
    }
    public list<sObject> SGMidTermUpgradeMarketingPromoTNR5(){
        list<Id> listToReturn = new list<Id>();
        for(Account acc:[select id,personContactId,Status__C,Loyalty_Start_Date__c,(Select Id from Opportunities where stageName not in ('Closed Won','Closed Lost') AND Opportunity_type__c = 'B2C - Renewal') from Account where Country__c = 'Singapore' AND  RecordTYpe.Name = 'Agent'AND Status__C IN ('Active')]){
            if(CalculateUpgradeTenure(acc) == 5 && (acc.Opportunities == null || acc.Opportunities.size() == 0)){
                listToReturn.add(acc.personContactId);
            }
        }
        return [Select id from Contact where Id in:listToReturn ];
    }
    public list<sObject> SGMidTermUpgradeMarketingPromoTNR6(){
        list<Id> listToReturn = new list<Id>();
        for(Account acc:[select id,personContactId,Status__C,Loyalty_Start_Date__c,(Select Id from Opportunities where stageName not in ('Closed Won','Closed Lost') AND Opportunity_type__c = 'B2C - Renewal') from Account where Country__c = 'Singapore' AND  RecordTYpe.Name = 'Agent'AND Status__C IN ('Active')]){
            if(CalculateUpgradeTenure(acc) >= 6 && (acc.Opportunities == null || acc.Opportunities.size() == 0)){
                listToReturn.add(acc.personContactId);
            }
        }
        return [Select id from Contact where Id in:listToReturn ];
    }

    public list<sObject> minus13Months(){
        Date minus13Months = System.today().addMonths(-13);
        return [Select id,Account.Subscription_End_Date__c  From Contact where Account.RecordType.Name = 'Agent' AND Account.Country__c = 'Malaysia' AND ( (Account.Status__c = 'Trial' AND Account.Account_Rule_Code__c = 'Trial' AND Account.Previous_Account_Rule__c = '') OR(Account.Status__c = 'Expired' AND Account.Account_Rule_Code__c = 'Trial' AND Account.Previous_Account_Rule__c = '') OR(Account.Status__c = 'Expired' AND Account.Account_Rule_Code__c IN ('ADMIN_ACCO', 'ADVANCED', 'BEGIN_1', 'BEGIN_2', 'GP', 'LITE', 'LITE10', 'LITE6', 'PREMIUM', 'PRO', 'ROOKIE-12', 'STANDARD') AND Account.Subscription_End_Date__c <=: minus13Months) )];
    }


    public static Decimal CalculateUpgradeTenure(Account acc){
        return (acc.Loyalty_Start_Date__c != null)? math.floor((((system.Today().addDays(1).year()-acc.Loyalty_Start_Date__c.year())*12+system.Today().addDays(1).month()-acc.Loyalty_Start_Date__c.month())/12)): 0;
    }
    public list<sObject> THDecOffer2(){
        list<Id> personContactIds = new list<id>();
        for(Opportunity opp : [Select Id,Account.PersonContactId  From Opportunity where stageName in ('New','Proposal') and Country__c = 'Thailand' and Opportunity_Type__c = 'B2C - Renewal' AND Opportunity.RecordType.Name = 'B2C' and Name LIKE '%December 2020 Renew%']){
            personContactIds.add(opp.Account.PersonContactId);
        }
        if(personContactIds.isEmpty()){
            return new list<contact>();
        }else{
            return [Select id from Contact where Id in :personContactIds ];
        }
    }

    //method used to return of the contacts for Riang Ria Raya Sale campaign
    //ref: PGAUTO-5134
    //remove the Opportunity_Type__c check, ref: PGAUTO-5248
    public list<sObject> fetchRiangRiaRayaSale(Integer subEndMonth){
        Set<String> setOfAccountStatus = new Set<String>{'Active', 'Suspended'};
            Set<String> setOfAccountRuleCode = new Set<String>{'LITE', 'STANDARD', 'ADVANCED', 'PREMIUM'};
                Set<String> setOfOptyStage = new Set<String>{'New', 'Proposal'};
                    List<Opportunity> listOfRenewal = [
                        SELECT Id, AccountId, Account.PersonContactId
                        FROM Opportunity
                        WHERE Account.Recordtype.DeveloperName = 'Agent' AND
                        Account.Country__c = 'Malaysia' AND
                        Account.Status__c IN: setOfAccountStatus AND
                        Account.Account_Rule_Code__c IN: setOfAccountRuleCode AND
                        //Opportunity_Type__c = 'B2C - Renewal' AND
                        StageName IN: setOfOptyStage AND
                        CALENDAR_Month(Account.Subscription_End_Date__c) =: subEndMonth AND
                        CALENDAR_YEAR(Account.Subscription_End_Date__c)= 2021
                    ];
        List<Contact> listContact = new List<Contact>();
        if(!listOfRenewal.isEmpty()) {
            Set<Id> setOfContactId = new Set<Id>();
            for(Opportunity eachOppty: listOfRenewal) {
                setOfContactId.add(eachOppty.Account.PersonContactId);
            }
            listContact = [SELECT Id FROM Contact WHERE Id IN: setOfContactId];
        }
        return listContact;
    }

    //method used to return Agents with less than $1k spends from the last 12 months
    //ref: PGAUTO-5723
    public list<sObject> fetchAgentsWithSpending(Decimal totalAmount) {
        Set<String> setOfAccountStatus = new Set<String>{'Active', 'Downgraded', 'Suspended'};
            Set<String> setOfAccountRuleCode = new Set<String>{'TRIAL', 'STANDARD', 'ADVANCE', 'PREMIER', 'BUSINESS'};
                Id b2cRecId = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C');
        Id b2cSSRecId = RecordTypeSelector.getRecordTypeId('Opportunity', 'B2C Self-Serve');
        Set<Id> setOfOptyRecId = new Set<Id>{b2cRecId, b2cSSRecId};
            Datetime startDateTime = Datetime.newInstance(2020, 07, 05, 00, 00, 00);
        Datetime endDateTime = Datetime.newInstance(2021, 07, 04, 23, 59, 59);
        Date startDate = Date.newInstance(2020, 07, 05);
        Date endDate = Date.newInstance(2021, 07, 04);
        List<Opportunity> listOfOppty = [
            SELECT Id, AccountId, Account.PersonContactId, Total_Amount__c, OMC_Approved_Date__c, CloseDate, RecordTypeId,
            Total_Spending_on_Discretionary_Prod_new__c
            FROM Opportunity
            WHERE Account.Recordtype.DeveloperName = 'Agent' AND
            Account.Country__c = 'Singapore' AND
            Account.Status__c IN: setOfAccountStatus AND
            Account.Account_Rule_Code__c IN: setOfAccountRuleCode AND
            Total_Amount__c != null AND
            ((RecordTypeId =: b2cRecId AND
              OMC_Approved_Date__c >: startDateTime AND
              OMC_Approved_Date__c <: endDateTime AND
              StageName = 'Closed Won') OR
             (RecordTypeId =: b2cSSRecId AND
              CloseDate >: startDate AND
              CloseDate <: endDate AND
              StageName = 'Converted'))
        ];
        List<Contact> listContact = new List<Contact>();
        if(!listOfOppty.isEmpty()) {
            Map<String, Decimal> mapOfAgentIdVsAmoutn = new Map<String, Decimal>();
            for(Opportunity eachOppty: listOfOppty) {
                Decimal totalDiscAmount;
                if(eachOppty.RecordTypeId == b2cRecId && eachOppty.Total_Spending_on_Discretionary_Prod_new__c != null) {
                    totalDiscAmount = eachOppty.Total_Spending_on_Discretionary_Prod_new__c;
                } else if(eachOppty.RecordTypeId == b2cSSRecId && eachOppty.Total_Amount__c != null) {
                    totalDiscAmount = eachOppty.Total_Amount__c;
                }
                if(totalDiscAmount != null) {
                    if(!mapOfAgentIdVsAmoutn.containsKey(eachOppty.Account.PersonContactId)) {
                        mapOfAgentIdVsAmoutn.put(eachOppty.Account.PersonContactId, totalDiscAmount);
                    } else {
                        Decimal oldAmount = mapOfAgentIdVsAmoutn.get(eachOppty.Account.PersonContactId);
                        mapOfAgentIdVsAmoutn.put(eachOppty.Account.PersonContactId, (oldAmount + totalDiscAmount));
                    }
                }
            }
            Set<Id> setOfContactId = new Set<Id>();
            for(String eachContactId : mapOfAgentIdVsAmoutn.keySet()) {
                if(mapOfAgentIdVsAmoutn.get(eachContactId) < totalAmount) {
                    setOfContactId.add(eachContactId);
                }
            }
            if(!setOfContactId.isEmpty()) {
                listContact = [SELECT Id FROM Contact WHERE Id IN: setOfContactId];
            }
        }
        return listContact;
    }

    /**
*  Method to fetch MY or TH Agents For EB, AM, AM+1 Renewal Campaign on
the basis of Renewal Opportunity created in current or in last 2 months
*  @param  String , String
*  @return List<Contact>
*  @reference PGAUTO-6038,6041
*/
    public list<sObject> fetchRenewalMYOrTHAgents(String campaignType, String campCountry){
        Set<String> agentStatusSet = new Set<String>();
        Set<Id> setToReturn = new Set<Id>();
        Set<String> oppStageName = new Set<String>{'Closed Won','Expired'};
            
            if(campaignType == 'EB') {
                agentStatusSet.add('Active');
            } else if(campaignType == 'AM') {
                agentStatusSet.add('Active');
                agentStatusSet.add('Suspended');
            } else if(campaignType == 'AM+1') {
                agentStatusSet.add('Suspended');
            }
        if(campaignType == 'EB') {
            for(Account acc: [SELECT Id,personContactId,
                              (SELECT Id, StageName
                               FROM Opportunities
                               WHERE Opportunity_Type__c = 'B2C - Renewal'
                               AND CreatedDate = THIS_MONTH)
                              FROM Account
                              WHERE country__c =: campCountry
                              AND recordtype.developerName = 'Agent'
                              AND Subscription_End_Date__c!= null
                              AND Subscription_End_Date__c = NEXT_MONTH
                              AND Test_Account__c = false
                              AND Status__c In: agentStatusSet]
               ) {
                   if(!acc.Opportunities.isEmpty()) {
                       setToReturn.add(acc.personContactId);
                   }
               }

        } else if(campaignType == 'AM') {
            for(Account acc: [SELECT Id,personContactId,
                              (SELECT Id, StageName
                               FROM Opportunities
                               WHERE StageName In: oppStageName
                               AND Opportunity_Type__c = 'B2C - Renewal'
                               AND CreatedDate = LAST_MONTH)
                              FROM Account
                              WHERE country__c =: campCountry
                              AND recordtype.developerName = 'Agent'
                              AND Subscription_End_Date__c!= null
                              AND Subscription_End_Date__c = THIS_MONTH
                              AND Test_Account__c = false
                              AND Status__c In: agentStatusSet]
               ) {
                   if(acc.Opportunities.isEmpty()) {
                       setToReturn.add(acc.personContactId);
                   }
               }

        } else if(campaignType == 'AM+1') {
            for(Account acc: [SELECT Id,personContactId,
                              (SELECT Id, StageName
                               FROM Opportunities
                               WHERE StageName In: oppStageName
                               AND Opportunity_Type__c = 'B2C - Renewal'
                               AND CreatedDate = LAST_N_MONTHS:2)
                              FROM Account
                              WHERE country__c =: campCountry
                              AND recordtype.developerName = 'Agent'
                              AND Subscription_End_Date__c!= null
                              AND Subscription_End_Date__c = LAST_MONTH
                              AND Test_Account__c = false
                              AND Status__c In: agentStatusSet]
               ) {
                   if(acc.Opportunities.isEmpty()) {
                       setToReturn.add(acc.personContactId);
                   }
               }
        }
        return [Select id from Contact where Id in:setToReturn ];
    }
    
    public List<sObject> fetchUpsellAgentsNov(String camCountry) {
        Set<Id> accToReturn = new Set<Id>();
        List<Account> accList = [SELECT Id, Country__c,personContactId,(SELECT Id,Opportunity_Type__c FROM Opportunities 
                                 WHERE Opportunity_Type__c = 'B2C - Upgrade' and RecordType.Developername = 'B2C' and 
                                 StageName = 'Proposal') FROM Account WHERE Country__c =:camCountry and Status__c = 'Active'
                                 and RecordType.Developername = 'Agent' and Test_Account__c = false];
        for(Account acc : accList) {
            if(acc.Opportunities != null && acc.Opportunities.size() !=0) {
                accToReturn.add(acc.personContactId);  
            }
        }
        return [Select id,name from Contact where id in:accToReturn];
        
    }
    
           /**
*  Method to fetch MY or TH Agents For EB, AM, AM+1 June Renewal Campaign on
the basis of Renewal Opportunity created in current or in last 2 months
*  @param  String , String
*  @return List<Contact>
*  @reference PGAUTO-8249
*/
    public list<sObject> fetchRenewalJuneMYOrTHAgents(String campaignType, String campCountry){
        Set<String> agentStatusSet = new Set<String>();
        Set<Id> setToReturn = new Set<Id>();
        Set<String> oppStageName = new Set<String>{'Closed Won','Expired'};
        Set<String> oppStage = new Set<String>{'New','Proposal'};
            
            if(campaignType == 'EB') {
                agentStatusSet.add('Active');
            } else if(campaignType == 'AM') {
                agentStatusSet.add('Active');
                agentStatusSet.add('Suspended');
            } else if(campaignType == 'AM+1') {
                agentStatusSet.add('Suspended');
            }
        if(campaignType == 'EB') {
            for(Account acc: [SELECT Id,personContactId,
                              (SELECT Id, StageName
                               FROM Opportunities
                               WHERE Opportunity_Type__c = 'B2C - Renewal'
                               AND StageName In: oppStage
                               AND CreatedDate = THIS_MONTH)
                              FROM Account
                              WHERE country__c =: campCountry
                              AND recordtype.developerName = 'Agent'
                              AND Subscription_End_Date__c!= null
                              AND Subscription_End_Date__c = NEXT_MONTH
                              AND Test_Account__c = false
                              AND Status__c In: agentStatusSet]
               ) {
                   if(!acc.Opportunities.isEmpty()) {
                       setToReturn.add(acc.personContactId);
                   }
               }

        } else if(campaignType == 'AM') {
            for(Account acc: [SELECT Id,personContactId,
                              (SELECT Id, StageName
                               FROM Opportunities
                               WHERE StageName NOT In: oppStageName
                               AND Opportunity_Type__c = 'B2C - Renewal'
                               AND CreatedDate = LAST_MONTH)
                              FROM Account
                              WHERE country__c =: campCountry
                              AND recordtype.developerName = 'Agent'
                              AND Subscription_End_Date__c!= null
                              AND Subscription_End_Date__c = THIS_MONTH
                              AND Test_Account__c = false
                              AND Status__c In: agentStatusSet]
               ) {
                   if(!acc.Opportunities.isEmpty()) {
                       setToReturn.add(acc.personContactId);
                   }
               }

        } else if(campaignType == 'AM+1') {
            for(Account acc: [SELECT Id,personContactId,
                              (SELECT Id, StageName
                               FROM Opportunities
                               WHERE StageName NOT In: oppStageName
                               AND Opportunity_Type__c = 'B2C - Renewal'
                               AND CreatedDate = LAST_N_MONTHS:2)
                              FROM Account
                              WHERE country__c =: campCountry
                              AND recordtype.developerName = 'Agent'
                              AND Subscription_End_Date__c!= null
                              AND Subscription_End_Date__c = LAST_MONTH
                              AND Test_Account__c = false
                              AND Status__c In: agentStatusSet]
               ) {
                   if(!acc.Opportunities.isEmpty()) {
                       setToReturn.add(acc.personContactId);
                   }
               }
        }
        return [Select id from Contact where Id in:setToReturn ];
    }
    
               /**
*  Method to fetch MY Agents For EB, AM, AM+1 June Renewal Commercial Agreement partners Campaign on
the basis of Renewal Opportunity created in current or in last 2 months
*  @param  String , String
*  @return List<Contact>
*  @reference PGAUTO-8250
*/
    public list<sObject> fetchRenewalMYCommercialAgents(String campaignType, String campCountry){
        Set<String> agentStatusSet = new Set<String>();
        Set<Id> setToReturn = new Set<Id>();
        Set<String> oppStageName = new Set<String>{'Closed Won','Expired'};
        Set<String> oppStage = new Set<String>{'New','Proposal'};
        Set<String> agencyName = new Set<String>{'0017F00001gEGDJQA4', '0017F00001gEGGtQAO', '0017F00001kzylPQAQ', '0017F00001gEG4wQAG', '0017F00001gEGGBQA4', '0017F00001gEG5lQAG', '0017F00001gEG74QAG'};
            
            if(campaignType == 'EB') {
                agentStatusSet.add('Active');
            } else if(campaignType == 'AM') {
                agentStatusSet.add('Active');
                agentStatusSet.add('Suspended');
            } else if(campaignType == 'AM+1') {
                agentStatusSet.add('Suspended');
            }
        if(campaignType == 'EB') {
            for(Account acc: [SELECT Id,personContactId,
                              (SELECT Id, StageName
                               FROM Opportunities
                               WHERE Opportunity_Type__c = 'B2C - Renewal'
                               AND StageName In: oppStage
                               AND CreatedDate = THIS_MONTH)
                              FROM Account
                              WHERE country__c =: campCountry
                              AND recordtype.developerName = 'Agent'
                              AND Subscription_End_Date__c!= null
                              AND Subscription_End_Date__c = NEXT_MONTH
                              AND Test_Account__c = false
                              AND Agency__c In: agencyName
                              AND Status__c In: agentStatusSet]
               ) {
                   if(!acc.Opportunities.isEmpty()) {
                       setToReturn.add(acc.personContactId);
                   }
               }

        } else if(campaignType == 'AM') {
            for(Account acc: [SELECT Id,personContactId,
                              (SELECT Id, StageName
                               FROM Opportunities
                               WHERE StageName NOT In: oppStageName
                               AND Opportunity_Type__c = 'B2C - Renewal'
                               AND CreatedDate = LAST_MONTH)
                              FROM Account
                              WHERE country__c =: campCountry
                              AND recordtype.developerName = 'Agent'
                              AND Subscription_End_Date__c!= null
                              AND Subscription_End_Date__c = THIS_MONTH
                              AND Test_Account__c = false
                              AND Agency__c In: agencyName
                              AND Status__c In: agentStatusSet]
               ) {
                   if(!acc.Opportunities.isEmpty()) {
                       setToReturn.add(acc.personContactId);
                   }
               }

        } else if(campaignType == 'AM+1') {
            for(Account acc: [SELECT Id,personContactId,
                              (SELECT Id, StageName
                               FROM Opportunities
                               WHERE StageName NOT In: oppStageName
                               AND Opportunity_Type__c = 'B2C - Renewal'
                               AND CreatedDate = LAST_N_MONTHS:2)
                              FROM Account
                              WHERE country__c =: campCountry
                              AND recordtype.developerName = 'Agent'
                              AND Subscription_End_Date__c!= null
                              AND Subscription_End_Date__c = LAST_MONTH
                              AND Test_Account__c = false
                              AND Agency__c In: agencyName
                              AND Status__c In: agentStatusSet]
               ) {
                   if(!acc.Opportunities.isEmpty()) {
                       setToReturn.add(acc.personContactId);
                   }
               }
        }
        return [Select id from Contact where Id in:setToReturn ];
    }

    /**
*  Method to fetch SG Agents For Renewal Campaign on the basis of
Renewal Opportunity created in current or in last month
*  @param  Integer
*  @return List<Contact>
*  @reference PGAUTO-6037
*/
    public list<sObject> fetchRenewalSGAgents(Integer tenure){
        Integer currentMonth = system.today().month();
        Integer nextMonth = (system.today().addMonths(+1)).month();
        Set<Id> setToReturn = new Set<Id>();
        Set<Id> agentsSubEnDateCurrMonth = new Set<Id>();
        Set<Id> agentsSubEnDateNextMonth = new Set<Id>();
        Set<String> oppStageName = new Set<String>{'Closed Won','Expired'};
            Set<String> agentStatusSet = new Set<String>{'Active','Suspended'};
                Set<String> accRuleCodeSet = new Set<String>{'STANDARD','ADVANCE','PREMIER','BUSINESS'};

                    if(tenure <=5) {
                        for(Account acc: [SELECT id,personcontactId,
                                          Subscription_End_Date__c
                                          FROM Account
                                          WHERE country__c='Singapore'
                                          AND recordtype.developerName='Agent'
                                          AND PG_Tenure__c =: tenure
                                          AND Account_Rule_Code__c In: accRuleCodeSet
                                          AND account.Status__c In: agentStatusSet
                                          AND Subscription_End_Date__c!= null
                                          AND Test_Account__c = false
                                          AND (Subscription_End_Date__c = THIS_MONTH
                                               OR Subscription_End_Date__c = NEXT_MONTH) ]
                           ) {

                               if(acc.Subscription_End_Date__c.month() == nextMonth) {
                                   agentsSubEnDateNextMonth.add(acc.Id);
                               } else if(acc.Subscription_End_Date__c.month() == currentMonth) {
                                   agentsSubEnDateCurrMonth.add(acc.Id);
                                   setToReturn.add(acc.personcontactId);
                               }
                           }
                    } else if(tenure == 6) {
                        for(Account acc: [SELECT id,personcontactId,
                                          Subscription_End_Date__c
                                          FROM Account
                                          WHERE country__c='Singapore'
                                          AND recordtype.developerName='Agent'
                                          AND PG_Tenure__c >= 6
                                          AND Account_Rule_Code__c In: accRuleCodeSet
                                          AND account.Status__c In: agentStatusSet
                                          AND Subscription_End_Date__c!= null
                                          AND Test_Account__c = false
                                          AND (Subscription_End_Date__c = THIS_MONTH
                                               OR Subscription_End_Date__c = NEXT_MONTH) ]
                           ) {

                               if(acc.Subscription_End_Date__c.month() == nextMonth) {
                                   agentsSubEnDateNextMonth.add(acc.Id);
                               } else if(acc.Subscription_End_Date__c.month() == currentMonth) {
                                   agentsSubEnDateCurrMonth.add(acc.Id);
                                   setToReturn.add(acc.personcontactId);
                               }
                           }
                    }

        if(!agentsSubEnDateNextMonth.isEmpty()) {
            for(Opportunity opp: [SELECT Id,Account.personcontactId
                                  FROM Opportunity
                                  WHERE Opportunity_Type__c = 'B2C - Renewal'
                                  AND CreatedDate = THIS_MONTH
                                  AND AccountId In:agentsSubEnDateNextMonth]
               ) {
                   if(!setToReturn.contains(opp.Account.personcontactId)) {
                       setToReturn.add(opp.Account.personcontactId);
                   }
               }
        } else if(!agentsSubEnDateCurrMonth.isEmpty()) {
            for(Opportunity opp: [SELECT Id,Account.personcontactId
                                  FROM Opportunity
                                  WHERE Opportunity_Type__c = 'B2C - Renewal'
                                  AND CreatedDate = LAST_MONTH
                                  AND StageName In: oppStageName
                                  AND AccountId In:agentsSubEnDateCurrMonth]
               ) {
                   if(setToReturn.contains(opp.Account.personcontactId)) {
                       setToReturn.remove(opp.Account.personcontactId);
                   }
               }
        }
        return [Select id from Contact where Id in:setToReturn ];
    }

    /**
*  Method to get the agent for Anniversary Benefits
*  @param  set of reward tier
*  @return List<Contact>
*  @reference
*/
    private list<sObject> fetchAnniversaryAgents(Set<String> setOfTier) {
        Integer currentMonth = system.today().month();
        List<Contact> listContact = [
            SELECT Id FROM Contact
            WHERE Account.Country__c = 'Singapore'
            AND Account.Recordtype.DeveloperName = 'Agent'
            AND Account.Test_Account__c = false
            AND CALENDAR_MONTH(Account.Loyalty_Start_Date__c) =: currentMonth
            AND Account.Account_Rule_Code__c IN ('Standard', 'Advance', 'Premier', 'Business')
            AND Account.Reward_Tier__c IN: setOfTier
        ];
        return listContact;
    }
    /**
*  Method to get the agent for MY Sept Specialist campaign
*  @return List<Contact>
*  @reference
*/
    public list<sObject> mySeptSpecialistCampaign() {

        Datetime startDateTime = Datetime.newInstance(2021, 09, 13, 00, 00, 00);
        Datetime endDateTime = Datetime.newInstance(2021, 09, 30, 23, 59, 59);
        Set<String> setOfAccountRuleCode = new Set<String>{'ADVANCED', 'PREMIUM'};
        List<Contact> listContact = new List<Contact>();
        Set<Id> setOfOpportunityId = new Set<Id>();
        Set<Id> setOfContactId = new Set<Id>();
        for(Opportunity eachOppty:  [SELECT Id, AccountId, Account.PersonContactId,Opportunity_Type__c
                                     FROM Opportunity
                                     WHERE Account.Recordtype.DeveloperName = 'Agent' AND
                                     Account.Country__c = 'Malaysia' AND
                                     Account.Account_Rule_Code__c IN: setOfAccountRuleCode AND
                                     (Opportunity_Type__c = 'B2C - Renewal' OR Opportunity_Type__c = 'B2C - Standard') AND
                                     StageName ='Closed Won' AND
                                     Recordtype.DeveloperName = 'B2C' AND
                                     OMC_Approved_Date__c >=: startDateTime AND
                                     OMC_Approved_Date__c <=: endDateTime AND
                                     StageName = 'Closed Won']){
                                         if(eachOppty.Opportunity_Type__c == 'B2C - Renewal'){
                                             setOfContactId.add(eachOppty.Account.PersonContactId);
                                         }else if(eachOppty.Opportunity_Type__c == 'B2C - Standard'){
                                             setOfOpportunityId.add(eachOppty.id);
                                         }
                                     }
        if(!setOfOpportunityId.isEmpty()){
            for(OpportunityLineItem oli : [SELECT Campaign__c, OpportunityId,opportunity.Account.PersonContactId,is_bundle__c ,Id FROM OpportunityLineItem where is_bundle__c =true and OpportunityId IN : setOfOpportunityId and Campaign__c!=null and Campaign__r.name ='MY Sept Merdeka Sale' ]){
                setOfContactId.add(oli.opportunity.Account.PersonContactId);
            }
        }
          if(!setOfContactId.isEmpty())
            listContact = [SELECT Id FROM Contact WHERE Id IN: setOfContactId];

        return listContact;
    }
    public list<sObject> SGMidTermUpgradeMarketingPromo(Integer tenure){
        list<Id> listToReturn = new list<Id>();
        list<account> accList = new list<account>();
        DateTime startDateDec = Datetime.newInstance(2021, 12, 01,00,00,00);
        DateTime endDateDec = Datetime.newInstance(2021, 12, 01,23,59,59);
        DateTime endDateJan = Datetime.newInstance(2022, 01, 01,23,59,59);
        DateTime startDateJan = Datetime.newInstance(2022, 01, 01,00,00,00);
        if(tenure==6){
            accList = [
                SELECT Id, personContactId, Status__c, Loyalty_Start_Date__c,
                (SELECT Id FROM Opportunities
                WHERE Country__c ='Singapore'
                AND Opportunity_type__c = 'B2C - Renewal'
                AND ((Createddate >=: startDateDec and Createddate<= :endDateDec)
                OR (Createddate >=: startDateJan and Createddate<= :endDateJan)))
                FROM Account where Country__c = 'Singapore'
                AND  RecordTYpe.Name = 'Agent'
                AND Status__C IN ('Active','Suspended')
                AND PG_Tenure__c >=: tenure
            ];
        }
        else{
            accList = [
                SELECT Id, personContactId, Status__c, Loyalty_Start_Date__c,
                (SELECT Id FROM Opportunities
                WHERE Country__c ='Singapore'
                AND Opportunity_type__c = 'B2C - Renewal'
                AND ((Createddate >=: startDateDec and Createddate<= :endDateDec)
                OR (Createddate >=: startDateJan and Createddate<= :endDateJan)))
                FROM Account where Country__c = 'Singapore'
                AND  RecordTYpe.Name = 'Agent'
                AND Status__C IN ('Active','Suspended')
                AND PG_Tenure__c =: tenure
            ];
        }
        for(Account acc:accList){
            if(!acc.Opportunities.isEmpty()){
                listToReturn.add(acc.personContactId);  
            }
        }
        return [Select id from Contact where Id in:listToReturn];
    }
    public class ExtensionMalformedCallException extends Exception {}  
}