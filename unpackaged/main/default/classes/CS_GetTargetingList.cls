global class CS_GetTargetingList implements csmso.CSRemoteActionDelegation.CSRemoteActionDelegate {
    global String performAction(String params) {
        Map<String, Object> currentTargetingsByGuid = (Map<String, Object>)JSON.deserializeUntyped(params);
        System.debug('currentTargetingsByGuid => ' + currentTargetingsByGuid);

        Map<String, Object> targetingListByGuid = CS_CurrentTargetingsTransformer.transformToTargetingList(currentTargetingsByGuid);

        System.debug('targetingListByGuid => ' + targetingListByGuid);

        return JSON.serialize(targetingListByGuid);
    }
}