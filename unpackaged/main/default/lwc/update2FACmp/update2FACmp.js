import { LightningElement,api } from 'lwc';
import LightningModal from 'lightning/modal';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecordNotifyChange  } from 'lightning/uiRecordApi';
import updateAgent2FA from '@salesforce/apexContinuation/AccountActionsCtlr.updateAgent2FAInAgentNet';
import updateAgent2FAInSF from '@salesforce/apex/AccountActionsCtlr.updateAgent2FAInSF';
import SG_REGION from '@salesforce/customPermission/SG_Region';
import MY_REGION from '@salesforce/customPermission/MY_Region';
import TH_REGION from '@salesforce/customPermission/TH_Region';
import thCountry from '@salesforce/label/c.THAILAND_REGION';
import myCountry from '@salesforce/label/c.MALAYSIA_REGION';
import sgCountry from '@salesforce/label/c.SINGAPORE_REGION';
export default class Update2FACmp extends LightningModal {
    @api current2FA;
    @api agentName;
    @api agentCountry;
    @api agentId;
    isLoading=true;
    @api title;
    enable2FA;
    connectedCallback(){
        this.isLoading=false;
        this.onLoadValidation();
    }
    onLoadValidation(){
        debugger;
        if(!this.agentCountry){
            this.errorMessage='Country is not present on this agent record.';
        }
        else if(!this.checkAccessToUpdate2FABasedOnCountry()){
            this.errorMessage='You don\'t have permission to update 2FA on this agent record.';
        }
    }
    checkAccessToUpdate2FABasedOnCountry(){
        debugger;
        //As of not this feature is only enabled for SG agents
        if((this.agentCountry.toLowerCase() === sgCountry.toLowerCase() && this.hasPermissionForSGRecords)){ //|| (this.agentCountry.toLowerCase() === thCountry.toLowerCase() && this.hasPermissionForTHRecords) || (this.agentCountry.toLowerCase() === myCountry.toLowerCase() && this.hasPermissionForMYRecords)){
            return true;
        }
        return false;
    }
    
    get bodyMessage(){
        if(this.current2FA === 'Enabled' ){
            this.enable2FA=false;
            return 'Are you sure you want to disable the 2FA of the agent ';
        }
        else{
            this.enable2FA=true;
            return 'Are you sure you want to enable the 2FA of the agent ';
        }
    }
    submit(){
        this.disableClose = true;
        this.isLoading=true;
        updateAgent2FA({enable2FA:this.enable2FA,agentId:this.agentId}).then(result=>{
            //Success
            if(result.isSuccess){
                this.errorMesxsage=undefined;
                updateAgent2FAInSF({ enable2FA:this.enable2FA,agentId:this.agentId }).then(()=>{
                    getRecordNotifyChange([{recordId: this.agentId}]);
                    this.disableClose = false;
                    this.close();
                    this.isLoading=false;
                    this.showToast('Success','success','2FA updated successfully!');
                }).catch(error=>{
                    this.errorMessage=this.processError(error);
                    this.isLoading=false;
                    this.disableClose = false;
                });
                result=undefined;
            }
            //Handle error 
            else{
                this.errorMessage=this.processError(result.errorMessage);
                this.isLoading=false;
                this.disableClose = false;
            }
        }).catch(error => {
            this.disableClose = false;
            this.errorMessage=this.processError(error);
            this.isLoading=false;
        });
    }
    handleClose(){
        this.close();
        this.isLoading=false;
    }
    showToast(title,type,message) {
        const event = new ShowToastEvent({
            title: title,
            message:message,
            variant:type
        });
        this.dispatchEvent(event);
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