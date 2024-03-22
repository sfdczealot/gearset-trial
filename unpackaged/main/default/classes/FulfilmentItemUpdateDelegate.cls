global with sharing class FulfilmentItemUpdateDelegate implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    global String performAction(String params) {
        KvaParams kvaParams = (KvaParams) JSON.deserialize(params, KvaParams.class);

        if(kvaParams.fulfilmentItemId!='') {
            List<csdf__Fulfilment_Item__c> fItems = [Select id from csdf__Fulfilment_Item__c where Id  =:kvaParams.fulfilmentItemId];
            if(!fItems.isEmpty()) {
                fItems[0].Keyvalues_and_Audience_JSON__c = KvaParams.kva;
                update fItems[0];
            }
        }
        return JSON.serialize('Ok');
    }

    public class KvaParams {
        public String fulfilmentItemId {get; set;}
        public String kva {get; set;}
    }
}