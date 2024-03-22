@isTest
public class GenricClassForCallout_Test {
    
    @isTest
    static void runTest(){
        
        map<string,string> headerParameters = new map<string,string>();
        headerParameters.put('Content-Type', 'application/json');
        headerParameters.put('x-api-key', 'RootEndpoint_Key');
        headerParameters.put('Content-Type', 'application/json');
        Test.startTest();
        GenricClassForCallout.runningInASandbox();
        GenricClassForCallout.GenericbasicAuthCallout(headerParameters, 'Endpoint', 'requestJson', 'methodName', true, false, null,null);
        Test.stopTest();
    }
}