import { LightningElement ,api ,wire,track} from 'lwc';
import runBatch from '@salesforce/apex/runRewardCalculatorController.runBatch';
import checkCurrenttBatch from '@salesforce/apex/runRewardCalculatorController.checkCurrenttBatch';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation'; 
import errorMsg from '@salesforce/label/c.ADD_ERROR_UNDETECTED'; 
export default class RunRewardsCalculation extends NavigationMixin(LightningElement) {
  
   @track value = 'Singapore';
   @track batchInExecution = false;
   @track showSpinner = false;
   @track errors;
   @track previousBatch_records = [];
   @track display_records=[];
   @track parseDataResponse;
   @track pageSize = 10;
   @track pageNumber = 1;
   @track totalRecords = 0;
   @track totalPages = 0;
   @track recordEnd = 0;
   @track recordStart = 0;
   @track isPrev = true;
   @track isNext = true;
   @track i= 0;
   @track k= 0;
   rowOffset = 0;
 
 
   @track columns = [
    { label: 'Country', fieldName: 'Country' , sortable: true},
    { label: 'Number of Agents ', fieldName: 'numOfAgents', type: 'Integer',sortable: true },
    {label:'Last Run By', fieldName:'LastRunByName',sortable: true,type: "button", 
    typeAttributes: { label: { fieldName: 'LastRunByName',type: 'text'},name :'runBy' , variant: 'base'}},
    { label: 'Last Run Date', fieldName: 'LastRunDate', sortable: true ,type: 'date', 
    typeAttributes: {day: 'numeric',month: 'short',year: 'numeric',hour: '2-digit',minute: '2-digit',
      second: '2-digit',hour12: true}},
    { label:'CSV', fieldName:'CSV',type: "button", 
    typeAttributes: {label: 'Click Here',name :'viewDoc',variant: 'base'}}
]; 
    
@wire(checkCurrenttBatch, {
  country: 'Singapore'
}) resWrapper(result){
  if(result.data){
  this.previousBatch_records = [];
  var tempVar = JSON.parse(result.data.response).completedAsynchJob;
  this.previousBatch_records = tempVar;
 // this.batchInExecution = JSON.parse(result.data.response).processingBatch;
  this.totalRecords = this.previousBatch_records.length;
  this.totalPages = Math.ceil(this.totalRecords/ this.pageSize);
  this.displayRecords();
  }
  
}

handleChange(event) {
    this.value = event.detail.value;
}
runCalculation(event) {

    runBatch({country : 'Singapore'})
    .then((result)=>{
      if(result.isSuccess){
        console.log(result);
        if(result.message == 'Rewards calculation already running. Please wait for existing run to complete'){
          this.showToast('ERROR',result.message);
        }
        if(result.message == 'Reward Calculation Started!!!!')
          this.showToast('SUCCESS',result.message);
        
      }
      else{
          this.showToast('ERROR',result.message);
      }
    })
    .catch((error) => {
          this.showToast('ERROR',errorMsg);
    }) 
    .finally(() => {
    });  
  
}
get options() {
  return [
      { label: 'Singapore', value: 'Singapore' },
      ];
}

showToast(title,msg) {
    const event = new ShowToastEvent({
      title: title,
      message: msg,
      variant: title
     });
    this.dispatchEvent(event);
  };
  defaultSortDirection = 'asc';
  sortDirection = 'asc';
  sortedBy;
  
    sortBy(field, reverse, primer) {
        const key = primer
            ? function(x) {
                  return primer(x[field]);
              }
            : function(x) {
                  return x[field];
              };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };
    }

    onHandleSort(event) {
        const { fieldName: sortedBy, sortDirection } = event.detail;
        const cloneData = [];
        for(var i in this.previousBatch_records){
          if(this.previousBatch_records[i] != undefined){
            cloneData.push(this.previousBatch_records[i]);
          }
        }
        cloneData.sort(this.sortBy(sortedBy, sortDirection === 'asc' ? 1 : -1));
        this.previousBatch_records = cloneData;
        this.sortDirection = sortDirection;
        this.sortedBy = sortedBy;
        this.displayRecords();
    }

    //handle next
    handleNext(){
      this.pageNumber = this.pageNumber+1;
      this.rowOffset += 10;
      this.displayRecords();
  }

  //handle prev
  handlePrev(){
      this.pageNumber = this.pageNumber-1;
      this.rowOffset -= 10;
      this.displayRecords();
  }
  displayRecords(event) {
    this.display_records = [];
    this.k = (this.pageNumber - 1) * this.pageSize;
    this.recordStart = this.k +1;
    this.recordEnd = this.pageSize * this.pageNumber;
    if(this.recordEnd > this.totalRecords) {
      this.recordEnd = this.totalRecords;
    }
    
    for(var i=0; i< this.pageSize; i++){
      this.display_records.push(this.previousBatch_records[this.k]);
      this.k++;
    }
      if(this.previousBatch_records[this.k]!=null){
          this.isNext = false;
      } else{
       this.isNext = true; 
      }
      if(this.pageNumber == 1){
       this.isPrev = true;
      } else{
       this.isPrev = false;
      }  
     
  }

  callRowAction(event){
    const actionName = event.detail.action.name;
    if(actionName == 'runBy'){
      this[NavigationMixin.Navigate]({  
        type: 'standard__webPage',  
        attributes: {  
            url:event.detail.row.LastRunBy
        }  
    })  
    }
    else if(actionName == 'viewDoc'){
      this[NavigationMixin.Navigate]({  
        type: 'standard__webPage',  
        attributes: {  
            url:event.detail.row.CSV
        }  
      })  
    }
  } 
 
}