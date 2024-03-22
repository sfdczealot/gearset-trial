/*------------------------------------------------------------
Author:         Whisnu Satriya Wardhana
Company:     Viseo Asia PTE LTD
Description:    Apex class to handle record eligiblity (parameterize)
Inputs:        
               
Test Class: EligibilityHandler_test
History
<Date>      <Authors Name>     <Brief Description of Change>
------------------------------------------------------------*/
public class EligibilityHandler {
    /*------------------------------------------------------------
    Author:         Whisnu Satriya Wardhana
    Company:     Viseo Asia PTE LTD
    Description:    Function to get list of available PricebookEntry which is Subscription Products
    Inputs:        param <list<sObject>>: list of sObject's eligibility to be determined
                   
    Return: string
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    ------------------------------------------------------------*/
    public static void assignValue(list<sObject> param, string countryName) {
        string objectName = string.valueof(param.getSObjectType());
        list<string> listEligibility = new list<string>();
        string stringEligibility = '';
        list<Eligibility__mdt> listEligibilityMdt = [select Id from Eligibility__mdt where Object__c=:objectName];
        list<Map_Eligibility__mdt> listMapEligibilityMdt = [select Eligibility__r.Label from Map_Eligibility__mdt where Eligibility__c in :listEligibilityMdt and Country__c=:countryName];
        
        if (listMapEligibilityMdt.size() > 0) {
            for (Map_Eligibility__mdt row: listMapEligibilityMdt) {
                listEligibility.add(row.Eligibility__r.Label);
            }
            stringEligibility = string.join(listEligibility, ',');
            for (sObject row: param) {
                row.put('Record_Eligibility__c', stringEligibility);
            }
        }
    }
    
    /*------------------------------------------------------------
    Author:         Whisnu Satriya Wardhana
    Company:     Viseo Asia PTE LTD
    Description:    Function to get list of country available for particular eligibility
    Inputs:        param <string>: Eligibility name to be look for
                   
    Return: string
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    ------------------------------------------------------------*/
    public static list<string> getCountryEligibility(string param) {
        list<string> listCountry = new list<string>();
        list<Eligibility__mdt> listEligibilityMdt = [select Id from Eligibility__mdt where Label=:param];
        list<Map_Eligibility__mdt> listMapEligibilityMdt = [select Country__c from Map_Eligibility__mdt where Eligibility__c in :listEligibilityMdt];
        
        if (listMapEligibilityMdt.size() > 0) {
            for (Map_Eligibility__mdt row: listMapEligibilityMdt) {
                listCountry.add(row.Country__c);
            }
        }
        return listCountry;
    }
    
    /*------------------------------------------------------------
    Author:         Whisnu Satriya Wardhana
    Company:     Viseo Asia PTE LTD
    Description:    Function to get map of country code
    Inputs:        
                   
    Return: map<string, string>
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    ------------------------------------------------------------*/
    public static map<string, string> getMapCountryCode() {
        CountryCode__C[] countrycode = CountryCode__c.getAll().Values();
        map<string,string> mapCountry = new map<string,string>();
        for (integer i = 0 ; i<countrycode.size(); i++){
            mapCountry.put(countrycode[i].Name, countrycode[i].Code__c);
        }
        return mapCountry;
    }
    
    /*------------------------------------------------------------
    Author:         Whisnu Satriya Wardhana
    Company:     Viseo Asia PTE LTD
    Description:    Function to get map of Expired Hours for each country
    Inputs:        
                   
    Return: map<string, Country_Expired_Hours__mdt>
    History
    <Date>      <Authors Name>     <Brief Description of Change>
    ------------------------------------------------------------*/
    public static map<string, Country_Attribute__mdt> getCountryAttribute(){
        map<string, Country_Attribute__mdt> mapCountryAMdt = new map<string, Country_Attribute__mdt>();
        for (Country_Attribute__mdt row: [select Label, Expired_Hours__c, Expired_Hours_Before_Ready_for_Payment__c, Payment_Link__c from Country_Attribute__mdt]) {
            mapCountryAMdt.put(row.Label, row);
        }
        return mapCountryAMdt;
    }
}