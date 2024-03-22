/**
 * Created by petar on 1/9/20.
 */

global class CS_AdServedPickerOptionsProvider implements csinvgridspt.PickerSupport.PickerOptionsProvider{

    /*
    *
    * @productNodeIdList:
    *        self explanatory, holds list of selected ProductNodes
    *
    * @paramsMap:
    *       holds the following keys:
    *           -   accountId
    *           -   billingType (CPM,CPD)
    *           -   fromTime
    *           -   toTime
    *           -   mediaTypes (Digital, Print)
    *

    */
    global String getPickerOptions(List<String> productNodeIdList, Map<String, String> paramsMap) {


        // fetch Rate Card Item price liste which matches Product Nodes and billing params
        List<csmso__Rate_Card_Item_Price__c> rcipList = [
                SELECT Id,
                        csmso__Advert_Assignment__r.Id,
                        csmso__Advert_Assignment__r.Name
                FROM
                    csmso__Rate_Card_Item_Price__c
                WHERE
                    csmso__Rate_Card__r.csmso__Product_Node__c IN: productNodeIdList
                    AND
                    csmso__Advert_Assignment__r.Rate_Type__c =: paramsMap.get('billingType')
                ];

        // convert RCIP list to PickerOption list to be returned\

        List<PickerOption> pOptionList = new List<PickerOption>();

        for (csmso__Rate_Card_Item_Price__c rcip : rcipList) {
                PickerOption newPO = new PickerOption();
                newPO.Id = rcip.Id;
                newPO.label = rcip.csmso__Advert_Assignment__r.Name;
                newPO.naa = new csmso__Node_Advert_Assignment__c(Id = rcip.csmso__Advert_Assignment__r.id,Name= rcip.csmso__Advert_Assignment__r.Name);
                newPO.rcip = rcip;

                pOptionList.add( newPO );
        }

        return JSON.serializePretty(new Map<String, List<PickerOption>>{'pickerOptions' => pOptionList});
    }


    global class PickerOption {
        global Id id; // RCIP Id
        global String label;
        global csmso__Node_Advert_Assignment__c naa;
        global csmso__Rate_Card_Item_Price__c rcip;
        global List<SObject> includedAds;
        global List<SObject> excludedAds;
    }

}