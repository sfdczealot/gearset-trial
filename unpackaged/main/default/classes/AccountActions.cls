/*******************************************************************
 *	Author: Suraj Bisht
 *  Class Name: AccountActions
 *  Description: Class to define invocable action for account object
 * 	Test Class: AccountActions_Test
 ******************************************************************/
public with sharing class AccountActions {
    
 /*******************************************************************
 *	Author: Suraj Bisht
 *  Description: Method will update the account status 
 ******************************************************************/
    @InvocableMethod(label='Update account status' description='Update account Status')
    public static void updateAccountStatus(List<InputParamCls> inputs) {
        if(inputs != null && !inputs.isEmpty()){
            list<Account> listOfAccountToUpdate=new list<Account>();
            for(InputParamCls input:inputs){
                Account objAccount=new Account(Id=input.accountId,Status__c=input.status);
                if(objAccount.Status__c == 'Suspended'){
                    objAccount.Suspended_Date_Time__c=Datetime.now();
                    objAccount.isSuspended__c=true;
                }
                listOfAccountToUpdate.add(objAccount);
            } 
            //Avoiding partial dml to show any error if occurred to user on screen flow
            update listOfAccountToUpdate;
        }
    } 
/*******************************************************************
 *	Author: Suraj Bisht
 *  Description: Class defining the input paramater that can be passed to apex from flow
******************************************************************/
    public class InputParamCls{
        @InvocableVariable public Id accountId;
        @InvocableVariable public String status;    
    }
}