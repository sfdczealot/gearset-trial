import { LightningElement,api ,wire,track} from 'lwc';
import validateApprovalCap from '@salesforce/apex/newLSDUpdaterequestController.validateApprovalCap';
import LSD_Update from '@salesforce/schema/LSD_Update__c'
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class NewLSDUpdaterequest extends LightningElement {
    @api recordId;
    @api objectApiName;
    @track loyaltyDate;
    @track allowRequest;
    @track showError = false;
    @track isModalOpen = false;
    @track showSpinner = false;

    @wire(validateApprovalCap, {
        accId: '$recordId'
    }) resWrapper(result){
        if(result.data){
            this.parseDataResponse = JSON.parse(result.data.response);
            this.loyaltyDate = this.parseDataResponse.loyaltyStartDate;
            this.allowRequest = this.parseDataResponse.allowRequest;
        }
        if(this.allowRequest == false){
            this.showError = true;
        }
    }
    openModal() {
        // to open modal set isModalOpen tarck value as true
        this.isModalOpen = true;
    }
    closeModal() {
        // to close modal set isModalOpen tarck value as false
        this.isModalOpen = false;
    }
    handleSuccess() {
        this.showSpinner = false;
        this.isModalOpen = false;
        this.allowRequest = false;
        this.showToast('SUCCESS','LSD Update request has been successfully created');
        eval("$A.get('e.force:refreshView').fire();");
    }
 
    handleSubmit(event){
        this.showSpinner = true;
        event.preventDefault();       // stop the form from submitting
        const fields = event.detail.fields;
        fields.Account__c = this.recordId;
        fields.Source__c =  'Manual';
        fields.Approval_Status__c = 'Submit for approval';
        this.template.querySelector('lightning-record-edit-form').submit(fields);
     }
     showToast(title,msg){
        const event = new ShowToastEvent({
            title: title +'! ',
            message: msg,
            variant: title
           });
          this.dispatchEvent(event);
        }
}