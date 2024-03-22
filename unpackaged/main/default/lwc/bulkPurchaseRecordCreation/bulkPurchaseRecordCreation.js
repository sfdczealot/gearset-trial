import { LightningElement, track, api } from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import csvFileRead from '@salesforce/apex/BulkPurchaseRecordCreationController.csvFileRead';

export default class BulkPurchaseRecordCreation extends LightningElement {
@track isLoading = false;

// accepted parameters
get acceptedCSVFormats() {
    return ['.csv'];
}

fileName = '';
		
		handleFilesChange(event) {
				const excel = event.target.files[0];
				if(excel.type == 'application/vnd.ms-excel' || excel.type == 'text/csv'){
					this.fileName = excel.name;
					var reader = new FileReader()
					reader.onload =()=>{
						var base64 = reader.result.split(',')[1]
						this.fileReceived = {
							'filename':excel.name,
							'base64':base64
						}
					}
					reader.readAsDataURL(excel)
				}
    }
		
		saveFile(){
            this.isLoading = true;
            csvFileRead({fileContents: this.fileReceived.base64})
            .then(result =>{
                debugger;
                window.console.log('result ===> '+result);
                eval("$A.get('e.force:refreshView').fire();");
                this.isLoading = false;
                this.showToast('Success','The Batch for Record Creation is in Process......');
            })
            .catch(error => {
                debugger;
                this.error = error;
                console.log(this.error);
                this.isLoading = false;
                this.showToast('Error',this.error.body.message);
            });
		}

        showToast(title,msg) {
            const event = new ShowToastEvent({
                title: title,
                message: msg,
                variant: title,
                mode: 'pester'
             });
            this.dispatchEvent(event);
          };
}