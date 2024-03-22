public class CampaignEligibilityHelper {
	
    public static string validateClassAndMethod(String className, String methodName){
        
        Callable extension;
        try{
            extension = (Callable) Type.forName(className).newInstance();
        }catch(Exception e){
            if(e.getMessage().contains('null object')){
                return 'Error : Please fill valid class name';
            }else{
                return 'Error : '+e.getMessage();
            }
        }
        
        return string.valueOf(extension.call(methodName, new Map<String, Object>()));
        
    }
}