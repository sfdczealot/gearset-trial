import { LightningElement,api } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import SG_REGION from '@salesforce/customPermission/SG_Region';
import MY_REGION from '@salesforce/customPermission/MY_Region';
import TH_REGION from '@salesforce/customPermission/TH_Region';
import thCountry from '@salesforce/label/c.THAILAND_REGION';
import myCountry from '@salesforce/label/c.MALAYSIA_REGION';
import sgCountry from '@salesforce/label/c.SINGAPORE_REGION';
import sendSMSWire from '@salesforce/apex/AccountActionsCtlr.sendSMS';
import getAgentAccounts from '@salesforce/apex/AccountActionsCtlr.getAgentAccounts';
import permissionToSendSMSToMultipleAgents from '@salesforce/customPermission/Account_Allow_To_Send_Multiple_SMS';
import FORM_FACTOR from '@salesforce/client/formFactor';
export default class TestCmp2 extends NavigationMixin(LightningModal)  {
    errorMessage;
    @api agentCountry;
    @api title;
    @api agentMobile;
    columns=[{label:'Agent Net Key',fieldName:'AgentKey__c'}, { label: 'Name', fieldName: 'Name' },{ label: 'Email', fieldName: 'PersonEmail'},{label: 'Mobile Number', fieldName: 'PersonMobilePhone'}];
    data=[];
    agentMobileNumbers;
    smsCharacterLimit=160;
    selectAgents=false;
    findAgentValidationMessage;
    @api agentId;
    @api countryCode;
    remainingCharacterLimit=160;
    message;
    validationMessage;
    isLoading=false;
    connectedCallback(){
        this.selectedMobileNumbers=this.agentMobile;
        this.onLoadValidation();
    }
    onLoadValidation(){
        if(!this.agentCountry){
            this.errorMessage='Country is not present on this agent record.';
        }
        else if(!this.checkAccessToSendSMSBasedOnCountry()){
            this.errorMessage='You don\'t have permission to send SMS to this agent.';
        }
    }
    
    getSelectedRecords(event) {
        const selectedRows = event.detail.selectedRows;
        // Display that fieldName of the selected rows
        for (let i = 0; i < selectedRows.length; i++) {
            console.log('You selected: ' + selectedRows[i].mobile);
        }
    }
    checkAccessToSendSMSBasedOnCountry(){
        if((this.agentCountry.toLowerCase() === sgCountry.toLowerCase() && this.hasPermissionForSGRecords) || (this.agentCountry.toLowerCase() === thCountry.toLowerCase() && this.hasPermissionForTHRecords) || (this.agentCountry.toLowerCase() === myCountry.toLowerCase() && this.hasPermissionForMYRecords)){
            return true;
        }
        return false;
    }
    findAgents(event){
        if(!this.agentMobileNumbers  ){
            this.checkNumberValidity('agentMobileNumbers',this.agentMobileNumbers);
            return;
        }
        else if(!this.checkNumberValidity('agentMobileNumbers',this.agentMobileNumbers)){
            return;
        }
        let mobileNumbers=this.agentMobileNumbers.replace(/\n/g,'-').replace(/\s/g,'').split(/[-,]+/);
        if(!mobileNumbers || mobileNumbers.length <= 0 ){
            this.checkNumberValidity('agentMobileNumbers',this.agentMobileNumbers);
            return;
        }

        this.isLoading=true;
        this.data=[];
        this.findAgentValidationMessage=undefined;
        getAgentAccounts({agentMobileNumbers:mobileNumbers,country:this.agentCountry})
        .then(result=>{
            let data=result;
            if(result){
                let agentMobileNumbers=Object.keys(result);
                if(agentMobileNumbers && agentMobileNumbers.length > 0){
                    agentMobileNumbers.forEach(number=>{
                        this.data.push(...data[number]);
                     })
                     this.data=JSON.parse(JSON.stringify(this.data));
                }
                else{
                    this.findAgentValidationMessage='No agent found';
                }
            }
            this.isLoading=false;
        })
        .catch(error=>{
            this.isLoading=false;
        });
    }
    get showAgentsDetails(){
        if(this.data && this.data.length > 0){
            return true;
        }
        return false;
    }
    handleChange(event){
        if(event.target.name === 'mobile'){
            this.selectedMobileNumbers=event.detail.value;
            this.checkNumberValidity('mobile',this.selectedMobileNumbers);
        }
        else if(event.target.name === 'agentMobileNumbers'){
            this.agentMobileNumbers=event.detail.value;
            this.checkNumberValidity('agentMobileNumbers',this.agentMobileNumbers);
        }
        else if(event.target.name === 'message'){
            this.message=event.detail.value;
            this.remainingCharacterLimit=this.smsCharacterLimit - event.detail.value.length;
            this.checkMessageValidity();
        }
    }
    addAgents(){
        this.selectAgents=true;
        this.agentMobileNumbers=this.agentMobile;
    }
    addSelectedAgents(event){
        let dataTableCmp=this.refs.agentsDataTable;
        let selectedRecords;
        if(dataTableCmp){
            selectedRecords=dataTableCmp.getSelectedRows();
        }
        if(selectedRecords && selectedRecords.length > 0){
            this.selectedMobileNumbers='';
            selectedRecords.forEach((agentRecord,index)=>{
                if(index !== 0) this.selectedMobileNumbers+='\n';
                this.selectedMobileNumbers+=agentRecord.PersonMobilePhone;
            });
            this.backToMainScreen();
        }
        else{
            this.findAgentValidationMessage='Please select a record.';
        }
    }
    backToMainScreen(){
        this.data=[];
        this.selectAgents=false;
        this.findAgentValidationMessage=undefined;
    }
    hideModalBox(){
        this.selectAgents=false;
    }
    sendSms(){
        if(!this.checkMessageValidity()){
            return;
        }
        if(!this.checkNumberValidity('mobile',this.selectedMobileNumbers)){
            return;
        }
        this.isLoading=true;
        let listOfMobileNumber=this.selectedMobileNumbers.split(/[\n,]+/);
        sendSMSWire({message:this.message,mobileNumbers:listOfMobileNumber,country:this.agentCountry}).then(result=>{
            this.enableClose();
            if(result.isSuccess){
                this.handleClose();
                this.showToast('Success','success','Send SMS initiated successfully!');
            }
            else{
                this.isLoading=false;
                this.errorMessage=result.errorMessage;
            }
        }).catch(err=>{
            this.isLoading=false;
            this.errorMessage=this.processError(err);
        });
    }
    handleClose(){
        this.close();
        this.isLoading=false;
        if(this.isMobile){
            this.navigateToRecordViewPage();
        }
    }
    navigateToRecordViewPage() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.agentId,
                objectApiName: 'Account',
                actionName: 'view'
            }
        });
    }
    enableClose(){
        if(!this.isMobile){
            this.disableClose = false;
        }
    }
    get isMobile() {
        return FORM_FACTOR === 'Small';
    }
    showToast(title,type,message) {
        const event = new ShowToastEvent({
            title: title,
            message:message,
            variant:type
        });
        this.dispatchEvent(event);
    }
    get hasPermissionToSendMultipleSMS(){
        if(permissionToSendSMSToMultipleAgents){
            return true;
        }
        return false;
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
    checkMessageValidity(){
        let isValid=true;
        let messageInput = this.template.querySelector("[data-name='message']");
        if(!this.message || this.message.trim().length < 1){
            isValid=false;
            messageInput.setCustomValidity("Please enter the message.");
        }
        else{
            messageInput.setCustomValidity(""); 
        }
        messageInput.reportValidity();
        return isValid;
    }
    
    checkNumberValidity(selector,value){
        let isValid=true;
        let numberInput = this.template.querySelector("[data-name='"+selector+"']");
        let specialChars = /[A-Za-z`!@#$%^&*()_+\-=\[\]{};':"\\|.<>\/?~]/;
        let numbers = /[0-9]/g;
        let message;
        if(!value){
            isValid=false;
            message='Please enter agent mobile number.';
        }
        // Validate capital letters
        else if (value && (specialChars.test(value)  || !value.match(numbers))) {
            isValid=false;
            message='Please enter valid mobile numbers separated by comma(,) or in new line.';
        }
        if(!isValid){
            numberInput.setCustomValidity(message);  
        }
        else numberInput.setCustomValidity(""); 
        numberInput.reportValidity();
        return isValid;
    }
    get hasPermissionForTHRecords(){
        if(TH_REGION){
            return true;
        }
        return false;
    }
    get hasPermissionForSGRecords(){
        if(SG_REGION){
            return true;
        }
        return false;
    }
    
    get hasPermissionForMYRecords(){
        if(MY_REGION){
            return true;
        }
        return false;
    }
}