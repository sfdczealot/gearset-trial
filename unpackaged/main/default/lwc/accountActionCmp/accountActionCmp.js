import { LightningElement,api,wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import FORM_FACTOR from '@salesforce/client/formFactor';
import update2FACmp from 'c/update2FACmp';
import viewAgentLogsCmp from 'c/viewAgentAdminNetLogs';
import sendSMSCmp from 'c/sendSMSCmp';
import X2FA_FIELD from '@salesforce/schema/Account.X2FA__c';
import STATUS_FIELD from '@salesforce/schema/Account.Status__c';
import COUNTRY_FIELD from '@salesforce/schema/Account.Country__c';
import AGNET_NET_ID_FIELD from '@salesforce/schema/Account.AgentNet_ID__c';
import AGNET_MOBILE_FIELD from '@salesforce/schema/Account.PersonMobilePhone';
import AGNET_MOBILE_COUNTRY_CODE_FIELD from '@salesforce/schema/Account.Mobile_Country__c';  
import NAME_FIELD from '@salesforce/schema/Account.Name';
import EMAIL_FIELD from '@salesforce/schema/Account.PersonEmail';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import has2FAUpdatePermission from '@salesforce/customPermission/Account_Agent_2FA_Update';
import hasSendSMSPermission from '@salesforce/customPermission/Account_Send_SMS';
import hasViewAuditLogsPermission from '@salesforce/customPermission/Account_View_Audit_Logs';
import {getRecord,getFieldValue } from 'lightning/uiRecordApi';
import auditLogTitle from '@salesforce/label/c.View_Agent_Audit_Logs_Title_Label';
import sendSMSTitle from '@salesforce/label/c.Send_SMS_Title_Label';
export default class AccountActionCmp extends NavigationMixin(LightningElement)  {
    @api recordId;
    isLoading=true;
    agent;
    title;
    errorMessage;
    deviceType;
    connectedCallback(){
        this.deviceType=FORM_FACTOR;
    }
    get buttons(){
        return [
            {
                label:this.update2FAButtonLabel,
                disabled:!this.is2FAUpdateButtonVisible,
                name:"update2FA"
            },{
                label:auditLogTitle,
                disabled:!this.isViewAuditLogButtonVisible,
                name:"viewAgentLogs"
            },
            {
                label:sendSMSTitle,
                disabled:!this.isSendSMSButtonVisible,
                name:"sendSMS"
            }        
        ];
    }
    get is2FAUpdateButtonVisible(){
        return has2FAUpdatePermission;
    }
    get isSendSMSButtonVisible(){
        return hasSendSMSPermission;
    }
    get isViewAuditLogButtonVisible(){
        return hasViewAuditLogsPermission;
    }
    @wire(getRecord,{recordId:'$recordId',fields:[X2FA_FIELD,NAME_FIELD,STATUS_FIELD,EMAIL_FIELD,AGNET_NET_ID_FIELD,COUNTRY_FIELD,AGNET_MOBILE_FIELD,AGNET_MOBILE_COUNTRY_CODE_FIELD]})
    processAgentData(result){
        if(result.data){
            this.agent=result;
            this.isLoading=false;
        }
        else if(result.error){
            this.isLoading=false;
            this.errorMessage=this.processError(result.error);
        }
    }
    get showButtons(){
        if(this.agent){
            return true;
        }
        return false;
    }
    async handleClick(event){
        let cmpObj;
        let componentName;
        if(event.target.name === 'update2FA'){
            componentName='update2FACmp';
            cmpObj=update2FACmp;
            this.title=this.update2FAButtonLabel;
            this.openInDesktop(cmpObj);
        }
        else if(event.target.name === 'viewAgentLogs'){
            componentName='viewAgentAdminNetLogs';
            cmpObj=viewAgentLogsCmp;
            this.title=auditLogTitle;
            this.openComponent(componentName,cmpObj,'large');
        }
        else if(event.target.name === 'sendSMS'){
            componentName='sendSMS';
            cmpObj=sendSMSCmp;
            this.title=sendSMSTitle;
            this.openComponent(componentName,cmpObj,'large');
        }
    }
    openComponent(componentName,objCmp,modalSize){
        if(this.isMobile){
            this.openInMobile(componentName);
        }
        else{
            this.openInDesktop(objCmp,modalSize);
        }
    }
    async openInDesktop(cmpObj,modalSize){
        const result=await cmpObj.open({
            agentName:this.name,
            agentId:this.recordId,
            agentNetId:this.agentNetId,
            agentCountry:this.country,
            current2FA:this.x2FA,
            agentEmail:this.email,
            agentMobile:this.agentMobile,
            title:this.title,
            countryCode:this.agentMobileCountryCode,
            status:this.status,
            size: modalSize?modalSize:'small',
            oncomplete:(e)=>{
                // stop further propagation of the event
                e.stopPropagation();
                this.showToast(e.detail.toastTitle,e.detail.toastType,e.detail.toastMessage);
            }
        });
    }
    openInMobile(componentName){
        var compDefinition = {
            componentDef: "c:"+componentName,
            attributes: {
                agentName:this.name,
                agentId:this.recordId,
                agentNetId:this.agentNetId,
                agentCountry:this.country,
                current2FA:this.x2FA,
                agentEmail:this.email,
                agentMobile:this.agentMobile,
                status:this.status,
                countryCode:this.agentMobileCountryCode,
                title:this.title
            }
        };
        var encodedCompDef = btoa(JSON.stringify(compDefinition));
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: '/one/one.app#' + encodedCompDef
            }
        });
    }
    showToast(title,type,message) {
        const event = new ShowToastEvent({
            title: title,
            message:message,
            variant:type
        });
        this.dispatchEvent(event);
    }
    get x2FA(){
        return getFieldValue(this.agent.data,X2FA_FIELD);
    }
    get name(){
        return getFieldValue(this.agent.data,NAME_FIELD);
    }
    get email(){
        return getFieldValue(this.agent.data,EMAIL_FIELD);
    }
    get country(){
        return getFieldValue(this.agent.data,COUNTRY_FIELD);
    }
    get agentNetId(){
        return getFieldValue(this.agent.data,AGNET_NET_ID_FIELD);
    }
    get agentMobile(){
        return getFieldValue(this.agent.data,AGNET_MOBILE_FIELD);
    }
    get agentMobileCountryCode(){
        return getFieldValue(this.agent.data,AGNET_MOBILE_COUNTRY_CODE_FIELD);
    }
    get status(){
        return getFieldValue(this.agent.data,STATUS_FIELD);
    }
    get update2FAButtonLabel(){
        if(this.x2FA === 'Enabled' ){
            return 'Disable 2FA';
        }
        else{
            return 'Enable 2FA';
        }
    }
    get isMobile() {
        return FORM_FACTOR === 'Small';
    }
    processError(error){
        let errorMessage='Unknown Error';
        if(typeof error === 'string'){
            errorMessage=error;
        }
        else if(error.body){
            // UI Api read operation return an array of objects
            if(Array.isArray(error.body)){
                errorMessage=error.body.map(e=> e.message).join(', ');
            }
            //update wire error handling
            else if(error.body.output && error.body.output.errors){
                errorMessage=error.body.output.errors.map(e=> e.message).join(', ');
            }
            //UI api write operation, apex read and write error handling
            else if(typeof error.body.message === 'string'){
                errorMessage='';
                errorMessage+=(error.body.exceptionType)?error.body.exceptionType+' : ':'';
                errorMessage+=error.body.message;
                errorMessage+=(error.body.stackTrace)?' Stack Trace : '+error.body.stackTrace:'';
            }
        }
        return errorMessage;
    }
}