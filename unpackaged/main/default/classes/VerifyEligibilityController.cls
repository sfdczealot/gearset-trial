/*
* TestClass :VerifyEligibilityController_Test
*/
public class VerifyEligibilityController {
    
    @AuraEnabled
    public static void validationCampaignEligibilityQuery(String recordId){
        
        Campaign_Eligibility__c ce = [Select id, Status__c, Criteria_Type__c,Rule_Name_Extension__c from Campaign_Eligibility__c where Id = :recordId ];
        
        List<String> stList = new List<String>();
        if(ce.Status__c == 'Active'){
            if(ce.Criteria_Type__c == 'SOQL'){
                
                if(string.isBlank(ce.Criteria_Type__c)){
                    throw new AuraHandledException('Please write SOQL.');
                }else{
                    if(String.isBlank(ce.Rule_Name_Extension__c)){
                        throw new AuraHandledException('Rule Name Extension can not be blank.');
                    }else {
                        stList = ce.Rule_Name_Extension__c.split(';');
                    }
                    
                    for(String st : stList){
                        if(st.contains('Select') || st.contains('select')){
                            try{
                                DataBase.query(st);  
                            }catch(Exception e){
                                system.debug('Error '+e.getMessage());
                                throw new AuraHandledException(e.getMessage());
                            } 
                        }else{
                            throw new AuraHandledException('Please fill a valid SOQL.');
                        }
                        
                    }
                }
                
            }else if(ce.Criteria_Type__c == 'Apex Method'){
                if(String.isNotBlank(ce.Rule_Name_Extension__c) && ce.Rule_Name_Extension__c.contains(';')){
                    list<string> classAndMethod = ce.Rule_Name_Extension__c.split(';');
                    if(classAndMethod != null && classAndMethod.size() == 2
                       && String.isNotBlank(classAndMethod[0].replaceAll( '\\s+', ''))
                       && String.isNotBlank(classAndMethod[1].replaceAll( '\\s+', ''))
                      ){
                          //add Class Name and method logic
                          String result = validateClassAndMethod(classAndMethod[0],classAndMethod[1]);
                          if(result.contains('Error')){
                              throw new AuraHandledException(result);
                          }
                      }else{
                          throw new AuraHandledException('Please check class name and method name format.');
                      }
                }else{
                    throw new AuraHandledException('Please fill class name and method name.');
                }
            }else{
                throw new AuraHandledException('Please select Criteria Type.');
            }
        }else{
            throw new AuraHandledException('Campaign eligibility is not active');
        }
        
    }
    
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