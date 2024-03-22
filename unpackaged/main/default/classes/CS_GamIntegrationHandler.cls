/**
 * Created by jameshladek on 3/10/20.
 */

global class CS_GamIntegrationHandler extends CS_StepHandlerBase {
    global CS_GamIntegrationHandler() {
    }

    global override CSPOFA__Orchestration_Step__c doWork(Object params) {
        Map<String, Object> paramsType = (Map<String, Object>) params;
        Callable c = (Callable) Type.forName('CS_GamIntegrationHelper').newInstance();
        return (CSPOFA__Orchestration_Step__c) c.call((String) paramsType.get('action'), paramsType);
    }
}