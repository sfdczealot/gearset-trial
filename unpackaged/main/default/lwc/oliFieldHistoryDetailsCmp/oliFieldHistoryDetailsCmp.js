import { LightningElement ,api,wire} from 'lwc';
import getHistoryDetails from '@salesforce/apexContinuation/OliFieldHistoryDetailsCls.getHistoryDetails';
export default class OliFieldHistoryDetailsCmp extends LightningElement {
    @api recordId;
    spinner=true;
    errorMessage;
    columns = [
        { label: 'Type', fieldName: 'Type__c',fixedWidth: 70 },
        { label: 'Field Name', fieldName: 'Field_Name__c'},
        { label: 'Old Value', fieldName: 'Old_Value__c' },
        { label: 'New Value', fieldName: 'New_Value__c' },
        {   label:'Created By',fieldName:'createdByUrl',type:'url',
            typeAttributes: {   target: '_blank' ,
                label: {
                    fieldName: 'CreatedById'
                },
                tooltip: { fieldName: 'CreatedById' }}
        },
        { label: 'Name', fieldName: 'oliUrl',fixedWidth: 110 ,type:'url',typeAttributes: {
            label: {
                fieldName: 'Name'
            }, target: '_blank',tooltip: { fieldName: 'Name' } } },
        { label: 'User', fieldName: 'userUrl' ,type:'url',typeAttributes: {
            label: {
                fieldName: 'User__c'
            }, target: '_blank',tooltip: { fieldName: 'User__c' } }
        }   , 
        {label:'Created Date',fieldName:'CreatedDate', type: 'date',typeAttributes: {
                day: 'numeric',
                month: 'short',
                year: 'numeric',
                hour: '2-digit',
                minute: '2-digit',
                second: '2-digit',
                hour12: true
            }
        } 
        
    ];
    @wire(getHistoryDetails,{opportunityId: '$recordId'})
    processHistoryResults(result) {
        this.spinner=true;
        if(result){
            //Success
            if(result.data){
                if(result.data.isSuccess){
                    this.response=this.processResult(result.data.oliHistoryRecords);
                    this.errorMessage=undefined;
                }
                //Handle error 
                else{
                    this.errorMessage=this.processError(result.data.errorMessage);
                }
                this.spinner=false;
            }
            //Error
            else if(result.error){
                this.errorMessage=this.processError(result.error);
                this.spinner=false;
            }
        }
    }
    processResult(data){
        let tempRecs=[];
        //prossing callout response to assign value in url type column
        if(data && Array.isArray(data)){
            data.forEach( ( record ) => {
                let tempRec = Object.assign( {}, record );  
                tempRec.createdByUrl = '/' + tempRec.CreatedById;
                tempRec.userUrl = '/' + tempRec.User__c;
                tempRec.oliUrl = '/' + tempRec.LineId__c;
                tempRecs.push( tempRec );
            });
        }
        return tempRecs;
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