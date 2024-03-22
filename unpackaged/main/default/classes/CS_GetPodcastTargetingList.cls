global class CS_GetPodcastTargetingList implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    global String performAction(String params) {
        System.debug('params => ' + params);
        List<RequestResult> requestResultList = (List<RequestResult>) JSON.deserialize(params, List<RequestResult>.class);

        Map<String, RequestResult> requestResultMap = new Map<String, RequestResult>();
        Set<Id> adSlotTargetingTemplatesIds = new Set<Id>();
        Set<Id> marketIds = new Set<Id>();
        for (RequestResult obj : requestResultList) {
            requestResultMap.put(obj.configId, obj);
            if (String.isNotBlank(obj.podcastTargetingId)) {
                adSlotTargetingTemplatesIds.add(obj.podcastTargetingId);
            }
            if (String.isNotBlank(obj.podcastGeoTargetingId)) {
                marketIds.add(obj.podcastGeoTargetingId);
            }
        }

        Map<Id, csmso__Product_Node__c> podcastGeoTargetingsMap =  new Map<Id, csmso__Product_Node__c>();
        if (!marketIds.isEmpty()){
            podcastGeoTargetingsMap = new Map<Id, csmso__Product_Node__c>([
                    SELECT Id, csmso__Description__c
                    FROM csmso__Product_Node__c
                    WHERE Id = :marketIds
            ]);
        }

        List<Ad_Slot_Targeting_Template__c> adSlotTargetingTemplates = new List<Ad_Slot_Targeting_Template__c>();
        if (!adSlotTargetingTemplatesIds.isEmpty()) {
            adSlotTargetingTemplates = [
                    SELECT Id, Targeting_Template__c, Ad_Slot__r.csdf__Name__c
                    FROM Ad_Slot_Targeting_Template__c
                    WHERE Targeting_Template__c = :adSlotTargetingTemplatesIds
            ];
        }

        Map<Id, String> adSlotTargetingListByTargetingTemplateId = new Map<Id, String>();
        for (Ad_Slot_Targeting_Template__c adSlotTargetingTemplate : adSlotTargetingTemplates) {
            if (adSlotTargetingListByTargetingTemplateId.containsKey(adSlotTargetingTemplate.Targeting_Template__c)){
                String adSlotTargetingList = adSlotTargetingListByTargetingTemplateId.get(adSlotTargetingTemplate.Targeting_Template__c);
                adSlotTargetingList += ', ' + adSlotTargetingTemplate.Ad_Slot__r.csdf__Name__c;
                adSlotTargetingListByTargetingTemplateId.put(adSlotTargetingTemplate.Targeting_Template__c, adSlotTargetingList);
            }
            else {
                String adSlotTargetingList = 'Inventory (include) ' + adSlotTargetingTemplate.Ad_Slot__r.csdf__Name__c;
                adSlotTargetingListByTargetingTemplateId.put(adSlotTargetingTemplate.Targeting_Template__c, adSlotTargetingList);
            }
        }

        Map<String, String> responseResult = new Map<String, String>();
        for (String configId : requestResultMap.keySet()) {
            RequestResult requestResult = requestResultMap.get(configId);
            String listOfTargeting = '';
            if (String.isNotBlank(requestResult.podcastTargetingId) && adSlotTargetingListByTargetingTemplateId.containsKey(requestResult.podcastTargetingId)) {
                listOfTargeting = adSlotTargetingListByTargetingTemplateId.get(requestResult.podcastTargetingId);
            }

            if (String.isNotBlank(requestResult.podcastGeoTargetingId) && podcastGeoTargetingsMap.containsKey(requestResult.podcastGeoTargetingId)) {
                csmso__Product_Node__c productNode = podcastGeoTargetingsMap.get(requestResult.podcastGeoTargetingId);
                if (String.isNotBlank(listOfTargeting)){
                    listOfTargeting += ' | ';
                }
                listOfTargeting += 'Geography (include) ' + productNode.csmso__Description__c;
            }

            responseResult.put(configId, listOfTargeting);
        }

        System.debug('responseResult => ' + responseResult);
        return JSON.serialize(responseResult);
    }

    public class RequestResult {
        public String configId;
        public Id podcastGeoTargetingId;
        public Id podcastTargetingId;
    }
}